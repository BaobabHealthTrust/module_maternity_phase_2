P.1. Observations [program: MATERNITY PROGRAM, scope: TODAY, concept: gravida, includejs: vitals, label: Post Natal Patient History, pos: 7, parent: 3]
C.1.1. Given a registered patient, capture their Patient History

Q.1.1.1. Gravida [concept: GRAVIDA, field_type: number, absoluteMin: 1, Max: 15, pos: 0, tt_pageStyleClass: NumbersOnly, tt_onUnLoad: count = 1]

Q.1.1.2. Multiple Gestation [concept: MULTIPLE GESTATION, field_type: text, pos: 1, condition: __$("1.1.1").value.trim().toUpperCase() > 1]
O.1.1.2.1. No
O.1.1.2.2. Yes

Q.1.1.3. Number of Deliveries [concept: PARITY, field_type: number, pos: 2, condition: __$("1.1.1").value > 1, tt_pageStyleClass: NumbersOnly, absoluteMin: 0, Max: 15]

Q.1.1.4. Number of Abortions [concept: NUMBER OF ABORTIONS, field_type: number, pos: 3, condition: __$("1.1.1").value > 1, tt_pageStyleClass: NumbersOnly, absoluteMin: 0, Max: 5;  num_babies = __$("1.1.3").value;]

Q.1.1.5. Delivery Mode 1<sup>st</sup> Pregnancy [concept: DELIVERY MODE, name: concept[Delivery Mode], field_type: text, pos: 4, condition: __$("1.1.3").value >= count, tt_onLoad: count = count + 1; ]
O.1.1.5.1. Breech delivery
O.1.1.5.2. Vacuum extraction delivery
O.1.1.5.3. Caesarean Section
O.1.1.5.4. Spontaneous vaginal delivery

Q.1.1.6. Delivery Mode 2<sup>nd</sup> Pregnancy [concept: DELIVERY MODE, name: concept[Delivery Mode], field_type: text, pos: 5, condition: __$("1.1.3").value >= count, tt_onLoad: count = count + 1]
O.1.1.6.1. Breech delivery
O.1.1.6.2. Vacuum extraction delivery
O.1.1.6.3. Caesarean Section
O.1.1.6.4. Spontaneous vaginal delivery

Q.1.1.8. Delivery Mode 3<sup>rd</sup> Pregnancy [concept: DELIVERY MODE, name: concept[Delivery Mode], field_type: text, pos: 6, condition: __$("1.1.3").value >= count, tt_onLoad: count = count + 1]
O.1.1.8.1. Breech delivery
O.1.1.8.2. Vacuum extraction delivery
O.1.1.8.3. Caesarean Section
O.1.1.8.4. Spontaneous vaginal delivery

Q.1.1.9. Delivery Mode 4<sup>th</sup> Pregnancy [concept: DELIVERY MODE, name: concept[Delivery Mode], field_type: text, pos: 7, condition: __$("1.1.3").value >= count, tt_onLoad: count = count + 1]
O.1.1.9.1. Breech delivery
O.1.1.9.2. Vacuum extraction delivery
O.1.1.9.3. Caesarean Section
O.1.1.9.4. Spontaneous vaginal delivery

Q.1.1.10. Delivery Mode 5<sup>th</sup> Pregnancy [concept: DELIVERY MODE, name: concept[Delivery Mode], field_type: text, pos: 8, condition: __$("1.1.3").value >= count, tt_onLoad: count = count + 1]
O.1.1.10.1. Breech delivery
O.1.1.10.2. Vacuum extraction delivery
O.1.1.10.3. Caesarean Section
O.1.1.10.4. Spontaneous vaginal delivery

Q.1.1.11. Delivery Mode 6<sup>th</sup> Pregnancy [concept: DELIVERY MODE, name: concept[Delivery Mode], field_type: text, pos: 9, condition: __$("1.1.3").value >= count, tt_onLoad: count = count + 1]
O.1.1.11.1. Breech delivery
O.1.1.11.2. Vacuum extraction delivery
O.1.1.11.3. Caesarean Section
O.1.1.11.4. Spontaneous vaginal delivery

Q.1.1.12. Delivery Mode 7<sup>th</sup> Pregnancy [concept: DELIVERY MODE, name: concept[Delivery Mode], field_type: text, pos: 10, condition: __$("1.1.3").value >= count, tt_onLoad: count = count + 1]
O.1.1.12.1. Breech delivery
O.1.1.12.2. Vacuum extraction delivery
O.1.1.12.3. Caesarean Section
O.1.1.12.4. Spontaneous vaginal delivery

Q.1.1.13. Delivery Mode 8<sup>th</sup> Pregnancy [concept: DELIVERY MODE, name: concept[Delivery Mode], field_type: text, pos: 11, condition: __$("1.1.3").value >= count, tt_onLoad: count = count + 1]
O.1.1.13.1. Breech delivery
O.1.1.13.2. Vacuum extraction delivery
O.1.1.13.3. Caesarean Section
O.1.1.13.4. Spontaneous vaginal delivery

Q.1.1.14. Delivery Mode 9<sup>th</sup> Pregnancy [concept: DELIVERY MODE, name: concept[Delivery Mode], field_type: text, pos: 12, condition: __$("1.1.3").value >= count, tt_onLoad: count = count + 1]
O.1.1.14.1. Breech delivery
O.1.1.14.2. Vacuum extraction delivery
O.1.1.14.3. Caesarean Section
O.1.1.14.4. Spontaneous vaginal delivery

Q.1.1.15. Delivery Mode 10<sup>th</sup> Pregnancy [concept: DELIVERY MODE, name: concept[Delivery Mode], field_type: text, pos: 13, condition: __$("1.1.3").value >= count, tt_onLoad: count = count + 1]
O.1.1.15.1. Breech delivery
O.1.1.15.2. Vacuum extraction delivery
O.1.1.15.3. Caesarean Section
O.1.1.15.4. Spontaneous vaginal delivery

Q.1.1.16. TTV Status [concept: TT STATUS, field_type: number, pos: 14, absoluteMin: 0, max: 5, tt_pageStyleClass: NumbersOnly]

Q.1.1.18. Next URL [pos: 16, name: ret, value: post-natal, type: hidden]
