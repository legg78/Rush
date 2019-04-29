package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.widget.*;

import java.sql.SQLException;
import java.util.List;

/**
 * Payment Orders Bean implementation class PaymentOrdersDao
 */
public class WidgetsDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("WIDGETS");
	
	@SuppressWarnings("unchecked")
	public Dashboard[] getDashboardsInfo(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			String limitation = CommonController.getLimitationByPriv(ssn,
					WidgetPrivConstants.VIEW_DASHBOARD);
			List<Dashboard> dashboards = ssn.queryForList("wgt.get-dashboards", convertQueryParams(
					params, limitation));
			return dashboards.toArray(new Dashboard[dashboards.size()]);
		} catch (SQLException e) {
//			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public WidgetItem[] getWidgets(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.VIEW_WIDGETS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					WidgetPrivConstants.VIEW_WIDGETS);
			List<WidgetItem> widgets = ssn.queryForList("wgt.get-widgets", convertQueryParams(
					params, limitation));
			return widgets.toArray(new WidgetItem[widgets.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getWidgetsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.VIEW_WIDGETS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					WidgetPrivConstants.VIEW_WIDGETS);
			return (Integer) ssn.queryForObject("wgt.get-widget-count", convertQueryParams(params,
					limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public WidgetItem addWidget(Long userSessionId, WidgetItem widget) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(widget.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.ADD_WIDGET, paramArr);
			ssn.insert("wgt.add-widget", widget);

			return widget;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public WidgetItem editWidget(Long userSessionId, WidgetItem widget) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(widget.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.EDIT_WIDGET, paramArr);

			ssn.update("wgt.edit-widget", widget);

			// as we don't modify anything that could require getting data from
			// other tables we don't have to query for modified object
			return widget;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeWidget(Long userSessionId, WidgetItem widget) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(widget.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.DELETE_WIDGET, paramArr);
			ssn.delete("wgt.delete-widget", widget);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Dashboard[] getDashboards(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.VIEW_DASHBOARD, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					WidgetPrivConstants.VIEW_DASHBOARD);
			List<Dashboard> dashboards = ssn.queryForList("wgt.get-dashboards", convertQueryParams(
					params, limitation));
			return dashboards.toArray(new Dashboard[dashboards.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getDashboardsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.VIEW_DASHBOARD, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					WidgetPrivConstants.VIEW_DASHBOARD);
			return (Integer) ssn.queryForObject("wgt.get-dashboard-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Dashboard addDashboard(Long userSessionId, Dashboard dashboard) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dashboard.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.ADD_DASHBOARD, paramArr);
			ssn.insert("wgt.add-dashboard", dashboard);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(dashboard.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(dashboard.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Dashboard) ssn.queryForObject("wgt.get-dashboards", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Dashboard editDashboard(Long userSessionId, Dashboard dashboard) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dashboard.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.EDIT_DASHBOARD, paramArr);

			ssn.update("wgt.edit-dashboard", dashboard);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(dashboard.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(dashboard.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Dashboard) ssn.queryForObject("wgt.get-dashboards", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeDashboard(Long userSessionId, Dashboard dashboard) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dashboard.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.DELETE_DASHBOARD, paramArr);
			ssn.delete("wgt.delete-dashboard", dashboard);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Dashboard2WidgetItem[] getDashboardWidgets(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.VIEW_DASHBOARD_WIDGET, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					WidgetPrivConstants.VIEW_DASHBOARD_WIDGET);
			List<Dashboard2WidgetItem> dashboardWidgets = ssn.queryForList(
					"wgt.get-dashboard-widgets", convertQueryParams(params, limitation));
			return dashboardWidgets.toArray(new Dashboard2WidgetItem[dashboardWidgets.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Dashboard2WidgetItem addDashboardWidget(Long userSessionId,
			Dashboard2WidgetItem dashboardWidget) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dashboardWidget.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.ADD_DASHBOARD_WIDGET, paramArr);
			ssn.insert("wgt.add-dashboard-widget", dashboardWidget);

			return dashboardWidget;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Dashboard2WidgetItem editDashboardWidget(Long userSessionId,
			Dashboard2WidgetItem dashboardWidget, List<WidgetParameter> widgetParams) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dashboardWidget.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.MODIFY_DASHBOARD_WIDGET, paramArr);

			ssn.update("wgt.edit-dashboard-widget", dashboardWidget);

			for (WidgetParameter param : widgetParams) {
				if (param.isChar()) {
					if (param.getValueV() == null || param.getValueV().isEmpty()) {
						// if value is empty either delete it (if it existed) or do nothing
						if (param.getValueId() != null) {
							ssn.delete("wgt.remove-widget-param-value", param);
						}
					} else {
						ssn.insert("wgt.set-widget-param-value-char", param);
					}
				} else if (param.isNumber()) {
					if (param.getValueN() == null) {
						// if value is empty either delete it (if it existed) or do nothing
						if (param.getValueId() != null) {
							ssn.delete("wgt.remove-widget-param-value", param);
						}
					} else {
						ssn.insert("wgt.set-widget-param-value-num", param);
					}
				} else if (param.isDate()) {
					if (param.getValueD() == null) {
						// if value is empty either delete it (if it existed) or do nothing
						if (param.getValueId() != null) {
							ssn.delete("wgt.remove-widget-param-value", param);
						}
					} else {
						ssn.insert("wgt.set-widget-param-value-date", param);
					}
				}
			}
			
			// as we don't modify anything that could require getting data from
			// other tables we don't have to query for modified object
			return dashboardWidget;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addDashboardWidgetList(Long userSessionId,
			Dashboard2WidgetItem[] oldWidgetPositionList,
			Dashboard2WidgetItem[] newWidgetPositionList) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.ADD_DASHBOARD_WIDGET, null);
			for (Dashboard2WidgetItem item : oldWidgetPositionList) {
				ssn.delete("wgt.delete-dashboard-widget", item);
			}

			for (Dashboard2WidgetItem item : newWidgetPositionList) {
				ssn.insert("wgt.add-dashboard-widget", item);
			}

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeDashboardWidget(Long userSessionId, Dashboard2WidgetItem dashboardWidget) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dashboardWidget.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.REMOVE_DASHBOARD_WIDGET, paramArr);
			ssn.delete("wgt.remove-dashboard-widget", dashboardWidget);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public WidgetParameter addWidgetParameter(Long userSessionId, WidgetParameter param) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.ADD_WIDGET_PARAMETER, paramArr);
			ssn.insert("wgt.add-widget-parameter", param);

			return param;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public WidgetParameter modifyWidgetParameter(Long userSessionId, WidgetParameter param) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.MODIFY_WIDGET_PARAMETER, paramArr);
			ssn.insert("wgt.modify-widget-parameter", param);

			return param;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeWidgetParameter(Long userSessionId, WidgetParameter param) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.REMOVE_WIDGET_PARAMETER, paramArr);
			ssn.delete("wgt.remove-widget-parameter", param);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public WidgetParameter[] getWidgetParamsWithValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.VIEW_WIDGET_PARAM_VALUES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					WidgetPrivConstants.VIEW_WIDGET_PARAM_VALUES);
			List<WidgetParameter> values = ssn.queryForList("wgt.get-widget-params-with-values",
					convertQueryParams(params, limitation));
			return values.toArray(new WidgetParameter[values.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getWidgetParamsWithValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.VIEW_WIDGET_PARAM_VALUES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					WidgetPrivConstants.VIEW_WIDGET_PARAM_VALUES);
			return (Integer) ssn.queryForObject("wgt.get-widget-params-with-values-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setWidgetParamValue(Long userSessionId, WidgetParameter value) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(value.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.SET_WIDGET_PARAM_VALUE, paramArr);
			if (value.isChar()) {
				ssn.insert("wgt.set-widget-param-value-char", value);
			} else if (value.isNumber()) {
				ssn.insert("wgt.set-widget-param-value-num", value);
			} else if (value.isDate()) {
				ssn.insert("wgt.set-widget-param-value-date", value);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeWidgetParamValue(Long userSessionId, WidgetParameter value) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(value.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, WidgetPrivConstants.REMOVE_WIDGET_PARAM_VALUE, paramArr);
			ssn.delete("wgt.remove-widget-param-value", value);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
}
