package ru.bpc.sv2.ui.fraud;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.fraud.Case;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.FraudDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbCases")
public class MbCases extends AbstractBean {
	private static final Logger logger = Logger.getLogger("FRAUD_PREVENTION");

	private static String COMPONENT_ID = "1803:casesTable";

	private FraudDao _fraudDao = new FraudDao();

	

	private Case filter;
	private Case _activeCase;
	private Case newCase;
	private Case detailCase;

	private ArrayList<SelectItem> institutions;
	private String tabName;

	private final DaoDataModel<Case> _casesSource;
	private final TableRowSelection<Case> _itemSelection;

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;

	public MbCases() {
		pageLink = "fraud|cases";
		tabName = "detailsTab";

		_casesSource = new DaoDataModel<Case>() {
			@Override
			protected Case[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Case[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getCases(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Case[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getCasesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Case>(null, _casesSource);
	}

	public DaoDataModel<Case> getCases() {
		return _casesSource;
	}

	public Case getActiveCase() {
		return _activeCase;
	}

	public void setActiveCase(Case activeCase) {
		_activeCase = activeCase;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeCase == null && _casesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeCase != null && _casesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCase.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeCase = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_casesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCase = (Case) _casesSource.getRowData();
		detailCase = (Case) _activeCase.clone();
		selection.addKey(_activeCase.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeCase.getId())) {
				changeSelect = true;
			}
			_activeCase = _itemSelection.getSingleSelection();
			if (_activeCase != null) {
				setBeans();
				if (changeSelect) {
					detailCase = (Case) _activeCase.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setBeans() {
		loadedTabs.clear();
		loadTab(getTabName());
	}

	public void clearBeansStates() {
		MbSuiteCases suiteCases = (MbSuiteCases) ManagedBeanWrapper.getManagedBean("MbSuiteCases");
		suiteCases.fullCleanBean();

		MbCaseEvents caseEvents = (MbCaseEvents) ManagedBeanWrapper.getManagedBean("MbCaseEvents");
		caseEvents.fullCleanBean();

		MbFrpChecks checks = (MbFrpChecks) ManagedBeanWrapper.getManagedBean("MbFrpChecks");
		checks.fullCleanBean();
	}

	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public Case getFilter() {
		if (filter == null) {
			filter = new Case();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Case filter) {
		this.filter = filter;
	}

	private void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getHistDepth() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getHistDepth());
			filters.add(paramFilter);
		}
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getLabel() != null && filter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setValue(filter.getLabel().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newCase = new Case();
		newCase.setLang(userLang);
		curLang = newCase.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newCase = (Case) detailCase.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newCase = _fraudDao.addCase(userSessionId, newCase);
				detailCase = (Case) newCase.clone();
				_itemSelection.addNewObjectToList(newCase);
			} else if (isEditMode()) {
				newCase = _fraudDao.modifyCase(userSessionId, newCase);
				detailCase = (Case) newCase.clone();
				if (!userLang.equals(newCase.getLang())) {
					newCase = getNodeByLang(_activeCase.getId(), userLang);
				}
				_casesSource.replaceObject(_activeCase, newCase);
			}
			_activeCase = newCase;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_fraudDao.removeCase(userSessionId, _activeCase);
			_activeCase = _itemSelection.removeObjectFromList(_activeCase);

			if (_activeCase == null) {
				clearState();
			} else {
				setBeans();
				detailCase = (Case) _activeCase.clone();
			}

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Case getNewCase() {
		if (newCase == null) {
			newCase = new Case();
		}
		return newCase;
	}

	public void setNewCase(Case newCase) {
		this.newCase = newCase;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeCase = null;
		detailCase = null;
		_casesSource.flushCache();

		clearBeansStates();
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;

		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}

		loadTab(tabName);
		
		if (tabName.equalsIgnoreCase("eventsTab")) {
			MbCaseEvents bean = (MbCaseEvents) ManagedBeanWrapper
					.getManagedBean("MbCaseEvents");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("checksTab")) {
			MbFrpChecks bean = (MbFrpChecks) ManagedBeanWrapper
					.getManagedBean("MbFrpChecks");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("suitesTab")) {
			MbSuiteCases bean = (MbSuiteCases) ManagedBeanWrapper
					.getManagedBean("MbSuiteCases");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public String getSectionId() {
		return SectionIdConstants.FRAU_PREVENTION_CASES;
	}
	
	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (_activeCase == null || _activeCase.getId() == null)
			return;

		if (tab.equalsIgnoreCase("suitesTab")) {
			MbSuiteCases suiteCases = (MbSuiteCases) ManagedBeanWrapper
					.getManagedBean("MbSuiteCases");
			suiteCases.fullCleanBean();
			suiteCases.getFilter().setCaseId(_activeCase.getId());
			suiteCases.getFilter().setCaseName(_activeCase.getLabel());
			suiteCases.setBlockCase(true);
			suiteCases.search();
		} else if (tab.equalsIgnoreCase("eventsTab")) {
			MbCaseEvents caseEvents = (MbCaseEvents) ManagedBeanWrapper
					.getManagedBean("MbCaseEvents");
			caseEvents.fullCleanBean();
			caseEvents.getFilter().setCaseId(_activeCase.getId());
			caseEvents.search();
		} else if (tab.equalsIgnoreCase("checksTab")) {
			MbFrpChecks checks = (MbFrpChecks) ManagedBeanWrapper.getManagedBean("MbFrpChecks");
			checks.fullCleanBean();
			checks.getFilter().setCaseId(_activeCase.getId());
			checks.setInstId(_activeCase.getInstId());
			checks.search();
		}

		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}

	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		rerenderList.add(tabName);
		return rerenderList;
	}

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}

	public void clearLoadedTabs() {
		loadedTabs.clear();
	}

	public void changeLanguage(ValueChangeEvent checkGroup) {
		curLang = (String) checkGroup.getNewValue();
		detailCase = getNodeByLang(detailCase.getId(), curLang);
	}
	
	public Case getNodeByLang(Integer id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id.toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Case[] checkGroups = _fraudDao.getCases(userSessionId, params);
			if (checkGroups != null && checkGroups.length > 0) {
				return checkGroups[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
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
	
	public void confirmEditLanguage() {
		curLang = newCase.getLang();
		Case tmp = getNodeByLang(newCase.getId(), newCase.getLang());
		if (tmp != null) {
			newCase.setLabel(tmp.getLabel());
			newCase.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public Case getDetailCase() {
		return detailCase;
	}

	public void setDetailCase(Case detailCase) {
		this.detailCase = detailCase;
	}

}
