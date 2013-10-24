/*
 * Custom javascript code goes in here.
 *
 **/

var mother_status = "";
var timedEvent = "";
var temp = ""
var lmp = "";
var name = '';
var bpOn = '';
var currentConcept = "";
var artData = {};

function check(id){
    var sum = 0;
    var loc = document.location.toString();
    var gravida = parseInt($("1.1.1").value);
  
    if (id == "1.1.5"){
        sum = parseInt($("1.1.5").value)
        if (sum < gravida){
            var vall = loc.match(/ante\_natal/i)? (gravida - sum - 1) : (gravida - sum)
            $("1.1.6").setAttribute("absoluteMax", vall);
            if (vall == 0){
                $("1.1.6").value = vall
            }
        }else{          
    //$("touchscreeninput" + tstCurrentPage + 1).setAttribute("condition", false)
    }
    }
    
    if (id == "1.1.6"){
        sum = parseInt($("1.1.5").value) + parseInt($("1.1.6").value)
        if (sum < gravida){
            var vall = loc.match(/ante\_natal/i)? (gravida - sum - 1) : (gravida - sum)
            $("1.1.7").setAttribute("absoluteMax", vall);
            if (vall == 0){
                $("1.1.7").value = vall
            }
        }else{
    //$("touchscreeninput" + tstCurrentPage + 1).setAttribute("condition", false)
    }
    }
    
    if (id == "1.1.7"){
        sum = parseInt($("1.1.5").value) + parseInt($("1.1.6").value) + parseInt($("1.1.7").value)
        if (sum < gravida){
            var vall = loc.match(/ante\_natal/i)? (gravida - sum - 1) : (gravida - sum)
            $("1.1.8").setAttribute("absoluteMax", vall);
            if (vall == 0){
                $("1.1.8").value = vall
            }
        }else{           
            
    }
    }
  
}

function checkDeliveriesLimits(cat){
    var gravida = parseInt($("1.1.1").value);

    if (cat == "ante-natal"){
        $("touchscreenInput" + tstCurrentPage).setAttribute("absoluteMax", (gravida - 1));
    }else{
        $("touchscreenInput" + tstCurrentPage).setAttribute("absoluteMax", gravida);
    }
}

function checkWeightSize(id){
    try{
        if(parseInt($(id).value) < 2500){

            showMessage("Admit Baby to Nursery Ward!", true);
            return true;
        }
        return false;
    }catch(ex){
        
    }
}

function checkAbortionsLimits(cat){
    var gravida = parseInt($("1.1.1").value);
    var deliveries = parseInt($("1.1.3").value);
    var diff = parseInt(gravida) - parseInt(deliveries);
    if (cat == "ante-natal"){
        $("1.1.4").setAttribute("absoluteMax", (diff - 1));
        $("1.1.4").setAttribute("absoluteMin", (diff - 1));
        $("1.1.5").setAttribute("absoluteMax", (gravida - 1));
        $("1.1.4").value = diff - 1;
    }else{
        $("1.1.4").setAttribute("absoluteMax", diff);
        $("1.1.4").setAttribute("absoluteMin", diff);
        $("1.1.5").setAttribute("absoluteMax", gravida);
        $("1.1.4").value = diff;
    }
}

function checkArtData(national_id){
    if ($("touchscreenInput" + tstCurrentPage).value.toLowerCase().trim() == "reactive"){
        artPull(national_id);
    }
}

function setMax(id){
    __$(id).setAttribute("absoluteMax", parseInt(__$("touchscreenInput" + tstCurrentPage).value) - 1)
}

function showAPGAR(){
    __$("page" + tstCurrentPage).innerHTML = "";

    __$("keyboard").style.display = "none";
    
    
    __$("page" + tstCurrentPage).style.backgroundColor = "#eee";
}

function unloadAPGAR(){
    
}

function checkBarcodeInput(){
    var input = __$("touchscreenInput" + tstCurrentPage).value;

    if (input.match(/\$/) && input.length > 2){
        __$("touchscreenInput" + tstCurrentPage).value = input.replace(/\$/, "")
        gotoNextPage();
    }else{
        setTimeout(function(){
            checkBarcodeInput();
        }, 10);
    }
}

function wardsHash(string){
    
    var babies_map = string.split("|");
    var map = {}
    for (var i = 0; i < babies_map.length; i ++){
        map[babies_map[i].split("--")[0]] = babies_map[i].split("--")[1];
    }
  
    return map
}

