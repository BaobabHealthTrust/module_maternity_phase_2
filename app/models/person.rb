class Person < ActiveRecord::Base
  set_table_name "person"
  set_primary_key "person_id"
  include Openmrs

  cattr_accessor :session_datetime
  cattr_accessor :migrated_datetime
  cattr_accessor :migrated_creator
  cattr_accessor :migrated_location

  has_one :patient, :foreign_key => :patient_id, :dependent => :destroy, :conditions => {:voided => 0}
  has_many :names, :class_name => 'PersonName', :foreign_key => :person_id, :dependent => :destroy, :order => 'person_name.preferred DESC', :conditions => {:voided => 0}
  has_many :addresses, :class_name => 'PersonAddress', :foreign_key => :person_id, :dependent => :destroy, :order => 'person_address.preferred DESC', :conditions => {:voided => 0}
  has_many :relationships, :class_name => 'Relationship', :foreign_key => :person_a, :conditions => {:voided => 0}
  has_many :person_attributes, :class_name => 'PersonAttribute', :foreign_key => :person_id, :conditions => {:voided => 0}
  has_many :observations, :class_name => 'Observation', :foreign_key => :person_id, :dependent => :destroy, :conditions => {:voided => 0} do
    def find_by_concept_name(name)
      concept_name = ConceptName.find_by_name(name)
      find(:all, :conditions => ['concept_id = ?', concept_name.concept_id]) rescue []
    end
  end

  def after_void(reason = nil)
    self.patient.void(reason) rescue nil
    self.names.each{|row| row.void(reason) }
    self.addresses.each{|row| row.void(reason) }
    self.relationships.each{|row| row.void(reason) }
    self.person_attributes.each{|row| row.void(reason) }
    # We are going to rely on patient => encounter => obs to void those
  end

  def name
    "#{self.names.first.given_name} #{self.names.first.family_name}"
  end

  def birthdate_formatted
    if self.birthdate_estimated==1
      if self.birthdate.day == 1 and self.birthdate.month == 7
        self.birthdate.strftime("??/???/%Y")
      elsif self.birthdate.day == 15
        self.birthdate.strftime("??/%b/%Y")
      end
    else
      self.birthdate.strftime("%d/%b/%Y")
    end
  end


	def mother
		Relationship.find(:last,
			:order => ["date_created"],
			:conditions => ["person_b = ? AND relationship = ?",
        self.person_id, RelationshipType.find(:last, :conditions => ["a_is_to_b = ? AND b_is_to_a = ?", "Parent", "Child"]).id])
	end


end
