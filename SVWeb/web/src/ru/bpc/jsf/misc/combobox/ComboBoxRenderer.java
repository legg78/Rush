package ru.bpc.jsf.misc.combobox;

import com.sun.faces.renderkit.RenderKitUtils;
import org.apache.commons.lang3.StringUtils;
import org.richfaces.component.UIComboBox;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import java.io.IOException;
import java.util.*;

public class ComboBoxRenderer extends org.richfaces.renderkit.html.ComboBoxRenderer {
	public List<Object> getItems(FacesContext context, UIComponent component) throws IOException, IllegalArgumentException {
		List<Object> values = new ArrayList();
		if (this.isAcceptableComponent(component)) {
			UIComboBox comboBox = (UIComboBox)component;

			for (Object value: this.encodeSuggestionValues(context, comboBox)) {
				Map<String, String> map = new HashMap<String, String>();
				map.put("value", (String) value);
				map.put("label", (String) value);
				values.add(map);
			}

			Iterator<SelectItem> selectItems = RenderKitUtils.getSelectItems(context, component);

			while (selectItems.hasNext()) {
				SelectItem selectItem = selectItems.next();

				String convertedValue = this.getConvertedStringValue(context, component, selectItem.getValue());
				String convertedLabel = this.getConvertedStringValue(context, component, selectItem.getLabel());

				if (StringUtils.isEmpty(convertedLabel)) {
					convertedLabel = convertedValue;
				}

				if ("".equals(convertedLabel)) {
					convertedLabel = " ";
				}

				Map<String, String> map = new HashMap<String, String>();
				map.put("value", convertedValue);
				map.put("label", convertedLabel);
				values.add(map);
			}
		}

		return values;
	}
}
