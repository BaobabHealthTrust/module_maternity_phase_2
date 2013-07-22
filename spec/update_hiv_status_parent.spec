P.1. UPDATE HIV STATUS [program: MATERNITY PROGRAM, scope: RECENT, pos: 30, label: Update HIV Status, concept: HIV Status]
C.1.1. Given a Pregnant woman, capture their HIV status

Q.1.1.1. HIV Status [concept: HIV STATUS, pos: 0]
O.1.1.1.1. Positive
O.1.1.1.2. Negative

Q.1.1.2. HIV Test Visit [concept: HIV TEST VISIT, pos: 1]
O.1.1.2.1. Current Visit
O.1.1.2.2. Previous Visit

Q.1.1.3. HIV Test Date [concept: HIV TEST DATE, tt_onUnLoad: checkHIVTestDate("1.1.3"), field_type: date, pos: 2]
