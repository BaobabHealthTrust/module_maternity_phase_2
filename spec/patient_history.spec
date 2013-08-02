P.1. Observations [program: MATERNITY PROGRAM, scope: TODAY, concept: gravida, includejs: vitals, label: Ante Natal Patient History, pos: 36, parent: 4]
C.1.1. Given a registered patient, capture their Patient History

Q.1.1.1. Gravida [concept: GRAVIDA, field_type: number, absoluteMin: 1, Max: 15, pos: 0, tt_pageStyleClass: NumbersOnly, tt_onUnLoad: count = 1]

Q.1.1.2. Multiple Gestation [concept: MULTIPLE GESTATION, field_type: text, pos: 1, condition: __$("1.1.1").value.trim().toUpperCase() > 1]
O.1.1.2.1. No
O.1.1.2.2. Yes

Q.1.1.3. Number of Deliveries [concept: PARITY, field_type: number, pos: 2, condition: __$("1.1.1").value > 1, tt_pageStyleClass: NumbersOnly, absoluteMin: 0, Max: 15]

Q.1.1.4. Number of Abortions [concept: NUMBER OF ABORTIONS, field_type: number, pos: 3, condition: __$("1.1.1").value > 1, tt_pageStyleClass: NumbersOnly, absoluteMin: 0, Max: 5;  num_babies = __$("1.1.3").value;]
Q.1.1.16. TTV Status [concept: TT STATUS, field_type: number, pos: 14, absoluteMin: 0, max: 5, tt_pageStyleClass: NumbersOnly]

Q.1.1.17. Last Menstrual Period [concept: DATE OF LAST MENSTRUAL PERIOD, field_type: date, pos: 15, tt_onLoad:  lmp = "<%= params["lmp"] rescue '' %>"; name = "<%= ' For <br>' + @patient.name rescue '' %>"; checkANCLMP(); calculateEDOD("1.1.17"), tt_onUnLoad: window.clearInterval(timedEvent)]
Q.1.1.18. Gestation (months) [disabled: disabled, concept: estimate LMP, max: 9, min: 6, tt_onUnLoad: var date = "<%= Date.today%>"; setLMPDate($("touchscreenInput" + tstCurrentPage).value + "|" + date), tt_pageStyleClass: NumbersOnly, condition: $("1.1.17").value.toLowerCase().trim() == "unknown", field_type: number, pos:16]

Q.1.1.19. Next URL [pos: 19, name: ret, value: ante-natal, type: hidden]

Q.1.1.20. Next URL [pos: 20, name: next_url, value: /two_protocol_patients/baby_historical_outcome?user_id=<%= @user.id%>&patient_id=<%= @patient.id%>, type: hidden]


