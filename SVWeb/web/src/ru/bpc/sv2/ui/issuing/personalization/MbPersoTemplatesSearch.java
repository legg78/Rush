package ru.bpc.sv2.ui.issuing.personalization;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.scale.ScaleConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.personalization.PrsMethod;
import ru.bpc.sv2.issuing.personalization.PrsTemplate;
import ru.bpc.sv2.logic.PersonalizationDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.naming.NameFormat;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbPersoTemplatesSearch")
public class MbPersoTemplatesSearch extends AbstractBean {
	private static final long serialVersionUID = 3424924783524852476L;

	private static final Logger logger = Logger.getLogger("PERSONALIZATION");

	private PersonalizationDao _personalizationDao = new PersonalizationDao();

	private RulesDao _rulesDao = new RulesDao();
	
	private Integer instId;

	private PrsTemplate filter;
	private PrsTemplate _activeTemplate;
	private PrsTemplate newTemplate;

	private ArrayList<SelectItem> formats;
	private ArrayList<SelectItem> methods;
	private ArrayList<SelectItem> persoTemPar = null;

	private final DaoDataModel<PrsTemplate> _templatesSource;

	private final TableRowSelection<PrsTemplate> _itemSelection;
	
	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;

	public MbPersoTemplatesSearch() {
		_templatesSource = new DaoDataModel<PrsTemplate>() {
			private static final long serialVersionUID = -5166794325445860674L;

			@Override
			protected PrsTemplate[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new PrsTemplate[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getTemplates(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PrsTemplate[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getTemplatesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<PrsTemplate>(null, _templatesSource);
	}

	public DaoDataModel<PrsTemplate> getTemplates() {
		return _templatesSource;
	}

	public PrsTemplate getActiveTemplate() {
		return _activeTemplate;
	}

	public void setActiveTemplate(PrsTemplate activeTemplate) {
		_activeTemplate = activeTemplate;
	}

	public SimpleSelection getItemSelection() {
		if (_activeTemplate == null && _templatesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeTemplate != null && _templatesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeTemplate.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeTemplate = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_templatesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTemplate = (PrsTemplate) _templatesSource.getRowData();
		selection.addKey(_activeTemplate.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeTemplate != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTemplate = _itemSelection.getSingleSelection();
		if (_activeTemplate != null) {
			setInfo();
		}
	}

	public void setInfo() {
		// MbNameComponentsSearch compSearch =
		// (MbNameComponentsSearch)ManagedBeanWrapper.getManagedBean("MbNameComponentsSearch");
		// NameComponent componentFilter = new NameComponent();
		// componentFilter.setFormatId(_activeFormat.getId());
		// compSearch.setFilter(componentFilter);
		//		
		// NameBaseParam baseParamFilter = new NameBaseParam();
		// baseParamFilter.setEntityType(_activeFormat.getEntityType());
		// compSearch.setBaseParamFilter(baseParamFilter);
		// compSearch.setBaseValues(null);
		// compSearch.search();
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new PrsTemplate();
		clearState();
		searching = false;
	}

	public PrsTemplate getFilter() {
		if (filter == null)
			filter = new PrsTemplate();
		return filter;
	}

	public void setFilter(PrsTemplate filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getEntityType() != null && filter.getEntityType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getMethodId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("methodId");
			paramFilter.setValue(filter.getMethodId().toString());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newTemplate = new PrsTemplate();
		newTemplate.setMethodId(getFilter().getMethodId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newTemplate = (PrsTemplate) _activeTemplate.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newTemplate = _activeTemplate;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		try {
			if (isNewMode()) {
				newTemplate = _personalizationDao.addTemplate(userSessionId, newTemplate, curLang);
				_itemSelection.addNewObjectToList(newTemplate);
			} else if (isEditMode()) {
				newTemplate = _personalizationDao.modifyTemplate(userSessionId, newTemplate,
						curLang);
				_templatesSource.replaceObject(_activeTemplate, newTemplate);
			}

			_activeTemplate = newTemplate;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_personalizationDao.deleteTemplate(userSessionId, _activeTemplate);
			_activeTemplate = _itemSelection.removeObjectFromList(_activeTemplate);
			if (_activeTemplate == null) {
				clearState();
			} else {
				setInfo();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void setCurMode(int mode) {
		curMode = mode;
	}

	public boolean isViewMode() {
		return curMode == VIEW_MODE;
	}

	public boolean isEditMode() {
		return curMode == EDIT_MODE;
	}

	public boolean isNewMode() {
		return curMode == NEW_MODE;
	}

	public PrsTemplate getNewTemplate() {
		if (newTemplate == null) {
			newTemplate = new PrsTemplate();
		}
		return newTemplate;
	}

	public void setNewTemplate(PrsTemplate newTemplate) {
		this.newTemplate = newTemplate;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeTemplate = null;
		_templatesSource.flushCache();
		curLang = userLang;
	}

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES_FOR_PERSONALIZATION);
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public String getCurLang() {
		return curLang;
	}

	public void setCurLang(String curLang) {
		this.curLang = curLang;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeTemplate.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			PrsTemplate[] templates = _personalizationDao.getTemplates(userSessionId, params);
			if (templates != null && templates.length > 0) {
				_activeTemplate = templates[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void changeEntityType(ValueChangeEvent event) {
		String entityType = (String) event.getNewValue();
		newTemplate = getNewTemplate();
		if (entityType == null || entityType.equals("")) {
			return;
		}
		try {
			newTemplate.setEntityType(entityType);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getFormats() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			if (getNewTemplate().getEntityType() == null
					|| getNewTemplate().getEntityType().trim().length() == 0) {
				return items;
			}

			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getNewTemplate().getEntityType());
			filtersList.add(paramFilter);

			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			NameFormat[] formatsTmp = _rulesDao.getNameFormats(userSessionId, params);
			for (NameFormat format : formatsTmp) {
				items.add(new SelectItem(format.getId(), format.getId() + " - " + format.getLabel()));
			}
			formats = items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (formats == null)
				formats = new ArrayList<SelectItem>();
		}

		return formats;
	}

	public ArrayList<SelectItem> getFormatsForEdit() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			if (getNewTemplate().getEntityType() == null
					|| getNewTemplate().getEntityType().trim().length() == 0) {
				return items;
			}
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getNewTemplate().getEntityType());
			filtersList.add(paramFilter);

			if (instId != null) {
				paramFilter = new Filter();
				paramFilter.setElement("instId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(instId.toString());
				filtersList.add(paramFilter);
			}
			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			NameFormat[] formatsTmp = _rulesDao.getNameFormats(userSessionId, params);
			for (NameFormat format : formatsTmp) {
				items.add(new SelectItem(format.getId(), format.getId() + " - " + format.getLabel()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}
		return items;
	}

	public ArrayList<SelectItem> getMethods() {
		if (methods == null) {

			ArrayList<SelectItem> items = new ArrayList<SelectItem>();
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);

				List<Filter> filtersList = new ArrayList<Filter>();
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(userLang);
				filtersList.add(paramFilter);

				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
				PrsMethod[] methodsTmp = _personalizationDao.getMethods(userSessionId, params);
				for (PrsMethod method : methodsTmp) {
					items.add(new SelectItem(method.getId(), method.getId() + " - " + method.getName()));
				}
				methods = items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (methods == null)
					methods = new ArrayList<SelectItem>();
			}
		}
		return methods;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
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

	public ArrayList<SelectItem> getPersoTemPar() {
		if (persoTemPar == null) {
			 Map<String, Object> paramMap = new HashMap<String, Object>();
	            paramMap.put("SCALE_TYPE", ScaleConstants.SCALE_FOR_PERSO_TEMPL);
	            persoTemPar =  (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.MODIFIER_LIST, paramMap);
		}		
		return persoTemPar;
	}
	
}
