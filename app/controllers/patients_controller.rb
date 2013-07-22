
class PatientsController < ApplicationController

	unloadable  

  before_filter :sync_user, :except => [:index, :user_login, :user_logout, 
    :set_datetime, :update_datetime, :reset_datetime]


  def show
    @patient = Patient.find(params[:id] || params[:patient_id]) rescue nil

    if @patient.nil?
      redirect_to "/encounters/no_patient" and return
    end

    if params[:user_id].nil?
      redirect_to "/encounters/no_user" and return
    end

    @user = User.find(params[:user_id]) rescue nil
    
    redirect_to "/encounters/no_user" and return if @user.nil?

    @task = TaskFlow.new(params[:user_id], @patient.id)

    @links = {}

    if File.exists?("#{Rails.root}/config/protocol_task_flow.yml")
      map = YAML.load_file("#{Rails.root}/config/protocol_task_flow.yml")["#{Rails.env
        }"]["label.encounter.map"].split(",") rescue []
    end

    @label_encounter_map = {}

    map.each{ |tie|
      label = tie.split("|")[0]
      encounter = tie.split("|")[1] rescue nil

      @label_encounter_map[label] = encounter if !label.blank? && !encounter.blank?

    }

    @task_status_map = {}

    @hash_check = {}

    @task.display_tasks.each{|task|  
      
    	ctrller = "protocol_patients"

      unless task.class.to_s.upcase == "ARRAY"      
            
     		if File.exists?("#{Rails.root}/config/protocol_task_flow.yml")        
          ctrller = YAML.load_file("#{Rails.root}/config/protocol_task_flow.yml")["#{task.downcase.gsub(/\s/, "_")}"] rescue ""
     		end

        next if task.downcase == "update baby outcome" and @patient.current_babies.length == 0
        #next if !@task.current_user_activities.collect{|ts| ts.upcase}.include?(task.upcase)

        #check if task has already been done depending on scopes
        scope = @task.task_scopes[task][:scope].upcase rescue nil
        scope = "TODAY" if scope.blank?
        encounter_name = @label_encounter_map[task.upcase]rescue nil
        concept = @task.task_scopes[task][:concept].upcase rescue nil

        @task_status_map[task] = done(scope, encounter_name, concept)
   
      	@links[task.titleize] = "/#{ctrller}/#{task.downcase.gsub(/\s/, "_")}?patient_id=#{
      	@patient.id}&user_id=#{params[:user_id]}" + (task.downcase == "update baby outcome" ?
            "&baby=1&baby_total=#{(@patient.current_babies.length rescue 0)}" : "")

      else
        
        @links[task[0].titleize] = {}      
        
        task[1].each{|t|
        
        	if File.exists?("#{Rails.root}/config/protocol_task_flow.yml")        
            ctrller = YAML.load_file("#{Rails.root}/config/protocol_task_flow.yml")["#{t.downcase.gsub(/\s/, "_")}"] rescue ""
     			end
     			
     			    		
          # next if !@task.current_user_activities.collect{|ts| ts.upcase}.include?(t.upcase)
          
          #check if task has already been done depending on scopes
          
          scope = @task.task_scopes[t.downcase][:scope].upcase rescue nil
          scope = "TODAY" if scope.blank?
          encounter_name = @label_encounter_map[t.downcase.upcase]rescue nil
          concept = @task.task_scopes[t.downcase][:concept].upcase rescue nil
          
          @task_status_map[t] = done(scope, encounter_name, concept)
        
          @links[task[0].titleize][t.titleize] = "/#{ctrller}/#{t.downcase.gsub(/\s/, "_").downcase}?patient_id=#{
          @patient.id}&user_id=#{params[:user_id]}"
        }

      end

    }
    
    @links.delete_if{|key, link|
      @links[key].class.to_s.upcase == "HASH" && @links[key].blank?
    }

    @list_band_url = "/patients/wrist_band?user_id=#{params[:user_id]}&patient_id=#{@patient.id}"
    
    @project = get_global_property_value("project.name") rescue "Unknown"

    @demographics_url = get_global_property_value("patient.registration.url") rescue nil

    if !@demographics_url.nil?
      @demographics_url = @demographics_url + "/demographics/#{@patient.id}?user_id=#{@user.id}&ext=true"
    end

    @task.next_task

    @babies = @patient.current_babies rescue []

  end

  def done(scope = "", encounter_name = "", concept = "", type="mother")

    patient_ids = [@task.patient.id]
    patient_ids += Relationship.find_all_by_person_a_and_relationship(@task.patient.id,
      RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child")).collect{|rel| rel.person_b}

    scope = "" if concept.blank?
    available = []

    case scope
    when "TODAY"
      available = Encounter.find(:all, :joins => [:observations], :conditions =>
          ["patient_id IN (?) AND encounter_type = ? AND obs.concept_id = ? AND DATE(encounter_datetime) = ?",
          patient_ids, EncounterType.find_by_name(encounter_name).id , ConceptName.find_by_name(concept).concept_id, @task.current_date.to_date]) rescue []

    when "RECENT"
      available = Encounter.find(:all, :joins => [:observations], :conditions =>
          ["patient_id IN (?) AND encounter_type = ? AND obs.concept_id = ? " +
            "AND (DATE(encounter_datetime) >= ? AND DATE(encounter_datetime) <= ?)",
          patient_ids, EncounterType.find_by_name(encounter_name).id, ConceptName.find_by_name(concept).concept_id,
          (@task.current_date.to_date - 6.month), (@task.current_date.to_date + 6.month)]) rescue []

    when "EXISTS"
      available = Encounter.find(:all, :joins => [:observations], :conditions =>
          ["patient_id IN (?) AND encounter_type = ? AND obs.concept_id = ?",
          patient_ids, EncounterType.find_by_name(encounter_name).id, ConceptName.find_by_name(concept).concept_id]) rescue []

    when ""
      #available = Encounter.find(:all, :conditions =>
        #  ["patient_id IN (?) AND encounter_type = ? AND DATE(encounter_datetime) = ?",
        #  patient_ids, EncounterType.find_by_name(encounter_name).id , @task.current_date.to_date]) rescue []
    end

    available = available.blank?? "notdone" : "done"
    available

  end

  def current_visit
    @patient = Patient.find(params[:id] || params[:patient_id]) rescue nil

    ProgramEncounter.current_date = (session[:date_time] || Time.now)
    
    @programs = @patient.program_encounters.current.collect{|p|

      [
        p.id,
        p.to_s,
        p.program_encounter_types.collect{|e|
          [
            e.encounter_id, e.encounter.type.name,
            e.encounter.encounter_datetime.strftime("%H:%M"),
            e.encounter.creator
          ]
        },
        p.date_time.strftime("%d-%b-%Y")
      ]
    } if !@patient.blank?

    # raise @programs.inspect

    render :layout => false
  end

  def visit_history
    @patient = Patient.find(params[:id] || params[:patient_id]) rescue nil

    @programs = @patient.program_encounters.find(:all, :order => ["date_time DESC"]).collect{|p|

      [
        p.id,
        p.to_s,
        p.program_encounter_types.collect{|e|
          [
            e.encounter_id, e.encounter.type.name,
            e.encounter.encounter_datetime.strftime("%H:%M"),
            e.encounter.creator
          ]
        },
        p.date_time.strftime("%d-%b-%Y")
      ]
    } if !@patient.nil?

    # raise @programs.inspect

    render :layout => false
  end

  def children

    @patient = Patient.find(params[:id] || params[:patient_id]) rescue nil
    @children = Relationship.find_all_by_person_a_and_relationship(@patient.patient_id,
      RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child")) rescue nil

    @baby_programs = {}
     
    @children.each {|chil|
      name = Patient.find(chil.person_b).name rescue "Unknown Baby Name"
      @baby_programs["#{name}"] = []
    }
  
    
    if !@children.blank?

      @children.each{|child|
        @baby = Patient.find(child.person_b)
       
        @programs = @baby.program_encounters.find(:all, :order => ["date_time DESC"]).collect{|p|

          [
            p.id,
            p.to_s,
            p.program_encounter_types.collect{|e|
              [
                e.encounter_id, e.encounter.type.name,
                e.encounter.encounter_datetime.strftime("%H:%M"),
                e.encounter.creator
              ]
            },
            p.date_time.strftime("%d-%b-%Y")
          ]
        }
        
        @baby_programs["#{@baby.name}"] = @programs if !@programs.blank?
       
      }
      #raise @baby_programs.to_yaml
    end
    # raise @programs.inspect

    render :layout => false
  end

  def wrist_band
    @patient = Patient.find(params[:id] || params[:patient_id]) rescue nil

    @children = Relationship.find(:all, :conditions => ["person_a = ? AND relationship = ? AND voided = 0", @patient.id, RelationshipType.find_by_a_is_to_b("Parent").id])
    
    render :layout => false
  end

  def band_print
    
    @patient = Patient.find(params[:patient_id]) rescue nil
    
    if params[:cat] == "mother"

      ward_loc = Location.find(session[:location_id]).name rescue ""

      provider_first_name = UserProperty.find_by_user_id_and_property(params[:user_id], "First Name").property_value rescue ""

      provider_last_name = UserProperty.find_by_user_id_and_property(params[:user_id], "Last Name").property_value rescue ""

      provider_name = "#{provider_first_name} #{provider_last_name}" rescue ""

      print_string = Baby.mother_wrist_band_barcode_label(@patient.id, ward_loc, provider_name, Date.today)
      
      if !print_string.blank?

        send_data(print_string,
          :type=>"application/label; charset=utf-8",
          :stream=> false,
          :filename=>"#{params[:patient_id]}#{rand(10000)}.bcl",
          :disposition => "inline") and return
    	end
      
    elsif params[:cat] == "baby"
      
      baby_id = params[:baby_id]
      
      print_string = Baby.baby_wrist_band_barcode_label(baby_id, @patient.id) rescue (raise "Unable to find patient (#{params[:baby_id]}) or generate a baby wrist band label for that baby")
      
      if !print_string.blank?

        send_data(print_string,
          :type=>"application/label; charset=utf-8",
          :stream=> false,
          :filename=>"#{params[:patient_id]}#{rand(10000)}.bcs",
          :disposition => "inline") and return
    	end
      
    else
      print_string = (raise "Unable to resolve relations")
    end   

    redirect_to "/patients/wrist_band?user_id=#{params[:user_id]}&patient_id=#{@patient.id}"

  end

  def demographics
    @patient = Patient.find(params[:id] || params[:patient_id]) rescue nil

    if @patient.nil?
      redirect_to "/encounters/no_patient" and return
    end

    if params[:user_id].nil?
      redirect_to "/encounters/no_user" and return
    end

    @user = User.find(params[:user_id]) rescue nil

    redirect_to "/encounters/no_user" and return if @user.nil?

  end

  def number_of_booked_patients
    date = params[:date].to_date
    encounter_type = EncounterType.find_by_name('Kangaroo review visit') rescue nil
    concept_id = ConceptName.find_by_name('APPOINTMENT DATE').concept_id

    count = Observation.count(:all,
      :joins => "INNER JOIN encounter e USING(encounter_id)",:group => "value_datetime",
      :conditions =>["concept_id = ? AND encounter_type = ? AND value_datetime >= ? AND value_datetime <= ?",
        concept_id,encounter_type.id,date.strftime('%Y-%m-%d 00:00:00'),date.strftime('%Y-%m-%d 23:59:59')]) rescue nil

    count = count.values unless count.blank?
    count = '0' if count.blank?

    render :text => (count.first.to_i > 0 ? {params[:date] => count}.to_json : 0)
  end


  def general_demographics

    @patient = Patient.find(params[:id]) || Patient.find(params[:patient_id])
    @children = @patient.current_babies rescue []
    @anc_patient = ANCService::ANC.new(@patient)
    @maternity_patient = MaternityService::Maternity.new(@patient) rescue nil
    @patient_registration = get_global_property_value("patient.registration.url") rescue ""

    if params[:ext_patient_id]

      relationship = RelationshipType.find_by_b_is_to_a("Spouse/Partner").id

      Relationship.create(
        :person_a => params[:id],
        :person_b => params[:ext_patient_id],
        :relationship => relationship)

    end

    #raise @children.to_yaml
    render :layout => false
  end

  def birth_report

    @patient = Patient.find(params[:patient_id]) rescue nil

    @person = Patient.find(params[:id] || params[:person_id]) rescue nil
    @anc_patient = ANCService::ANC.new(@person) rescue nil

  end

  def birth_report_printable

    @patient = Patient.find(params[:patient_id]) rescue nil
    @person = Patient.find(params[:person_id]) rescue nil
    @person = Patient.find(params[:id]) rescue nil if @person.blank?
    @anc_patient = ANCService::ANC.new(@person) rescue nil

    mother_id = Relationship.find(:all, :order => ["date_created ASC"], :conditions => ["person_b = ? AND person_a = ? AND relationship = ?",
        @person.id, @patient.id,
        RelationshipType.find_by_a_is_to_b("Parent").id]).collect{|r|
      r.person_a if Person.find(r.person_a).gender.match(/f/i)}.last rescue nil
  
    @mother = Patient.find(mother_id) rescue nil

    @anc_mother = ANCService::ANC.new(@mother) rescue nil

    @maternity_mother = MaternityService::Maternity.new(@mother) rescue nil

    father_id = @maternity_mother.husband.person_b rescue nil

    @father = Patient.find(father_id) rescue nil

    @anc_father = ANCService::ANC.new(@father) rescue nil

    @serial_number = PatientIdentifier.find(:first, :conditions => ["patient_id = ? AND identifier_type = ?",
        @person.id,
        PatientIdentifierType.find_by_name("Serial Number").id]).identifier rescue "?"

    #user = PersonName.find_by_person_id(User.find(params[:user_id]).person_id) rescue nil

    #@provider_name = user.given_name.split("")[0].upcase + ".  " + user.family_name.humanize if user
    @provider_name = User.find(params[:user_id]).name

    @facility = get_global_property_value("facility.name")

    @district = get_global_property_value("current_district") rescue ''

    maternity = MaternityService::Maternity.new(@patient) rescue nil

    data = maternity.export_person((params[:user_id] rescue 1), @facility, @district)

    render :layout => false
  end

  def print_note
    location = request.remote_ip rescue ""

    @patient    = Patient.find(params[:patient_id] || params[:id] || session[:patient_id]) rescue nil
    person_id = params[:id] || params[:person_id]
    if @patient
      current_printer = ""

      wards = GlobalProperty.find_by_property("facility.ward.printers").property_value.split(",") rescue []

      printers = wards.each{|ward|
        current_printer = ward.split(":")[1] if ward.split(":")[0].upcase == location
      } rescue []
      ["ORIGINAL FOR:(PARENT)", "DUPLICATE FOR DISTRICT:REGISTRY OF BIRTH", "TRIPLICATE FOR DISTRICT:REGISTRY OF ORIGINAL HOME", "QUADRUPLICATE FOR:THE HOSPITAL", ""].each do |rec|

        @recipient = rec
        name = rec.split(":").last.downcase.gsub("(", "").gsub(")", "") if !rec.blank?

        t1 = Thread.new{
          Kernel.system "wkhtmltopdf --zoom 0.8 -s A4 http://" +
            request.env["HTTP_HOST"] + "\"/patients/birth_report_printable/" +
            person_id.to_s + "?patient_id=#{@patient.id}&person_id=#{person_id}&user_id=#{params[:user_id]}&recipient=#{@recipient}" + "\" /tmp/output-#{Regexp.escape(name)}" + ".pdf \n"
        } if !rec.blank?

        t2 = Thread.new{
          sleep(2)
          Kernel.system "lp #{(!current_printer.blank? ? '-d ' + current_printer.to_s : "")} /tmp/output-#{Regexp.escape(name)}" + ".pdf\n"
        } if !rec.blank?

        t3 = Thread.new{
          sleep(3)
          Kernel.system "rm /tmp/output-#{Regexp.escape(name)}"+ ".pdf\n"
        }if !rec.blank?
        sleep(1)
      end

    end
    redirect_to "/patients/birth_report/#{person_id}?person_id=#{person_id}&patient_id=#{params[:patient_id]}&user_id=#{params[:user_id]}" and return
  end

  def send_birth_report

    facility = get_global_property_value("facility.name") rescue ''

    district = get_global_property_value("current_district") rescue ''

    patient = Patient.find(params[:id]) rescue nil

    maternity = MaternityService::Maternity.new(patient) rescue nil
    user = User.find(params[:user_id]).id rescue nil

    data = maternity.export_person(user, facility, district)

    uri = get_global_property_value("birth_registration_url") rescue nil

    result = RestClient.post(uri, data) rescue "birth report couldnt be sent"

    if ((result.downcase rescue "") == "baby added") and params[:update].nil?
      flash[:error] = "Birth Report Sent"
      BirthReport.create(:person_id => params[:id])
    else
      flash[:error] = "Sending failed. Check configurations and make sure you are not resending"
    end

    redirect_to "/patients/birth_report/#{params[:id]}?person_id=#{params[:id]}&user_id=#{params[:user_id]}&patient_id=#{params[:patient_id]}&today=1" and return
  end

  def void
    @relationship = Relationship.find(params[:id])
    @relationship.void
    head :ok
  end

  def provider_details
    @patient = Patient.find(params[:patient_id])
    @person = Person.find(params[:person_id])

    @name = Person.find(User.find(params[:user_id]).id).name rescue " "

    @facility = get_global_property_value("facility.name") rescue ''

    @district = get_global_property_value("current_district") rescue ''

  end

  def create_provider

    @patient = Patient.find(params[:person_id]) rescue nil
    @anc_patient = ANCService::ANC.new(@patient) rescue nil

    @facility = get_global_property_value("facility.name") rescue ''

    @district = get_global_property_value("district.name") rescue ''

    @anc_patient.set_attribute("Hospital Date", Date.today)

    @anc_patient.set_attribute("Health Center", @facility)

    @anc_patient.set_attribute("Health District", @district)

    if !params[:ProviderTitle].nil? && !params[:ProviderTitle].blank?
      @anc_patient.set_attribute("Provider Title", params[:ProviderTitle])
    end

    if !params[:ProviderName].nil? && !params[:ProviderName].blank?
      @anc_patient.set_attribute("Provider Name", params[:ProviderName])
    end
   
    redirect_to "/patients/birth_report/#{params[:person_id]}?person_id=#{params[:person_id]}&patient_id=#{params[:patient_id]}&user_id=#{params[:user_id]}"
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
