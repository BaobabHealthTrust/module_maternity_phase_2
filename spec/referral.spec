P.1. IS PATIENT REFERRED? [program: MATERNITY PROGRAM, scope: TODAY, label: Referral, pos: 51]

Q.1.1. Is the Patient a Referral Case From Another Health Facility? [pos: 0, name: concept[Is patient referred?], concept: Is patient referred?]
O.1.1.1. No
O.1.1.2. Yes

Q.1.1.2.1. Referral Clinic If Referred? [pos: 1, name: concept[REFERRAL CLINIC IF REFERRED], ajaxURL: /encounters/static_locations?search_string=, concept: REFERRAL CLINIC IF REFERRED, field_type: text, allowFreeText: true]

Q.1.1.2.2. Time of referral Arrival [pos: 2, field_type: advancedTime, concept: REFERRAL ARRIVAL TIME]

Q.1.1.2.3. Date of referral arrival [pos: 3, concept: REFERRAL ARRIVAL DATE, field_type: date, tt_OnLoad: __$("Unknown").style.display = "none"]

Q.1.1.2.4. Select Referral Diagnosis [name: concept[REASON FOR REFERRAL TO ANOTHER SITE][], pos: 4, fieldtype: text, ajaxURL: /encounters/diagnoses?search_string=, allowFreeText: true]

Q.1.1.2.5. Select Next Referral Diagnosis [name: concept[REASON FOR REFERRAL TO ANOTHER SITE][], pos: 5, optional: true, fieldtype: text, ajaxURL: /encounters/diagnoses?search_string=, allowFreeText: true, optional: true, condition: __$("1.1.2.4").value != ""]

Q.1.2. Next URL [pos: 7, name: next_url, value: /two_protocol_patients/admit_to_ward?user_id=<%= @user.id %>&patient_id=<%= @patient.id %>&location_id=<%= params["location_id"]%>, type: hidden]

