package ru.bpc.sv2.ui.reports.constructor.converter;

import java.util.List;

import javax.faces.component.UIComponent;
import javax.faces.convert.FacesConverter;

import ru.bpc.sv2.ui.reports.constructor.support.ListShuttleSupport;

@FacesConverter("dynamicReportListShuttleConverter")
public class ListShuttleConverter extends ListConverter {
	protected final ListShuttleSupport<?, ?> getSupport(UIComponent component) {
		return (ListShuttleSupport<?, ?>) getAttribute(component,
				"converterValue", ListShuttleSupport.class);
	}

	@Override
	protected List<?> getList(UIComponent component) {
		return getSupport(component).getConverterValue();
	}
}