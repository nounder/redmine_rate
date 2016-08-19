class RatesController < ApplicationController
  include SortHelper

  SORT_OPTIONS = {
    'date_in_effect' => "#{Rate.table_name}.date_in_effect",
    'project_id' => "#{Project.table_name}.name"
  }

  helper :users
  helper :sort

  before_filter :permit_params
  before_filter :require_admin, only: [:edit, :update, :destroy]
  before_filter :find_user, only: [:index, :new]


  def index
    sort_init '#{Rate.table_name}.date_in_effect', 'desc'
    sort_update SORT_OPTIONS

    @rates = Rate.visible.where(user_id: @user.id).order(sort_clause)

    respond_to do |format|
      format.html { render :action => 'index', :layout => !request.xhr?}
      format.xml  { render :xml => @rates }
    end
  end

  def new
    @rate = Rate.new(user_id: @user.id)

    respond_to do |format|
      format.html
      format.js
      format.xml  { render :xml => @rate }
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
      format.js do
        if @rate.valid?
        else
        end
      end
    end
  end

  def update
    @rate = Rate.find(params[:id])

    respond_to do |format|
      # Locked rates will fail saving here.
      if @rate.update_attributes(rate_params)
        flash[:notice] = 'Rate was successfully updated.'
        format.html { redirect_back_or_default(rates_url(:user_id => @rate.user_id)) }
        format.xml  { head :ok }
      else
        if @rate.locked?
          flash[:error] = "Rate is locked and cannot be edited"
          @rate.reload # Removes attribute changes
        end
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rate.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @rate = Rate.find(params[:id])
    @rate.destroy

    respond_to do |format|
      format.html {
        flash[:error] = "Rate is locked and cannot be deleted" if @rate.locked?
        redirect_back_or_default(rates_url(:user_id => @rate.user_id))
      }
      format.xml  { head :ok }
    end
  end

  private

  def permit_params
    params.permit! if defined?(ActionController::Parameters)
  end

  def rate_params
    params[:rate]
  end

  def find_user
    @user = User.find(params[:user_id])
  end

  def set_back_url
    @back_url = params[:back_url]
    @back_url
  end
end
