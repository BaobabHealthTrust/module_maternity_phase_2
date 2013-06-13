P.1. Baby delivery [program: MATERNITY PROGRAM, label: Baby Delivery, pos: 6, parent: 2]
C.1.1. Given a mother that has delivered, for each selected baby

Q.1.1.1. Scan baby barcode (Optional) [pos: 0, optional: true, concept: Baby identifier, tt_onLoad: __$("keyboard").style.display = "none"; checkBarcodeInput();]

Q.1.1.2. Date of delivery [pos: 1, name: concept[Date of delivery], field_type: date, concept: Date of delivery, helpText: Date of delivery]

Q.1.1.3. Time of delivery [pos: 2, name: concept[Time of delivery], field_type: advancedTime, concept: Time of delivery, helpText: Time of delivery]

Q.1.1.4. Gender [pos: 3, name: concept[Gender], concept: Gender, helpText: Gender]
O.1.1.4.1. Male
O.1.1.4.2. Female

Q.1.1.5. Birth weight [pos: 4, name: concept[Birth weight], min: 2500, max: 4500, absoluteMin: 100, absoluteMax: 8000, field_type: number, tt_pageStyleclass: NumbersOnlyWithDecimal, concept: Birth weight, helpText: Birth weight (grams)]

Q.1.1.7. Place of delivery [pos: 5, name: concept[Place of delivery], concept: Place of delivery, helpText: Place of delivery]
O.1.1.7.1. This facility
O.1.1.7.2. In transit
O.1.1.7.3. Other facility
O.1.1.7.4. Home/TBA

Q.1.1.8. Delivery mode [pos: 6, name: concept[Delivery mode], concept: Delivery mode, helpText: Delivery mode]
O.1.1.8.1. Spontaneous vaginal delivery
O.1.1.8.2. Vacuum extraction delivery
O.1.1.8.3. Breech delivery
O.1.1.8.4. Caesarean section

Q.1.1.9. Newborn baby complications [pos: 7, name: concept[Newborn baby complications], concept: Newborn baby complications, helpText: Newborn baby complications]
O.1.1.9.1. None
O.1.1.9.2. Weight less than 2500g
O.1.1.9.3. Prematurity
O.1.1.9.4. Asphyxia
O.1.1.9.5. Sepsis
O.1.1.9.6. Other


