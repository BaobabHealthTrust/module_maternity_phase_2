class ReportController < ApplicationController

  def report_limits
 
    @type = params["type"]
  
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

    @complications = report.complications

    @obst_complications = report.obst_complications

    @vitaminA_given = report.vitaminA_given

    @pmtct_survival = report.pmtct_survival

    @twins = report.twins
    
  end

  def decompose
    # raise params.to_yaml
    @facility = get_global_property_value("facility.name")

    @patients = []

    if params[:patients]
      new_women = params[:patients].split(",")
      @patients = Patient.find(:all, :conditions => ["patient_id IN (?)", new_women])
    end

    # raise @patients.length.to_yaml

    render :layout => false
  end
 
end
