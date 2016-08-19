class RatesController < ApplicationController
  include SortHelper

  SORT_OPTIONS = {
    'date_in_effect' => "#{Rate.table_name}.date_in_effect",
    'project_id' => "#{Project.table_name}.name"
  }

  helper :users
  helper :sort

  before_filter :permit_params
  before_filter :require_admin
  before_filter :require_user_id, :only => [:index, :new]
  before_filter :set_back_url
  skip_before_filter  :verify_authenticity_token

  def index
    sort_init '#{Rate.table_name}.date_in_effect', 'desc'
    sort_update SORT_OPTIONS

    @rates = Rate.history_for_user(@user, sort_clause)

    respond_to do |format|
      format.html { render :action => 'index', :layout => !request.xhr?}
      format.xml  { render :xml => @rates }
    end
  end

  def new
    @rate = Rate.new(:user_id => @user.id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rate }
    end
  end

  def edit
    @rate = Rate.find(params[:id])
  end

  def create
    logger.info "Create"
    @rate = Rate.new(rate_params)

    respond_to do |format|
      if @rate.save
        format.html {
          flash[:notice] = 'Rate was successfully created.'
          redirect_back_or_default(rates_url(:user_id => @rate.user_id))
        }
        format.xml  { render :xml => @rate, :status => :created, :location => @rate }
        format.js { render :action => 'create.js.rjs'}
      else
        logger.error "errors: #{@rate.errors}"
        format.html { render :action => "new" }
        format.xml  { render :xml => @rate.errors, :status => :unprocessable_entity }
        format.js {
          flash.now[:error] = 'Error creating a new Rate.'
          render :action => 'create_error.js.rjs'
        }
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

  def require_user_id
    begin
      @user = User.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html { redirect_to(home_url) }
        format.xml  { render :xml => "User not found", :status => :not_found }
      end
    end
  end

  def set_back_url
    @back_url = params[:back_url]
    @back_url
  end

  # Override defination from ApplicationController to make sure it follows a
  # whitelist
  def redirect_back_or_default(default)
    whitelist = %r{(rates|/users/edit)}

    back_url = CGI.unescape(params[:back_url].to_s)
    if !back_url.blank?
      begin
        uri = URI.parse(back_url)
        if uri.path && uri.path.match(whitelist)
          super
          return
        end
      rescue URI::InvalidURIError
        # redirect to default
        logger.debug("Invalid URI sent to redirect_back_or_default: " + params[:back_url].inspect)
      end
    end
    redirect_to default
  end
end
