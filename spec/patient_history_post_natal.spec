P.1. Observations [program: MATERNITY PROGRAM, scope: TODAY, concept: gravida, includejs: vitals, label: Post Natal Patient History, pos: 7, parent: 3]
C.1.1. Given a registered patient, capture their Patient History

Q.1.1.1. Gravida [concept: GRAVIDA, field_type: number, absoluteMin: 1, Max: 15, pos: 0, tt_pageStyleClass: NumbersOnly, tt_onUnLoad: count = 1]

Q.1.1.2. Multiple gestation? [concept: MULTIPLE GESTATION, field_type: text, pos: 1, condition: parseInt(__$("1.1.1").value.trim()) > 1]
O.1.1.2.1. No
O.1.1.2.2. Yes

Q.1.1.3. Number of delivered pregnancies [concept: PARITY, tt_OnLoad: checkDeliveriesLimits("post-natal"), tt_OnUnLoad: checkAbortionsLimits("post-natal"), field_type: number, pos: 2, condition:  __$("1.1.1").value > 1  , tt_pageStyleClass: NumbersOnly, absoluteMin: 0, Max: 15]

Q.1.1.4. Number of abortions [concept: NUMBER OF ABORTIONS, field_type: number, pos: 3, condition: __$("1.1.1").value > 1, tt_pageStyleClass: NumbersOnly, absoluteMin: 0, Max: 5;  num_babies = __$("1.1.3").value;]

Q.1.1.5.  Number Of Caesarean Sections [concept: Caesarean Section, tt_OnUnLoad: check("1.1.5"), pos: 4, field_type: number, tt_pageStyleClass: NumbersOnly]

Q.1.1.6.  Number Of breech Deliveries [concept: Breech delivery, tt_OnUnLoad: check("1.1.6"), pos: 5, field_type: number, tt_pageStyleClass: NumbersOnly]

Q.1.1.7.  Number Of Vacuum Extraction Deliveries [concept: Vacuum extraction delivery, tt_OnUnLoad: check("1.1.7"), pos: 6, field_type: number, tt_pageStyleClass: NumbersOnly]

Q.1.1.8.  Number Of Spontaneous Vaginal Deliveries [concept: Spontaneous vaginal delivery, tt_OnUnLoad: check("1.1.8"), pos: 7, field_type: number, tt_pageStyleClass: NumbersOnly]

Q.1.1.16. TTV Status [concept: TT STATUS, field_type: number, pos: 14, absoluteMin: 0, max: 5, tt_pageStyleClass: NumbersOnly]

Q.1.1.19. Next URL [pos: 17, name: ret, value: post-natal, type: hidden]
