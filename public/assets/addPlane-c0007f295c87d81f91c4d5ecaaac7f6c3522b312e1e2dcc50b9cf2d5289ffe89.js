function start(){airplanes=gon.airplanes,startSettings(),document.getElementById("addPlane").onclick=function(){showPlaneOptions()},document.getElementById("showAfterClick").style.display="none"}function showPlaneOptions(){document.getElementById("showAfterClick").style.display="block",document.getElementById("addPlane").style.display="none"}function startSettings(){if(!addedManu){for(var e=0;e<airplanes.length;e++)null==planeDict[airplanes[e].manufacturer]?(planeDict[airplanes[e].manufacturer]=[],planeDict[airplanes[e].manufacturer].push(airplanes[e].model)):planeDict[airplanes[e].manufacturer].push(airplanes[e].model);for(var n=document.getElementById("manufacturer"),t=Object.keys(planeDict),e=0;e<t.length;e++){var a=document.createElement("option");a.text=t[e],a.innerHTML=t[e],a.value=t[e],n.appendChild(a)}changePlanes()}addedManu=!0}function changePlanes(){for(var e=document.getElementById("manufacturer"),n=document.getElementById("model"),t=e.options[e.selectedIndex].value,a=(planeDict[t],n.length-1);a>=0;a--)n.remove(a);newPlaneList=planeDict[t];for(var a=0;a<newPlaneList.length;a++){var l=document.createElement("option");l.text=newPlaneList[a],l.innerHTML=newPlaneList[a],l.value=newPlaneList[a],n.appendChild(l)}}window.addEventListener("load",start,!1);var planeDict={},addedManu=!1;