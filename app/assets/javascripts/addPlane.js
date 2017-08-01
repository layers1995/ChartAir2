window.addEventListener("load",start,false);

var planeDict= {}
var addedManu=false;

function start(){
	
    //get json package and save it into a good location
    airplanes= gon.airplanes;
    
    //creates the dictionary and the list of manufactors
    startSettings();
    
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
	    	
	    	newOption.text=keys[i];
	    	newOption.innerHTML=keys[i];
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
	newPlaneList= planeDict[manuVal];
	
	//add the new planes to the list
	for(var i=0; i<newPlaneList.length;i++){
		
		var newOption = document.createElement('option');
	    	
	    newOption.text=newPlaneList[i];
	    newOption.innerHTML=newPlaneList[i];
	    newOption.value=newPlaneList[i];
	    	
	    airplaneList.appendChild(newOption);
	}
	
}