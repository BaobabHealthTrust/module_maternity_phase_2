P.1. Observations [program: MATERNITY PROGRAM, scope: TODAY, concept: Lie, label: Physical Exam, pos: 8, parent: 4]
C.1.1. Given a registered patient, capture their Physical Examination

Q.1.1.1. Fundus (weeks) [concept: FUNDUS, value: <%= @patient.fundus_by_lmp - 1 rescue nil%>, min: <%= (@patient.fundus_by_lmp - 2) rescue 42%>, max: <%= (@patient.fundus_by_lmp) rescue 42%>, field_type: number, pos: 0, tt_pageStyleClass: NumbersOnly na]

Q.1.1.2. Lie [concept: LIE, field_type: text, pos: 1, condition: __$("1.1.1").value != "N/A"]
O.1.1.2.1. Undefined
O.1.1.2.2. Oblique
O.1.1.2.3. Transverse
O.1.1.2.4. Longitudinal

Q.1.1.3. Presentation [concept: Presentation, field_type: text, tt_pageStyleClass: NoKeyboard, pos: 2, condition: __$("1.1.1").value != "N/A"]
O.1.1.3.1. Shoulder
O.1.1.3.2. Brow
O.1.1.3.3. Cord
O.1.1.3.4. Footling
O.1.1.3.5. Face
O.1.1.3.6. Breech
O.1.1.3.7. Cephalic
O.1.1.3.8. Compound

Q.1.1.4. Contractions [concept: CONTRACTIONS, field_type: text, pos: 3, condition: __$("1.1.1").value != "N/A"]
O.1.1.4.1. No
O.1.1.4.2. Yes

Q.1.1.5. Contractions Intensity [concept: CONTRACTIONS INTENSITY, field_type: text, pos: 4, condition: __$("1.1.3").value.trim().toUpperCase() == "YES"]
O.1.1.5.1. Niggling
O.1.1.5.2. Strong
O.1.1.5.3. Moderate
O.1.1.5.4. Mild

Q.1.1.6. Contractions Level [concept: CONTRACTIONS LEVEL, field_type: number, absoluteMax: 5, absoluteMin: 1, tt_pageStyleClass: NumbersOnly level, tt_onLoad: changeIds(), pos: 4, tt_pageStyleClass: NumbersOnly na, condition: __$("1.1.4").value.trim().toUpperCase() != "NIGGLING"]

Q.1.1.7. Descent [concept: DESCENT, field_type: text, pos: 6, tt_pageStyleClass: NoKeyboard]
O.1.1.7.1. 0/5
O.1.1.7.2. 1/5
O.1.1.7.3. 2/5
O.1.1.7.4. 3/5
O.1.1.7.5. 4/5
O.1.1.7.6. 5/5
O.1.1.7.7. N/A

Q.1.1.8. Next URL [pos: 7, name: ret, value: ante-natal, type: hidden]
