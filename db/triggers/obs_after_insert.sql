DELIMITER $$
DROP TRIGGER IF EXISTS `obs_after_insert`$$
CREATE TRIGGER `obs_after_insert` AFTER INSERT 
ON `obs`
FOR EACH ROW
BEGIN
	SET @type = (SELECT name FROM encounter_type WHERE encounter_type_id = (SELECT encounter_type FROM encounter WHERE encounter_id = new.encounter_id));
	SET @outcometype = (SELECT name FROM encounter_type WHERE encounter_type_id = (SELECT encounter_type FROM encounter WHERE encounter_id = new.encounter_id));

  	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "BABY OUTCOME" LIMIT 1) AND @type = "BABY DELIVERY" THEN
		SET @outcome = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, baby_outcome, baby_outcome_date, obs_datetime, obs_id) VALUES(new.person_id, @outcome, new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "DELIVERY MODE" LIMIT 1) AND @type = "BABY DELIVERY" THEN
		SET @mode = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, delivery_mode, delivery_date, obs_datetime, obs_id) VALUES(new.person_id, @mode, new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "NUMBER OF BABIES" LIMIT 1) AND @type = "UPDATE OUTCOME" THEN
		SET @mode = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	
		SET @existing = (SELECT COUNT(*) FROM patient_report WHERE birthdate >= DATE_ADD(new.obs_datetime, INTERVAL -7 DAY) AND birthdate <= DATE_ADD(new.obs_datetime, INTERVAL 7 DAY) AND patient_id = new.person_id AND COALESCE(babies, '') != '');

		IF @existing <= 0 THEN
	 		INSERT INTO patient_report (patient_id, babies, birthdate, obs_datetime, obs_id) VALUES(new.person_id, @mode, new.obs_datetime, new.obs_datetime, new.obs_id);
		END IF;
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "NUMBER OF BABIES" LIMIT 1) AND @type = "CURRENT BBA DELIVERY" THEN
		SET @mode = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, bba_babies, bba_date, obs_datetime, obs_id) VALUES(new.person_id, @mode, new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "OUTCOME" LIMIT 1) AND @type != "CURRENT BBA DELIVERY" AND @outcometype = "UPDATE OUTCOME" THEN
		SET @mode = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, outcome, outcome_date, obs_datetime, obs_id) VALUES(new.person_id, @mode, new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;
	
		
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "DIAGNOSIS ON DISCHARGE" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "ADMISSION DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);

  		INSERT INTO patient_report (patient_id, diagnosis, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "HYSTERECTOMY DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "HYSTERECTOMY", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;	

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "LAPARATOMY DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "LAPARATOMY", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;	

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "DILATION AND CURETTAGE DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "DILATION AND CURETTAGE", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;	

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "EVACUATION/MVA DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "Evacuation/Manual Vacuum Aspiration", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "EXAM UNDER ANAESTHESIA DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "Exam Under Anaesthesia", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "CAESAREAN SECTION DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "Caesarean Section", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "INCISION AND DRAINAGE DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "Incision And Drainage", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "BIOPSY DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "Biopsy", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "EXCISION DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "Excision", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "MALSUPILISATION DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "Malsupilisation", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "CYSTECTOMY DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "Cystectomy", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "CECLAGE DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "Ceclage", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "MYOMECTOMY DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "Myomectomy", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

        IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "BILATERAL TUBAL LIGATION DIAGNOSIS" LIMIT 1) THEN
		SET @diagnosis = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, diagnosis, procedure_done, diagnosis_date, obs_datetime, obs_id) VALUES(new.person_id, @diagnosis, "Bilateral Tubal Ligation", new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;

	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "ADMISSION SECTION" LIMIT 1) AND COALESCE(new.comments, '') != '' THEN
			SET @ward = (SELECT name FROM location WHERE location_id = new.comments LIMIT 1);

  		INSERT INTO patient_report (patient_id, source_ward, destination_ward, internal_transfer_date, obs_datetime, obs_id) VALUES(new.person_id, @ward, new.value_text, new.obs_datetime, new.obs_datetime, new.obs_id);

		UPDATE patient_report SET last_ward_where_seen = new.value_text, last_ward_where_seen_date = new.obs_datetime WHERE COALESCE(delivery_mode,'') != '' AND patient_id = new.person_id AND delivery_date >= DATE_ADD(new.obs_datetime, INTERVAL -7 DAY) AND delivery_date <= DATE_ADD(new.obs_datetime, INTERVAL 7 DAY);

        END IF;

	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "ADMISSION SECTION" LIMIT 1) THEN
		SET @ward = (SELECT name FROM location WHERE location_id = new.location_id LIMIT 1);	

  		INSERT INTO patient_report (patient_id, admission_ward, admission_date, obs_datetime, obs_id) VALUES(new.person_id, @ward, new.value_datetime, new.value_datetime, new.obs_id);
	END IF;

        IF (new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "ADMISSION TIME" LIMIT 1)) AND (UPPER(@type) = "OBSERVATIONS") THEN
		INSERT INTO patient_report (patient_id, admission_date, obs_datetime, obs_id) VALUES(new.person_id, new.value_datetime, new.value_datetime, new.obs_id);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "IS PATIENT REFERRED?" LIMIT 1) AND new.value_coded IN (SELECT concept_id FROM concept_name WHERE name = "Yes") THEN

  		INSERT INTO patient_report (patient_id, referral_in, obs_datetime, obs_id) VALUES(new.person_id, new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "OUTCOME" LIMIT 1) AND new.value_text = "REFERRED OUT" THEN

  		INSERT INTO patient_report (patient_id, referral_out, obs_datetime, obs_id) VALUES(new.person_id, new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "PROCEDURE DONE" LIMIT 1) THEN
		SET @procedure = (SELECT name FROM concept_name WHERE concept_name_id = new.value_coded_name_id);	

  		INSERT INTO patient_report (patient_id, procedure_done, procedure_date, obs_datetime, obs_id) VALUES(new.person_id, @procedure, new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "CLINIC SITE OTHER" LIMIT 1) AND new.value_coded IN (SELECT concept_id FROM concept_name WHERE name = "No") THEN

  		INSERT INTO patient_report (patient_id, discharged_home, obs_datetime, obs_id) VALUES(new.person_id, new.obs_datetime, new.obs_datetime, new.obs_id);
	END IF;
	
	IF new.concept_id = (SELECT concept_id FROM concept_name WHERE name = "OUTCOME" LIMIT 1) AND new.value_coded = (SELECT concept_id FROM concept_name WHERE name = "DISCHARGED" LIMIT 1) THEN
      SET @ward = (SELECT name FROM location WHERE location_id = new.location_id);
      
  		INSERT INTO patient_report (patient_id, discharged, discharge_ward, obs_datetime, obs_id) VALUES(new.person_id, new.obs_datetime, @ward, new.obs_datetime, new.obs_id);
	END IF;
	
END$$

DELIMITER ;
