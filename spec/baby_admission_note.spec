P.1. Admit patient [program: UNDER 5 PROGRAM, includejs: generalCondition, includecss: generalCondition, label: Baby Admission Note, pos: 105, parent: 2]
C.1. If baby has been admitted to ward

Q.1.1. Scan baby barcode [pos: 0, concept: Baby identifier, tt_onLoad: __$("keyboard").style.display = "none"; id_string = "<%= @patient.babies_national_ids%>"; try{nat_id = "<%= params['national_id'] rescue ''%>"; if (nat_id.length > 1){__$("touchscreenInput" + tstCurrentPage).value = nat_id + "$";}}catch(ex){}; checkBarcodeInput();]
