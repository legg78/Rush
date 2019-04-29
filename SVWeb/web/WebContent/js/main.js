var oldValue;
var rightButton;
var contextPath = "";
var disableContext=false;

var isIE = false;
var IEVersion;

new function() {
    var base = document.getElementsByTagName('base')[0];
    if (base && base.href && (base.href.length > 0)) {
        base = base.href;
    } else {
        base = document.URL;
    }
    var hashIndex = base.indexOf('#');
    var paramIndex = base.indexOf('?');
    var truncIndex = hashIndex > 0 && paramIndex > 0 ? Math.min(hashIndex, paramIndex) : Math.max(hashIndex, paramIndex);
    if (truncIndex >= 0) {
        base = base.substring(0, truncIndex);
    }
    contextPath = base.substr(0, base.indexOf('/', base.indexOf('/', base.indexOf('//') + 2) + 1));
}();

function detectIE() {
	var IEString = "MSIE";
	if (navigator.userAgent.indexOf(IEString) == -1) {
		return;
	}
	isIE = true;
	IEVersion = parseFloat(navigator.userAgent.substring(
			navigator.userAgent.indexOf(IEString) + IEString.length+1));
}

detectIE();

/**
 * <p>Blocks standard modal panel buttons to prevent double click or
 * misclicks when some action is performed.</p>
 */
function disableModalPanelBtns(button) {
	
	var formEl;
	if (button.nodeName.toLowerCase() != "form") {
		formEl = button.parentNode;
		while (formEl && formEl.nodeName && formEl.nodeName.toLowerCase() != "form") {
			formEl = formEl.parentNode;
		}
	} else {
		formEl = button;
	}

	if (!formEl || !jQuery(formEl).is("form"))
		return;

//	document.getElementById(formEl.id + ":saveBtn").disabled = true;
//	document.getElementById(formEl.id + ":cancelBtn").disabled = true;

	// block all inputs of type 'button' and 'submit' inside form
	var inputs = formEl.getElementsByTagName("INPUT");
	for (var i = 0; i < inputs.length; i++) {
	    if (inputs[i].type == 'button' || inputs[i].type == 'submit') {
	        inputs[i].disabled = true;
	    }
	}
	
	// block all <button> inside form
	var buttons = formEl.getElementsByTagName("BUTTON");
	for (var i = 0; i < buttons.length; i++) {
		buttons[i].disabled = true;
	}
	
	/*
	// block all <a> inside form
	var as = formEl.getElementsByTagName("A");
	for (var i = 0; i < as.length; i++) {
		as[i].setAttribute("disabled", "disabled");
		var onclicktxt = as[i].getAttribute("onclick");
		as[i].setAttribute("onclick", "return false;" + onclicktxt);		
	}
	*/
}

/**
 * <p>Unblocks standard modal panel buttons after some action has been 
 * performed.</p>
 */
function enableModalPanelBtns(button) {
	var formEl = button.parentNode;
	while (formEl && formEl.nodeName && formEl.nodeName.toLowerCase() != "form") {
		formEl = formEl.parentNode;
	}

	if (!formEl || !jQuery(formEl).is("form"))
		return;

//	document.getElementById(formEl.id + ":saveBtn").disabled = false;
//	document.getElementById(formEl.id + ":cancelBtn").disabled = false;

	// block all inputs of type 'button' and 'submit' inside form
	var inputs = formEl.getElementsByTagName("INPUT");
	for (var i = 0; i < inputs.length; i++) {
	    if (inputs[i].type == 'button' || inputs[i].type == 'submit') {
	        inputs[i].disabled = false;
	    }
	}
	
	// block all <button> inside form
	var buttons = formEl.getElementsByTagName("BUTTON");
	for (var i = 0; i < buttons.length; i++) {
		buttons[i].disabled = false;
	}
	/*
	var as = formEl.getElementsByTagName("A");
	for (var i = 0; i < as.length; i++) {
		as[i].removeAttribute("disabled");
		var onclicktxt = as[i].getAttribute("onclick");
		onclicktxt = onclicktxt.replace(/return false;/g,"");
		as[i].setAttribute("onclick", onclicktxt);		
	}
	*/
}

