P.1. Update Outcome [program: MATERNITY PROGRAM, scope: RECENT, concept: DISCHARGED, label: Discharged, pos: 11, parent: 5]

Q.1.1.1. Outcome [pos: 0, name: concept[Outcome], concept: Outcome, type: hidden, value: Discharged]

Q.1.1.2. Discharged to Where? [concept: DISCHARGED, pos: 1, field_type: text]
O.1.1.2.1. Another Health Facility
O.1.1.2.2. Home - Waiting
O.1.1.2.3. Home

Q.1.1.3. Which Health Facility [concept: HEALTH FACILITY, pos: 2, fieldtype: text, ajaxURL: /encounters/static_locations?search_string=, allowFreeText: true, condition: __$("1.1.2").value.trim().toUpperCase() == "ANOTHER HEALTH FACILITY"]

Q.1.1.4. Select Discharge Diagnosis [name: concept[Diagnosis][], concept: DIAGNOSIS, pos: 3, fieldtype: text, ajaxURL: /encounters/diagnoses?search_string=, allowFreeText: true]

Q.1.1.5. Select Next Discharge Diagnosis [name: concept[Diagnosis][], concept: DIAGNOSIS, pos: 4, optional: true, fieldtype: text, ajaxURL: /encounters/diagnoses?search_string=, allowFreeText: true, condition: __$("1.1.4").value != ""]
