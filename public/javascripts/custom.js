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
            /*  $("inputFrame" + tstCurrentPage).style.height = "300px";
            $("touchscreenInput" + tstCurrentPage).style.height = "300px";
            $("touchscreenInput" + tstCurrentPage).setAttribute("field_type", "text")
            $("viewport").style.height = "300px" */
            if ($("touchscreenInput" + tstCurrentPage).outerHTML.match(/\<textarea/)){

            }else{
                $("touchscreenInput" + tstCurrentPage).outerHTML = $("touchscreenInput" + tstCurrentPage).outerHTML.replace(/\<input/, "<textarea")
                $("touchscreenInput" + tstCurrentPage).setAttribute('class','touchscreenTextAreaInput');
                $("touchscreenInput" + tstCurrentPage).setAttribute("cols", 67);
                $("touchscreenInput" + tstCurrentPage).setAttribute("rows", 6);
                $("return").style.display = "block";
            }
        }else{
            $("arv_period").style.display = "none"
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
        setTimeout("updateFromVariables()", 100)
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
   
    try{
        var pageConcept = $("touchscreenInput" + tstCurrentPage).name.replace(/concept\[|]/g, "");
        if (pageConcept != currentConcept){
            currentConcept =  pageConcept;
            
            var user = "";
            var patient = "";
            
            var inputNodes = document.getElementsByTagName("input")
            for (var i = 0; i < inputNodes.length; i ++){
                if (inputNodes[i].name == "patient_id"){
                    patient = inputNodes[i].value
                }else if (inputNodes[i].name == "user_id"){
                    user = inputNodes[i].value
                }
            }
           
            ajaxPull(currentConcept, user, patient);
        }
    }catch(ex){
        
    }
    setTimeout("probeValues()", 300);
}

function ajaxPull(concept, user, patient){

    var httpRequest = new XMLHttpRequest();
    httpRequest.onreadystatechange = function() {

        if ((!httpRequest) || (!concept) || (!patient)) return;
        if (httpRequest.readyState == 4 && (httpRequest.status == 200 ||
            httpRequest.status == 304)) {

            var result = JSON.parse(httpRequest.responseText);
            if (result.toString().length > 0){
                /*
                var flag = document.createElement("div")
                flag.id = "flag"
                flag.style.background = "url('/images/drop_icon.jpg')";
                flag.style.position = "absolute";
                flag.style.top = "feed";
                flag.style.zIndex = 100;
                flag.style.width = "85px";
                flag.style.height = "75px";
                flag.style.left = "0.5%"
                
                flag.onclick = function(){
                    this.style.display = "none";
                    $('inputFrame' + tstCurrentPage).style.marginLeft = "25px";
                    $('helpText' + tstCurrentPage).style.marginLeft = "0px";
                    $('inputFrame' + tstCurrentPage).style.width = "96.5%";
                    $("touchscreenInput" + tstCurrentPage).value = result
                }
                $('inputFrame' + tstCurrentPage).style.marginLeft = "100px";
                $('inputFrame' + tstCurrentPage).style.width = "90%";
                 $('helpText' + tstCurrentPage).style.marginLeft = "80px";
                 */
                $('inputFrame' + tstCurrentPage).onclick = function(){
                    if ($("touchscreenInput" + tstCurrentPage).value.length == 0){
                        $("touchscreenInput" + tstCurrentPage).value = result
                    }
                }
                $('page' + tstCurrentPage).appendChild(flag)
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


setTimeout("updateFromVariables()", 1);
setTimeout("probeValues()", 20);



  
