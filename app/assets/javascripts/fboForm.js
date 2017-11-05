window.addEventListener("load",start,false);

function start(){
    alert("started");
    hideSections();
    alert("hidden sections");
    addListeners();
    alert("listenersAdded");
}

function addListeners(){
    var landing= document.getElementsByClassName("1");
    listerHelper(landing, '1');
    var ramp= document.getElementsByClassName("3");
    listerHelper(ramp, '3');
    var facility = document.getElementsByClassName("4");
    listerHelper(facility, '4');
    var tieDown = document.getElementsByClassName("2");
    listerHelper(tieDown, '2');
    var callOut = document.getElementsByClassName("5");
    listerHelper(callOut, 5);
}

//needed to be used for coffescript
exports.addListeners=addListeners;

function listerHelper(selectors, groupNumber){
    for(var i=0; i<selectors.length;i++){
        selectors[i].removeAttribute("id");
        selectors[i].setAttribute("id",i+" "+groupNumber);
        selectors[i].onchange=function(e){updateField(this.id)};
    }
}

//hides the sections of the form that are not being used
function hideSections(){
    var uneededSections= document.getElementsByClassName('byWeight');
    var uneededSections2= document.getElementsByClassName('byWeightRange');
    for(var i=0; i<uneededSections.length; i++){
        uneededSections[i].style.display="none";
    }
    for(var k=0; k<uneededSections2.length;k++){
        uneededSections2[k].style.display="none";
    }
}

//update the feild when the user picks a different category
function updateField(elementID){
    var curDropdown= document.getElementById(elementID);
    var selectorValue= curDropdown.options[curDropdown.selectedIndex].value;
    if(selectorValue==3){
        makeWeight(elementID);
    }
    if(selectorValue==4){
        makeWeightRange(elementID);
    }
    if(selectorValue!=3 && selectorValue!=4){
        makeStandard(elementID);
    }
}

function makeWeight(elementID){
    var classId = elementID.substring(elementID.length-1, elementID.length);
    var visableClass= document.getElementsByClassName("byWeight");
    var invisableClass= document.getElementsByClassName("noUnitPrice");
    var invisableClass2= document.getElementsByClassName("byWeightRange");
    
    for(var j=0; j<invisableClass.length; j++){
        if(invisableClass[j].getAttribute("id")===classId){
            invisableClass[j].style.display="none";
        }
    }
    
    for(var i=0; i<invisableClass2.length; i++){
        if(invisableClass2[i].getAttribute("id")===classId){
            invisableClass2[i].style.display="none";
        }
    }
    
    for(var k=0; k<visableClass.length; k++){
        if(visableClass[k].getAttribute("id")===classId){
            visableClass[k].style.display="inline";
        }
    }
}

function makeWeightRange(elementID){
    var classId = elementID.substring(elementID.length-1, elementID.length);
    var visableClass= document.getElementsByClassName("byWeightRange");
    var invisableClass= document.getElementsByClassName("noUnitPrice");
    var invisableClass2= document.getElementsByClassName("byWeight");
    
    for(var j=0; j<invisableClass.length; j++){
        if(invisableClass[j].getAttribute("id")===classId){
            invisableClass[j].style.display="none";
        }
    }
    
    for(var i=0; i<invisableClass2.length; i++){
        if(invisableClass2[i].getAttribute("id")===classId){
            invisableClass2[i].style.display="none";
        }
    }
    
    for(var k=0; k<visableClass.length; k++){
        if(visableClass[k].getAttribute("id")===classId){
            visableClass[k].style.display="inline";
        }
    }
    
}

function makeStandard(elementID){
    var classId = elementID.substring(elementID.length-1, elementID.length);
    var visableClass= document.getElementsByClassName("noUnitPrice");
    var invisableClass= document.getElementsByClassName("byWeight");
    var invisableClass2= document.getElementsByClassName("byWeightRange");
    
    for(var j=0; j<invisableClass.length; j++){
        if(invisableClass[j].getAttribute("id")===classId){
            invisableClass[j].style.display="none";
        }
    }
    
    for(var i=0; i<invisableClass2.length; i++){
        if(invisableClass2[i].getAttribute("id")===classId){
            invisableClass2[i].style.display="none";
        }
    }
    
    for(var k=0; k<visableClass.length; k++){
        if(visableClass[k].getAttribute("id")===classId){
            visableClass[k].style.display="inline";
        }
    }
}