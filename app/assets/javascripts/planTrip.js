window.addEventListener("load",start,false);

var cityDict= {};
var citiess;
var curAirplanes;
var selectedAirplane;
var addedManu=false;

function start(){
    //get json package and save it into a good location
    cities= gon.cities;
    curAirplanes= gon.curAirplanes;
    selectedAirplane= gon.selectedPlane
    
    //creates the dictionary and the list of manufactors
    startSettings();
}

function startSettings(){
	
	if(!addedManu){
		
		//make the dictonary of cities
	    for(var i=0 ; i<cities.length; i++){
	        if(cityDict[cities[i]["state"]]==null){
	            cityDict[cities[i]["state"]]= [];
	            cityDict[cities[i]["state"]].push(cities[i]["name"]);
	        }else{
	        	cityDict[cities[i]["state"]].push(cities[i]["name"]);
	        }
	    }
		
		//add list of states to the state list
	    var states=document.getElementById("states");
	    var keys= Object.keys(cityDict);
		
	    for(var i=0; i<keys.length;i++){
	    	
	    	var newOption = document.createElement('option');
	    	
	    	newOption.text= capitialize(keys[i]);
	    	newOption.innerHTML=capitialize(keys[i]);
	    	newOption.value=keys[i];
	    	
	    	states.appendChild(newOption);
	    }
	    
	    //adds list of cities to the city list
	    changeCities();
	    
	    
	    //add list of planes to the plane list
	    addCurrentAirplanes();
	    
	    //selects airplane the user wishes to use
	    selectUserCurrentAirplane();
	}
	
	addedManu=true;
    
}

//have ruby check to make sure 
function addCurrentAirplanes(){
	
	var airplanes= document.getElementById("airplanes");
	
	for(var i=0; i<curAirplanes.length;i++){
		
		var newOption = document.createElement('option');
	    	
	    newOption.text=curAirplanes[i]["tailnumber"];
	    newOption.innerHTML=curAirplanes[i]["tailnumber"];
	    newOption.value=curAirplanes[i]["tailnumber"];
	    	
	    airplanes.appendChild(newOption);
	}
	
	
}

function selectUserCurrentAirplane(){
	
	var airplanes= document.getElementById("airplanes");
	
	for(var i=0; i<airplanes.length;i++){
		if(curAirplanes[i]["tailnumber"]===(selectedAirplane)){
			airplanes.selectedIndex=i;
		}
	}
}


//Changes the city depending on the state
function changeCities(){
    
	//get the select table and cities that are going to be added
	
	//the two current selectors seen by user
	var states=document.getElementById("states");
	var cityList=document.getElementById("cities");
	
	//currently selected state
	var stateVal=states.options[states.selectedIndex].value;
	//list of cities within the state
	var citiesInState=cityDict[stateVal];
	
	//remove all the current planes from the list
	for(var i=cityList.length-1; i>=0; i--){
		cityList.remove(i);
	}
	
	//add the new planes to the list
	for(var i=0; i<citiesInState.length;i++){

		var newOption = document.createElement('option');
	    	
	    newOption.text= properCapitlize(citiesInState[i]);
	    newOption.innerHTML= properCapitlize(citiesInState[i]);
	    newOption.value=citiesInState[i];
	    	
	    cityList.appendChild(newOption);
	}
	
}


function properCapitlize(s){
	return s.toLowerCase().replace( /\b./g, function(a){ return a.toUpperCase(); } );
}

function capitialize(name){
	return name.toUpperCase();
}