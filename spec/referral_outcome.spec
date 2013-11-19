P.1. REFERRAL [program: UNDER 5 PROGRAM, pos: 39, label: Refer Baby, parent: 2]
C.1.1. When referring to another ward a mother and her baby from labour ward to another ward, capture the outcome details of the baby based on mother's HIV status as follows:

Q.1.1.2. Referral Type [pos: 1, disabled: disabled]
O.1.1.2.1. Other Health Facility
O.1.1.2.2. Internal Referral

Q.1.1.3. Ward [pos: 2, helpText: Ward referred to?, condition: __$("1.1.2").value.toLowerCase().trim() == "internal referral"]
O.1.1.3.1. Nursery
O.1.1.3.2. Kangaroo
O.1.1.3.3. EID
O.1.1.3.4. Immunization
O.1.1.3.5. Check Up

Q.1.1.4. Facility Referred To? [pos: 3, condition: __$("1.1.2").value.toLowerCase().trim() == "other health facility", name: concept[CLINIC PATIENT WAS REFERRRED], ajaxURL: /encounters/static_locations?search_string=, concept: CLINIC PATIENT WAS REFERRRED, fieldtype: text, allowFreeText: true]

Q.1.1.5. Referral Out Date [pos: 4, min: <%= (Date.today - 3.months)%>, helpText: Date referred, field_type: date]

Q.1.1.6. Referral Out Time [pos: 5, helpText: Time referred, field_type: advancedTime]

Q.1.1.7. Reason for referral [pos: 6, ajaxURL: /encounters/diagnoses?search_string=]