function setDate(elementId){

    if ($(elementId).value.toLowerCase() == 'unknown'){
        $(elementId+'_value_datetime').value = null;
        $(elementId+'_value_modifier').value = null;
    }
    else{
        $(elementId+'_value_datetime').value = new Date($(elementId).value);  //.replace(/-/g, '/'));
    }
}

function checkHIVTestDate(id){
    var hiv_test_date_str = $(id).value.replace(/-/g, '/');
    var hiv_test_date     = new Date(hiv_test_date_str);
    var today             = new Date(Date.now());

    var weeks_ago = parseInt((today.getTime()- hiv_test_date.getTime())/ (1000 * 60 * 60 * 24 * 7));

    if (weeks_ago > 12){
        showMessage("Patient needs to be tested now!", true);
        return "true";
    }
    return "false";
}

// Every 500 milliseconds update the Next/Finish button
function updateNextFinish(){
    if (tstInputTarget.value == '')
        $('nextButton').innerHTML = '<span>Finish</span>';
    else
        $('nextButton').innerHTML = '<span>Next</span>';
    setTimeout(updateNextFinish, 500)
}

function calculateEDOD(){
    var edod = "";
    var gestation = "";
    var month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    if(!$('expected_date_of_delivery')){
        var div = document.createElement("div");
        div.id = "expected_date_of_delivery";
        div.className = "statusLabel";

        $("inputFrame" + tstCurrentPage).appendChild(div);
    }

    if($("touchscreenInput" + tstCurrentPage).value.trim().length > 0 &&
        $("touchscreenInput" + tstCurrentPage).value.trim() != "Unknown"){

        var theDate = new Date($("touchscreenInput" + tstCurrentPage).value.trim());

        theDate.setDate(theDate.getDate() + 7);

        var today = new Date();

        var s = today - theDate;

        gestation = String(Math.floor(s / (24 * 60 * 60 * 7 * 1000)));

        theDate.setMonth(theDate.getMonth() + 9);

        edod = (theDate.getDate() + "-" + month[theDate.getMonth()] + "-" + theDate.getFullYear());

    }

    $("expected_date_of_delivery").innerHTML = "Expected Date Of Delivery: <i style='font-size: 1.2em; float: right;'>" +
    edod + "</i><br /><br />Gestation Weeks: " + (gestation < 37 &&
        gestation.trim().length > 0 ? "<i style='color: red'>(Premature)</i>" : (gestation > 41 && gestation.trim().length > 0 ? "<i style='color: red'>(Abnormal)</i>" : "")) +
    "<i style='font-size: 1.2em; float: right; width: 100px;'>" + gestation + "</i>";

    timedEvent = setTimeout('calculateEDOD()', 500);
}


function changeIds(){
    
    $("6").style.display = "none";
    $("7").style.display = "none";
    $("8").style.display = "none";
    $("9").style.display = "none";
    $("zero").style.display = "none";

    $("clearButton").onclick = function(){
        enableButtons();
    }
    $("1").onclick = function(){
        disableButtons();
    }
    $("2").onclick = function(){
        disableButtons();
    }
    $("3").onclick = function(){
        disableButtons();
    }
    $("4").onclick = function(){
        disableButtons();
    }
    $("5").onclick = function(){
        disableButtons();
    }
}

function disableButtons(){
    $("1").className = "keyboardButton gray";
    $("2").className = "keyboardButton gray";
    $("3").className = "keyboardButton gray";
    $("4").className = "keyboardButton gray";
    $("5").className = "keyboardButton gray";

    $("1").onmousedown = function(){};
    $("2").onmousedown = function(){};
    $("3").onmousedown = function(){};
    $("4").onmousedown = function(){};
    $("5").onmousedown = function(){};
}

