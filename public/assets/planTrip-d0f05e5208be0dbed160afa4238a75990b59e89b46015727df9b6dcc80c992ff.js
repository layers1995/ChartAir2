function start(){cities=gon.cities,curAirplanes=gon.curAirplanes,selectedAirplane=gon.selectedPlane,startSettings()}function startSettings(){if(!addedManu){for(var e=0;e<cities.length;e++)null==cityDict[cities[e].state]?(cityDict[cities[e].state]=[],cityDict[cities[e].state].push(cities[e].name)):cityDict[cities[e].state].push(cities[e].name);for(var t=document.getElementById("states"),n=Object.keys(cityDict),e=0;e<n.length;e++){var i=document.createElement("option");i.text=n[e],i.innerHTML=n[e],i.value=n[e],t.appendChild(i)}changeCities(),addCurrentAirplanes(),selectUserCurrentAirplane()}addedManu=!0}function addCurrentAirplanes(){for(var e=document.getElementById("airplanes"),t=0;t<curAirplanes.length;t++){var n=document.createElement("option");n.text=curAirplanes[t].tailnumber,n.innerHTML=curAirplanes[t].tailnumber,n.value=curAirplanes[t].tailnumber,e.appendChild(n)}}function selectUserCurrentAirplane(){for(var e=document.getElementById("airplanes"),t=0;t<e.length;t++)curAirplanes[t].tailnumber===selectedAirplane&&(e.selectedIndex=t)}function changeCities(){for(var e=document.getElementById("states"),t=document.getElementById("cities"),n=e.options[e.selectedIndex].value,i=cityDict[n],a=t.length-1;a>=0;a--)t.remove(a);for(var a=0;a<i.length;a++){var r=document.createElement("option");r.text=i[a],r.innerHTML=i[a],r.value=i[a],t.appendChild(r)}}window.addEventListener("load",start,!1);var cityDict={},addedManu=!1;