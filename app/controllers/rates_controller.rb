class RatesController < ApplicationController
  include SortHelper
  include RatesHelper

  SORT_OPTIONS = {
    'date_in_effect' => "#{Rate.table_name}.date_in_effect",
    'project_id' => "#{Project.table_name}.name"
  }

  helper :users
  helper :sort

  before_filter :require_admin, only: [:edit, :update, :destroy]
  before_filter :require_view_permission
  before_filter :require_edit_permission, only: [:new, :create]
  before_filter :permit_params
  before_filter :find_user, only: [:index, :new]


  def index
    sort_init '#{Rate.table_name}.date_in_effect', 'desc'
    sort_update SORT_OPTIONS

    @rates = Rate.visible.where(user_id: @user.id).order(sort_clause)

    respond_to do |format|
      format.html { render :action => 'index', :layout => !request.xhr?}
    end
  end

  def new
    @rate = Rate.new(user_id: @user.id)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @rate = Rate.find(params[:id])
  end

  def create
    project = project_with_editable_rates
                .where(id: rate_params[:project_id]).first

    # only admins can assign global rates
    if project.nil? and not RedmineRate.supervisor?
      return render_403
    end

    @rate = Rate.new(rate_params)

    @rate.save

    respond_to do |format|
      format.html do
        if @rate.valid?
          redirect_to user_rates_path(@rate.user)
        else
          render :new
        end
      end
      format.js
    end
  end

  def update
    @rate = Rate.find(params[:id])

    if @rate.update_attributes(rate_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_back_or_default(rates_url(user_id: @rate.user_id))
    else
      if @rate.locked?
        flash[:error] = l(:notice_rate_locked)
        @rate.reload # Removes attribute changes
      end
      render :edit
    end
  end

  def destroy
    @rate = Rate.find(params[:id])

    if @rate.locked?
      flash[:error] = l(:notice_rate_locked)

      redirect_to user_rates_path(@rate.user_id)
    else
      @rate.destroy

      flash[:notice] = l(:notice_successful_delete)

      redirect_to user_rates_path(@rate.user_id)
    end
  end

  private

  def require_view_permission
    unless RedmineRate.supervisor? \
      or User.current.allowed_to_globally?(:view_rates)
      render_403
    end
  end

  def require_edit_permission
    unless RedmineRate.supervisor? \
          or User.current.allowed_to_globally?(:edit_rates)
      render_403
    end
  end

  def permit_params
    params.permit! if defined?(ActionController::Parameters)
  end

  def rate_params
    params[:rate]
  end

  def find_user
    @user = User.find(params[:user_id])
  end
end
