P.1. UPDATE BABY OUTCOME [program: MATERNITY PROGRAM]
C.1.1. When discharging a mother and her baby from labour ward to another ward, capture the outcome details of the baby based on mother's HIV status as follows:
Q.1.1.1. Baby outcome [pos: 0, condition: "<%= @patient.hiv_status.upcase %>" == "NEGATIVE"]
O.1.1.1.1. Alive and not exposed
O.1.1.1.2. Fresh stillbirth
O.1.1.1.3. Macerated stillbirth
O.1.1.1.4. Neonatal death

C.1.2. If the mother's HIV status is positive, possible responses are:
Q.1.2.1. Baby outcome [pos: 1, condition: "<%= @patient.hiv_status.upcase %>" == "POSITIVE"]
O.1.2.1.1. Alive, exposed - on NVP
O.1.2.1.2. Alive, exposed – not on NVP
O.1.2.1.3. Fresh stillbirth
O.1.2.1.4. Macerated stillbirth
O.1.2.1.5. Neonatal death

C.1.3. If mother's HIV status is unknown, possible responses are:
Q.1.3.1. Baby outcome [pos: 2, condition: "<%= @patient.hiv_status.upcase %>" == "UNKNOWN"]
O.1.3.1.1. Alive – unknown exposure
O.1.3.1.2. Fresh stillbirth
O.1.3.1.3. Macerated stillbirth
O.1.3.1.4. Neonatal death

C.1.4. For each baby, if baby is still alive
Q.1.4.1. Breast feeding initiated within 60 minutes? [pos: 3, condition: __$("1.1.1").value != "Fresh stillbirth" && __$("1.1.1").value != "Macerated stillbirth" && __$("1.1.1").value != "Neonatal death" && __$("1.2.1").value != "Fresh stillbirth" && __$("1.2.1").value != "Macerated stillbirth" && __$("1.2.1").value != "Neonatal death" && __$("1.3.1").value != "Fresh stillbirth" && __$("1.3.1").value != "Macerated stillbirth" && __$("1.3.1").value != "Neonatal death"]
O.1.4.1.1. Yes
O.1.4.1.2. No

Q.1.5.1. Tetracycline eye ointment given? [pos: 4, condition: __$("1.1.1").value != "Fresh stillbirth" && __$("1.1.1").value != "Macerated stillbirth" && __$("1.1.1").value != "Neonatal death" && __$("1.2.1").value != "Fresh stillbirth" && __$("1.2.1").value != "Macerated stillbirth" && __$("1.2.1").value != "Neonatal death" && __$("1.3.1").value != "Fresh stillbirth" && __$("1.3.1").value != "Macerated stillbirth" && __$("1.3.1").value != "Neonatal death"]
O.1.5.1.1. Yes
O.1.5.1.2. No

Q.1.6.1. Are there are any comments on the outcome? [pos: 5, disabled: disabled]
O.1.6.1.1. No
O.1.6.1.2. Yes
Q.1.6.1.2.1. Comments [pos: 6, field_type: textarea]

Q.1.7.1. Discharge baby [pos: 7, condition: __$("1.1.1").value != "Fresh stillbirth" && __$("1.1.1").value != "Macerated stillbirth" && __$("1.1.1").value != "Neonatal death" && __$("1.2.1").value != "Fresh stillbirth" && __$("1.2.1").value != "Macerated stillbirth" && __$("1.2.1").value != "Neonatal death" && __$("1.3.1").value != "Fresh stillbirth" && __$("1.3.1").value != "Macerated stillbirth" && __$("1.3.1").value != "Neonatal death"]
O.1.7.1.1. Home
O.1.7.1.2. Admit to ward
Q.1.7.1.2.1. Admit to ward [pos: 8]
O.1.7.1.2.1.1. Nursery
O.1.7.1.2.1.2. Kangaroo Ward

Q.1.8.1. Baby identifier [pos: 9, type: hidden, value: <%= @patient.current_babies[params["baby"].to_i - 1] %>]

Q.1.9.1. Next URL [pos: 10, name: next_url, value: /protocol_patients/update_baby_outcome?user_id=<%= @user.id %>&patient_id=<%= @patient.id %>&baby=<%= params["baby"].to_i + 1 %>&baby_total=<%= params["baby_total"]%>, type: hidden, ruby: <%= (params["baby"].to_i >= params["baby_total"].to_i ? "disabled" | "") %>]


