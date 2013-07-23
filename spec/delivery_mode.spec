P.1. Update Outcome [program: MATERNITY PROGRAM, scope: TODAY, ignore: true, label: Delivery Mode, pos: 12]
C.1.1. Given a mother who has delivered, capture her baby delivery mode

Q.1.1.1. Scan baby barcode [pos: 0, concept: Baby identifier, tt_onLoad: __$("keyboard").style.display = "none"; checkBarcodeInput(); id_string = "<%= @patient.babies_national_ids%>"; try{nat_id = "<%= params['national_id'] rescue ''%>"; if (nat_id.length > 1){__$("touchscreenInput" + tstCurrentPage).value = nat_id + "$";}}catch(ex){}]

Q.1.1.2. Delivery Mode [pos: 1, condition: id_string.match(__$("1.1.1").value), concept: STATUS OF BABY, field_type: text, ajaxURL: /encounters/baby_delivery_mode?search_string=, helpText: Delivery Mode <%= params["baby"] + ((params["baby"].to_i == 1) ? "<sup>st</sup>" | ((params["baby"].to_i == 2) ? "<sup>nd</sup>" | ((params["baby"].to_i == 3) ? "<sup>rd</sup>" | "<sup>th</sup>" ))) %> baby]

Q.1.1.3. Next URL [pos: 2, condition: id_string.match(__$("1.1.1").value), name: next_url, value: /two_protocol_patients/delivery_mode?user_id=<%= @user.id %>&patient_id=<%= @patient.id %>&baby=<%= params["baby"].to_i + 1 %>&baby_total=<%= params["baby_total"]%>, type: hidden, ruby: <%= (params["baby"].to_i >= params["baby_total"].to_i ? "disabled" | "") %>]
