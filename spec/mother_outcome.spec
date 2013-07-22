P.1. Update outcome [program: MATERNITY PROGRAM, label: Update Outcome Mum, parent: 5, pos: 7]
C.1. After the mother has delivered, update the outcome of the delivery
Q.1.1. Complications [pos: 0]
O.1.1.1. None
O.1.1.2. Ante part hemorrhage
O.1.1.3. Post part hemorrhage
O.1.1.4. Prolonged first stage of labour
O.1.1.5. Prolonged second stage of labour
O.1.1.6. Pre-Eclampsia [concept: Pre-Eclampsia]
O.1.1.7. Sepsis
O.1.1.8. Ruptured uterus
O.1.1.9. Other
Q.1.1.9.1. Specify [pos: 1]

Q.1.2. Blood transfusion done? [pos: 2, concept: Blood transfusion]
O.1.2.1. Yes
O.1.2.2. No

Q.1.3. Placenta removed manually? [pos: 3]
O.1.3.1. Yes
O.1.3.2. No

Q.1.4. Vitamin A given? [pos: 4]
O.1.4.1. Yes
O.1.4.2. No

Q.1.5. Staff conducting delivery [pos: 5]
O.1.5.1. Medical Doctor /Clinical Officer /Medical Assistant
O.1.5.2. Patient Attendant / Ward Attendant /Health Surveillance Assistant
O.1.5.3. Other
Q.1.5.3.1. Specify [pos: 6]

Q.1.6. Maternity outcome [pos: 7]
O.1.6.1. Alive
O.1.6.2. Patient died

Q.1.7. Sutures removed [pos: 8, condition: <%= (@patient.current_procedures rescue []).include?("caesarean section") %>]
O.1.7.1. Yes
O.1.7.2. No

Q.1.8. Refer out [pos: 9, condition: __$("1.6").value.toUpperCase().trim() == "ALIVE" ]
O.1.8.1. No
O.1.8.2. Yes
Q.1.8.2.1. Referred [pos: 10, ajaxUrl: /encounters/static_locations]