/**
 * <p>
 * Allows only numbers to be typed in input[type='text']. 
 * Not quite universal so use with <i>onkeypress</i> event only.
 * </p>
 * @param element - element from which this function is invoked
 * @param e - event
 * @param dot - whether decimal point is eligible or not 
 * @return
 */
function numbersOnly(element, e, dot, negative) {
	var code;
	var shift;
	var ctrl;
	var event = window.event || e;
	if (window.event) { 
		code = window.event.keyCode;
		shift = window.event.shiftKey;
		ctrl = window.event.ctrlKey;
	} else {
		code = e.charCode;
		shift = e.shiftKey;
		ctrl = e.ctrlKey;
	}

	if (code == null || code == 0 || code == 8 || 
		    code == 9 || code == 13 || code == 27) {
		return true;
	/** 
	 * if use commented code with <i>onkeypress</i> in FF it'll allow special 
	 * symbols like "!#$%&(" to be entered. Under IE <i>onkeypress</i> event
	 * isn't triggered if non-character key is pressed, so there's no need
	 * to process them. 
	 */
//	} else if ((code >= 33 && code <= 40) || code == 45 || code == 46) {
//		//arrows & home,end, pageup, pagedown, delete, insert
//		return true;
	} else if (!shift && code > 47 && code < 58) {
		return true;
	} else if (ctrl && (String.fromCharCode(code) == 'c' || String.fromCharCode(code) == 'v')) {
		// copy-paste for FF
		return true;
	} else if (negative && String.fromCharCode(code) == "-") {
		if (element.value.indexOf("-") < 0) {
			element.value = "-" + element.value;
		}
		//set key code for IE only
		event.keyCode = 0;
		return false;
	}
	if (dot && element.value.indexOf(".") < 0) {
		if (String.fromCharCode(code) == ".") {
			return true;
		} else if (String.fromCharCode(code) == ",") {
			replaceComma(element);
		}
	}
	//set key code for IE only
	event.keyCode = 0;
	return false;
}
/**
 * <p>
 * Allows only numbers to be pasted in input[type='text'].
 * </p>oked
 * @param event
 * @return
 */
function numbersOnlyPaste (event, element, length) {
    var pasteValue = event.clipboardData.getData('text/plain');
    var elementValue = element.value;
    if(/^\d+$/.test(pasteValue)) {
        if(typeof length !== 'undefined') {
            if((pasteValue.length + elementValue.length) <= length )
                return true;
            return false;
        }
        return true;
    }
    return false;
}
function alfaNumbersOnly(element, e) {
	var code;
	var shift;
	var ctrl;
	var event = window.event || e;
	if (window.event) { 
		code = window.event.keyCode;
		shift = window.event.shiftKey;
		ctrl = window.event.ctrlKey;
	} else {
		code = e.charCode;
		shift = e.shiftKey;
		ctrl = e.ctrlKey;
	}
	if (code == null || code == 0 || code == 8 || 
		    code == 9 || code == 13 || code == 27) {
		return true;
	} else if (!shift && code > 47 && code < 58) {
		return true;
	} else if(( code >= 97 && code <= 122 ) ||
	          ( code > 1040 && code <= 1103 )){
		return true;
	} else if (ctrl && (String.fromCharCode(code) == 'c' || String.fromCharCode(code) == 'v')) {
		// copy-paste for FF
		return true;
	}
	event.keyCode = 0;
	return false;
}

