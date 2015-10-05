//
// Do NOT modify this script to avoid traffic misrepresentation!
// Web CEO version 0300/1
//
// hitlens v1.2.5
function hitlens_external() {
var SERVER=1;
if(!(cpu=navigator.cpuClass)){cpu=''};
var rf=escape(document.referrer);
if((rf=="undefined")||(rf=="")){rf="bookmark";};
var frl=top.frames.length;
var hr=escape(location.href); 
var je=navigator.javaEnabled()?'y':'n';
var ce=navigator.cookieEnabled?'y':'n';
if(typeof(navigator.cookieEnabled)=='undefined'){ce=''};
if(!(sl=navigator.systemLanguage)){sl=''};
if(!(bl=navigator.browserLanguage)){bl=''}; 
if(!(ul=navigator.userLanguage)){ul=''};
if(!(nl=navigator.language)){nl=''};
var shw=screen.height+'*'+screen.width;
var scd=screen.colorDepth;
if(!scd){scd=screen.pixelDepth};
var d=new Date;
var tz=-d.getTimezoneOffset()/60;
var pg="";
if(navigator.plugins.length){
	for(var i = 0; i < navigator.plugins.length; i++){
		pg += navigator.plugins[i].name+";";
	} 
	pg=escape(pg);
}
var q=hitlens_embedded()+"&s="+SERVER+"&cpu="+cpu+"&rf="+rf+"&frl="+frl+"&hr="+hr+"&je="+je+"&ce="+ce+"&sl="+sl+"&bl="+bl+"&ul="+ul+"&nl="+nl+"&shw="+shw+"&scd="+scd+"&tz="+tz+"&pg="+pg+"&rndm="+Math.random();
var text="<a href='http://www.webceo.com/'>";
text=text+"<img src='http"+(location.href.indexOf('https:')==0?'s://www':'://track')+".websiteceo.com/m/?"+q+"' width='1' height='1' border='0' align='left'>";
text=text+"</a>";
return text;
}
document.write(hitlens_external());
