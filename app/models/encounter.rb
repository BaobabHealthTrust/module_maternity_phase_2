class Encounter < ActiveRecord::Base
  set_table_name :encounter
  set_primary_key :encounter_id
  include Openmrs

  has_one :program_encounter, :foreign_key => :encounter_id, :conditions => {:voided => 0}
  has_many :observations, :dependent => :destroy, :conditions => {:voided => 0}
  has_many :drug_orders,  :through   => :orders,  :foreign_key => 'order_id'
  has_many :orders, :dependent => :destroy, :conditions => {:voided => 0}
  belongs_to :type, :class_name => "EncounterType", :foreign_key => :encounter_type, :conditions => {:retired => 0}
  # belongs_to :provider, :class_name => "User", :foreign_key => :provider_id, :conditions => {:voided => 0}
  belongs_to :patient, :conditions => {:voided => 0}

  # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
  named_scope :current, :conditions => 'DATE(encounter.encounter_datetime) = CURRENT_DATE() AND encounter.voided = 0'
  named_scope :current_pregnancy, :conditions => '(SELECT COUNT(*)  FROM obs ob WHERE ob.person_id = encounter.patient_id AND ob.concept_id =
    (SELECT cnm.concept_id FROM concept_name cnm WHERE cnm.name = "DATE OF LAST MENSTRUAL PERIOD" LIMIT 1)
    AND ob.value_datetime >= DATE_ADD(NOW(), INTERVAL -9 MONTH)
    AND encounter.encounter_datetime > ob.value_datetime ) > 0
    AND encounter.voided = 0'
  named_scope :active, :conditions => 'encounter.voided = 0'
  
  def before_save
    # self.provider = User.current if self.provider.blank?
    # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
    self.encounter_datetime = Time.now if self.encounter_datetime.blank?
  end

  def after_save
    # self.add_location_obs
  end

  def after_void(reason = nil)
    self.observations.each do |row| 
      if not row.order_id.blank?
        ActiveRecord::Base.connection.execute <<EOF