function replaceComma(element) {
	if (document.selection) { 
		// for IE
		var range = document.selection.createRange();
		range.text = '.';
    } else if (element.selectionStart || element.selectionStart == '0') { 
    	var start = element.selectionStart;
    	var end   = element.selectionEnd;
    	element.value = element.value.substring(0, start) + '.' +
    			element.value.substring(end, element.value.length);
    	element.selectionStart = start + 1;
    	element.selectionEnd   = start + 1;     
    } else {
    	element.value += '.';
    }
    return false;
}

function checkPositive(element) {
	if (element == null) {
		return false;
	}
	var value = element.value;
	if (value != null && value >= 0) {
		return true; 
	}
	return false;
}

function checkNumbers(value, intOnly) {
	if ((intOnly && /^\d*$/.test(value)) || /^\d*(\.\d+)?$/.test(value)) { 
		return true;
	}
	return false;
}

function limitText(e, limitField, limitNum) {
	var event = window.event || e;
	var code;
	if (window.event) { 
		code = window.event.keyCode;
	} else {
		code = e.charCode;
	}
	var result = (limitField.value.length < limitNum)||(code == 0 || code == 8 || code == 9 || code == 13 ||code == 27);
	//set key code for IE only
	if (!result) event.keyCode = 0;
	return result;
}

function ignoreEnter(e) {
	if (!e) e = window.event; 

	var code = (e.keyCode) ? e.keyCode : e.which;

	if (code == 13 || code == 3) return true;
	return false;
}

function handleEnter(event, submitButtonId) {
	if (submitButtonId && event && event.keyCode && event.keyCode == 13) {
		document.getElementById(submitButtonId).click();
		return false;
	}
	return true;
}

function isNonFunctionalKey(e, ignoreEnter) {
	if (!e) e = window.event; 
	var code = (e.keyCode) ? e.keyCode : e.which;
	
	//   ctrl           alt                 arrows                 capslock
	if (code == 17 || code == 18 || (code >= 37 && code <= 40) || code == 20
			//    end         escape         home           insert
			|| code == 35 || code == 27 || code == 36 || code == 45
			//   page up     page down       shift         tab
			|| code == 33 || code == 34 || code == 16 || code == 9) {
		return true;
	}
	
	if (code == 13 && ignoreEnter) {
		return true;
	}
	
	return false;
}

// for context menu

var savedEvent;
var savedPanelName;	 

function handleMouseClick(e) {
	e.stopPropagation ? e.stopPropagation() : (e.cancelBubble=true);
	if (!e) var e = window.event;
	if (e.which) rightButton = (e.which == 3);
	else if (e.button) rightButton = (e.button == 2);
}

function setDisableContext(l){
	disableContext=l;
}

function isSelectedRow(elem, isRow) {
	var $elem = jQuery(elem);
	return $elem.parents(".extdt-row-selected").size() > 0 || $elem.parents(".treetable_selection").size() > 0 ||
	       $elem.hasClass("extdt-row-selected") || $elem.hasClass("treetable_selection");
}

function showMenu(elem, isRow) {
	return rightButton && isSelectedRow(elem, rightButton);
}

function isCurrentTreeRowSelected(elem, treeId) {
	var tree = document.getElementById(treeId);
	if (rightButton && elem.className.indexOf("treetable_selection") > 0) { //"treeRow" + tree.getSelectedNodeKey()
		return true;
	}
	return false;
}

function showMenuForTree(elem, treeId, isTransaction, event) {
	if (!event) {
		event = window.event;
	}
	if (isTransaction && isCurrentTreeRowSelected(elem, treeId)) {
		savedEvent = event;
		return true;
	}
	return false;
}

function saveEvent(e) {
	if (!e) e = window.event;
	savedEvent = e;
}
// end context menu

function hideErrorField(elem) {
	var element = document.getElementById(elem.id + "Error");
	if (element) {
		element.style.display = "none";
	}
	return true;
}

