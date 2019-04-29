/* Overrides some richfaces code */

/**
 * These 2 methods make possible to resize columns in richfaces table
 * to whatever size you want omitting the limitation of max width.
 */
ExtendedDataTable.DataTable.header.prototype.OnSepMouseMove = function(event) {
	if(this.dragColumnInfo && this.dragColumnInfo.mouseDown) {
		if(!this.dragColumnInfo.dragStarted) {
			this.dragColumnInfo.dragStarted = true;
			this._showSplitter(this.dragColumnInfo.srcElement.columnIndex);
		}
		var delta = Event.pointerX(event) -
			this.dragColumnInfo.startX
		if (delta < this.minDelta) {
			delta = this.minDelta;
		}

		if (delta > this.maxDelta && jQuery(event.target).closest('.search_result_block_inner .rich-extdt-maindiv').size() == 0) {
			delta = this.maxDelta;
		}

		var x = this.dragColumnInfo.originalX + delta;
		var finalX = x - this.minColumnWidth - 6 //6 stands for sep span width;
		this.columnSplitter.moveToX(finalX);
		Event.stop(event);
	}
}

ExtendedDataTable.DataTable.header.prototype.OnSepMouseUp = function(event) {
	Event.stop(event);
	Event.stopObserving(document, 'mousemove', this.eventSepMouseMove);
	Event.stopObserving(document, 'mouseup', this.eventSepMouseUp);
	if(this.dragColumnInfo && this.dragColumnInfo.dragStarted) {
		this.dragColumnInfo.dragStarted = false;
		this.dragColumnInfo.mouseDown = false;

		var delta = Event.pointerX(event) -
			this.dragColumnInfo.startX;
		if (delta < this.minDelta) {
			delta = this.minDelta;
		}

		if (delta > this.maxDelta && jQuery(event.target).closest('.search_result_block_inner .rich-extdt-maindiv').size() == 0) {
			delta = this.maxDelta;
		}

		var columnIndex = this.dragColumnInfo.srcElement.columnIndex;
		var newWidth = this.getColumnWidth(columnIndex) + delta;

		this.extDt.setColumnWidth(columnIndex, newWidth);
		this.setColumnWidth(columnIndex,newWidth);
		this.extDt.updateLayout();
		if (this.extDt.onColumnResize){
			//set properly value to this.columnWidths
			this.extDt.columnWidths = "";
			for (i=0; i<this.columnsNumber; i++){
				this.extDt.columnWidths += "" + this.getColumnWidth(i) + ";";
			}//for
			this.extDt.onColumnResize(event, this.extDt.columnWidths);
		}
	}
	this._hideSplitter();
};

/*************************************************************************************************************
 *
 *              COMBOBOXLIST
 *
 *************************************************************************************************************/

Richfaces.ComboBoxList.prototype.createItem = function(text, className) {
    var escapedText = text.label.escapeHTML();
    return "<span class=\"" + className+ "\" value=\"" + text.value + "\">" + escapedText + "</span>";
};

Richfaces.ComboBoxList.prototype.getItemByValue = function(text, exact) {
    var txt = text.toLowerCase();
    for (var i = 0; i < this.itemsText.length; i++) {
        var item = this.itemsText[i];
        if (!exact) {
            if (item.value.toLowerCase().indexOf(txt) > -1)
                return item;
        } else if(exact == 1) {
            if (item.value.substr(0, txt.length).toLowerCase() == txt)
                return item;
        } else if(exact == 2) {
            if (item.value.toLowerCase() == txt)
                return item;
        }
    }
    return null;
};

Richfaces.ComboBoxList.prototype.getItemByLabel = function(text, exact) {
    var txt = text.toLowerCase();
    for (var i = 0; i < this.itemsText.length; i++) {
        var item = this.itemsText[i];
        if (!exact) {
            if (item.label.toLowerCase().indexOf(txt) > -1 || item.value.toLowerCase().indexOf(txt) > -1)
                return item;
        } else {
            if (item.label.toLowerCase().indexOf(txt) > -1)
                return item;
        }

    }
    return null;
};

