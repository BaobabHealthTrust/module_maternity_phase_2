P.1. Admit patient [program: UNDER 5 PROGRAM, includejs: generalCondition, includecss: generalCondition, label: Admit baby, pos: 5, parent: 2]
C.1. If baby has been admitted to ward

Q.1.1. Scan baby barcode [pos: 0, concept: Baby identifier, tt_onLoad: __$("keyboard").style.display = "none"; checkBarcodeInput(); id_string = "<%= @patient.babies_national_ids%>"; try{nat_id = "<%= params['national_id'] rescue ''%>"; if (nat_id.length > 1){__$("touchscreenInput" + tstCurrentPage).value = nat_id + "$";}}catch(ex){}]

Q.1.2. Ward [pos: 1, condition: id_string.match(__$("1.1").value)]
O.1.2.1. Nursery
O.1.2.2. Kangaroo

Q.1.3. Admission date [pos: 2, field_type: date, tt_onLoad: $("Unknown").style.display = "none", condition: id_string.match(__$("1.1").value)]

Q.1.4. Admission time [pos: 3, field_type: advancedTime, condition: id_string.match(__$("1.1").value)]

Q.1.5. Baby weight at admission (grams) [concept: Baby weight at admission, pos: 4, condition: id_string.match(__$("1.1").value), field_type: number, absoluteMin: 100, min: 2000, max: 5000, absoluteMax: 10000, tt_pageStyleClass: NumbersOnlyWithDecimal]

Q.1.6. Baby temperature (<sup>o</sup>C) [concept: temperature, pos: 5,  tt_pageStyleClass: Numeric NumbersOnlyWithDecimal, field_type: number,  min: 36, max: 38, absoluteMin: 0, absoluteMax: 70, condition: id_string.match(__$("1.1").value)]

Q.1.7. Reason for admission [pos: 6, name: concept[Reason for admission][], condition: id_string.match(__$("1.1").value), ajaxUrl: /encounters/diagnoses?&search_string=]

Q.1.8. Next reason for admission (Optional) [optional: true, pos: 7, name: concept[Reason for admission][], condition: id_string.match(__$("1.1").value), ajaxUrl: /encounters/diagnoses?&search_string=]

Q.1.9. General Condition [concept: General condition, condition: id_string.match(__$("1.1").value), tt_onLoad: showGeneralConditionControl(); __$("keyboard").style.display = "none", pos: 8, tt_pageStyleClass: NoKeyboard,  helpText: General condition of baby]