function checkField(fieldId) {
	if (document.getElementById(fieldId) != null && document.getElementById(fieldId).value == "") {
		document.getElementById(fieldId + "Error").style.display = "inline";
		return false;
	}
	return true;
}

function hideErrorDateField(elem) {
	var id = elem.id.substr(0, elem.id.length - "InputDate".length);
	document.getElementById(id + "Error").style.display = "none";
}

function checkDateField(fieldId) {
	if (document.getElementById(fieldId + "InputDate") != null && document.getElementById(fieldId + "InputDate").value == "") {
		document.getElementById(fieldId + "Error").style.display = "inline";
		return false;
	}
	return true;
}

/**
 * Checks input fields that accept numbers with certain exponent for 
 * exceeding the length of fractional part. 
 * @param element
 * @param exponent
 * @return
 */
function isExponentExceeded(element, e, exponent) {
	var defaultExponent = 2;	// see ru.bpc.jsf.conversion.CurrencyConverter
	var code;
	if (window.event) { 
		code = window.event.keyCode;
	} else {
		code = e.charCode;
	}
	// here we check only if fractional part is too big so we check only digits,
	// other symbols should be filtered in numbersOnly() or anywhere else
	if (code < 48 || code > 57) {
		return false;
	}
	
	var sel = getInputSelection(element);
	var dotPosition = element.value.indexOf('.');
	if (dotPosition < 0 || dotPosition >= sel.start) {
		return false;
	}

	if (exponent == "") exponent = defaultExponent;

	var fractionPartLength = element.value.substr(dotPosition + 1).length; 
	if (fractionPartLength < exponent) {
		return false;
	}
	var selectionLength = sel.end - sel.start;
	if (fractionPartLength == exponent && selectionLength > 0) {
		return false;
	}
    return true;
}

/**
 * Gets selection of input element
 * @param el
 * @return
 * @author Tim Down
 * {@link = http://stackoverflow.com/questions/3622818/ies-document-selection-createrange-doesnt-include-leading-or-trailing-blank-li}
 */
function getInputSelection(el) {
    var start = 0, end = 0, normalizedValue, range,
        textInputRange, len, endRange;

    if (typeof el.selectionStart == "number" && typeof el.selectionEnd == "number") {
        start = el.selectionStart;
        end = el.selectionEnd;
    } else {
        range = document.selection.createRange();

        if (range && range.parentElement() == el) {
            len = el.value.length;
            normalizedValue = el.value.replace(/\r\n/g, "\n");

            // Create a working TextRange that lives only in the input
            textInputRange = el.createTextRange();
            textInputRange.moveToBookmark(range.getBookmark());

            // Check if the start and end of the selection are at the very end
            // of the input, since moveStart/moveEnd doesn't return what we want
            // in those cases
            endRange = el.createTextRange();
            endRange.collapse(false);

            if (textInputRange.compareEndPoints("StartToEnd", endRange) > -1) {
                start = end = len;
            } else {
                start = -textInputRange.moveStart("character", -len);
                start += normalizedValue.slice(0, start).split("\n").length - 1;

                if (textInputRange.compareEndPoints("EndToEnd", endRange) > -1) {
                    end = len;
                } else {
                    end = -textInputRange.moveEnd("character", -len);
                    end += normalizedValue.slice(0, end).split("\n").length - 1;
                }
            }
        }
    }

    return {
        start: start,
        end: end
    };
}

/**
 * Shows or hides rows which contain elements with certain style classes   
 */
function showHideRows() {
	var hiddenRows = jQuery('.hiddenRow');
	for (var i = 0; i < hiddenRows.length; i++) {
		hiddenRows[i].parentNode.parentNode.style.display = "none";
	}
	var visibleRows = jQuery('.visibleRow');
	for (var i = 0; i < visibleRows.length; i++) {
		visibleRows[i].parentNode.parentNode.style.display = "";
	}
}

//-----------------------

