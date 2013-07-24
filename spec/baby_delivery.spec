P.1. Baby delivery [program: MATERNITY PROGRAM,  ignore: true, includejs: apgar, includecss: apgar, label: Baby Delivery, pos: 6, parent: 2]
C.1.1. Given a mother that has delivered, for each selected baby

Q.1.1.1. Scan baby barcode (Optional) [pos: 0, optional: true, concept: Baby identifier, condition: false, tt_onLoad: __$("keyboard").style.display = "none"; checkBarcodeInput();]

Q.1.1.2. Date of delivery [helpText: <%= params["prefix"] %> Date of Delivery, pos: 1, name: concept[Date of delivery], field_type: date, concept: Date of delivery]

Q.1.1.3. Time of delivery [pos: 2, name: concept[Time of delivery], field_type: advancedTime, concept: Time of delivery, helpText: <%= params["prefix"] %> Time of Delivery]

Q.1.1.4. Place of delivery [pos: 3, name: concept[Place of delivery], concept: Place of delivery, helpText: <%= params["prefix"] %> Place of Delivery]
O.1.1.4.1. This facility
O.1.1.4.2. In transit
O.1.1.4.3. Other facility
O.1.1.4.4. Home/TBA

Q.1.1.5. Gender [pos: 4, name: concept[Gender], concept: Gender, helpText: <%= params["prefix"] %> Gender]
O.1.1.5.1. Male
O.1.1.5.2. Female

Q.1.1.6. Presentation [pos: 5, name: concept[Presentation], ajaxURL: /encounters/presentation?search_string=, field_type: text, concept: Presentation, helpText: <%= params["prefix"] %> Presentation]

Q.1.1.7. Delivery Outcome [pos: 6, name: concept[BABY OUTCOME], ajaxURL: /encounters/concept_set_options?set=baby_outcome&search_string=, field_type: text, concept: BABY OUTCOME, helpText: <%= params["prefix"] %> Delivery Outcome]

Q.1.1.8. Baby on NVP? [pos: 7, name: concept[Baby on NVP?], condition: __$("1.1.7").value.toLowerCase().trim() == "alive" && <%= (@patient.hiv_status.downcase.strip == "positive" rescue false)%>, helpText: Is <%= params["prefix"] %> Baby on NVP?]
O.1.1.8.1. No
O.1.1.8.2. Yes

Q.1.1.9. Birth weight [pos: 8, name: concept[Birth weight], min: 2500, max: 4500, absoluteMin: 100, absoluteMax: 8000, field_type: number, tt_pageStyleclass: NumbersOnlyWithDecimal, concept: Birth weight, helpText: <%= params["prefix"] %> Birth Weight (grams)]

Q.1.1.10. Height (CM) [concept: HEIGHT (CM), field_type: number, condition: __$("1.1.4").value.toLowerCase().trim() == "this facility" && __$("1.1.7").value.toLowerCase().trim() == "alive", min: 15.0, max: 60.0, tt_pageStyleClass: Numeric NumbersOnlyWithUnknown, pos: 9, absoluteMin: 0, absoluteMax: 100, helpText: <%= params["prefix"] %> Birth Length (cm)]

Q.1.1.11. APGAR [concept: Apgar minute one, field_type: number, condition: __$("1.1.4").value.toLowerCase().trim() == "this facility" && __$("1.1.7").value.toLowerCase().trim() == "alive", tt_onLoad: showApgarControl(1); __$("keyboard").style.display = "none",absoluteMax: 10, absoluteMin: 1, pos: 10, tt_pageStyleClass: NoKeyboard,  helpText: <%= params["prefix"] %> 1<sup>st</sup> Minute APGAR]

Q.1.1.12. APGAR [concept: Apgar minute five, field_type: number, condition: __$("1.1.4").value.toLowerCase().trim() == "this facility" && __$("1.1.7").value.toLowerCase().trim() == "alive", tt_onLoad: showApgarControl(5); __$("keyboard").style.display = "none",absoluteMax: 10, absoluteMin: 1, pos: 11, tt_pageStyleClass: NoKeyboard, helpText: <%= params["prefix"] %> 5<sup>th</sup> Minute APGAR]

Q.1.1.13. Delivery mode [pos: 12, name: concept[Delivery mode], concept: Delivery mode, helpText: <%= params["prefix"] %> Delivery Mode]
O.1.1.13.1. Spontaneous vaginal delivery
O.1.1.13.2. Vacuum extraction delivery
O.1.1.13.3. Breech delivery
O.1.1.13.4. Caesarean section

Q.1.1.14. Newborn baby complications [pos: 13, condition: __$("1.1.7").value.toLowerCase().trim() == "alive", name: concept[Newborn baby complications], concept: Newborn baby complications, helpText: <%= params["prefix"] %> Newborn Complications]
O.1.1.14.1. None
O.1.1.14.2. Asphyxia
O.1.1.14.3. Sepsis
O.1.1.14.4. Other

Q.1.1.14. Breast feeding initiated within 60 minutes? [pos: 14, helpText: <%= params["prefix"] %> Breast Feeding Initiated Within 60 Minutes?, condition: __$("1.1.7").value.toLowerCase().trim() == "alive"]
O.1.1.14.1. No
O.1.4.14.2. Yes

Q.1.15.1. Tetracycline eye ointment given? [pos: 15, helpText: <%= params["prefix"] %> Tetracycline Eye Ointment Given?, condition: __$("1.1.7").value.toLowerCase().trim() == "alive"]
O.1.15.1.1. No
O.1.15.1.2. Yes

Q.1.16.1. Are there are any comments on baby the outcome? [pos: 16, condition: __$("1.1.7").value.toLowerCase().trim() == "alive", disabled: disabled]
O.1.16.1.1. No
O.1.16.1.2. Yes
Q.1.16.1.2.1. Comments [pos: 17, field_type: textarea]

Q.1.17.15. Next URL [pos: 18, name: next_url, value: /two_protocol_patients/mother_delivery_details?user_id=<%= @user.id %>&patient_id=<%= @patient.id %>, type: hidden]


