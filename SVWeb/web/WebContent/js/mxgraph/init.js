		// Program starts here. The document.onLoad executes the
		// mxApplication constructor with a given configuration.
		// In the config file, the mxEditor.onInit method is
		// overridden to invoke this global function as the
		// last step in the editor constructor.
		function onInit(editor, isFirstTime)
		{
			// Defines an icon for creating new connections in the connection handler.
			// This will automatically disable the highlighting of the source vertex.
			mxConnectionHandler.prototype.connectImage = new mxImage('images/connector.gif', 16, 16);
			
			// Enables connections in the graph and disables
			// reset of zoom and translate on root change
			// (ie. switch between XML and graphical mode).
			editor.graph.setConnectable(true);

			// Clones the source if new connection has no target
			editor.graph.connectionHandler.setCreateTarget(true);
			
			// Displays information about the session
			// in the status bar
			editor.addListener(mxEvent.SESSION, function(editor, evt)
			{
				var session = evt.getProperty('session');
				
				if (session.connected)
				{
					var tstamp = new Date().toLocaleString();
					editor.setStatus(tstamp+':'+
						' '+session.sent+' bytes sent, '+
						' '+session.received+' bytes received');
				}
				else
				{
					editor.setStatus('Not connected');
				}
			});
			
			// Updates the title if the root changes
			var title = document.getElementById('title');
			
			if (title != null)
			{
				var f = function(sender)
				{
					title.innerHTML = sender.getTitle();
				};
				
				editor.addListener(mxEvent.ROOT, f);
				f(editor);
			}
			
		    // Changes the zoom on mouseWheel events
		    mxEvent.addMouseWheelListener(function (evt, up)
		    {
			    if (!mxEvent.isConsumed(evt))
			    {
			    	if (up)
					{
			    		editor.execute('zoomIn');
					}
					else
					{
						editor.execute('zoomOut');
					}
					
					mxEvent.consume(evt);
			    }
		    });

			// Defines a new action to switch between
			// XML and graphical display
			var textNode = document.getElementById('xml');
			var graphNode = editor.graph.container;
			var sourceInput = document.getElementById('source');
			sourceInput.checked = false;

			var funct = function(editor)
			{
				if (sourceInput.checked)
				{
					graphNode.style.display = 'none';
					textNode.style.display = 'inline';
					
					var enc = new mxCodec();
					var node = enc.encode(editor.graph.getModel());
					
					textNode.value = mxUtils.getPrettyXml(node);
					textNode.originalValue = textNode.value;
					textNode.focus();
				}
				else
				{
					graphNode.style.display = '';
					
					if (textNode.value != textNode.originalValue)
					{
						var doc = mxUtils.parseXml(textNode.value);
						var dec = new mxCodec(doc);
						dec.decode(doc.documentElement, editor.graph.getModel());
					}

					textNode.originalValue = null;
					
					// Makes sure nothing is selected in IE
					if (mxClient.IS_IE)
					{
						document.selection.empty();
					}

					textNode.style.display = 'none';

					// Moves the focus back to the graph
					textNode.blur();
					editor.graph.container.focus();
				}
			};
			
			editor.addAction('switchView', funct);
			
			// Defines a new action to switch between
			// XML and graphical display
			mxEvent.addListener(sourceInput, 'click', function()
			{
				editor.execute('switchView');
			});

			// Create select actions in page
			var node = document.getElementById('mainActions');
			var buttons = ['group', 'delete', 'undo', 'print'];
			
			for (var i = 0; i < buttons.length; i++)
			{
				var button = document.createElement('button');
				mxUtils.write(button, mxResources.get(buttons[i]));
			
				var factory = function(name)
				{
					return function()
					{
						editor.execute(name);
					};
				};
			
				mxEvent.addListener(button, 'click', factory(buttons[i]));
				node.appendChild(button);
			}

			var select = document.createElement('select');
			var option = document.createElement('option');
			mxUtils.writeln(option, 'More Actions...');
			select.appendChild(option);

			var items = ['redo', 'ungroup', 'cut', 'copy', 'paste', 'show', 'exportImage'];

			for (var i=0; i<items.length; i++)
			{
				var option = document.createElement('option');
				mxUtils.writeln(option, mxResources.get(items[i]));
				option.setAttribute('value', items[i]);
				select.appendChild(option);
			}
			
			mxEvent.addListener(select, 'change', function(evt)
			{
				if (select.selectedIndex > 0)
				{
					var option = select.options[select.selectedIndex];
					select.selectedIndex = 0;
				
					if (option.value != null)
					{
						editor.execute(option.value);
					}
				}
			});
			
			node.appendChild(select);

			// Create select actions in page
			var node = document.getElementById('selectActions');
			mxUtils.write(node, 'Select: ');
			mxUtils.linkAction(node, 'All', editor, 'selectAll');
			mxUtils.write(node, ', ');
			mxUtils.linkAction(node, 'None', editor, 'selectNone');
			mxUtils.write(node, ', ');
			mxUtils.linkAction(node, 'Vertices', editor, 'selectVertices');
			mxUtils.write(node, ', ');
			mxUtils.linkAction(node, 'Edges', editor, 'selectEdges');

			// Create select actions in page
			var node = document.getElementById('zoomActions');
			mxUtils.write(node, 'Zoom: ');
			mxUtils.linkAction(node, 'In', editor, 'zoomIn');
			mxUtils.write(node, ', ');
			mxUtils.linkAction(node, 'Out', editor, 'zoomOut');
			mxUtils.write(node, ', ');
			mxUtils.linkAction(node, 'Actual', editor, 'actualSize');
			mxUtils.write(node, ', ');
			mxUtils.linkAction(node, 'Fit', editor, 'fit');
		};