var detailsStates = new Object();
var EXPANDED_CATEGORY_CSS_CLASS = "expandedBranch";
var COLLAPSED_CATEGORY_CSS_CLASS = "collapsedBranch";

/**
 * Shows or hides details category in details tab. 
 */
function showHideDetails(elem) {
	var column = elem.parentNode;
	var collapse = column.className.indexOf(EXPANDED_CATEGORY_CSS_CLASS) >= 0;
	if (collapse) {
		column.className = replaceClass(column.className, EXPANDED_CATEGORY_CSS_CLASS, COLLAPSED_CATEGORY_CSS_CLASS);
		elem.src = elem.src.replace("minus.gif", "plus.gif");
		detailsStates[elem.parentNode.id] = COLLAPSED_CATEGORY_CSS_CLASS;
	} else {
		column.className = replaceClass(column.className, COLLAPSED_CATEGORY_CSS_CLASS, EXPANDED_CATEGORY_CSS_CLASS);
		elem.src = elem.src.replace("plus.gif", "minus.gif");
		detailsStates[elem.parentNode.id] = EXPANDED_CATEGORY_CSS_CLASS;
	}
	
	collapseExpandDetailsRows(column, collapse);
}

/**
 * <p>
 * Replaces <code>remove</code> class with <code>insert</code> class in
 * <code>className</code>. If <code>remove</code> class doesn't exist
 * <code>insert</code> class just added to the end of className (with
 * preceding space symbol). If <code>insert</code> class already exists in
 * <code>className</code> it's just left unchanged. If both exist or some
 * duplicates of any are caught then only one instance of <code>insert</code>
 * will be available in result anyway.
 * </p>
 * 
 * @param className -
 *            some element's <i>class</i> attribute
 * @param remove -
 *            CSS class to remove
 * @param insert -
 *            CSS class to insert
 * @return
 */
function replaceClass(className, remove, insert) {
	var classes = className.split(" ");
	var result = "";
	var separator = " ";
	var replaced = false;
	for (var i = 0; i < classes.length; i++) {
		if (i == classes.length - 1) separator = "";
		if (classes[i] == remove || classes[i] == insert) {
			if (!replaced) {
				result += insert + separator;
			}
			replaced = true;
		} else if (classes[i] == "") {
			continue;
		} else {
			result += classes[i] + separator;
		}
	}
	if (!replaced) {
		className += " " + insert;
	}
	return result;
}

function collapseExpandDetailsRows(column, collapse) {
	var row = column.parentNode.nextSibling;
	while (row != null) {
		if (row.nodeName != "TR") {
			row = row.nextSibling;
			continue;
		}
		if (collapse) {
			if (getTd(row).className.indexOf("detailsCategory") < 0) {
				row.style.display = "none";
			} else {
				break;
			}
		} else {
			if (getTd(row).className.indexOf("detailsCategory") < 0) {
				row.style.display = "";
			} else {
				break;
			}
		}
		row = row.nextSibling;
	}
}

function getTd(row) {
	var td = row.firstChild;
	while (td.tagName != "TD") {
		td = td.nextSibling;
	}
	return td;
}

function setDetailsState(detailsTableId) {
	for (var id in detailsStates) {
		if (detailsTableId) {
			// if detailsTableId is set then expand/collapse only indicated table
			if (id.indexOf(detailsTableId) == 0) {
				setDetailsCategoryState(id);
			}
		} else {
			// if detailsTableId is not set then expand/collapse all details
			setDetailsCategoryState(id);
		}
	}
}

