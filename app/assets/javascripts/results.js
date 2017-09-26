window.addEventListener("load",start,false);

//main dictionary used by the class
var feeDict;
//holds the order of a collect of fbo objects;
var fbos=[];
//current filter in use
var curFilter;
//dictionary of different fees used by the airports
var appliedFees= {};
//destination location
var destination;

function start(){
    //alert("start");
    feeDict=gon.dict;
    destination=gon.destination;
    
    addListeners();
    //alert("listeners added");
    createFboList();
    //alert("fbo list created" + fbos.length + " is the lenght");
    fillAppliedFeesDict();
    //alert("fees applied to dictionary");
    filterButtonClicked(curFilter);
    //alert("filter button clicked");
}

//adds listeners to buttons
function addListeners(){
    
    //filter buttons
    document.getElementById("filters").onchange=function(){filterButtonClicked();};
	document.getElementById("locationIcon").onchange=function(){filterButtonClicked("distance");};
	
	//alert("filer buttons work");
	
	//fee select buttons
	document.getElementById("landing").onclick=function(){feeButtonClicked("landing");};
	document.getElementById("tie down").onclick=function(){feeButtonClicked("tie down");};
	document.getElementById("ramp").onclick=function(){feeButtonClicked("ramp");};
	document.getElementById("facility").onclick=function(){feeButtonClicked("facility");};
	//document.getElementById("hanger").onclick=function(){feeButtonClicked("hanger");};
	document.getElementById("call out").onclick=function(){feeButtonClicked("call out");};
	document.getElementById("other").onclick=function(){feeButtonClicked("other");};
	
}

function createFboList(){
    
    var fboNames= Object.keys(feeDict);
    
    if(fboNames.length>fbos.length){
        
        for(var i=0; i<fboNames.length; i++){
            
            var fbo={name:"",distance: 0, total:0};
            
            fbo.name=fboNames[i];
            fbo.distance=parseInt(feeDict[fboNames[i]]["distance"].substring(0,feeDict[fboNames[i]]["distance"].length-4));
            fbo.total=feeDict[fboNames[i]]["total"];
            
            this.fbos.push(fbo);
        }
    }
    
}

//starts by filling the applied fees dictionary
function fillAppliedFeesDict(){
    appliedFees["landing"]=true;
    appliedFees["tie down"]=true;
    appliedFees["ramp"]= true;
    appliedFees["facility"]=true;
    appliedFees["call out"]=true;
    //appliedFees["hanger"]=true;
    appliedFees["other"]=true;
    
    //turn on check boxes
    document.getElementById("landing").checked = true;
    document.getElementById("ramp").checked = true;
    document.getElementById("tie down").checked = true;
    document.getElementById("call out").checked = true;
    
    //turn off check boxes for tie down and call out
    feeButtonClicked("tie down");
    feeButtonClicked("call out");
}

//listens for when a filter button is clicked
function filterButtonClicked(){
    
    //get the buttons
    var e = document.getElementById("filters");
    var buttonClicked = e.options[e.selectedIndex].value;
    
    curFilter=buttonClicked;
    
    if(buttonClicked==="cost"){
        //update buttons
        curFilter="cost";
    }else{
         //update buttons
         curFilter="distance";
    }

    arrangeResults();
    updateTable();
}

//listens for when a fee button is clicked
function feeButtonClicked(buttonClicked){
    
    if(appliedFees[buttonClicked]){
        //turn off
        appliedFees[buttonClicked]=false;
        var button=	document.getElementById(buttonClicked);
        document.getElementById(buttonClicked).checked = false;
    }else{
        //turn on
        appliedFees[buttonClicked]=true;
        var button=	document.getElementById(buttonClicked);
        document.getElementById(buttonClicked).checked = true;
    }
    
    //updates the current cost and reagranges the results
    updateTotalCost();
    arrangeResults();
    updateTable();
}

//updates the current full costs of the results
function updateTotalCost(){

    var fees= Object.keys(appliedFees);
    
    for(var i=0; i<this.fbos.length;i++){
        
        var hasKnownFees=false;
        var tempTotal=0;
        
        for(var k=0; k<fees.length; k++){
            if(feeDict[fbos[i].name][fees[k]]!=null){
                hasKnownFees=true;
                if(appliedFees[fees[k]]){
                    tempTotal+= Math.floor(feeDict[fbos[i].name][fees[k]]);
                }
            }
        }
        
        //gives a certain price if the fbo has unknown fees
        if(hasKnownFees){
            fbos[i].total=tempTotal;
            feeDict[fbos[i].name]["total"]=tempTotal;
        }else{
            fbos[i].total=1000001;
            feeDict[fbos[i].name]["total"]=1000001;
        }
        
    }
    
}

