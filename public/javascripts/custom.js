/*
 * Custom javascript code goes in here.
 *
 **/

var mother_status = "";

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
        }, 100);
    }
}