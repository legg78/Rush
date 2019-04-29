package ru.bpc.sv2.widget;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Dashboard2WidgetItem implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Integer id;
	private Integer seqnum;
	private Integer dashboardId;
	private Integer widgetId;
	private Integer rowPos;
	private Integer columnPos;
	private Boolean refresh;
	private Integer refreshInterval;

	public Dashboard2WidgetItem() {

	}

	public Dashboard2WidgetItem(Integer dashboardId, Integer widgetId, Integer rowPos, Integer columnPos) {
		this.dashboardId = dashboardId;
		this.widgetId = widgetId;
		this.rowPos = rowPos;
		this.columnPos = columnPos;
	}

	public long getDashboardId() {
		return dashboardId;
	}
	public void setDashboardId(Integer dashboardId) {
		this.dashboardId = dashboardId;
	}
	public Integer getWidgetId() {
		return widgetId;
	}
	public void setWidgetId(Integer widgetId) {
		this.widgetId = widgetId;
	}
	public Integer getRowPos() {
		return rowPos;
	}
	public void setRowPos(Integer rowPos) {
		this.rowPos = rowPos;
	}
	public Integer getColumnPos() {
		return columnPos;
	}
	public void setColumnPos(Integer columnPos) {
		this.columnPos = columnPos;
	}

	public Boolean getRefresh() {
		return refresh;
	}

	public void setRefresh(Boolean refresh) {
		this.refresh = refresh;
	}

	public Integer getRefreshInterval() {
		return refreshInterval;
	}

	public void setRefreshInterval(Integer refreshInterval) {
		this.refreshInterval = refreshInterval;
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqnum() {
		return seqnum;
	}

	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public Object getModelId() {
		return id;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("dashboardId", getDashboardId());
		result.put("widgetId", getWidgetId());
		result.put("rowPos", getRowPos());
		result.put("columnPos", getColumnPos());
		result.put("refresh", getRefresh());
		result.put("refreshInterval", getRefreshInterval());
		return result;
	}
}