function enableButtons(){
    $("1").className = "keyboardButton blue";
    $("2").className = "keyboardButton blue";
    $("3").className = "keyboardButton blue";
    $("4").className = "keyboardButton blue";
    $("5").className = "keyboardButton blue";

    $("1").onmousedown = function() {
        press('1');
    }
    $("2").onmousedown = function() {
        press('2');
    }
    $("3").onmousedown = function() {
        press('3');
    }
    $("4").onmousedown = function() {
        press('4');
    }
    $("5").onmousedown = function() {
        press('5');
    }
}
function calculatePeriodOnARVs(){
    var periodOnARVs = 0;
    var date_started = $("touchscreenInput" + tstCurrentPage).value.trim() + " 00:00"
    var one_month = 1000*60*60*24*30;
    var date = createDate(date_started);
    var today = new Date();
    var periodOnARVs = Math.round(Math.abs(today - date)/one_month);
    return periodOnARVs;
}
function showPeriodOnARVs(){
  
    if(!$('arv_period')){
        var div = document.createElement("div");
        div.id = "arv_period";
        div.className = "statusLabel";
        $("inputFrame" + tstCurrentPage).appendChild(div);
    }

    $('arv_period').innerHTML = "<i style='font-size: 1.2em;float: left;'> Period On ARVs    </i> "
    +  "<i style='font-size: 1.2em;float: right;'>" + calculatePeriodOnARVs() + ((calculatePeriodOnARVs() == 1)? " Month</i>" : " Months</i>")
}

function checkHIVTestUnkown(id){
    if($(id).value.toLowerCase() == "unknown"){

        showMessage("Patient needs to be tested now!", true);
        return true;
    }
    return false;
}

function checkNVPStart(id){
    if($(id).value.toLowerCase().trim() == "no"){

        showMessage("Baby needs to start NVP Now!", true);
        return true;
    }
    return false;
}

function checkVDRLStatus(id){
    if($(id).value.toLowerCase().trim() == "reactive"){

        showMessage("Patient needs treatment now!", true);
        return true;
    }
    return false;
}

function checkFeedingStart(id){
    if($(id).value.toLowerCase().trim() == "no"){

        showMessage("Baby needs to start feeding Now!", true);
        return true;
    }
    return false;
}

function checkARTStart(id){
    if($(id).value.toLowerCase().trim() == "no"){

        showMessage("Start ARV's Now!", true);
        return true;
    }
    return false;
}

function isValidDateFormat(value){
    return value.trim().match(/(\d{4})\-(\d{2})\-(\d{2})\s(\d{2})\:(\d{2})/);
}
function createDate(value){
    var d = isValidDateFormat(value);
    if(d){
        return new Date(eval(d[1]),(eval(d[2])-1),eval(d[3]),eval(d[4]),eval(d[5]));
    } else {
        return new Date();
    }
}

function weightAlert(str){
    gender_id = str.split("*")[1]
    if(!$('weight_label')){
        var div = document.createElement("div");
        div.id = "weight_label";
        div.className = "statusLabel";

        gender = $(gender_id).value;
        if (gender == "Male"){
            maxi = 4500;
            mini = 2500;
        }else if (gender == "Female"){
            maxi = 4400;
            mini = 2400;
        }
        $("inputFrame" + tstCurrentPage).appendChild(div);

    }
    weight = $("touchscreenInput" + tstCurrentPage).value.trim();
    if (weight != ""){
        $('weight_label').innerHTML = ((weight > maxi )? "<i style='font-size: 1.2em;color: red;float: right;'> Over Weight</i>" : ((weight < mini)? "<i  style='font-size: 1.2em;float: right;color: red;'>Under Weight</i>"  : ""));
        if (weight < maxi && weight > mini){
            $('weight_label').innerHTML = "<i style='float:right;font-size:1.2em;'>  Normal Weight</i>";
        }
    }else {
        $('weight_label').innerHTML = "<i style='float:left;font-size:1.2em;'>  Enter Weight</i>";
    }

    if (temp != "alert_done"){
        timedEvent = self.setInterval(function(){
            weightAlert(str)
        }, 100);
        temp = "alert_done";
    }
}

function attribute(str){
    id = str.split("*")[0]
    atr = str.split("*")[1]
    val = str.split("*")[2]
    __$(id).setAttribute(atr, val)
}

function calculateBP(str){
    id1 = str.split("*")[0]
    id2 = str.split("*")[1]
    pos = str.split("*")[2]

    var bp;

    if(!$('bp')){
        var div = document.createElement("div");
        div.id = "bp";
        div.className = "statusLabel";

        $("inputFrame" + tstCurrentPage).appendChild(div);
    }

    if(pos == 1){
        bp = ($("touchscreenInput" + tstCurrentPage).value.trim().length > 0 ? $("touchscreenInput" +
            tstCurrentPage).value.trim() : "?") +
        "/" + ($(id2).value.trim().length > 0 ? $(id2).value.trim() : "?");
    } else if(pos == 2){
        bp = ($(id1).value.trim().length > 0 ? $(id1).value.trim() : "?") +
        "/" + ($("touchscreenInput" + tstCurrentPage).value.trim().length > 0 ? $("touchscreenInput" +
            tstCurrentPage).value.trim() : "?");
    }

    $("bp").innerHTML = "Blood Pressure: <i style='font-size: 1.2em; float: right;'>" + bp + "</i>";

    if (temp != "event_set"){
        timedEvent = setInterval(function(){
            calculateBP(str)
        }, 200);
        temp = "event_set"
    }
}

