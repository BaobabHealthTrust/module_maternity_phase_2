# app/models/reports.rb

class Report

  def initialize(start_date, end_date)

    @startdate = "#{start_date} 00:00:00".to_date
    @enddate = "#{end_date} 23:59:59".to_date

    @program_encounter_details =  ProgramEncounterDetail.find(:all, :joins => [:program_encounter],
      :conditions => ["(DATE(date_time) >= ? AND DATE(date_time) <= ?) AND program_encounter.program_id = ?",
        @startdate.strftime("%Y-%m-%d"), @enddate.strftime("%Y-%m-%d"), Program.find_by_name("MATERNITY PROGRAM").program_id]) rescue []

    @report_patients = @program_encounter_details.collect{|ped|
      ped.program_encounter.patient_id;
    }.uniq rescue []

    @program_encounters = @program_encounter_details.collect{|ped|
      ped.encounter_id
    }.uniq rescue []


    @hiv_tests = Encounter.find_by_sql(["SELECT enc.patient_id AS patient, enc.encounter_id AS encounter, enc.encounter_datetime AS capturedate, MAX(ob.value_datetime) AS testdate
        FROM encounter enc
        INNER JOIN obs ob ON ob.encounter_id = enc.encounter_id AND ob.voided = 0 AND enc.voided = 0
          AND ob.concept_id IN (?)
          AND enc.encounter_id IN (?)
         GROUP BY patient",
        ["HIV TEST DATE", "Confirmatory HIV test date", "Mother HIV test date"].collect{|coc| ConceptName.find_by_name(coc).concept_id rescue "------"},
        @program_encounters])
    
  end

  def pull(encounter, concept_name, obs_answer)
    data = Encounter.find(:all, :joins => [:observations], :select => ["patient_id"],
      :conditions => ["encounter_type = ? AND concept_id = ? AND encounter.encounter_id IN (?) AND (value_text = ? OR value_coded = ?) AND encounter.voided = 0",
        EncounterType.find_by_name(encounter).id,
        ConceptName.find_by_name(concept_name).concept_id,
        @program_encounters, obs_answer,
        (ConceptName.find_by_name(obs_answer).concept_id rescue nil)]).collect{|e| e.patient_id}.uniq rescue []
    data
  end

  def twins_pull(min = 1, max = 1)

    @mother_type = RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Parent", "Child").relationship_type_id

    @twin_siblings = "SELECT COUNT(*) FROM obs observ WHERE observ.person_id IN (SELECT rl.person_b FROM relationship rl WHERE rl.person_a = p.patient_id AND rl.relationship = #{@mother_type}) AND
    concept_id IN (SELECT cn.concept_id FROM concept_name cn WHERE cn.name = 'Date of delivery') AND observ.voided = 0 AND
    observ.obs_datetime >= DATE_ADD(ob.obs_datetime, INTERVAL -30 DAY) AND
    observ.obs_datetime <= DATE_ADD(ob.obs_datetime, INTERVAL 30 DAY)"

    @delivery_encounters = "encounter e ON e.encounter_id IN (?) AND e.voided = 0
            AND e.encounter_type = (SELECT encounter_type_id FROM encounter_type WHERE name = 'BABY DELIVERY')
            JOIN obs ob ON e.encounter_id = ob.encounter_id AND
                concept_id IN (SELECT c.concept_id FROM concept_name c WHERE c.name = 'Date of delivery')"

    p = Patient.find_by_sql(["SELECT r.person_a AS mother, (#{@twin_siblings}) AS twin_siblings FROM patient p
        INNER JOIN relationship r ON p.patient_id = r.person_a AND r.relationship = #{@mother_type} AND r.voided = 0
        INNER JOIN #{@delivery_encounters}
        GROUP BY mother HAVING (twin_siblings >= ? AND twin_siblings <= ?)", @program_encounters, min, max])

    p.collect{|t| t.attributes["mother"]}

  end

  def delivery_staff
    result = {}

    md =  pull("UPDATE OUTCOME", "STAFF CONDUCTING DELIVERY", "Medical Doctor /Clinical Officer /Medical Assistant" )
    pa =  pull("UPDATE OUTCOME", "STAFF CONDUCTING DELIVERY", "Patient Attendant / Ward Attendant /Health Surveillance Assistant")
    other = pull("UPDATE OUTCOME", "STAFF CONDUCTING DELIVERY", "Other")

    result["MD"] = md
    result["PA"] = pa
    result["OTHER"] = other

    result
  end

  def hiv_status_map
    result = {}

    p_negative = pull("ADMIT PATIENT", "Previous HIV Test Status From Before Current Facility Visit", "Non-reactive less than 3 months")
    p_positive = pull("ADMIT PATIENT", "Previous HIV Test Status From Before Current Facility Visit", "Reactive")
    n_negative = pull("ADMIT PATIENT", "HIV STATUS", "Non-reactive")
    n_positive =  pull("ADMIT PATIENT", "HIV STATUS", "Reactive")
    not_done =  pull("ADMIT PATIENT", "HIV STATUS", "Not Done")

    result["P_NEGATIVE"] = (p_negative + self.p_negative).uniq
    result["P_POSITIVE"] = (p_positive + self.p_positive).uniq
    result["N_NEGATIVE"] = (n_negative + self.n_negative).uniq
    result["N_POSITIVE"] = (n_positive + self.n_positive).uniq
    result["N_DONE"] = (not_done + (@report_patients - (result["P_NEGATIVE"] + result["P_POSITIVE"] + result["N_NEGATIVE"] + result["N_POSITIVE"]))).uniq
    result["POSITIVE"] = (result["P_POSITIVE"] + result["N_POSITIVE"]).uniq
    result["NEGATIVE"] = ((result["N_NEGATIVE"] + result["P_NEGATIVE"] + not_done) - (p_positive + n_positive)).uniq
    result["TOTAL"] = ( result["POSITIVE"] + result["NEGATIVE"] + result["N_DONE"]).uniq
    result
  end

  def p_negative
   
    patients = @hiv_tests.collect{|test|
      patient = Encounter.find(test.encounter).patient
      status = patient.hiv_status
      patient.patient_id  if (((test.testdate.to_date < (test.capturedate.to_date - 7.days)) && status.strip.downcase == "negative") rescue false)
    }.delete_if{|val| val.blank?}

    patients
  end

  def p_positive

    patients = @hiv_tests.collect{|test|
      patient = Encounter.find(test.encounter).patient
      status = patient.hiv_status
      patient.patient_id if (((test.testdate.to_date < (test.capturedate.to_date - 7.days)) && status.strip.downcase == "positive") rescue false)
    }.delete_if{|val| val.blank?}
    patients
  end

  def n_positive

    patients = @hiv_tests.collect{|test|
      patient = Encounter.find(test.encounter).patient
      status = patient.hiv_status
      patient.patient_id if (((test.testdate.to_date >= (test.capturedate.to_date - 7.days)) && status.strip.downcase == "positive") rescue false)
    }.delete_if{|val| val.blank?}

    patients
  end

  def n_negative

    patients = @hiv_tests.collect{|test|
      patient = Encounter.find(test.encounter).patient
      status = patient.hiv_status
      patient.patient_id if (((test.testdate.to_date >= (test.capturedate.to_date - 7.days)) && status.strip.downcase == "negative") rescue false)
    }.delete_if{|val| val.blank?}

    patients
  end
  
  def art_mother
    result = {}

    no_art =  pull("ADMIT PATIENT", "ON ART", "NO")
    startb4preg = pull("ADMIT PATIENT", "Date antiretrovirals started", "On ART before pregnancy")
    t1_or_t2 = pull("ADMIT PATIENT", "Date antiretrovirals started",  "On ART since first or second trimester")
    t3 = pull("ADMIT PATIENT", "Date antiretrovirals started",  "On ART since third trimester")
    during_labour = pull("ADMIT PATIENT", "Date antiretrovirals started", "On ART during labour")

    result["NO_ART"] = no_art
    result["START_B4_PREG"] = startb4preg
    result["T1_OR_T2"] = t1_or_t2
    result["T3"] = t3
    result["DURING_LABOUR"] = during_labour
    result
  end

  def referred
    result = {}

    # not_referred = pull("UPDATE OUTCOME", "OUTCOME", "NO")
    referred = pull("UPDATE OUTCOME", "OUTCOME", "REFERRED OUT")

    result["YES"] = referred
    result["NO"] = (@report_patients - referred).uniq
   
    result
  end

  def deaths
    
    patients =  @report_patients.collect{|pa|
      next if 
      pa if (["1", 1, "false", true].include?(Person.find(pa).dead) rescue false) && (Patient.find(pa).lmp.present? rescue false)
    }.delete_if{|val| val.blank?}

    patients
    
  end

  def maternity_outcome
    result = {}

    alive = pull("UPDATE OUTCOME", "MATERNITY OUTCOME", "ALIVE")
    dead = pull("UPDATE OUTCOME", "MATERNITY OUTCOME", "PATIENT DIED") + pull("UPDATE OUTCOME", "OUTCOME", "PATIENT DIED") +
      self.deaths
    
    result["DEAD"] = dead
    result["ALIVE"] = ((alive + @report_patients) - dead).uniq
    
    result
  end

  def delivery_place
    result = {}

    here = pull("BABY DELIVERY", "PLACE OF DELIVERY", "THIS FACILITY")
    in_transit = pull("BABY DELIVERY", "PLACE OF DELIVERY", "IN TRANSIT")
    other_facility = pull("BABY DELIVERY", "PLACE OF DELIVERY", "OTHER FACILITY")
    home_or_tba = pull("BABY DELIVERY", "PLACE OF DELIVERY", "HOME/TBA")

    result["HERE"] = here
    result["IN_TRANSIT"] = in_transit
    result["OTHER_FACILITY"] = other_facility
    result["HOME/TBA"] = home_or_tba
    result
  end

  def delivery_mode
    result = {}

    spontaneous = pull("BABY DELIVERY", "DELIVERY MODE", "Spontaneous vaginal delivery")
    vacuum = pull("BABY DELIVERY", "DELIVERY MODE", "Vacuum extraction delivery")
    breech = pull("BABY DELIVERY", "DELIVERY MODE", "Breech delivery")
    caesarean = pull("BABY DELIVERY", "DELIVERY MODE", "Caesarean section")

    result["SPONTANEOUS"] = spontaneous
    result["VACUUM"] = vacuum
    result["BREECH"] = breech
    result["CAESAREAN"] = caesarean
    result
  end

  def newborn_complications
    result = {}

    none = pull("BABY DELIVERY", "Newborn baby complications", "none")
    w2500 = pull("BABY DELIVERY", "Newborn baby complications", "Weight less than 2500g")
    sepsis = pull("BABY DELIVERY", "Newborn baby complications", "sepsis")
    asphyxia = pull("BABY DELIVERY", "Newborn baby complications", "Asphyxia")
    prematurity = pull("BABY DELIVERY", "Newborn baby complications", "Prematurity")
    other = pull("BABY DELIVERY", "Newborn baby complications", "Other")

    result["NONE"] = none
    result["W2500"] = w2500
    result["SEPSIS"] = sepsis
    result["ASPHYXIA"] =asphyxia
    result["PREMATURITY"] = prematurity
    result["OTHER"] = other
    result
  end

  def complications
    result = {}

    none = pull("UPDATE OUTCOME", "complications", "none")
    aph = pull("UPDATE OUTCOME", "complications", "Ante part hemorrhage")
    pph = pull("UPDATE OUTCOME", "complications", "Post part hemorrhage")
    pl1 = pull("UPDATE OUTCOME", "complications", "Prolonged first stage of labour")
    pl2 = pull("UPDATE OUTCOME", "complications", "Prolonged second stage of labour")
    pre_eclampsia = pull("UPDATE OUTCOME", "complications", "Pre-Eclampsia")
    sepsis = pull("UPDATE OUTCOME", "complications", "Sepsis")
    ru = pull("UPDATE OUTCOME", "complications", "Ruptured uterus")
    other = pull("UPDATE OUTCOME", "complications", "Other")

    result["NONE"] = none
    result["APH"] = aph
    result["PPH"] = pph
    result["PRO_LABOUR"] = pl1 + pl2
    result["PRE_ECLAMPSIA"] = pre_eclampsia
    result["SEPSIS"] = sepsis
    result["RUPTURED_UTERUS"] = ru
    result["OTHER"] = other
    result
  end

  def obst_complications
    result = {}

    blood_tr = pull("UPDATE OUTCOME", "Blood transfusion", "YES")
    placenta_rm = pull("UPDATE OUTCOME", "Placenta removed manually?", "YES")

    result["BLOOD_TRANSFUSION"] = blood_tr
    result["PLACENTA_REMOVED"] = placenta_rm

    result
  end

  def vitaminA_given
    result = {}

    no = pull("UPDATE OUTCOME", "Vitamin A given?", "NO")
    yes = pull("UPDATE OUTCOME", "Vitamin A given?", "YES")

    result["NO"] = no
    result["YES"] = yes

    result
  end

  def pmtct_survival
    result = {}

    alive_no_exposure = pull("UPDATE BABY OUTCOME", "baby outcome", "Alive and not exposed")
    alive_exposed_noNVP = pull("UPDATE BABY OUTCOME", "baby outcome", "Alive, exposed – not on NVP")
    alive_exposed_NVP = pull("UPDATE BABY OUTCOME", "baby outcome", "Alive, exposed - on NVP")
    alive_unknown_exp = pull("UPDATE BABY OUTCOME", "baby outcome", "Alive – unknown exposure")
    still_fresh = pull("BABY DELIVERY", "baby outcome", "Fresh still birth")
    still_macerated = pull("BABY DELIVERY", "baby outcome", "Macerated still birth")
    neonatal_death = pull("BABY DELIVERY", "baby outcome", "Neonatal death")

    result["NO_EXP"] = alive_no_exposure
    result["EXP_NONVP"] = alive_exposed_noNVP
    result["EXP_NVP"] = alive_exposed_NVP
    result["UNKNOWN_EXP"] = alive_unknown_exp
    result["FRESH"] = still_fresh
    result["MACERATED"] = still_macerated
    result["NEONATAL"] = neonatal_death


    result
  end

  def twins
    result = {}
    result["YES"] = twins_pull(2, 100)
    result["NO"] = twins_pull(0, 1)

    result
  end

  def clients_served?
    @program_encounters.present?
  end

  def premature
  
    @prematures =  Encounter.find_by_sql(["SELECT enc.patient_id AS mother, ob.value_datetime AS lmp, rel.person_b AS child FROM encounter enc
          INNER JOIN obs ob ON ob.encounter_id = enc.encounter_id AND enc.voided = 0
          INNER JOIN relationship rel ON rel.person_a = enc.patient_id AND rel.voided = 0
                AND rel.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child' LIMIT 1)
          WHERE enc.encounter_id IN (?)
              AND ob.concept_id = (SELECT concept_id FROM concept_name cn WHERE name = 'DATE OF LAST MENSTRUAL PERIOD' LIMIT 1)
           GROUP BY mother HAVING DATE_ADD(lmp, INTERVAL + 7 MONTH) >= (SELECT observ.value_datetime FROM obs observ
            WHERE observ.voided = 0 AND observ.concept_id = (SELECT conc.concept_id FROM concept_name conc WHERE conc.name = 'Date of delivery' LIMIT 1) ORDER BY observ.obs_datetime ASC LIMIT 1)
        ",
        @program_encounters])
    
    @prematures.collect{|t| t.attributes["child"]} rescue []
  
  end

  def w2500
    @lowweight =  Encounter.find_by_sql(["SELECT enc.patient_id AS child, ob.value_numeric AS number, ob.value_text AS text FROM encounter enc
          INNER JOIN obs ob ON ob.encounter_id = enc.encounter_id AND enc.voided = 0
            AND ob.concept_id = (SELECT conc.concept_id FROM concept_name conc WHERE conc.name = 'Birth weight' LIMIT 1)
          GROUP BY child HAVING COALESCE(number, text, 100000000000) < 2500",
        @program_encounters])

    @lowweight.collect{|t| t.attributes["child"]} rescue []
    
  end

end