function setDetailsCategoryState(id) {
	var column = document.getElementById(id);
	if (!column) return;
	var img = column.getElementsByTagName("IMG");
	if (!img || img.length == 0) return;
	if (detailsStates[id] == EXPANDED_CATEGORY_CSS_CLASS) {
		// after rerender is done all categories are expanded but if they're not uncomment this
//		column.className = replaceClass(column.className, COLLAPSED_CATEGORY_CSS_CLASS, EXPANDED_CATEGORY_CSS_CLASS);
//		img[0].src = img[0].src.replace("plus.gif", "minus.gif");
//		collapseExpandDetailsRows(column, false);
	} else {
		column.className = replaceClass(column.className, EXPANDED_CATEGORY_CSS_CLASS, COLLAPSED_CATEGORY_CSS_CLASS);
		img[0].src = img[0].src.replace("minus.gif", "plus.gif");
		collapseExpandDetailsRows(column, true);
	}
}
//----------------------------------------

/**
 * Removes white spaces from both ends of str
 */
function trim(str){
	if (str==null) {
		return "";
	}
	return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
}

/**
 * Fills table rows with standard colours.
 * 
 * @param tableId
 * @return
 */
function makeZebraStyle(tableId) {
	var table = document.getElementById(tableId);
	var tbody = table.getElementsByTagName("TBODY");
	var rows;
	if (tbody != null && tbody.length > 0) {
		rows = tbody[0].childNodes;
	} else {
		rows = table.childNodes;
	}
	var odd = false; 
	for (var i = 0; i < rows.length; i++) {
		if (rows[i].tagName.toUpperCase() == "TR") {
			if (odd) {
				rows[i].className = rows[i].className + " odd"; 
			}
			odd = !odd;
		}
	}
}

/**
 * Gets elements with tag names from <code>list</code> inside <code>obj</code>
 * element and sorts them in order of appearance (if <code>obj</code> is
 * <code>null</code> then <code>document</code> is used).
 * 
 * @param list -
 *            comma separated list of tag names
 * @param obj -
 *            element where to search for tags from <code>list</code>
 * @param hidden -
 *            include hidden elements
 * @param disabled -
 *            include disabled elements
 * @return
 * @see http://www.quirksmode.org/dom/getElementsByTagNames.html
 */
function getElementsByTagNames(list, obj, hidden, disabled) {
	if (!obj) var obj = document;
	var tagNames = list.split(',');
	var resultArray = new Array();
	for (var i = 0; i < tagNames.length; i++) {
		var tags = obj.getElementsByTagName(tagNames[i]);
		for (var j = 0; j < tags.length; j++) {
			if ((!hidden && tags[j].type == "hidden") || (!disabled && tags[j].disabled)) {
				continue;
			}
			resultArray.push(tags[j]);
		}
	}
	var testNode = resultArray[0];
	if (!testNode) return [];
	if (testNode.sourceIndex) {
		resultArray.sort(function (a, b) {
				return a.sourceIndex - b.sourceIndex;
		});
	}
	else if (testNode.compareDocumentPosition) {
		resultArray.sort(function (a, b) {
				return 3 - (a.compareDocumentPosition(b) & 6);
		});
	}
	return resultArray;
}

function focusFirstElemet(formId) {
	var tags = "input,select,textarea";
	var elems = getElementsByTagNames(tags, document.getElementById(formId));
	elems[0].focus();
}

// just a blank method that prevents javascript errors when pages try to call
// same method from page that wasn't fully rendered yet. Once page is rendered
// this method is overridden by the method on that page.
function updateHeight(){updateGridHeight();}

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

function fixScrollableTables() {
	/* Fix for tables with scrollable content, like OpenFaces treeTable.
	 Such tables misbehave in IE browser, incorrectly calculating column widths.
	 Current fix forces forces table to recalculate widths after document is completely loaded */
	jQuery('.o_scrollable_table').each(function(){
		if (this._centerArea && this._centerArea.updateWidth) {
			try {
				this._centerArea.updateWidth();
			} catch (e) {
			}
		}
	});
}



