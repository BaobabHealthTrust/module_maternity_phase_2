P.1. Observations [program: MATERNITY PROGRAM, scope: TODAY, concept: Lie, label: Physical Exam, pos: 8, parent: 4]
C.1.1. Given a registered patient, capture their Physical Examination

Q.1.1.1. Fundus (weeks) [concept: FUNDUS, value: <%= @patient.fundus_by_lmp + 1 rescue nil%>, absolutMin: 1, absoluteMax: 52, min: <%= (@patient.fundus_by_lmp ) rescue 42%>, max: <%= (@patient.fundus_by_lmp + 2) rescue 42%>, field_type: number, pos: 0, tt_pageStyleClass: NumbersOnly na]

Q.1.1.2. Lie [concept: LIE, field_type: text, pos: 1, condition: __$("1.1.1").value != "N/A", tt_pageStyleClass: NoKeyboard]
O.1.1.2.1. Undefined
O.1.1.2.2. Oblique
O.1.1.2.3. Transverse
O.1.1.2.4. Longitudinal

Q.1.1.3. Presentation [concept: Presentation, field_type: text, tt_pageStyleClass: NoKeyboard, pos: 2, condition: __$("1.1.1").value != "N/A", tt_pageStyleClass: NoKeyboard]
O.1.1.3.1. Shoulder
O.1.1.3.2. Brow
O.1.1.3.3. Cord
O.1.1.3.4. Footling
O.1.1.3.5. Face
O.1.1.3.6. Breech
O.1.1.3.7. Cephalic
O.1.1.3.8. Compound

Q.1.1.4. Breech Position Type [concept: BREECH, field_type: text, pos: 3, condition: __$("1.1.3").value.trim().toUpperCase() == "BREECH", tt_pageStyleClass: NoKeyboard]
O.1.1.4.1. Right Sacro Posterior
O.1.1.4.2. Right Sacro Transverse
O.1.1.4.3. Right Sacro Anterior
O.1.1.4.4. Left Sacro Posterior
O.1.1.4.5. Left Sacro Transverse
O.1.1.4.6. Left Sacro Anterior

Q.1.1.5. Cephalic Position Type [concept: CEPHALIC, field_type: text, pos: 4, condition: __$("1.1.3").value.trim().toUpperCase() == "CEPHALIC", tt_pageStyleClass: NoKeyboard]
O.1.1.5.1. Right Occipito Posterior
O.1.1.5.2. Right Occipito Transverse
O.1.1.5.3. Right Occipito Anterior
O.1.1.5.4. Left Occipito Posterior
O.1.1.5.5. Left Occipito Transverse
O.1.1.5.6. Left Occipito Anterior

Q.1.1.6. Face Position Type [concept: FACE, field_type: text, pos: 5, condition: __$("1.1.3").value.trim().toUpperCase() == "FACE", tt_pageStyleClass: NoKeyboard]
O.1.1.6.1. Right Mento Posterior
O.1.1.6.2. Right Mento Transverse
O.1.1.6.3. Right Mento Anterior
O.1.1.6.4. Left Mento Posterior
O.1.1.6.5. Left Mento Transverse
O.1.1.6.6. Left Mento Anterior

Q.1.1.7. Shoulder Position Type [concept: SHOULDER, field_type: text, pos: 6, condition: __$("1.1.3").value.trim().toUpperCase() == "SHOULDER", tt_pageStyleClass: NoKeyboard]
O.1.1.7.1. Right Acromion Dorsal Posterior
O.1.1.7.2. Right Acromion Dorsal Anterior
O.1.1.7.3. Left Acromion Dorsal Posterior
O.1.1.7.4. Left Acromion Dorsal Anterior

Q.1.1.8. Any Contractions? [concept: CONTRACTIONS, field_type: text, pos: 7, condition: __$("1.1.1").value != "N/A"]
O.1.1.8.1. No
O.1.1.8.2. Yes

Q.1.1.9. Contractions Intensity [concept: CONTRACTIONS INTENSITY, field_type: text, pos: 8, condition: __$("1.1.8").value.trim().toUpperCase() == "YES"]
O.1.1.9.1. Niggling
O.1.1.9.2. Strong
O.1.1.9.3. Moderate
O.1.1.9.4. Mild

Q.1.1.10. Contractions Level [concept: CONTRACTIONS LEVEL, condition: __$("1.1.9").value.trim().toUpperCase() != "NIGGLING" && __$("1.1.8").value.trim().toUpperCase() == "YES",  pos: 9, field_type: number, absoluteMax: 5, absoluteMin: 1, tt_pageStyleClass: NumbersOnly level, tt_onLoad: changeIds(), tt_pageStyleClass: NumbersOnly na]

Q.1.1.11. Descent [concept: DESCENT, field_type: text, pos: 10, tt_pageStyleClass: NoKeyboard]
O.1.1.11.1. 0/5
O.1.1.11.2. 1/5
O.1.1.11.3. 2/5
O.1.1.11.4. 3/5
O.1.1.11.5. 4/5
O.1.1.11.6. 5/5
O.1.1.11.7. N/A

Q.1.1.12. Next URL [pos: 11, name: ret, value: ante-natal, type: hidden]
