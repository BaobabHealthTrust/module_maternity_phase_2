P.1. Observations [program: MATERNITY PROGRAM, scope: TODAY, label: PMTCT, pos: 10, parent: 4]
C.1.1. Given a registered patient capture PMTCT

Q.1.1.1. PMTCT Status [concept: HIV STATUS, field_type: text, pos: 0, tt_pageStyleClass: LongSelectList, tt_BeforeUnload: checkHIVTestUnkown("1.1.1");]
O.1.1.1.1. Non-Reactive
O.1.1.1.2. Reactive
O.1.1.1.3. Unknown

Q.1.1.2. PMTCT Test Date [concept: HIV TEST DATE, field_type: date, pos: 1, condition: __$("1.1.1").value.trim().toUpperCase() != "UNKNOWN", tt_onUnLoad: checkHIVTestDate("1.1.2"); ]

Q.1.1.3. On ARVs [concept: ON ARVS, field_type: text, pos: 2, condition: __$("1.1.1").value.trim().toUpperCase() == "REACTIVE"]
O.1.1.3.1. No
O.1.1.3.2. Yes

Q.1.1.4. ARV Start Date [concept: ART Start Date, field_type: date, pos: 3, condition: __$("1.1.3").value.trim().toUpperCase() == "YES", tt_onUnLoad: window.clearInterval(timedEvent), tt_onLoad: showPeriodOnARVs();]

Q.1.1.5. Feeding Option [concept: FEEDING OPTION, field_type: text, pos: 5], condition: __$("1.1.1").value.trim().toUpperCase() == "REACTIVE"
O.1.1.5.1. Exclusive Formula Feeding
O.1.1.5.2. No Breast Feeding
O.1.1.5.3. Exclusive Breast Feeding
