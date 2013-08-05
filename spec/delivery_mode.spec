P.1. Update Outcome [program: MATERNITY PROGRAM, scope: TODAY, ignore: true, label: Baby Discharge Outcome, pos: 12]
C.1.1. Given a mother who has delivered, capture her baby delivery mode

Q.1.1.1. Scan baby barcode [pos: 0, condition: false, concept: Baby identifier, value: <%= params["baby_national_id"]%>]

Q.1.1.2. Delivery Mode [pos: 1, concept: STATUS OF BABY, tt_OnLoad: $("touchscreenInput" + tstCurrentPage).value = "<%= params['value']%>"; if ("<%= params["value"]%>".trim().toLowerCase() == "dead"){gotoNextPage()}, field_type: text, helpText: <%= params["baby_name"]%> discharge outcome]
O.1.1.2.1. Dead
O.1.1.2.2. Alive

Q.1.1.3. Next URL [pos: 2, condition: id_string.match(__$("1.1.1").value), name: next_url, value: /two_protocol_patients/delivery_mode?user_id=<%= @user.id %>&patient_id=<%= @patient.id %>&baby=<%= params["baby"].to_i + 1 %>&baby_total=<%= params["baby_total"]%>, type: hidden, ruby: <%= (params["baby"].to_i >= params["baby_total"].to_i ? "disabled" | "") %>]
