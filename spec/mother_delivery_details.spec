P.1. Update Outcome [program: MATERNITY PROGRAM, ignore: true, label: Mother Delivery Details, pos: 13]

Q.1.1.1. Perineum [concept: Perineum, pos: 0, field_type: text]
O.1.1.1.1. Laceration
O.1.1.1.2. Episiotomy
O.1.1.1.3. Tear
O.1.1.1.4. Intact

Q.1.1.2. Tear extent [concept: TEAR, pos: 1, field_type: text, condition: __$("1.1.1").value.trim().toUpperCase() == "TEAR"]
O.1.1.2.1. 4 Degrees
O.1.1.2.2. 3 Degrees
O.1.1.2.3. 2 Degrees
O.1.1.2.4. 1 Degree

Q.1.2. Blood transfusion done? [pos: 2, concept: Blood transfusion]
O.1.2.1. No
O.1.2.2. Yes
Q.1.2.2.1. Mother blood group [pos: 3, concept: Blood Group,  tt_onLoad: $("keyboard").style.display = "none"; $("inputFrame" + tstCurrentPage).style.height = "550px"; $("viewport").style.height = "550px"]
O.1.2.2.1.1. O+
O.1.2.2.1.2. O-
O.1.2.2.1.3. AB+
O.1.2.2.1.4. AB-
O.1.2.2.1.5. B+
O.1.2.2.1.6. B-
O.1.2.2.1.7. A+
O.1.2.2.1.8. A-

Q.1.3. VDRL Status [concept: VDRL, pos: 4, tt_BeforeUnLoad: checkVDRLStatus("1.3"), tt_onLoad: $("keyboard").style.display = "none"; $("inputFrame" + tstCurrentPage).style.height = "550px"; $("viewport").style.height = "550px"]
O.1.3.1. Unknown
O.1.3.2. Non-Reactive
O.1.3.3. Reactive
O.1.3.4. Treated

Q.1.4. Convulsions? [concept: Convulsions, pos: 5]
O.1.4.1. No
O.1.4.2. Yes

Q.1.5. Complications [pos: 6, tt_pageStyleClass: LongSelectList, tt_onLoad: $("keyboard").style.display = "none"; $("inputFrame" + tstCurrentPage).style.height = "550px"; $("viewport").style.height = "550px"]
O.1.5.1. None
O.1.5.2. Ante part hemorrhage
O.1.5.3. Post part hemorrhage
O.1.5.4. Prolonged first stage of labour
O.1.5.5. Prolonged second stage of labour
O.1.5.6. Pre-Eclampsia [concept: Pre-Eclampsia]
O.1.5.7. Sepsis
O.1.5.8. Ruptured uterus
O.1.5.9. Other
Q.1.5.9.1. Specify [pos: 7]

Q.1.6. Next URL [pos: 8, name: next_url, value: /two_protocol_patients/delivery_procedures?user_id=<%= @user.id %>&patient_id=<%= @patient.id %>, type: hidden]
