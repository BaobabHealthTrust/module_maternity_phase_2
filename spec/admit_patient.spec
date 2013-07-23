P.1. Admit patient [program: MATERNITY PROGRAM, parent: 5, ignore: true, scope: TODAY, concept: Previous HIV Test Status From Before Current Facility Visit]
C.1. Given a pregnant mother that has come for delivery, the following details are required at the time of admission.
Q.1.1. Gravida [pos: 0, field_type: number, tt_pageStyleClass: NumbersOnly, absoluteMin: 1, max: 10, absoluteMax: 20]

Q.1.2. Parity [pos: 1, field_type: number, tt_pageStyleClass: NumbersOnly, absoluteMin: 1, max: 10, absoluteMax: 20, condition: __$("1.1").value > 1]

Q.1.3. Gestation weeks [pos: 2, field_type: number, tt_pageStyleClass: NumbersOnly, absoluteMin: 1, max: 42, absoluteMax: 45, min: 36]

Q.1.4. Previous HIV Test Status From Before Current Facility Visit [pos: 3]
O.1.4.1. Non-reactive less than 3 months
O.1.4.2. Reactive
O.1.4.3. Unknown
Q.1.4.3.1. HIV status [pos: 4]
O.1.4.3.1.1. Non-reactive
O.1.4.3.1.2. Not done
O.1.4.3.1.3. Reactive

Q.1.5. On ART [pos: 5, condition: ((__$("1.4.3.1").value.toLowerCase().trim() == "reactive")  || (__$("1.4").value.toLowerCase().trim() == "reactive"))]
O.1.5.1. No
O.1.5.2. Yes
Q.1.5.2.1. Date antiretrovirals started [pos: 6, helpText: When was ART started?]
O.1.5.2.1.1. On ART before pregnancy
O.1.5.2.1.2. On ART since first or second trimester
O.1.5.2.1.3. On ART since third trimester
O.1.5.2.1.4. On ART during labour
Q.1.5.2.2. Mother ART registration number [pos: 7]
