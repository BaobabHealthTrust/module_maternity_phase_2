
class EncountersController < ApplicationController
 	unloadable  

  def create
 
    d = (session[:datetime].to_date rescue Date.today)   
    t = Time.now
    session_date = DateTime.new(d.year, d.month, d.day, t.hour, t.min, t.sec)
    
    assign_serial_numbers = get_global_property_value("assign_serial_numbers").to_s == "true" rescue false

    if assign_serial_numbers
      serial_num = SerialNumber.find(:first, :conditions => ["national_id IS NULL"]) rescue nil
      redirect_to "/encounters/no_serial_number"  and return  if serial_num.blank?
    end

    
    @current_location_name = Location.find(session[:location_id]).name rescue nil
    @gynae = @current_location_name.match(/Gynaecology/i)[0] rescue ""
    @theater = @current_location_name.match(/Theater/i)[0] rescue ""
    @baby_location = @current_location_name.match(/kangaroo ward|nursery ward/i) ? true : false
    @baby_id = nil
    
    @ret = params[:ret].present?? "&ret=#{params[:ret]}" : ""
    params[:concept] = extract_concepts(params[:observations]) rescue {} if params[:concept].blank?
      
    if params[:autoflow].present? && params[:autoflow].to_s == "true"
      session[:autoflow] = "true"
    elsif params[:autoflow].present? && params[:autoflow].to_s == "false"
      session[:autoflow] = "false"
    end
    
    #watch for terminal conditions
    if params["proc_check"] && (params["concept"]["Procedure Done"].blank? || params["concept"]["Procedure Done"].downcase == "none")
      redirect_to "/patients/show/#{params[:patient_id]}?user_id=#{params[:user_id]}&autoflow=false" and return
    end
    
    if params["concept"]["Baby identifier"] && !params["concept"]["Baby identifier"].blank?

      my_baby = PatientIdentifier.find_all_by_identifier_and_identifier_type(params["concept"]["Baby identifier"],
        PatientIdentifierType.find_by_name("National id").patient_identifier_type_id) rescue nil     

      if !my_baby.blank? && my_baby.length == 1
       
        my_children = Relationship.find(:all, :conditions => ["person_a = ? AND relationship = ? AND voided = 0",
            params[:patient_id], RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child").id]).collect{|rel|
          rel.person_b
        } rescue []
        
      end
          
      if ((my_baby.blank? || !my_children.include?(my_baby.last.patient.patient_id)) rescue true)        
        redirect_to "/encounters/missing_baby?national_id=#{params['concept']['Baby identifier']}&ward=" and return
               
      end unless ["baby delivery", "admit patient"].include?(params[:encounter_type].downcase.strip)
      
      if !my_baby.blank? && my_baby.length == 1
        fake_identifier =  params['concept']['Baby identifier']
        params["concept"].delete("Baby identifier")
        params[:person_id] = my_baby.last.patient.patient_id
      end

      if params[:concept].blank?
     
        session[:baby_id] = params[:person_id]

        redirect_to "/patients/show?patient_id=#{session[:baby_id]}&user_id=#{session[:user_id] || params[:user_id]}" and return

      end
    end
    
    patient = Patient.find(params[:person_id]) rescue nil if params[:person_id]
    patient = Patient.find(params[:patient_id]) rescue nil if patient.blank?

    procedures_check = request.referrer.match(/delivery\_procedures/).present?
    
    if @baby_location && (params["concept"]["Blood transfusion"].present? || procedures_check)
      #mother delivery details, switch client to mother for saving observations
      #@baby_id to be used for switching back to baby client after saving is finished
      @baby_id = params[:patient_id]
      mother_id = patient.person.mother.person_a
      params[:patient_id] = mother_id
      patient = Patient.find(mother_id)      
    end
       
    #create baby given condition
    if (!@baby_location) and (my_baby.first.patient.patient_id.blank? rescue true) and params[:encounter_type].downcase.strip == "baby delivery" and !params["concept"]["Time of delivery"].blank?
      
      baby = Baby.new(params[:user_id], params[:patient_id], session[:location_id], session_date)

      mother = Person.find(params[:patient_id]) rescue nil

      link = get_global_property_value("patient.registration.url").to_s rescue nil

      children = Relationship.find(:all, :conditions => ["person_a = ? AND voided = 0 AND relationship = ?", params[:patient_id], RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child").id])

      first_name = "Baby-" + (children.length + 1).to_s

      #Check for duplicate names
      child_names = PersonName.find(:all, :conditions => ["person_id IN (?)", children.collect{|child| child.person_a}]).collect{|name|
        name.given_name rescue nil}.uniq
      
      if child_names.include?(first_name)
        first_name = first_name +"_"+ (session_date.to_date).year.to_s + "/"
      end
      
      birth_date = params["concept"]["Date of delivery"].to_date rescue session_date.to_date

      baby_id = baby.associate_with_mother("#{link}", first_name,
        "#{(!mother.nil? ? (mother.names.first.family_name rescue "Unknown") :
        "Unknown")}", params["concept"]["Gender"], birth_date).to_s.strip #rescue nil
      
      redirect_to "/encounters/missing_baby?message=culdn't_find_baby_for_#{patient.name}" and return if baby_id.blank?

      my_baby = PatientIdentifier.find_by_sql("SELECT * FROM patient_identifier WHERE identifier = #{baby_id}
          AND identifier_type = (SELECT patient_identifier_type_id FROM patient_identifier_type WHERE name = 'National id')
          ORDER BY date_created DESC LIMIT 1") if !baby_id.blank?
     
      patient = Patient.find(my_baby.first.patient_id) rescue patient

      mother_address = PersonAddress.find_by_person_id(params[:patient_id]) rescue nil


      if !mother_address.blank? && params[:patient_id] != patient.patient_id

        export_mother_addresss(params[:patient_id], patient.patient_id) rescue nil

        if assign_serial_numbers

          id_type = PatientIdentifierType.find_by_name("Serial Number").patient_identifier_type_id
          serial_num = SerialNumber.find(:first, :conditions => ["national_id IS NULL"])

          PatientIdentifier.create(:patient_id => patient.patient_id,
            :identifier => serial_num.serial_number,
            :identifier_type => id_type,
            :location_id => (session[:location_id] || params[:location_id])
          ) if serial_num.present? && id_type.present?

          serial_num.national_id = patient.national_id
          serial_num.date_assigned = session_date.to_date rescue Date.today
          serial_num.save

        end
        
      end
      
      if  params["concept"]["BABY OUTCOME"].present? && !params["concept"]["BABY OUTCOME"].match(/Alive/i)
        patient.person.update_attributes(:dead => true,
          :death_date => session_date) if (!my_baby.first.blank? rescue false)
        patient.release_serial_number if (!my_baby.first.blank? rescue false)
      end
    end
    
    if params["concept"]["STATUS OF BABY"].present? && !params["concept"]["STATUS OF BABY"].match(/Alive/i)
      patient.person.update_attributes(:dead => true,
        :death_date => session_date)
    end

    if params["concept"]["Condition of baby at admission"].present? && params["concept"]["Condition of baby at admission"].match(/Dead/i)
      patient.person.update_attributes(:dead => true,
        :death_date => session_date)
    end

    if params["concept"]["Outcome"].present? && params["concept"]["Outcome"].match(/patient died/i)
      patient.person.update_attributes(:dead => true,
        :death_date => (params["concept"]["DATE OF DEATH"].to_date rescue session_date))
    end
    
    if params["concept"]["TREATMENT GROUP"].present?
      params["concept"]["TREATMENT GROUP"] = params["concept"]["TREATMENT GROUP"].delete_if{|val| val.blank?}.join(", ")
    end
    
    if !patient.blank?
      
      type = EncounterType.find_by_name(params[:encounter_type]).id rescue nil

      if !type.blank?
        
        concepts_tag_to_merge = params[:concept].keys.collect{|ky|ky.upcase if ky.match(/Procedure Done|Perineum/i)}.compact

        if (concepts_tag_to_merge.length > 0) && ((params[:encounter_type].downcase.strip == "update outcome" && patient.recent_delivery_outcome.present?) rescue false)
          @encounter = Encounter.find(patient.recent_delivery_outcome(session_date))
        else
          @encounter = Encounter.create(
            :patient_id => patient.id,
            :provider_id => (params[:user_id] || session[:user_id]),
            :encounter_type => type,
            :encounter_datetime => session_date,
            :location_id => (session[:location_id] || params[:location_id])
          )
        end

        @current = nil
        
        if !params[:program].blank?

          @program = Program.find_by_concept_id(ConceptName.find_by_name(params[:program]).concept_id) rescue nil

          if !@program.blank?

            @program_encounter = ProgramEncounter.find_by_program_id(@program.id,
              :conditions => ["patient_id = ? AND DATE(date_time) = ?",
                patient.id, session_date.to_date.strftime("%Y-%m-%d")])

            if @program_encounter.blank?

              @program_encounter = ProgramEncounter.create(
                :patient_id => patient.id,
                :date_time => session_date,
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
                :date_enrolled => session_date
              )

            end

          else
            
            redirect_to "/encounters/missing_program?program=#{params[:program]}" and return

          end

        end

        if params[:concept].has_key?("PLAN") &&  params[:concept].has_key?("IMPRESSION")
          #force these concepts to be saved at all costs
          params[:concept]["PLAN"] = "None" if params[:concept]["PLAN"].blank?
          params[:concept]["IMPRESSION"] = "None" if params[:concept]["IMPRESSION"].blank?
        end
      
        params[:concept].each do |key, value|

          if value.blank?
            next
          end

          if value.class.to_s.downcase != "array"

            concept = ConceptName.find_by_name(key.strip).concept_id rescue nil

            if !concept.nil? and !value.blank?

              if !@program.nil? and !@current.nil?
                
                selected_state = @program.program_workflows.map(&:program_workflow_states).flatten.select{|pws|
                  pws.concept.fullname.upcase() == value.upcase()
                }.first rescue nil
                
                @current.transition({
                    :state => "#{value}",
                    :start_date => session_date,
                    :end_date => session_date
                  }) if !selected_state.nil?
              end
              
              concept_type = nil
              if value.strip.match(/^\d+$/)

                concept_type = "number"

              elsif value.strip.match(/^\d{4}-\d{2}-\d{2}$/)

                concept_type = "date"

              elsif value.strip.match(/^\d{2}\:\d{2}\:\d{2}$/)

                concept_type = "time"

              else

                value_coded = ConceptName.find_by_name(value.strip) rescue nil

                if !value_coded.nil?

                  concept_type = "value_coded"

                else

                  concept_type = "text"

                end

              end
              
              obs = Observation.new(
                :person_id => @encounter.patient_id,
                :concept_id => concept,
                :location_id => @encounter.location_id,
                :obs_datetime => @encounter.encounter_datetime,
                :encounter_id => @encounter.id
              )

              case concept_type
              when "date"

                obs.value_datetime = value

              when "time"

                obs.value_datetime = "#{session_date.strftime("%Y-%m-%d")} " + value

              when "number"

                obs.value_numeric = value

              when "value_coded"

                obs.value_coded = value_coded.concept_id
                obs.value_coded_name_id = value_coded.concept_name_id

              else

                obs.value_text = value
                
              end

              if (params[:ret] && !params[:ret].blank?) || @gynae.present? || @theater.present?
                if !@gynae.blank?
                  obs.comments = @gynae
                elsif !@theater.blank?
                  obs.comments = @theater
                else
                  obs.comments = params[:ret]
                end
              end

              if (concept == ConceptName.find_by_name("ADMISSION SECTION").concept_id && params[:encounter_type].downcase.strip == "admit patient")
                
                @last_location = Observation.find(:first, :order => ["obs_datetime DESC"],
                  :conditions => ["person_id = ? AND concept_id = ? AND  obs_datetime >= ?",
                    params[:patient_id], ConceptName.find_by_name("ADMISSION SECTION").concept_id, 7.days.ago]).location_id  rescue nil

                obs.comments = @last_location if ((@last_location.present? && session[:location_id].to_i != @last_location.to_i))

              end
              
              obs.save

            else

              redirect_to "/encounters/missing_concept?concept=#{key}" and return if !value.blank?

            end

          else

            value.each do |item|

              concept = ConceptName.find_by_name(key.strip).concept_id rescue nil

              if !concept.nil? and !item.blank?

                if !@program.nil? and !@current.nil?
                  selected_state = @program.program_workflows.map(&:program_workflow_states).flatten.select{|pws|
                    pws.concept.fullname.upcase() == item.upcase()
                  }.first rescue nil

                  @current.transition({
                      :state => "#{item}",
                      :start_date => session_date,
                      :end_date => session_date
                    }) if !selected_state.nil?
                end
              
                concept_type = nil
                if item.strip.match(/^\d+$/)

                  concept_type = "number"

                elsif item.strip.match(/^\d{4}-\d{2}-\d{2}$/)

                  concept_type = "date"

                elsif item.strip.match(/^\d{2}\:\d{2}\:\d{2}$/)

                  concept_type = "time"

                else

                  value_coded = ConceptName.find_by_name(item.strip) rescue nil

                  if !value_coded.nil?

                    concept_type = "value_coded"

                  else

                    concept_type = "text"

                  end

                end

                obs = Observation.new(
                  :person_id => @encounter.patient_id,
                  :concept_id => concept,
                  :location_id => @encounter.location_id,
                  :obs_datetime => @encounter.encounter_datetime,
                  :encounter_id => @encounter.id
                )

                case concept_type
                when "date"

                  obs.value_datetime = item

                when "time"

                  obs.value_datetime = "#{session_date.strftime("%Y-%m-%d")} " + item

                when "number"

                  obs.value_numeric = item

                when "value_coded"

                  obs.value_coded = value_coded.concept_id
                  obs.value_coded_name_id = value_coded.concept_name_id

                else

                  obs.value_text = item

                end

                if (params[:ret] && !params[:ret].blank?) || @gynae.present? || @theater.present?
                  if !@gynae.blank?
                    obs.comments =  @gynae
                  elsif !@theater.blank?
                    obs.comments = @theater
                  else
                    obs.comments = params[:ret]
                  end
                end

                if (concept == ConceptName.find_by_name("ADMISSION SECTION").concept_id && params[:encounter_type].downcase.strip == "admit patient")

                  @last_location = Observation.find(:first, :order => ["obs_datetime DESC"],
                    :conditions => ["person_id = ? AND concept_id = ? AND obs_datetime >= ?",
                      params[:patient_id], ConceptName.find_by_name("ADMISSION SECTION").concept_id, 7.days.ago]).location_id  rescue nil

                  obs.comments = @last_location if ((@last_location.present? && session[:location_id].to_i != @last_location.to_i))

                end
                
                obs.save
                
              else

                redirect_to "/encounters/missing_concept?concept=#{item}" and return if !item.blank?

              end

            end

          end

        end

      else

        redirect_to "/encounters/missing_encounter_type?encounter_type=#{params[:encounter_type]}" and return

      end

      if ((params[:patient_id] && all_recent_babies_entered?(Patient.find(params[:patient_id])) == true) rescue false)
        prefix = (Patient.find(params[:patient_id]).recent_babies.to_i + 1) rescue 0

        @prefix = "Baby"

        unless (Patient.find(params[:patient_id]).recent_delivery_count.to_i == 1 rescue false)
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

        @user_id = session[:user]["user_id"] rescue params[:users_id]

        if ((params[:patient_id] != patient.patient_id && params["encounter_type"].to_s.downcase.strip == "baby delivery") rescue false)

          print_and_redirect("/patients/delivery_print?patient_id=#{patient.patient_id}",
            "/two_protocol_patients/baby_delivery?patient_id=#{@baby_id || params[:patient_id]}&user_id=#{@user_id}&prefix=#{@prefix}#{@ret}") and return

        else

          redirect_to "/two_protocol_patients/baby_delivery?patient_id=#{@baby_id || params[:patient_id]}&user_id=#{@user_id}&prefix=#{@prefix}#{@ret}" and return
 
        end
        
      end
      
      @task = TaskFlow.new(params[:user_id] || session[:user_id] || User.first.id, params[:patient_id], session_date)
      
      unless ((params[:patient_id] != patient.patient_id && params["encounter_type"].to_s.downcase.strip == "baby delivery") rescue false)
        
        if params["encounter_type"].downcase.strip == "update outcome" && params["concept"]["DISCHARGED"].present?
          
          print_and_redirect("/encounters/label/?encounter_id=#{@encounter.id}",
            params[:next_url] + "#{@ret}")  and return if !params[:next_url].blank?
          
          print_and_redirect("/encounters/label/?encounter_id=#{@encounter.id}",
            "/patients/show/#{@baby_id || params[:patient_id]}?user_id=#{params[:user_id]}#{@ret}") and return
          
        else

          unless (params[:next_url].match(/admit\_to\_ward/i) &&
                Location.find(session[:location_id]).name.match(/registration|labour\sward/i) rescue false)
         
            redirect_to params[:next_url] + "#{@ret}" and return if !params[:next_url].blank?
            
          end
          redirect_to "/patients/show/#{@baby_id || params[:patient_id]}?user_id=#{params[:user_id]}#{@ret}" and return
        end
        
      else
        
        print_and_redirect("/patients/delivery_print?patient_id=#{patient.patient_id}",
          params[:next_url] + "#{@ret}")  and return if !params[:next_url].blank?
        print_and_redirect("/patients/delivery_print?patient_id=#{patient.patient_id}",
          "/patients/show/#{@baby_id || params[:patient_id]}?user_id=#{params[:user_id]}#{@ret}") and return
        
      end
    end
    
  end

  def all_recent_babies_entered?(patient)
    
    (patient.recent_babies < patient.recent_delivery_count) rescue false
  end

  def extract_concepts(observations)

    concepts = {}
    observ = observations.map{|ob|
      [ob[:concept_name], (ob[:value_text].present?  ? ob[:value_text] :
            (ob[:value_numeric].present? ? ob[:value_numeric] : ob[:value_datetime] )).to_s]
    }.delete_if{|obs| obs[1].blank?}

    observ.each{|key, val|
      concepts[key] << val if concepts.has_key?(key)
      concepts[key] = [val] if !concepts.has_key?(key)
    }
   
    concepts
  end
  
  def label
    send_label(Encounter.find(params[:encounter_id]).label)
  end

  def list_observations
    obs = []
    encounter = Encounter.find(params[:encounter_id])

    if encounter.type.name.upcase == "TREATMENT"
      obs = encounter.orders.collect{|o|
        ["drg", o.to_s]
      }
    else
      obs = encounter.observations.collect{|o|
        [o.id, o.to_piped_s] rescue nil
      }.compact
    end
    
    render :text => obs.to_json
  end

  def void
    prog = ProgramEncounterDetail.find_by_encounter_id(params[:encounter_id]) rescue nil

    unless prog.blank?
     
      encounter = Encounter.find(params[:encounter_id]) rescue nil

      enc_name = encounter.type.name
      patient = encounter.patient
      born_alive = patient.delivery_outcome.match(/alive/i) rescue false
      discharge_err = patient.discharge_outcome.match(/dead/i) rescue false
      limited = patient.person.death_date.to_date <= patient.person.birthdate.to_date + 1.month rescue false


      if born_alive && discharge_err && limited

        patient.person.update_attributes(:dead => false,
          :death_date => nil,
          :cause_of_death => nil)

      end rescue nil
      
      unless encounter.blank?
        prog.void
        encounter.void
      end
      
      if ((enc_name.match(/update\soutcome/i) &&
              (encounter.observations.collect{|ob| ob.answer_string.upcase.strip}).include?("DELIVERED")) rescue false)

        if encounter.patient.recent_babies(session[:datetime] || Date.today)
          #void recent delivered babies
          (encounter.patient.recent_baby_relations(session[:datetime] || Date.today) || []).each{|rel|
            rel.void
          }
        end
        
      end

    end

    render :text => [].to_json
  end

  def list_encounters
    result = []
    
    program = ProgramEncounter.find(params[:program_id]) rescue nil
  
    @task = TaskFlow.new(params[:user_id], program.patient_id)

    @current_location_name = Location.find(session[:location_id]).name
    @baby_location = @current_location_name.match(/kangaroo ward|nursery ward/i) ? true : false

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
    
    # raise  @label_encounter_map.to_yaml
    unless program.nil?
      result = program.program_encounter_types.find(:all, :joins => [:encounter],
        :order => ["encounter_datetime DESC"]).collect{|e|
        next if e.encounter.blank?

        if (session[:baby_id].blank? && !@baby_location) || request.referrer.match(/mother\_tab/)
          labl = labell(e.encounter_id, @label_encounter_map).titleize rescue nil if params[:baby].blank?
          labl = label2_4baby(e.encounter_id, @label_encounter_map).titleize rescue nil if !params[:baby].blank?
        end

        labl = e.encounter.type.name.titleize if labl.blank?
        labl = "Notes" if (labl.downcase.strip == "observations" rescue false)
        
        [
          e.encounter_id, labl,
          e.encounter.encounter_datetime.strftime("%H:%M"),
          e.encounter.creator,
          e.encounter.encounter_datetime.strftime("%d-%b-%Y")
        ]
      }.uniq
    end

    render :text => result.to_json
  end
  def label2_4baby(encounter_id, hash)
    encounter = Encounter.find(encounter_id)
    concepts = encounter.observations.collect{|ob| ob.concept.name.name.downcase}.delete_if{|conc| conc.match(/clinician notes/i)}

    lbl = ""
    hash.each{|val, label|
      concept = val.split("|")[1].downcase rescue nil
      next if ((encounter.type.name.match(/update outcome/i) && concept.match(/diagnosis/i)) rescue false)
      lbl = label if (concepts.include?(concept) rescue false)
    }
    
    lbl
    #lbl.gsub(/examination/i , "exam").gsub(/ante natal|post natal/i, "")
  end
  
  def labell(encounter_id, hash)
    encounter = Encounter.find(encounter_id)
    concepts = encounter.observations.collect{|ob| ob.concept.name.name.downcase}.delete_if{|conc| conc.match(/clinician notes/i)}
    
    lbl = ""
    hash.each{|val, label|
      concept = val.split("|")[1].downcase rescue nil
      next if ((encounter.type.name.match(/update outcome/i) && concept.match(/diagnosis/i)) rescue false)
      lbl = label if (concepts.include?(concept) rescue false)
    }

    ret = encounter.observations.collect{|ob| ob.comments }.compact.first.titleize rescue ""
    replc = lbl.gsub(/Ante Natal|Post Natal|Gynaecology|Theater/i, " ")
    return encounter.name if encounter.name.match(/Admit Patient|Is Patient referred\?/i)
    lbl = "<i>#{ret}</i> #{replc}" if (ret.match(/Gynaecology|Theater|Ante Natal|Post Natal/i) && !lbl.match(/#{ret}/i)rescue false)
    lbl = lbl.gsub(/Theater/i, "<i>Th.</i>").gsub(/Gynaecology/i, "<i>Gyna.</i>").gsub(/Examination/i , "exam").gsub(/Ante Natal/i, "<i>An.</i>").gsub(/Post Natal/i, "<i>Pn.</i>")
    lbl
    
  end

  def static_locations
    search_string = params[:search_string].upcase
    filter_list = params[:filter_list].split(/, */) rescue []
    locations =  Location.find(:all, :select =>'name', :conditions => ["name LIKE ?", '%' + search_string + '%'])
    render :text => "<li>" + locations.map{|location| location.name }.join("</li><li>") + "</li>"
  end
  
  def static_locations2
    search_string = (params[:search_string] || "").upcase
    extras = ["Health Facility", "Home", "TBA", "Other"]

    locations = []

    File.open(RAILS_ROOT + "/public/data/locations.txt", "r").each{ |loc|
      locations << loc if loc.upcase.strip.match(search_string)
    }

    if params[:extras]
      extras.each{|loc| locations << loc if loc.upcase.strip.match(search_string)}
    end

    render :text => "<li></li><li " + locations.map{|location| "value=\"#{location.strip}\">#{location.strip}" }.join("</li><li ") + "</li>"

  end

  def relation_type
    search_string = params[:search_string]
    relation = ["Mother",
      "Husband",
      "Sister",
      "Friend",
      "Aunt",
      "Neighbour",
      "Mother-in-law",
      "Landlord/Landlady",
      "Other"]

    @relation = Observation.find(:all, :joins => [:concept, :encounter],
      :conditions => ["obs.concept_id = ? AND NOT value_text IN (?) AND " +
          "encounter_type = ?",
        ConceptName.find_by_name("OTHER RELATIVE").concept_id, relation,
        EncounterType.find_by_name("SOCIAL HISTORY").id]).collect{|o| o.value_text}

    @relation = relation + @relation
    @relation = @relation.collect{|rel| rel.gsub('-', ' ').gsub('_', ' ').squish.titleize}.uniq
    @relation = @relation.collect{|rel| rel if rel.downcase.include?(search_string.downcase)}

    render :text => "<li></li><li>" + @relation.join("</li><li>") + "</li>"

  end
  def religion
    search_string = params[:search_string]
    religions = ["Jehovahs Witness",
      "Roman Catholic",
      "Presbyterian (C.C.A.P.)",
      "Seventh Day Adventist",
      "Baptist",
      "Moslem",
      "Other"]

    @religions = Observation.find(:all, :joins => [:concept, :encounter],
      :conditions => ["obs.concept_id = ? AND NOT value_text IN (?) AND " +
          "encounter_type = ?",
        ConceptName.find_by_name("Other").concept_id, religions,
        EncounterType.find_by_name("SOCIAL HISTORY").id]).collect{|o| o.value_text}

    @religions = religions + @religions
    @religions = @religions.collect{|rel| rel.gsub('-', ' ').gsub('_', ' ').squish.titleize}.uniq
    @religions = @religions.collect{|rel| rel if rel.downcase.include?(search_string.downcase)}
    render :text => "<li></li><li>" + @religions.join("</li><li>") + "</li>"
  end
  def diagnoses
    
    search_string = (params[:search_string] || '').upcase
    filter_list = params[:filter_list].split(/, */) rescue []
    previous_answers = []
    
    if params[:set].blank?
      outpatient_diagnosis = ConceptName.find_by_name("DIAGNOSIS").concept
      diagnosis_concept_set = ConceptName.find_by_name("MATERNITY DIAGNOSIS LIST").concept
      previous_answers = Observation.find_most_common(outpatient_diagnosis, search_string)
    else
      diagnosis_concept_set = ConceptName.find_by_name(params[:set].titleize).concept
    end
    
    diagnosis_concepts = Concept.find(:all, :joins => :concept_sets,
      :conditions => ['concept_set = ?', diagnosis_concept_set.id])

    valid_answers = diagnosis_concepts.map{|concept|
      name = concept.fullname rescue nil
      name.upcase.include?(search_string) ? name : nil rescue nil
    }.compact
    previous_answers = []
    # TODO Need to check global property to find out if we want previous answers or not (right now we)
   
    @suggested_answers = (previous_answers + valid_answers.sort!).reject{|answer| filter_list.include?(answer) }.uniq[0..10]
    @suggested_answers = @suggested_answers - params[:search_filter].split(',') rescue @suggested_answers

    render :text => "<li></li>" + "<li>" + @suggested_answers.join("</li><li>") + "</li>"
  end

  def list_complications
    search_string = (params[:search_string] || '')

    @suggested_answers =  [
      "None", "Fever", "Ante part hemorrhage", "Post part hemorrhage", " Prolonged first stage of labour",
      "Prolonged second stage of labour", "Pre-Eclampsia", "Sepsis", "Ruptured uterus", "Convulsions", "Proteunia",
      "PV Bleeding", "Hypertension", "UTI", "Other"
    ].delete_if{|value| !value.match(/#{params[:search_string]}/i)}
    
    render :text => "<option>" + "<li>" + @suggested_answers.join("</li><li>") + "</li>"
  end
  
  def current_baby_exam

    children = Encounter.find(:all, :joins =>[:observations],
      :conditions => ["person_id = ? AND encounter_type = ? AND encounter_datetime > ? AND concept_id = ? AND value_text = ?",
        params[:patient_id], EncounterType.find_by_name("OUTCOME"), 9.months.ago.strftime("%Y-%m-%d"),
        Concept.find_by_name("BABY OUTCOME"),
        "ALIVE"
      ]).length rescue 0
    redirect to "/two_protocol_patients/current_baby_exam_baby?baby=#{params[:baby]}&patient_id=#{params[:patient_id]}&baby_total=#{children}"
  end

  def baby_delivery_mode
    search_string = params[:search_string]
    @options = Concept.find_by_name("BABY OUTCOME").concept_answers.collect{|c| c.name}
    @options = @options.collect{|rel| rel if rel.downcase.include?(search_string.downcase)}
    @options.delete_if{|rel| rel.match(/Intrauterine/i)}
    render :text => "<li></li><li>" + @options.join("</li><li>") + "</li>"
  end
  def presentation
    search_string = params[:search_string]
    @options = Concept.find_by_name("PRESENTATION").concept_answers.collect{|c| c.name}
    @options = @options.collect{|rel| rel if rel.downcase.include?(search_string.downcase)}
    render :text => "<li></li><li>" + @options.join("</li><li>") + "</li>"
  end
  def concept_set_options
    search_string = params[:search_string]
    set = params[:set].gsub("_", " ").strip.upcase
    @options = Concept.find_by_name(set).concept_answers.collect{|c| c.name}
    @options = @options.collect{|rel| rel if rel.downcase.include?(search_string.downcase)}
   
    @options.delete_if{|opt| !opt.blank? and opt.match(/Intrauterine death/i) and set.downcase == "baby outcome"}
    render :text => "<li></li><li>" + @options.join("</li><li>") + "</li>"
  end
  def procedure_diagnoses

    procedure = params[:procedure].upcase.gsub("_", " ")
    procedure ="Exploratory laparatomy +/- adnexectomy".upcase  if params[:procedure] == "laparatomy"
    procedure ="Evacuation/Manual Vacuum Aspiration".upcase  if params[:procedure] == "evacuation"
    search_string         = (params[:search_string] || '').upcase

    diagnosis_concept_set = ConceptName.find_by_name(procedure).concept
    diagnosis_concepts = Concept.find(:all, :joins => :concept_sets,
      :conditions => ['concept_set = ?', diagnosis_concept_set.id])
    valid_answers = diagnosis_concepts.map{|concept|
      name = concept.fullname rescue nil
      name.upcase.include?(search_string) ? name : nil rescue nil
    }.compact

    @results = valid_answers.collect{|e| e if e.downcase.include?(search_string.downcase)}

    render :text => "<li></li>" + "<li>" + @results.join("</li><li>") + "</li>"
  end

  def export_mother_addresss(mother_id, baby_id)

    mother_address = PersonAddress.find_by_person_id(mother_id)

    keys = mother_address.attributes.keys.delete_if{|key| key.blank? || key.match(/person_id|person_address_id|date_created/)}
    baby_address = PersonAddress.new
    baby_address.person_id = baby_id

    keys.each do |ky|
      baby_address["#{ky}"] = mother_address["#{ky}"]
    end

    baby_address.save
    
  end

  def generics
    search_string = (params[:search_string] || '').upcase
    filter_list = params[:filter_list].split(/, */) rescue []
    @drug_concepts = ConceptName.find(:all,
      :select => "concept_name.name",
      :joins => "INNER JOIN drug ON drug.concept_id = concept_name.concept_id AND drug.retired = 0",
      :conditions => ["concept_name.name LIKE ?", '%' + search_string + '%'],:group => 'drug.concept_id')
    render :text => "<li>" + @drug_concepts.map{|drug_concept| drug_concept.name }.uniq.join("</li><li>") + "</li>"
  end

  def generic
    
    medication_tag = get_global_property_value("application_generic_medication")

    if !medication_tag.blank?

      application_drugs = concept_set(medication_tag)

    else

      application_drugs = ActiveRecord::Base.connection.select_all(
        "SELECT concept_name.name name, drug.concept_id concept_id FROM drug
        INNER JOIN concept_name ON drug.concept_id = concept_name.concept_id AND concept_name.voided = 0 AND drug.retired = 0"
      ).map{|drg| [drg["name"], drg["concept_id"]]}.compact.uniq

    end

    application_drugs.uniq
  
  end

  def baby_drugs_route

    @return_url = request.referrer
    @patient = Patient.find(params[:patient_id])
   
  end
  
  def give_drugs

    @return_url = params[:return_url] || request.referrer

    @baby = Patient.find(session[:baby_id]) rescue nil
    
    if @baby
      @patient = @baby
      params[:patient_id] = @baby.patient_id
      @program = "UNDER 5 PROGRAM"
    else
      @patient = Patient.find(params[:patient_id])
    end
   
    @generics = generic
  
    values = []
    @generics.each { | gen |
      if gen[0].downcase == "nvp" or gen[0].downcase == "nevirapine" or gen[0].match(/albendazole/i) or
          gen[0].match(/fefol/i) or gen[0].downcase == "fansidar"  or gen[0].downcase == "sp"
        @generics.delete(gen)
        values << gen
      end
    }
    values.each { |val|
      @generics.insert(0, val)
    }

    @frequencies = drug_frequency
    @diagnosis = @patient.current_diagnoses["DIAGNOSIS"] rescue []
  end

  def load_frequencies_and_dosages
    # @drugs = Drug.drugs(params[:concept_id]).to_json
    @drugs = drugs(params[:concept_id]).to_json
    render :text => @drugs
  end

  def dosages(generic_drug_concept_id)

    Drug.find(:all, :conditions => ["concept_id = ?", generic_drug_concept_id]).collect {|d|
      ["#{d.dose_strength.to_i rescue 1}#{d.units.upcase rescue ""}", "#{d.dose_strength.to_i rescue 1}", "#{d.units.upcase rescue ""}"]
    }.uniq.compact rescue []

  end

  def drug_frequency
    # ConceptName.drug_frequency

    # This method gets the collection of all short forms of frequencies as used in
    # the Diabetes Module and returns only no-empty values or an empty array if none
    # exist
    ConceptName.find_by_sql("SELECT name FROM concept_name WHERE concept_id IN \
                        (SELECT answer_concept FROM concept_answer c WHERE \
                        concept_id = (SELECT concept_id FROM concept_name \
                        WHERE name = 'DRUG FREQUENCY CODED')) AND concept_name_id \
                        IN (SELECT concept_name_id FROM concept_name_tag_map \
                        WHERE concept_name_tag_id = (SELECT concept_name_tag_id \
                        FROM concept_name_tag WHERE tag = 'preferred_dmht'))").collect {|freq|
      freq.name rescue nil
    }.compact rescue []

  end

  def drugs(generic_drug_concept_id)
    frequencies = drug_frequency
    collection = []

    Drug.find(:all, :conditions => ["concept_id = ? AND retired = 0", generic_drug_concept_id]).each {|d|
      frequencies.each {|freq|
        dr = d.dose_strength.to_s.match(/(\d+)\.(\d+)/)
        collection << ["#{(dr ? (dr[2].to_i > 0 ? d.dose_strength : dr[1]) : d.dose_strength.to_i) rescue 1}#{d.units.upcase rescue ""}", "#{freq}"]
      }
    }.uniq.compact rescue []

    collection.uniq
  end

  def create_prescription

    d = (session[:datetime].to_date rescue Date.today)
    t = Time.now
    session_date = DateTime.new(d.year, d.month, d.day, t.hour, t.min, t.sec)
    
    User.current = User.find(session[:user]["user_id"])
    redirect_to params[:return_url] || "/patients/show/#{params[:patient_id]}?user_id=#{User.current.user_id}" and return if params[:prescription].blank?
    
    if params[:prescription]

      params[:prescription].each do |prescription|

        @suggestions = prescription[:suggestion] || ['New Prescription']
        @patient = Patient.find(params[:patient_id]) rescue nil

        type = EncounterType.find_by_name(params[:encounter][:encounter_type_name]).id rescue nil
        encounter = @patient.encounters.find(:first, :order => ["encounter_datetime DESC"],
          :conditions => ["voided = 0 AND encounter_type = ? AND DATE(encounter_datetime) = ?", type, (session[:datetime].to_date rescue Date.today)]) rescue nil

        if !type.blank? && encounter.blank?
          encounter = Encounter.create(
            :patient_id => @patient.id,
            :provider_id => (User.current.user_id),
            :encounter_type => type,
            :encounter_datetime => session_date,
            :location_id => (session[:location_id] || params[:location_id])
          )
        end
        
        if !encounter.blank?
          @current = nil

          if !params[:program].blank?

            @program = Program.find_by_concept_id(ConceptName.find_by_name(params[:program]).concept_id) rescue nil

            if !@program.blank?

              @program_encounter = ProgramEncounter.find_by_program_id(@program.id,
                :conditions => ["patient_id = ? AND DATE(date_time) = ?",
                  @patient.id, session_date.strftime("%Y-%m-%d")])

              if @program_encounter.blank?

                @program_encounter = ProgramEncounter.create(
                  :patient_id => @patient.id,
                  :date_time => session_date,
                  :program_id => @program.id
                )

              end

              @encounter_detail = ProgramEncounterDetail.create(
                :encounter_id => encounter.id.to_i,
                :program_encounter_id => @program_encounter.id,
                :program_id => @program.id
              )

              @current = PatientProgram.find_by_program_id(@program.id,
                :conditions => ["patient_id = ? AND COALESCE(date_completed, '') = ''", @patient.id])

              if @current.blank?

                @current = PatientProgram.create(
                  :patient_id => @patient.id,
                  :program_id => @program.id,
                  :date_enrolled => session_date
                )

              end

            end

          end

        end
    
        if !prescription[:formulation]
          # redirect_to "/patients/print_exam_label/?patient_id=#{@patient.id}" and return if (encounter.type.name.upcase rescue "") ==
          #  "TREATMENT"
          next
          #redirect_to next_task(@patient) and return
        end

        unless params[:location]
          session_date = session[:datetime] || params[:encounter_datetime] || Time.now()
        else
          session_date = params[:encounter_datetime] #Use encounter_datetime passed during import
        end
      
        Location.current_location = Location.find(params[:location]) if params[:location]

        @encounter = encounter
        @diagnosis = Observation.find(prescription[:diagnosis]) rescue nil
        @suggestions.each do |suggestion|
          unless (suggestion.blank? || suggestion == '0' || suggestion == 'New Prescription')
            @order = DrugOrder.find(suggestion)
            DrugOrder.clone_order(@encounter, @patient, @diagnosis, @order)
          else

            @formulation = (prescription[:formulation] || '').upcase
            @drug = Drug.find_by_name(@formulation) rescue nil
            unless @drug
              flash[:notice] = "No matching drugs found for formulation #{prescription[:formulation]}"
              render :give_drugs, :patient_id => params[:patient_id], :user_id => User.current.user_id
              return
            end
            start_date = session_date
            auto_expire_date = session_date.to_date + prescription[:duration].to_i.days
            prn = prescription[:prn].to_i
            if prescription[:type_of_prescription] == "variable"

              DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug,
                start_date, auto_expire_date, [prescription[:morning_dose],
                  prescription[:afternoon_dose], prescription[:evening_dose],
                  prescription[:night_dose]], prescription[:type_of_prescription], prn)

            else
              DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug,
                start_date, auto_expire_date, prescription[:dose_strength], prescription[:frequency], prn)
            end
          end
        end

      end

    else

      @suggestions = params[:suggestion] || ['New Prescription']
      @patient = Patient.find(params[:patient_id]) rescue nil

      encounter = Encounter.new(params[:encounter])
      encounter.encounter_datetime ||= session[:datetime]
      encounter.save

      unless params[:location]
        session_date = session[:datetime] || params[:encounter_datetime] || Time.now()
      else
        session_date = params[:encounter_datetime] #Use encounter_datetime passed during import
      end
      # set current location via params if given
      Location.current_location = Location.find(params[:location]) if params[:location]

      @encounter = encounter
      @diagnosis = Observation.find(params[:diagnosis]) rescue nil
      @suggestions.each do |suggestion|
        unless (suggestion.blank? || suggestion == '0' || suggestion == 'New Prescription')
          @order = DrugOrder.find(suggestion)
          DrugOrder.clone_order(@encounter, @patient, @diagnosis, @order)
        else

          @formulation = (params[:formulation] || '').upcase
          @drug = Drug.find_by_name(@formulation) rescue nil
          unless @drug
            flash[:notice] = "No matching drugs found for formulation #{params[:formulation]}"
            render :give_drugs, :patient_id => params[:patient_id]
            return
          end
          start_date = session_date
          auto_expire_date = session_date.to_date + params[:duration].to_i.days
          prn = params[:prn].to_i
          if params[:type_of_prescription] == "variable"
            DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug,
              start_date, auto_expire_date, [params[:morning_dose],
                params[:afternoon_dose], params[:evening_dose], params[:night_dose]], 'VARIABLE', prn)
          else
            DrugOrder.write_order(@encounter, @patient, @diagnosis, @drug,
              start_date, auto_expire_date, params[:dose_strength], params[:frequency], prn)
          end
        end
      end

    end

    #  redirect_to "/patients/print_exam_label/?patient_id=#{@patient.id}" and return if (@encounter.type.name.upcase rescue "") ==
    #   "TREATMENT"
   
    redirect_to params[:return_url] || "/patients/show/#{params[:patient_id]}?user_id=#{User.current.user_id}"

  end

  def print_note

    location = request.remote_ip rescue ""
    zoom = get_global_property_value("report.zoom.percentage")/100.0 rescue 1
    @patient    = Patient.find(params[:patient_id]) rescue (Patient.find(params[:id]) rescue (Patient.find(session[:patient_id]) rescue nil))

    if @patient
      current_printer = ""

      wards = GlobalProperty.find_by_property("facility.ward.printers").property_value.split(",") rescue []

      printers = wards.each{|ward|
        current_printer = ward.split(":")[1] if ward.split(":")[0].upcase == location
      } rescue []

      cat = params[:cat].blank? ? "" : params[:cat] + "_"
      
      t1 = Thread.new{
        Kernel.system "wkhtmltopdf --zoom #{zoom} -s A4 http://" +
          request.env["HTTP_HOST"] + "\"/patients/#{cat}admissions_note_printable/" +
          @patient.patient_id.to_s + "?patient_id=#{@patient.patient_id}&baby_id=#{@patient.id}&user_id=#{params[:user_id]}&ret=#{params[:ret]}"+ "\" /tmp/output-" + params[:user_id].to_s + ".pdf \n"
      }

      t2 = Thread.new{
        sleep(5)
        Kernel.system "lp #{(!current_printer.blank? ? '-d ' + current_printer.to_s : "")} /tmp/output-" +
          session[:user_id].to_s + ".pdf\n"
      }

      t3 = Thread.new{
        sleep(20)
        Kernel.system "rm /tmp/output-*"
      }

    end
    
    redirect_to "/patients/#{cat}admissions_note?patient_id=#{@patient.id}&baby_id=#{@patient.id}&user_id=#{session[:user_id]}&identifier=#{params[:identifier]}"+
      (params[:ret] ? "&ret=" + params[:ret] : "") and return
  end

  def probe_values
    patient = Patient.find(params[:patient_id])
    result = ""
    session_date = session[:datetime].to_date rescue Date.today

    concept_id = ConceptName.find_by_name(params[:concept_name]).concept_id rescue nil
    render :text => "".to_json  and return if concept_id.blank?

    patient.encounters.find(:all, :order => ["encounter_datetime DESC"], :limit => 1, :joins => [:observations],
      :conditions => ["obs.concept_id = ? AND DATE(encounter_datetime) >= ?",
        concept_id, (session_date - 1.month)]).each{|enc|

      enc.observations.each{|obs|
        if obs.concept.concept_id == concept_id
          result = obs.answer_string.titleize.strip if result.blank?
        end
      }
      
    }
   
    render :text => result.to_s.to_json
  end

  def void_order
    order = Order.find(params[:order_id])

    if order.present?
      encounter = order.encounter
      order.void
      if encounter.orders.blank? && encounter.name.match(/TREATMENT/i)
        encounter.void
      end
    end
    
    return render :text => {"ok" => true}.to_json
  end

end