//reorginizes the different results
function arrangeResults(){
    
    if(curFilter==="cost"){
        fbos.sort(compairPrice);
    }else{
        fbos.sort(compairDistance);
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

//edited to allow for unknow fees to sink to bottom
function compairDistance(x, y){
    
   var xDistance=parseInt(x.distance);
   var yDistance=parseInt(y.distance);
   
   if(parseInt(x.total)==1000001 || parseInt(y.total)==1000001){
       if (parseInt(x.total) < parseInt(y.total))
          return -1;
       if (parseInt(x.total) > parseInt(y.total))
         return 1;
   }
   
   if (xDistance < yDistance)
      return -1;
   if (xDistance > yDistance)
     return 1;
    
   //no forever loop    
   if(parseInt(x.total)!= parseInt(y.total))
        return compairPrice(x,y);
}

//Helper function to capitalize strings with extra charecters and spaces
function properCapitlize(s){
	return s.toLowerCase().replace( /\b./g, function(a){ return a.toUpperCase(); } );
}

//adds all entries to the table
function updateTable(){
    
    //deletes all entries
    var div = document.getElementById("allResults");
    div.innerHTML = "";
    var mapDetails="";
    var numUnknown=0;
    
    //creates an array of buttons
    var buttons= Array(fbos.length);
    
    if(fbos.length!=0){
        
        for(var i=0; i<this.fbos.length;i++){
            
            var curName=fbos[i].name;
            
            //checks to make sure only 2 unknowns are shown
            if(numUnknown>1){
                break;
            }
            
            if(feeDict[curName]["total"]==1000001){
                numUnknown+=1;
            }
            
            //creates new table
            var newDiv= document.createElement("div");
            newDiv.setAttribute('class', 'result');
            
            var table = document.createElement('table');
            table.setAttribute('class', 'resultTable');
            // Insert a row in the table at the last row
            var newRow   = table.insertRow(table.rows.length);
            
            // Insert a cell in the row at index 0
            var c1  = document.createElement('td');
            // Append a text node column
            var c1text= document.createElement("H3");
            c1text.appendChild(document.createTextNode( (i+1) + "." + " "+ properCapitlize(feeDict[curName]["airport"])));
            c1.appendChild(c1text);
            newRow.appendChild(c1);
            
            //insert a blank cell
            var c2  = document.createElement('td');
            var c2text=document.createElement("H3");
            c2text.setAttribute('class', 'center');
            c2text.appendChild(document.createTextNode(feeDict[curName]["distance"]));
            c2.appendChild(c2text);
            newRow.appendChild(c2);
            
            //make a cell for price
            var c3  = document.createElement('td');
            var c3text=document.createElement("H4");
            
            if(feeDict[curName]["estimated"]){
                c3text.setAttribute('class', 'estimate');
            }
            
            if(notAllFeesKnown(feeDict, curName)){
                c3text.setAttribute('class', 'estimate');
            }
            
            if(feeDict[curName]["total"]==1000001){
                c3text.appendChild(document.createTextNode("Unknown Cost"));
            }else{
                c3text.appendChild(document.createTextNode("Total Cost: $" + feeDict[curName]["total"]));
            }
            
            c3.setAttribute("class", "right");
            c3.appendChild(c3text);
            newRow.appendChild(c3);
            
            //make a cell for the button
            var c4  = document.createElement('td');
            buttons[i]= document.createElement("button");
            buttons[i].innerHTML = 'Book Trip';
            buttons[i].setAttribute("id",i);
            buttons[i].onclick=function(e){linkToBookTrip(this.id);};
            //set location of button
            c4.setAttribute("class", "center");
            c4.appendChild(buttons[i]);
            newRow.appendChild(c4);
            
            // Insert a row in the table at the last row
            var fboRow = table.insertRow(table.rows.length);
            var fboc= document.createElement('td');
            //fboc.setAttribute("class", "center");
            var fboName= document.createElement("H4");
            fboName.appendChild(document.createTextNode("\u00a0\u00a0" + properCapitlize(curName)));
            fboc.appendChild(fboName);
            fboRow.appendChild(fboc);
            
            //insert fee into new row landing and ramp
            var landingRamp= document.createElement("td");
            var landingCosts=""
            var rampCosts=""
            if(feeDict[curName]["landing"]!=null){
                landingCosts+="Landing: $" + Math.floor(feeDict[curName]["landing"]);
            }else{
                landingCosts+="Landing: Unknown";
            }
            if(feeDict[curName]["ramp"]!=null){
                rampCosts+= "Ramp: $" + Math.floor(feeDict[curName]["ramp"]);
            }else{
                rampCosts+= "Ramp: Unknown";
            }
            landingRamp.appendChild(document.createTextNode(landingCosts));
            landingRamp.appendChild(document.createElement("br"));
            landingRamp.appendChild(document.createTextNode(rampCosts));
            fboRow.appendChild(landingRamp);
            
            
            //add tie down and call out
            var tdco= document.createElement("td");
            var tdCosts=""
            var coCosts=""
            if(feeDict[curName]["tie down"]!=null){
                tdCosts+="Tie-Down: $" + Math.floor(feeDict[curName]["tie down"]);
            }else{
                tdCosts+="Tie-Down: Unknown";
            }
            if(feeDict[curName]["call out"]!=null){
                coCosts+= "Call-Out: $" + Math.floor(feeDict[curName]["call out"]);
            }else{
                coCosts+= "Call-Out: Unknown";
            }
            tdco.appendChild(document.createTextNode(tdCosts));
            tdco.appendChild(document.createElement("br"));
            tdco.appendChild(document.createTextNode(coCosts));
            fboRow.appendChild(tdco);
            
            
            //add other and facility
            var other= document.createElement("td");
            var otherCosts=0
            var otherCostsString=""
            if(feeDict[curName]["facility"]!=null){
                otherCosts+=Math.floor(feeDict[curName]["facility"])
                
                if(feeDict[curName]["other"]!=null){
                    otherCosts+= "Other: $" + Math.floor(feeDict[curName]["other"])+Math.floor(otherCosts);
                }else{
                    otherCostsString+= "Other: $" + otherCosts;
                }
            }else{
                
                if(feeDict[curName]["other"]!=null){
                    otherCostsString+= "Other: $" + Math.floor(feeDict[curName]["other"]);
                }else{
                    otherCostsString+= "Other: Unknown";
                }
            }
            other.appendChild(document.createTextNode(otherCostsString));
            fboRow.appendChild(other);
            
            //append table to div
            newDiv.appendChild(table);
            //append div to div
            div.appendChild(newDiv);
            
            //add to src strings
            mapDetails+= "&markers=color:red|label:"+(i+1)+"|" + feeDict[curName]["latitude"] + "," + feeDict[curName]["longitude"];
        }
    }else{
        //create a result
        var newDiv= document.createElement("div");
        newDiv.setAttribute('class', 'result');
        
        //add paragraph saying that nothing was found, try a larger area
        var newText= document.createElement("H3");
        newText.appendChild(document.createTextNode("Sadly, it seems there are no airports within the mile radius you selected for this city. Try again with a larger radius, or from another nearby city. Sorry for any inconveince!"));
    
        //append the different elements together
        newDiv.appendChild(newText);
        div.appendChild(newDiv);
    }
    
    createGoogleMap(mapDetails);
    
}

function notAllFeesKnown(curFeeDict, curNameFBO){
    //alert(curFeeDict[curNameFBO]["total"]);
    if(curFeeDict[curNameFBO]["landing"]==null){
        return true;
    }
    if(curFeeDict[curNameFBO]["ramp"]==null){
        return true;
    }
    if(curFeeDict[curNameFBO]["tie down"]==null){
        return true;
    }
    if(curFeeDict[curNameFBO]["call out"]==null){
        return true;
    }
    if(curFeeDict[curNameFBO]["facility"]==null && curFeeDict[curNameFBO]["other"]==null){
        return true;
    }

    return false;
}

function linkToBookTrip(index){
    var fboName=fbos[parseInt(index)].name;
    var airportName=feeDict[fboName]["airport"];
    var tailnumber=gon.tailnumber;
    var time= gon.time;
    var time2 =gon.time2;
    var cost=feeDict[fboName]["total"];
    window.location='https://www.chartair.us/book_trip?fbo='+fboName+'&airport='+airportName+'&cost='+cost+'&tailnumber='+tailnumber+'&time='+time+'&time2='+time2;
}

function createGoogleMap(mapDetails){
    //get the image I want to change
    var googleMap= document.getElementById("googleMap");
    var destinationMarker="&markers=color:blue|label:D|"+destination;
    var finalsrc="http://maps.google.com/maps/api/staticmap?size=512x512&maptype=roadmap&sensor=false" +destinationMarker+ mapDetails;
    googleMap.src=finalsrc;
}