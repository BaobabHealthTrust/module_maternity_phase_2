
class MaternityController < ApplicationController

  def baby_wrist_band_label
    print_string = Baby.baby_wrist_band_barcode_label(params[:baby_id], params[:mother_id]) rescue (raise "Unable to find patient (#{params[:baby_id]}) or generate a baby wrist band label for that baby")
    
    send_data(print_string,
      :type=>"application/label; charset=utf-8",
      :stream=> false,
      :filename=>"#{params[:patient_id]}#{rand(10000)}.bcs",
      :disposition => "inline")
  end

  def mother_wrist_band_label
    print_string = Baby.mother_wrist_band_barcode_label(params[:patient_id], 
      params[:ward], params[:provider],
      (session[:date_time] || Date.today)) rescue (raise "Unable to find patient (#{params[:baby_id]}) or generate a baby wrist band label for that baby")

    send_data(print_string,
      :type=>"application/label; charset=utf-8",
      :stream=> false,
      :filename=>"#{params[:patient_id]}#{rand(10000)}.bcl",
      :disposition => "inline")
  end

end