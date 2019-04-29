package ru.bpc.sv2.ui.hsm;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.hsm.HsmDevice;
import ru.bpc.sv2.hsm.HsmDynamicConnection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.HsmDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbConnectivity")
public class MbConnectivity extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private HsmDao _hsmDao = new HsmDao();

	

	private HsmDynamicConnection connFilter;
	private HsmDynamicConnection newConnection;
	private HsmDevice hsmDevice;

	private final DaoDataModel<HsmDynamicConnection> _connsSource;
	private final TableRowSelection<HsmDynamicConnection> _itemSelection;
	private HsmDynamicConnection _activeConnection;
	
	private static String COMPONENT_ID = "connectivityTable";
	private String tabName;
	private String parentSectionId;

	public MbConnectivity() {
		

		_connsSource = new DaoDataModel<HsmDynamicConnection>() {
			@Override
			protected HsmDynamicConnection[] loadDaoData(SelectionParams params) {
				if (hsmDevice == null) {
					return new HsmDynamicConnection[0];
				}
				try {
					setFilters(params);
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _hsmDao.getDynamicConnections(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new HsmDynamicConnection[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (hsmDevice == null) {
					return 0;
				}
				try {
					setFilters(params);
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _hsmDao.getDynamicConnectionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<HsmDynamicConnection>(null, _connsSource);
	}

	public DaoDataModel<HsmDynamicConnection> getConnections() {
		return _connsSource;
	}

	public HsmDynamicConnection getActiveConnection() {
		return _activeConnection;
	}

	public void setActiveConnection(HsmDynamicConnection activeConnection) {
		_activeConnection = activeConnection;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeConnection = _itemSelection.getSingleSelection();
	}

	public String search() {
		// search using new criteria
		clearBean();

		return "";
	}

	public void clearFilter() {
		connFilter = new HsmDynamicConnection();
	}

	public void setFilters(SelectionParams params) {
		connFilter = getFilter();

		filters = new ArrayList<Filter>();
		if (hsmDevice.getId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("deviceId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(hsmDevice.getId().toString());
			filters.add(paramFilter);
		}
		// copy filters that are already exist in SelectionParams
		// replace all asterisks by percent sign for oracle to search correctly
//		for (Filter filter : params.getFilters()) {
//
//			// check if filter is already defined upper or if it is empty
//			if (filter.getElement().equalsIgnoreCase("deviceId")
//					|| filter.getValue().trim().length() == 0) {
//				continue;
//			}
//			filter.setValue(filter.getValue().trim().toUpperCase().replaceAll("[*]", "%")
//					.replaceAll("[?]", "_"));
//			filters.add(filter);
//		}
		// if (connFilter.getDeviceId() != null) {
		// paramFilter.setElement("id");
		// paramFilter.setOp(Operator.eq);
		// paramFilter.setValue(connFilter.getDeviceId().toString());
		// filters.add(paramFilter);
		// }
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public HsmDynamicConnection getFilter() {
		if (connFilter == null) {
			connFilter = new HsmDynamicConnection();
		}
		return connFilter;
	}

	public void setFilter(HsmDynamicConnection connFilter) {
		this.connFilter = connFilter;
	}

	public HsmDynamicConnection getNewConnection() {
		if (newConnection == null) {
			newConnection = new HsmDynamicConnection();
		}
		return newConnection;
	}

	public void setNewConnection(HsmDynamicConnection newConnection) {
		this.newConnection = newConnection;
	}

	public void clearBean() {
		_connsSource.flushCache();
		_itemSelection.clearSelection();
		_activeConnection = null;
	}

	public void fullCleanBean() {
		hsmDevice = null;
		clearBean();
	}

	public HsmDevice getHsmDevice() {
		return hsmDevice;
	}

	public void setHsmDevice(HsmDevice hsmDevice) {
		this.hsmDevice = hsmDevice;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

}
