P.1. Baby delivery [program: MATERNITY PROGRAM, ignore: true, label: Baby Delivery]
C.1.1. Given a mother that has delivered, for each selected baby

Q.1.1.2. Date of delivery [pos: 0, name: concept[Date of delivery], field_type: date, concept: Date of delivery, helpText: Date of delivery <%= params["baby"] + ((params["baby"].to_i == 1) ? "<sup>st</sup>" | ((params["baby"].to_i == 2) ? "<sup>nd</sup>" | ((params["baby"].to_i == 3) ? "<sup>rd</sup>" | "<sup>th</sup>" ))) %> baby]

Q.1.1.3. Time of delivery [pos: 1, name: concept[Time of delivery], field_type: advancedTime, concept: Time of delivery, helpText: Time of delivery <%= params["baby"] + ((params["baby"].to_i == 1) ? "<sup>st</sup>" | ((params["baby"].to_i == 2) ? "<sup>nd</sup>" | ((params["baby"].to_i == 3) ? "<sup>rd</sup>" | "<sup>th</sup>" ))) %> baby]

Q.1.1.4. Gender [pos: 2, name: concept[Gender], concept: Gender, helpText: Gender <%= params["baby"] + ((params["baby"].to_i == 1) ? "<sup>st</sup>" | ((params["baby"].to_i == 2) ? "<sup>nd</sup>" | ((params["baby"].to_i == 3) ? "<sup>rd</sup>" | "<sup>th</sup>" ))) %> baby]
O.1.1.4.1. Male
O.1.1.4.2. Female

Q.1.1.5. Birth weight [pos: 3, name: concept[Birth weight], field_type: number, tt_pageStyleclass: NumbersOnlyWithDecimal, concept: Birth weight, helpText: Birth weight <%= params["baby"] + ((params["baby"].to_i == 1) ? "<sup>st</sup>" | ((params["baby"].to_i == 2) ? "<sup>nd</sup>" | ((params["baby"].to_i == 3) ? "<sup>rd</sup>" | "<sup>th</sup>" ))) %> baby]

Q.1.1.6. Apgar score [pos: 4, name: concept[Apgar], concept: Apgar, tt_onLoad: showAPGAR(), tt_beforeUnLoad: unloadAPGAR(), helpText: APGAR score <%= params["baby"] + ((params["baby"].to_i == 1) ? "<sup>st</sup>" | ((params["baby"].to_i == 2) ? "<sup>nd</sup>" | ((params["baby"].to_i == 3) ? "<sup>rd</sup>" | "<sup>th</sup>" ))) %> baby]

Q.1.1.7. Place of delivery [pos: 5, name: concept[Place of delivery], concept: Place of delivery, helpText: Place of delivery <%= params["baby"] + ((params["baby"].to_i == 1) ? "<sup>st</sup>" | ((params["baby"].to_i == 2) ? "<sup>nd</sup>" | ((params["baby"].to_i == 3) ? "<sup>rd</sup>" | "<sup>th</sup>" ))) %> baby]
O.1.1.7.1. This facility
O.1.1.7.2. In transit
O.1.1.7.3. Other facility
O.1.1.7.4. Home/TBA

Q.1.1.8. Delivery mode [pos: 6, name: concept[Delivery mode], concept: Delivery mode, helpText: Delivery mode <%= params["baby"] + ((params["baby"].to_i == 1) ? "<sup>st</sup>" | ((params["baby"].to_i == 2) ? "<sup>nd</sup>" | ((params["baby"].to_i == 3) ? "<sup>rd</sup>" | "<sup>th</sup>" ))) %> baby]
O.1.1.8.1. Spontaneous vaginal delivery
O.1.1.8.2. Vacuum extraction delivery
O.1.1.8.3. Breech delivery
O.1.1.8.4. Caesarean section

Q.1.1.9. Newborn baby complications [pos: 7, name: concept[Newborn baby complications], concept: Newborn baby complications, helpText: Newborn baby complications <%= params["baby"] + ((params["baby"].to_i == 1) ? "<sup>st</sup>" | ((params["baby"].to_i == 2) ? "<sup>nd</sup>" | ((params["baby"].to_i == 3) ? "<sup>rd</sup>" | "<sup>th</sup>" ))) %> baby]
O.1.1.9.1. None
O.1.1.9.2. Weight less than 2500g
O.1.1.9.3. Prematurity
O.1.1.9.4. Asphyxia
O.1.1.9.5. Sepsis
O.1.1.9.6. Other

Q.1.1.10. Next URL [pos: 8, name: next_url, value: /protocol_patients/baby_delivery?user_id=<%= @user.id %>&patient_id=<%= @patient.id %>&baby=<%= params["baby"].to_i + 1 %>&baby_total=<%= params["baby_total"]%>, type: hidden, ruby: <%= (params["baby"].to_i >= params["baby_total"].to_i ? "disabled" | "") %>]


