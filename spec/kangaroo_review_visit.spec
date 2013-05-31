P.1. Kangaroo review visit [program: MATERNITY PROGRAM]
C.1. Given a baby that passed through Kangaroo ward, when they come for a review visit:
Q.1.1. Scan baby barcode [pos: 0, concept: Baby identifier, tt_onLoad: __$("keyboard").style.display = "none"]
Q.1.2. Weight (grams) [concept: Weight, pos: 1, field_type: number, absoluteMin: 100, min: 500, max: 5000, absoluteMax: 10000, tt_pageStyleClass: NumbersOnlyWithDecimal]
Q.1.3. Return visit date [pos: 2, field_type: calendar, tt_onLoad: showCategory("Return visit date"), ajaxCalendarUrl: /patients/number_of_booked_patients?date=, value: <%= Date.today.strftime("%Y-%m-%d") %>]

