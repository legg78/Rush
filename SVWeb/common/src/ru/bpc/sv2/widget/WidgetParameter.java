package ru.bpc.sv2.widget;

import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;

public class WidgetParameter extends Parameter implements IAuditableObject {
	private Integer paramId;
	private Integer valueId;
	private Integer widgetId;
	private Integer dashboardWidgetId;

	public Integer getParamId() {
		return paramId;
	}
	
	public void setParamId(Integer paramId) {
		this.paramId = paramId;
	}

	public Integer getValueId() {
		return valueId;
	}

	public void setValueId(Integer valueId) {
		this.valueId = valueId;
	}

	public Integer getWidgetId() {
		return widgetId;
	}

	public void setWidgetId(Integer widgetId) {
		this.widgetId = widgetId;
	}

	public Integer getDashboardWidgetId() {
		return dashboardWidgetId;
	}

	public void setDashboardWidgetId(Integer dashboardWidgetId) {
		this.dashboardWidgetId = dashboardWidgetId;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("paramId", getParamId());
		result.put("systemName", getSystemName());
		result.put("name", getName());
		result.put("dataType", getDataType());
		result.put("lovId", getLovId());
		result.put("widgetId", getWidgetId());
		result.put("lang", getLang());
		result.put("valueId", getValueId());
		result.put("dashboardWidgetId", getDashboardWidgetId());
		result.put("valueV", getValueV());
		result.put("valueN", getValueN());
		result.put("valueD", getValueD());
		return result;
	}
}
