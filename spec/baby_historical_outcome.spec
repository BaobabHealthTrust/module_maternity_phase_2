P.1. Update Outcome [program: MATERNITY PROGRAM, scope: TODAY, ignore: true, label: Baby Historical Outcome, pos: 46]
C.1.1. Given a mother who has delivered, capture her baby delivery mode

Q.1.1.2. Year of Birth [concept: YEAR OF BIRTH, pos: 0, field_type: number, tt_pageStyleClass: NumbersOnly, min: <%= (Date.today - (@patient.age.years + 10)).year%>, max: min: <%= (Date.today - (@patient.age.years + 50)).year%>, helpText: <%= params["prefix"]%> Year of Birth]

Q.1.1.3.  Delivery Mode [concept: Delivery Mode, pos: 1, helpText: <%= params["prefix"]%> Delivery Mode]
O.1.1.3.1. Breech delivery
O.1.1.3.2. Vacuum extraction delivery
O.1.1.3.3. Caesarean Section
O.1.1.3.4. Spontaneous vaginal delivery

Q.1.1.4. Gestation (months) [concept: gestation, pos: 2, min: 6, max: 9, helpText: <%= params["prefix"]%> Gestation]

Q.1.1.5. Next URL [pos: 3, name: next_url, value: /two_protocol_patients/baby_historical_outcome?user_id=<%= @user.id%>&patient_id=<%= @patient.id%>&prefix=1%>, type: hidden]
