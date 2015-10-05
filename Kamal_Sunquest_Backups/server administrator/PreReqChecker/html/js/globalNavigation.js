
var infoWindow;
var helpWindow;
var contactsWindow;


function loadInfopage()
{
   location.href="http://localhost/blank.htm?doc.msg";
}

function loadInfoMSpage()
{
   location.href="http://localhost/blank.htm?docms.msg";
}

function loadQIGpage()
{
   location.href="http://localhost/blank.htm?qig.msg";
}

function exitSysMgmtCD()
{
   location.href="http://localhost/blank.htm?exit.msg";
}

var interval_handle;

function initSetTimer()
{
   interval_handle = setInterval("ticktock()", 1000);	  
	location.href = "http://localhost/blank.htm?depcheckready.msg"; 
}

//var index = 0;

function ticktock()
{
   if( this.loadingtext )
	{
      this.loadingtext.innerText += ".";
	}

//   if( cmcode.value == "0" ) 
//   {
//      clearInterval( interval_handle );
//      alert( prereqresultfile.value );
//      location.href = prereqresultfile.value;
//   }
   
//   index++;
    
//   if( index == 5 )   // after 5 seconds, tell app to load depcheck info
//   {
//	   clearInterval( interval_handle );
//      location.href = "http://localhost/loaddepcheck.msg";
//   } 
}

