
class ApplicationController < ActionController::Base
  helper :all

  before_filter :start_session

  before_filter :check_user, :except => [:user_login, :user_logout, :missing_program, :baby_admissions_note_printable, :admissions_note_printable, :birth_report_printable,
    :missing_concept, :missing_admission, :no_user, :print_birth_cohort, :birth_cohort, :issue_birth_report, :no_serial_number, :no_patient, :project_users_list, :check_role_activities]
  
  def get_global_property_value(global_property)
		property_value = Settings[global_property]
		if property_value.nil?
			property_value = GlobalProperty.find(:first, :conditions => {:property => "#{global_property}"}
      ).property_value rescue nil
		end
		return property_value
	end

  def create_from_dde_server
    get_global_property_value('create.from.dde.server').to_s == "true" rescue false
  end

  def print_and_redirect(print_url, redirect_url, message = "Printing, please wait...", show_next_button = false, patient_id = nil)
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    @show_next_button = show_next_button
    @patient_id = patient_id
    render :template => 'print/print', :layout => nil
  end

  def rescue_action(exception)
    @message = exception.message
    @backtrace = exception.backtrace.join("\n") unless exception.nil?
    logger.info @message
    logger.info @backtrace
    render :file => "#{RAILS_ROOT}/app/views/errors/error.rhtml", :layout=> false, :status => 404
  end if RAILS_ENV == 'production'


  protected

  def start_session
    session[:started] = true
  end

  def check_user

    if !params[:token].blank?
      session[:token] = params[:token]
    end

    if !params[:user_id].blank?
      session[:user_id] = params[:user_id]
    end

    if !params[:location_id].blank?
      session[:location_id] = params[:location_id]
    end

    link = get_global_property_value("user.management.url").to_s rescue nil

    if link.blank?
      flash[:error] = "Missing configuration for <br/>user management connection!"

      redirect_to "/no_user" and return
    end    

    # Track final destination
    Dir::mkdir("#{RAILS_ROOT}/tmp") rescue nil
    file = "#{File.expand_path("#{Rails.root}/tmp", __FILE__)}/current.path.yml"

    f = File.open(file, "w")

    f.write("#{Rails.env}:\n    current.path: #{request.referrer}")

    f.close

    if session[:token].blank?
      redirect_to "/user_login?internal=true" and return
    end

  end

  def send_label(label_data)
    send_data(
      label_data,
      :type=>"application/label; charset=utf-8",
      :stream => false,
      :filename => "#{Time.now.to_i}#{rand(100)}.lbl",
      :disposition => "inline"
    )
  end

end
