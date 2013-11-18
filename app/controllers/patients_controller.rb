require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/rmagick_outputter'

class PatientsController < ApplicationController

	unloadable  

  before_filter :sync_user, :except => [:index, :user_login, :user_logout, 
    :set_datetime, :update_datetime, :reset_datetime, :admissions_note_printable, :baby_admissions_note_printable, :birth_report_printable]

  def show
    
    d = (session[:datetime].to_date rescue Date.today)
    t = Time.now
    session_date = DateTime.new(d.year, d.month, d.day, t.hour, t.min, t.sec)
 
    @patient = Patient.find(params[:id] || params[:patient_id]) rescue nil
    
    #check if we are supposed to enroll any babies in EID program
    if (@patient.hiv_status.match(/positive/i) rescue false)

      @babies = @patient.recent_baby_relations rescue []

      @babies.each do |baby|

        @baby_patient = Patient.find(baby.person_b) rescue nil
        next if @baby_patient.blank?
        
        baby_programs = @baby_patient.patient_programs.collect{|pr| pr.program.name} rescue []
       
        create_registration(@baby_patient, "EARLY INFANT DIAGNOSIS PROGRAM") if !baby_programs.include?("EARLY INFANT DIAGNOSIS PROGRAM")

      end

    end

    if @patient.age(session_date) < 10
      return_ip = "http://#{request.raw_host_with_port}/?user_id=#{session[:user_id] || params[:user_id]}&location_id=#{session[:location_id]}";
      redirect_to "/encounters/not_female?return_ip=#{return_ip}" and return
    end
    
    @next_user_task = []
    
    if params[:autoflow].present? && params[:autoflow].to_s == "true"
      session[:autoflow] = "true"
    elsif params[:autoflow].present? && params[:autoflow].to_s == "false"
      session[:autoflow] = "false"
    end
  
    if @patient.nil?
      redirect_to "/encounters/no_patient" and return
    end

    if params[:user_id].nil?
      redirect_to "/encounters/no_user" and return
    end

    @user = User.find(params[:user_id]) rescue nil
    
    redirect_to "/encounters/no_user" and return if @user.nil?

    @last_location = @patient.recent_location.location_id rescue nil
    @current_location_name = Location.find(session[:location_id]).name rescue nil
  
    if !@last_location.blank? && ((session[:location_id].to_i != @last_location) rescue false) && (!@current_location_name.match(/registration|labour ward/i) rescue false)
      redirect_to "/two_protocol_patients/admit_to_ward?patient_id=#{@patient.id}&user_id=#{@user.id}&location_id=#{session[:location_id]}"
    end
    
    if params[:from_search].present? && @last_location.blank?
      redirect_to "/two_protocol_patients/referral?patient_id=#{@patient.id}&user_id=#{@user.id}&location_id=#{session[:location_id]}"
    end
    
    @task = TaskFlow.new(params[:user_id], @patient.id, session_date.to_date)

    @undischarged_baby = @patient.next_undischarged_baby rescue nil
 
    unless  @undischarged_baby.blank?
      
      @baby = Patient.find(@undischarged_baby.person_b) rescue nil
     
      name = @baby.name.delete("^a-z\sA-Z0-9") rescue "...  "
     
      national_id = @baby.national_id rescue " NOT FOUND"
      if ((@baby.person.dead == 1 || @baby.person.dead == true) rescue false)
        @value = "Dead"
      else
        @value = ""
      end
      
      @next_user_task = ["#{name} Discharge Outcome",
        "/two_protocol_patients/baby_discharge_outcome?patient_id=#{@patient.id}&user_id=#{@user.id}&value=#{@value}&baby_name=#{name}&baby_national_id=#{national_id}"
      ]
      redirect_to @next_user_task[1] #and return if (session[:autoflow] == "true")
      
    end if @patient.is_discharged_mother?

    if done_ret("RECENT", "SOCIAL HISTORY", "", "GUARDIAN FIRST NAME") != "done"

      @next_user_task = ["Social History",
        "/two_protocol_patients/social_history?patient_id=#{@patient.id}&user_id=#{@user.id}"
      ]

      social_history = 0

      redirect_to @next_user_task[1] and return if (session[:autoflow] == "true")

    else

      social_history = 1
      
    end

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
       
        @task_status_map[task] = done_ret(scope, encounter_name, "", concept) #unless task.upcase.match(/notes/i)
   
        @links[task.titleize] = "/#{ctrller}/#{task.downcase.gsub(/\s/, "_")}?patient_id=#{
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
          
          scope = @task.task_scopes[t.downcase][:scope].upcase rescue nil
          scope = "TODAY" if scope.blank?
          encounter_name = @label_encounter_map[t.upcase]rescue nil
          concept = @task.task_scopes[t.downcase][:concept].upcase rescue nil
          ret = task[0].titleize.match(/ante natal|post natal/i)[0].gsub(/\s/, "-").downcase rescue ""
       
          @task_status_map[t] = done_ret(scope, encounter_name, ret, concept)# unless t.upcase.match(/notes/i)
        
          @links[task[0].titleize][t.titleize] = "/#{ctrller}/#{t.downcase.gsub(/\s/, "_").downcase}?patient_id=#{
          @patient.id}&user_id=#{params[:user_id]}"
        }

      end

    }

    @task_status_map["SOCIAL HISTORY"] = "done" if social_history == 1
   
    @links.delete_if{|key, link|
      @links[key].class.to_s.upcase == "HASH" && @links[key].blank?
    }
     
    @links["Give Drugs"] = "/encounters/give_drugs?patient_id=#{@patient.id}&user_id=#{@user.id}"
    @links["Baby Outcomes"]["Give Drugs"] = "/encounters/baby_drugs_route?patient_id=#{@patient.id}&user_id=#{@user.id}" rescue nil
   
    @list_band_url = "/patients/wrist_band?user_id=#{params[:user_id]}&patient_id=#{@patient.id}"
    
    @project = get_global_property_value("project.name") rescue "Unknown"

    @demographics_url = get_global_property_value("patient.registration.url") rescue nil

    if !@demographics_url.nil?
      @demographics_url = @demographics_url + "/demographics/#{@patient.id}?user_id=#{@user.id}&ext=true"
    end

    @task.next_task
    @links.keys.each{|key|
      if key.match(/Natal Exams/i)
        ret = key.downcase.gsub(/\s/, "-").gsub(/-exams/, "")
        @links[key]["Admissions Note"] = "/patients/admissions_note?patient_id=#{@patient.id}&user_id=#{@user.id}&ret=#{ret}"

        if @links[key]["Ante Natal Patient History"].present?
          @links[key]["Ante Natal Patient History"] = @links[key]["Ante Natal Patient History"].gsub(/two\_protocol\_|ante\_natal\_/, "") + "&ret=ante-natal"
        elsif @links[key]["Post Natal Patient History"].present?
          @links[key]["Post Natal Patient History"] = @links[key]["Post Natal Patient History"].gsub(/two\_protocol\_|post\_natal\_/, "") + "&ret=post-natal"
        end
      end
    }
 
    @links = @links.delete_if{|key, val| key.match(/hiv/i)}

    @groupings = {}
    @groupings["Ante Natal Exams"] = ["ante_natal_admission_details", "ante_natal_vitals", "ante_natal_patient_history", "ante natal pmtct", "physical_exam", "ante_natal_vaginal_examination", "general_body_exam", "admission_diagnosis", "ante natal notes", "admissions_note"]
    @groupings["Post Natal Exams"] = ["post_natal_admission_details", "abdominal examination", "post natal pmtct", "post_natal_patient_history", "post_natal_vitals", "post_natal_vaginal_examination", "post natal notes", "admissions_note"]
    @groupings["Update Outcome"] = ["delivered", "discharged", "referred_out", "absconded", "patient_died"]
    @groupings["Baby Outcomes"] = ["baby_examination", "admit_baby", "refer_baby", "kangaroo_review_visit", "give_drugs", "Notes", "Baby Admission Note"]
    @groupings["Baby Outcomes"].delete_if{|outcome| 
      !@task.current_user_activities.collect{|ts| ts.upcase.strip}.include?(outcome.gsub(/\_/, " ").upcase)
    }
    @first_level_order = ["Ante Natal Exams", "Update Outcome"]
    @first_level_order << "Post Natal Exams" if ((@patient.recent_delivery_count > 0) rescue false)
    @first_level_order << "Baby Outcomes" if !((@patient.recent_babies.to_i < 1) rescue false)  
    @first_level_order << "Social History" if @task.current_user_activities.collect{|ts| ts.upcase.strip}.include?("SOCIAL HISTORY")
    @first_level_order << "Give Drugs" if @task.current_user_activities.collect{|ts| ts.upcase.strip}.include?("GIVE DRUGS")

    @first_level_order.insert(1, @first_level_order.delete_at(@first_level_order.index("Post Natal Exams"))) rescue nil if @first_level_order.include?("Post Natal Exams")
    
    @ret = params[:ret].present?? "&ret=#{params[:ret]}" : ""

    #disable tasks for some wrong entries
    @first_level_order = [] if @patient.age(session_date) < 10 || !@patient.gender.match(/f/i)

    @first_level_order.delete_if{|order|
      ((@patient.recent_babies.to_i < 1 && order.match(/Baby Outcomes/i)) rescue false)
    }

    if ((all_recent_babies_entered?(@patient) == true) rescue false)
      prefix = (@patient.recent_babies.to_i + 1) rescue 0

      @prefix = "Baby"
     
      unless (@patient.recent_delivery_count.to_i == 1 rescue false)
        case prefix
        when 1
          @prefix = "1<sup>st</sup> " + @prefix
        when 2
          @prefix = "2<sup>nd</sup> " + @prefix
        when 3
          @prefix = "3<sup>rd</sup> " + @prefix
        else
          @prefix = "#{prefix}<sup>th</sup> " + @prefix
        end
      end
      
      @next_user_task = ["#{@prefix} Delivery",
        "/two_protocol_patients/baby_delivery?patient_id=#{@patient.id}&user_id=#{@user.id}&prefix=#{@prefix}#{@ret}"
      ]
      redirect_to "/two_protocol_patients/baby_delivery?patient_id=#{@patient.id}&user_id=#{@user.id}&prefix=#{@prefix}#{@ret}" and return  if (session[:autoflow].to_s == "true" rescue false)

    else
      
      #watch for the following encounters, if done
      @route = ""
      ["blood transfusion"].each do |concept|
        @check = @patient.encounters.find(:first, :joins => [:observations],
          :conditions => ["DATE(encounter.encounter_datetime) > ?  AND encounter.encounter_type = ? AND obs.concept_id = ?",
            ((session[:datetime].to_date rescue Date.today) - 1.month), EncounterType.find_by_name("UPDATE OUTCOME").id, ConceptName.find_by_name(concept).concept_id])

        next if !@route.blank?
        if @check.blank?

          route = {"blood transfusion" => "mother_delivery_details",
            "procedure done" => "delivery_procedures"
          }
          
          @route = route[concept.downcase]
          
          @next_user_task = ["#{@route.titleize}",
            "/two_protocol_patients/#{@route}?patient_id=#{@patient.id}&user_id=#{@user.id}"
          ]
          
        end
        
      end if (@patient.recent_delivery_count > 0 rescue false)

    end
    
    @groupings["Ante Natal Exams"].each do |encounter|

      next if !@next_user_task.blank? || ((@patient.recent_babies.to_i > 0) rescue true)
      next if !@task.current_user_activities.collect{|ts| ts.upcase}.include?(encounter.titleize.upcase)
     
      scope = @task.task_scopes[encounter.downcase][:scope].upcase rescue nil
      scope = "TODAY" if scope.blank?
      encounter_name = @label_encounter_map[encounter.humanize.upcase] rescue nil
      concept = @task.task_scopes[encounter.titleize.downcase][:concept].upcase rescue nil

      # next if encounter.match(/note/i)
      
      if done_ret(scope, encounter_name, "ante-natal", concept) == "notdone"
        display_task_name = encounter.match(/natal/i)? encounter : ("ante natal " + encounter).humanize
        @next_user_task = [display_task_name.gsub(/examinations|examination/i, "Exam"),
          "/two_protocol_patients/#{encounter.downcase.gsub(/\s/, "_")}?patient_id=#{@patient.id}&user_id=#{@user.id}&ret=ante-natal"]

        if ((@next_user_task && @next_user_task[0].match(/patient\_history/)) rescue false)

          @next_user_task[1] = @next_user_task[1].gsub(/two\_protocol\_|ante\_natal\_|post\_natal\_/, "")

        end
        redirect_to @next_user_task[1]  and return  if (session[:autoflow].to_s == "true" rescue false)
          
      end
    end
    
    if @next_user_task.blank?
      @next_user_task = ["Delivery Outcome",
        "/two_protocol_patients/delivered?patient_id=#{@patient.id}&user_id=#{@user.id}"
      ] if (@patient.recent_babies.to_i == 0  rescue false)

      @groupings["Post Natal Exams"].each do |encounter|
        
        next if !@next_user_task.blank? || (@patient.recent_babies.to_i == 0  rescue true)
        next if !@task.current_user_activities.collect{|ts| ts.upcase}.include?(encounter.titleize.upcase)
          
        scope = @task.task_scopes[encounter.downcase][:scope].upcase rescue nil
        scope = "TODAY" if scope.blank?
        encounter_name = @label_encounter_map[encounter.humanize.upcase] rescue nil
        concept = @task.task_scopes[encounter.titleize.downcase][:concept].upcase rescue nil
        #next if encounter.match(/note/i)
        
        if done_ret(scope, encounter_name, "post-natal", concept) == "notdone"

          display_task_name = encounter.match(/natal/i)? encounter : ("post natal " + encounter).humanize
          @next_user_task = [display_task_name.gsub(/examinations|examination/i, "Exam"),
            "/two_protocol_patients/#{encounter.downcase.gsub(/\s/, "_")}?patient_id=#{@patient.id}&user_id=#{@user.id}&ret=post-natal"]
        
          if ((@next_user_task && @next_user_task[0].match(/patient\_history/)) rescue false)

            @next_user_task[1] = @next_user_task[1].gsub(/two\_protocol\_|ante\_natal\_|post\_natal\_/, "")

          end
          redirect_to @next_user_task[1]  and return  if (session[:autoflow].to_s == "true" rescue false)

        end
     
      end
    end

    if ((@next_user_task && @next_user_task[0].match(/patient\_history/)) rescue false)

      @next_user_task[1] = @next_user_task[1].gsub(/two\_protocol\_|ante\_natal\_|post\_natal\_/, "") 

    end

    @assign_serial_numbers = get_global_property_value("assign_serial_numbers").to_s == "true" rescue false
    
    @pending_birth_reports = BirthReport.pending(@patient)
    @user_unsent_birth_reports = BirthReport.unsent_babies(session[:user_id], @patient.id).map(& :person_b) if session[:user_id].present?
 
    @groupings.delete_if{|key, links|
      @groupings[key].blank?
    }
    @babies = @patient.current_babies rescue []
    
  end

  def done(scope = "", encounter_name = "", ret="", concept = "")

    session_date = session[:datetime].to_date rescue Date.today
    patient_ids = [@task.patient.id]
    patient_ids += Relationship.find_all_by_person_a_and_relationship(@task.patient.id,
      RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child")).collect{|rel| rel.person_b}
      
    scope = "" if concept.blank?
    available = []

    case scope
    when "TODAY"
      available = Encounter.find(:all, :joins => [:observations], :conditions =>
          ["patient_id IN (?) AND encounter_type = ? AND obs.concept_id = ? AND DATE(encounter_datetime) = ?",
          patient_ids, EncounterType.find_by_name(encounter_name).id ,
          ConceptName.find_by_name(concept).concept_id, session_date]).collect{|enc| enc.observations.collect{|ob|
          ob.comments.strip.downcase rescue nil }
      }.flatten.delete_if{|cmt| (!cmt.match(ret) rescue true)}
     
    when "RECENT"
      available = Encounter.find(:all, :joins => [:observations], :conditions =>
          ["patient_id IN (?) AND encounter_type = ? AND obs.concept_id = ? AND DATE(encounter_datetime) >= ? AND DATE(encounter_datetime) <= ?",
          patient_ids, EncounterType.find_by_name(encounter_name).id, ConceptName.find_by_name(concept).concept_id,
          (session_date - 6.month), (session_date + 6.month)]).collect{|enc| enc.observations.collect{|ob|
          ob.comments.strip.downcase rescue nil }
      }.flatten.delete_if{|cmt| (!cmt.match(ret) rescue true)}
      
    when "EXISTS"
      available = Encounter.find(:all, :joins => [:observations], :conditions =>
          ["patient_id IN (?) AND encounter_type = ? AND obs.concept_id = ?",
          patient_ids, EncounterType.find_by_name(encounter_name).id, ConceptName.find_by_name(concept).concept_id]).collect{|enc| enc.observations.collect{|ob|
          ob.comments.strip.downcase rescue nil }
      }.flatten.delete_if{|cmt| (!cmt.match(ret) rescue true)}

    when ""
      
    end

    available = available.blank?? "notdone" : "done"
    available

  end

  def done_ret(scope = "", encounter_name = "", ret = "", concept="")

    session_date = session[:datetime].to_date rescue Date.today
    patient_ids = [@task.patient.id]
    available = []
    ret = "" if ret.blank?
    case scope
    when "TODAY"
      available = Encounter.find(:all, :joins => [:observations], :conditions =>
          ["patient_id IN (?) AND encounter_type = ? AND obs.concept_id = ? AND DATE(encounter_datetime) = ?",
          patient_ids, EncounterType.find_by_name(encounter_name).id ,
          ConceptName.find_by_name(concept).concept_id, session_date.to_date]) rescue []

    when "RECENT"
      available = Encounter.find(:all, :joins => [:observations], :conditions =>
          ["patient_id IN (?) AND encounter_type = ? AND obs.concept_id = ? " +
            "AND (DATE(encounter_datetime) >= ? AND DATE(encounter_datetime) <= ?)",
          patient_ids, EncounterType.find_by_name(encounter_name).id, ConceptName.find_by_name(concept).concept_id,
          (session_date - 6.month), (session_date + 6.month)]) rescue []

    when "EXISTS"
      available = Encounter.find(:all, :joins => [:observations], :conditions =>
          ["patient_id IN (?) AND encounter_type = ? AND obs.concept_id = ? ",
          patient_ids, EncounterType.find_by_name(encounter_name).id, ConceptName.find_by_name(concept).concept_id]) rescue []

    end

    available = available.blank?? "notdone" : "done"
    available

  end
  
  def current_visit
    
    @patient = Patient.find(params[:id] || params[:patient_id]) rescue nil
    d = (session[:datetime].to_date rescue Date.today)
    t = Time.now
    session_date = DateTime.new(d.year, d.month, d.day, t.hour, t.min, t.sec)
    
    ProgramEncounter.current_date = session_date.to_date
    
    @programs = @patient.program_encounters.find(:all, :order => ["date_time DESC"],
      :conditions => ["DATE(date_time) = ?", session_date.to_date]).collect{|p|
      [
        p.id,
        p.to_s,
        p.program_encounter_types.collect{|e|
          next if e.encounter.blank?
         
          [
            e.encounter_id, e.encounter.type.name,
            e.encounter.encounter_datetime.strftime("%H:%M"),
            e.encounter.creator
          ]
        }.uniq,
        p.date_time.strftime("%d-%b-%Y")
      ]
    } if !@patient.blank?

    @programs.delete_if{|prg| prg[2].blank? || (prg[2].first.blank? rescue false)}
    render :layout => false
  end

  def patient_history

    @patient = Patient.find(params[:patient_id])

    @encounters = @patient.encounters.collect{|e| e.name}
    
  end

  def obstetric_counts
    
    @patient = Patient.find(params[:patient_id])
    @anc_patient = ANCService::ANC.new(@patient) rescue nil

    @ret = params[:ret]
    @gravida = params[:observations].collect{|obs|  obs[:value_numeric] if obs[:concept_name].match(/gravida/i)}.compact[0]   rescue 1
    @parity = params[:observations].collect{|obs| obs[:value_numeric] if  obs[:concept_name].match(/parity/i)}.compact[0] rescue 0
    @abortions = params[:observations].collect{|obs| obs[:value_numeric] if  obs[:concept_name].match(/number of abortions/i)}.compact[0] rescue 0

    @birth_year = @anc_patient.birth_year

    @min_birth_year = @birth_year + 13
    @max_birth_year = ((@birth_year + 50) > ((session[:datetime] || Date.today).year) ?
        ((session[:datetime] || Date.today).year) : (@birth_year + 50))

    @abs_max_birth_year = ((@birth_year + 55) > ((session[:datetime] || Date.today).year) ?
        ((session[:datetime] || Date.today).year) : (@birth_year + 55))

    @delivery_modes = ["", "Spontaneous vaginal delivery", "Caesarean Section",
      "Vacuum extraction delivery", "Breech delivery"]

  end

  def visit_history
    @patient = Patient.find(params[:id] || params[:patient_id]) rescue nil

    @task = TaskFlow.new(params[:user_id], @patient.id)
        
    if File.exists?("#{Rails.root}/config/protocol_task_flow.yml")
      map = YAML.load_file("#{Rails.root}/config/protocol_task_flow.yml")["#{Rails.env
        }"]["label.encounter.map"].split(",") rescue []
    end

    @label_encounter_map = {}

    map.each{ |tie|
      label = tie.split("|")[0]
      encounter = tie.split("|")[1] rescue nil

      concept = @task.task_scopes[label.titleize.downcase.strip][:concept].upcase rescue ""
      key  = encounter + "|" + concept
      @label_encounter_map[key] = label if !label.blank? && !encounter.blank?
    }
   
    @programs = @patient.program_encounters.find(:all, :order => ["date_time DESC"]).collect{|p|
     
      [
        p.id,
        p.to_s,
        p.program_encounter_types.collect{|e|
          next if e.encounter.blank?
          labl = label(e.encounter_id, @label_encounter_map) || e.encounter.type.name
          [
            e.encounter_id, labl,
            e.encounter.encounter_datetime.strftime("%H:%M"),
            e.encounter.creator
          ] rescue []
        }.uniq,
        p.date_time.strftime("%d-%b-%Y")
      ]
    } if !@patient.nil?

    @programs.delete_if{|prg| prg[2].blank? || (prg[2].first.blank? rescue false)}
    render :layout => false
  end

  def label(encounter_id, hash)
    concepts = Encounter.find(encounter_id).observations.collect{|ob| ob.concept.name.name.downcase}
    lbl = ""
    hash.each{|val, label|
      lbl = label if (concepts.include?(val.split("|")[1].downcase) rescue false)}
    lbl
  end

  def children

    @patient = Patient.find(params[:id] || params[:patient_id]) rescue nil
    @children = Relationship.find_all_by_person_a_and_relationship(@patient.patient_id,
      RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child").id) rescue nil

    @baby_programs = {}
    @name_sex_map = {}
     
    @children.each {|chil|
      name = Patient.find(chil.person_b).name rescue "Unknown Baby Name"
      @baby_programs["#{name}"] = []
      @name_sex_map["#{name.downcase}"] = (Patient.find(chil.person_b).gender.match(/f/i)? "female" : "male") rescue nil
    }
  
    
    if !@children.blank?

      @children.each{|child|
        @baby = Patient.find(child.person_b)
       
        @programs = @baby.program_encounters.find(:all, :order => ["date_time DESC"]).collect{|p|

          [
            p.id,
            p.to_s,
            p.program_encounter_types.collect{|e|
              next if e.encounter.blank?
              [
                e.encounter_id, e.encounter.type.name,
                e.encounter.encounter_datetime.strftime("%H:%M"),
                e.encounter.creator
              ]
            },
            p.date_time.strftime("%d-%b-%Y")
          ]
        }
        @programs.delete_if{|prg| prg[2].blank? || (prg[2].first.blank? rescue false)}
        @baby_programs["#{@baby.name}"] = @programs if !@programs.blank?
       
      }
       
    end
  
    render :layout => false
  end

  def wrist_band
    @patient = Patient.find(params[:id] || params[:patient_id]) rescue nil

    @children = Relationship.find(:all, :conditions => ["person_a = ? AND relationship = ? AND voided = 0", @patient.id, RelationshipType.find_by_a_is_to_b("Parent").id])
    @children.delete_if{|p| Person.find(p.person_b).dead == 1 }
    
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
    
    user = session[:user_id] || session[:user]["user_id"] || params[:user_id]
    @provider_name = User.find(user).name rescue nil
    
    @facility = get_global_property_value("facility.name")

    @district = get_global_property_value("district.name") rescue ''
    
    maternity = MaternityService::Maternity.new(@patient) rescue nil

    data = maternity.export_person((params[:user_id] rescue 1), @facility, @district)

    render :layout => false
  end

  def print_note
    location = request.remote_ip rescue ""

    @patient    = Patient.find(params[:patient_id] || params[:id] || session[:patient_id]) rescue nil
    person_id = params[:id] || params[:person_id]
    zoom = get_global_property_value("report.zoom.percentage")/100.0 rescue 1
    
    if @patient
      current_printer = ""

      wards = GlobalProperty.find_by_property("facility.ward.printers").property_value.split(",") rescue []

      printers = wards.each{|ward|
        current_printer = ward.split(":")[1] if ward.split(":")[0].upcase == location
      } rescue []

      ["ORIGINAL FOR:(PARENT)", "DUPLICATE FOR:THE HOSPITAL", ""].each do |rec|

        @recipient = rec
        name = rec.split(":").last.downcase.gsub("(", "").gsub(")", "") if !rec.blank?

        t1 = Thread.new{
          Kernel.system "wkhtmltopdf --zoom #{zoom} -s A4 http://" +
            request.env["HTTP_HOST"] + "\"/patients/birth_report_printable/" +
            person_id.to_s + "?patient_id=#{@patient.id}&person_id=#{person_id}&user_id=#{params[:user_id]}&recipient=#{@recipient}" + "\" /tmp/output-#{Regexp.escape(name)}" + ".pdf \n"
        } if !rec.blank?

        t2 = Thread.new{
          sleep(5)
          Kernel.system "lp #{(!current_printer.blank? ? '-d ' + current_printer.to_s : "")} /tmp/output-#{Regexp.escape(name)}" + ".pdf\n"
        } if !rec.blank?

      end

      t3 = Thread.new{
        sleep(15)
        Kernel.system "rm /tmp/output-*"
      }

    end
    redirect_to "/patients/birth_report/#{person_id}?person_id=#{person_id}&patient_id=#{params[:patient_id]}&user_id=#{params[:user_id]}" and return
  end

  def send_birth_report

    facility = get_global_property_value("facility.name") rescue ''

    district = get_global_property_value("district.name") rescue ''

    patient = Patient.find(params[:id]) rescue nil

    maternity = MaternityService::Maternity.new(patient) rescue nil
    user = User.find(params[:user_id]).id rescue nil

    data = maternity.export_person(user, facility, district)

    uri = get_global_property_value("birth_registration_url") rescue nil

    @anc_patient = ANCService::ANC.new(patient) rescue nil

    hospital_date = @anc_patient.get_attribute("Hospital Date")
    health_center = @anc_patient.get_attribute("Health Center")
    health_district = @anc_patient.get_attribute("Health District")
    provider_title = @anc_patient.get_attribute("Provider Title")
    provider_name = @anc_patient.get_attribute("Provider Name")

    @provider_details_available = true if (hospital_date and health_center and health_district and provider_title and provider_name)

    if @provider_details_available
      result = RestClient.post(uri, data) rescue "birth report couldnt be sent"
    end

    birth_report = BirthReport.find_by_person_id(params[:id]) rescue nil

    if !@provider_details_available
      flash[:error] = "Provider Details Incomplete"
    elsif ((result.downcase rescue "") == "baby added") and params[:update].nil?

      flash[:error] = "Birth Report Sent"

      if birth_report.present?
        birth_report.update_attributes(:created_by => session[:user_id],
          :sent_by => session[:user_id] || session[:user]["user_id"] || params[:user_id],
          :date_updated => Time.now,
          :acknowledged => Time.now)
      else
        BirthReport.create(:person_id => params[:id],
          :created_by => session[:user_id] || session[:user]["user_id"] || params[:user_id],
          :sent_by => session[:user_id] || session[:user]["user_id"] || params[:user_id],
          :date_created => Time.now,
          :acknowledged => Time.now)
      end

    elsif ((result.downcase rescue "") == "baby added") and params[:update].present?

      flash[:error] = "Birth Report Updated"

      if birth_report.present?
        birth_report.update_attributes(:created_by => session[:user_id],
          :sent_by => session[:user_id] || session[:user]["user_id"] || params[:user_id],
          :date_updated => Time.now,
          :acknowledged => Time.now)
      else
        BirthReport.create(:person_id => params[:id],
          :created_by => session[:user_id] || session[:user]["user_id"] || params[:user_id],
          :sent_by => session[:user_id] || session[:user]["user_id"] || params[:user_id],
          :date_created => Time.now,
          :acknowledged => Time.now)
      end

    elsif ((result.downcase rescue "") == "baby not added") and params[:update].nil?
      flash[:error] = "Remote System Could Not Add Birth Report"

      BirthReport.create(:person_id => params[:id],
        :created_by => session[:user_id] || session[:user]["user_id"] || params[:user_id],
        :date_created => Time.now)  if birth_report.blank?

    elsif ((result.downcase rescue "") == "baby not added") and params[:update].present?
      flash[:error] = "Remote System Could Not Update Birth Report"
      BirthReport.create(:person_id => params[:id],
        :created_by => session[:user_id] || session[:user]["user_id"] || params[:user_id],
        :date_created => Time.now)  if birth_report.blank?
    else
      flash[:error] = "Sending failed"
      BirthReport.create(:person_id => params[:id],
        :created_by => session[:user_id] || session[:user]["user_id"] || params[:user_id],
        :date_created => Time.now)  if birth_report.blank?
    end

    user = session[:user_id] || session[:user]["user_id"] || params[:user_id]
    redirect_to "/patients/birth_report/#{params[:id]}?person_id=#{params[:id]}&user_id=#{user}&patient_id=#{params[:patient_id]}&today=1" and return
  end

  def void
    @relationship = Relationship.find(params[:id])
    @relationship.void
    head :ok
  end

  def provider_details
    @patient = Patient.find(params[:patient_id])
    @person = Person.find(params[:person_id])
    user = session[:user_id] || session[:user]["user_id"] || params[:user_id]
    @name = User.find(user).name rescue " "
    
    @roles = session[:user]["roles"].join(", ") rescue nil

    @facility = get_global_property_value("facility.name") rescue ''

    @district = get_global_property_value("current_district") rescue ''

  end

  def create_provider

    @patient = Patient.find(params[:person_id]) rescue nil
    @anc_patient = ANCService::ANC.new(@patient) rescue nil
    @roles = session[:user]["roles"].join(", ") rescue nil
    params[:ProviderTitle] = @roles if params[:ProviderTitle].blank?
    
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

  def admissions_note

    @patient = Patient.find(params[:patient_id])
    @return_url = request.referrer
    
  end

  def admissions_note_printable
    @patient    = Patient.find(params[:patient_id]) rescue nil
    @user = params[:user_id]
    @user_name = User.find(@user).name rescue nil if @user.present?
    
    @user_name = User.find(session[:user_id]).name rescue nil if @user_name.blank?

    @facility = get_global_property_value("facility.name") rescue ""

    @patient.create_barcode

    @encounters = {}
    @babyencounters = {}
    @bbaencounters = {}
    @outpatient_diagnosis = {}
    @referral = {}

    @deliveries = 0
    @gravida = 0
    @abortions = 0

    @patient.encounters.find(:all, :conditions => ["encounter_type = ?",
        EncounterType.find_by_name("IS PATIENT REFERRED?").encounter_type_id]).each{|e|
      e.observations.each{|o|
        if o.concept.name.name == "IS PATIENT REFERRED?"
          if !@referral[o.concept.name.name.upcase]
            @referral[o.concept.name.name.upcase] = []
          end

          @referral[o.concept.name.name.upcase] << o.answer_string
        elsif o.concept.name.name.include?("TIME")
          @referral[o.concept.name.name.upcase] = o.value_datetime.to_date
        else
          @referral[o.concept.name.name.upcase] = o.answer_string
        end
      }
    }

    @patient.encounters.find(:all, :conditions => ["encounter_type = ? OR encounter_type = ?",
        EncounterType.find_by_name("DIAGNOSIS").encounter_type_id,
        EncounterType.find_by_name("OBSERVATIONS").encounter_type_id]).each{|e|
      e.observations.each{|o|
        if o.concept.name.name.upcase == "DIAGNOSIS" || o.concept.name.name.upcase == "ADMISSION DIAGNOSIS"
          if !@outpatient_diagnosis[o.concept.name.name.upcase]
            @outpatient_diagnosis[o.concept.name.name.upcase] = []
          end

          @outpatient_diagnosis[o.concept.name.name.upcase] << o.answer_string
        end
      }
    }
  
    @enc_ids  = ["ABDOMINAL EXAMINATION", "OBSERVATIONS", "VITALS"].collect{|enc|
      EncounterType.find_by_name(enc).encounter_type_id rescue nil}

    @patient.encounters.find(:all, :conditions => ["encounter_type IN (?) ",
        @enc_ids]).each{|e|
      e.observations.each{|o|
        if o.concept.name.name.upcase == "DELIVERY MODE"
          if !@encounters[o.concept.name.name.upcase]
            @encounters[o.concept.name.name.upcase] = []
          end

          @encounters[o.concept.name.name.upcase] << o.answer_string
        elsif o.concept.name.name.upcase.include?("TIME")
          @encounters[o.concept.name.name.upcase] = o.value_datetime.strftime("%H:%M")
        else
          name = o.concept.name.name.upcase.gsub('"', "").strip
          @encounters[name] = o.answer_string
        end
      }
    }

    @encounters.keys.each{|key|
      @encounters[key] = @encounters[key].strip rescue @encounters[key]
    }

   
    @patient.encounters.find(:all, :conditions => ["encounter_type = ? ",
        EncounterType.find_by_name("CURRENT BBA DELIVERY").encounter_type_id]).each{|e|
      e.observations.each{|o|
        if o.concept.name.name.upcase == "DELIVERY MODE"
          if !@bbaencounters[o.concept.name.name.upcase]
            @bbaencounters[o.concept.name.name.upcase] = []
          end

          @bbaencounters[o.concept.name.name.upcase] << o.answer_string
        elsif o.concept.name.name.upcase.include?("TIME")
          @bbaencounters[o.concept.name.name.upcase] = o.value_datetime.strftime("%H:%M")
        else
          @bbaencounters[o.concept.name.name.upcase] = o.answer_string
        end
      }
    }

    @patient.encounters.find(:all, :conditions => ["encounter_type = ?",
        EncounterType.find_by_name("PHYSICAL EXAMINATION BABY").encounter_type_id]).each{|e|
      e.observations.each{|o|
        if o.concept.name.name.upcase == "CONDITION OF BABY AT ADMISSION" ||
            o.concept.name.name.upcase == "WEIGHT (KG)" ||
            o.concept.name.name.upcase == "TEMPERATURE (C)" ||
            o.concept.name.name.upcase == "RESPIRATORY RATE" ||
            o.concept.name.name.upcase == "PULSE" ||
            o.concept.name.name.upcase == "CORD CLEAN" ||
            o.concept.name.name.upcase == "CORD TIED" ||
            o.concept.name.name.upcase == "SPECIFY" ||
            o.concept.name.name.upcase == "ABDOMEN"
          if !@babyencounters[o.concept.name.name.upcase]
            @babyencounters[o.concept.name.name.upcase] = []
          end

          @babyencounters[o.concept.name.name.upcase] << o.answer_string
        elsif o.concept.name.name.upcase.include?("TIME")
          @babyencounters[o.concept.name.name.upcase] = o.value_datetime.strftime("%H:%M")
        else
          @babyencounters[o.concept.name.name.upcase] = o.answer_string
        end
      }
    }

    # raise @referral.to_yaml

    @nok = (@patient.next_of_kin["GUARDIAN FIRST NAME"] + " " + @patient.next_of_kin["GUARDIAN LAST NAME"] +
        " - " + @patient.next_of_kin["GUARDIAN RELATIONSHIP TO CHILD"] + " " +
        (@patient.next_of_kin["NEXT OF KIN TELEPHONE"] ? " (" + @patient.next_of_kin["NEXT OF KIN TELEPHONE"] +
          ")" : "")) rescue ""

    @religion = (@patient.next_of_kin["RELIGION"] ? (@patient.next_of_kin["RELIGION"].upcase == "OTHER" ?
          @patient.next_of_kin["OTHER"] : @patient.next_of_kin["RELIGION"]) : "") rescue ""

    @education = @patient.next_of_kin["EDUCATION LEVEL"] rescue ""

    @position = (@encounters["CEPHALIC"] ? @encounters["CEPHALIC"] : "") +
      (@encounters["BREECH"] ? @encounters["BREECH"] : "") + (@encounters["FACE"] ? @encounters["FACE"] : "") +
      (@encounters["SHOULDER"] ? @encounters["SHOULDER"] : "") rescue ""

    if @encounters["PRESENTATION"] && @encounters["PRESENTATION"].upcase == "BREECH"
      @position = @encounters["BREECH DELIVERY"] if  @encounters["BREECH DELIVERY"].downcase.match("sacro")
    end

    if (@encounters["ARV START DATE"].match("/") rescue false)
      mon = [" ", "Jan","Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
      year = @encounters["ARV START DATE"].split("/")[2].to_i
      month = @encounters["ARV START DATE"].split("/")[1]
      month = mon.index(month).to_i
      day = @encounters["ARV START DATE"].split("/")[0].to_i
      date_started_arvs = Date.new(year, month, day)
      months_from_start_date = date_started_arvs.year * 12 + date_started_arvs.month
      months_today = Date.today.year * 12 + Date.today.month
      @period_on_arvs = months_today - months_from_start_date
      @period_on_arvs_string = (@period_on_arvs > 11)? ((@period_on_arvs/12).to_s == 1? (@period_on_arvs/12).to_s + " Yr   " +
          (@period_on_arvs%12).to_s + " months": (@period_on_arvs./12).to_s + " Yrs " + (@period_on_arvs%12).to_s + " months") :  (@period_on_arvs%12).to_s + " months"
    else
      @period_on_arvs_string = ""
    end
    lmp_date = (@encounters["DATE OF LAST MENSTRUAL PERIOD"].to_date - 7.days) rescue nil
    current_date = ((session[:datetime] && session[:datetime].present?)? session[:datetime] : Date.today).to_date rescue nil

    if ((lmp_date.to_date + 10.months >= Date.today) rescue false)
      @edd_weeks = ((current_date - lmp_date).days).to_i/(60 * 60 * 24 * 7) rescue "Unknown"
    else
      @edd_weeks = "Unknown"
    end
    
    render :layout => false
  end

  def all_recent_babies_entered?(patient)

    (patient.recent_babies < patient.recent_delivery_count) rescue false
    
  end
  
  def delivery_print

    patient = Patient.find(params[:patient_id])

    if [false, 0, "0", "false"].include?(patient.person.dead)
      print_string = (patient.national_id_label rescue "") + (patient.baby_details("summary") rescue "") + (patient.baby_details("apgar") rescue "") + (patient.baby_details("complications") rescue "")
    else
      print_string = (patient.national_id_label rescue "") + (patient.baby_details("summary") rescue "") + (patient.baby_details("complications") rescue "")
    end

    send_data(print_string,
      :type=>"application/label; charset=utf-8",
      :stream=> false,
      :filename=>"#{params[:patient_id]}#{rand(10000)}.lbl",
      :disposition => "inline")
  end
  
  def art_summary

    art_link = get_global_property_value("art.link") rescue nil

    data = JSON.parse(RestClient.get("#{art_link}/encounters/art_summary?national_id=#{params[:national_id]}")) rescue {}
    data["start_date"] = data["start_date"].to_date.strftime("%d/%b/%Y") rescue "" if !data["start_date"].blank?
    
    data.keys.each {|key|
      data[key.titleize.upcase] = data[key]
      data.delete(key)
    }
 
    render :text => data.to_json
    
  end


  def create_registration(patient, program)

    return if patient.blank?

    @encounter = Encounter.create(:patient_id => patient.patient_id,
      :encounter_type => EncounterType.find_by_name("REGISTRATION").id,
      :encounter_datetime => (session[:datetime].to_time rescue Time.now),
      :provider_id => (session[:user_id] || params[:user_id]),
      :location_id => session[:location_id],
      :creator => (session[:user_id] || params[:user_id])
    )

    Observation.create(:person_id => patient.patient_id,
      :concept_id => ConceptName.find_by_name("Workstation location").concept_id,
      :value_text => Location.find(session[:location_id]).name,
      :location_id => session[:location_id],
      :encounter_id => @encounter.id,
      :creator => (session[:user_id] || params[:user_id]),
      :obs_datetime => (session[:datetime] || Time.now)
    )

    @program = Program.find_by_concept_id(ConceptName.find_by_name(program).concept_id) rescue nil

    @program_encounter = ProgramEncounter.find_by_program_id(@program.id,
      :conditions => ["patient_id = ? AND DATE(date_time) = ?",
        patient.id,  (session[:datetime].to_time rescue Time.now).to_date.strftime("%Y-%m-%d")])

    if @program_encounter.blank?

      @program_encounter = ProgramEncounter.create(
        :patient_id => patient.id,
        :date_time =>  (session[:datetime].to_time rescue Time.now),
        :program_id => @program.id
      )

    end

    ProgramEncounterDetail.create(
      :encounter_id => @encounter.id.to_i,
      :program_encounter_id => @program_encounter.id,
      :program_id => @program.id
    )

    @current = PatientProgram.find_by_program_id(@program.id,
      :conditions => ["patient_id = ? AND COALESCE(date_completed, '') = ''", patient.id])

    if @current.blank?

      @current = PatientProgram.create(
        :patient_id => patient.id,
        :program_id => @program.id,
        :date_enrolled => (session[:datetime].to_time rescue Time.now)
      )

    end
      
  end

  def baby_admissions_note

    pids = PatientIdentifier.find_all_by_identifier(params[:identifier])
    
    @patient = pids.last.patient
    @mother = Patient.find(@patient.mother.person_a)
    @return_url = request.referrer
    
  end

  def baby_admissions_note_printable

    @baby = Patient.find(params[:baby_id])
    @mother =  Patient.find(@baby.mother.person_a)
    @user = (params[:user_id] || session[:user_id])
    @user_name = User.find(@user).name rescue nil if @user.present?

    @user_name = User.find(params[:user_id] || session[:user_id]).name rescue nil if @user_name.blank?

    @facility = get_global_property_value("facility.name") rescue ""

    @maternal_history = @mother.maternal_history
    #raise @maternal_history.to_yaml
    @birth_history = @baby.birth_history

    @maternal_complications = @mother.maternal_complications

    @birth_complications = @baby.birth_complications

    @admission_details = @baby.admission_details

    @referral_details = @baby.referral_details

    @prematurity = "Unknown"
    @prem = "No"
    if @maternal_history["LMP"].present? && @birth_history["DATE OF CONFINEMENT"].present?
      date_diff_wks = (@birth_history["DATE OF CONFINEMENT"].to_date - @maternal_history["LMP"].to_date).to_i/7 rescue nil
      if date_diff_wks.present? && date_diff_wks > 0
        if date_diff_wks < 34
          @prem = "Yes"
          @prematurity = " #{date_diff_wks} wks   -   Pre term"
        elsif date_diff_wks <= 37
          @prem = "Yes"
          @prematurity = " #{date_diff_wks} wks   -   Near term"
        elsif date_diff_wks <= 42
          @prematurity = " #{date_diff_wks} wks   -   Full term"
        elsif date_diff_wks > 42
          @prematurity = " #{date_diff_wks} wks   -   Post term"
        end
      end
    end
    

    @baby.create_barcode("baby_id")
    @mother.create_barcode

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
