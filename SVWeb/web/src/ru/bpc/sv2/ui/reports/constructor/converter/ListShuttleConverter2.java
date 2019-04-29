package ru.bpc.sv2.ui.reports.constructor.converter;

import java.util.List;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.FacesConverter;

import org.richfaces.component.UIListShuttle;
import org.richfaces.model.ListShuttleRowKey;

import ru.bpc.sv2.ui.reports.constructor.support.ListShuttleSupport;

@FacesConverter("dynamicReportListShuttleConverter2")
public final class ListShuttleConverter2 extends ListShuttleConverter {
	@Override
	protected List<?> getList(UIComponent component) {
		List<?> result;
		ListShuttleSupport<?, ?> support = getSupport(component);
		if (support.isSource()) {
			result = support.getSourceValue();
		} else {
			result = support.getTargetValue();
		}
		return result;
	}

	@Override
	public Object getAsObject(FacesContext context, UIComponent component,
			String value) {
		ListShuttleSupport<?, ?> support = getSupport(component);
		support.setSource(value.startsWith("s"));
		Object result = super.getAsObject(context, component,
				value.substring(1));
		return result;
	}

	@Override
	public String getAsString(FacesContext context, UIComponent component,
			Object value) {
		ListShuttleSupport<?, ?> support = getSupport(component);
		ListShuttleRowKey rowKey = (ListShuttleRowKey) ((UIListShuttle) component)
				.getRowKey();
		support.setSource(rowKey.isSource());
		String result = (support.isSource() ? "s" : "t")
				+ super.getAsString(context, component, value);
		return result;
	}
}