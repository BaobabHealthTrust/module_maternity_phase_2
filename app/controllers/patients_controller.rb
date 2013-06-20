
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
        next if !@task.current_user_activities.collect{|ts| ts.upcase}.include?(task.upcase)       

        #check if task has already been done depending on scopes
        scope = @task.task_scopes[task][:scope].upcase rescue nil
        scope = "TODAY" if scope.blank?
        encounter_name = @label_encounter_map[task.upcase]rescue nil
        concept = @task.task_scopes[task][:concept].upcase rescue nil

        @task_status_map[task] = done(scope, encounter_name, concept)
   
      	@links[task.titleize] = "#/{ctrller}/#{task.gsub(/\s/, "_")}?patient_id=#{
      	@patient.id}&user_id=#{params[:user_id]}" + (task.downcase == "update baby outcome" ?
            "&baby=1&baby_total=#{(@patient.current_babies.length rescue 0)}" : "")

      else
        
        @links[task[0].titleize] = {}      
        
        task[1].each{|t|
        
        	if File.exists?("#{Rails.root}/config/protocol_task_flow.yml")        
            ctrller = YAML.load_file("#{Rails.root}/config/protocol_task_flow.yml")["#{t.downcase.gsub(/\s/, "_")}"] rescue ""
     			end
     			
     			    		
          next if !@task.current_user_activities.collect{|ts| ts.upcase}.include?(t.upcase)
          
          #check if task has already been done depending on scopes
          scope = @task.task_scopes[t][:scope].upcase rescue nil
          scope = "TODAY" if scope.blank?
          encounter_name = @label_encounter_map[t.upcase]rescue nil
          concept = @task.task_scopes[t][:concept].upcase rescue nil
          
          @task_status_map[t] = done(scope, encounter_name, concept)
        
          @links[task[0].titleize][t.titleize] = "/#{ctrller}/#{t.gsub(/\s/, "_").downcase}?patient_id=#{
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
      available = Encounter.find(:all, :conditions =>
          ["patient_id IN (?) AND encounter_type = ? AND DATE(encounter_datetime) = ?",
          patient_ids, EncounterType.find_by_name(encounter_name).id , @task.current_date.to_date]) rescue []
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
  
  protected

  def sync_user
    if !session[:user].nil?
      @user = session[:user]
    else 
      @user = JSON.parse(RestClient.get("#{@link}/verify/#{(session[:user_id])}")) rescue {}
    end
  end
  
end
