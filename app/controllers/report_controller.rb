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