Richfaces.ComboBoxList.prototype.getFilteredItems = function(text) {
    var items = new Array();
    var txt = text.toLowerCase();
    for (var i = 0; i < this.itemsText.length; i++) {
        var item = this.itemsText[i];
        if (item.label.toLowerCase().indexOf(txt) > -1 || item.value.toLowerCase().indexOf(txt) > -1) {
            items.push(this.createItem(item, this.classes.item.normal));
        }
    }
    return items;
};

Richfaces.ComboBoxList.prototype.findItemByDOMNode = function(node) {
    var substr = node.getAttribute('value');
    return this.findItemBySubstr(substr);
};

Richfaces.ComboBoxList.prototype.findItemBySubstr = function(substr) {
    var items = this.getItems();
    for (var i = 0; i < items.length; i++) {
        var item = items[i]
        var itText = item.getAttribute('value');
        if (itText.substr(0, substr.length).toLowerCase() == substr.toLowerCase()) {
            return item;
        }
    }
};

/*************************************************************************************************************
 *
 *              COMBOBOX
 *
 *************************************************************************************************************/

Richfaces.ComboBox.prototype.initialize = function(id, options) {
    options = options || {};
    Object.extend(this, options.fields);
    this.combobox = $(id);
    this.comboValue = document.getElementById(id + "comboboxValue");
    this.field = document.getElementById(id + "comboboxField");

    this.tempItem;

    this.BUTTON_WIDTH = 17; //px
    this.BUTTON_LEFT_BORDER = 1; //px
    this.BUTTON_RIGHT_BORDER = 1; //px

    this.classes = Richfaces.mergeStyles(options.userStyles,new Richfaces.ComboBoxStyles().getCommonStyles());

    this.button = document.getElementById(id + "comboboxButton");
    this.buttonBG = document.getElementById(id + "comboBoxButtonBG");

    this.setInputWidth();

    var width = document.getElementById(id + "combobox").style.width;
    if (width != '150px') {
        this.combobox.style.width = document.getElementById(id + "combobox").style.width;
    }
    this.combobox.className = 'bpc-rich-combobox';

    var listOptions = options.listOptions || {};
    listOptions.listWidth = listOptions.listWidth || this.getCurrentWidth();
    this.comboList = new Richfaces.ComboBoxList(id, this.filterNewValues, this.classes.combolist, listOptions, "comboboxField");
    if (Richfaces.browser.isIE6) {
        this.comboList.createIframe(this.comboList.listParent.parentNode, this.comboList.listWidth, id,
            "rich-combobox-list-width rich-combobox-list-scroll rich-combobox-list-position");
    }

    var initValue = options.value;
    if (app.isNull(initValue)) {
        if (listOptions.itemsText && listOptions.itemsText.length > 0 && listOptions.itemsText[0].value != '') {
            initValue = listOptions.itemsText[0].value;
        }
    }
    if (!app.isNull(initValue)) {

        this.field.value = '';
        var item = this.comboList.getItemByValue(initValue, 2);
        if (item) {
            this.field.value = item.label;
            this.field.prevLabel = item.label;
            this.field.prevValue = item.value;
            this.comboValue.value = item.value;
        } else {
            item = this.comboList.findItemBySubstr(initValue);
            if (item) {
                this.comboList.doSelectItem(item);
                this.comboValue.value = initValue;
            }
        }
    } else {
        if (this.defaultLabel) {
            this.applyDefaultText();
            this.field.prevLabel = this.defaultLabel;
        }
    }
    this.isSelection = true;
    if (this.onselected) {
        this.combobox.observe("rich:onselect", this.onselected);
    }
    if (this.disabled) {
        this.disable(); //TODO rename to 'disable'
    }

    this.combobox.component = this;
    this.initHandlers();
    this["rich:destructor"] = "destroy";
};


