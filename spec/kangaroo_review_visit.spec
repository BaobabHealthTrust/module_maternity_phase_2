P.1. Kangaroo review visit [program: UNDER 5 PROGRAM, pos: 9, scope: TODAY, parent: 2, concept: Return visit date]
C.1. Given a baby that passed through Kangaroo ward, when they come for a review visit:

Q.1.2. Weight (grams) [concept: Weight, pos: 1, field_type: number, absoluteMin: 100, min: 500, max: 5000, absoluteMax: 10000, tt_pageStyleClass: NumbersOnlyWithDecimal]

Q.1.3. Return visit date [pos: 2, field_type: calendar, tt_onLoad: showCategory("Return visit date"), ajaxCalendarUrl: /patients/number_of_booked_patients?date=, value: <%= (@session_date.to_date  rescue Date.today).strftime("%Y-%m-%d") %>]

