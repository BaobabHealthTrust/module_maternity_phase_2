P.1. Update Outcome [program: UNDER 5 PROGRAM, scope: TODAY, ignore: true, label: Baby Discharge Outcome, pos: 12]
C.1.1. Given a mother who has delivered, capture her baby delivery mode

Q.1.1.1. Scan baby barcode [pos: 0, condition: false, concept: Baby identifier, value: <%= params["baby_national_id"]%>]

Q.1.1.2. Delivery Mode [pos: 1, concept: STATUS OF BABY, tt_OnLoad: $("touchscreenInput" + tstCurrentPage).value = "<%= params['value']%>"; if ("<%= params["value"]%>".trim().toLowerCase() == "dead"){gotoNextPage()}, field_type: text, helpText: <%= params["baby_name"]%> discharge outcome]
O.1.1.2.1. Dead
O.1.1.2.2. Alive
