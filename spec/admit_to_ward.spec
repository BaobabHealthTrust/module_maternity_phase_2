P.1. Admit Patient [program: MATERNITY PROGRAM, scope: TODAY, label: Admit to ward, pos: 50]

Q.1.1.2. Admit to this Ward? [pos: 1, tt_onLoad: try{$("cancelButton").style.display = "none"}catch(c){}, tt_BeforeUnLoad: if($("1.1.2").value.toLowerCase().trim() == "no"){ $("1.1.3").value = ""}, concept: Admit to ward]
O.1.1.2.1. No
O.1.1.2.2. Yes

Q.1.1.3. Location [pos: 2, condition: false, concept: Admission Section, value: <%= Location.find(params["location_id"]).name rescue nil%>]



