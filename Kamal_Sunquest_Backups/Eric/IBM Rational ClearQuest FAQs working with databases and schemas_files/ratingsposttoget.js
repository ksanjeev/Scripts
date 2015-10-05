function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}

addLoadEvent(function() {
  for (var i=0; i < document.forms.length; i++) {
    if (document.forms[i].action.search(/RatingsHandler/) > 0) {
	document.forms[i].method = 'GET';
    }
  }
});
