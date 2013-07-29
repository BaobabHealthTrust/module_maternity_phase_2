
class EncountersController < ApplicationController
 	unloadable  

  def create

    @ret = params[:ret].present?? "&ret=#{params[:ret]}" : ""

    if params[:autoflow].present? && params[:autoflow].to_s == "true"
      session[:autoflow] = "true"
    elsif params[:autoflow].present? && params[:autoflow].to_s == "false"
      session[:autoflow] = "false"
    end
    
    #watch for terminal conditions
    if params["proc_check"] && (params["concept"]["Procedure Done"].blank? || params["concept"]["Procedure Done"].downcase == "none")
      redirect_to "/patients/show/#{params[:patient_id]}?user_id=#{params[:user_id]}" and return
    end
    
    if (params["concept"]["Baby identifier"])

      my_baby = PatientIdentifier.find_all_by_identifier_and_identifier_type(params["concept"]["Baby identifier"],
        PatientIdentifierType.find_by_name("National id").patient_identifier_type_id) rescue nil

      if !my_baby.blank? && my_baby.length == 1
       
        my_children = Relationship.find(:all, :conditions => ["person_a = ? AND relationship = ? AND voided = 0",
            params[:patient_id], RelationshipType.find_by_a_is_to_b("Parent").id]).collect{|rel|
          rel.person_b
        } rescue []
        
      end 
      
      if ((my_baby.blank? || !my_children.include?(my_baby.first.patient.patient_id)) rescue true)
        
        redirect_to "/encounters/missing_baby?national_id=#{params['concept']['Baby identifier']}&ward=" and return
               
      end unless params[:encounter_type].downcase.strip == "baby delivery"
      
      if !my_baby.blank? && my_baby.length == 1
        fake_identifier =  params['concept']['Baby identifier']
        params["concept"].delete("Baby identifier")
        params[:person_id] = my_baby.first.patient.patient_id
      end
      
    end   
    
    patient = Patient.find(params[:person_id]) rescue nil if params[:person_id]    
    patient = Patient.find(params[:patient_id]) rescue nil if patient.blank?
        
    if params[:encounter_type].downcase.squish == "kangaroo review visit"

      admitted_in_kangaroo = Patient.find(params[:patient_id]).wards_hash.split("|").collect{|p|
        p.split("--")[0].upcase if p.split("--")[1].match(/kangaroo/i)
      }.compact.include?(fake_identifier.upcase) rescue false

      redirect_to "/encounters/missing_baby?national_id=#{fake_identifier}&ward=kangaroo" and return if !admitted_in_kangaroo
      
    end
    
    #create baby given condition
    if (my_baby.first.patient.patient_id.blank? rescue true) and params[:encounter_type].downcase.strip == "baby delivery" and !params["concept"]["Time of delivery"].nil?
      
      baby = Baby.new(params[:user_id], params[:patient_id], session[:location_id], (session[:datetime] || Date.today))

      mother = Person.find(params[:patient_id]) rescue nil

      link = get_global_property_value("patient.registration.url").to_s rescue nil

      children = Relationship.find(:all, :conditions => ["person_a = ? AND voided = 0 AND relationship = ?", params[:patient_id], RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child").id])

      first_name = "Baby-" + (children.length + 1).to_s

      #Check for duplicate names
      child_names = PersonName.find(:all, :conditions => ["person_id IN (?)", children.collect{|child| child.person_a}]).collect{|name|
        name.given_name rescue nil}.uniq

      if child_names.include?(first_name)
        first_name = first_name +"_"+ Date.today.year.to_s + "/"
      end
      
      birth_date = params["concept"]["Date of delivery"].to_date rescue Date.today

      baby_id = baby.associate_with_mother("#{link}", first_name,
        "#{(!mother.nil? ? (mother.names.first.family_name rescue "Unknown") :
        "Unknown")}", params["concept"]["Gender"], birth_date).to_s.strip #rescue nil

      redirect_to "/encounters/missing_baby?message=failed_to_create_baby_for_#{patient.name}" and return if baby_id.blank?

      my_baby = PatientIdentifier.find_by_sql("SELECT * FROM patient_identifier WHERE identifier = #{baby_id}
          AND identifier_type = (SELECT patient_identifier_type_id FROM patient_identifier_type WHERE name = 'National id')
          ORDER BY date_created DESC LIMIT 1") if !baby_id.blank?
     
      patient = Patient.find(my_baby.first.patient_id) rescue patient

      mother_address = PersonAddress.find_by_person_id(params[:patient_id]) rescue nil

      export_mother_addresss(params[:patient_id],
        patient.patient_id) rescue nil if !mother_address.blank? && params[:patient_id] != patient.patient_id
          
      if !params["concept"]["BABY OUTCOME"].match(/Alive/i)
        patient.person.update_attributes(:dead => true) if (!my_baby.first.blank? rescue false)
      end
      
    end
   
    if !patient.blank?
      
      type = EncounterType.find_by_name(params[:encounter_type]).id rescue nil

      if !type.blank?
        @encounter = Encounter.create(
          :patient_id => patient.id,
          :provider_id => (params[:user_id]),
          :encounter_type => type,
          :location_id => (session[:location_id] || params[:location_id])
        )

        @current = nil
        
        if !params[:program].blank?

          @program = Program.find_by_concept_id(ConceptName.find_by_name(params[:program]).concept_id) rescue nil

          if !@program.blank?

            @program_encounter = ProgramEncounter.find_by_program_id(@program.id,
              :conditions => ["patient_id = ? AND DATE(date_time) = ?",
                patient.id, Date.today.strftime("%Y-%m-%d")])

            if @program_encounter.blank?

              @program_encounter = ProgramEncounter.create(
                :patient_id => patient.id,
                :date_time => Time.now,
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
                :date_enrolled => Time.now
              )

            end

          else
            
            redirect_to "/encounters/missing_program?program=#{params[:program]}" and return

          end

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
                    :start_date => Time.now,
                    :end_date => Time.now
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
              
              obs = Observation.create(
                :person_id => @encounter.patient_id,
                :concept_id => concept,
                :location_id => @encounter.location_id,
                :obs_datetime => @encounter.encounter_datetime,
                :encounter_id => @encounter.id
              )

              case concept_type
              when "date"

                obs.update_attribute("value_datetime", value)

              when "time"

                obs.update_attribute("value_datetime", "#{Date.today.strftime("%Y-%m-%d")} " + value)

              when "number"

                obs.update_attribute("value_numeric", value)

              when "value_coded"

                obs.update_attribute("value_coded", value_coded.concept_id)
                obs.update_attribute("value_coded_name_id", value_coded.concept_name_id)

              else

                obs.update_attribute("value_text", value)
                
              end

              if params[:ret] && !params[:ret].blank?

                obs.update_attributes(:comments => params[:ret])

              end

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
                      :start_date => Time.now,
                      :end_date => Time.now
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

                obs = Observation.create(
                  :person_id => @encounter.patient_id,
                  :concept_id => concept,
                  :location_id => @encounter.location_id,
                  :obs_datetime => @encounter.encounter_datetime,
                  :encounter_id => @encounter.id
                )

                case concept_type
                when "date"

                  obs.update_attribute("value_datetime", item)

                when "time"

                  obs.update_attribute("value_datetime", "#{Date.today.strftime("%Y-%m-%d")} " + item)

                when "number"

                  obs.update_attribute("value_numeric", item)

                when "value_coded"

                  obs.update_attribute("value_coded", value_coded.concept_id)
                  obs.update_attribute("value_coded_name_id", value_coded.concept_name_id)

                else

                  obs.update_attribute("value_text", item)

                end

                if params[:ret] && !params[:ret].blank?

                  obs.update_attributes(:comments => params[:ret])

                end

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

        @user_id = session[:user]["user_id"] rescue params[:users_id]

        if ((params[:patient_id] != patient.patient_id && params["encounter_type"].to_s.downcase.strip == "baby delivery") rescue false)

          print_and_redirect("/patients/delivery_print?patient_id=#{patient.patient_id}",
            "/two_protocol_patients/baby_delivery?patient_id=#{params[:patient_id]}&user_id=#{@user_id}&prefix=#{@prefix}#{@ret}") and return

        else

          redirect_to "/two_protocol_patients/baby_delivery?patient_id=#{params[:patient_id]}&user_id=#{@user_id}&prefix=#{@prefix}#{@ret}" and return
 

        end
        
      end
      
      @task = TaskFlow.new(params[:user_id] || User.first.id, params[:patient_id])
      
      unless ((params[:patient_id] != patient.patient_id && params["encounter_type"].to_s.downcase.strip == "baby delivery") rescue false)
        redirect_to params[:next_url] + "#{@ret}" and return if !params[:next_url].blank?
        redirect_to "/patients/show/#{params[:patient_id]}?user_id=#{params[:user_id]}#{@ret}" and return
        redirect_to @task.next_task.url + "#{@ret}" and return
      else
        
        print_and_redirect("/patients/delivery_print?patient_id=#{patient.patient_id}",
          params[:next_url] + "#{@ret}")  and return if !params[:next_url].blank?

        print_and_redirect("/patients/delivery_print?patient_id=#{patient.patient_id}",
          "/patients/show/#{params[:patient_id]}?user_id=#{params[:user_id]}#{@ret}") and return

        print_and_redirect("/patients/delivery_print?patient_id=#{patient.patient_id}",
          @task.next_task.url + "#{@ret}") and return
      end
    end
    
  end

  def all_recent_babies_entered?(patient)
    
    (patient.recent_babies < patient.recent_delivery_count) rescue false
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

    unless prog.nil?
      prog.void

      encounter = Encounter.find(params[:encounter_id]) rescue nil

      unless encounter.nil?
        encounter.void
      end

    end

    

    render :text => [].to_json
  end

  def list_encounters
    result = []
    
    program = ProgramEncounter.find(params[:program_id]) rescue nil

    unless program.nil?
      result = program.program_encounter_types.find(:all, :joins => [:encounter],
        :order => ["encounter_datetime DESC"]).collect{|e|
        next if e.encounter.blank?
        [
          e.encounter_id, e.encounter.type.name.titleize,
          e.encounter.encounter_datetime.strftime("%H:%M"),
          e.encounter.creator,
          e.encounter.encounter_datetime.strftime("%d-%b-%Y")
        ]
      }.uniq
    end

    render :text => result.to_json
  end

  def static_locations
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
		outpatient_diagnosis = ConceptName.find_by_name("DIAGNOSIS").concept

		diagnosis_concept_set = ConceptName.find_by_name("MATERNITY DIAGNOSIS LIST").concept
		diagnosis_concepts = Concept.find(:all, :joins => :concept_sets,
      :conditions => ['concept_set = ?', diagnosis_concept_set.id])

		valid_answers = diagnosis_concepts.map{|concept|
			name = concept.fullname rescue nil
			name.upcase.include?(search_string) ? name : nil rescue nil
		}.compact
		previous_answers = []
		# TODO Need to check global property to find out if we want previous answers or not (right now we)
		previous_answers = Observation.find_most_common(outpatient_diagnosis, search_string)
		@suggested_answers = (previous_answers + valid_answers.sort!).reject{|answer| filter_list.include?(answer) }.uniq[0..10]
		@suggested_answers = @suggested_answers - params[:search_filter].split(',') rescue @suggested_answers

		render :text => "<li></li>" + "<li>" + @suggested_answers.join("</li><li>") + "</li>"
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
    generics = []
    # preferred = ConceptName.find_by_name("Maternity Prescriptions").concept.concept_members.collect{|c| c.id} rescue []

    Drug.all.each{|drug|
      #Concept.find(drug.concept_id, :conditions => ["retired = 0 AND concept_id IN (?)", preferred]).concept_names.each{|conceptname|
      Concept.find(drug.concept_id, :conditions => ["retired = 0"]).concept_names.each{|conceptname|
        generics << [(conceptname.name.titleize == "Tetanus Toxoid Vaccine" ? "TTV" : conceptname.name), drug.concept_id] rescue nil
      }.compact.uniq rescue []
    }

    generics.uniq
  end

  def give_drugs

   
    @return_url = request.referrer
    @patient = Patient.find(params[:patient_id]) rescue nil
   
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
    User.current = User.find(session[:user]["user_id"])
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
                  @patient.id, Date.today.strftime("%Y-%m-%d")])

              if @program_encounter.blank?

                @program_encounter = ProgramEncounter.create(
                  :patient_id => @patient.id,
                  :date_time => Time.now,
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
                  :date_enrolled => Time.now
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

      if !params[:formulation]
        #redirect_to "/patients/print_exam_label/?patient_id=#{@patient.id}" and return if (encounter.type.name.upcase rescue "") ==
        #  "TREATMENT"
        next
        #redirect_to next_task(@patient) and return
      end

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
   
    redirect_to "/patients/show/#{params[:patient_id]}?user_id=#{User.current.user_id}"

  end

  def print_note

    location = request.remote_ip rescue ""
    
    @patient    = Patient.find(params[:patient_id]) rescue (Patient.find(params[:id]) rescue (Patient.find(session[:patient_id]) rescue nil))

    if @patient
      current_printer = ""

      wards = GlobalProperty.find_by_property("facility.ward.printers").property_value.split(",") rescue []

      printers = wards.each{|ward|
        current_printer = ward.split(":")[1] if ward.split(":")[0].upcase == location
      } rescue []

      t1 = Thread.new{
        Kernel.system "wkhtmltopdf -s A4 http://" +
          request.env["HTTP_HOST"] + "\"/patients/admissions_printable/" +
          @patient.patient_id.to_s + "?patient_id=#{@patient.patient_id}&user_id=#{params[:user_id]}&ret=#{params[:ret]}"+ "\" /tmp/output-" + params[:user_id].to_s + ".pdf \n"
      }

      t2 = Thread.new{
        sleep(5)
        Kernel.system "lp #{(!current_printer.blank? ? '-d ' + current_printer.to_s : "")} /tmp/output-" +
          session[:user_id].to_s + ".pdf\n"
      }

      t3 = Thread.new{
        sleep(10)
        Kernel.system "rm /tmp/output-" + session[:user_id].to_s + ".pdf\n"
      }


    end

    redirect_to "/patients/admissions_note?patient_id=#{@patient.id}&user_id=#{session[:user_id]}"+
      (params[:ret] ? "&ret=" + params[:ret] : "") and return
  end

  def probe_values
    patient = Patient.find(params[:patient_id])
    result = ""
    session_date = session[:datetime].to_date rescue Date.today
     
    patient.encounters.find(:all, :order => ["encounter_datetime DESC"], :limit => 1, :joins => [:observations],
      :conditions => ["obs.concept_id = ? AND DATE(encounter_datetime) >= ?",
        ConceptName.find_by_name(params[:concept_name]).concept_id, (session_date - 1.month)]).each{|enc|

      enc.observations.each{|obs|
        if obs.concept.name.name.downcase.strip == params[:concept_name].downcase.strip          
          result = obs.answer_string.strip if result.blank?
        end
      }
      
    }
   
    render :text => result.to_s.to_json
  end

end
