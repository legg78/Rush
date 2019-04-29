package ru.bpc.sv2.ui.aup;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.aup.AuthScheme;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AuthProcessingDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean(name = "MbAupSchemes")
public class MbAupSchemes extends AbstractBean {

	private static final Logger logger = Logger.getLogger("AUTH_PROCESSING");

	private static String COMPONENT_ID = "1862:schemesTable";

	private static final int scaleId = 1003;

	private AuthProcessingDao _aupDao = new AuthProcessingDao();

	

	private AuthScheme filter;
	private AuthScheme newScheme;
	private AuthScheme detailScheme;

	private final DaoDataModel<AuthScheme> _schemeSource;
	private final TableRowSelection<AuthScheme> _itemSelection;
	private AuthScheme _activeScheme;
	private String tabName;
	private ArrayList<SelectItem> institutions;
	private String oldLang;


	public MbAupSchemes() {
		
		pageLink = "aup|schemes";
		tabName = "detailsTab";
		_schemeSource = new DaoDataModel<AuthScheme>() {
			@Override
			protected AuthScheme[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new AuthScheme[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _aupDao.getSchemes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AuthScheme[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _aupDao.getSchemesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AuthScheme>(null, _schemeSource);
	}

	public DaoDataModel<AuthScheme> getSchemes() {
		return _schemeSource;
	}

	public AuthScheme getActiveScheme() {
		return _activeScheme;
	}

	public void setActiveScheme(AuthScheme activeScheme) {
		_activeScheme = activeScheme;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeScheme == null && _schemeSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeScheme != null && _schemeSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeScheme.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeScheme = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null
					&& !_itemSelection.getSingleSelection().getId().equals(_activeScheme.getId())) {
				changeSelect = true;
			}
			_activeScheme = _itemSelection.getSingleSelection();
			// set entry templates
			if (_activeScheme != null) {
				setBeans();
				if (changeSelect) {
					detailScheme = (AuthScheme) _activeScheme.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_schemeSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeScheme = (AuthScheme) _schemeSource.getRowData();
		selection.addKey(_activeScheme.getModelId());
		_itemSelection.setWrappedSelection(selection);

		if (_activeScheme != null) {
			setBeans();
			detailScheme = (AuthScheme) _activeScheme.clone();
		}
	}

	public void search() {
		clearBean();
		searching = true;
		curLang = userLang;
	}

	public void clearFilter() {
		curLang = userLang;
		filter = null;
		searching = false;
		clearBean();
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		if (filter.getLabel() != null && filter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getLabel().trim().toUpperCase().replaceAll("[*]", "%")
			        .replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getSchemeType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("schemeType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getSchemeType());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newScheme = new AuthScheme();
		newScheme.setLang(userLang);
		curLang = newScheme.getLang();
		newScheme.setScaleId(scaleId);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newScheme = (AuthScheme) detailScheme.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_aupDao.deleteScheme(userSessionId, _activeScheme);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf", "scheme_deleted",
			        "(id = " + _activeScheme.getId() + ")");

			_activeScheme = _itemSelection.removeObjectFromList(_activeScheme);
			if (_activeScheme == null) {
				clearBean();
			} else {
				setBeans();
				detailScheme = (AuthScheme) _activeScheme.clone();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newScheme = _aupDao.addScheme(userSessionId, newScheme);
				detailScheme = (AuthScheme) newScheme.clone();
				_itemSelection.addNewObjectToList(newScheme);
			} else {
				newScheme = _aupDao.editScheme(userSessionId, newScheme);
				detailScheme = (AuthScheme) newScheme.clone();
				if (!userLang.equals(newScheme.getLang())) {
					newScheme = getNodeByLang(_activeScheme.getId(), userLang);
				}
				_schemeSource.replaceObject(_activeScheme, newScheme);
			}
			_activeScheme = newScheme;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf",
			        "scheme_saved"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public AuthScheme getFilter() {
		if (filter == null) {
			filter = new AuthScheme();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(AuthScheme filter) {
		this.filter = filter;
	}

	public AuthScheme getNewScheme() {
		if (newScheme == null) {
			newScheme = new AuthScheme();
		}
		return newScheme;
	}

	public void setNewScheme(AuthScheme newScheme) {
		this.newScheme = newScheme;
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbAupSchemeTemplates templsBean = (MbAupSchemeTemplates) ManagedBeanWrapper
		        .getManagedBean("MbAupSchemeTemplates");
		templsBean.setScheme(_activeScheme);
		if (_activeScheme.getSchemeType().equals("AUSC0001") || 
				_activeScheme.getSchemeType().equals("AUSC0002")){
			templsBean.setTemplType(_activeScheme.getSchemeType().replace("SC", "TM"));
		}else{
			templsBean.setTemplType(null);
		}
		templsBean.search();
		//
		MbAupSchemeObjects objsBean = (MbAupSchemeObjects) ManagedBeanWrapper
		        .getManagedBean("MbAupSchemeObjects");
		objsBean.setScheme(_activeScheme);
		objsBean.search();
	}

	public void clearBean() {
		_schemeSource.flushCache();
		_itemSelection.clearSelection();
		_activeScheme = null;
		detailScheme = null;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("templatesTab")) {
			MbAupSchemeTemplates bean = (MbAupSchemeTemplates) ManagedBeanWrapper
					.getManagedBean("MbAupSchemeTemplates");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("objectsTab")) {
			MbAupSchemeObjects bean = (MbAupSchemeObjects) ManagedBeanWrapper
					.getManagedBean("MbAupSchemeObjects");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_AUTH_SCHEME;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeScheme != null) {
			curLang = (String) event.getNewValue();
			detailScheme = getNodeByLang(detailScheme.getId(), curLang);
		}
	}
	
	public AuthScheme getNodeByLang(Integer id, String lang) {
		if (_activeScheme != null) {
			List<Filter> filtersList = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(id);
			filtersList.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(lang);
			filtersList.add(paramFilter);

			filters = filtersList;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			try {
				AuthScheme[] devices = _aupDao.getSchemes(userSessionId, params);
				if (devices != null && devices.length > 0) {
					return devices[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		return null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getSchemeTypes() {
		return getDictUtils().getArticles(DictNames.AUTH_SCHEME_TYPE, true);
	}

	public List<SelectItem> getResponseCodes() {
		return getDictUtils().getLov(LovConstants.RESPONSE_CODES);
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		curLang = newScheme.getLang();
		AuthScheme tmp = getNodeByLang(newScheme.getId(), newScheme.getLang());
		if (tmp != null) {
			newScheme.setLabel(tmp.getLabel());
			newScheme.setDescription(tmp.getDescription());
		}
	}

	public void cancelEditLanguage() {
		newScheme.setLang(oldLang);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public AuthScheme getDetailScheme() {
		return detailScheme;
	}

	public void setDetailScheme(AuthScheme detailScheme) {
		this.detailScheme = detailScheme;
	}
	
	public boolean isNegativeSchemeType(){
		if (newScheme != null){
			if ("AUSC0002".equalsIgnoreCase(newScheme.getSchemeType())){
				return true;
			}else{
				return false;
			}
		}else{
			return false;
		}
	}

}
