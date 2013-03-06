
class Baby

  attr_accessor :mother, :person, :user, :current_date, :location_id

  def initialize(user_id, patient_id, location_id, session_date = Date.today)
    self.mother = Patient.find(patient_id)
    self.user = User.find(user_id)
    self.current_date = session_date
    self.location_id = location_id
  end

  def associate_with_mother(destination, first_name, last_name, gender, birthdate = Date.today)
    params = {
      "person[names][given_name]" => "#{first_name}",
      "person[names][family_name]" => "#{last_name}",
      "person[gender]" => "#{gender}",
      "person[birth_year]" => "#{birthdate.to_date.year rescue Date.today.year}",
      "person[birth_month]" => "#{birthdate.to_date.month rescue Date.today.month}",
      "person[birth_day]" => "#{birthdate.to_date.day rescue Date.today.day}",
      "person[patient]" => "",
      "mother_id" => self.mother.id
    }

    url = "#{destination}/create_baby?user_id=#{self.user.id}&location_id=#{self.location_id}"

    result = RestClient.post(url, params)

    result
  end

  def self.baby_wrist_band_barcode_label(baby_id, mother_id)
    baby = Patient.find(baby_id) rescue nil

    mother = Patient.find(mother_id) rescue nil

    "^XA~TA000~JSN^LT0^MNM^MTD^PON^PMN^LH0,0^JMA^PR2,2^MD21^JUS^LRN^CI0^XZ
^XA
^FO80,0^BY4^BCR,200,N,N,N^FD#{mother.national_id_with_dashes}^FS
^FO40,60^ADR,36,20^FDMUM #{mother.national_id}^FS
^FO200,420^ADR,36,20^FD#{(mother.name rescue nil)}^FS
^FO160,420^ADR,36,20^FD#{(mother.address rescue nil)}^FS
^FO120,420^ADR,36,20^FD#{(mother.address1 rescue nil)}^FS
^FO80,420^ADR,36,20^FD#{(mother.address2 rescue nil)}^FS
^FO80,800^BY4^BCR,200,N,N,N^FD#{baby.national_id_with_dashes}^FS
^FO40,850^ADR,36,20^FDBABY #{baby.national_id}^FS
^XZ"
  end

  def self.mother_wrist_band_barcode_label(patient_id, ward = "", provider = "", session_date = Date.today)
    my_mother = Patient.find(patient_id) rescue nil
    
    "^XA~TA000~JSN^LT0^MNM^MTD^PON^PMN^LH0,0^JMA^PR2,2^MD21^JUS^LRN^CI0^XZ
^XA
^FO200,1250^ADR,36,20^FD#{(my_mother.name rescue nil)}^FS
^FO160,1250^ADR,36,20^FD#{(my_mother.address rescue nil)}^FS
^FO120,1250^ADR,36,20^FD#{(my_mother.address1 rescue nil)}^FS
^FO80,1250^ADR,36,20^FD#{(my_mother.address2 rescue nil)}^FS
^FO80,1850^BY4^BCR,200,N,N,N^FD#{(my_mother.national_id rescue nil)}^FS
^FO40,1950^ADR,36,20^FD#{(my_mother.national_id_with_dashes rescue nil)}^FS
^FO200,2400^ADR,36,20^FD#{ward}^FS
^FO160,2400^ADR,36,20^FD#{provider}^FS
^FO120,2400^ADR,36,20^FD#{(session_date || Date.today).strftime("%d/%b/%Y")}^FS
^XZ"
  end

end
