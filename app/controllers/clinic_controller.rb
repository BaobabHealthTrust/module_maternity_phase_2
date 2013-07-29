
class ClinicController < ApplicationController
  unloadable  

  before_filter :sync_user, :except => [:index, :user_login, :user_logout, 
    :set_datetime, :update_datetime, :reset_datetime]

  def index
    
    if session[:user_id].blank?
      reset_session
      
      user_login and return
    end
    
    @location = Location.find(session[:location_id]) rescue nil

    session[:location_id] = @location.id if !@location.nil?
    
    redirect_to "/patients/show/#{params[:ext_patient_id]}?user_id=#{params[:user_id]}&location_id=#{params[:location_id]}" and return if !params[:ext_patient_id].blank?

    @project = get_global_property_value("project.name") rescue "Unknown"

    @facility = get_global_property_value("facility.name") rescue "Unknown"

    @patient_registration = get_global_property_value("patient.registration.url") rescue ""

    @link = get_global_property_value("user.management.url").to_s rescue nil

    @user = JSON.parse(RestClient.get("#{@link}/verify/#{(session[:user_id])}")) rescue {}
    
    session[:user] = @user rescue nil
    
    if @link.nil?
      flash[:error] = "Missing configuration for <br/>user management connection!"

      redirect_to "/no_user" and return
    end

    @selected = YAML.load_file("#{Rails.root}/config/application.yml")["#{Rails.env
        }"]["demographic.fields"].split(",") rescue []

  end

  def user_login

    link = get_global_property_value("user.management.url").to_s rescue nil

    if link.nil?
      flash[:error] = "Missing configuration for <br/>user management connection!"

      redirect_to "/no_user" and return
    end

    host = request.host_with_port rescue ""

    redirect_to "#{link}/login?ext=true&src=#{host}" and return if params[:ext_user_id].nil?

  end

  def user_logout

    link = get_global_property_value("user.management.url").to_s rescue nil
    
    reset_session

    if link.nil?
      flash[:error] = "Missing configuration for <br/>user management connection!"

      redirect_to "/no_user" and return
    end

    session[:datetime] = nil
    session[:location_id] = nil

    host = request.host_with_port rescue ""

    redirect_to "#{link}/logout/#{params[:id]}?ext=true&src=#{host}" and return if params[:ext_user_id].nil?

  end

  def set_datetime
     
    
  end

  def update_datetime
  
    unless params[:retrospective_date].blank?
      # set for 1 second after midnight to designate it as a retrospective date
      date_of_encounter = (params[:retrospective_date] + " " + Time.now.strftime("%H:%M")).to_time

      session[:datetime] = date_of_encounter if date_of_encounter.to_date != Date.today
    end

    redirect_to "/clinic?user_id=#{params[:user_id]}&location_id=#{params[:location_id]}" and return
     
  end

  def reset_datetime
    session[:datetime] = nil
    redirect_to "/clinic?user_id=#{params[:user_id]}&location_id=#{params[:location_id]}" and return
  end

  def administration

    @link = get_global_property_value("user.management.url").to_s rescue nil

    if @link.nil?
      flash[:error] = "Missing configuration for <br/>user management connection!"

      redirect_to "/no_user" and return
    end

    @host = request.host_with_port rescue ""

    render :layout => false
  end

  def my_account

    @link = get_global_property_value("user.management.url").to_s rescue nil

    if @link.nil?
      flash[:error] = "Missing configuration for <br/>user management connection!"

      redirect_to "/no_user" and return
    end
    
    @host = request.host_with_port rescue ""

    render :layout => false
  end

  def overview
    @program_encounter_details =  ProgramEncounterDetail.find(:all, :select => ["encounter_id"], :joins => [:program_encounter],
      :conditions => ["program_encounter.program_id = ?",
        Program.find_by_name("MATERNITY PROGRAM").program_id]).collect{|ed| ed.encounter_id } rescue []

    User.current = User.find(session[:user]["user_id"])

    if File.exists?("#{Rails.root}/config/protocol_task_flow.yml")
      map = YAML.load_file("#{Rails.root}/config/protocol_task_flow.yml")["#{Rails.env
        }"]["label.encounter.map"].split(",") rescue []
    end

    @types = []

    map.each{ |tie|
      encounter = tie.split("|")[1] rescue nil
      @types << encounter if !encounter.blank?
    }

    @types.delete_if{|del| del.match(/Refer|Diagnosis|social|dispensing|observations|examination|vitals|admit|baby/i) || del.downcase == "outcome"}
    
    @me = Encounter.statistics(@types,  @program_encounter_details, :conditions =>
        ['DATE(encounter_datetime) = DATE(NOW()) AND encounter.creator = ? AND encounter.location_id = ?',
        User.current.user_id, session[:location_id]])

    @today = Encounter.statistics(@types, @program_encounter_details, :conditions => ['DATE(encounter_datetime) = DATE(NOW()) AND encounter.location_id = ?',
        session[:location_id]])

    @year = Encounter.statistics(@types, @program_encounter_details, :conditions => ['YEAR(encounter_datetime) = YEAR(NOW()) AND encounter.location_id = ?',
        session[:location_id]])

    @ever = Encounter.statistics(@types, @program_encounter_details, :conditions => ['encounter.location_id = ?', session[:location_id]])

    if (get_global_property_value("assign_serial_numbers").to_s == "true" rescue false)

      @me["BIRTH REPORTS"] = {}
      @me["BIRTH REPORTS"]["SENT"] = BirthReport.unsent_between("sent", Date.today, Date.today, User.current.user_id)
      @me["BIRTH REPORTS"]["PENDING"] = BirthReport.unsent_between("pending", Date.today, Date.today, User.current.user_id)
      @me["BIRTH REPORTS"]["UNATTEMPTED"] = BirthReport.unsent_between("unattempted", Date.today, Date.today, User.current.user_id)

      @today["BIRTH REPORTS"] = {}
      @today["BIRTH REPORTS"]["SENT"] = BirthReport.unsent_between("sent", Date.today, Date.today)
      @today["BIRTH REPORTS"]["PENDING"] = BirthReport.unsent_between("pending", Date.today, Date.today)
      @today["BIRTH REPORTS"]["UNATTEMPTED"] = BirthReport.unsent_between("unattempted", Date.today, Date.today)

      @year["BIRTH REPORTS"] = {}
      @year["BIRTH REPORTS"]["SENT"] = BirthReport.unsent_between("sent", "#{Date.today.strftime('%Y')}-01-01".to_date, "#{Date.today.strftime('%Y')}-12-31".to_date)
      @year["BIRTH REPORTS"]["PENDING"] = BirthReport.unsent_between("pending", "#{Date.today.strftime('%Y')}-01-01".to_date, "#{Date.today.strftime('%Y')}-12-31".to_date)
      @year["BIRTH REPORTS"]["UNATTEMPTED"] = BirthReport.unsent_between("unattempted", "#{Date.today.strftime('%Y')}-01-01".to_date, "#{Date.today.strftime('%Y')}-12-31".to_date)

      @ever["BIRTH REPORTS"] = {}
      @ever["BIRTH REPORTS"]["SENT"] = BirthReport.unsent_between("sent")
      @ever["BIRTH REPORTS"]["PENDING"] = BirthReport.unsent_between("pending")
      @ever["BIRTH REPORTS"]["UNATTEMPTED"] = BirthReport.unsent_between("unattempted")

      @types = @types + @ever["BIRTH REPORTS"].keys.reverse
      
    end

    render :layout => false
  end

  def reports
    render :layout => false
  end

  def project_users
    if !session[:user].nil?
      @user = session[:user]
    else 
      @user = JSON.parse(RestClient.get("#{@link}/verify/#{(session[:user_id])}")) rescue {}
    end
    render :layout => false
  end

  def project_users_list
    users = User.find(:all, :conditions => ["username LIKE ? AND user_id IN (?)", "#{params[:username]}%",
        UserProperty.find(:all, :conditions => ["property = 'Status' AND property_value = 'ACTIVE'"]
        ).map{|user| user.user_id}], :limit => 50)

    @project = get_global_property_value("project.name").downcase.gsub(/\s/, ".") rescue nil

    result = users.collect { |user|
      [
        user.id,
        (user.user_properties.find_by_property("#{@project}.activities").property_value.split(",") rescue nil),
        (user.user_properties.find_by_property("Last Name").property_value rescue nil),
        (user.user_properties.find_by_property("First Name").property_value rescue nil),
        user.username
      ]
    }

    render :text => result.to_json
  end

  def add_to_project

    @project = get_global_property_value("project.name").downcase.gsub(/\s/, ".") rescue nil

    unless params[:target].nil? || @project.nil?
      user = User.find(params[:target]) rescue nil

      unless user.nil?
        UserProperty.create(
          :user_id => user.id,
          :property => "#{@project}.activities",
          :property_value => ""
        )
      end
    end
    
    redirect_to "/project_users_list" and return
  end

  def remove_from_project

    @project = get_global_property_value("project.name").downcase.gsub(/\s/, ".") rescue nil

    unless params[:target].nil? || @project.nil?
      user = User.find(params[:target]) rescue nil

      unless user.nil?
        user.user_properties.find_by_property("#{@project}.activities").delete
      end
    end
    
    redirect_to "/project_users_list" and return
  end

  def manage_activities

    @project = get_global_property_value("project.name").downcase.gsub(/\s/, ".") rescue nil

    unless @project.nil?
      @users = UserProperty.find_all_by_property("#{@project}.activities").collect { |user| user.user_id }
    
      @roles = UserRole.find(:all, :conditions => ["user_id IN (?)", @users]).collect { |role| role.role }.sort.uniq

    end

  end

  def check_role_activities
    activities = {}

    if File.exists?("#{Rails.root}/config/protocol_task_flow.yml")
      YAML.load_file("#{Rails.root}/config/protocol_task_flow.yml")["#{Rails.env
        }"]["clinical.encounters.sequential.list"].split(",").each{|activity|
        
        activities[activity.titleize] = 0

      } rescue nil
    end
      
    role = params[:role].downcase.gsub(/\s/,".") rescue nil

    unless File.exists?("#{Rails.root}/config/roles")
      Dir.mkdir("#{Rails.root}/config/roles")
    end

    unless role.nil?
      if File.exists?("#{Rails.root}/config/roles/#{role}.yml")
        YAML.load_file("#{Rails.root}/config/roles/#{role}.yml")["#{Rails.env
        }"]["activities.list"].split(",").compact.each{|activity|

          activities[activity.titleize] = 1

        } rescue nil
      end
    end

    render :text => activities.to_json
  end

  def create_role_activities
    activities = []
    
    role = params[:role].downcase.gsub(/\s/,".") rescue nil
    activity = params[:activity] rescue nil

    unless File.exists?("#{Rails.root}/config/roles")
      Dir.mkdir("#{Rails.root}/config/roles")
    end

    unless role.nil? || activity.nil?

      file = "#{Rails.root}/config/roles/#{role}.yml"

      activities = YAML.load_file(file)["#{Rails.env
        }"]["activities.list"].split(",") rescue []

      activities << activity

      activities = activities.map{|a| a.upcase}.uniq

      f = File.open(file, "w")

      f.write("#{Rails.env}:\n    activities.list: #{activities.uniq.join(",")}")

      f.close

    end
    
    activities = {}

    if File.exists?("#{Rails.root}/config/protocol_task_flow.yml")
      YAML.load_file("#{Rails.root}/config/protocol_task_flow.yml")["#{Rails.env
        }"]["clinical.encounters.sequential.list"].split(",").each{|activity|

        activities[activity.titleize] = 0

      } rescue nil
    end

    YAML.load_file("#{Rails.root}/config/roles/#{role}.yml")["#{Rails.env
        }"]["activities.list"].split(",").each{|activity|

      activities[activity.titleize] = 1

    } rescue nil

    render :text => activities.to_json
  end

  def remove_role_activities
    activities = []

    role = params[:role].downcase.gsub(/\s/,".") rescue nil
    activity = params[:activity] rescue nil

    unless File.exists?("#{Rails.root}/config/roles")
      Dir.mkdir("#{Rails.root}/config/roles")
    end

    unless role.nil? || activity.nil?

      file = "#{Rails.root}/config/roles/#{role}.yml"

      activities = YAML.load_file(file)["#{Rails.env
        }"]["activities.list"].split(",").map{|a| a.upcase} rescue []

      activities = activities - [activity.upcase]

      activities = activities.map{|a| a.titleize}.uniq

      f = File.open(file, "w")

      f.write("#{Rails.env}:\n    activities.list: #{activities.uniq.join(",")}")

      f.close

    end

    activities = {}

    if File.exists?("#{Rails.root}/config/protocol_task_flow.yml")
      YAML.load_file("#{Rails.root}/config/protocol_task_flow.yml")["#{Rails.env
        }"]["clinical.encounters.sequential.list"].split(",").each{|activity|

        activities[activity.titleize] = 0

      } rescue nil
    end

    YAML.load_file("#{Rails.root}/config/roles/#{role}.yml")["#{Rails.env
        }"]["activities.list"].split(",").each{|activity|

      activities[activity.titleize] = 1

    } rescue nil

    render :text => activities.to_json
  end

  def project_members    
  end

  def my_activities    
  end

  def check_user_activities
    activities = {}

    @user["roles"].each do |role|

      role = role.downcase.gsub(/\s/,".") rescue nil

      if File.exists?("#{Rails.root}/config/roles/#{role}.yml")

        YAML.load_file("#{Rails.root}/config/roles/#{role}.yml")["#{Rails.env
        }"]["activities.list"].split(",").each{|activity|

          activities[activity.titleize] = 0 if activity.downcase.match("^" +
              (!params[:search].nil? ? params[:search].downcase : ""))

        } rescue nil

      end
    
    end

    @project = get_global_property_value("project.name").downcase.gsub(/\s/, ".") rescue nil

    unless @project.nil?
      
      UserProperty.find_by_user_id_and_property(session[:user_id],
        "#{@project}.activities").property_value.split(",").each{|activity|
        
        activities[activity.titleize] = 1 if activity.downcase.match("^" +
            (!params[:search].nil? ? params[:search].downcase : "")) and !activities[activity.titleize].nil?

      }

    end
    
    render :text => activities.to_json
  end

  def create_user_activity

    @project = get_global_property_value("project.name").downcase.gsub(/\s/, ".") rescue nil

    unless @project.nil? || params[:activity].nil?

      user = UserProperty.find_by_user_id_and_property(session[:user_id],
        "#{@project}.activities")

      unless user.nil?
        properties = user.property_value.split(",")

        properties << params[:activity]

        properties = properties.map{|p| p.upcase}.uniq

        user.update_attribute("property_value", properties.join(","))

      else

        UserProperty.create(
          :user_id => session[:user_id],
          :property => "#{@project}.activities",
          :property_value => params[:activity]
        )

      end

    end
    
    activities = {}

    @user["roles"].each do |role|

      role = role.downcase.gsub(/\s/,".") rescue nil

      if File.exists?("#{Rails.root}/config/roles/#{role}.yml")

        YAML.load_file("#{Rails.root}/config/roles/#{role}.yml")["#{Rails.env
        }"]["activities.list"].split(",").each{|activity|

          activities[activity.titleize] = 0 if activity.downcase.match("^" +
              (!params[:search].nil? ? params[:search].downcase : ""))

        } rescue nil

      end

    end

    @project = get_global_property_value("project.name").downcase.gsub(/\s/, ".") rescue nil

    unless @project.nil?

      UserProperty.find_by_user_id_and_property(session[:user_id],
        "#{@project}.activities").property_value.split(",").each{|activity|

        activities[activity.titleize] = 1

      }

    end

    render :text => activities.to_json
  end

  def remove_user_activity

    @project = get_global_property_value("project.name").downcase.gsub(/\s/, ".") rescue nil

    unless @project.nil? || params[:activity].nil?

      user = UserProperty.find_by_user_id_and_property(session[:user_id],
        "#{@project}.activities")

      unless user.nil?
        properties = user.property_value.split(",").map{|p| p.upcase}.uniq

        properties = properties - [params[:activity].upcase]

        user.update_attribute("property_value", properties.join(","))
      end

    end

    activities = {}

    @user["roles"].each do |role|

      role = role.downcase.gsub(/\s/,".") rescue nil

      if File.exists?("#{Rails.root}/config/roles/#{role}.yml")

        YAML.load_file("#{Rails.root}/config/roles/#{role}.yml")["#{Rails.env
        }"]["activities.list"].split(",").each{|activity|

          activities[activity.titleize] = 0 if activity.downcase.match("^" +
              (!params[:search].nil? ? params[:search].downcase : ""))

        } rescue nil

      end

    end

    unless @project.nil?

      UserProperty.find_by_user_id_and_property(session[:user_id],
        "#{@project}.activities").property_value.split(",").each{|activity|

        activities[activity.titleize] = 1

      }

    end

    render :text => activities.to_json
  end

  def demographics_fields
  end

  def show_selected_fields
    fields = ["Middle Name", "Maiden Name", "Home of Origin", "Current District",
      "Current T/A", "Current Village", "Landmark or Plot", "Cell Phone Number",
      "Office Phone Number", "Home Phone Number", "Occupation", "Nationality"]

    selected = YAML.load_file("#{Rails.root}/config/application.yml")["#{Rails.env
        }"]["demographic.fields"].split(",") rescue []

    @fields = {}

    fields.each{|field|
      if selected.include?(field)
        @fields[field] = 1
      else
        @fields[field] = 0
      end
    }
    
    render :text => @fields.to_json
  end

  def remove_field
    initial = YAML.load_file("#{Rails.root}/config/application.yml").to_hash rescue {}

    demographics = initial["#{Rails.env}"]["demographic.fields"].split(",") rescue []

    demographics = demographics - [params[:target]]

    initial["#{Rails.env}"]["demographic.fields"] = demographics.join(",")

    File.open("#{Rails.root}/config/application.yml", "w+") { |f| f.write(initial.to_yaml) }

    fields = ["Middle Name", "Maiden Name", "Home of Origin", "Current District",
      "Current T/A", "Current Village", "Landmark or Plot", "Cell Phone Number",
      "Office Phone Number", "Home Phone Number", "Occupation", "Nationality"]

    selected = YAML.load_file("#{Rails.root}/config/application.yml")["#{Rails.env
        }"]["demographic.fields"].split(",") rescue []

    @fields = {}

    fields.each{|field|
      if selected.include?(field)
        @fields[field] = 1
      else
        @fields[field] = 0
      end
    }

    render :text => @fields.to_json
  end

  def add_field
    initial = YAML.load_file("#{Rails.root}/config/application.yml").to_hash rescue {}

    demographics = initial["#{Rails.env}"]["demographic.fields"].split(",") rescue []

    demographics = demographics + [params[:target]]

    initial["#{Rails.env}"]["demographic.fields"] = demographics.join(",")

    File.open("#{Rails.root}/config/application.yml", "w+") { |f| f.write(initial.to_yaml) }

    fields = ["Middle Name", "Maiden Name", "Home of Origin", "Current District",
      "Current T/A", "Current Village", "Landmark or Plot", "Cell Phone Number",
      "Office Phone Number", "Home Phone Number", "Occupation", "Nationality"]

    selected = YAML.load_file("#{Rails.root}/config/application.yml")["#{Rails.env
        }"]["demographic.fields"].split(",") rescue []

    @fields = {}

    fields.each{|field|
      if selected.include?(field)
        @fields[field] = 1
      else
        @fields[field] = 0
      end
    }

    render :text => @fields.to_json
  end

  def serial_numbers
    @remaining_serial_numbers = SerialNumber.find(:all, :conditions => ["national_id IS NULL"]).size
    @print_string = (@remaining_serial_numbers ==1)?  "" + @remaining_serial_numbers.to_s + " Serial Number Remaining" : "" + @remaining_serial_numbers.to_s + " Serial Numbers Remaining"
    @limited_serial_numbers = (SerialNumber.all.size  <= 100) rescue false
    render :layout => false
  end
  
  def create_batch
    @initial_numbers = SerialNumber.all.size

    if ((!params[:start_serial_number].blank? rescue false) && (!params[:end_serial_number].blank? rescue false) &&
          (params[:start_serial_number].to_i < params[:end_serial_number].to_i) rescue false)
      (params[:start_serial_number]..params[:end_serial_number]).each do |number|
        snum = SerialNumber.new()
        snum.serial_number = number
        snum.creator = params[:user_id]
        snum.save if (SerialNumber.find(number).nil? rescue true)
      end
      @final_numbers = initial_numbers = SerialNumber.all.size
    else
    end
    redirect_to "/?user_id=#{session[:user]['user_id']}&location_id=#{session[:location_id]}"
  end

  def add_batch

  end

  protected

  def sync_user
    if !session[:user].nil?
      @user = session[:user]
    else 
      @user = JSON.parse(RestClient.get("#{@link}/verify/#{(session[:user_id])}")) rescue {}
    end
  end

end
