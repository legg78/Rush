function data_change(value) {
	alert(event.keyCode);
	return false;
}
 
 function isNumber(sText) {
	 if (sText=="") return false;
	 var ValidChars = "0123456789.";
	 var IsNumber=true;
	 var Char;
	 var dotCnt = 0;

	 for (i = 0; i < sText.length && IsNumber == true; i++)
	 {
	 Char = sText.charAt(i);
	 if (Char==".") dotCnt = dotCnt +1;
	 if (ValidChars.indexOf(Char) == -1 || dotCnt>1)
	 {
	 IsNumber = false;
	 }
	 }
	 return IsNumber;

	 }