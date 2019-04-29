var Stretch = {
	
	MIN_WORKPLACE_HEIGHT : 230,
    HEADER_HEIGHT: 45,
	COLLAPSE_TAB_HEIGHT : 25 /*Adjustable*/,
	TABS : 30,
	BUTTONS : 29,
	LANG_SELECTOR: 43,
    PAGINATED_AND_BUTTONS: 61,
    CALENDARS: 24,
    CALENDARS_AND_BUTTONS: 37,
    CHECKBOX: 22,
    CAPTION: 14,
    LABEL: 15,
    TOP_BUTTONS : 38,
    TOP_PADDING: 11,
	
	getWindowHeight: function (){
		if( typeof( window.innerWidth ) == 'number' ) {
		  //Non-IE
		  myHeight = window.innerHeight;
		} else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
		  //IE 6+ in 'standards compliant mode'
		  myHeight = document.documentElement.clientHeight;
		} else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
		  //IE 4 compatible
		  myHeight = document.body.clientHeight;
		}
		return myHeight;
	},
	
	updateTableHeightByFixedHeight: function (wrapperDivId, wrapperDivHeight){
		Stretch.checkExisting(wrapperDivId);
		var wrapperDiv = document.getElementById(wrapperDivId);
		wrapperDiv.style.height = wrapperDivHeight + "px";
		jQuery('.rich-extdt-maindiv', wrapperDiv).height(wrapperDivHeight - 2 /*border*/);
		var headHeight = jQuery('.extdt-thead', wrapperDiv).height();
		jQuery('.extdt-content', wrapperDiv).height(wrapperDivHeight - headHeight /*head*/);
		
	},
	
	updateTableHeightByWrapperHeight: function (wrapperDivId){
	    try {
            Stretch.checkExisting(wrapperDivId);
            var wrapperDiv = document.getElementById(wrapperDivId);
            var wrapperDivHeight = wrapperDiv.clientHeight;
            wrapperDiv.style.height = wrapperDivHeight + "px";
            jQuery('.rich-extdt-maindiv', wrapperDiv).height(wrapperDivHeight - 2 /*border*/);
            var clientHeight = jQuery('.rich-extdt-maindiv', wrapperDiv)[0]['clientHeight'];
            var headHeight = jQuery('.extdt-thead', wrapperDiv).outerHeight();
            jQuery('.extdt-content', wrapperDiv).height(clientHeight - headHeight /*head*/);
        } catch(e) {
	        console.error(e);
        }
	},
	
	updateTreeHeightByFixedHeight: function (wrapperDivId, wrapperDivHeight){
		Stretch.checkExisting(wrapperDivId);
		var wrapperDiv = document.getElementById(wrapperDivId);
		if (wrapperDivHeight < 0 ){
			wrapperDivHeight = 0; 
		}
		wrapperDiv.style.height = wrapperDivHeight;
		var mainTable = jQuery('.o_initially_invisible', wrapperDiv).get(0);
		jQuery(mainTable).height(wrapperDivHeight);
	},
	
	updateMainTreeByWrapperHeight: function (wrapperDivId){
		Stretch.checkExisting(wrapperDivId);
		var wrapperDiv = document.getElementById(wrapperDivId);
		var wrapperDivHeight = wrapperDiv.clientHeight;
		this.updateTreeHeightByFixedHeight(wrapperDivId, wrapperDivHeight);
	},	

	// depricated. Use details().
	updateDetailsHeightByFixedHeight: function (wrapperFormId, wrapperDivHeight){
		Stretch.checkExisting(wrapperFormId);
		var wrapperForm = document.getElementById(wrapperFormId);
		jQuery('.carddata-wrapper', wrapperForm).height(wrapperDivHeight - 2 /*border*/);
	},
	// depricated. Use details().	
	updateDetailsWrapperByFixedHeight: function (wrapperDivId, wrapperDivHeight){
		Stretch.checkExisting(wrapperDivId);
		var wrapperDiv = document.getElementById(wrapperDivId);
		wrapperDiv.style.height = wrapperDivHeight + "px";
	},

	// depricated. Use height()
	setHeight: function (elementId, height){
		var element = document.getElementById(elementId);
		if (element != null){
			element.style.height = height + 'px';
		}						
	},
	
	checkExisting: function(elementId){
		if (!Stretch.exists(elementId)){
			throw new Error("Wrapper: '" + elementId + "' is not found!");
		}
	},
	
	exists: function(elementId){
		return document.getElementById(elementId) != null;
	},
	
	form: function(formId, height){
		Stretch.checkExisting(formId);
		var formHeight = height - Stretch.BUTTONS - Stretch.TABS;
		if (isIE){
			formHeight = formHeight + 2;
		}
		document.getElementById(formId).style.height = formHeight + "px";
	},
	
	detailsFormWrapper: function(form, wrapper, base, modificator){
		var wrapperFullName = wrapper;
		var k = 2;
		if (form != null){
			Stretch.checkExisting(form);
			wrapperFullName = form + ":" + wrapper; 
		}
		Stretch.details(wrapperFullName, base, modificator);
		if (form != null){
			var formHeight = base - Stretch.BUTTONS - Stretch.TABS + k;
			document.getElementById(form).style.height = formHeight + "px";			
		}
	},
	
	detailsWrapper: function(wrapper, base, modificator){
		var k = 2;
		Stretch.checkExisting(wrapper);
		var wrapperHeight = base - modificator + k;
		document.getElementById(wrapper).style.height = wrapperHeight + "px";
	},
	
	details: function(a, b, c, d){
		if (arguments.length == 4) 
			return Stretch.detailsFormWrapper(a, b, c, d);
		else if (arguments.length == 3){
			return Stretch.detailsWrapper(a, b, c);
		}
	},
	
	height: function(elementId, height){
		Stretch.checkExisting(elementId);
		document.getElementById(elementId).style.height = height + "px";
	}
	
};


