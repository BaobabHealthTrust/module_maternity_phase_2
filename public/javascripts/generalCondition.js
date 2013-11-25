
function showGeneralConditionControl(labelsMap){

    if (labelsMap){

    }else{
        labelsMap = {
            "General Condition" : ["Very Good", "Good", "Fair", "Poor", "Miserable"],
            "Skin Color" : ["Pink", "Acrocyanotic", "Cyanotic", "Jaundiced", "Mottling"],
            "Heart beat" : ["Normal", "Weak", "Fast", "Slow", "None"],
            "Respiration" : ["Normal", "Grunting", "Tachypnoea", "Apnoea", "In Drawing"]
        }
        
    }

    var scoreWindow = document.createElement("div");
    scoreWindow.setAttribute("id", "selectWindow");
    
    $('inputFrame' + tstCurrentPage).style.display = "none";
    $('page' + tstCurrentPage).style.minHeight = "650px";
    $('page' + tstCurrentPage).appendChild(scoreWindow);
   
    labels = Object.keys(labelsMap);
    
    // clear all previous selections
    try{
        
        setTimeout(function(){
            $("clearButton").onmousedown.apply($("clearButton"))
        }, 50);
        
    }catch(ex){}
    
    //build place holders for parameters to be passes to server
    for (var i = 0; i < labels.length; i ++){
                
        createField(labels[i], labels[i], "input", "hidden", "");

    }

    //build the first row of controls
    for (var r = 0; r < labels.length; r ++){
        var row = buildRow(r, labels[r], labelsMap[labels[r]]);
        if (r != 0) {
            row.style.display = "none";
        }
        scoreWindow.appendChild(row);
        
    }
}

function buildRow(rpos, label, options){

    var rowDiv = document.createElement("div");
    rowDiv.id = "row_" + label
    rowDiv.setAttribute("class", "row-div")

    var lblCell = createField("label_" + label, label, "leftButt", "div", "");
    lblCell.innerHTML = label;
    rowDiv.appendChild(lblCell);
    
    for(var i = 0; i < options.length; i++){
        var id = label + "_" + rpos + "_" + options[i];
        var clas = "value butt " + label + "-" + rpos;
        var cell = createField(id , label, clas , "div", options[i]);
        rowDiv.appendChild(cell);
    }

    return rowDiv
}

function createField(id, name, classes, type, value){

    if (type == "hidden"){
        var node = document.createElement("input");
    }else{
        var node = document.createElement("div");
    }

    var nameInput = "concept[" + name.toLowerCase() + "]";
    
    node.id = id.toLowerCase();
    node.setAttribute("name", nameInput );
    node.setAttribute("type", type);
    node.setAttribute("class", classes);
    node.setAttribute("selected", "false");
  

    if (type == "hidden"){

        document.forms[0].appendChild(node);

    }else if (classes.match(/value/)){
        node.innerHTML = value;
        node.style.background = "url('/images/btn_blue.png')";
        node.style.color = "white";              
        //open event
        node.onclick = function(){
           
            this.style.background = "url('/images/click_btn.png')";
            this.setAttribute("selected", "true");

            var __target = node.id.toString().split("_");
            var prevRowSelection = $(__target[0].toLowerCase()).value
            $(__target[0].toLowerCase()).value = this.value;

            try{
                
                var nextRow = $("row_" + labels[labels.indexOf(this.parentNode.id.split("_")[1]) + 1]);
                
                $("selectWindow").style.height = ($("selectWindow").style.height + 10.3) +"%";

                if (!prevRowSelection && nextRow.getAttribute("onscreen") != "true"){
                    showDiv(nextRow);
                }
               
                
            }catch(exc){
              
            }
                      
            var rsib = this.parentNode.children
            
            for (var j = 0; j < rsib.length; j ++){
                
                if (rsib[j].innerHTML != this.innerHTML && rsib[j].getAttribute("class").match(/value/)){
                    
                    rsib[j].style.background = "url('/images/btn_blue.png')";
                    rsib[j].setAttribute("selected", "false");
                    
                }
                
            }

            updateFields();

        }
    //event closed
    }
    
    node.value = value;

    return node
}

function updateFields(){

    var nodes = document.getElementsByClassName("input");

    $('touchscreenInput'+tstCurrentPage).setAttribute("optional", "true")

    for (var k = 0; k < nodes.length; k ++){

        if (nodes[k].value.length == 0){

            $('touchscreenInput'+tstCurrentPage).setAttribute("optional", null)


        }
    }

    $("clearButton").onmousedown = function(){
        
        clearInput();

        $('touchscreenInput'+tstCurrentPage).setAttribute("optional", null)


        var nodes = document.getElementsByClassName("input");
        
        for (var k = 0; k < nodes.length; k ++){

            nodes[k].value = "";

        }

        var buttons = document.getElementsByClassName("value");

        for (var k = 0; k < buttons.length; k ++){
            buttons[k].style.background = "url('/images/btn_blue.png')";
            buttons[k].setAttribute("selected", "false");
        }

    }
}

function fadeIn(div, opacity){
    div.style.opacity = opacity;
    if (opacity >= 0 && opacity <= 1){
        opacity = opacity + 0.01;
        setTimeout(function(){
            fadeIn(div, opacity)
        }, 4)
    }
}

function showDiv(div){
    div.style.opacity = 0;
    div.setAttribute("onscreen", "true");
    div.style.display = "table-row";
    setTimeout(function(){
        fadeIn(div, 0);
    }, 120);
}