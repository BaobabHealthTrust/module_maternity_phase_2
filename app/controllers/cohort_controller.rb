class CohortController < ActionController::Base # < ApplicationController

  def index
    @location = GlobalProperty.find_by_property("facility.name").property_value rescue ""

    if params[:reportType]
      @reportType = params[:reportType] rescue nil
    else
      @reportType = nil
    end

  end

  def cohort
   
    @selSelect = params[:selSelect] rescue nil
    @day =  params[:day] rescue nil
    @selYear = params[:selYear] rescue 
    @selWeek = params[:selWeek] rescue nil
    @selMonth = params[:selMonth] rescue nil
    @selQtr = "#{params[:selQtr].gsub(/&/, "_")}" rescue nil

    @start_date = params[:start_date] rescue nil
    @end_date = params[:end_date] rescue nil

    @start_time = params[:start_time] rescue nil
    @end_time = params[:end_time] rescue nil

    @reportType = params[:reportType] rescue ""    
    @extended = get_global_property_value("extended_diagnoses_report").to_s == "true"
  
    render :layout => "menu"
  end

  def get_global_property_value(global_property)
		property_value = Settings[global_property]
		if property_value.nil?
			property_value = GlobalProperty.find(:first, :conditions => {:property => "#{global_property}"}
      ).property_value rescue nil
		end
		return property_value
	end

  def report
    @section = Location.find(params[:location_id]).name rescue ""
    
    @start_date = (params[:start_date].to_time rescue Time.now)
    
    @end_date = (params[:end_date].to_time rescue Time.now)
    
    @group1_start = @start_date
    
    @group1_end = (@end_date <= (@start_date + 12.hour) ? @end_date : (@start_date + 12.hour))
        
    @group2_start = (@end_date > (@start_date + 12.hour) ? (@start_date + 12.hour) : nil)
    
    @group2_end = (@end_date > (@start_date + 12.hour) ? @end_date : nil)
       
    render :layout => false
  end
  
  def diagnoses_report
    @section = Location.find(params[:location_id]).name rescue ""
    
    @start_date = (params[:start_date].to_time rescue Time.now)
    
    @end_date = (params[:end_date].to_time rescue Time.now)
    
    @group1_start = @start_date
    
    @group1_end = (@end_date <= (@start_date + 12.hour) ? @end_date : (@start_date + 12.hour))
        
    @group2_start = (@end_date > (@start_date + 12.hour) ? (@start_date + 12.hour) : nil)
    
    @group2_end = (@end_date > (@start_date + 12.hour) ? @end_date : nil)
       
    render :layout => false
  end

  def diagnoses_report_extended
    @section = Location.find(params[:location_id]).name rescue ""
    
    @start_date = (params[:start_date].to_time rescue Time.now)
    
    @end_date = (params[:end_date].to_time rescue Time.now)
    
    @group1_start = @start_date
    
    @group1_end = (@end_date <= (@start_date + 12.hour) ? @end_date : (@start_date + 12.hour))
        
    @group2_start = (@end_date > (@start_date + 12.hour) ? (@start_date + 12.hour) : nil)
    
    @group2_end = (@end_date > (@start_date + 12.hour) ? @end_date : nil)
       
    render :layout => false
  end
  
  def q

    if params[:parent]

      procedure(params[:start_date], params[:end_date], params[:group], params[:field], params[:parent])
    elsif params[:like]
      diagnosis_regex(params[:start_date], params[:end_date], params[:group], params[:field])
    elsif params[:field] && !params[:ext] && !params[:pro] && !params[:proc]
      case params[:field]
      when "admissions"
        admissions(params[:start_date], params[:end_date], params[:group], params[:field])
      when "svd"
        svd(params[:start_date], params[:end_date], params[:group], params[:field])
      when "c_section"
        c_section(params[:start_date], params[:end_date], params[:group], params[:field])
      when "vacuum_extraction"
        vacuum_extraction(params[:start_date], params[:end_date], params[:group], params[:field])
      when "breech_delivery"
        breech_delivery(params[:start_date], params[:end_date], params[:group], params[:field])
      when "twins"
        twins(params[:start_date], params[:end_date], params[:group], params[:field])
      when "triplets"
        triplets(params[:start_date], params[:end_date], params[:group], params[:field])
      when "live_births"
        live_births(params[:start_date], params[:end_date], params[:group], params[:field])
      when "macerated"
        macerated(params[:start_date], params[:end_date], params[:group], params[:field])
      when "fresh"
        fresh(params[:start_date], params[:end_date], params[:group], params[:field])
      when "neonatal_death"
        neonatal_death(params[:start_date], params[:end_date], params[:group], params[:field])
      when "maternal_death"
        maternal_death(params[:start_date], params[:end_date], params[:group], params[:field])
      when "bba"
        bba(params[:start_date], params[:end_date], params[:group], params[:field])
      when "referral_out"
        referral_out(params[:start_date], params[:end_date], params[:group], params[:field])
      when "referral_in"
        referral_in(params[:start_date], params[:end_date], params[:group], params[:field])
      when "discharges"
        discharges(params[:start_date], params[:end_date], params[:group], params[:field])
      when "ante_natal_ward"
        ante_natal_ward(params[:start_date], params[:end_date], params[:group], params[:field])
      when "discharges_low_risk"
        discharges_low_risk(params[:start_date], params[:end_date], params[:group], params[:field])
      when "discharges_high_risk"
        discharges_high_risk(params[:start_date], params[:end_date], params[:group], params[:field])
      when "abscondees"
        abscondees(params[:start_date], params[:end_date], params[:group], params[:field])
      when "post_mothers"
        post_mothers(params[:start_date], params[:end_date], params[:group], params[:field])
      when "post_babies"
        post_babies(params[:start_date], params[:end_date], params[:group], params[:field])
      when "ante_labor"
        ante_labor(params[:start_date], params[:end_date], params[:group], params[:field])
      when "post_labor"
        post_labor(params[:start_date], params[:end_date], params[:group], params[:field])
      when "labor_high"
        labor_high(params[:start_date], params[:end_date], params[:group], params[:field])
      when "labor_low"
        labor_low(params[:start_date], params[:end_date], params[:group], params[:field])
      when "theatre_high"
        theatre_high(params[:start_date], params[:end_date], params[:group], params[:field])
      when "ante_theatre"
        ante_theatre(params[:start_date], params[:end_date], params[:group], params[:field])
      when "labor_gynae"
        labor_gynae(params[:start_date], params[:end_date], params[:group], params[:field])
      when "gynae_labor"
        gynae_labor(params[:start_date], params[:end_date], params[:group], params[:field])
      when "labor_ante"
        labor_ante(params[:start_date], params[:end_date], params[:group], params[:field])
      when "total_deliveries"
        total_deliveries(params[:start_date], params[:end_date], params[:group], params[:field])
      when "premature_labour"
        premature_labour(params[:start_date], params[:end_date], params[:group], params[:field])
      when "abortions"
        abortions(params[:start_date], params[:end_date], params[:group], params[:field])
      when "cancer_of_cervix"
        cancer_of_cervix(params[:start_date], params[:end_date], params[:group], params[:field])
      when "molar_pregnancy"
        molar_pregnancy(params[:start_date], params[:end_date], params[:group], params[:field])
      when "fibriods"
        fibriods(params[:start_date], params[:end_date], params[:group], params[:field])
      when "pelvic_inflamatory_disease"
        pelvic_inflamatory_disease(params[:start_date], params[:end_date], params[:group], params[:field])
      when "anaemia"
        anaemia(params[:start_date], params[:end_date], params[:group], params[:field])
      when "malaria"
        malaria(params[:start_date], params[:end_date], params[:group], params[:field])
      when "post_partum"
        post_partum(params[:start_date], params[:end_date], params[:group], params[:field])
      when "haemorrhage"
        haemorrhage(params[:start_date], params[:end_date], params[:group], params[:field])
      when "ante_partum"
        ante_partum(params[:start_date], params[:end_date], params[:group], params[:field])
      when "pre_eclampsia"
        pre_eclampsia(params[:start_date], params[:end_date], params[:group], params[:field])
      when "eclampsia"
        eclampsia(params[:start_date], params[:end_date], params[:group], params[:field])
      when "premature_labour"
        premature_labour(params[:start_date], params[:end_date], params[:group], params[:field])
      when "premature_membranes_rapture"
        premature_membranes_rapture(params[:start_date], params[:end_date], params[:group], params[:field])
      when "laparatomy"
        laparatomy(params[:start_date], params[:end_date], params[:group], params[:field])
      when "ruptured_uterus"
        ruptured_uterus(params[:start_date], params[:end_date], params[:group], params[:field])
      end
    elsif !params[:proc]
      diagnosis(params[:start_date], params[:end_date], params[:group], params[:field])
    end
  end
    
  def admissions(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all,
      :conditions => ["admission_date >= ? AND admission_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def total_deliveries(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(delivery_mode, '') != '' " + 
          "AND delivery_date >= ? AND delivery_date <= ?", startdate, enddate]).collect{|p| p.patient_id}
    
    render :text => patients.to_json
  end

  def svd(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(delivery_mode, '') = 'SPONTANEOUS VAGINAL DELIVERY' " + 
          "AND delivery_date >= ? AND delivery_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def c_section(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(delivery_mode, '') = 'Caesarean section' " + 
          "AND delivery_date >= ? AND delivery_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def vacuum_extraction(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(delivery_mode, '') = 'Vacuum extraction delivery' " + 
          "AND delivery_date >= ? AND delivery_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def breech_delivery(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(delivery_mode, '') = 'Breech delivery' " + 
          "AND delivery_date >= ? AND delivery_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def twins(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(babies, '') = 2 " + 
          "AND birthdate >= ? AND birthdate <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def triplets(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(babies, '') = 3 " + 
          "AND birthdate >= ? AND birthdate <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def live_births(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(baby_outcome, '') = 'Alive' " + 
          "AND baby_outcome_date >= ? AND baby_outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def macerated(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(baby_outcome, '') = 'Macerated still birth' " + 
          "AND baby_outcome_date >= ? AND baby_outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def fresh(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(baby_outcome, '') = 'Fresh still birth' " + 
          "AND baby_outcome_date >= ? AND baby_outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def neonatal_death(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(baby_outcome, '') = 'Neonatal death' " + 
          "AND baby_outcome_date >= ? AND baby_outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def maternal_death(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(outcome, '') = 'Patient died' " + 
          "AND outcome_date >= ? AND outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def bba(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = []
      
    PatientReport.find(:all, :conditions => ["COALESCE(bba_babies, '') != '' " + 
          "AND bba_date >= ? AND bba_date <= ?", startdate, enddate]).each{|p| 
      (1..(p.bba_babies.to_i)).each{|b|
        patients << p.patient_id
      }
    }
    
    render :text => patients.to_json
  end

  def referral_out(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(referral_out, '') != '' " + 
          "AND referral_out >= ? AND referral_out <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def referral_in(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(referral_in, '') != '' " + 
          "AND referral_in >= ? AND referral_in <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def discharges(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(outcome, '') = 'Discharged' " + 
          "AND outcome_date >= ? AND outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def discharges_low_risk(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(discharge_ward, '') = 'Post-Natal Ward (Low Risk)' " +
          "AND discharged >= ? AND discharged <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq

    render :text => patients.to_json
  end

  def discharges_high_risk(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(discharge_ward, '') = 'Post-Natal Ward (High Risk)' " +
          "AND discharged >= ? AND discharged <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq

    render :text => patients.to_json
  end

  def abscondees(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(outcome, '') = 'Absconded' " + 
          "AND outcome_date >= ? AND outcome_date <= ?", startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def post_mothers(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["(COALESCE(last_ward_where_seen, '') = 'Post-Natal Ward' OR " + 
          "COALESCE(last_ward_where_seen, '') = 'Post-Natal Ward (High Risk)' OR COALESCE(last_ward_where_seen, '') = " + 
          "'Post-Natal Ward (Low Risk)') AND last_ward_where_seen_date >= ? AND last_ward_where_seen_date <= ?", 
        startdate, enddate]).collect{|p| p.patient_id} #.uniq
    
    render :text => patients.to_json
  end

  def post_babies(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["(COALESCE(last_ward_where_seen, '') = 'Post-Natal Ward' OR " + 
          "COALESCE(last_ward_where_seen, '') = 'Post-Natal Ward (High Risk)' OR COALESCE(last_ward_where_seen, '') = " + 
          "'Post-Natal Ward (Low Risk)') AND COALESCE(delivery_mode, '') != '' AND last_ward_where_seen_date >= ? " + 
          "AND last_ward_where_seen_date <= ?", startdate, enddate]).collect{|p| p.patient_id}
    
    render :text => patients.to_json
  end

  def ante_labor(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Ante-Natal Ward' AND " + 
          "COALESCE(destination_ward, '') = 'Labour Ward' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def post_labor(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["(COALESCE(source_ward, '') = 'Post-Natal Ward' OR " + 
          "COALESCE(source_ward, '') = 'Post-Natal Ward (High Risk)' OR COALESCE(source_ward, '') = 'Post-Natal Ward (Low Risk)') AND " + 
          "COALESCE(destination_ward, '') = 'Labour Ward' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def labor_high(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Labour Ward' AND " + 
          "COALESCE(destination_ward, '') = 'Post-Natal Ward (High Risk)' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def labor_ante(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Labour Ward' AND " + 
          "COALESCE(destination_ward, '') = 'Ante-Natal Ward' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def labor_low(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Labour Ward' AND " + 
          "COALESCE(destination_ward, '') = 'Post-Natal Ward (Low Risk)' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def theatre_high(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["(COALESCE(source_ward, '') = 'Theater' " + 
          "OR COALESCE(source_ward, '') = 'Theatre') AND " + 
          "COALESCE(destination_ward, '') = 'Post-Natal Ward (High Risk)' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def ante_theatre(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Ante-Natal Ward' AND " + 
          "(COALESCE(destination_ward, '') = 'Theater' OR COALESCE(destination_ward, '') = 'Theatre') " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def labor_gynae(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Labour Ward' AND " + 
          "COALESCE(destination_ward, '') = 'Gynaecology Ward' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end

  def gynae_labor(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["COALESCE(source_ward, '') = 'Gynaecology Ward' AND " + 
          "COALESCE(destination_ward, '') = 'Labour Ward' " + 
          "AND internal_transfer_date >= ? AND internal_transfer_date <= ?", startdate, enddate]).collect{|p| p.patient_id}.uniq
    
    render :text => patients.to_json
  end
  
  # DIAGNOSES
  def premature_labour(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Premature Labour", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def abortions(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis regexp ? AND diagnosis_date >= ? AND diagnosis_date <= ?",
        "Abortion", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def cancer_of_cervix(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Cancer of Cervix", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def molar_pregnancy(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Molar Pregnancy", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def fibriods(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis LIKE ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "%Fibroid%", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def pelvic_inflamatory_disease(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Pelvic Inflammatory Disease", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def anaemia(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Anaemia", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def malaria(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Malaria", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def post_partum(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Post Partum", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def haemorrhage(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Haemorrhage", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def ante_partum(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis LIKE ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "%Ante%Partum%", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def pre_eclampsia(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Pre-Eclampsia", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def eclampsia(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?",
        "Eclampsia", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def premature_labour(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Premature Labour", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def premature_membranes_rapture(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Premature Membranes Rapture", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def laparatomy(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["procedure_done LIKE ? AND procedure_date >= ? AND procedure_date <= ?", 
        "%Laparatomy%", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def ruptured_uterus(startdate = Time.now, enddate = Time.now, group = 1, field = "")
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        "Ruptured Uterus", startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def diagnosis(startdate = Time.now, enddate = Time.now, group = 1, field = "")
	
    check_field = field.humanize.gsub("- ", "-").gsub("_", " ").gsub("!", "/")
    if check_field.downcase == "pprom"
      check_field = " Preterm Premature Rupture Of Membranes (Pprom)"
    end
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        check_field, startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def diagnosis_regex(startdate = Time.now, enddate = Time.now, group = 1, field = "")

    check_field = field.humanize.gsub("- ", "-").gsub("_", " ").gsub("!", "/")
    if field == "invasive_cancer_of_cervix"
      patients = PatientReport.find(:all, :conditions => ["diagnosis IN (?) AND diagnosis_date >= ? AND diagnosis_date <= ?",
          ["Cervical stage 1", "Cervical stage 2", "Cervical stage 3", "Cervical stage 4", "Invasive cancer of cervix", "Cancer of Cervix"], startdate, enddate]).collect{|p| p.patient_id}.uniq
    else
      patients = PatientReport.find(:all, :conditions => ["diagnosis regexp ? AND diagnosis_date >= ? AND diagnosis_date <= ?",
          check_field, startdate, enddate]).collect{|p| p.patient_id}.uniq
    end
    render :text => patients.to_json
  end

  def procedure(startdate = Time.now, enddate = Time.now, group = 1, field = "", proc = "")
    check_field = field.humanize.gsub("- ", "-").gsub("!", "/") 
    check_proc = proc.humanize.gsub("- ", "-").gsub("!", "/")
    if proc.downcase == "evacuation"
      check_proc = "Evacuation/Manual Vacuum Aspiration"
    end
	
    patients = PatientReport.find(:all, :conditions => ["diagnosis = ? AND procedure_done = ? AND diagnosis_date >= ? AND diagnosis_date <= ?", 
        check_field, check_proc, startdate, enddate]).collect{|p| p.patient_id}.uniq

    render :text => patients.to_json
  end

  def decompose
    @patients = Patient.find(:all, :conditions => ["patient_id IN (?)", params[:patients].split(",")])
    
    # raise @patients.to_yaml
    render :layout => false
  end

  def matrix_decompose
		@patients = Patient.find(:all, :conditions => ["patient_id IN (?)", params[:patients].split(",")]).uniq rescue [  ]

    if @patients.blank? && session[:drill_down_data].present? & params[:group].present?

      ids = []

      if session[:drill_down_data]["#{params[:group]}"].class.to_s.match(/Array/i)
        ids = session[:drill_down_data]["#{params[:group]}"]
      elsif params[:key].present?
        ids = (session[:drill_down_data]["#{params[:group]}"]["#{params[:key].upcase.strip}"] +
            ((session[:drill_down_data]["#{params[:group]}"]["FE_#{params[:key].gsub(/male\_/i, '').upcase.strip}"] || []) rescue []) +
            ((session[:drill_down_data]["#{params[:group]}"]["F_#{params[:key].gsub(/male\_/i, '').upcase.strip}"] || []) rescue [])).uniq rescue []
      end
      @patients = Patient.find(:all, :conditions => ["patient_id IN (?)", ids]).uniq if ids.present?

    end

		render :layout => false
  end
  
end
