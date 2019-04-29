package ru.bpc.jsf.menu;

import java.io.IOException;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.context.ResponseWriter;
import javax.faces.convert.Converter;
import javax.faces.model.SelectItem;

import com.sun.faces.renderkit.html_basic.MenuRenderer;


/**
 * Extended menu renderer which renders the 'optionClasses' attribute above the standard menu
 * renderer. To use it, define it as follows in the render-kit tag of faces-config.xml.
 * 
 * <pre>
 * &lt;renderer&gt;
 *     &lt;component-family&gt;javax.faces.SelectOne&lt;/component-family&gt;
 *     &lt;renderer-type&gt;javax.faces.Menu&lt;/renderer-type&gt;
 *     &lt;renderer-class&gt;net.balusc.jsf.renderer.html.ExtendedMenuRenderer&lt;/renderer-class&gt;
 * &lt;/renderer&gt;
 * &lt;renderer&gt;
 *     &lt;component-family&gt;javax.faces.SelectMany&lt;/component-family&gt;
 *     &lt;renderer-type&gt;javax.faces.Menu&lt;/renderer-type&gt;
 *     &lt;renderer-class&gt;net.balusc.jsf.renderer.html.ExtendedMenuRenderer&lt;/renderer-class&gt;
 * &lt;/renderer&gt;
 * </pre>
 * 
 * And define the 'optionClasses' attribute as a f:attribute of the h:selectOneMenu or 
 * h:selectManyMenu as follows:
 * 
 * <pre>
 * &lt;f:attribute name="optionClasses" value="option1,option2,option3" /&gt;
 * </pre>
 * 
 * It accepts a comma separated string of CSS class names which are to be applied on the options
 * repeatedly (the same way as you use rowClasses in h:dataTable). The optionClasses will be
 * rendered only if there is no 'disabledClass' or 'enabledClass' being set as an attribute.
 * 
 */
public class ExtendedMenuRenderer extends MenuRenderer {

    // Override -----------------------------------------------------------------------------------
    protected boolean renderOption(FacesContext context, UIComponent component, Converter converter,
        SelectItem currentItem, Object currentSelections, Object[] submittedValues, OptionComponentInfo options)
            throws IOException
    {
    	 // Copied from MenuRenderer#renderOption() (and a bit rewritten, but that's just me) ------
        // Get writer.
        ResponseWriter writer = context.getResponseWriter();
        assert (writer != null);

        // Write 'option' tag.
        writer.writeText("\t", component, null);
        writer.startElement("option", component);

        // Write 'value' attribute.
        String valueString = getFormattedValue(context, component, currentItem.getValue(), converter);
        writer.writeAttribute("value", valueString, "value");

        // Write 'selected' attribute.
        Object valuesArray;
        Object itemValue;
        if (containsaValue(submittedValues)) {
            valuesArray = submittedValues;
            itemValue = valueString;
        } else {
            valuesArray = currentSelections;
            itemValue = currentItem.getValue();
        }
        if (isSelected(context, component, itemValue, valuesArray, converter)) {
            writer.writeAttribute("selected", true, "selected");
        }

        // Write 'disabled' attribute.
        Boolean disabledAttr = (Boolean) component.getAttributes().get("disabled");
        boolean componentDisabled = disabledAttr != null && disabledAttr.booleanValue();
        if (!componentDisabled && currentItem.isDisabled()) {
            writer.writeAttribute("disabled", true, "disabled");
        }

        // Write 'data-image' attribute.
        String dataImage = (String) component.getAttributes().get("data-image");
        if (dataImage != null && !dataImage.isEmpty()) {
            writer.writeAttribute("data-image", dataImage, "");
        }
        
        // Write 'data-imagecss' attribute.
        String dataImageCss = "";
        String[] dataImageCsses = (String[]) component.getAttributes().get("data-imagecss");
        if (dataImageCsses != null) {
            String indexKey = component.getClientId(context) + "_currentOptionIndex";
            Integer index = (Integer) component.getAttributes().get(indexKey);
            if (index == null) {
                index = 0;
            }
            
            dataImageCss = dataImageCsses[index];
            index++;
            component.getAttributes().put(indexKey, index);
            
            if(index == dataImageCsses.length) {
            	 component.getAttributes().remove(indexKey);
            }
        }

        // The remaining copy of MenuRenderer#renderOption() --------------------------------------

        if (dataImageCss != null && !dataImageCss.isEmpty()) {
            writer.writeAttribute("data-imagecss", dataImageCss, "");
        }

        // Write option body (the option label).
        if (currentItem.isEscape()) {
            String label = currentItem.getLabel();
            if (label == null) {
                label = valueString;
            }
            writer.writeText(label, component, "label");
        } else {
            writer.write(currentItem.getLabel());
        }

        // Write 'option' end tag.
        writer.endElement("option");
        writer.writeText("\n", component, null);
        return true;
    }

}