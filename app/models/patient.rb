class Patient < ActiveRecord::Base
  set_table_name "patient"
  set_primary_key "patient_id"
  include Openmrs

  has_one :person, :foreign_key => :person_id, :conditions => {:voided => 0}
  has_many :patient_identifiers, :foreign_key => :patient_id, :dependent => :destroy, :conditions => {:voided => 0}
  has_many :patient_programs, :conditions => {:voided => 0}
  has_many :programs, :through => :patient_programs
  has_many :relationships, :foreign_key => :person_a, :dependent => :destroy, :conditions => {:voided => 0}
  has_many :orders, :conditions => {:voided => 0}

  has_many :program_encounters, :class_name => 'ProgramEncounter',
    :foreign_key => :patient_id, :dependent => :destroy
  
  has_many :encounters, :conditions => {:voided => 0} do 
    def find_by_date(encounter_date)
      encounter_date = Date.today unless encounter_date
      find(:all, :conditions => ["encounter_datetime BETWEEN ? AND ?", 
          encounter_date.to_date.strftime('%Y-%m-%d 00:00:00'),
          encounter_date.to_date.strftime('%Y-%m-%d 23:59:59')
        ]) # Use the SQL DATE function to compare just the date part
    end
  end

  def after_void(reason = nil)
    self.person.void(reason) rescue nil
    self.patient_identifiers.each {|row| row.void(reason) }
    self.patient_programs.each {|row| row.void(reason) }
    self.orders.each {|row| row.void(reason) }
    self.encounters.each {|row| row.void(reason) }
  end

  def name
    "#{self.person.names.first.given_name} #{self.person.names.first.family_name}"
  end
  
  def national_id
    self.patient_identifiers.find_by_identifier_type(PatientIdentifierType.find_by_name("National id").id).identifier rescue nil
  end

  def create_barcode

    barcode = Barby::Code128B.new(self.national_id)

    File.open(RAILS_ROOT + '/public/images/patient_id.png', 'w') do |f|
      f.write barcode.to_png(:height => 100, :xdim => 2)
    end

  end
  
  def national_id_with_dashes
    id = self.national_id
    id[0..4] + "-" + id[5..8] + "-" + id[9..-1] rescue id
  end

  def address
    "#{self.person.addresses.first.city_village}" rescue nil
  end

  def address1
    "#{self.person.addresses.first.address1}" rescue nil
  end

  def address2
    "#{self.person.addresses.first.address2}" rescue nil
  end

  def age(today = Date.today)
    return nil if self.person.birthdate.nil?

    # This code which better accounts for leap years
    patient_age = (today.year - self.person.birthdate.year) + ((today.month -
          self.person.birthdate.month) + ((today.day - self.person.birthdate.day) < 0 ? -1 : 0) < 0 ? -1 : 0)

    # If the birthdate was estimated this year, we round up the age, that way if
    # it is March and the patient says they are 25, they stay 25 (not become 24)
    birth_date=self.person.birthdate
    estimate=self.person.birthdate_estimated==1
    patient_age += (estimate && birth_date.month == 7 && birth_date.day == 1  &&
        today.month < birth_date.month && self.person.date_created.year == today.year) ? 1 : 0
  end

  def gender
    self.person.gender rescue nil
  end

  def age_in_months(today = Date.today)
    years = (today.year - self.person.birthdate.year)
    months = (today.month - self.person.birthdate.month)
    (years * 12) + months
  end

  def allergic_to_sulphur
    status = self.encounters.collect { |e|
      e.observations.find(:last, :conditions => ["concept_id = ?",
          ConceptName.find_by_name("Allergic to sulphur").concept_id]).answer_string rescue nil
    }.compact.flatten.first

    status = "unknown" if status.blank?
    status
  end

  def dpt1
    status = self.encounters.collect { |e|
      e.observations.find(:last, :conditions => ["concept_id = ?",
          ConceptName.find_by_name("Was DPT-HepB-Hib 1 vaccine given at 6 weeks or later?").concept_id]).answer_string rescue nil
    }.compact.flatten.first

    status = "unknown" if status.blank?
    status
  end

  def dpt2
    status = self.encounters.collect { |e|
      e.observations.find(:last, :conditions => ["concept_id = ?",
          ConceptName.find_by_name("Was DPT-HepB-Hib 2 vaccine given at 1 month after first dose?").concept_id]).answer_string rescue nil
    }.compact.flatten.first

    status = "unknown" if status.blank?
    status
  end

  def dpt3
    status = self.encounters.collect { |e|
      e.observations.find(:last, :conditions => ["concept_id = ?",
          ConceptName.find_by_name("Was DPT-HepB-Hib 3 vaccine given at 1 month after second dose?").concept_id]).answer_string rescue nil
    }.compact.flatten.first

    status = "unknown" if status.blank?
    status
  end

  def pcv1
    status = self.encounters.collect { |e|
      e.observations.find(:last, :conditions => ["concept_id = ?",
          ConceptName.find_by_name("PCV 1 vaccine given at 6 weeks or later?").concept_id]).answer_string rescue nil
    }.compact.flatten.first

    status = "unknown" if status.blank?
    status
  end

  def pcv2
    status = self.encounters.collect { |e|
      e.observations.find(:last, :conditions => ["concept_id = ?",
          ConceptName.find_by_name("PCV 2 vaccine given at 1 month after first dose?").concept_id]).answer_string rescue nil
    }.compact.flatten.first

    status = "unknown" if status.blank?
    status
  end

  def pcv3
    status = self.encounters.collect { |e|
      e.observations.find(:last, :conditions => ["concept_id = ?",
          ConceptName.find_by_name("PCV 3 vaccine given at 1 month after second dose?").concept_id]).answer_string rescue nil
    }.compact.flatten.first

    status = "unknown" if status.blank?
    status
  end

  def polio0
    status = self.encounters.collect { |e|
      e.observations.find(:last, :conditions => ["concept_id = ?",
          ConceptName.find_by_name("First polio vaccine at birth").concept_id]).answer_string rescue nil
    }.compact.flatten.first

    status = "unknown" if status.blank?
    status
  end

  def polio1
    status = self.encounters.collect { |e|
      e.observations.find(:last, :conditions => ["concept_id = ?",
          ConceptName.find_by_name("Second polio vaccine at 1.5 months").concept_id]).answer_string rescue nil
    }.compact.flatten.first

    status = "unknown" if status.blank?
    status
  end

  def polio2
    status = self.encounters.collect { |e|
      e.observations.find(:last, :conditions => ["concept_id = ?",
          ConceptName.find_by_name("Third polio vaccine at 2.5 months").concept_id]).answer_string rescue nil
    }.compact.flatten.first

    status = "unknown" if status.blank?
    status
  end

  def polio3
    status = self.encounters.collect { |e|
      e.observations.find(:last, :conditions => ["concept_id = ?",
          ConceptName.find_by_name("Fourth polio vaccine at 3.5 months").concept_id]).answer_string rescue nil
    }.compact.flatten.first

    status = "unknown" if status.blank?
    status
  end

  def hiv_status
    
    @hiv_concepts = ["MOTHER HIV STATUS", "Previous HIV Test Status From Before Current Facility Visit", "HIV STATUS", "DNA-PCR Testing Result", "Rapid Antibody Testing Result", "Alive On ART"].collect{
      |concept| ConceptName.find_by_name(concept).concept_id rescue nil}.compact rescue []

    status = self.encounters.collect { |e|
      e.observations.find(:last, :conditions => ["concept_id IN (?)",
          @hiv_concepts]).answer_string rescue nil
    }.compact.flatten.last.strip rescue ""

    status = "unknown" if status.blank?
    status = "positive" if ["reactive"].include?(status.downcase)
    status = "negative" if ["non reactive", "non-reactive less than 3 months"].include?(status.downcase)
    status
  end

  def current_babies(session_date = Date.today)
    ProgramEncounterDetail.find(:all, :joins => [:program_encounter],
      :conditions => ["patient_id = ? AND (DATE(date_time) >= ? AND DATE(date_time) <= ?)",
        self.id, (session_date.to_date - 1.year).strftime("%Y-%m-%d"),
        (session_date.to_date).strftime("%Y-%m-%d")]).collect{|e|

      e.encounter.observations.collect{|o|
        o.name.strip if o.concept.concept_names.first.name.downcase == "baby outcome"
      } if e.encounter.type.name.downcase == "baby delivery"

    }.flatten.delete_if{|x| x.blank?}
  end

  def current_procedures(session_date = Date.today)
    ProgramEncounterDetail.find(:all, :joins => [:program_encounter],
      :conditions => ["patient_id = ? AND (DATE(date_time) >= ? AND DATE(date_time) <= ?)",
        self.id, (session_date.to_date - 1.year).strftime("%Y-%m-%d"),
        (session_date.to_date).strftime("%Y-%m-%d")]).collect{|e|

      e.encounter.observations.collect{|o|
        o.name.strip.downcase if o.concept.concept_names.first.name.downcase == "procedure done"
      } if e.encounter.type.name.downcase == "update outcome"

    }.flatten.delete_if{|x| x.blank?}
    
  end

  def wards_hash

    map = ""
    
    Relationship.find_all_by_person_a_and_relationship(self.patient_id,
      
      RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child").relationship_type_id).each{|re|
      
      map += Patient.find(re.person_b).national_id + "--" + Patient.find(re.person_b).current_ward.strip + "|" rescue nil
    
    }
    return map
  end

  def current_ward

    status = self.encounters.find(:all, :order => ["date_created DESC"]).collect{|e|
      e.observations.find(:first, :conditions => ["concept_id = ?",
          ConceptName.find_by_name("Ward").concept_id]).answer_string rescue nil
    }.compact.flatten.first

    status = "unknown" if status.blank?
    status
    
  end

  def babies_national_ids
    
    Relationship.find_all_by_person_a_and_relationship(self.patient_id,

      RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child").relationship_type_id).collect{|re|

      Patient.find(re.person_b).national_id rescue nil

    }.delete_if{|id| id.blank?}.compact.join("|")
    
  end

  def recent_babies(session_date = Date.today)
    Relationship.find(:all, :conditions => ["voided = 0 AND date_created > ? AND person_a = ? AND relationship = ?",
        (session_date - 1.months), self.patient_id, RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child").id]).length
  end

  def recent_delivery_count(session_date = Date.today)
    ob = Observation.find(:first, :order => ["date_created DESC"], :conditions => ["person_id = ? AND voided = 0 AND concept_id = ? AND obs_datetime > ?",
        self.patient_id, ConceptName.find_by_name("NUMBER OF BABIES").concept_id, (session_date - 1.month)]).answer_string.strip.to_i
    ob 
  end

  def fundus
    self.encounters.collect{|e|
      e.observations.collect{|o|
        o.answer_string.to_i if o.concept.concept_names.map(& :name).include?("Fundus")
      }.compact
    }.uniq.delete_if{|x| x == []}.flatten.max
  end

  def fundus_by_lmp(today = Date.today)
    self.encounters.collect{|e|
      e.observations.collect{|o|
        (((today.to_date - o.answer_string.to_date).to_i/7) rescue nil) if o.concept.concept_names.map(& :name).include?("Date of last menstrual period")
      }.compact
    }.uniq.delete_if{|x| x == []}.flatten.max
  end

  def lmp(today = Date.today)
    self.encounters.collect{|e|
      e.observations.collect{|o|
        (o.answer_string.to_date rescue nil) if o.concept.concept_names.map(& :name).include?("Date of last menstrual period") && o.answer_string.to_date <= today.to_date
      }.compact
    }.uniq.delete_if{|x| x == []}.flatten.max
  end

  def national_id_label
    return unless self.national_id
    sex =  self.person.gender.match(/F/i) ? "(F)" : "(M)"
    address = self.address.strip[0..24].humanize.delete("'") rescue ""
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 2
    label.font_vertical_multiplier = 2
    label.left_margin = 50
    label.draw_barcode(50,180,0,1,5,15,120,false,"#{self.national_id}")
    label.draw_multi_text("#{self.name.titleize.delete("'")}") #'
    label.draw_multi_text("#{self.national_id_with_dashes} #{self.person.birthdate_formatted}#{sex}")
    label.draw_multi_text("#{address}")
    label.print(1)
  end 

  def baby_details(type)

    values = {}
    self.encounters.collect{|enc| enc if enc.name.upcase == "BABY DELIVERY"}.each do |enc|

      user = User.find(enc.creator).name rescue nil
      values["TIME"]  = enc.encounter_datetime.strftime("%d/%b/%Y")
      values["USER"] = (user.split(" ")[0].strip[0 .. 0] + ". " + user.split(" ")[1]) rescue "?"
      date = ""
      time = ""

      enc.observations.each do |obs|
        name = ConceptName.find_by_concept_id(obs.concept.concept_id).name.upcase rescue ""
        if name.match(/Gender/i)
          values["GENDER"] = obs.answer_string
        elsif name.match(/Date of/i)
          date = obs.answer_string
        elsif name.match(/Time of/i)
          time = obs.answer_string
        elsif name.match(/length/i)
          values["#{name.upcase.strip}"] = ((obs.answer_string.blank? || obs.answer_string.to_i == 0) rescue true) ? "Unknown" : obs.answer_string
        else
          values["#{name.upcase.strip}"] = (name.match(/Minute/i) && !name.match(/\?/)) ? ((obs.value_numeric.to_i.blank? rescue true) ? "?" : obs.answer_string.to_i) : obs.answer_string
        end

      end

      values["TIME"] = date + "   " + time

    end

    if (values["PLACE OF DELIVERY"].downcase.strip == "this facility" rescue false)
      values["PLACE OF DELIVERY"] = get_global_property_value("facility.name")
    end

    label = ZebraPrinter::StandardLabel.new

    case type

    when "apgar"
      label.draw_text("FIRST MINUTE APGAR",28,29,0,1,1,2,false)
      label.draw_text("FIFTH MINUTE APGAR",400,29,0,1,1,2,false)
      label.draw_line(28,60,162,1,0)
      label.draw_line(400,60,162,1,0)

      label.draw_text("Entered By:",40,283,0,1,1,1,false)
      label.draw_text(values["USER"],190,283,0,1,1,1,false)

      label.draw_text("Date Entered:",470,283,0,1,1,1,false)
      label.draw_text(values["TIME"],620,283,0,1,1,1,false)

      label.draw_text("Appearance",28,80,0,2,1,1,false)
      label.draw_text("Pulse",28,110,0,2,1,1,false)
      label.draw_text("Grimace",28,140,0,2,1,1,false)
      label.draw_text("Activity",28,170,0,2,1,1,false)
      label.draw_text("Respiration",28,200,0,2,1,1,false)
      label.draw_text("APGAR SCORE", 28,230,0,1,1,2,false)

      label.draw_text("Appearance",400,80,0,2,1,1,false)
      label.draw_text("Pulse",400,110,0,2,1,1,false)
      label.draw_text("Grimace",400,140,0,2,1,1,false)
      label.draw_text("Activity",400,170,0,2,1,1,false)
      label.draw_text("Respiration",400,200,0,2,1,1,false)
      label.draw_text("APGAR SCORE", 400,230,0,1,1,2,false)

      label.draw_line(250,70,130,1,0)
      label.draw_line(250,70,1,183,0)
      label.draw_line(380,70,1,183,0)
      label.draw_line(250,100,130,1,0)
      label.draw_line(250,130,130,1,0)
      label.draw_line(250,160,130,1,0)
      label.draw_line(250,190,130,1,0)
      label.draw_line(250,220,130,1,0)
      label.draw_line(250,250,130,1,0)
      label.draw_line(659,70,130,1,0)
      label.draw_line(659,70,1,183,0)
      label.draw_line(790,70,1,183,0)
      label.draw_line(659,100,130,1,0)
      label.draw_line(659,130,130,1,0)
      label.draw_line(659,160,130,1,0)
      label.draw_line(659,190,130,1,0)
      label.draw_line(659,220,130,1,0)
      label.draw_line(659,250,130,1,0)

      label.draw_text("#{values['APPEARANCE MINUTE ONE']}/2",280,80,0,2,1,1,false)
      label.draw_text("#{values['PULSE MINUTE ONE']}/2",280,110,0,2,1,1,false)
      label.draw_text("#{values['GRIMANCE MINUTE ONE']}/2",280,140,0,2,1,1,false)
      label.draw_text("#{values['ACTIVITY MINUTE ONE']}/2",280,170,0,2,1,1,false)
      label.draw_text("#{values['RESPIRATION MINUTE ONE']}/2",280,200,0,2,1,1,false)
      label.draw_text("#{values['APGAR MINUTE ONE']}/10",280,230,0,2,1,1,false)

      label.draw_text("#{values['APPEARANCE MINUTE FIVE']}/2",690,80,0,2,1,1,false)
      label.draw_text("#{values['PULSE MINUTE FIVE']}/2",690,110,0,2,1,1,false)
      label.draw_text("#{values['GRIMANCE MINUTE FIVE']}/2",690,140,0,2,1,1,false)
      label.draw_text("#{values['ACTIVITY MINUTE FIVE']}/2",690,170,0,2,1,1,false)
      label.draw_text("#{values['RESPIRATION MINUTE FIVE']}/2",690,200,0,2,1,1,false)
      label.draw_text("#{values['APGAR MINUTE FIVE']}/10",690,230,0,2,1,1,false)

    when "summary"

      label.draw_text("DELIVERY SUMMARY",300,29,0,1,1,2,false)
      label.draw_line(300,60,153,1,0)

      label.draw_text("Entered By:",40,290,0,1,1,1,false)
      label.draw_text(values["USER"],190,290,0,1,1,1,false)

      label.draw_text("Date Entered:",470,290,0,1,1,1,false)
      label.draw_text(values["TIME"],620,290,0,1,1,1,false)

      label.draw_text(" Birth Weight    : ",28,80,0,2,1,1,false)
      label.draw_text(" Birth Length    : ",28,110,0,2,1,1,false)
      label.draw_text(" Baby outcome    : ",28,140,0,2,1,1,false)
      label.draw_text(" Sex             : ",28,170,0,2,1,1,false)
      label.draw_text(" Presentation    : ",28,200,0,2,1,1,false)
      label.draw_text(" Delivery Time   : ", 28,230,0,2,1,1,false)

      label.draw_text("#{values['BIRTH WEIGHT']}",248,80,0,2,1,1,false)
      label.draw_text("#{values['BIRTH LENGTH']}",248,110,0,2,1,1,false)
      label.draw_text("#{values['BABY OUTCOME']}",248,140,0,2,1,1,false)
      label.draw_text("#{values['GENDER']}",248,170,0,2,1,1,false)
      label.draw_text("#{values['PRESENTATION']}",248,200,0,2,1,1,false)
      label.draw_text("#{values['TIME']}", 248,230,0,2,1,1,false)

    when "complications"
      label.draw_text("DELIVERY SUMMARY CONT..",300,29,0,1,1,2,false)
      label.draw_line(300,60,153,1,0)

      label.draw_text("Entered By:",40,290,0,1,1,1,false)
      label.draw_text(values["USER"],190,290,0,1,1,1,false)

      label.draw_text("Date Entered:",470,290,0,1,1,1,false)
      label.draw_text(values["TIME"],620,290,0,1,1,1,false)

      label.draw_text(" Place Of Delivery    : ",28,80,0,2,1,1,false)
      label.draw_text(" Tet.Ointment Given?  : ",28,110,0,2,1,1,false)
      label.draw_text(" Complications        : ",28,140,0,2,1,1,false)
      label.draw_text(" Breast Fed In 60 min?: ",28,170,0,2,1,1,false)
      label.draw_text(" On NVP?              : ",28,200,0,2,1,1,false)
      label.draw_text(" Comments             : ", 28,230,0,2,1,1,false)

      label.draw_text("#{values['PLACE OF DELIVERY']}",248,80,0,2,1,1,false)
      label.draw_text("#{values['TETRACYCLINE EYE OINTMENT GIVEN?']}",248,110,0,2,1,1,false)
      label.draw_text("#{values['NEWBORN BABY COMPLICATIONS']}",248,140,0,2,1,1,false)
      label.draw_text("#{values['BREAST FEEDING INITIATED WITHIN 60 MINUTES?']}",248,170,0,2,1,1,false)
      label.draw_text("#{values['BABY ON NVP?']}",248,200,0,2,1,1,false)
      label.draw_text("#{values['CLINICIAN NOTES']}", 248,230,0,2,1,1,false)
      
    end

    label.print(1)

  end

  def get_global_property_value(global_property)
		property_value = Settings[global_property]
		if property_value.nil?
			property_value = GlobalProperty.find(:first, :conditions => {:property => "#{global_property}"}
      ).property_value rescue nil
		end
		return property_value
	end

  def next_of_kin
    nok = {}

    self.encounters.last(:conditions => ["encounter_type = ?",
        EncounterType.find_by_name("SOCIAL HISTORY").id]).observations.each{|o|
      nok[o.concept.name.name.upcase] = o.answer_string
    }

    nok

  end


end
