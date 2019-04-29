function customExpand(e, input, button) {

	if (!this.isRendered) {
		this.isRendered = true;
		this.render();
	}


	if (this.isVisible) {
		this.doCollapse();
		if (input == this.customInput)
			return true;
	}

	this.skipEventOnCollapse = e && e.type == 'click';
	if (!this.params.popup || this.isVisible) return;

	var element = $(this.id);

	if (this.invokeEvent("expand", element, e)) {

		var iframe = null;
		if (Richfaces.browser.isIE6) iframe = $(this.IFRAME_ID);

		var base = $(this.POPUP_ID);
		var baseInput = input;

		//custom input
		this.customInput = baseInput;

		var baseButton = button;

		if (baseInput && baseInput.value != undefined) {
			this.selectDate(baseInput.value, false, {event: e, element: element});
		}

		//rect calculation

		var offsetBase = Position.cumulativeOffset(baseButton);

		if (this.params.showInput) {
			var offsetBase1 = Position.cumulativeOffset(baseInput);

			offsetBase = [offsetBase[0] < offsetBase1[0] ? offsetBase[0] : offsetBase1[0],
				offsetBase[1] < offsetBase1[1] ? offsetBase[1] : offsetBase1[1]];
			var offsetDimInput = Richfaces.Calendar.getOffsetDimensions(baseInput);
		}

		var offsetDimBase = Richfaces.Calendar.getOffsetDimensions(base);
		var offsetDimButton = Richfaces.Calendar.getOffsetDimensions(baseButton);
		var offsetTemp = (window.opera ? [0, 0] : Position.realOffset(baseButton));
		var o = {
			left: offsetBase[0] - offsetTemp[0],
			top: offsetBase[1] - offsetTemp[1],
			width: offsetDimBase.width,
			height: (offsetDimInput && offsetDimInput.height > offsetDimButton.height ? offsetDimInput.height :
				offsetDimButton.height)
		};

		Richfaces.Calendar.setElementPosition(element, o, this.params.jointPoint,
			this.params.direction, this.popupOffset);

		if (iframe) {
			iframe.style.left = element.style.left;
			iframe.style.top = element.style.top;
			var edim = Richfaces.Calendar.getOffsetDimensions(element);
			iframe.style.width = edim.width + 'px';
			iframe.style.height = edim.height + 'px';
			Element.show(iframe);
		}
		Element.show(element);

		this.isVisible = true;

		Event.observe(window.document, "click", this.eventOnCollapse, false);
	}
}