function updateFromVariables(){
    //show period on ARVs
    try{
        if (currentConcept.match(/art start date/i)){
            showPeriodOnARVs();
        }else{
            $("arv_period").style.display = "none"
        }
    }catch(ex){
    
    }
    conc = currentConcept.toLowerCase().trim();
    try{
        if (conc == "plan" || conc == "impression" || conc == "clinician notes" || conc == "notes"){

        }else{
            try{

            }catch(ex){
                $("arv_period").style.display = "none"
            }
        }
    }catch(ex){

    }


    try{
        
        if (tt_cancel_destination.match(/autoflow/)){
            tt_cancel_destination.replace(/autoflow\=true/g, "autoflow=false")
        }else{
            tt_cancel_destination += "&autoflow=false";
        }

        var pageConcept = $("touchscreenInput" + tstCurrentPage).name.replace(/concept\[|]/g, "");
        var params = document.location.toString().split("&");
        var paramz = document.location.toString().replace("//", "").split(/\//);

        for (var k = 0; k < params.length; k ++){

            try{

                if (params[k].match(/ret\=/i) || paramz[1].match(/protocol\_patient/i) && !pageConcept.match(/APGAR/i)){
                    var ret = params[k].split("=")[1].replace("-", " ");
                    var encounter = paramz[2].split("?")[0].replace(/\_/g, " ").replace(/\-/g, " ")

                    encounter = encounter.split("")
                    encounter[0] = encounter[0].toUpperCase();
                    encounter = encounter.join("")

                    showCategory(encounter);
                }

            }catch(e){
                
            }
            
            if (params[k].match(/autoflow/i)){
                for (var i = 0; i < document.forms.length; i ++){
                    if (document.forms[i].action.match(params[k])){
                        
                    }else{
                        document.forms[i].action += document.forms[i].action.match(/\?/) ? ("&" + params[k]) : ("?" + params[k])
                    }
                }
            }
            

        }
        setTimeout("updateFromVariables()", 100);
        
    }catch(ex){
        if (document.location.toString().match(/protocol\_patients/)){         
            setTimeout("updateFromVariables()", 100)
        }
    }
   
}


function checkANCLMP(){
    lmp = lmp.replace("/", "-")
   
    if (lmp.length > 1){
        var checked = dispatchMessage("Accept Date " + lmp + name_clause + "<br> From ANC LMP?", tstMessageBoxType.YesNo);
        if (checked == true){
            try{
                buttons = $("messageBar").getElementsByClassName("button");
                if (buttons[0].innerHTML.match(/Yes/i)){
                    buttons[0].onclick = function(){
                        $("touchscreenInput" + tstCurrentPage).value = lmp;
                        $("messageBar").style.display = "none";
                    }
                }
            }catch(ex){}
        }
    }
}


function bpAlerts(){
    if (bpOn == 1 || bpOn == 2){
        var type = bpOn;
        var val = $("touchscreenInput" + tstCurrentPage).value
        var complication = "";

        if (val > 0){
            // check for complications
            var val = parseInt(val);
            if (type == 1){
                complication = (val >= 120 && val <= 139) ? "Prehypertension" : ((val >= 140 && val <= 159 ) ? "Hypertension Stage 1" : ((val >= 160 && val <= 180) ? "Hypertension Stage 2" : ((val > 180)? "Emergency Care Needed" : "")));
            }else{
                complication = (val >= 80 && val <= 89) ? "Prehypertension" : ((val >= 90 && val <= 99 ) ? "Hypertension Stage 1" : ((val >= 100 && val <= 110) ? "Hypertension Stage 2" : ((val > 110)? "Emergency Care Needed" : "")));
            }
        }

        if(!$("bpFlag")){
            try{
                $("bp").innerHTML += "<div style='color:red;width:100%;text-align:center;' id='bpFlag'><i style='float=right;align:center;'>" + complication + "</i></div>";
            }catch(e){};
        }else{
            $("bpFlag").innerHTML = "<div style='color:red;width:100%;text-align:center;' id='bpFlag'><i style='float=right;align:center;'>" + complication + "</i></div>";
        }
        setTimeout("bpAlerts()", 20)
    }
}

function probeValues(){
  
    if (document.location.toString().match(/protocol\_patients/)){  
        try{
            var pageConcept = $("touchscreenInput" + tstCurrentPage).name.replace(/concept\[|]/g, "");
            if (pageConcept != currentConcept){
              
                currentConcept =  pageConcept;

                if (document.location.toString().match(/pmtct/i) && $("touchscreenInput" + tstCurrentPage).value.length == 0){

                    if (currentConcept.toLowerCase().trim() == "art start date"){
                        try{
                            if (artData["START DATE"] && artData["START DATE"] != "" && artData["START DATE"] != undefined){
                                $("touchscreenInput" + tstCurrentPage).value = artData["START DATE"].replace(/\//g, "-")
                            }
                        }catch(ex){
                        
                        }
                    }
 
                    if (currentConcept.toLowerCase().match(/art registration number/i)){
                    
                        try{
                            if (artData["ARV NUMBER"] && artData["ARV NUMBER"] != "" && artData["ARV NUMBER"] != undefined){
                                $("touchscreenInput" + tstCurrentPage).value = artData["ARV NUMBER"]
                            }
                        }catch(ex){

                        }
                    }

                    if (currentConcept.toLowerCase().trim() == "on arvs"){
                        try{
                            if (artData["START DATE"] && artData["START DATE"] != "" && artData["START DATE"] != undefined){
                                $("touchscreenInput" + tstCurrentPage).value = "Yes"
                            }
                        }catch(ex){

                        }
                    }
                }
                var user = "";
                var patient = "";
            
                var inputNodes = document.getElementsByTagName("input")
                for (var i = 0; i < inputNodes.length; i ++){
                    if (inputNodes[i].name == "patient_id"){
                        patient = inputNodes[i].value;
                    }else if (inputNodes[i].name == "user_id"){
                        user = inputNodes[i].value;
                    }
                }
           
                ajaxPull(currentConcept, user, patient);
            }
        }catch(ex){
        
        }
        setTimeout("probeValues()", 300);
    }
}

function ajaxPull(concept, user, patient){

    var httpRequest = new XMLHttpRequest();
    httpRequest.onreadystatechange = function() {

        if ((!httpRequest) || (!concept) || (!patient)) return;
        if (httpRequest.readyState == 4 && (httpRequest.status == 200 ||
            httpRequest.status == 304)) {

            var result = JSON.parse(httpRequest.responseText);
            
            if (result.toString().length > 0){
                if ($("touchscreenInput" + tstCurrentPage).value == 0 && currentConcept.match(/HIV STATUS|ON ARVs|art registration number|art start date/i)){
                    $("touchscreenInput" + tstCurrentPage).value = result
                }

                $('inputFrame' + tstCurrentPage).onclick = function(){
                    if ($("touchscreenInput" + tstCurrentPage).value.length == 0){
                        $("touchscreenInput" + tstCurrentPage).value = result
                    }
                }
                try{
                    $('page' + tstCurrentPage).appendChild(flag)
                }catch(ex){}
            }
        }
    };
    
    try {
        var aUrl = "/encounters/probe_values?concept_name=" + concept + "&patient_id=" + patient + "&user_id=" + user;
        httpRequest.open('GET', aUrl, true);
        httpRequest.send(null);
    } catch(e){
    }
}

function artPull(national_id){
  
    var nat_id = national_id
    var httpRequest = new XMLHttpRequest();
    httpRequest.onreadystatechange = function() {

        if (!httpRequest) return;
        if (httpRequest.readyState == 4 && (httpRequest.status == 200 ||
            httpRequest.status == 304)) {

            var result = JSON.parse(httpRequest.responseText);

            try {
                if (Object.keys(result).length > 0){
                    buildPmtctAlert(result);
                }
            }catch(ex){}

            artData = result
           
        }
    };

    try {
        var aUrl = "/patients/art_summary?national_id=" + national_id;
        httpRequest.open('GET', aUrl, true);
        httpRequest.send(null);
    } catch(e){
    }
}

function setLMPDate(str){
    try{
        var period = str.split("|")[0]
        var date = str.split("|")[1]
        var year = date.split("-")[0]
        var day = date.split("-")[2]
        var month = date.split("-")[1]

        var d = new Date();

        d.setDate(parseInt(day));
        d.setYear(parseInt(year));
        d.setMonth(parseInt(month) - 1);
        
        d.setMonth(d.getMonth() - parseInt(period));
        if (parseInt(period) >= 0){
            __$("1.1.17").value = d.getFullYear() + "-" + padZeros((d.getMonth() + 1), 2) + "-" + padZeros(d.getDate(),2);
        }
    }catch(e){
        __$("1.1.17").value = ""
    }
}

function padZeros(number, positions){
    var zeros = parseInt(positions) - String(number).length;
    var padded = "";

    for(var i = 0; i < zeros; i++){
        padded += "0";
    }

    padded += String(number);

    return padded;
}

function buildPmtctAlert(data){
    /*
     Fields available in data
    1. LAST DATE SEEN
    2. START DATE
    3. ARV NUMBER
    4. LATEST HIV TEST
         I. HIV STATUS
        II. HIV TEST DATE
       III. HTC SERIAL NUMBER
        IV. LOCATION OF HIV TEST
         V. WORKSTATION LOCATION
     */

    var mainHolder = document.createElement("div");
    mainHolder.id = "mainHolder";   
    mainHolder.style.position = "absolute";
    mainHolder.style.zIndex = 97;

    var header = document.createElement("th");
    header.setAttribute("class", "header");
    
    header.innerHTML = "ART DATA FROM ART EMR";
   
    mainHolder.appendChild(header)
    
    var keys = Object.keys(data)

    for (var k = 0; k < keys.length; k ++){

        try{
            if (keys[k].trim() == "LATEST HIV TEST"){
                var hiv_keys = Object.keys(data[keys[k]])

                for (var i = 0; i < hiv_keys.length; i ++){                  
                    mainHolder.appendChild(alertRow(hiv_keys[i], data[keys[k]][hiv_keys[i]]))
                }
                
            }else{
                if (data[keys[k]] && data[keys[k]].length > 0){
                    mainHolder.appendChild(alertRow(keys[k], data[keys[k]]))
                }
            }
        }catch(ex){
            
        }

    }
    
    document.body.appendChild(createCancelButton());
    
    var shield = document.createElement("div");
    shield.id = "lyrShield";
    shield.style.position = "absolute";
    shield.style.width = "100%";
    shield.style.height = "100%";
    shield.style.left = "0px";
    shield.style.top = "0px";
    shield.style.backgroundColor = "#333"; 
    shield.style.opacity = "0.5";
    shield.style.zIndex = 90;
    
    document.body.appendChild(shield);
    
    document.body.appendChild(mainHolder)
    
}

function createCancelButton(){

    var img = document.createElement("div");
    img.id = "image";
    img.style.zIndex = 100;
    img.innerHTML = "&nbsp";

    img.onclick = function(){

        $('mainHolder').parentNode.removeChild($('mainHolder'));
        $('lyrShield').parentNode.removeChild($('lyrShield'));         
        this.parentNode.removeChild(this);
        
        try{
            if ($("touchscreenInput" + tstCurrentPage).value.length == 0 && artData["LATEST HIV TEST"]["HIV TEST DATE"] != "" && artData["LATEST HIV TEST"]["HIV TEST DATE"] != undefined){
                $("touchscreenInput" + tstCurrentPage).value = artData["LATEST HIV TEST"]["HIV TEST DATE"]
            }
        }catch(c){}
    }

    return img;
}

function alertRow(key, value){

    var rowDiv = document.createElement("div");
    rowDiv.setAttribute("class", "alert-row");    
    
    var keyDiv = document.createElement("div");
    keyDiv.setAttribute("class", "alert-key");
    keyDiv.innerHTML = key.replace(/last date seen/i, "LAST DATE SEEN AT ART").replace(/start date/i, "DATE STARTED ARVs");
    rowDiv.appendChild(keyDiv);

    var valueDiv = document.createElement("div");
    valueDiv.setAttribute("class", "alert-value");
    valueDiv.innerHTML = value;
    rowDiv.appendChild(valueDiv);
    return rowDiv
}

setTimeout("updateFromVariables()", 1);
setTimeout("probeValues()", 20);



  
