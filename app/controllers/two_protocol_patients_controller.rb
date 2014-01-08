
class TwoProtocolPatientsController < ApplicationController
	unloadable

	before_filter :check_user

	def discharged

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def baby_discharge_outcome

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def baby_delivery

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def referred_out

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def post_natal_patient_history

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def ante_natal_vaginal_examination

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def ante_natal_vitals

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def give_drugs

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def ante_natal_notes

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def post_natal_vaginal_examination

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def baby_historical_outcome

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def admit_to_ward

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def admission_diagnosis

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def admit_patient

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def social_history

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def update_outcome_mum

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def update_outcome

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def refer_baby

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def gynaecology_notes

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def general_body_exam

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def ante_natal_pmtct

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def ante_natal_patient_history

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def post_natal_vitals

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def kangaroo_review_visit

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def delivered

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def admit_baby

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def patient_died

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def post_natal_admission_details

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def abdominal_examination

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def post_natal_notes

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def baby_outcomes

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def delivery_procedures

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def post_natal_exams

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def referral

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def post_natal_pmtct

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def ante_natal_exams

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def notes

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def ante_natal_admission_details

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def baby_examination

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def gynaecology_vitals

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def absconded

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def physical_exam

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def mother_delivery_details

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

	def gynaecology_admission_details

	@patient = Patient.find(params[:patient_id]) rescue nil

	@session_date = session[:datetime] rescue nil 

	redirect_to '/encounters/no_patient' and return if @patient.nil?

	if params[:user_id].nil?
	redirect_to '/encounters/no_user' and return
	end

	@user = User.find(params[:user_id]) rescue nil?

	redirect_to '/encounters/no_patient' and return if @user.nil?
	

	end

end
