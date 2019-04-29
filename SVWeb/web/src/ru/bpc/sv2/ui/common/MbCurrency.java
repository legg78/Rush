package ru.bpc.sv2.ui.common;

import java.net.SocketTimeoutException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.xml.ws.BindingProvider;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;



import ru.bpc.datamanagement.DataManagement;
import ru.bpc.datamanagement.DataManagement_Service;
import ru.bpc.datamanagement.EntityObjStatusType;
import ru.bpc.datamanagement.EntityObjType;
import ru.bpc.datamanagement.ObjectFactory;
import ru.bpc.datamanagement.SyncronizeRqType;
import ru.bpc.datamanagement.SyncronizeRsType;
import ru.bpc.sv2.common.Currency;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.WebServiceConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;

@ViewScoped
@ManagedBean (name = "MbCurrency")
public class MbCurrency extends AbstractBean{		
	private static final long serialVersionUID = 1L;
	
	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "1454:currsTable";
		
	private CommonDao _commonDao = new CommonDao();

	private SettingsDao settingsDao = new SettingsDao();
	
	private Currency filter;

    private final DaoDataModel<Currency> _currenciesSource;
	private final TableRowSelection<Currency> _itemSelection;
	private Currency _activeCurrency;
	
	private Currency newCurrency;

	public MbCurrency() {
		pageLink = "common|currencies";
		_currenciesSource = new DaoDataModel<Currency>() {
			private static final long serialVersionUID = 1L;
			
			@Override
			protected Currency[] loadDaoData(SelectionParams params) {
				if (!isSearching()) {
					return new Currency[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getCurrencies( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Currency[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching()) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getCurrenciesCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Currency>(null, _currenciesSource);
	}

	public DaoDataModel<Currency> getCurrencies() {
		return _currenciesSource;
	}

	public Currency getActiveCurrency() {
		return _activeCurrency;
	}

	public void setActiveCurrency(Currency activeCurrency) {
		_activeCurrency = activeCurrency;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCurrency = _itemSelection.getSingleSelection();
	}

	public void  search() {
		setFilters();

		searching = true;

		// search using new criteria
		_currenciesSource.flushCache();

		// reset selection
		if (_activeCurrency != null) {
			_itemSelection.unselect(_activeCurrency);
			_activeCurrency = null;
		}
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new Currency();
		searching = false;
		clearState();
	}
	
	public void clearState() {
		_itemSelection.clearSelection();
		_activeCurrency = null;
		_currenciesSource.flushCache();
		curLang = userLang;
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		getFilter();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getCode() != null && filter.getCode().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("code");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getCode());
			filters.add(paramFilter);
		}

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim()
					.toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getCurrencyName() != null && filter.getCurrencyName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("currencyName");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getCurrencyName().trim()
					.toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void resetBean() {
	}

	public Currency getFilter() {
		if (filter == null) {
			filter = new Currency();
		}
		return filter;
	}

	public void setFilter(Currency filter) {
		this.filter = filter;
	}

	public void close() {
		curMode = AbstractBean.VIEW_MODE;
	}

	public void cancel() {
		close();
	}

	public void changeLang(ValueChangeEvent event) {
		String lang = (String) event.getNewValue();
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(_activeCurrency.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);
			
			params.setFilters(filters);
			Currency[] currs = _commonDao.getCurrencies( userSessionId, params);
			
			if (currs != null && currs.length > 0) {
				_activeCurrency = currs[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public void add(){
		newCurrency = new Currency();
		newCurrency.setLang(userLang);
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void edit(){
		try {
			curMode = AbstractBean.EDIT_MODE;
			newCurrency = _activeCurrency.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}
	
	public void save(){
		try {
			if (isEditMode()) {
				newCurrency = _commonDao.editCurrency(userSessionId, newCurrency);
				_currenciesSource.replaceObject(_activeCurrency, newCurrency);
			} else {
				_commonDao.addCurrency(userSessionId, newCurrency);
				_itemSelection.addNewObjectToList(newCurrency);
			}
			refresh();
			_activeCurrency = newCurrency;
			curMode = AbstractBean.VIEW_MODE;

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}
	
	public void refresh(){
		try {
			CurrencyCache.getInstance().reload();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}

	public void reload(){
		try {
			List<Currency> currencies = _itemSelection
					.getMultiSelection();
			if (currencies.size() == 0) {
				return;
			}

			String feLocation = settingsDao.getParameterValueV(userSessionId,
					SettingsConstants.FRONT_END_LOCATION, LevelNames.SYSTEM,
					null);
			if (feLocation == null || feLocation.trim().length() == 0){
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty", SettingsConstants.FRONT_END_LOCATION);
				FacesUtils.addErrorExceptionMessage(msg);
				return;
			}
			Double wsPort = settingsDao.getParameterValueN(userSessionId,
					SettingsConstants.UPDATE_CACHE_WS_PORT, LevelNames.SYSTEM, null);
			if (wsPort == null) {
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
						SettingsConstants.UPDATE_CACHE_WS_PORT);
				FacesUtils.addErrorExceptionMessage(msg);
			}
			feLocation = feLocation + ":" + wsPort.intValue();

			ObjectFactory of = new ObjectFactory();
			SyncronizeRqType syncronizeRqType = of.createSyncronizeRqType();
			List<EntityObjType> listEnityObjType = syncronizeRqType
					.getEntityObj();

			for (Currency currency : currencies) {
				EntityObjType entityObj = of.createEntityObjType();
				entityObj.setObjId(currency.getId().toString());
				entityObj.setObjSeq(currency.getSeqNum());
				listEnityObjType.add(entityObj);
			}
			syncronizeRqType.setEntityType(WebServiceConstants.CURRENCY);

			DataManagement_Service service = new DataManagement_Service();
			DataManagement port = service.getDataManagementSOAP();
			BindingProvider bp = (BindingProvider)port;
			bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);
			bp.getRequestContext().put("javax.xml.ws.client.connectionTimeout", SystemConstants.FE_TIMEOUT);
			bp.getRequestContext().put("javax.xml.ws.client.receiveTimeout", SystemConstants.FE_TIMEOUT);
			
			SyncronizeRsType rsType = null;
			try {
				rsType = port.syncronize(syncronizeRqType);
			} catch (Exception e) {
				String msg = null;
				if (e.getCause() instanceof UnknownHostException){
					msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "unknown_host", e.getCause().getMessage()) + ".";
				} else if (e.getCause() instanceof SocketTimeoutException){
					msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "web_service_timeout");
				} else {
					msg = e.getMessage();
				}
				msg += ". " + FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "check_front_end_settings");
				FacesUtils.addErrorExceptionMessage(msg);
				logger.error("", e);
				return;
			}
			List<EntityObjStatusType> objStatusTypes = rsType.getEntityObjStatus();
			
			for (int i=0;i<currencies.size();i++){
				Currency currency = currencies.get(i);
				EntityObjStatusType objStatusType = objStatusTypes.get(i);
				currency.setFerrNo(objStatusType.getFerrno());
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void delete(){
		try {
			_commonDao.deleteCurrency(userSessionId, _activeCurrency);

			_activeCurrency = _itemSelection.removeObjectFromList(_activeCurrency);

			curMode = AbstractBean.VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}
		
	public Currency getNewCurrency(){
		if (newCurrency == null) {
			newCurrency = new Currency();
		}
		return newCurrency;
	}
	
	public List<Currency> getSelectedItems(){
		return _itemSelection.getMultiSelection();
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
