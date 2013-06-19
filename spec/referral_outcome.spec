P.1. REFERRAL [program: MATERNITY PROGRAM, pos: 8, label: Refer Baby, parent: 2]
C.1.1. When referring to another ward a mother and her baby from labour ward to another ward, capture the outcome details of the baby based on mother's HIV status as follows:

Q.1.1.1. Scan baby barcode [pos: 0, concept: Baby identifier, tt_onLoad: __$("keyboard").style.display = "none"; checkBarcodeInput(); id_string = "<%= @patient.babies_national_ids%>"; try{nat_id = "<%= params['national_id'] rescue ''%>"; if (nat_id.length > 1){__$("touchscreenInput" + tstCurrentPage).value = nat_id + "$";}}catch(ex){}]

Q.1.1.2. Ward [pos: 1, helpText: Ward referred to?, condition: id_string.match(__$("1.1.1").value)]
O.1.1.2.1. Nursery
O.1.1.2.2. Kangaroo
O.1.1.2.3. EID
O.1.1.2.4. Immunization
O.1.1.2.5. Check Up

Q.1.1.3. Referral Out Date [pos: 2, helpText: Date referred, field_type: date, condition: id_string.match(__$("1.1.1").value)]

Q.1.1.4. Referral Out Time [pos: 3, helpText: Time referred, field_type: advancedTime, condition: id_string.match(__$("1.1.1").value)]

Q.1.1.5. Reason for referral [pos: 4, ajaxURL: /encounters/diagnoses?search_string=, condition: id_string.match(__$("1.1.1").value)]

