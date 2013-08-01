P.1. UPDATE BABY OUTCOME [program: MATERNITY PROGRAM, ignore: true, pos: 8, parent: 2]
C.1.1. When discharging a mother and her baby from labour ward to another ward, capture the outcome details of the baby based on mother's HIV status as follows:

Q.1.1.1. Scan baby barcode [pos: 0, concept: Baby identifier, tt_onLoad: __$("keyboard").style.display = "none"; checkBarcodeInput(); id_string = "<%= @patient.babies_national_ids%>"]

Q.1.1.2. Baby outcome [pos: 1, name: concept[Baby Outcome][],  condition: "<%= @patient.hiv_status.upcase%>" == "NEGATIVE" && id_string.match(__$("1.1.1").value)]
O.1.1.2.1. Alive and not exposed
O.1.1.2.2. Fresh stillbirth
O.1.1.2.3. Macerated stillbirth
O.1.1.2.4. Neonatal death

C.1.2. If the mother's HIV status is positive, possible responses are:
Q.1.2.1. Baby outcome [pos: 2, name: concept[Baby Outcome][], condition: "<%= @patient.hiv_status.upcase %>" == "POSITIVE" && id_string.match(__$("1.1.1").value)]
O.1.2.1.1. Alive, exposed - on NVP
O.1.2.1.2. Alive, exposed – not on NVP
O.1.2.1.3. Fresh stillbirth
O.1.2.1.4. Macerated stillbirth
O.1.2.1.5. Neonatal death

C.1.3. If mother's HIV status is unknown, possible responses are:
Q.1.3.1. Baby outcome [pos: 3, name: concept[Baby Outcome][], condition: "<%= @patient.hiv_status.upcase %>" == "UNKNOWN" && id_string.match(__$("1.1.1").value)]
O.1.3.1.1. Alive – unknown exposure
O.1.3.1.2. Fresh stillbirth
O.1.3.1.3. Macerated stillbirth
O.1.3.1.4. Neonatal death

Q.1.6.1. Are there are any comments on the outcome? [pos: 6, condition: id_string.match(__$("1.1.1").value), disabled: disabled]
O.1.6.1.1. No
O.1.6.1.2. Yes
Q.1.6.1.2.1. Comments [pos: 7, condition: id_string.match(__$("1.1.1").value) && __$("1.6.1").value == "Yes", field_type: textarea]





