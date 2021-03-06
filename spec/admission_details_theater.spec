P.1. Observations [program: MATERNITY PROGRAM, scope: TODAY, concept: Admission Date, label: Theater Admission Details, pos: 135]
C.1.1. Given a registered patient, capture their admission diagnoses

Q.1.1.1. Admission Date [concept: Admission date, field_type: date, pos: 0]

Q.1.1.2. Admission Time [concept: Admission Time, field_type: advancedTime, pos: 1]

Q.1.1.3. Observation [concept: Observation, field_type: text, pos: 2]
O.1.1.3.1. Healthy
O.1.1.3.2. Ill Looking

Q.1.1.4. Condition [concept: Condition, field_type: text, pos: 3]
O.1.1.4.1. Stable
O.1.1.4.2. Critical

Q.1.1.5. Anaemic [concept: Anaemic, field_type: text, pos: 4]
O.1.1.5.1. Yes
O.1.1.5.2. No

Q.1.1.6. Oedema [concept: Oedema, field_type: text, pos: 5]
O.1.1.6.1. None
O.1.1.6.2. 1+
O.1.1.6.3. 2+
O.1.1.6.4. 3+

Q.1.1.7. Select reason for admission [name: concept[Diagnosis][], allowFreeText: true, pos: 6, ajaxURL: /encounters/diagnoses?search_string=]

Q.1.1.8. Select next reason for admission [name: concept[Diagnosis][], optional:true, allowFreeText: true, pos: 7, ajaxURL: /encounters/diagnoses?search_string=]

