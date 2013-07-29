P.1. Vitals [program: MATERNITY PROGRAM, scope: TODAY, concept: Systolic Blood Pressure, includejs: vitals, pos: 34, label: Post Natal Vitals, parent: 3]
C.1.1. Given a registered patient, capture Vitals

Q.1.1.1. Systolic Blood Pressure [concept: SYSTOLIC BLOOD PRESSURE, field_type: number, tt_onLoad: bpOn = 1; bpAlerts(); calculateBP("1.1.1*1.1.2*1"); attribute("1.1.1*validationRule*([0-9]+\\.[0-9])|Unknown$"); attribute("1.1.1*validationMessage*You must enter a decimal between 0 and 9 (for example 36<b>.6</b>)"), min: 90, max: 140, tt_pageStyleClass: Numeric NumbersOnlyWithDecimal, pos: 0, allowFreeText: true, absoluteMin: 20, absoluteMax: 250, units: mm Hg, tt_onUnLoad: window.clearInterval(timedEvent); temp = ""; bpOn = false;]

Q.1.1.2. Diastolic Blood Pressure [concept: DIASTOLIC BLOOD PRESSURE, field_type: number, tt_onLoad: bpOn = 2; bpAlerts(); calculateBP("1.1.1*1.1.2*2"); attribute("1.1.2*validationRule*^([0-9]+)|Unknown$"), min: 60, max: 90, tt_pageStyleClass: Numeric NumbersOnlyWithDecimal, pos: 1, allowFreeText: true, absoluteMin: 35, absoluteMax: 135, units: mm Hg, tt_onUnLoad: window.clearInterval(timedEvent); temp = ""; bpOn = false;]

Q.1.1.3. Pulse (Beats Per Minute)[concept: PULSE, field_type: number, tt_onLoad: attribute("1.1.3*validationRule*([0-9]+)|Unknown$"), min: 50, max: 120, tt_pageStyleClass: Numeric NumbersOnlyWithDecimal, pos: 3, absoluteMin: 0, absoluteMax: 160, units: bpm]

Q.1.1.4. Respiration (Breaths Per Minute) [concept: RESPIRATION, field_type: number, tt_onLoad: attribute("1.1.4*validationRule*([0-9]+)|Unknown$"), min: 12, max: 20, tt_pageStyleClass: Numeric NumbersOnlyWithDecimal, pos: 4, absoluteMin: 0, absoluteMax: 200, units: bpm]

Q.1.1.5. Temperature [helpText: Temperature (<sup>o</sup>C), concept: TEMPERATURE, field_type: number, tt_onLoad: attribute("1.1.5*validationRule*([0-9]+)|Unknown$"), min: 36.5, max: 37.5, tt_pageStyleClass: Numeric NumbersOnlyWithDecimal, pos: 5, absoluteMin: 0, absoluteMax: 100]

Q.1.1.6. Next URL [pos: 6, name: ret, value: post-natal, type: hidden]
