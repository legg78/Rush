/* Script file with patches to external code. Is called at bottom of pages that extend base page */

if (typeof mojarra == 'undefined') {
	/* For some unclear reason, IE sometimes fails to load JSF RI script (jsf.js.jsf)
	 even when corresponding <script> tag exists in the markup
	 Which, in turn, prevents components (menu links for example) from working properly.
	 To fix that, we figure out when script is not loaded and reload it, using src from original <script> tag */
	jQuery('script[src*="jsf.js.jsf"]:eq(0)').each(function () {
		jQuery.getScript(jQuery(this).attr('src'));
	});
}


/** Patch to Richfaces Calendar **/
if (typeof Richfaces != 'undefined' && typeof Richfaces.Calendar != 'undefined') {
	// Redefine default direction option to auto. If calendar popup does not fit in viewport, it will be repositioned.
	// If it fits, it will be placed according to "bottom-right" direction (which was the original default)
	Richfaces.Calendar.defaultOptions.direction = "auto";
	// Redefine default z-index so that calendar in modal window would not be behind that modal window which has z-index=100
	Richfaces.Calendar.defaultOptions.style = "z-index: 1000;";

	// Redefine setElementPosition to deal with hiding parts of calendar due to ancestors' overflow:hidden style
	Richfaces.Calendar.setElementPosition = function (element, baseElement, jointPoint, direction, offset) {
		// parameters:
		// baseElement: Dom element or {left:, top:, width:, height:};
		// jointPoint: {x:,y:} or ('top-left','top-right','bottom'-left,'bottom-right')
		// direction:  ('top-left','top-right','bottom'-left,'bottom-right', 'auto')
		// offset: {dx:,dy:}

		if (!offset) offset = {dx: 0, dy: 0};

		var elementDim = Richfaces.Calendar.getOffsetDimensions(element);
		var baseElementDim;
		var baseOffset;

		if (baseElement.left != undefined) {
			baseElementDim = {width: baseElement.width, height: baseElement.height};
			baseOffset = [baseElement.left, baseElement.top];
		} else {
			baseElementDim = Richfaces.Calendar.getOffsetDimensions(baseElement);
			baseOffset = Position.cumulativeOffset(baseElement);
		}

		var windowRect = Richfaces.Calendar.getWindowViewport();

		// jointPoint
		var ox = baseOffset[0];
		var oy = baseOffset[1];
		var re = /^(top|bottom)-(left|right)$/;
		var match;

		if (typeof jointPoint == 'object') {
			ox = jointPoint.x;
			oy = jointPoint.y
		} else if (jointPoint && (match = jointPoint.toLowerCase().match(re)) != null) {
			if (match[2] == 'right') ox += baseElementDim.width;
			if (match[1] == 'bottom') oy += baseElementDim.height;
		} else {
			// ??? auto
		}

		// direction
		if (direction && (match = direction.toLowerCase().match(re)) != null) {
			if (match[2] == 'left') ox -= elementDim.width + offset.dx; else if (match[2] == 'right') ox += offset.dx;
			if (match[1] == 'top') oy -= elementDim.height + offset.dy; else if (match[1] == 'bottom') oy += offset.dy;
		} else {
			// auto
			var theBest = {square: 0};
			// jointPoint: bottom-right, direction: bottom-left
			var basex = baseOffset[0] - offset.dx;
			var basey = baseOffset[1] + offset.dy;

			/** patched **/
			var rect = {left: basex + baseElementDim.width, top: basey + baseElementDim.height};
			rect.right = rect.left + elementDim.width;
			/** **/

			rect.bottom = rect.top + elementDim.height;
			ox = rect.left;
			oy = rect.top;
			var s = Richfaces.Calendar.checkCollision(rect, windowRect);
			if (s != 0) {
				if (ox >= 0 && oy >= 0 && theBest.square < s) theBest = {x: ox, y: oy, square: s};
				// jointPoint: top-right, direction: top-left
				basex = baseOffset[0] - offset.dx;
				basey = baseOffset[1] - offset.dy;
				rect = {right: basex + baseElementDim.width, bottom: basey};
				rect.left = rect.right - elementDim.width;
				rect.top = rect.bottom - elementDim.height;
				ox = rect.left;
				oy = rect.top;
				s = Richfaces.Calendar.checkCollision(rect, windowRect);
				if (s != 0) {
					if (ox >= 0 && oy >= 0 && theBest.square < s) theBest = {x: ox, y: oy, square: s};
					// jointPoint: bottom-left, direction: bottom-right
					basex = baseOffset[0] + offset.dx;
					basey = baseOffset[1] + offset.dy;
					rect = {left: basex, top: basey + baseElementDim.height};
					rect.right = rect.left + elementDim.width;
					rect.bottom = rect.top + elementDim.height;
					ox = rect.left;
					oy = rect.top;
					s = Richfaces.Calendar.checkCollision(rect, windowRect);
					if (s != 0) {
						if (ox >= 0 && oy >= 0 && theBest.square < s) theBest = {x: ox, y: oy, square: s};
						// jointPoint: top-left, direction: top-right
						basex = baseOffset[0] + offset.dx;
						basey = baseOffset[1] - offset.dy;
						rect = {left: basex, bottom: basey};
						rect.right = rect.left + elementDim.width;
						rect.top = rect.bottom - elementDim.height;
						ox = rect.left;
						oy = rect.top;
						s = Richfaces.Calendar.checkCollision(rect, windowRect);
						if (s != 0) {
							// the best way selection
							if (ox < 0 || oy < 0 || theBest.square > s) {
								ox = theBest.x;
								oy = theBest.y
							}
						}
					}
				}

			}
		}

		var els = element.style;
		var originalVisibility = els.visibility;
		var originalPosition = els.position;
		var originalDisplay = els.display;
		els.visibility = 'hidden';
		els.position = 'absolute';
		els.display = '';

		var parentOffset;
		if (!window.opera) {
			parentOffset = element.getOffsetParent().viewportOffset();
			ox -= parentOffset[0];
			oy -= parentOffset[1];
		} else if (element.offsetParent) {
			// for Opera only
			if (element.offsetParent != document.body) {
				parentOffset = Position.cumulativeOffset(element.offsetParent);
				ox -= parentOffset[0];
				oy -= parentOffset[1];
				ox += element.offsetParent.scrollLeft;
				oy += element.offsetParent.scrollTop;
			} else {
				parentOffset = Richfaces.Calendar.cumulativeScrollOffset(element);
				ox += parentOffset[0];
				oy += parentOffset[1];
			}
		}

		els.display = originalDisplay;
		els.position = originalPosition;
		els.visibility = originalVisibility;
		element.style.left = ox + 'px';
		element.style.top = oy + 'px';

		/** patched **/
		window.setTimeout(function () {
			// Take element from its parent and append directly to body
			// in order to avoid dealing with absolute positioning and overflow:hidden styles of ancestor elements
			// placed under body element, calendar will always be visible no matter of container the original field placed in
			var $element = jQuery(element);
			if (!element._originalParent)
				element._originalParent = $element.parent();
			// recalculate element's position relative to document, not offset parent
			var offset = $element.offset();
			jQuery("body").append($element);
			$element.css({left: offset.left + "px", top: offset.top + "px"});

			function trackCalendarHide() {
				// tracking when element becomes invisible to return it back to original parent
				if ($element.is(":visible"))
					setTimeout(trackCalendarHide, 500);
				else if (element._originalParent) {
					jQuery(element._originalParent).append($element);
					element._originalParent = null;
				}
			}

			trackCalendarHide();
		}, 1);
		/**  **/
	};
}
/** End of patch to Richfaces Calendar **/

if (jQuery.browser.msie && typeof ExtendedDataTable != 'undefined' && typeof ExtendedDataTable.DataTable != 'undefined') {
	// Prevent default update layout to execute when container div has zero width. This might happen in IE when
	// container div is not visible.
	var defaultUpdateLayout = ExtendedDataTable.DataTable.prototype.updateLayout;
	ExtendedDataTable.DataTable.prototype.updateLayout = function() {
		if (this.mainDiv.getWidth() > 0)
			defaultUpdateLayout.apply(this);
	};

	// For the same reason as above, revert saveRatios to backup if, after ratios have been calculated, the are infinite
	var defaultSaveRatiosImpl = ExtendedDataTable.DataTable.prototype.saveRatios;
	ExtendedDataTable.DataTable.prototype.saveRatios = function() {
		var ratiosBackup = this.ratios;
		defaultSaveRatiosImpl.apply(this);
		if (this.ratios.length > 0 && !isFinite(this.ratios[0]))
			this.ratios = ratiosBackup;
	};
}