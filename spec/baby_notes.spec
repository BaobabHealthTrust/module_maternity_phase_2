P.1. Observations [program: MATERNITY PROGRAM, scope: TODAY, label: Notes, pos: 14, parent: 2, concept: Clinician Notes]
C.1.1. Given a registered patient, Notes

Q.1.1.1. Scan baby barcode [pos: 0, concept: Baby identifier, tt_onLoad: __$("keyboard").style.display = "none"; checkBarcodeInput(); id_string = "<%= @patient.babies_national_ids%>"; try{nat_id = "<%= params['national_id'] rescue ''%>"; if (nat_id.length > 1){__$("touchscreenInput" + tstCurrentPage).value = nat_id + "$";}}catch(ex){}]

Q.1.1.2. Notes [concept: CLINICIAN NOTES, field_type: text, condition: id_string.match(__$("1.1.1").value), allowFreeText: true, pos: 1, optional: true]

