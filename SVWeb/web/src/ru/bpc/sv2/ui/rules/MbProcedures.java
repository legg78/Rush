package ru.bpc.sv2.ui.rules;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.Procedure;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbProcedures")
public class MbProcedures extends AbstractBean{
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("RULES");

	private static String COMPONENT_ID = "1045:proceduresTable";

	private RulesDao _rulesDao = new RulesDao();

	private Procedure procedureFilter;
	private List<String> rerenderList;
	
	private final DaoDataModel<Procedure> _procedureSource;
	private final TableRowSelection<Procedure> _itemSelection;
	private Procedure _activeProcedure;
	private Procedure newProcedure;
	private Procedure detailProcedure;

	private MbProcedureSess sessBean;
	private String tabName;

	public MbProcedures() {
		pageLink = "rules|procedures";
		sessBean = (MbProcedureSess) ManagedBeanWrapper.getManagedBean("MbProcedureSess");
		tabName = "detailsTab";
		thisBackLink = "rules|procedures";

		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		if (restoreBean != null && restoreBean) {
			_activeProcedure = sessBean.getProcedure();
			if (_activeProcedure != null) {
				try {
					detailProcedure = (Procedure) _activeProcedure.clone();
				} catch (CloneNotSupportedException e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
			}
			procedureFilter = sessBean.getFilter();
			tabName = sessBean.getTabName();
			rowsNum = sessBean.getRowsNum();
			pageNumber = sessBean.getPageNum();
			searching = true;
			setBeans(true);
			FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
		}

		_procedureSource = new DaoDataModel<Procedure>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Procedure[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Procedure[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getProcedures(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Procedure[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getProceduresCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Procedure>(null, _procedureSource);
	}

	public DaoDataModel<Procedure> getProcedures() {
		return _procedureSource;
	}

	public Procedure getActiveProcedure() {
		return _activeProcedure;
	}

	public void setActiveProcedure(Procedure activeProcedure) {
		_activeProcedure = activeProcedure;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeProcedure == null && _procedureSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeProcedure != null && _procedureSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeProcedure.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeProcedure = _itemSelection.getSingleSelection();
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
					&& !_itemSelection.getSingleSelection().getId().equals(_activeProcedure.getId())) {
				changeSelect = true;
			}
			_activeProcedure = _itemSelection.getSingleSelection();
			if (_activeProcedure != null) {
				setBeans();
				if (changeSelect) {
					detailProcedure = (Procedure) _activeProcedure.clone();
				}
			}
	
			sessBean.setProcedure(_activeProcedure);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_procedureSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeProcedure = (Procedure) _procedureSource.getRowData();
		selection.addKey(_activeProcedure.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeProcedure != null) {
			setBeans();
			detailProcedure = (Procedure) _activeProcedure.clone();
		}

		sessBean.setProcedure(_activeProcedure);
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		sessBean.setTabName(tabName);
		
		if (tabName.equalsIgnoreCase("procedureParamsTab")) {
			MbProcedureParams bean = (MbProcedureParams) ManagedBeanWrapper
					.getManagedBean("MbProcedureParams");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_PROCESSING_PROCEDURE;
	}

	private void setBeans() {
		setBeans(false);		
	}
	
	private void setBeans(boolean restoreState) {
		MbProcedureParams procParamsBean = (MbProcedureParams) ManagedBeanWrapper
				.getManagedBean("MbProcedureParams");

		procParamsBean.setProcedureId(_activeProcedure.getId());
		procParamsBean.setBackLink(thisBackLink);
		if (restoreState) {
			procParamsBean.restoreBean();
		} else {
			procParamsBean.search();
		}
		
		sessBean.setProcedure(_activeProcedure);
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
		sessBean.setRowsNum(rowsNum);
	}

	public void setPageNumber(int pageNumber) {
		sessBean.setPageNum(pageNumber);
		this.pageNumber = pageNumber;
	}

	public void search() {
		clearBean();
		searching = true;
		sessBean.setFilter(getFilter());
		// reset dependent bean
		// resetBalanceType();
	}

	public void clearFilter() {
		procedureFilter = new Procedure();

		clearBean();
		searching = false;
	}

	public void setFilters() {
		procedureFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;

		if (procedureFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(procedureFilter.getId().toString());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (procedureFilter.getProcedureName() != null
				&& procedureFilter.getProcedureName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("procedureName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(procedureFilter.getProcedureName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (procedureFilter.getName() != null && procedureFilter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(procedureFilter.getName().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (procedureFilter.getCategory() != null && !procedureFilter.getCategory().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("category");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(procedureFilter.getCategory());
			filters.add(paramFilter);
		}
	}

	public Procedure getFilter() {
		if (procedureFilter == null) {
			procedureFilter = new Procedure();
		}
		return procedureFilter;
	}

	public void setFilter(Procedure procedureFilter) {
		this.procedureFilter = procedureFilter;
	}

	public void add() {
		curMode = NEW_MODE;
		newProcedure = new Procedure();
		newProcedure.setLang(userLang);
		curLang = newProcedure.getLang();
	}

	public void edit() {
		curMode = EDIT_MODE;
		try {
			newProcedure = detailProcedure.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newProcedure = _activeProcedure;
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newProcedure = _rulesDao.addProcedure(userSessionId, newProcedure);
				detailProcedure = (Procedure) newProcedure.clone();
				_itemSelection.addNewObjectToList(newProcedure);
			} else {
				newProcedure = _rulesDao.modifyProcedure(userSessionId, newProcedure);
				detailProcedure = (Procedure) newProcedure.clone();
				if (!userLang.equals(newProcedure.getLang())) {
					newProcedure = getNodeByLang(_activeProcedure.getId(), userLang);
				}
				_procedureSource.replaceObject(_activeProcedure, newProcedure);
			}
			_activeProcedure = newProcedure;
			setBeans();
			curMode = VIEW_MODE;

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_rulesDao.deleteProcedure(userSessionId, _activeProcedure);

			_activeProcedure = _itemSelection.removeObjectFromList(_activeProcedure);
			if (_activeProcedure == null) {
				clearBean();
			} else {
				setBeans();
				detailProcedure = (Procedure) _activeProcedure.clone();
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

	public ArrayList<SelectItem> getAllAccountTypes() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
	}

	public void clearBean() {
		// search using new criteria
		_procedureSource.flushCache();

		// reset selection
		_itemSelection.clearSelection();
		_activeProcedure = null;
		detailProcedure = null;

		MbProcedureParams paramsBean = (MbProcedureParams) ManagedBeanWrapper
				.getManagedBean("MbProcedureParams");
		paramsBean.setProcedureId(null);
		paramsBean.clearBean();
	}

	public Procedure getNewProcedure() {
		return newProcedure;
	}

	public void setNewProcedure(Procedure newProcedure) {
		this.newProcedure = newProcedure;
	}

	public ArrayList<SelectItem> getCategories() {
		return getDictUtils().getArticles(DictNames.RULE_CATEGORIES, true, false);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailProcedure = getNodeByLang(detailProcedure.getId(), curLang);
	}
	
	public Procedure getNodeByLang(Integer id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(id.toString());
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
			Procedure[] procs = _rulesDao.getProcedures(userSessionId, params);
			if (procs != null && procs.length > 0) {
				return procs[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public void confirmEditLanguage() {
		curLang = newProcedure.getLang();
		Procedure tmp = getNodeByLang(newProcedure.getId(), newProcedure.getLang());
		if (tmp != null) {
			newProcedure.setName(tmp.getName());
			newProcedure.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();		
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	public Procedure getDetailProcedure() {
		return detailProcedure;
	}

	public void setDetailProcedure(Procedure detailProcedure) {
		this.detailProcedure = detailProcedure;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				procedureFilter = new Procedure();
				if (filterRec.get("procedureName") != null) {
					procedureFilter.setProcedureName(filterRec.get("procedureName"));
				}
				if (filterRec.get("category") != null) {
					procedureFilter.setCategory(filterRec.get("category"));
				}
				if (filterRec.get("name") != null) {
					procedureFilter.setName(filterRec.get("name"));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			procedureFilter = getFilter();
			if (procedureFilter.getProcedureName() != null) {
				filterRec.put("procedureName", procedureFilter.getProcedureName());
			}
			if (procedureFilter.getCategory() != null) {
				filterRec.put("category", procedureFilter.getCategory());
			}
			if (procedureFilter.getName() != null) {
				filterRec.put("name", procedureFilter.getName());
			}
			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
}