var app = {
    isNull: function(value) {
        return value == null || value == undefined;
    },

    isEmpty: function(value) {
        return value == null || value == undefined || (Object.isString(value) && value.replace(/[ \s\t]/g) == '');
    },

    // return errorMessage if has errors
    checkMaskValue: function(value, options) {
        var params = jQuery.extend({
            minMaskTailLength: 4,
            errorMessage: '',
            allowEmpty: true
        }, options);

        if(app.isEmpty(value)) {
            if (!params.allowEmpty) {
                return params.errorMessage.replace('{0}', params.minMaskTailLength);
            } else {
                return null;
            }
        }
        var index = Math.max(value.lastIndexOf('*'), value.lastIndexOf('%'), value.lastIndexOf('?'), value.lastIndexOf('_'));
        if (index == -1) return null; // it's ok
        if ((value.length - index) <= params.minMaskTailLength) {
            return params.errorMessage.replace('{0}', params.minMaskTailLength);
        }
        return null;
    },

    showWarning: function(message, options) {
        var params = jQuery.extend({
            html: true
        }, options);

        var node = jQuery("#baseWarningDialog\\:confirmPanelForm\\:warningMsg");
        if (params.html) {
            node.html(message);
        } else {
            node.text(message);
        }
        Richfaces.showModalPanel('baseWarningDialog:confirmPanel');
    },

    css: function ($node, property, value) {
        $node.each(function() {
            var style = this.style;
            if (!style) return;
            if (app.isEmpty(value)) {
                if (style.removeAttribute) {
                    style.removeAttribute(property);
                } else {
                    style.removeProperty(property);
                }
            } else {
                style[property] = value;
            }
        });
    },

    handleEnter: function(event, btnId) {
        if (event.keyCode == 13) {
            document.getElementById(btnId).click();
            return false;
        }
        return true;
    }
};


jQuery(document).ready(function () {
    A4J.AJAX.onError = function(req, status, message){
        var json = null;
        if (status === 401) {
            try {
                json = JSON.parse(req.getResponseText());
            } catch (ignored) {
            }
            if (json && json.redirect) {
                if (json.redirect === '/logout') {
                    json.redirect = contextPath + json.redirect;
                }
                window.location = json.redirect;
            }
        }
    }
});

x$ = function(selector, parent) {
    if(typeof selector == 'string') {
        return jQuery(selector.replace(/:/g, '\\:'), parent);
    } else {
        return jQuery(selector, parent);
    }

};


