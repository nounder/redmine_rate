class RatesController < ApplicationController
  include SortHelper
  include RatesHelper

  SORT_OPTIONS = {
    'date_in_effect' => "#{Rate.table_name}.date_in_effect",
    'project_id' => "#{Project.table_name}.name"
  }

  helper :users
  helper :queries
  helper :sort

  before_filter :require_view_permission
  before_filter :require_edit_permission, only: [:new, :create, :update_form]
  before_filter :permit_params
  before_filter :setup_query, only: [:index]

  def index
    if params[:user_id]
      @query.add_filter('user_id', '=', [ params[:user_id] ])
      session[:query] = { type: 'RateQuery', filters: @query.filters }

      return redirect_to(rates_path)
    end

    @limit = per_page_option
    @rate_count = @query.rate_count
    @rate_pages = Paginator.new(@rate_count, @limit, params['page'])

    @rates = @query.rates(order: sort_clause,
                          offset: @rate_pages.offset,
                          limit: @limit)

    respond_to do |format|
      format.html { render :action => 'index', :layout => !request.xhr?}
    end
  end

  def new
    @project = Project.find(params[:project_id]) if params[:project_id]
    @user = User.find(params[:user_id]) if params[:user_id]

    @rate = Rate.new
    @rate.project = @project if @project

    if @user
      @rate.user = @user
      @rates = Rate.visible.recently.where(user_id: @user.id)
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @rate = Rate.find(params[:id])
  end

  def create
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
      redirect_to user_rates_path(@rate.user_id)
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

  def update_form
    @rate = Rate.new(params[:rate])
  end

  private

  def setup_query
    if session[:query] and session[:query][:type] == 'RateQuery'
      @query = RateQuery.new(name: '_', filters: session[:query][:filters])
      session.delete(:query)
    else
      @query = RateQuery.new(name: '_')
      @query.build_from_params(params)
    end

    sort_update(SORT_OPTIONS)
    @query.sort_criteria = sort_criteria.to_a

    @query.group_by = 'user' unless params[:f]
  end

  def require_view_permission
    unless RedmineRate.supervisor? \
      or User.current.allowed_to_globally?(:view_rates, {})
      render_403
    end
  end

  def require_edit_permission
    unless RedmineRate.supervisor? \
          or User.current.allowed_to_globally?(:edit_rates, {})
      render_403
    end
  end

  def permit_params
    params.permit! if defined?(ActionController::Parameters)
  end

  def rate_params
    params[:rate]
  end
end
