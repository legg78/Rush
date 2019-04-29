package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoService;
import ru.bpc.sv2.ui.utils.*;

/**
 * Manage Bean for List PMO Services page.
 */
@ViewScoped
@ManagedBean (name = "MbPMOServices")
public class MbPMOServices extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");
	private static String COMPONENT_ID = "2123:mainTable";

	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();

	private PmoService _activeService;
	private PmoService newService;
	private PmoService detailService;

	private PmoService serviceFilter;
	private ArrayList<SelectItem> institutions;
	private boolean selectMode;

	private final DaoDataModel<PmoService> _servicesSource;
	private final TableRowSelection<PmoService> _serviceSelection;

	public MbPMOServices() {
		pageLink = "pmo|services";
		_servicesSource = new DaoDataListModel<PmoService>(logger) {
			@Override
			protected List<PmoService> loadDaoListData(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setFilters(filters);
					return _paymentOrdersDao.getServices(userSessionId, params);
				}
				return new ArrayList<PmoService>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setFilters(filters);
					return _paymentOrdersDao.getServicesCount(userSessionId, params);
				}
				return 0;
			}
		};
		_serviceSelection = new TableRowSelection<PmoService>(null, _servicesSource);
	}

	public DaoDataModel<PmoService> getServices() {
		return _servicesSource;
	}

	public PmoService getActiveService() {
		return _activeService;
	}

	public void setActiveService(PmoService activeService) {
		this._activeService = activeService;
	}

	public SimpleSelection getServiceSelection() {
		try {
			if (_activeService == null && _servicesSource.getRowCount() > 0) {
				_servicesSource.setRowIndex(0);
				SimpleSelection selection = new SimpleSelection();
				_activeService = (PmoService) _servicesSource.getRowData();
				detailService = (PmoService) _activeService.clone();
				selection.addKey(_activeService.getModelId());
				_serviceSelection.setWrappedSelection(selection);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _serviceSelection.getWrappedSelection();
	}

	public void setServiceSelection(SimpleSelection selection) {
		try {
			_serviceSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_serviceSelection.getSingleSelection() != null 
					&& !_serviceSelection.getSingleSelection().getId().equals(_activeService.getId())) {
				changeSelect = true;
			}
			_activeService = _serviceSelection.getSingleSelection();
			if (changeSelect) {
				detailService = (PmoService) _activeService.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		serviceFilter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_servicesSource.flushCache();
		if (_serviceSelection != null) {
			_serviceSelection.clearSelection();
		}
		_activeService = null;
		detailService = null;
	}

	public void add() {
		newService = new PmoService();
		newService.setLang(userLang);
		newService.setInstId(SystemConstants.DEFAULT_INSTITUTION);
		curLang = newService.getLang();
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newService = (PmoService) detailService.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newService = _activeService;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newService = _paymentOrdersDao.editService(userSessionId, newService);
				detailService = (PmoService) newService.clone();
				if (!userLang.equals(newService.getLang())) {
					newService = getNodeByLang(_activeService.getId(), userLang);
				}
				_servicesSource.replaceObject(_activeService, newService);
			} else {
				newService = _paymentOrdersDao.addService(userSessionId, newService);
				detailService = (PmoService) newService.clone();
				_serviceSelection.addNewObjectToList(newService);
			}
			_activeService = newService;

			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);

		}
	}

	public void delete() {
		try {
			_paymentOrdersDao.removeService(userSessionId, _activeService);
			FacesUtils.addMessageInfo("Service (id = " + _activeService.getId()
					+ ") has been deleted.");

			_activeService = _serviceSelection.removeObjectFromList(_activeService);
			if (_activeService == null) {
				clearBean();
			} else {
				detailService = (PmoService) _activeService.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		
	}

	public void setFilters() {
		filters = new ArrayList<Filter>(1);
		filters.add(Filter.create("lang", userLang));

		if (getServiceFilter().getId() != null) {
			filters.add(Filter.create("id", getServiceFilter().getId()));
		}
		if (StringUtils.isNotBlank(getServiceFilter().getLabel())) {
			filters.add(Filter.create("label", Operator.like, Filter.mask(getServiceFilter().getLabel())));
		}
		if (getServiceFilter().getDirection() != null) {
			filters.add(Filter.create("direction", getServiceFilter().getDirection()));
		}
		if (getServiceFilter().getInstId() != null) {
			filters.add(Filter.create("instId", getServiceFilter().getInstId()));
		}
	}

	public PmoService getServiceFilter() {
		if (serviceFilter == null) {
			serviceFilter = new PmoService();
		}
		return serviceFilter;
	}

	public void setServiceFilter(PmoService serviceFilter) {
		this.serviceFilter = serviceFilter;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public PmoService getNewService() {
		return newService;
	}

	public void setNewService(PmoService newService) {
		this.newService = newService;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailService = getNodeByLang(detailService.getId(), curLang);
	}

	public PmoService getNodeByLang(Integer id, String lang) {
		try {
			List<Filter> localFilters = new ArrayList<Filter>(2);
			localFilters.add(Filter.create("id", id.toString()));
			localFilters.add(Filter.create("lang", lang));

			SelectionParams params = new SelectionParams(filters);
			List<PmoService> services = _paymentOrdersDao.getServices(userSessionId, params);
			if (services != null && !services.isEmpty()) {
				return services.get(0);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public void confirmEditLanguage() {
		curLang = newService.getLang();
		PmoService tmp = getNodeByLang(newService.getId(), newService.getLang());
		if (tmp != null) {
			newService.setLabel(tmp.getLabel());
			newService.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public PmoService getDetailService() {
		return detailService;
	}

	public void setDetailService(PmoService detailService) {
		this.detailService = detailService;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
			if (institutions == null) {
				institutions = new ArrayList<SelectItem>();
			}
		}
		return institutions;
	}
}
