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
  has_one :mother, :class_name => "Relationship", :foreign_key => :person_b, :dependent => :destroy,
    :conditions => {:voided => 0, :relationship => RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child").id}

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

  def create_barcode(fname = "patient_id")

    barcode = Barby::Code128B.new(self.national_id)

    File.open(RAILS_ROOT + "/public/images/#{fname}.png", "w") do |f|
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
    status = "positive" if ["reactive", "hiv infected"].include?(status.downcase)
    status = "negative" if ["non reactive", "non-reactive", "-", "non-reactive less than 3 months"].include?(status.downcase)
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

  def delivery_outcome
    self.encounters.collect{|enc| enc.observations.collect{|ob| 
        ob.answer_string.strip if (ob.concept.name.name.match(/BABY OUTCOME/i) rescue false)
      } if (enc.name.match(/baby delivery/i) rescue false)}.flatten.compact.first rescue ""
  end

  def discharge_outcome
    self.encounters.collect{|enc| enc.observations.collect{|ob|
        ob.answer_string.strip if (ob.concept.name.name.match(/STATUS OF BABY/i) rescue false)
      } if (enc.name.match(/UPDATE OUTCOME/i) rescue false)}.flatten.compact.first rescue ""
  end

  def recent_babies(session_date = Date.today)
    Relationship.find(:all, :conditions => ["voided = 0 AND date_created > ? AND person_a = ? AND relationship = ?",
        (session_date - 1.months), self.patient_id, RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child").id]).length
  end

  def recent_baby_relations(session_date = Date.today)
    Relationship.find(:all, :conditions => ["voided = 0 AND date_created > ? AND person_a = ? AND relationship = ?",
        (session_date - 1.months), self.patient_id, RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child").id])
  end

  def recent_delivery_count(session_date = Date.today)
    ob = Observation.find(:first, :order => ["date_created DESC"], :conditions => ["person_id = ? AND voided = 0 AND concept_id = ? AND obs_datetime > ?",
        self.patient_id, ConceptName.find_by_name("NUMBER OF BABIES").concept_id, (session_date - 2.month)]).answer_string.strip.to_i rescue -1
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

  def release_serial_number
    serial_number = SerialNumber.find_by_national_id(self.national_id)
    serial_num = SerialNumber.find(:first, :conditions => ["national_id IS NULL"])
    serial_number.update_attributes(:national_id =>  serial_num.national_id,
      :date_assigned => serial_num.date_assigned,
      :voided_by => serial_num.voided_by
    )
  end rescue nil

  def recent_location(session_date = Date.today)
    location_id = ProgramEncounterDetail.find(:first, :order => ["encounter_datetime DESC"], :joins => [:encounter],
      :conditions => ["program_id = ? AND DATE(encounter_datetime) > ? AND patient_id = ? AND encounter.location_id != ?",
        Program.find_by_name("MATERNITY PROGRAM").id, (session_date - 7.day), self.patient_id,
        Location.find("REGISTRATION").location_id]).encounter.location_id rescue nil
    Location.find(location_id) rescue nil
  end

  def is_discharged_mother?(session_date = Date.today)
    
    ProgramEncounterDetail.find(:all, :limit => 20, :order => ["encounter_datetime DESC"], :joins => [:encounter],
      :conditions => ["program_id = ? AND DATE(encounter_datetime) > ? AND encounter_type = ? AND patient_id = ? AND encounter.voided = 0",
        Program.find_by_name("MATERNITY PROGRAM").id, (session_date - 7.day),
        EncounterType.find_by_name("UPDATE OUTCOME").id, self.patient_id]).collect{|enc|
      enc.encounter.observations.collect{|obs|
        obs.answer_string.upcase if obs.concept.name.name.upcase.strip == "DISCHARGED"
      } rescue []
    }.flatten.delete_if{|val| val.blank?}.present? rescue false
   
  end

  def next_undischarged_baby(session_date = Date.today)
    #check current mother discharge
    @type = RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child").id rescue nil
    @baby = nil
    Relationship.find(:all, :order => ["date_created"], :conditions => ["voided = 0 AND person_a = ? AND relationship = ? and DATE(date_created) > ?",
        self.patient_id, @type,  (session_date - 7.day)]).each{|baby|

      next if @baby.present?
       
      @baby = baby if !Patient.find(baby.person_b).is_discharged?
    }

    @baby
  end

  def is_discharged?
    concept_id = ConceptName.find_by_name("STATUS OF BABY").concept_id
    check = Observation.find_by_concept_id_and_person_id(concept_id, self.patient_id).present? rescue false
    check
  end

  def gravida
    concept_id = ConceptName.find_by_name("Gravida").concept_id
    Observation.find_all_by_concept_id_and_person_id(concept_id, self.patient_id).collect{|ob| ob.answer_string.to_i rescue nil}.compact.max.to_i rescue 0;
  end

  def known_babies
    
  end

  def recent_admission_date(session_date = Date.today)
    Observation.find(:last, :select => ["value_datetime"],
      :order => ["obs_datetime"],
      :conditions => ["person_id = ? AND concept_id = ? AND DATE(value_datetime) > ?", self.patient_id,
        ConceptName.find_by_name("ADMISSION DATE").concept_id,
        (session_date.to_date - 30.days)]).value_datetime.strftime("%d/%b/%Y") rescue nil
  end

  def recent_delivery_outcome(session_date = Date.today)
    self.encounters.find(:last, :order => ["encounter_datetime ASC"], :joins => [:observations] ,
      :conditions => ["encounter.voided = 0 AND encounter_type = ? AND obs.concept_id = ? AND obs.value_coded = ? AND DATE(encounter_datetime) >= ?",
        EncounterType.find_by_name("UPDATE OUTCOME").id, ConceptName.find_by_name("OUTCOME").concept_id,
        ConceptName.find_by_name("DELIVERED").concept_id, (session_date.to_date - 2.days)]).encounter_id rescue nil
  end

  def recent_admission(session_date = Date.today)
    self.encounters.find(:last, :order => ["encounter_datetime ASC"], :joins => [:observations] ,
      :conditions => ["encounter.voided = 0 AND encounter_type = ? AND obs.concept_id = ? AND DATE(encounter_datetime) >= ?",
        EncounterType.find_by_name("ADMIT PATIENT").id, ConceptName.find_by_name("ADMISSION DATE").concept_id,
        (session_date.to_date - 3.months)]) rescue nil
  end

  def maternal_history(today = Date.today)
    result = {}
    enc = Encounter.find(:last, :order => ["encounter_datetime ASC"], :joins => [:observations],
      :conditions => ["patient_id = ? AND encounter_type = ? AND concept_id = ? AND obs.voided = 0 AND DATE(encounter_datetime) > ?",
        self.id, EncounterType.find_by_name("UPDATE OUTCOME").id,  ConceptName.find_by_name("OUTCOME").concept_id,
        (today - 8.months).to_date]).observations.each{|ob|
    
      result[ob.concept.name.name.upcase] = ob.answer_string
      
    }

    result["HIV STATUS"] = self.hiv_status

    vxam = {}
    vxam_enc =  Observation.find(:last,
      :conditions => ["person_id = ? AND concept_id = ? AND voided = 0 AND DATE(obs_datetime) > ?",
        self.id,  ConceptName.find_by_name("MEMBRANES").concept_id, (today - 8.months).to_date]).encounter rescue []
    
    vxam_enc.observations.each{|ob|
      
      vxam[ob.concept.name.name.upcase] = ob.answer_string
      
    } unless vxam_enc.blank?

    if ((vxam["RUPTURE TIME"].present? && vxam["RUPTURE DATE"].present?) rescue false)
      vxam["RUPTURE DELAY"] = "#{vxam['RUPTURE DATE'].to_date.to_s} &nbsp&nbsp  #{vxam['RUPTURE TIME']}"
      
      dod =  self.valid_delivery_time(today)
      doa =  self.valid_admission_time(dod)
      
      diff = ((doa.to_time - vxam["RUPTURE DELAY"].to_time)/3600) rescue nil
      
      result["ROM"] = "At &nbsp&nbsp #{vxam["RUPTURE DELAY"]}  &nbsp&nbsp (#{diff.round} hrs from admission) " rescue "Unknown"
    end
      
    result["VXAM"] = vxam    
    result

  end

  def valid_delivery_time(session_date = Date.today)
    date = Observation.find(:last, :order => ["obs_datetime ASC"],
      :conditions => ["DATE(obs_datetime) >= ? AND voided = 0 AND concept_id = ?",
        (session_date.to_date - 9.months), ConceptName.find_by_name("DATE OF DELIVERY").concept_id]).answer_string.strip rescue nil
    return nil if date.blank?
    
    time = Observation.find(:last, :order => ["obs_datetime ASC"],
      :conditions => ["DATE(obs_datetime) >= ? AND voided = 0 AND concept_id = ?",
        (session_date.to_date - 9.months), ConceptName.find_by_name("TIME OF DELIVERY").concept_id]).answer_string.strip rescue nil
    return nil if time.blank?

    "#{date.to_date.to_s} #{time}"
    
  end

  def valid_admission_time(session_date = Date.today)
    date = Observation.find(:last, :order => ["obs_datetime ASC"],
      :conditions => ["DATE(obs_datetime) >= ?  AND DATE(obs_datetime) <= ? AND  voided = 0 AND concept_id = ?",
        (session_date.to_date - 9.months), session_date.to_date, ConceptName.find_by_name("ADMISSION DATE").concept_id]).answer_string.strip rescue nil
    return nil if date.blank?

    time = Observation.find(:last, :order => ["obs_datetime ASC"],
      :conditions => ["DATE(obs_datetime) >= ? AND DATE(obs_datetime) <= ? AND voided = 0 AND concept_id = ?",
        (session_date.to_date - 9.months), session_date.to_date, ConceptName.find_by_name("ADMISSION TIME").concept_id]).answer_string.strip rescue nil
    return nil if time.blank?

    "#{date.to_date.to_s} #{time}"

  end

  def birth_history(today = Date.today)
    
    result = {}

    Encounter.find(:last, :order => ["encounter_datetime ASC"], :joins => [:observations],
      :conditions => ["patient_id = ? AND encounter_type = ? AND concept_id = ? AND obs.voided = 0 AND DATE(encounter_datetime) > ?",
        self.id, EncounterType.find_by_name("BABY DELIVERY").id,  ConceptName.find_by_name("Date of delivery").concept_id,
        (today - 8.months).to_date]).observations.each{|ob|
      
      result[ob.concept.name.name.upcase] = ob.answer_string
      
    }    

    result
  end

  def maternal_complications(today = Date.today)

    result = {}
    legal_concepts = ["Diagnosis", "Complications"].collect{|name| ConceptName.find_by_name(name).concept_id}
    
    Observation.find(:all, :conditions => ["person_id = ? AND voided = 0 AND DATE(obs_datetime) >= ? AND concept_id IN (?)",
        self.id, (today - 8.months).to_date, legal_concepts
      ]).each{|ob|

      (result[ob.concept.name.name.upcase] += ", " + ob.answer_string) rescue (result[ob.concept.name.name.upcase] = ob.answer_string)

    }
    
    result["DRUGS"] = self.drugs(today)
   
    result
    
  end

  def birth_complications(today = Date.today)


    result = {}
    legal_concepts = ["Diagnosis", "Newborn baby complications", "Adverse event action taken", "Baby on NVP?"].collect{|name| ConceptName.find_by_name(name).concept_id}

    Observation.find(:all, :conditions => ["person_id = ? AND voided = 0 AND DATE(obs_datetime) >= ? AND concept_id IN (?)",
        self.id, (today - 8.months).to_date, legal_concepts
      ]).each{|ob|

      (result[ob.concept.name.name.upcase] += ", " + ob.answer_string) rescue (result[ob.concept.name.name.upcase] = ob.answer_string)

    }

    result["DRUGS"] = self.drugs(today) + ((result["BABY ON NVP?"].match(/Yes/i) rescue false) ? " , NVP" : "")

  
    result 
    
  end

  def admission_details(today = Date.today)
    result = {}
    self.encounters.find(:all, :order => ["encounter_datetime ASC"],
      :conditions => ["encounter_type = ? AND voided = 0 AND DATE(encounter_datetime) >= ?",
        EncounterType.find_by_name("ADMIT PATIENT").id, (today - 8.months).to_date]).collect{|enc|
      enc.observations.each{|ob|
        name = ob.concept.name.name.upcase
        name = "BLOOD SUGAR" if ob.concept.concept_id == ConceptName.find_by_name("Blood Sugar").concept_id
        result[name] = ob.answer_string

      }}
    result
  end

  def referral_details(today = Date.today)

    result = {}
    
    enc =  self.encounters.find(:last, :order => ["encounter_datetime ASC"],
      :conditions => ["encounter_type = ? AND voided = 0 AND DATE(encounter_datetime) >= ?",
        EncounterType.find_by_name("REFERRAL").id, (today - 8.months).to_date])
    
    return result if enc.blank?

    enc.observations.each{|ob|
      name = ob.concept.name.name.upcase
      result[name] = ob.answer_string
    }
    
    result["PROVIDER_NAME"] = User.find(enc.provider_id).name rescue nil

    result
    
  end

  def drugs(today = Date.today)
    
    self.encounters.find(:all,
      :conditions => ["encounter_type = ? AND voided = 0 AND DATE(encounter_datetime) >= ?",
        EncounterType.find_by_name("TREATMENT").id, (today - 8.months).to_date]).collect{|enc|
      enc.drug_orders.collect{|drg| drg.drug.name}}.flatten.uniq.compact.join(" , ")
  end

  def serial_number

    ident = self.patient_identifiers.find_by_identifier_type(PatientIdentifierType.find_by_name("SERIAL NUMBER").id)
    return "" if ident.blank?
    ident.identifier

  end

  def birth_weight
    
    ob = Observation.find_by_concept_id_and_person_id_and_voided(ConceptName.find_by_name("BIRTH WEIGHT").concept_id, self.id, 0)
    return -1 if (ob.answer_string.to_i == 0 rescue true)
    
    ob.answer_string.to_i
    
  end

  def kmc_started?
    self.encounters.find(:all,
      :conditions => ["encounter_type = ? AND voided = 0",
        EncounterType.find_by_name("KANGAROO REVIEW VISIT").id]).length > 0 ? "Yes" : "No"
  end
  
end