UPDATE drug_order SET quantity = NULL WHERE order_id = #{row.order_id};
EOF
      end rescue nil
      row.void(reason) 
    end rescue []

    self.orders.each do |order|
      order.void(reason) 
    end
  end

  def name
    self.type.name rescue "N/A"
  end

  def label
    case self.type.name.upcase
       
    when "UPDATE OUTCOME"
      if self.to_s.upcase.include?("DISCHARGED")

        label = ZebraPrinter::Label.new()
        label.font_size = 3
        label.font_horizontal_multiplier = 1
        label.font_vertical_multiplier = 1
        label.left_margin = 300
        label.draw_multi_text("ADMITTED ON: #{self.admission_date rescue nil}")
        label.draw_multi_text("DISCHARGED ON: #{self.discharge_date rescue nil}", :font_reverse => false)
        label.draw_multi_text("NAME: #{self.patient.name}")
        label.draw_multi_text("DIAGNOSES: #{self.discharge_summary[0] rescue nil}", :font_reverse => false)
        label.draw_multi_text("MANAGEMENT: #{self.discharge_summary[1] rescue nil}", :font_reverse => false)
        label.draw_multi_text("DISCHARGED BY: #{User.find(self.provider_id).name rescue ''}")
        label.print
      end
    end
  end

  def discharge_summary
    [ (self.patient.encounters.current_pregnancy.find(:all, :order => ["encounter_datetime DESC"]).collect{|e|
          e.observations.collect{|o|
            o.answer_string if o.concept.name.name.upcase == "DIAGNOSIS"
          }.compact.delete_if{|x| x.blank?} if e.type.name.eql?("UPDATE OUTCOME")
        }.flatten.delete_if{|y| y.blank?}[0 .. 2] rescue nil),
      
      (self.patient.encounters.current_pregnancy.find(:all, :order => ["encounter_datetime DESC"]).collect{|e|
          e.observations.collect{|o|
            o.answer_string if o.concept.name.name.upcase == "PROCEDURE DONE"
          }.compact.delete_if{|x| x.blank?} if e.type.name.eql?("UPDATE OUTCOME")
        }.flatten.delete_if{|y| y.blank?}[0 .. 2] rescue nil)
    ]
  end

  def admission_date

    Encounter.find(:first, :order => ["encounter_datetime DESC"], :joins => [:observations],
      :conditions => ["encounter.encounter_type = ? AND obs.concept_id = ? AND encounter.patient_id = ?",
        EncounterType.find_by_name("OBSERVATIONS").id, ConceptName.find_by_name("ADMISSION DATE").concept_id, self.patient_id]).observations.collect{|obs|
      return obs.answer_string if (obs.concept.name.name.upcase.strip == "ADMISSION DATE" rescue false) rescue nil
    }
    
  end

  def discharge_date

    Encounter.find(:first, :order => ["encounter_datetime DESC"], :joins => [:observations],
      :conditions => ["encounter.encounter_type = ? AND obs.concept_id = ? AND encounter.patient_id = ?",
        EncounterType.find_by_name("UPDATE OUTCOME").id, ConceptName.find_by_name("DISCHARGED").concept_id, self.patient_id]).encounter_datetime.to_date.strftime("%d/%b/%Y") rescue " - "

  end

  def encounter_type_name=(encounter_type_name)
    self.type = EncounterType.find_by_name(encounter_type_name)
    raise "#{encounter_type_name} not a valid encounter_type" if self.type.nil?
  end

  def to_s
    if name == 'REGISTRATION'
      "Patient was seen at the registration desk at #{encounter_datetime.strftime('%I:%M')}"
    elsif name == 'TREATMENT'
      o = orders.collect{|order| order.drug_order}.join(", ")
      # o = "TREATMENT NOT DONE" if self.patient.treatment_not_done
      o = "No prescriptions have been made" if o.blank?
      o
    elsif name == 'DISPENSING'
      o = orders.collect{|order| order.drug_order}.join(", ")
      # o = "TREATMENT NOT DONE" if self.patient.treatment_not_done
      o = "No TTV vaccine given" if o.blank?
      o
    elsif name == 'VITALS'
      temp = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("TEMPERATURE (C)") && "#{obs.answer_string}".upcase != 'UNKNOWN' }
      weight = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("WEIGHT (KG)") && "#{obs.answer_string}".upcase != '0.0' }
      height = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("HEIGHT (CM)") && "#{obs.answer_string}".upcase != '0.0' }
      systo = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("SYSTOLIC BLOOD PRESSURE") && "#{obs.answer_string}".upcase != '0.0' }
      diasto = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("DIASTOLIC BLOOD PRESSURE") && "#{obs.answer_string}".upcase != '0.0' }
      vitals = [weight_str = weight.first.answer_string + 'KG' rescue 'UNKNOWN WEIGHT',
        height_str = height.first.answer_string + 'CM' rescue 'UNKNOWN HEIGHT', bp_str = "BP: " + 
          (systo.first.answer_string.to_i.to_s rescue "?") + "/" + (diasto.first.answer_string.to_i.to_s rescue "?")]
      temp_str = temp.first.answer_string + '°C' rescue nil
      vitals << temp_str if temp_str
      vitals.join(', ')
    elsif name == 'DIAGNOSIS'
      diagnosis_array = []
      observations.each{|observation|
        next if observation.obs_group_id != nil
        observation_string =  observation.answer_string
        child_ob = observation.child_observation rescue nil
        while child_ob != nil
          observation_string += " #{child_ob.answer_string}"
          child_ob = child_ob.child_observation
        end
        diagnosis_array << observation_string
        diagnosis_array << " : "
      }
      diagnosis_array.compact.to_s.gsub(/ : $/, "")
    elsif name == 'OBSERVATIONS' || name == 'CURRENT PREGNANCY'
      observations.collect{|observation| observation.to_s.titleize.gsub("Breech Delivery", "Breech")}.join(", ")
    elsif name == 'SURGICAL HISTORY'
      observations.collect{|observation| observation.to_s.titleize.gsub("Tuberculosis Test Date Received", "Date")}.join(", ")
    elsif name == "ANC VISIT TYPE"
      observations.collect{|o| "Visit No.: " + o.value_numeric.to_i.to_s}.join(", ")
    else
      observations.collect{|observation| observation.to_s.titleize}.join(", ")
    end
  end

  def self.statistics(encounter_types, encounters = [], opts={})
    
    encounter_types = EncounterType.all(:conditions => ['name IN (?)', encounter_types])
    encounter_types_hash = encounter_types.inject({}) {|result, row| result[row.encounter_type_id] = row.name; result }
    with_scope(:find => opts) do
      rows = self.all(
        :select => 'count(*) as number, encounter_type',
        :group => 'encounter.encounter_type',
        :conditions => ['encounter_type IN (?) AND encounter_id IN (?)', encounter_types.map(&:encounter_type_id),  encounters])
      return rows.inject({}) {|result, row| result[encounter_types_hash[row['encounter_type']]] = row['number']; result }
    end
  end
