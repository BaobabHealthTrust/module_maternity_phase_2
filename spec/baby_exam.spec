P.1. PHYSICAL EXAMINATION BABY [program: UNDER 5 PROGRAM, label: Baby Examination, pos: 17, parent: 2]
C.1.1. Given a registered patient, capture each babies physical examination

Q.1.1.2. Condition at Admission [pos: 1, name: concept[Condition of baby at admission], field_type: text, concept: Condition of baby at admission, helpText: Condition of baby at admission]
O.1.1.2.1. Dead
O.1.1.2.2. Critical
O.1.1.2.3. Stable

Q.1.1.3. Temperature [concept: TEMPERATURE, field_type: number, tt_onLoad: attribute("1.1.3*validationRule*([0-9]+\\.[0-9])|Unknown$"), min: 36, max: 38, tt_pageStyleClass: Numeric NumbersOnlyWithDecimal, pos: 2, absoluteMin: 0, absoluteMax: 100, helpText: Baby temperature (<sup>o</sup>C), condition: __$("1.1.2").value.trim().toUpperCase() != "DEAD"]

Q.1.1.4. Respiratory Rate [concept: RESPIRATORY RATE, field_type: number, min: 0, max: 80, tt_pageStyleClass: Numeric NumbersOnlyWithDecimal, pos: 3, units: bpm, helpText: Respiratory rate, condition: __$("1.1.2").value.trim().toUpperCase() != "DEAD"]

Q.1.1.5. Heart Rate [concept: HEART RATE, field_type: number, min: 20, max: 60, tt_pageStyleClass: Numeric NumbersOnlyWithDecimal, pos: 4, units: bpm, helpText: Heart rate, condition: __$("1.1.2").value.trim().toUpperCase() != "DEAD"]

Q.1.1.6. Baby Weight (grams) [concept: WEIGHT, field_type: number, tt_onLoad: attribute("1.1.5*validationRule*([0-9]+\\.[0-9])|Unknown$"), min: 2500, max: 5000, tt_pageStyleClass: Numeric NumbersOnlyWithDecimal, pos: 5, condition: __$("1.1.2").value.trim().toUpperCase() != "DEAD"]

Q.1.1.7. Abdomen [concept: ABDOMEN, field_type: text, pos: 6, helpText: Abdomen, condition: __$("1.1.2").value.trim().toUpperCase() != "DEAD"]
O.1.1.7.1. Soft
O.1.1.7.2. Distended

Q.1.1.8. Cord Tied [concept: CORD TIED, field_type: text, pos: 7, helpText: Cord Tied, condition: __$("1.1.2").value.trim().toUpperCase() != "DEAD"]
O.1.1.8.1. No
O.1.1.8.2. Yes

Q.1.1.9. Any Abnormalities [concept: Any abnormalities, disabled: disabled, field_type: text, pos: 8, helpText: Any abnormalities, condition: __$("1.1.2").value.trim().toUpperCase() != "DEAD"]
O.1.1.9.1. No
O.1.1.9.2. Yes

Q.1.1.10. Specify Abnormalities [concept: SPECIFY, field_type: text, pos: 9, helpText: Specify abnormality(s), condition: __$("1.1.2").value.trim().toUpperCase() != "DEAD"; __$("1.1.9").value.trim().toUpperCase() == "YES"]
