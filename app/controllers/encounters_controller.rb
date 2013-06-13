
class EncountersController < ApplicationController

  before_filter :check_user, :except => [:missing_program, :static_locations,
    :missing_concept, :no_user, :no_patient, :check_role_activities,
    :missing_encounter_type, :diagnoses, :missing_baby]

  def create
  
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
        "Unknown")}", params["concept"]["Gender"], birth_date).to_s.strip rescue nil
        
      my_baby = PatientIdentifier.find_by_sql("SELECT * FROM patient_identifier WHERE identifier = #{baby_id}
          AND identifier_type = (SELECT patient_identifier_type_id FROM patient_identifier_type WHERE name = 'National id')
          ORDER BY date_created DESC LIMIT 1") if !baby_id.blank?
     
      patient = Patient.find(my_baby.first.patient_id) rescue patient

      mother_address = PersonAddress.find_by_person_id(params[:patient_id]) rescue nil

      if !mother_address.blank?
        baby_address = mother_address       

        baby_address.update_attributes(:person_id => patient.patient_id,
          :date_created =>  (session[:datetime].to_date rescue Date.today)
        )
      end
        
    end
   
    if !patient.nil?
      
      type = EncounterType.find_by_name(params[:encounter_type]).id rescue nil

      if !type.nil?
        @encounter = Encounter.create(
          :patient_id => patient.id,
          :provider_id => (params[:user_id]),
          :encounter_type => type,
          :location_id => (session[:location_id] || params[:location_id])
        )

        @current = nil
        
        if !params[:program].blank?

          @program = Program.find_by_concept_id(ConceptName.find_by_name(params[:program]).concept_id) rescue nil

          if !@program.nil?

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

              else

                redirect_to "/encounters/missing_concept?concept=#{item}" and return if !item.blank?

              end

            end

          end

        end

      else

        redirect_to "/encounters/missing_encounter_type?encounter_type=#{params[:encounter_type]}" and return

      end
     
      @task = TaskFlow.new(params[:user_id] || User.first.id, params[:patient_id])

      redirect_to params[:next_url] and return if !params[:next_url].nil?

      redirect_to @task.next_task.url and return

    end
    
  end

  def list_observations
    obs = []

    obs = Encounter.find(params[:encounter_id]).observations.collect{|o|
      [o.id, o.to_piped_s] rescue nil
    }.compact

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
        [
          e.encounter_id, e.encounter.type.name.titleize,
          e.encounter.encounter_datetime.strftime("%H:%M"),
          e.encounter.creator,
          e.encounter.encounter_datetime.strftime("%d-%b-%Y")
        ]
      }
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

  def diagnoses

    search_string         = (params[:search_string] || '').upcase

    diagnosis_concepts    = Concept.find_by_name("Qech outpatient diagnosis list").concept_members.collect{|c| c.concept.fullname}.sort.uniq rescue ["Unknown"]

    @results = diagnosis_concepts.collect{|e| e}.delete_if{|x| !x.upcase.match("#{search_string}")}

    render :text => "<li>" + @results.join("</li><li>") + "</li>"

  end
  
end