Richfaces.ComboBox.prototype.dataUpdating = function(event) {
    if (Richfaces.ComboBox.SPECIAL_KEYS.indexOf(event.keyCode) == -1) {
        if (this.filterNewValues) {
            this.comboList.hideWithDelay();
            this.comboList.dataFilter(this.field.value);
            if (this.comboList.getItems() && this.comboList.getItems().length != 0) {
                var isSearchSuccessful = true;
                this.comboList.showWithDelay();
            }
        } else {
            if (!this.comboList.visible()) {
                this.comboList.createDefaultList();
                this.comboList.showWithDelay();
            }

            var item = this.comboList.findItemBySubstr(this.field.value);
            if (item) {
                this.comboList.doActiveItem(item);
                this.comboList.scrollingUpToItem(this.comboList.activeItem);
                isSearchSuccessful = true;
            }
        }

        if (this.isValueSet(event) && isSearchSuccessful) {
            var value = this.getActiveItemLabel();
            if(value && this.directInputSuggestions) {
                this.doDirectSuggestion(value);
            }
        }
        var val = this.getActiveItemValue();
        this.comboValue.value = app.isNull(val) ? '' : val;
    }
};

Richfaces.ComboBox.prototype.getActiveItemLabel = function(){
    var value = null;
    if (this.comboList.activeItem) {
        value = jQuery(this.comboList.activeItem).text();
        value = value.replace(/\xA0/g," ").strip();
    }
    return value;
};

Richfaces.ComboBox.prototype.getActiveItemValue = function(){
    var value = null;
    if (this.comboList.activeItem) {
        value = jQuery(this.comboList.activeItem).attr('value');
        value = value.replace(/\xA0/g," ").strip();
    }
    return value;
};



Richfaces.ComboBox.prototype.fieldKeyDownHandler = function(event) {
    switch (event.keyCode) {
        case Event.KEY_RETURN :
            this.setValue(true);
            this.comboList.hideWithDelay();
            Event.stop(event); // It is necessary for a cancelling of sending form at selecting item
            break;
        case Event.KEY_DOWN :
            this.comboList.moveActiveItem(event);
            break;
        case Event.KEY_UP :
            this.comboList.moveActiveItem(event);
            break;
        case Event.KEY_ESC :
            this.field.value = app.isNull(this.field.prevLabel) ? '' : this.field.prevLabel; //field must lose focus
            this.comboValue.value = app.isNull(this.field.prevValue) ? '' : this.field.prevValue;
            this.comboList.hideWithDelay();
            break;
    }
};


Richfaces.ComboBox.prototype.setValue = function(toSetOnly) {
    var label = this.field.value;
    var value = this.comboValue.value;

    var item = null;
    if (!toSetOnly) {
        item = this.comboList.getItemByValue(value, 2);
    }

    if (item) {
        value = item.value;
        label = item.label;
    } else if(this.comboList.activeItem) {
        value = this.getActiveItemValue();
        label = this.getActiveItemLabel();
    } else {
        item = this.comboList.getItemByLabel(label);

        if (item) {
            value = item.value;
            label = item.label;
        } else {
            value = null;
        }
    }

    var oldValue = app.isNull(this.field.prevValue) ? '' : this.field.prevValue;
    if(value != null && value != oldValue) {
        this.comboValue.value = value;
        this.comboList.doSelectItem(this.comboList.activeItem);
        this.combobox.fire("rich:onselect", {});

        this.field.prevValue = value;
        this.field.prevLabel = label;
        this.field.value = app.isNull(label) ? '' : label;
        Richfaces.invokeEvent(this.onchange, this.combobox, "onchange", {value:value});
    } else if (label != null && (label != this.field.value)) {
        // https://jira.jboss.org/jira/browse/RF-8200
        this.field.value = label;
    } else {
        if (this.field.prevValue == undefined || this.field.prevValue == null) {
            this.applyDefaultText();
        } else {
            this.field.value = app.isNull(this.field.prevLabel) ? '' : this.field.prevLabel;
            this.comboValue.value = app.isNull(oldValue) ? '' : oldValue;
        }
    }
};
