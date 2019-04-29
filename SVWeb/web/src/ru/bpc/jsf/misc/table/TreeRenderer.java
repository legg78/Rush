package ru.bpc.jsf.misc.table;

import org.ajax4jsf.renderkit.ComponentVariables;

import javax.faces.context.FacesContext;
import javax.faces.context.ResponseWriter;
import java.io.IOException;

public class TreeRenderer extends org.richfaces.renderkit.html.TreeRenderer {
	public void doEncodeEnd(ResponseWriter writer, FacesContext context, org.richfaces.component.UITree component, ComponentVariables variables) throws IOException {

		encodeSelectionStateInput(context, component);

		java.lang.String clientId = component.getClientId(context);
		writer.startElement("script", component);
		getUtils().writeAttribute(writer, "type", "text/javascript");

		writer.writeText("// <!--\n", null);

		writer.writeText(convertToString("(function() {\n			var tree = new Tree(\"" + convertToString(clientId) + "\", \"" + convertToString(clientId) + ":input\", \"" + convertToString(component.getSwitchType()) + "\",\n				{\n					onselect: \"" + convertToString(component.getAttributes().get("onselected")) + "\", \n					onexpand: \"" + convertToString(component.getAttributes().get("onexpand")) + "\", \n					oncollapse: \"" + convertToString(component.getAttributes().get("oncollapse")) + "\",\n					oncontextmenu: \"" + convertToString(component.getAttributes().get("oncontextmenu")) + "\" \n				},\n				function(event) {\n					" + convertToString(getAjaxScript(context, component)) + "\n				},\n				" + convertToString(getOptions(context, component)) + "\n			);\n			" + convertToString(getScriptContributions("tree", context, component)) + "\n		}());"), null);

		writer.writeText("\n// -->\n", null);

		writer.endElement("script");
		writeScriptElement(context, component, "");

		writer.endElement("div");

	}

	private String convertToString(Object obj ) {
		return ( obj == null ? "" : obj.toString() );
	}
}
