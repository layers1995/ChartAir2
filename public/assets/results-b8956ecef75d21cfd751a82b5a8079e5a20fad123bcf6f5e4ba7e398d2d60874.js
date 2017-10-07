function start(){feeDict=gon.dict,destination=gon.destination,addListeners(),createFboList(),fillAppliedFeesDict(),filterButtonClicked(curFilter)}function addListeners(){document.getElementById("filters").onchange=function(){filterButtonClicked()},document.getElementById("locationIcon").onchange=function(){filterButtonClicked("distance")},document.getElementById("landing").onclick=function(){feeButtonClicked("landing")},document.getElementById("tie down").onclick=function(){feeButtonClicked("tie down")},document.getElementById("ramp").onclick=function(){feeButtonClicked("ramp")},document.getElementById("facility").onclick=function(){feeButtonClicked("facility")},document.getElementById("call out").onclick=function(){feeButtonClicked("call out")},document.getElementById("other").onclick=function(){feeButtonClicked("other")}}function createFboList(){var e=Object.keys(feeDict);if(e.length>fbos.length)for(var t=0;t<e.length;t++){var n={name:"",distance:0,total:0};n.name=e[t],n.distance=parseInt(feeDict[e[t]].distance.substring(0,feeDict[e[t]].distance.length-4)),n.total=feeDict[e[t]].total,this.fbos.push(n)}}function fillAppliedFeesDict(){appliedFees.landing=!0,appliedFees["tie down"]=!0,appliedFees.ramp=!0,appliedFees.facility=!0,appliedFees["call out"]=!0,appliedFees.other=!0,document.getElementById("landing").checked=!0,document.getElementById("ramp").checked=!0,document.getElementById("tie down").checked=!0,document.getElementById("call out").checked=!0,feeButtonClicked("tie down"),feeButtonClicked("call out")}function filterButtonClicked(){var e=document.getElementById("filters"),t=e.options[e.selectedIndex].value;curFilter=t,curFilter="cost"===t?"cost":"distance",arrangeResults(),updateTable()}function feeButtonClicked(e){if(appliedFees[e]){appliedFees[e]=!1;document.getElementById(e);document.getElementById(e).checked=!1}else{appliedFees[e]=!0;document.getElementById(e);document.getElementById(e).checked=!0}updateTotalCost(),arrangeResults(),updateTable()}function updateTotalCost(){for(var e=Object.keys(appliedFees),t=0;t<this.fbos.length;t++){for(var n=!1,o=0,a=0;a<e.length;a++)null!=feeDict[fbos[t].name][e[a]]&&(n=!0,appliedFees[e[a]]&&(o+=Math.floor(feeDict[fbos[t].name][e[a]])));n?(fbos[t].total=o,feeDict[fbos[t].name].total=o):(fbos[t].total=1000001,feeDict[fbos[t].name].total=1000001)}}function arrangeResults(){"cost"===curFilter?fbos.sort(compairPrice):fbos.sort(compairDistance)}function compairPrice(e,t){var n=parseInt(e.total),o=parseInt(t.total);return n<o?-1:n>o?1:compairDistance(e,t)}function compairDistance(e,t){var n=parseInt(e.distance),o=parseInt(t.distance);if(1000001==parseInt(e.total)||1000001==parseInt(t.total)){if(parseInt(e.total)<parseInt(t.total))return-1;if(parseInt(e.total)>parseInt(t.total))return 1}return n<o?-1:n>o?1:parseInt(e.total)!=parseInt(t.total)?compairPrice(e,t):void 0}function properCapitlize(e){return e.toLowerCase().replace(/\b./g,function(e){return e.toUpperCase()})}function updateTable(){var e=document.getElementById("allResults");e.innerHTML="";var t="",n=0,o=Array(fbos.length);if(0!=fbos.length)for(var a=0;a<this.fbos.length;a++){var i=fbos[a].name;if(n>1)break;1000001==feeDict[i].total&&(n+=1);var l=document.createElement("div");l.setAttribute("class","result");var c=document.createElement("table");c.setAttribute("class","resultTable");var d=c.insertRow(c.rows.length),r=document.createElement("td"),s=document.createElement("H3");s.appendChild(document.createTextNode(a+1+". "+properCapitlize(feeDict[i].airport))),r.appendChild(s),d.appendChild(r);var u=document.createElement("td"),p=document.createElement("H3");p.setAttribute("class","center"),p.appendChild(document.createTextNode(feeDict[i].distance)),u.appendChild(p),d.appendChild(u);var m=document.createElement("td"),f=document.createElement("H4");feeDict[i].estimated&&f.setAttribute("class","estimate"),notAllFeesKnown(feeDict,i)&&f.setAttribute("class","estimate"),1000001==feeDict[i].total?f.appendChild(document.createTextNode("Unknown Cost")):f.appendChild(document.createTextNode("Total Cost: $"+feeDict[i].total)),m.setAttribute("class","right"),m.appendChild(f),d.appendChild(m);var h=document.createElement("td");o[a]=document.createElement("button"),o[a].innerHTML="Book Trip",o[a].setAttribute("id",a),o[a].onclick=function(){linkToBookTrip(this.id)},h.setAttribute("class","center"),h.appendChild(o[a]),d.appendChild(h);var g=c.insertRow(c.rows.length),C=document.createElement("td"),b=document.createElement("H4");b.appendChild(document.createTextNode("\xa0\xa0"+properCapitlize(i))),C.appendChild(b),g.appendChild(C);var k=document.createElement("td"),D="",E="";null!=feeDict[i].landing?D+="Landing: $"+Math.floor(feeDict[i].landing):D+="Landing: Unknown",null!=feeDict[i].ramp?E+="Ramp: $"+Math.floor(feeDict[i].ramp):E+="Ramp: Unknown",k.appendChild(document.createTextNode(D)),k.appendChild(document.createElement("br")),k.appendChild(document.createTextNode(E)),g.appendChild(k);var y=document.createElement("td"),B="",I="";null!=feeDict[i]["tie down"]?B+="Tie-Down: $"+Math.floor(feeDict[i]["tie down"]):B+="Tie-Down: Unknown",null!=feeDict[i]["call out"]?I+="Call-Out: $"+Math.floor(feeDict[i]["call out"]):I+="Call-Out: Unknown",y.appendChild(document.createTextNode(B)),y.appendChild(document.createElement("br")),y.appendChild(document.createTextNode(I)),g.appendChild(y);var v=document.createElement("td"),w=0,T="";null!=feeDict[i].facility?(w+=Math.floor(feeDict[i].facility),null!=feeDict[i].other?w+="Other: $"+Math.floor(feeDict[i].other)+Math.floor(w):T+="Other: $"+w):null!=feeDict[i].other?T+="Other: $"+Math.floor(feeDict[i].other):T+="Other: Unknown",v.appendChild(document.createTextNode(T)),g.appendChild(v),l.appendChild(c),e.appendChild(l),t+="&markers=color:red|label:"+(a+1)+"|"+feeDict[i].latitude+","+feeDict[i].longitude}else{var l=document.createElement("div");l.setAttribute("class","result");var F=document.createElement("H3");F.appendChild(document.createTextNode("Sadly, it seems there are no airports within the mile radius you selected for this city. Try again with a larger radius, or from another nearby city. Sorry for any inconveince!")),l.appendChild(F),e.appendChild(l)}createGoogleMap(t)}function notAllFeesKnown(e,t){return null==e[t].landing||(null==e[t].ramp||(null==e[t]["tie down"]||(null==e[t]["call out"]||null==e[t].facility&&null==e[t].other)))}function linkToBookTrip(e){var t=fbos[parseInt(e)].name,n=feeDict[t].airport,o=gon.tailnumber,a=gon.time,i=gon.time2,l=feeDict[t].total;window.location="https://push-fuzzykitenz.c9users.io/book_trip?fbo="+t+"&airport="+n+"&cost="+l+"&tailnumber="+o+"&time="+a+"&time2="+i}function createGoogleMap(e){var t=document.getElementById("googleMap"),n="&markers=color:blue|label:D|"+destination,o="http://maps.google.com/maps/api/staticmap?size=512x512&maptype=roadmap&sensor=false"+n+e;t.src=o}window.addEventListener("load",start,!1);var feeDict,fbos=[],curFilter,appliedFees={},destination;