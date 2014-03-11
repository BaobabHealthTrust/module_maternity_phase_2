P.1. Social History [program: MATERNITY PROGRAM, scope: RECENT, concept: guardian first name, pos: 31]
C.1.1. Given a registered patient, capture their Social history

Q.1.1.1. Education Level [concept: EDUCATION LEVEL, pos: 0]
O.1.1.1.1. Primary
O.1.1.1.2. Secondary
O.1.1.1.3. Tertiary
O.1.1.1.4. None
O.1.1.1.5. Other

Q.1.1.2. Religion [concept: RELIGION, field_type: text, ajaxURL: /encounters/religion?search_string=, pos: 1]

Q.1.1.2.1. Specify Other Religion [concept: OTHER, field_type: text, condition: __$("1.1.2").value == "Other", pos: 2]

Q.1.1.3. Next Of Kin First Name [concept: Guardian First Name, field_type: text, pos: 3]

Q.1.1.4. Next Of Kin Last Name [concept: Guardian Last Name, field_type: text, pos: 4]

Q.1.1.5. Next Of Kin Phone Number [concept: Next of Kin Telephone, validationRule: ^0\d{7}$|Unknown|Not Available|^0\d{9}$|^N\/A$, validationMessage: Not a valid phone number, field_type: number, tt_pageStyleClass: nota NumbersOnlyWithUnknown, pos: 4]

Q.1.1.6. Next Of Kin Relation Type [concept: GUARDIAN RELATION, pos: 6, ajaxURL: /encounters/relation_type?search_string=]

Q.1.1.6.1. Specify Other Relation Type [concept: OTHER RELATIVE, field_type: text, condition: __$("1.1.6").value == "Other", pos: 7]


