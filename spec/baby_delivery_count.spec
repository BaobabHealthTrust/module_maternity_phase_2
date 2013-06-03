P.1. Baby delivery [program: MATERNITY PROGRAM, ignore: true, label: Baby Delivery Count, scope: EXISTS, concept: Number of babies]
C.1.1. Given a mother that has delivered

C.1.1. Baby
Q.1.1.1. Number of babies delivered [pos: 0, concept: Number of babies, field_type: number, tt_pageStyleclass: NumbersOnly, absoluteMin: 1, max: 5, absoluteMax: 10, tt_onUnLoad: __$("1.1.2").value = __$("1.1.2").value + __$("touchscreenInput" + tstCurrentPage).value]

Q.1.1.2. Next URL [pos: 1, name: next_url, type: hidden, value: /protocol_patients/baby_delivery?user_id=<%= @user.id %>&patient_id=<%= @patient.id %>&baby=1&baby_total=]

