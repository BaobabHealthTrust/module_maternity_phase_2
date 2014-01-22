P.1. PROCEDURES DONE [program: MATERNITY PROGRAM, scope: TODAY, label: Theater Procedures, pos: 158, concept: Treatment Group]
C.1.1. Given a registered patient in theater 

Q.1.1.1. Procedure Done [name: concept[Procedure Done], concept: Procedure done, pos: 0, optional: true, field_type: text, ajaxURL: /encounters/concept_set_options?set=procedure_done&search_string=]

Q.1.1.2. Reason For Procedure [name: concept[HYSTERECTOMY DIAGNOSIS][], concept: HYSTERECTOMY DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "HYSTERECTOMY", pos: 1, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=hysterectomy&search_string=]

Q.1.1.3. Reason For Procedure [name: concept[BIOPSY DIAGNOSIS][], concept: BIOPSY DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "BIOPSY", pos: 2, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=biopsy&search_string=]

Q.1.1.4. Reason For Procedure [name: concept[BILATERAL TUBAL LIGATION DIAGNOSIS][], concept: BILATERAL TUBAL LIGATION DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "BILATERAL TUBAL LIGATION", pos: 3, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=bilateral_tubal_ligation&search_string=]

Q.1.1.5. Reason For Procedure [name: concept[MYOMECTOMY DIAGNOSIS][], concept: MYOMECTOMY DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "MYOMECTOMY", pos: 4, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=myomectomy&search_string=]

Q.1.1.6. Reason For Procedure [name: concept[CECLAGE DIAGNOSIS][], concept: CECLAGE DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "CECLAGE", pos: 5, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=ceclage&search_string=]

Q.1.1.7. Reason For Procedure [name: concept[CYSTECTOMY DIAGNOSIS][], concept: CYSTECTOMY DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "CYSTECTOMY", pos: 6, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=cystectomy&search_string=]

Q.1.1.8. Reason For Procedure [name: concept[MALSUPILISATION DIAGNOSIS][], concept: MALSUPILISATION DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "MALSUPILISATION", pos: 7, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=malsupilisation&search_string=]

Q.1.1.9. Reason For Procedure [name: concept[EXCISION DIAGNOSIS][], concept: EXCISION DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "EXCISION", pos: 8, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=excision&search_string=]

Q.1.1.10. Reason For Procedure [name: concept[INCISION AND DRAINAGE DIAGNOSIS][], concept: INCISION AND DRAINAGE DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "INCISION AND DRAINAGE", pos: 9, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=incision_and_drainage&search_string=]

Q.1.1.11. Reason For Procedure [name: concept[CAESAREAN SECTION DIAGNOSIS][], concept: CAESAREAN SECTION DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "CAESAREAN SECTION", pos: 10, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=caesarean_section&search_string=]

Q.1.1.12. Reason For Procedure [name: concept[EXAM UNDER ANAESTHESIA DIAGNOSIS][], concept: EXAM UNDER ANAESTHESIA DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "EXAM UNDER ANAESTHESIA", pos: 11, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=exam_under_anaesthesia&search_string=]

Q.1.1.13. Reason For Procedure [name: concept[EVACUATION/MVA DIAGNOSIS][], concept: EVACUATION/MVA DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "EVACUATION/MANUAL VACUUM ASPIRATION", pos: 12, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=evacuation&search_string=]

Q.1.1.14. Reason For Procedure [name: concept[DILATION AND CURETTAGE DIAGNOSIS][], concept: DILATION AND CURETTAGE DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "DILATION AND CURETTAGE", pos: 13, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=dilation_and_curettage&search_string=]

Q.1.1.15. Reason For Procedure [name: concept[LAPARATOMY DIAGNOSIS DIAGNOSIS][], concept: LAPARATOMY DIAGNOSIS DIAGNOSIS, condition: __$("1.1.1").value.trim().toUpperCase() == "EXPLORATORY LAPARATOMY +/- ADNEXECTOMY", pos: 14, field_type: text, ajaxURL: /encounters/procedure_diagnoses?procedure=laparatomy&search_string=]

Q.1.1.16. Select team member involved [name: concept[TREATMENT GROUP][], ajaxURL: /clinic/users?user_id=<%= params["user_id"]%>&search_string=, pos: 15]

Q.1.1.17. Select next team member involved (Optional) [optional: true, name: concept[TREATMENT GROUP][], ajaxURL: /clinic/users?user_id=<%= params["user_id"]%>&search_string=, pos: 16]

Q.1.1.18. Select next team member involved (Optional) [optional: true, condition: try{$("1.1.17").value.length > 0}catch(e){false}, name: concept[TREATMENT GROUP][], ajaxURL: /clinic/users?user_id=<%= params["user_id"]%>&search_string=, pos: 17]

Q.1.1.19. Select next team member involved (Optional) [optional: true, condition: try{$("1.1.18").value.length > 0}catch(e){false}, name: concept[TREATMENT GROUP][], ajaxURL: /clinic/users?user_id=<%= params["user_id"]%>&search_string=, pos: 18]

Q.1.1.20. Select next team member involved (Optional) [optional: true, condition: try{$("1.1.19").value.length > 0}catch(e){false}, name: concept[TREATMENT GROUP][], ajaxURL: /clinic/users?user_id=<%= params["user_id"]%>&search_string=, pos: 19]

Q.1.1.21. Select next team member involved (Optional) [optional: true, condition: try{$("1.1.20").value.length > 0}catch(e){false}, name: concept[TREATMENT GROUP][], ajaxURL: /clinic/users?user_id=<%= params["user_id"]%>&search_string=, pos: 20]

Q.1.1.22. Select next team member involved (Optional) [optional: true, condition: try{$("1.1.21").value.length > 0}catch(e){false}, name: concept[TREATMENT GROUP][], ajaxURL: /clinic/users?user_id=<%= params["user_id"]%>&search_string=, pos: 21]

Q.1.1.23. Select next team member involved (Optional)[optional: true, condition: try{$("1.1.22").value.length > 0}catch(e){false}, name: concept[TREATMENT GROUP][], ajaxURL: /clinic/users?user_id=<%= params["user_id"]%>&search_string=, pos: 22]

Q.1.1.24. Select next team member involved (Optional) [optional: true, condition: try{$("1.1.23").value.length > 0}catch(e){false}, name: concept[TREATMENT GROUP][], ajaxURL: /clinic/users?user_id=<%= params["user_id"]%>&search_string=, pos: 23]

Q.1.1.25. Select next team member involved (Optional) [optional: true, condition: try{$("1.1.24").value.length > 0}catch(e){false}, name: concept[TREATMENT GROUP][], ajaxURL: /clinic/users?user_id=<%= params["user_id"]%>&search_string=, pos: 24]

Q.1.1.26. Select next team member involved (Optional) [optional: true, condition: try{$("1.1.25").value.length > 0}catch(e){false}, name: concept[TREATMENT GROUP][], ajaxURL: /clinic/users?user_id=<%= params["user_id"]%>&search_string=, pos: 25]
