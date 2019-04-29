	var tabs = {};
	var contextTabs = {};
	var currentTab;
	var tabNameInput;
	var submittingTab;
	
	function load(tabNameInputId) {
		tabNameInput = tabNameInputId;
		if(document.getElementById(tabNameInput) != null) {
			currentTab = document.getElementById(tabNameInput).value;
			tabs[currentTab] = true;
		}
	}
			 	
	function submitTab(tabName) {
		currentTab = tabName;
		document.getElementById(tabNameInput).value = currentTab;
		if (tabs[currentTab] == true) {
			//do not load tab if it is already loaded
			return false;
		}
		tabs[currentTab] = true;	
		return true;
	}
	
	function setTabLoaded(tabName) {
		currentTab = tabName;
		document.getElementById(tabNameInput).value = currentTab;
		tabs[currentTab] = true;
		return true;
	}
	
	function checkTabLoaded(tabName) {
		if (tabs[tabName] == true) {
			return true;
		}	
		return false;
	}
	
	function flushTabs() {
		tabs = {};
		flushContextTabs();
		if(document.getElementById(tabNameInput) != null){
			document.getElementById(tabNameInput).value = currentTab;
		}
	}
	
	//-------context tabs------------------	
    
	function setContextTabLoaded(tabName) {
		contextTabs[tabName] = true;
		return true;
	}
    
    function checkContextTabLoaded(tabName) {
		if (contextTabs[tabName] == true) {
			return true;
		}	
		return false;
	}
    
	function selectContextTab(tabName) {
		contextDialogTab = tabName;
		if (checkContextTabLoaded(tabName)) {
			setContextTabName(tabName);
			return false;
		}
		setContextTabLoaded(tabName);
		refreshContextTab(tabName);
		return true;
	}
	
	function flushContextTabs() {
		contextTabs = {};
	}
//---------------------------------
	
	function adjustTable() {
		
	}
	
	function unmarkTab(tabName) {
		tabs[tabName] = false;		
	}
	
	function stopScroll(tabPanelId) {
		jQuery("#" + tabPanelId + " .scrollable-tabs table:first").stop();
	}
	
	function scrollLeft(tabPanelId) {
		var left = parseInt(jQuery("#" + tabPanelId + " .scrollable-tabs table:first").css("margin-left"));
		if (isNaN(left)) {
			left = 0;
		}
		var width = jQuery("#" + tabPanelId + " .scrollable-tabs table:first").width();
		if (width + left <= 100) {
			jQuery("#" + tabPanelId + " .scrollable-tabs table:first").stop();
			return;
		}
		leftOffset = left - 100;
		if (width + left < 200) {leftOffset = 200-width;}
		//leftOffset = 200-width;
		jQuery("#" + tabPanelId + " .scrollable-tabs table:first").animate({marginLeft:leftOffset},"fast");
		//jQuery("#details .rich-tabhdr-cell-active").parent().parent().parent().css("margin-left",leftOffset);
	}

	function scrollRight(tabPanelId) {
		var left = parseInt(jQuery("#" + tabPanelId + " .scrollable-tabs table:first").css("margin-left"));
		if (isNaN(left)) {
			left = 0;
		}
		if (left == 0) {
	    	jQuery("#" + tabPanelId + " .scrollable-tabs table:first").stop();
	    	return;
	    }
	    leftOffset = left + 100;
	    if (leftOffset > 0 ) {leftOffset = 0;}
	    //leftOffset = 0;
	    jQuery("#" + tabPanelId + " .scrollable-tabs table:first").animate({marginLeft:leftOffset},"fast");
	    
	}
	
	function makeScrollableTabs(tabPanelId) {
		if (jQuery("#" + tabPanelId + " .tabs .scrollable-tabs").length != 0) {
			return;
		}
		jQuery(".content .template").clone().appendTo(jQuery("#" + tabPanelId + " .tabs"));
		jQuery("#" + tabPanelId + " .tabs .scrollable-tabs-table").removeClass("template");
		jQuery("#" + tabPanelId + " .tabs .scrollable-tabs-table").css("display", "");
		jQuery("#" + tabPanelId + " .tabs form:first").appendTo(jQuery("#" + tabPanelId + " .tabs .scrollable-tabs"));
		
		jQuery("#" + tabPanelId + " #left").click(function(){
			stopScroll(tabPanelId);
			scrollLeft(tabPanelId);
		  });
		jQuery("#" + tabPanelId + " #right").click(function(){
			stopScroll(tabPanelId);
			scrollRight(tabPanelId);			    
		  });				  
	}
	
	var Tabs = function(tabNameInputId, currentTab){
		this.tabNameInputId = tabNameInputId;
		this.currentTab = currentTab;
		this.tabs = {};
		this.tabs[this.currentTab] = true;
	};
	
	Tabs.prototype = {
		loaded: function(tabName){
			if (this.tabs[tabName] == true) {
				return true;
			}	
			return false;	
		},
		set: function(tabName){
			this.currentTab = tabName;
			this.updateInput();
			this.tabs[this.currentTab] = true;
			return true;
		},
		setAndCheck: function(tabName){
			var result = this.loaded(tabName); 
			this.set(tabName);
			return result;
		},
		flush: function(){
			this.tabs = {};
			this.tabs[this.currentTab] = true;
			this.updateInput();
		},
		unmark: function(tabName){
			this.tabs[tabName] = false;
		},
		updateInput: function(){
			if (document.getElementById(this.tabNameInputId)){
				document.getElementById(this.tabNameInputId).value = this.currentTab;
			} else {
				if (!isIE){
					console.warn('Hidden input \'' + this.tabNameInputId + '\' has not been found. Tabs functionality may work incorrectly!');
				}
			}
		}
	};