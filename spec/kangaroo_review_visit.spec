P.1. Kangaroo review visit [program: MATERNITY PROGRAM, pos: 9, parent: 2]
C.1. Given a baby that passed through Kangaroo ward, when they come for a review visit:

Q.1.1. Scan baby barcode [pos: 0, concept: Baby identifier, tt_onLoad: __$("keyboard").style.display = "none"; checkBarcodeInput(); wards_map = {}; wards_map = wardsHash("<%= @patient.wards_hash%>"); ]

Q.1.2. Weight (grams) [concept: Weight, pos: 1, field_type: number, absoluteMin: 100, min: 500, max: 5000, tt_onLoad: try{__$("category").style.display = "none"}catch(ex){}, condition: try{wards_map[$("1.1").value].toLowerCase().trim() == "kangaroo"}catch(ex){false}, absoluteMax: 10000, tt_pageStyleClass: NumbersOnlyWithDecimal]

Q.1.3. Return visit date [pos: 2, field_type: calendar, tt_onUnLoad: if (wards_map[$("1.1").value].toLowerCase().trim() != "kangaroo"){__$("1.3").value = ""}, condition: try{wards_map[$("1.1").value].toLowerCase().trim() == "kangaroo"}catch(ex){false}, tt_onLoad: showCategory("Return visit date"), ajaxCalendarUrl: /patients/number_of_booked_patients?date=, value: <%= Date.today.strftime("%Y-%m-%d") %>]

