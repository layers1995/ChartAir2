window.addEventListener("load",start,false);

var planeDict= {}

function start(){
    //get json package and save it into a good location
    
	//adds listeners dropdownlists
	
}


//Changes the city depending on the state
function changePlanes(){
    
	//get the select table and cities that are going to be added
	var state=document.getElementById("state");
	var cityTable=document.getElementById("city");
	var stateVal=state.options[state.selectedIndex].value;
	var cities=cityDict[stateVal];
	
	//change over the cities, if there are more cities in this state than the last
	if(cities.length>=cityTable.length)
	
		for(var i=0; i<cities.length;i++){
			
			var curCity=cityTable.options[i];
			
			//replace the values in the current table
			if(curCity != null){
				curCity.text=properCapitlize(cities[i]);
				curCity.value=properCapitlize(cities[i]);
				curCity.innerHTML=properCapitlize(cities[i]);
			}else{
			//if there are no more spaces in the current table	
				var newOption = document.createElement('option');
			    newOption.value = properCapitlize(cities[i]);
			    newOption.innerHTML = properCapitlize(cities[i]);
			    cityTable.appendChild(newOption);
			}
		}
		
	else{
		
		//put in new city values
		for(var i=0; i<cities.length;i++){
			
			var curCity=cityTable.options[i];
			
			//replace the values in the current table
			curCity.text=;
			curCity.value=;
			curCity.innerHTML=;
		}
		
		//delete the old city values
		for(var i=cities.length; i<cityTable.length;i++){
			cityTable.remove(i);
		}
	}	
	
}