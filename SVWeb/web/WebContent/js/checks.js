var or_label = 'or';
function setOrLable(label){
	or_label = label;
}
function empty(element){
	if (element.value == null || element.value == '') return true;
	return false;
}
function paint(element){
	element.style.backgroundColor = '#FF9999';
}
function clean(element){
	element.style.backgroundColor = '#FFFFFF';
}
function appendMsg(srcMsg, addMsg){
	var result = srcMsg;
	if (result != ''){
		result = result + '\n' + or_label + '\n';
	}
	result = result + addMsg;
	return result;
}
function cleanAll(elArray){
	for (i=0; i<elArray.length; i++){
		clean(elArray[i]);
	}
}
function paintAll(elArray){
	for (i=0; i<elArray.length; i++){
		paint(elArray[i]);
	}
}
function contain(element, symbol){
	var value = element.value;
	return value.indexOf(symbol) >= 0;	
}