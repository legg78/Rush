package ru.bpc.sv2.ui.reports.constructor.converter;

import java.util.List;

import javax.faces.component.UIComponent;
import javax.faces.component.UISelectItems;
import javax.faces.convert.FacesConverter;

@FacesConverter("dynamicReportInnerListConverter")
public final class InnerListConverter extends ListConverter {
	@Override
	protected List<?> getList(UIComponent component) {
		List<?> result = null;
		for (UIComponent child : component.getChildren()) {
			if(child instanceof UISelectItems) {
				result = super.getList(child);
				break;
			}
		}
		return result;
	}
}