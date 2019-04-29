package ru.bpc.sv2.ui.common;

import java.math.BigDecimal;
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
import ru.bpc.sv2.common.Country;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.WebServiceConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

@ViewScoped
@ManagedBean (name = "MbCountry")
public class MbCountry extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");
	
	private static String COMPONENT_ID = "1453:countriesTable";

	private CommonDao _commonDao = new CommonDao();
	
	private Country filter;

    private final DaoDataModel<Country> _countriesSource;
	private final TableRowSelection<Country> _itemSelection;
	private Country _activeCountry;

    private Country newCountry;

	public MbCountry() {
		pageLink = "common|countries";
		_countriesSource = new DaoDataModel<Country>() {
			private static final long serialVersionUID = 1L;
			
			@Override
			protected Country[] loadDaoData(SelectionParams params) {
				if (!isSearching()) {
					return new Country[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getCountries( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Country[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching()) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getCountriesCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Country>(null, _countriesSource);
	}

    public void add(){
        newCountry = new Country();
        newCountry.setLang(userLang);
        curMode = AbstractBean.NEW_MODE;
    }

    public void edit(){
        try {
            curMode = AbstractBean.EDIT_MODE;
            newCountry = _activeCountry.clone();
        } catch (CloneNotSupportedException e) {
            FacesUtils.addMessageError(e);
            logger.error(e.getMessage(), e);
        }
    }

    public void save(){
        try {
            if (isEditMode()) {
                newCountry = _commonDao.editCountry(userSessionId, newCountry);
                _countriesSource.replaceObject(_activeCountry, newCountry);
            } else {
                newCountry = _commonDao.addCountry(userSessionId, newCountry);
                _itemSelection.addNewObjectToList(newCountry);
            }
            _activeCountry = newCountry;
            curMode = AbstractBean.VIEW_MODE;

        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error(e.getMessage(), e);
        }
    }

//    public void refresh(){
//        try {
//            reload();   // TODO CHECK HERE...
//        } catch (Exception e) {
//            FacesUtils.addMessageError(e);
//            logger.error(e.getMessage(), e);
//        }
//    }
	
	public void reload() {
		try {
			List<Country> countries = _itemSelection
					.getMultiSelection();
			if (countries.size() == 0) {
				return;
			}
			
			SettingsCache settingParamsCache = SettingsCache.getInstance();
			String feLocation = settingParamsCache.getParameterStringValue(SettingsConstants.FRONT_END_LOCATION);
			if (feLocation == null || feLocation.trim().length() == 0){
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty", SettingsConstants.FRONT_END_LOCATION);
				FacesUtils.addErrorExceptionMessage(msg);
				return;
			}
			BigDecimal wsPort = settingParamsCache.getParameterNumberValue(SettingsConstants.UPDATE_CACHE_WS_PORT);
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

			for (Country country : countries) {
				EntityObjType entityObj = of.createEntityObjType();
				entityObj.setObjId(country.getId().toString());
				entityObj.setObjSeq(country.getSeqNum());
				listEnityObjType.add(entityObj);
			}
			syncronizeRqType.setEntityType(WebServiceConstants.COUNTRY);

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
			
			for (int i=0;i<countries.size();i++){
				Country country = countries.get(i);
				EntityObjStatusType objStatusType = objStatusTypes.get(i);
				country.setFerrNo(objStatusType.getFerrno());
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public DaoDataModel<Country> getCountries() {
		return _countriesSource;
	}

	public Country getActiveCountry() {
		return _activeCountry;
	}

	public void setActiveCountry(Country activeCountry) {
		_activeCountry = activeCountry;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCountry = _itemSelection.getSingleSelection();
	}

	public void  search() {
		setFilters();

		searching = true;

		// search using new criteria
		_countriesSource.flushCache();

		// reset selection
		if (_activeCountry != null) {
			_itemSelection.unselect(_activeCountry);
			_activeCountry = null;
		}
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new Country();
		searching = false;
		clearState();
	}
	
	public void clearState() {
		_itemSelection.clearSelection();
		_activeCountry = null;
		_countriesSource.flushCache();
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

		if (filter.getCountryName() != null && filter.getCountryName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("countryName");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getCountryName().trim()
					.toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void resetBean() {
	}

	public Country getFilter() {
		if (filter == null) {
			filter = new Country();
		}
		return filter;
	}

	public void setFilter(Country filter) {
		this.filter = filter;
	}

	public void close() {
        curMode = AbstractBean.VIEW_MODE;
	}

	public void cancel() {
        close();
	}

    public void confirmEditLanguage() {
        curLang = newCountry.getLang();
        Country tmp = getNodeByLang(newCountry.getId(), newCountry.getLang());
        if (tmp != null) {
            try {
                newCountry = tmp.clone();
            } catch (CloneNotSupportedException e) {
                FacesUtils.addMessageError(e);
                logger.error(e.getMessage(), e);
            }

        }
    }


    public Country getNodeByLang(Integer id, String lang) {
        try {
            SelectionParams params = new SelectionParams();
            Filter[] filters = new Filter[2];
            filters[0] = new Filter();
            filters[0].setElement("id");
            filters[0].setValue(id.toString());
            filters[1] = new Filter();
            filters[1].setElement("lang");
            filters[1].setValue(lang);

            params.setFilters(filters);
            Country[] items = _commonDao.getCountries( userSessionId, params);

            if (items != null && items.length > 0) {
                return items[0];
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("",e);
        }
        return null;
    }

	public void changeLanguage(ValueChangeEvent event) {
		String lang = (String) event.getNewValue();
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(_activeCountry.getId().toString());
            filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);
			
			params.setFilters(filters);
			Country[] items = _commonDao.getCountries( userSessionId, params);
			
			if (items != null && items.length > 0) {
				_activeCountry = items[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	public List<Country> getSelectedItems(){
		return _itemSelection.getMultiSelection();
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

    public void delete(){
        try {
            _commonDao.deleteCountry(userSessionId, _activeCountry);

            _activeCountry = _itemSelection.removeObjectFromList(_activeCountry);

            curMode = AbstractBean.VIEW_MODE;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error(e.getMessage(), e);
        }
    }



    public Country getNewCountry(){
        if (newCountry == null) {
            newCountry = new Country();
        }
        return newCountry;
    }

}
