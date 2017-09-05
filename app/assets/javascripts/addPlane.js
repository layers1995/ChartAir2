window.addEventListener("load",start,false);

var planeDict= {}
var addedManu=false;

function start(){
    //get json package and save it into a good location
    airplanes= gon.airplanes;
    
    //creates the dictionary and the list of manufactors
    startSettings();
    //add listener to button
    var addButton= document.getElementById("addPlane");
    addButton.onclick=function(){showPlaneOptions();};
    
    //make orginal section not show
    var show= document.getElementById("showAfterClick");
	show.style.display='none'
}

function showPlaneOptions(){
	
	var show= document.getElementById("showAfterClick");
	show.style.display='block';
	
	var addButton= document.getElementById("addPlane");
	addButton.style.display='none';
}

function startSettings(){
	
	if(!addedManu){
		
		//make the dictonary of planes
	    for(var i=0 ; i<airplanes.length; i++){
	        if(planeDict[airplanes[i]["manufacturer"]]==null){
	            planeDict[airplanes[i]["manufacturer"]]= [];
	            planeDict[airplanes[i]["manufacturer"]].push(airplanes[i]["model"]);
	        }else{
	        	planeDict[airplanes[i]["manufacturer"]].push(airplanes[i]["model"]);
	        }
	    }
		
		//add list of manufatoroers to the manufacture list
	    var manufacters=document.getElementById("manufacturer");
	    var keys= Object.keys(planeDict);
		
	    for(var i=0; i<keys.length;i++){
	    	
	    	var newOption = document.createElement('option');
	    	
	    	newOption.text=capitalize(keys[i]);
	    	newOption.innerHTML=capitalize(keys[i]);
	    	newOption.value=keys[i];
	    	
	    	manufacters.appendChild(newOption);
	    }
	    
	    changePlanes();
	}
	
	addedManu=true;
    
}


//Changes the city depending on the state
function changePlanes(){
    
	//get the select table and cities that are going to be added
	
	//the two current selectors seen by user
	var manufacters=document.getElementById("manufacturer");
	var airplaneList=document.getElementById("model");
	
	//currently selected manufacter
	var manuVal=manufacters.options[manufacters.selectedIndex].value;
	//list of planes made by manufacter
	var airplanesFromManu=planeDict[manuVal];
	
	//remove all the current planes from the list
	for(var i=airplaneList.length-1; i>=0; i--){
		airplaneList.remove(i);
	}
	
	//get new airplane list
	var newPlaneList= planeDict[manuVal];
	
	//add the new planes to the list
	for(var i=0; i<newPlaneList.length;i++){
		
		var newOption = document.createElement('option');
	    	
	    newOption.text=capitalize(newPlaneList[i]);
	    newOption.innerHTML=capitalize(newPlaneList[i]);
	    newOption.value=newPlaneList[i];
	    	
	    airplaneList.appendChild(newOption);
	}
	
}

function capitalize(s){
	return s.toLowerCase().replace( /\b./g, function(a){ return a.toUpperCase(); } );
}