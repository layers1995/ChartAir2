function start(){feeDict=gon.dict,curFilter=document.getElementById("userFilter").innerHTML.toLocaleLowerCase(),alert("start"),addListeners(),alert("listeners added"),createFboList(),alert("fbo list created"+fbos.length+" is the lenght"),fillAppliedFeesDict(),alert("fees applied to dictionary"),filterButtonClicked(curFilter),alert("filter button clicked")}function addListeners(){document.getElementById("costIcon").onclick=function(){filterButtonClicked("cost")},document.getElementById("locationIcon").onclick=function(){filterButtonClicked("distance")},document.getElementById("landing").onclick=function(){feeButtonClicked("landing")},document.getElementById("tie down").onclick=function(){feeButtonClicked("tie down")},document.getElementById("ramp").onclick=function(){feeButtonClicked("ramp")},document.getElementById("facility").onclick=function(){feeButtonClicked("facility")},document.getElementById("hanger").onclick=function(){feeButtonClicked("hanger")},document.getElementById("call out").onclick=function(){feeButtonClicked("call out")},document.getElementById("other").onclick=function(){feeButtonClicked("other")}}function createFboList(){var e=Object.keys(feeDict);if(e.length>fbos.length)for(var t=0;t<e.length;t++){var n={name:"",distance:0,total:0};n.name=e[t],n.distance=parseInt(feeDict[e[t]].distance.substring(0,feeDict[e[t]].distance.length-4)),n.total=feeDict[e[t]].total,this.fbos.push(n)}}function fillAppliedFeesDict(){appliedFees.landing=!0,appliedFees["tie down"]=!0,appliedFees.ramp=!0,appliedFees.facility=!0,appliedFees["call out"]=!0,appliedFees.hanger=!0,appliedFees.other=!0}function filterButtonClicked(e){var t=document.getElementById("costIcon"),n=document.getElementById("locationIcon");curFilter=e,"cost"===e?(curFilter="cost",t.style.opacity=1,n.style.opacity=.4):(curFilter="distance",t.style.opacity=.4,n.style.opacity=1),arrangeResults(),updateTable()}function feeButtonClicked(e){if(appliedFees[e]){appliedFees[e]=!1;var t=document.getElementById(e);t.style.opacity=.4}else{appliedFees[e]=!0;var t=document.getElementById(e);t.style.opacity=1}updateTotalCost(),arrangeResults(),updateTable()}function updateTotalCost(){for(var e=Object.keys(appliedFees),t=0;t<this.fbos.length;t++){for(var n=0,i=0;i<e.length;i++)appliedFees[e[i]]&&null!=feeDict[fbos[t].name][e[i]]&&(n+=feeDict[fbos[t].name][e[i]]);fbos[t].total=n,feeDict[fbos[t].name].total=n}}function arrangeResults(){"cost"===curFilter?fbos.sort(compairPrice):fbos.sort(compairDistance)}function compairPrice(e,t){var n=parseInt(e.total),i=parseInt(t.total);return n<i?-1:n>i?1:compairDistance(e,t)}function compairDistance(e,t){var n=parseInt(e.distance),i=parseInt(t.distance);return n<i?-1:n>i?1:parseInt(e.total)!=parseInt(t.total)?compairPrice(e,t):void 0}function properCapitlize(e){for(var t=e.split(/[ .:;?!~,`"&|()<>{}\[\]\r\n\/\\\-]+/),n="",i=-1,a=0;a<t.length;a++)i=i+1+t[a].length,n=n+t[a].charAt(0).toUpperCase()+t[a].substring(1,t[a].length)+e.charAt(i);return n=n.substring(0,n.length)}function updateTable(){var e=document.getElementById("allResults");if(e.innerHTML="",0!=fbos.length)for(var t=0;t<this.fbos.length;t++){var n=document.createElement("div");n.setAttribute("class","result");var i=document.createElement("table");i.setAttribute("class","resultTable");var a=i.insertRow(i.rows.length),c=document.createElement("td"),l=document.createElement("H3");l.appendChild(document.createTextNode(t+1+". "+properCapitlize(feeDict[fbos[t].name].airport))),c.appendChild(l),a.appendChild(c);var o=document.createElement("td"),r=document.createElement("H3");r.setAttribute("class","center"),r.appendChild(document.createTextNode(feeDict[fbos[t].name].distance)),o.appendChild(r),a.appendChild(o);var d=document.createElement("td"),s=document.createElement("H4");s.appendChild(document.createTextNode("Total Cost: $"+feeDict[fbos[t].name].total)),d.setAttribute("class","right"),d.appendChild(s),a.appendChild(d);var p=document.createElement("td"),u=document.createElement("button");u.innerHTML="Book Trip",p.setAttribute("class","center"),p.appendChild(u),a.appendChild(p);var m=i.insertRow(i.rows.length),f=document.createElement("td"),h=document.createElement("H4");h.appendChild(document.createTextNode("\xa0\xa0"+properCapitlize(fbos[t].name))),f.appendChild(h),m.appendChild(f),n.appendChild(i),e.appendChild(n)}else{var n=document.createElement("div");n.setAttribute("class","result");var g=document.createElement("H3");g.appendChild(document.createTextNode("Sadly, it seems there are no airports within the mile radius you selected for this city. Try again with a larger radius, or from another nearby city. Sorry for any inconveince!")),n.appendChild(g),e.appendChild(n)}}window.addEventListener("load",start,!1);var feeDict,fbos=[],curFilter,appliedFees={};