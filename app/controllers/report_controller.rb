class ReportController < ApplicationController

  def report_limits
 
    @type = params["type"]
    @action = ""
    case @type
    when "babies_matrix"
      @action = "baby_matrix"

    when "monthly_report"
      @action = "report"
    end
 
  end
 
  def report

    @startdate = params["start_date"]
    @enddate = params["end_date"]

    @facility = get_global_property_value("facility.name")
    @year = @enddate.to_date.year rescue Date.today.year
    @month = @enddate.to_date.strftime("%B")

    report = Report.new(@startdate, @enddate)

    @delivery_mode = report.delivery_mode
    
    @delivery_place = report.delivery_place

    @hiv_status_map = report.hiv_status_map

    @delivery_staff = report.delivery_staff

    @art_mother = report.art_mother

    @referred = report.referred

    @mother_outcome = report.maternity_outcome

    @newborn_complications = report.newborn_complications
    
    @newborn_complications["PREMATURITY"] = (@newborn_complications["PREMATURITY"] || []).concat(report.premature).uniq
    @newborn_complications["W2500"] = (@newborn_complications["W2500"] || []).concat(report.w2500).uniq
    
    @newborn_complications["NONE"] =  @newborn_complications["NONE"] - (@newborn_complications["SEPSIS"] + @newborn_complications["PREMATURITY"] + @newborn_complications["ASPHYXIA"] +
        @newborn_complications["OTHER"] + @newborn_complications["W2500"])   
    
    @complications = report.complications

    @obst_complications = report.obst_complications

    @vitaminA_given = report.vitaminA_given

    @pmtct_survival = report.pmtct_survival

    @twins = report.twins

    @any_client_served = report.clients_served?
  
    render :layout => false
  end

  def cohort

    unless params[:from_print]
      day = params[:selQtr].to_s.match(/^min=(.+)&max=(.+)$/)
      @start_date = (day ? day[1] : Date.today.strftime("%Y-%m-%d"))
      @end_date = (day ? day[2] : Date.today.strftime("%Y-%m-%d"))
    else
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    end

    @reportType = params[:reportType]
    
  end

  def birth_cohort

    @quarter = params[:start_date].match(/\-07\-01/)? "3" : (params[:start_date].match(/\-01\-01/) ? "1" : (params[:end_date].match(/\-12\-31/) ? "4" : "2"))

    @system_upgrade_date = Relationship.find(:first, :order => ["date_created ASC"], :conditions => ["relationship = ?",
        RelationshipType.find_by_a_is_to_b_and_b_is_to_a("Mother", "Child")]).date_created.to_date rescue "2013-04-20"

    #2013-04-20 is the date when we started creating baby-mother relationships in  BHT EMR's

    params[:start_date] = @system_upgrade_date.blank?? params[:start_date] : (@system_upgrade_date.to_date > params[:start_date].to_date ? @system_upgrade_date : params[:start_date])

    @total_admissions = Patient.total_admissions(params[:start_date], params[:end_date]) rescue []

    @ctotal_admissions = Patient.total_admissions(@system_upgrade_date, params[:end_date]) rescue []

    @total_mothers = Patient.total_mothers_in_range(params[:start_date], params[:end_date],  @total_admissions) rescue []

    @maternal_outcomes = {}
    @maternal_outcomes["DEAD"] = Patient.deaths(@total_admissions, params[:start_date], params[:end_date])# rescue []
    
    @maternal_outcomes["ALIVE"] = @total_admissions - @maternal_outcomes["DEAD"]

    @cmaternal_outcomes = {}
    @cmaternal_outcomes["DEAD"] = Patient.deaths(@total_admissions, @system_upgrade_date, params[:end_date]) rescue []
    @cmaternal_outcomes["ALIVE"] = @ctotal_admissions - @cmaternal_outcomes["DEAD"]


    @total_delivery_counts = Relationship.twins_pull(@total_admissions, params[:start_date], params[:end_date]) rescue []
    @ctotal_delivery_counts = Relationship.twins_pull(@ctotal_admissions, @system_upgrade_date, params[:end_date]) rescue []

    @twins = {}
    @twins["1"] = @total_delivery_counts.collect{|mother| mother.patient_id if mother.counter.to_i == 1}.compact.uniq
    @twins["2"] = @total_delivery_counts.collect{|mother| mother.patient_id if mother.counter.to_i == 2}.compact.uniq
    @twins["3"] = @total_delivery_counts.collect{|mother| mother.patient_id if mother.counter.to_i == 3}.compact.uniq
    @twins[">3"] = @total_delivery_counts.collect{|mother| mother.patient_id if mother.counter.to_i > 3}.compact.uniq
    @twins["Unknown"] =  @total_delivery_counts.collect{|mother| mother.patient_id if mother.counter.blank? || mother.counter.to_i < 1}.compact.uniq

    @ctwins = {}
    @ctwins["1"] = @ctotal_delivery_counts.collect{|mother| mother.patient_id if mother.counter.to_i == 1}.compact.uniq
    @ctwins["2"] = @ctotal_delivery_counts.collect{|mother| mother.patient_id if mother.counter.to_i == 2}.compact.uniq
    @ctwins["3"] = @ctotal_delivery_counts.collect{|mother| mother.patient_id if mother.counter.to_i == 3}.compact.uniq
    @ctwins[">3"] = @ctotal_delivery_counts.collect{|mother| mother.patient_id if mother.counter.to_i > 3}.compact.uniq
    @ctwins["Unknown"] = @ctotal_delivery_counts.collect{|mother| mother.patient_id if mother.counter.blank? || mother.counter.to_i < 1}.compact.uniq

    @ctotal_mothers = Patient.total_mothers_in_range(@system_upgrade_date, params[:end_date],  @ctotal_admissions) rescue []

    @total_babies = Relationship.total_babies_in_range(params[:start_date], params[:end_date]) rescue []

    @ctotal_babies = Relationship.total_babies_in_range(@system_upgrade_date, params[:end_date]) rescue []

    @total_babies_born = @total_babies.collect{|baby| baby.person_id rescue nil}.compact rescue []
    @ctotal_babies_born = @ctotal_babies.collect{|baby| baby.person_id rescue nil}.compact rescue []

    @delivery_weeks = {}
    @delivery_weeks["PRE_TERM"] = @total_mothers.collect{|mother| mother.patient_id if ((mother.weeks.present? && mother.weeks.to_i < 34 && mother.weeks.to_i > 1)rescue false)}.compact.uniq
    @delivery_weeks["NEAR_TERM"] = @total_mothers.collect{|mother| mother.patient_id if ((mother.weeks.present? && mother.weeks.to_i >= 34 && mother.weeks.to_i <= 37)rescue false)}.compact.uniq
    @delivery_weeks["POST_TERM"] = @total_mothers.collect{|mother| mother.patient_id if ((mother.weeks.present? && mother.weeks.to_i > 42)rescue false)}.compact.uniq
    @delivery_weeks["FULL_TERM"] = @total_mothers.collect{|mother| mother.patient_id if ((mother.weeks.present? && mother.weeks.to_i >= 38 && mother.weeks.to_i <= 42)rescue false)}.compact.uniq
    @delivery_weeks["UNKNOWN"] = @total_mothers.collect{|mother| mother.patient_id if mother.weeks.blank? || mother.weeks.to_i <= 1}.compact.uniq

    @cdelivery_weeks = {}
    @cdelivery_weeks["PRE_TERM"] = @ctotal_mothers.collect{|mother| mother.patient_id if ((mother.weeks.present? && mother.weeks.to_i < 34)rescue false)}.compact.uniq
    @cdelivery_weeks["NEAR_TERM"] = @ctotal_mothers.collect{|mother| mother.patient_id if ((mother.weeks.present? && mother.weeks.to_i >= 34 && mother.weeks.to_i <= 37)rescue false)}.compact.uniq
    @cdelivery_weeks["POST_TERM"] = @ctotal_mothers.collect{|mother| mother.patient_id if ((mother.weeks.present? && mother.weeks.to_i > 42)rescue false)}.compact.uniq
    @cdelivery_weeks["FULL_TERM"] = @ctotal_mothers.collect{|mother| mother.patient_id if ((mother.weeks.present? && mother.weeks.to_i >= 38 && mother.weeks.to_i <= 42)rescue false)}.compact.uniq
    @cdelivery_weeks["UNKNOWN"] = @ctotal_mothers.collect{|mother| mother.patient_id if mother.weeks.blank?}.compact.uniq


    @birth_report_status = {}
    @birth_report_status["SENT"] = @total_babies.collect{|baby| baby.person_id if ((baby.br_status.present? && baby.br_status.match(/SENT/i))rescue false)}.compact.uniq
    @birth_report_status["PENDING"] = @total_babies.collect{|baby| baby.person_id if ((baby.br_status.present? && baby.br_status.match(/PENDING/i))rescue false)}.compact.uniq
    @birth_report_status["UNATTEMPTED"] = @total_babies.collect{|baby| baby.person_id if ((baby.br_status.present? && baby.br_status.match(/UNATTEMPTED/i))rescue false)}.compact.uniq
    @birth_report_status["UNKNOWN"] = @total_babies.collect{|baby| baby.person_id if ((baby.br_status.present? && baby.br_status.match(/UNKNOWN/i))rescue false)}.compact.uniq

    @cbirth_report_status = {}
    @cbirth_report_status["SENT"] = @ctotal_babies.collect{|baby| baby.person_id if ((baby.br_status.present? && baby.br_status.match(/SENT/i))rescue false)}.compact.uniq
    @cbirth_report_status["PENDING"] = @ctotal_babies.collect{|baby| baby.person_id if ((baby.br_status.present? && baby.br_status.match(/PENDING/i))rescue false)}.compact.uniq
    @cbirth_report_status["UNATTEMPTED"] = @ctotal_babies.collect{|baby| baby.person_id if ((baby.br_status.present? && baby.br_status.match(/UNATTEMPTED/i))rescue false)}.compact.uniq
    @cbirth_report_status["UNKNOWN"] = @ctotal_babies.collect{|baby| baby.person_id if ((baby.br_status.present? && baby.br_status.match(/UNKNOWN/i))rescue false)}.compact.uniq

    @gender = {}
    @gender["MALES"] = @total_babies.collect{|baby| baby.person_id if !baby.gender.match(/F/i)}.compact.uniq
    @gender["FEMALES"] = @total_babies.collect{|baby| baby.person_id if baby.gender.match(/F/i)}.compact.uniq
    @cgender = {}
    @cgender["MALES"] = @ctotal_babies.collect{|baby| baby.person_id if !baby.gender.match(/F/i)}.compact.uniq
    @cgender["FEMALES"] = @ctotal_babies.collect{|baby| baby.person_id if baby.gender.match(/F/i)}.compact.uniq

    @apgar1 = {}
    @apgar2 = {}
    @capgar1 = {}
    @capgar2 = {}

    @apgar1["FE_LOW"] = @total_babies.collect{|baby| baby.person_id if baby.apgar.present? && baby.apgar.to_i <= 3 && baby.gender.match(/F/i)}.compact.uniq
    @apgar1["FE_FAIRLY_LOW"] = @total_babies.collect{|baby| baby.person_id if baby.apgar.present? && baby.apgar.to_i > 3 && baby.apgar.to_i < 7 && baby.gender.match(/F/i)}.compact.uniq
    @apgar1["FE_NORMAL"] = @total_babies.collect{|baby| baby.person_id if baby.apgar.present? && baby.apgar.to_i >= 7 && baby.gender.match(/F/i)}.compact.uniq
    @apgar1["FE_UNKNOWN"] = (@gender["FEMALES"] - (@apgar1["FE_LOW"] + @apgar1["FE_FAIRLY_LOW"] + @apgar1["FE_NORMAL"] ))

    @apgar2["FE_LOW"] = @total_babies.collect{|baby| baby.person_id if  baby.apgar2.present? && baby.apgar2.to_i <= 3 && baby.gender.match(/F/i)}.compact.uniq
    @apgar2["FE_FAIRLY_LOW"] = @total_babies.collect{|baby| baby.person_id if baby.apgar2.present? && baby.apgar2.to_i > 3 && baby.apgar2.to_i < 7 && baby.gender.match(/F/i)}.compact.uniq
    @apgar2["FE_NORMAL"] = @total_babies.collect{|baby| baby.person_id if baby.apgar2.present? && baby.apgar2.to_i >= 7 && baby.gender.match(/F/i)}.compact.uniq
    @apgar2["FE_UNKNOWN"] = (@gender["FEMALES"] - (@apgar2["FE_NORMAL"] + @apgar2["FE_FAIRLY_LOW"] + @apgar2["FE_LOW"]))

    @apgar1["MALE_LOW"] = @total_babies.collect{|baby| baby.person_id if baby.apgar.present? && baby.apgar.to_i <= 3 && !baby.gender.match(/F/i)}.compact.uniq
    @apgar1["MALE_FAIRLY_LOW"] = @total_babies.collect{|baby| baby.person_id if  baby.apgar.present? && baby.apgar.to_i > 3 && baby.apgar.to_i < 7 && !baby.gender.match(/F/i)}.compact.uniq
    @apgar1["MALE_NORMAL"] = @total_babies.collect{|baby| baby.person_id if  baby.apgar.present? && baby.apgar.to_i >= 7 && !baby.gender.match(/F/i)}.compact.uniq
    @apgar1["MALE_UNKNOWN"] = (@gender["MALES"] - (@apgar1["MALE_NORMAL"] + @apgar1["MALE_FAIRLY_LOW"] + @apgar1["MALE_LOW"]))

    @apgar2["MALE_LOW"] = @total_babies.collect{|baby| baby.person_id if baby.apgar2.present? && baby.apgar2.to_i <= 3 && !baby.gender.match(/F/i)}.compact.uniq
    @apgar2["MALE_FAIRLY_LOW"] = @total_babies.collect{|baby| baby.person_id if baby.apgar2.present? && baby.apgar2.to_i > 3 && baby.apgar2.to_i < 7 && !baby.gender.match(/F/i)}.compact.uniq
    @apgar2["MALE_NORMAL"] = @total_babies.collect{|baby| baby.person_id if baby.apgar2.present? && baby.apgar2.to_i >= 7 && !baby.gender.match(/F/i)}.compact.uniq
    @apgar2["MALE_UNKNOWN"] = (@gender["MALES"]  - (@apgar2["MALE_LOW"] + @apgar2["MALE_FAIRLY_LOW"] + @apgar2["MALE_NORMAL"]))

    # for cumulative totals
    @capgar1["FE_LOW"] = @ctotal_babies.collect{|baby| baby.person_id if baby.apgar.present? && baby.apgar.to_i <= 3 && baby.gender.match(/F/i)}.compact.uniq
    @capgar1["FE_FAIRLY_LOW"] = @ctotal_babies.collect{|baby| baby.person_id if baby.apgar.present? && baby.apgar.to_i > 3 && baby.apgar.to_i < 7 && baby.gender.match(/F/i)}.compact.uniq
    @capgar1["FE_NORMAL"] = @ctotal_babies.collect{|baby| baby.person_id if baby.apgar.present? && baby.apgar.to_i >= 7 && baby.gender.match(/F/i)}.compact.uniq
    @capgar1["FE_UNKNOWN"] = (@cgender["FEMALES"] - (@capgar1["FE_LOW"] + @capgar1["FE_FAIRLY_LOW"] + @capgar1["FE_NORMAL"] ))

    @capgar2["FE_LOW"] = @ctotal_babies.collect{|baby| baby.person_id if  baby.apgar2.present? && baby.apgar2.to_i <= 3 && baby.gender.match(/F/i)}.compact.uniq
    @capgar2["FE_FAIRLY_LOW"] = @ctotal_babies.collect{|baby| baby.person_id if baby.apgar2.present? && baby.apgar2.to_i > 3 && baby.apgar2.to_i < 7 && baby.gender.match(/F/i)}.compact.uniq
    @capgar2["FE_NORMAL"] = @ctotal_babies.collect{|baby| baby.person_id if baby.apgar2.present? && baby.apgar2.to_i >= 7 && baby.gender.match(/F/i)}.compact.uniq
    @capgar2["FE_UNKNOWN"] = (@cgender["FEMALES"] - (@capgar2["FE_NORMAL"] + @capgar2["FE_FAIRLY_LOW"] + @capgar2["FE_LOW"]))

    @capgar1["MALE_LOW"] = @ctotal_babies.collect{|baby| baby.person_id if baby.apgar.present? && baby.apgar.to_i <= 3 && !baby.gender.match(/F/i)}.compact.uniq
    @capgar1["MALE_FAIRLY_LOW"] = @ctotal_babies.collect{|baby| baby.person_id if  baby.apgar.present? && baby.apgar.to_i > 3 && baby.apgar.to_i < 7 && !baby.gender.match(/F/i)}.compact.uniq
    @capgar1["MALE_NORMAL"] = @ctotal_babies.collect{|baby| baby.person_id if  baby.apgar.present? && baby.apgar.to_i >= 7 && !baby.gender.match(/F/i)}.compact.uniq
    @capgar1["MALE_UNKNOWN"] = (@cgender["MALES"] - (@capgar1["MALE_NORMAL"] + @capgar1["MALE_FAIRLY_LOW"] + @capgar1["MALE_LOW"]))

    @capgar2["MALE_LOW"] = @ctotal_babies.collect{|baby| baby.person_id if baby.apgar2.present? && baby.apgar2.to_i <= 3 && !baby.gender.match(/F/i)}.compact.uniq
    @capgar2["MALE_FAIRLY_LOW"] = @ctotal_babies.collect{|baby| baby.person_id if baby.apgar2.present? && baby.apgar2.to_i > 3 && baby.apgar2.to_i < 7 && !baby.gender.match(/F/i)}.compact.uniq
    @capgar2["MALE_NORMAL"] = @ctotal_babies.collect{|baby| baby.person_id if baby.apgar2.present? && baby.apgar2.to_i >= 7 && !baby.gender.match(/F/i)}.compact.uniq
    @capgar2["MALE_UNKNOWN"] = (@cgender["MALES"]  - (@capgar2["MALE_LOW"] + @capgar2["MALE_FAIRLY_LOW"] + @capgar2["MALE_NORMAL"]))

    @delivery_mode = {}
    @delivery_mode["MALE_ALIVE"] = @total_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Alive/i) && !baby.gender.match(/F/i)}.compact.uniq
    @delivery_mode["MALE_NEO"] = @total_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Neonatal death/i) && !baby.gender.match(/F/i)}.compact.uniq
    @delivery_mode["MALE_FRESH"] = @total_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Fresh still birth/i) && !baby.gender.match(/F/i)}.compact.uniq
    @delivery_mode["MALE_MAC"] = @total_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Macerated still birth/i) && !baby.gender.match(/F/i)}.compact.uniq

    @delivery_mode["F_ALIVE"] = @total_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Alive/i) && baby.gender.match(/F/i)}.compact.uniq
    @delivery_mode["F_NEO"] = @total_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Neonatal death/i) && baby.gender.match(/F/i)}.compact.uniq
    @delivery_mode["F_FRESH"] = @total_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Fresh still birth/i) && baby.gender.match(/F/i)}.compact.uniq
    @delivery_mode["F_MAC"] = @total_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Macerated still birth/i) && baby.gender.match(/F/i)}.compact.uniq

    #cumulative delivery outcomes
    @cdelivery_mode = {}
    @cdelivery_mode["MALE_ALIVE"] = @ctotal_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Alive/i) && !baby.gender.match(/F/i)}.compact.uniq
    @cdelivery_mode["MALE_NEO"] = @ctotal_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Neonatal death/i) && !baby.gender.match(/F/i)}.compact.uniq
    @cdelivery_mode["MALE_FRESH"] = @ctotal_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Fresh still birth/i) && !baby.gender.match(/F/i)}.compact.uniq
    @cdelivery_mode["MALE_MAC"] = @ctotal_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Macerated still birth/i) && !baby.gender.match(/F/i)}.compact.uniq

    @cdelivery_mode["F_ALIVE"] = @ctotal_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Alive/i) && baby.gender.match(/F/i)}.compact.uniq
    @cdelivery_mode["F_NEO"] = @ctotal_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Neonatal death/i) && baby.gender.match(/F/i)}.compact.uniq
    @cdelivery_mode["F_FRESH"] = @ctotal_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Fresh still birth/i) && baby.gender.match(/F/i)}.compact.uniq
    @cdelivery_mode["F_MAC"] = @ctotal_babies.collect{|baby| baby.person_id if baby.delivery_outcome.match(/Macerated still birth/i) && baby.gender.match(/F/i)}.compact.uniq


    @discharge_outcome = {}
    @discharge_outcome["MALE_ALIVE"] = @total_babies.collect{|baby| baby.person_id if (baby.discharge_outcome.match(/Alive/i) rescue false) && !baby.gender.match(/F/i)}.compact.uniq
    @discharge_outcome["MALE_DEAD"] = @total_babies.collect{|baby| baby.person_id if (!baby.delivery_outcome.match(/Alive/i)) && !baby.gender.match(/F/i)}.compact.uniq
    @discharge_outcome["MALE_STILL"] = @delivery_mode["MALE_FRESH"] + @delivery_mode["MALE_MAC"]
    @discharge_outcome["MALE_NEO"] = @delivery_mode["MALE_NEO"]
    @discharge_outcome["MALE_NOT_DISCHARGED"] = (@gender["MALES"] - (@discharge_outcome["MALE_ALIVE"] + @discharge_outcome["MALE_DEAD"])).uniq

    @discharge_outcome["F_ALIVE"] = @total_babies.collect{|baby| baby.person_id if (baby.discharge_outcome.match(/Alive/i) rescue false) && baby.gender.match(/F/i)}.compact.uniq
    @discharge_outcome["F_DEAD"] = @total_babies.collect{|baby| baby.person_id if (!baby.delivery_outcome.match(/Alive/i)) && baby.gender.match(/F/i)}.compact.uniq
    @discharge_outcome["F_STILL"] = @delivery_mode["F_FRESH"] + @delivery_mode["F_MAC"]
    @discharge_outcome["F_NEO"] = @delivery_mode["F_NEO"]
    @discharge_outcome["F_NOT_DISCHARGED"] = (@gender["FEMALES"] - (@discharge_outcome["F_ALIVE"] + @discharge_outcome["F_DEAD"])).uniq

    #cumulative discharges
    @cdischarge_outcome = {}
    @cdischarge_outcome["MALE_ALIVE"] = @ctotal_babies.collect{|baby| baby.person_id if (baby.discharge_outcome.match(/Alive/i) rescue false) && !baby.gender.match(/F/i)}.compact.uniq
    @cdischarge_outcome["MALE_DEAD"] = @ctotal_babies.collect{|baby| baby.person_id if (!baby.delivery_outcome.match(/Alive/i)) && !baby.gender.match(/F/i)}.compact.uniq
    @cdischarge_outcome["MALE_STILL"] = @cdelivery_mode["MALE_FRESH"] + @cdelivery_mode["MALE_MAC"]
    @cdischarge_outcome["MALE_NEO"] = @cdelivery_mode["MALE_NEO"]
    @cdischarge_outcome["MALE_NOT_DISCHARGED"] = (@cgender["MALES"] - (@cdischarge_outcome["MALE_ALIVE"] + @cdischarge_outcome["MALE_DEAD"])).uniq

    @cdischarge_outcome["F_ALIVE"] = @ctotal_babies.collect{|baby| baby.person_id if (baby.discharge_outcome.match(/Alive/i) rescue false) && baby.gender.match(/F/i)}.compact.uniq
    @cdischarge_outcome["F_DEAD"] = @ctotal_babies.collect{|baby| baby.person_id if (!baby.delivery_outcome.match(/Alive/i)) && baby.gender.match(/F/i)}.compact.uniq
    @cdischarge_outcome["F_STILL"] = @cdelivery_mode["F_FRESH"] + @cdelivery_mode["F_MAC"]
    @cdischarge_outcome["F_NEO"] = @cdelivery_mode["F_NEO"]
    @cdischarge_outcome["F_NOT_DISCHARGED"] = (@cgender["FEMALES"] - (@cdischarge_outcome["F_ALIVE"] + @cdischarge_outcome["F_DEAD"])).uniq

    @weights = {}
    @weights["MALE_LOW"] = @total_babies.collect{|baby| baby.person_id if ((baby.birth_weight.to_i != 0 && baby.birth_weight.to_i < 2500) rescue false) && !baby.gender.match(/F/i)}.compact.uniq
    @weights["MALE_NORMAL"] = @total_babies.collect{|baby| baby.person_id if ((baby.birth_weight.to_i >= 2500 && baby.birth_weight.to_i <= 4500) rescue false) && !baby.gender.match(/F/i)}.compact.uniq
    @weights["MALE_HIGH"] = @total_babies.collect{|baby| baby.person_id if ((baby.birth_weight.to_i > 4500) rescue false) && !baby.gender.match(/F/i)}.compact.uniq
    @weights["MALE_UNKNOWN"] =  (@gender["MALES"] - (@weights["MALE_LOW"] + @weights["MALE_NORMAL"] + @weights["MALE_HIGH"])).uniq

    @weights["FE_LOW"] = @total_babies.collect{|baby| baby.person_id if ((baby.birth_weight.to_i != 0 && baby.birth_weight.to_i < 2500) rescue false) && baby.gender.match(/F/i)}.compact.uniq
    @weights["FE_NORMAL"] = @total_babies.collect{|baby| baby.person_id if ((baby.birth_weight.to_i >= 2500 && baby.birth_weight.to_i <= 4500) rescue false) && baby.gender.match(/F/i)}.compact.uniq
    @weights["FE_HIGH"] = @total_babies.collect{|baby| baby.person_id if ((baby.birth_weight.to_i > 4500) rescue false) && baby.gender.match(/F/i)}.compact.uniq
    @weights["FE_UNKNOWN"] = (@gender["FEMALES"] - (@weights["FE_LOW"] + @weights["FE_NORMAL"] + @weights["FE_HIGH"])).uniq

    #weight for cumulative outcomes
    @cweights = {}
    @cweights["MALE_LOW"] = @ctotal_babies.collect{|baby| baby.person_id if ((baby.birth_weight.to_i != 0 && baby.birth_weight.to_i < 2500) rescue false) && !baby.gender.match(/F/i)}.compact.uniq
    @cweights["MALE_NORMAL"] = @ctotal_babies.collect{|baby| baby.person_id if ((baby.birth_weight.to_i >= 2500 && baby.birth_weight.to_i <= 4500) rescue false) && !baby.gender.match(/F/i)}.compact.uniq
    @cweights["MALE_HIGH"] = @ctotal_babies.collect{|baby| baby.person_id if ((baby.birth_weight.to_i > 4500) rescue false) && !baby.gender.match(/F/i)}.compact.uniq
    @cweights["MALE_UNKNOWN"] =  (@cgender["MALES"] - (@cweights["MALE_LOW"] + @cweights["MALE_NORMAL"] + @cweights["MALE_HIGH"])).uniq

    @cweights["FE_LOW"] = @ctotal_babies.collect{|baby| baby.person_id if ((baby.birth_weight.to_i != 0 && baby.birth_weight.to_i < 2500) rescue false) && baby.gender.match(/F/i)}.compact.uniq
    @cweights["FE_NORMAL"] = @ctotal_babies.collect{|baby| baby.person_id if ((baby.birth_weight.to_i >= 2500 && baby.birth_weight.to_i <= 4500) rescue false) && baby.gender.match(/F/i)}.compact.uniq
    @cweights["FE_HIGH"] = @ctotal_babies.collect{|baby| baby.person_id if ((baby.birth_weight.to_i > 4500) rescue false) && baby.gender.match(/F/i)}.compact.uniq
    @cweights["FE_UNKNOWN"] = (@cgender["FEMALES"] - (@cweights["FE_LOW"] + @cweights["FE_NORMAL"] + @cweights["FE_HIGH"])).uniq

    # for the report drill down
    result = {}
    result["discharges"] = @discharge_outcome
    result["deliveries"] = @delivery_mode
    result["gender"] = @gender
    result["admissions"] = @total_admissions
    result["apgar1"] = @apgar1
    result["apgar2"] = @apgar2
    result["total_babies_born"] = @total_babies_born
    result["birth_report_status"] = @birth_report_status
    result["delivery_weeks"] = @delivery_weeks

    #cumulative figures
    result["cdischarges"] = @cdischarge_outcome
    result["cdeliveries"] = @cdelivery_mode
    result["cgender"] = @cgender
    result["cadmissions"] = @ctotal_admissions
    result["capgar1"] = @capgar1
    result["capgar2"] = @capgar2
    result["ctotal_babies_born"] = @ctotal_babies_born
    result["cbirth_report_status"] = @cbirth_report_status
    result["cdelivery_weeks"] = @cdelivery_weeks

    session[:drill_down_data] = result

    render :layout => false
  end

  def baby_matrix
		#render :layout => false
	end

	def baby_matrix_printable
		render :layout => false
	end

  def matrix_q
    case params[:field]
    when "lessorequal1499_macerated"
      lessorequal1499(params[:start_date].to_date, params[:end_date].to_date, 'Macerated Still birth')
    when "lessorequal1499_fresh"
      lessorequal1499(params[:start_date].to_date, params[:end_date].to_date, 'Fresh Still birth')
    when "lessorequal1499_predischarge"
      lessorequal1499_predischarge(params[:start_date].to_date, params[:end_date].to_date)
    when "lessorequal1499_aliveatdischarge"
      lessorequal1499_aliveatdischarge(params[:start_date].to_date, params[:end_date].to_date)
    when "lessorequal1499_missingoutcomes"
      lessorequal1499_missingoutcomes(params[:start_date].to_date, params[:end_date].to_date)
    when "lessorequal1499_total"
      lessorequal1499_total(params[:start_date].to_date, params[:end_date].to_date)
    when "1500-2499_macerated"
      from1500to2499(params[:start_date].to_date, params[:end_date].to_date, 'Macerated Still birth')
    when "1500-2499_fresh"
      from1500to2499(params[:start_date].to_date, params[:end_date].to_date, 'Fresh Still birth')
    when "1500-2499_predischarge"
      from1500to2499_predischarge(params[:start_date].to_date, params[:end_date].to_date)
    when "1500-2499_aliveatdischarge"
      from1500to2499_aliveatdischarge(params[:start_date].to_date, params[:end_date].to_date)
    when "1500-2499_missingoutcomes"
      from1500to2499_missingoutcomes(params[:start_date].to_date, params[:end_date].to_date)
    when "1500-2499_total"
      from1500to2499_total(params[:start_date].to_date, params[:end_date].to_date)
    when "greaterorequal2500_macerated"
      greaterorequal2500(params[:start_date].to_date, params[:end_date].to_date, 'Macerated Still birth')
    when "greaterorequal2500_fresh"
      greaterorequal2500(params[:start_date].to_date, params[:end_date].to_date, 'Fresh Still birth')
    when "greaterorequal2500_predischarge"
      greaterorequal2500_predischarge(params[:start_date].to_date, params[:end_date].to_date)
    when "greaterorequal2500_aliveatdischarge"
      greaterorequal2500_aliveatdischarge(params[:start_date].to_date, params[:end_date].to_date)
    when "greaterorequal2500_missingoutcomes"
      greaterorequal2500_missingoutcomes(params[:start_date].to_date, params[:end_date].to_date)
    when "greaterorequal2500_total"
      greaterorequal2500_total(params[:start_date].to_date, params[:end_date].to_date)
    when "missingweights_macerated"
      missingweights(params[:start_date].to_date, params[:end_date].to_date, 'Macerated Still birth')
    when "missingweights_fresh"
      missingweights(params[:start_date].to_date, params[:end_date].to_date, 'Fresh Still birth')
    when "missingweights_predischarge"
      missingweights_predischarge(params[:start_date].to_date, params[:end_date].to_date)
    when "missingweights_aliveatdischarge"
      missingweights_aliveatdischarge(params[:start_date].to_date, params[:end_date].to_date)
    when "missingweights_missingoutcomes"
      missingweights_missingoutcomes(params[:start_date].to_date, params[:end_date].to_date)
    when "missingweights_total"
      missingweights_total(params[:start_date].to_date, params[:end_date].to_date)
    when "total_macerated"
      total(params[:start_date].to_date, params[:end_date].to_date, 'Macerated Still birth')
    when "total_fresh"
      total(params[:start_date].to_date, params[:end_date].to_date, 'Fresh Still birth')
    when "total_predischarge"
      total_predischarge(params[:start_date].to_date, params[:end_date].to_date)
    when "total_aliveatdischarge"
      total_aliveatdischarge(params[:start_date].to_date, params[:end_date].to_date)
    when "total_missingoutcomes"
      total_missingoutcomes(params[:start_date].to_date, params[:end_date].to_date)
    when "total_total"
      total_total(params[:start_date].to_date, params[:end_date].to_date)
    end
  end

	def lessorequal1499(startdate = Time.now, enddate = Time.now, field = 'blank')
    babies = []

    @concepts = ['BABY OUTCOME'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND o.value_coded = (SELECT concept_id FROM concept_name WHERE name = '#{field}' LIMIT 1)").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight <= 1499)
    end

    babies.delete_if{|baby| baby.blank?}
    render :text => babies.uniq.to_json
	end

  def lessorequal1499_neonatal(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }

    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded IN (#{@values_coded}) OR o.value_text IN ('Dead'))").each do |data|


      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight  and (weight <= 1499)
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("BABY OUTCOME").concept_id]).answer_string.blank? rescue false)
    }

    babies
	end

	def lessorequal1499_predischarge(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Dead'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }

    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded IN (#{@values_coded}) OR o.value_text IN ('Dead'))").each do |data|


      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight  and (weight <= 1499)
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }

    neo = lessorequal1499_neonatal(startdate, enddate) rescue []
    babies = babies.concat(neo)

    render :text => babies.uniq.to_json
	end

	def lessorequal1499_aliveatdischarge(startdate = Time.now, enddate = Time.now)
    babies = []

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id = (SELECT concept_id FROM concept_name WHERE name = 'STATUS OF BABY')
				AND o.voided = 0
				AND o.value_coded = (SELECT concept_id FROM concept_name WHERE name = 'Alive' LIMIT 1)").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight <= 1499)
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    render :text => babies.uniq.to_json
	end

  def lessorequal1499_alive_predischarge(startdate = Time.now, enddate = Time.now)
    babies = []
    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id = (SELECT concept_id FROM concept_name WHERE name = 'BABY OUTCOME')
				AND o.voided = 0
        AND (SELECT COUNT(*) FROM obs WHERE person_id = r.person_b AND voided = 0
            AND concept_id = (SELECT concept_id FROM concept_name WHERE name = 'STATUS OF BABY' LIMIT 1)) = 0
				AND o.value_coded IN (SELECT concept_id FROM concept_name WHERE name = 'Alive')").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight <= 1499)
    end

    babies.delete_if{|baby| baby.blank? }
    babies
	end

  def lessorequal1499_missingoutcomes(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death', 'Fresh still birth', 'Macerated still birth', 'Intrauterine death', 'Alive'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded NOT IN (#{@values_coded})
								OR (SELECT COUNT(*) FROM obs WHERE person_id = r.person_b AND concept_id = (SELECT concept_id FROM concept_name WHERE name = 'BABY OUTCOME')) = 0
	)").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight <= 1499)
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    render :text => babies.uniq.to_json
  end

  def lessorequal1499_total(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death', 'Fresh still birth', 'Macerated still birth', 'Intrauterine death', 'Alive'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME', 'STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.voided = 0
				AND o.concept_id IN (#{@concepts_coded})").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil
      babies << data.person_b if weight and (weight <= 1499)
    end

    alive_without_discharge = lessorequal1499_alive_predischarge(startdate, enddate) rescue []

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    babies = babies - alive_without_discharge
    render :text => babies.uniq.to_json
  end

  def from1500to2499(startdate = Time.now, enddate = Time.now, field = 'blank')
    babies = []

    @concepts = ['BABY OUTCOME', 'STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND o.value_coded = (SELECT concept_id FROM concept_name WHERE name = '#{field}' LIMIT 1)").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 1499) and (weight <= 2499)
    end

    babies.delete_if{|baby| baby.blank?}
    render :text => babies.uniq.to_json
  end

  def from1500to2499_neonatal(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }

    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded IN (#{@values_coded}) OR o.value_text IN ('Dead'))").each do |data|


      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 1499) and (weight <= 2499)
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("BABY OUTCOME").concept_id]).answer_string.blank? rescue false)
    }

    babies
  end

  def from1500to2499_predischarge(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Dead'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded IN (#{@values_coded}) OR o.value_text IN ('Dead'))").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 1499) and (weight <= 2499)
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    neo = from1500to2499_neonatal(startdate, enddate)
    babies = babies.concat(neo)
    render :text => babies.uniq.to_json
  end

  def from1500to2499_alive_predischarge(startdate = Time.now, enddate = Time.now)
    babies = []
    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id = (SELECT concept_id FROM concept_name WHERE name = 'BABY OUTCOME')
				AND o.voided = 0
        AND (SELECT COUNT(*) FROM obs WHERE person_id = r.person_b AND voided = 0
            AND concept_id = (SELECT concept_id FROM concept_name WHERE name = 'STATUS OF BABY' LIMIT 1)) = 0
				AND o.value_coded IN (SELECT concept_id FROM concept_name WHERE name = 'Alive')").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 1499) and (weight <= 2499)
    end

    babies.delete_if{|baby| baby.blank? }
    babies
	end

  def from1500to2499_aliveatdischarge(startdate = Time.now, enddate = Time.now)
    babies = []

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id = (SELECT concept_id FROM concept_name WHERE name = 'STATUS OF BABY')
				AND o.voided = 0
				AND o.value_coded = (SELECT concept_id FROM concept_name WHERE name = 'Alive' LIMIT 1)").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 1499) and (weight <= 2499)
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    render :text => babies.uniq.to_json
  end

  def from1500to2499_missingoutcomes(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death', 'Fresh still birth', 'Macerated still birth', 'Intrauterine death', 'Alive'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded NOT IN (#{@values_coded})
								OR (SELECT COUNT(*) FROM obs WHERE person_id = r.person_b AND concept_id = (SELECT concept_id FROM concept_name WHERE name = 'BABY OUTCOME')) = 0
	)").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 1499) and (weight <= 2499)
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    render :text => babies.uniq.to_json
  end

  def from1500to2499_total(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death', 'Fresh still birth', 'Macerated still birth', 'Intrauterine death', 'Alive'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME', 'STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.voided = 0
				AND o.concept_id IN (#{@concepts_coded})").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 1499) and (weight <= 2499)
    end

    alive_without_discharge = from1500to2499_alive_predischarge(startdate, enddate) rescue []
    babies = babies - alive_without_discharge

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    render :text => babies.uniq.to_json
  end

  def greaterorequal2500(startdate = Time.now, enddate = Time.now, field = 'blank')
    babies = []

    @concepts = ['BABY OUTCOME', 'STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND o.value_coded = (SELECT concept_id FROM concept_name WHERE name = '#{field}' LIMIT 1)").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 2499)
    end

    babies.delete_if{|baby| baby.blank?}
    render :text => babies.uniq.to_json
  end

  def greaterorequal2500_neonatal(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }

    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded IN (#{@values_coded}) OR o.value_text IN ('Dead'))").each do |data|


      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 2499)
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("BABY OUTCOME").concept_id]).answer_string.blank? rescue false)
    }

    babies
  end

  def greaterorequal2500_predischarge(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Dead'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded IN (#{@values_coded}) OR o.value_text IN ('Dead'))").each do |data|


      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 2499)
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }

    neo = greaterorequal2500_neonatal(startdate, enddate)
    babies = babies.concat(neo)
    render :text => babies.uniq.to_json
  end

  def greaterorequal2500_aliveatdischarge(startdate = Time.now, enddate = Time.now)
    babies = []

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id = (SELECT concept_id FROM concept_name WHERE name = 'STATUS OF BABY')
				AND o.voided = 0
				AND o.value_coded = (SELECT concept_id FROM concept_name WHERE name = 'Alive' LIMIT 1)").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 2499)
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    render :text => babies.uniq.to_json
  end

  def greaterorequal2500_missingoutcomes(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death', 'Fresh still birth', 'Macerated still birth', 'Intrauterine death', 'Alive'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded NOT IN (#{@values_coded})
								OR (SELECT COUNT(*) FROM obs WHERE person_id = r.person_b AND concept_id = (SELECT concept_id FROM concept_name WHERE name = 'BABY OUTCOME')) = 0
	)").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 2499)
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    render :text => babies.uniq.to_json
  end

  def greaterorequal2500_alive_predischarge(startdate = Time.now, enddate = Time.now)
    babies = []
    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id = (SELECT concept_id FROM concept_name WHERE name = 'BABY OUTCOME')
				AND o.voided = 0
        AND (SELECT COUNT(*) FROM obs WHERE person_id = r.person_b AND voided = 0
            AND concept_id = (SELECT concept_id FROM concept_name WHERE name = 'STATUS OF BABY' LIMIT 1)) = 0
				AND o.value_coded IN (SELECT concept_id FROM concept_name WHERE name = 'Alive')").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil
      babies << data.person_b if weight and (weight >= 2500)
    end

    babies.delete_if{|baby| baby.blank? }
    babies
	end

  def greaterorequal2500_total(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death', 'Fresh still birth', 'Macerated still birth', 'Intrauterine death', 'Alive'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"


    @concepts = ['BABY OUTCOME', 'STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.voided = 0
				AND o.concept_id IN (#{@concepts_coded})").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight and (weight > 2499)
    end

    alive_without_discharge = greaterorequal2500_alive_predischarge(startdate, enddate) rescue []
    babies = babies - alive_without_discharge

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    render :text => babies.uniq.to_json
  end

  def missingweights(startdate = Time.now, enddate = Time.now, field = 'blank')
    babies = []

    @concepts = ['BABY OUTCOME', 'STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND o.value_coded = (SELECT concept_id FROM concept_name WHERE name = '#{field}' LIMIT 1)").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight.blank?
    end

    babies.delete_if{|baby| baby.blank?}
    render :text => babies.uniq.to_json
  end

  def missingweights_neonatal(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }

    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded IN (#{@values_coded}) OR o.value_text IN ('Dead'))").each do |data|


      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight.blank?
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("BABY OUTCOME").concept_id]).answer_string.blank? rescue false)
    }

    babies
  end

  def missingweights_predischarge(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Dead'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded IN (#{@values_coded}) OR o.value_text IN ('Dead'))").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight.blank?
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    neo = missingweights_neonatal(startdate, enddate) rescue []
    babies = babies.concat(neo)
    render :text => babies.uniq.to_json
  end

  def missingweights_aliveatdischarge(startdate = Time.now, enddate = Time.now)
    babies = []

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id = (SELECT concept_id FROM concept_name WHERE name = 'STATUS OF BABY')
				AND o.voided = 0
				AND o.value_coded = (SELECT concept_id FROM concept_name WHERE name = 'Alive' LIMIT 1)").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight.blank?
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    render :text => babies.uniq.to_json
  end

  def missingweights_missingoutcomes(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death', 'Fresh still birth', 'Macerated still birth', 'Intrauterine death', 'Alive'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded NOT IN (#{@values_coded})
								OR (SELECT COUNT(*) FROM obs WHERE person_id = r.person_b AND concept_id = (SELECT concept_id FROM concept_name WHERE name = 'BABY OUTCOME')) = 0
	)").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight.blank?
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    render :text => babies.uniq.to_json
  end


  def missingweights_alive_predischarge(startdate = Time.now, enddate = Time.now)
    babies = []
    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id = (SELECT concept_id FROM concept_name WHERE name = 'BABY OUTCOME')
				AND o.voided = 0
        AND (SELECT COUNT(*) FROM obs WHERE person_id = r.person_b AND voided = 0
            AND concept_id = (SELECT concept_id FROM concept_name WHERE name = 'STATUS OF BABY' LIMIT 1)) = 0
				AND o.value_coded IN (SELECT concept_id FROM concept_name WHERE name = 'Alive')").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil
      babies << data.person_b if weight.blank?
    end

    babies.delete_if{|baby| baby.blank? }
    babies
	end

  def missingweights_total(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death', 'Fresh still birth', 'Macerated still birth', 'Intrauterine death', 'Alive'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME', 'STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.voided = 0
				AND o.concept_id IN (#{@concepts_coded})").each do |data|

      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b if weight.blank?
    end

    alive_without_discharge = missingweights_alive_predischarge(startdate, enddate)
    babies  = babies - alive_without_discharge
    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    render :text => babies.uniq.to_json
  end

  def total(startdate = Time.now, enddate = Time.now, field = 'blank')
    babies = []

    @concepts = ['BABY OUTCOME', 'STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.voided = 0
				AND o.concept_id IN (#{@concepts_coded})
				AND o.value_coded = (SELECT concept_id FROM concept_name WHERE name = '#{field}' LIMIT 1)").each do |data|

      babies << data.person_b
    end

    babies.delete_if{|baby| baby.blank?}
    render :text => babies.uniq.to_json
  end

  def total_neonatal(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }

    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded IN (#{@values_coded}) OR o.value_text IN ('Dead'))").each do |data|


      weight = Observation.find(:last,
        :conditions => ["person_id = ? AND concept_id = ?",
          data.person_b, ConceptName.find_by_name("BIRTH WEIGHT").concept_id]).answer_string.to_i  rescue nil

      babies << data.person_b
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("BABY OUTCOME").concept_id]).answer_string.blank? rescue false)
    }

    babies
  end

  def total_predischarge(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Dead'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded IN (#{@values_coded}) OR o.value_text IN ('Dead'))").each do |data|


      babies << data.person_b
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    neo = total_neonatal(startdate, enddate) rescue []
    babies = babies.concat(neo)
    render :text => babies.uniq.to_json
  end

  def total_aliveatdischarge(startdate = Time.now, enddate = Time.now)
    babies = []

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id = (SELECT concept_id FROM concept_name WHERE name = 'STATUS OF BABY')
				AND o.voided = 0
				AND o.value_coded = (SELECT concept_id FROM concept_name WHERE name = 'Alive' LIMIT 1)").each do |data|
      babies << data.person_b
    end

    babies.delete_if{|baby|
      baby.blank? or (Observation.find(:last, :conditions => ["person_id = ? AND concept_id = ?",
            baby, ConceptName.find_by_name("STATUS OF BABY").concept_id]).answer_string.blank? rescue false)
    }
    render :text => babies.uniq.to_json
  end

  def total_missingoutcomes(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death', 'Fresh still birth', 'Macerated still birth', 'Intrauterine death', 'Alive'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id IN (#{@concepts_coded})
				AND o.voided = 0
				AND (o.value_coded NOT IN (#{@values_coded})
								OR (SELECT COUNT(*) FROM obs WHERE person_id = r.person_b AND concept_id = (SELECT concept_id FROM concept_name WHERE name = 'BABY OUTCOME')) = 0
	)").each do |data|

      babies << data.person_b

    end

    babies.delete_if{|baby|
      baby.blank?
    }
    render :text => babies.uniq.to_json
  end

  def total_alive_predischarge(startdate = Time.now, enddate = Time.now)
    babies = []
    Relationship.find_by_sql("SELECT r.person_b FROM relationship r JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.concept_id = (SELECT concept_id FROM concept_name WHERE name = 'BABY OUTCOME')
				AND o.voided = 0
        AND (SELECT COUNT(*) FROM obs WHERE person_id = r.person_b AND voided = 0
            AND concept_id = (SELECT concept_id FROM concept_name WHERE name = 'STATUS OF BABY' LIMIT 1)) = 0
				AND o.value_coded IN (SELECT concept_id FROM concept_name WHERE name = 'Alive')").each do |data|

      babies << data.person_b
    end

    babies.delete_if{|baby| baby.blank? }
    babies
	end

  def total_total(startdate = Time.now, enddate = Time.now)
    babies = []

    @values = ['Neonatal death', 'Fresh still birth', 'Macerated still birth', 'Intrauterine death', 'Alive'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @values_coded = "'" + @values.join("','") + "'"

    @concepts = ['BABY OUTCOME', 'STATUS OF BABY'].collect{
      |val| ConceptName.find_by_name(val).concept_id
    }
    @concepts_coded = "'" + @concepts.join("','") + "'"

    Relationship.find_by_sql("SELECT r.person_b FROM relationship r
			  JOIN obs o ON o.person_id = r.person_b
				WHERE r.voided = 0 AND r.relationship = (SELECT relationship_type_id FROM relationship_type WHERE a_is_to_b = 'Parent' AND b_is_to_a = 'Child')
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') <= '#{enddate}'
				AND DATE_FORMAT((SELECT birthdate FROM person WHERE person_id = r.person_b), '%Y-%m-%d') >= '#{startdate}'
				AND o.voided = 0
				AND o.concept_id IN (#{@concepts_coded})").each do |data|

      babies << data.person_b
    end

    alive_without_discharge = total_alive_predischarge(startdate, enddate)
    babies = babies - alive_without_discharge

    babies.delete_if{|baby|
      baby.blank?
    }

    render :text => babies.uniq.to_json
  end

  def print_csv

    csv_arr = params["print_string"].split(",,")

    csv_string = ""

    csv_arr.each do |row|

      csv_string +=  "#{row}\n"

    end

    send_data(csv_string,
      :type => 'text/csv; charset=utf-8;',
      :stream=> false,
      :disposition => 'inline',
      :filename => "babies_matrix.csv") and return
  end

  def decompose
    
    @facility = get_global_property_value("facility.name")

    @patients = []

    if params[:patients]
      new_women = params[:patients].split(",")
      @patients = Patient.find(:all, :conditions => ["patient_id IN (?)", new_women])
    end

    render :layout => false
  end

  def matrix_decompose
		@patients = Patient.find(:all, :conditions => ["patient_id IN (?)", params[:patients].split(",")])
		render :layout => false
  end
 
end
