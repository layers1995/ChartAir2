window.addEventListener("load",start,false);

//main dictionary used by the class
var feeDict;
//current filter in use
var curFilter;
//dictionary of different fees used by the airports
var appliedFees= {};

function start(){
    feeDict=gon.dict;
    addListeners();
    fillAppliedFeesDict();
    updateTable();
}

//adds listeners to buttons
function addListeners(){
    
    //filter buttons
    document.getElementById("costIcon").onclick=function(){filterButtonClicked("cost");};
	document.getElementById("locationIcon").onclick=function(){filterButtonClicked("distance");};
	
	//fee select buttons
	document.getElementById("landing").onclick=function(){feeButtonClicked("landing");};
	document.getElementById("tie down").onclick=function(){feeButtonClicked("tie down");};
	document.getElementById("ramp").onclick=function(){feeButtonClicked("ramp");};
	document.getElementById("facility").onclick=function(){feeButtonClicked("facility");};
	document.getElementById("hanger").onclick=function(){feeButtonClicked("hanger");};
	document.getElementById("call out").onclick=function(){feeButtonClicked("call out");};
	document.getElementById("other").onclick=function(){feeButtonClicked("other");};
}

//starts by filling the applied fees dictionary
function fillAppliedFeesDict(){
    appliedFees["landing"]=true;
    appliedFees["tie down"]=true;
    appliedFees["ramp"]= true;
    appliedFees["facility"]=true;
    appliedFees["call out"]=true;
    appliedFees["hanger"]=true;
    appliedFees["other"]=true;
}

//listens for when a filter button is clicked
function filterButtonClicked(buttonClicked){
    
    //get the buttons
    var costButton= document.getElementById("costIcon");
    var distanceButton= document.getElementById("locationIcon");
    
    curFilter=buttonClicked;
    
    if(buttonClicked==="cost"){
        //update buttons
        costButton.style.opacity=1;
        distanceButton.style.opacity=0.4;
    }else{
         //update buttons
        costButton.style.opacity=0.4;
        distanceButton.style.opacity=1;
    }
    
    //arrangeResults();
    updateTable();
}

//listens for when a fee button is clicked
function feeButtonClicked(buttonClicked){
    
    if(appliedFees[buttonClicked]){
        //turn off
        appliedFees[buttonClicked]=false;
        var button=	document.getElementById(buttonClicked);
        button.style.opacity=0.4;
    }else{
        //turn on
        appliedFees[buttonClicked]=true;
        var button=	document.getElementById(buttonClicked);
        button.style.opacity=1;
    }
    
    //updates the current cost and reagranges the results
    updateTotalCost();
    //arrangeResults();
    updateTable();
}

//updates the current full costs of the results
function updateTotalCost(){
    
    var fbos= Object.keys(feeDict);
    var fees= Object.keys(appliedFees);
    
    for(var i=0; i<fbos.length;i++){
        
        var tempTotal=0;
        
        for(var k=0; k<fees.length; k++){
            if(appliedFees[fees[k]]){
                if(feeDict[fbos[i]][fees[k]]!=null){
                    tempTotal+= feeDict[fbos[i]][fees[k]];
                }
            }
        }
        
        feeDict[fbos[i]]["total"]=tempTotal;
    }
    
}

//reorginizes the different results
function arrangeResults(){
    
    if(curFilter==="cost"){
        feeDict.sort(compairPrice);
    }else{
        feeDict.sort(compairDistance);
    }
    
}

//adds all entries to the table
function updateTable(){
    
    //deletes all entries
    var div = document.getElementById("allResults");
    div.innerHTML = "";
    
    var fbos= Object.keys(feeDict);
    
    for(var i=0; i<fbos.length;i++){
        
        var newDiv= document.createElement("div");
        newDiv.setAttribute('class', 'result')
        
        var table = document.createElement('table');
        table.setAttribute('class', 'resultTable');
        // Insert a row in the table at the last row
        var newRow   = table.insertRow(table.rows.length);
        
        // Insert a cell in the row at index 0
        var c1  = document.createElement('td');
        // Append a text node column
        var c1text= document.createElement("H3");
        c1text.appendChild(document.createTextNode( (i+1) + "." + " "+ properCapitlize(feeDict[fbos]["airport"])));
        c1.appendChild(c1text);
        newRow.appendChild(c1);
        
        /*insert a blank cell
        var c2  = document.createElement('td');
        newRow.appendChild(c2);*/
        
        //make a cell for price
        var c3  = document.createElement('td');
        var c3text=document.createElement("H4");
        c3text.appendChild(document.createTextNode("Total Cost: $" + feeDict[fbos]["total"]));
        c3.setAttribute("class", "right");
        c3.appendChild(c3text);
        newRow.appendChild(c3);
        
        //make a cell for the button
        var c4  = document.createElement('td');
        var c4button= document.createElement("button");
        c4button.innerHTML = 'Book Trip';
        c4.setAttribute("class", "center");
        c4.appendChild(c4button);
        newRow.appendChild(c4);
        
        // Insert a row in the table at the last row
        var fboRow = table.insertRow(table.rows.length);
        var fboc= document.createElement('td');
        //fboc.setAttribute("class", "center");
        var fboName= document.createElement("H4");
        fboName.appendChild(document.createTextNode("\u00a0\u00a0\u00a0\u00a0" + fbos[i]));
        fboc.appendChild(fboName);
        fboRow.appendChild(fboc);
        
        //append table to div
        newDiv.appendChild(table);
        //append div to div
        div.appendChild(newDiv);
    }
    
}

//Helper functions of reorder Objects
function compairPrice(x, y){
    
   var xFee=parseInt(x.total);
   var yFee=parseInt(y.total);
   
   if (xFee < yFee)
      return -1;
   if (xFee > yFee)
     return 1;
    
   return compairDistance(x,y);
}

function compairDistance(x, y){
    
   var xDistance=parseInt(x.distance.substring(0,x.distance.length-4));
   var yDistance=parseInt(y.distance.substring(0,y.distance.length-4));
   
   if (xDistance < yDistance)
      return -1;
   if (xDistance > yDistance)
     return 1;
    
   //no forever loop    
   if(parseInt(x.fee)!= parseInt(y.fee))
        return compairPrice(x,y);
}

//Helper function to capitalize strings with extra charecters and spaces
function properCapitlize(name){
	
	var tempArr=name.split(/[ .:;?!~,`"&|()<>{}\[\]\r\n/\\\-]+/);
	var tempStr="";
	var curLocation=-1;
	
	for(var i=0; i<tempArr.length; i++){
		curLocation=curLocation+1+tempArr[i].length;
		tempStr=tempStr + tempArr[i].charAt(0).toUpperCase() + tempArr[i].substring(1,tempArr[i].length) +name.charAt(curLocation);
	}
	
	tempStr=tempStr.substring(0,tempStr.length);
	return tempStr;
}