end


=begin

  def to_s
    if name == 'REGISTRATION'
      "Patient was seen at the registration desk at #{encounter_datetime.strftime('%I:%M')}" 
    elsif name == 'TREATMENT'
      o = orders.collect{|order| order.drug_order}.join(", ")
      # o = "TREATMENT NOT DONE" if self.patient.treatment_not_done
      o = "No prescriptions have been made" if o.blank?
      o
    elsif name == 'VITALS'
      temp = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("TEMPERATURE (C)") && "#{obs.answer_string}".upcase != 'UNKNOWN' }
      weight = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("WEIGHT (KG)") && "#{obs.answer_string}".upcase != '0.0' }
      height = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("HEIGHT (CM)") && "#{obs.answer_string}".upcase != '0.0' }
      systo = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("SYSTOLIC BLOOD PRESSURE") && "#{obs.answer_string}".upcase != '0.0' }
      diasto = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("DIASTOLIC BLOOD PRESSURE") && "#{obs.answer_string}".upcase != '0.0' }
      vitals = [weight_str = weight.first.answer_string + 'KG' rescue 'UNKNOWN WEIGHT',
        height_str = height.first.answer_string + 'CM' rescue 'UNKNOWN HEIGHT', bp_str = "BP: " + 
          (systo.first.answer_string.to_i.to_s rescue "?") + "/" + (diasto.first.answer_string.to_i.to_s rescue "?")]
      temp_str = temp.first.answer_string + '°C' rescue nil
      vitals << temp_str if temp_str                          
      vitals.join(', ')
    elsif name == 'DIAGNOSIS'
      diagnosis_array = []
      observations.each{|observation|
        next if observation.obs_group_id != nil
        observation_string =  observation.answer_string
        child_ob = observation.child_observation
        while child_ob != nil
          observation_string += " #{child_ob.answer_string}"
          child_ob = child_ob.child_observation
        end
        diagnosis_array << observation_string
        diagnosis_array << " : "
      }
      diagnosis_array.compact.to_s.gsub(/ : $/, "")    
    elsif name == 'OBSERVATIONS' || name == 'CURRENT PREGNANCY'
      observations.collect{|observation| observation.to_s.titleize.gsub("Breech Delivery", "Breech")}.join(", ")   
    elsif name == 'SURGICAL HISTORY'
      observations.collect{|observation| observation.to_s.titleize.gsub("Tuberculosis Test Date Received", "Date")}.join(", ")
    elsif name == "ANC VISIT TYPE"
      observations.collect{|o| "Visit No.: " + o.value_numeric.to_i.to_s}.join(", ")
    else  
      observations.collect{|observation| observation.to_s.titleize}.join(", ")
    end  
  end

=end