(function($) {
    var colors = {
      DANGER: '#FFB2B2',
      SUCCESS: '#B2FFB2',
      WARNING: '#fff08d',
      DISABLED: '#BBBBBB'
    };

    /**
     Examples:
     var isValidField = x$('#formatEditForm:instId').validate();
     var isValidAllFields = x$('#formForEdit .required-fields').validate();
     var invalidFieldList1 = x$('#formForEdit .required-fields').validate({returnList: true});
     var invalidFieldList2 = x$('#formForEdit .required-fields').validate({
        returnList: true,
        check: function(value) {
          if (value == '9999' || app.isEmpty(value)) return true;
          return false;
        }
     });
     */
    $.fn.inputValidation = function(options) {
        var settings = $.extend({
            maxLength: -1,
            numbersOnly: false,
            alphaNumOnly: false
        }, options);

        return this.each(function() {
            var node = $(this);
            node.bind('paste keypress', function() {
                var oldValue = node.val();

                setTimeout(function() {
                    var value = node.val();
                    if(settings.numbersOnly === true) {
                        if(!/^\d+$/.test(value) && !app.isEmpty(value)) {
                            node.val(oldValue);
                        }
                    }
                    else if (settings.alphaNumOnly === true) {
                        if(!/^[a-z0-9]+$/i.test(value) && !app.isEmpty(value)) {
                        	node.val(oldValue);
                        }
                    }
                    value = node.val();
                    if (settings.maxLength >= 0) {
						if(value.length > settings.maxLength) {
							node.val(value.substr(0, settings.maxLength));
                        }
                    }
                }, 0);
            });
        });
	}

    $.fn.validate = function(options) {
        var settings = $.extend({
            returnList: false,
            check: null
        }, options);

        var list = $([]);
        this.each(function() {
            var $this = $(this);

            if ($this.hasClass('rich-combobox')) {
                $this = $this.parent();
            }

            var checkNode = $this;
            var markNode = $this;
            if($this.children('.rich-combobox').length) {
                checkNode = x$('#' + $this.attr('id') + 'comboboxValue');
                markNode = $this.find('.rich-combobox-shell > input');
            } else if($this.hasClass('rich-calendar-popup')) {
                checkNode = x$('#' + $this.attr('id') + 'InputDate');
                markNode = checkNode;
            }
            var badValue = null;
            if ($.isFunction(settings.check)) {
                badValue = !settings.check.apply(checkNode, [checkNode.val(), $this, markNode]);
            } else {
                if (checkNode[0].maskType) {
                    badValue = checkNode[0].maskType.isEmpty();
                } else {
                    badValue = app.isEmpty(checkNode.val());
                }
            }
            if (badValue) {
                markNode.markError(settings);
                list = list.add($this);
            } else {
                markNode.markNormal(settings);
            }
        });

        return settings.returnList ? list : list.length == 0;
    };

    $.fn.errorLabel = function(options) {
        var settings = $.extend({
            errorLabelNode: null,
            errorLabelSuffix: 'Error',
            errorLabelId: null,
            errorLabelShow: true
        }, options);

        return this.each(function() {
            var $this = $(this);
            var node = null;
            if (settings.errorLabelId) {
                node = settings.errorLabelNode;
            } else if (settings.errorLabelId) {
                node = x$('#' + settings.errorLabelId);
            } else if(settings.errorLabelSuffix) {
                var id = $this.attr('id');
                if (!id) return;
                if ($this.hasClass('rich-combobox') && id.endsWith('combobox')) {
                    id = id.replace(/combobox$/, '');
                } else if ($this.parent().hasClass('rich-combobox-shell') && id.endsWith('comboboxField')) {
                    id = id.replace(/comboboxField$/, '');
                } else if ($this.hasClass('rich-calendar-input')) {
                    id = id.replace(/InputDate$/, '');
                }
                if (id) {
                    node = x$('#' + id + settings.errorLabelSuffix);
                }
            }
            if (!node) return;
            app.css(node, 'display', settings.errorLabelShow ? null : 'none');
        });
    };

    $.fn.highlight = function(options) {
        var settings = $.extend({
            backgroundColor: null
        }, options);

        return this.each(function() {
            var $this = $(this);
            var node = $this;
            if ($this.hasClass('rich-combobox') || $this.children('.rich-combobox').length) {
                node = $this.find('.rich-combobox-shell > input');
            } else if($this.hasClass('rich-calendar-popup')) {
                node = x$('#' + $this.attr('id') + 'InputDate');
            }
            app.css(node, 'background-color', settings.backgroundColor);
        });
    };

    $.fn.markError = function(options) {
        var settings = $.extend({
            backgroundColor: colors.DANGER,
            errorLabelShow: true
        }, options);
        return this.highlight(settings).errorLabel(settings);
    };

    $.fn.markSuccess = function(options) {
        var settings = $.extend({
            backgroundColor: colors.SUCCESS
        }, options);
        return this.highlight(settings);
    };

    $.fn.markWarning = function(options) {
        var settings = $.extend({
            backgroundColor: colors.WARNING
        }, options);
        return this.highlight(settings);
    };

    $.fn.markDisabled = function(options) {
        var settings = $.extend({
            backgroundColor: colors.DISABLED
        }, options);
        return this.highlight(settings);
    };

    $.fn.markNormal = function(options) {
        var settings = $.extend({
            backgroundColor: null,
            errorLabelShow: false
        }, options);
        return this.highlight(settings).errorLabel(settings);
    };
})(jQuery);
