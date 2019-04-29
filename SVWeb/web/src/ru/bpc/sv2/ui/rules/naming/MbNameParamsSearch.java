package ru.bpc.sv2.ui.rules.naming;

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

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.naming.NameBaseParam;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean(name = "MbNameParamsSearch")
public class MbNameParamsSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;
	
	private static final Logger logger = Logger.getLogger("RULES");
	
	private static String COMPONENT_ID = "1192:paramsTable";

	private RulesDao _rulesDao = new RulesDao();

    private NameBaseParam filter;
    private NameBaseParam _activeBaseParam;
    private NameBaseParam newBaseParam;
    
	private String backLink;
	private boolean selectMode;
	
	private final DaoDataModel<NameBaseParam> _paramsSource;

	private final TableRowSelection<NameBaseParam> _itemSelection;
	private ArrayList<SelectItem> dataTypes;

	public MbNameParamsSearch() {
		pageLink = "rules|naming|params";
		_paramsSource = new DaoDataModel<NameBaseParam>() {
			private static final long serialVersionUID = 1L;
			
			@Override
			protected NameBaseParam[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new NameBaseParam[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getNameBaseParams( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new NameBaseParam[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getNameBaseParamsCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<NameBaseParam>( null, _paramsSource);
    }

    public DaoDataModel<NameBaseParam> getBaseParams() {
		return _paramsSource;
	}

	public NameBaseParam getActiveBaseParam() {
		return _activeBaseParam;
	}

	public void setActiveBaseParam(NameBaseParam activeBaseParam) {
		_activeBaseParam = activeBaseParam;
	}

	public SimpleSelection getItemSelection() {
		if (_activeBaseParam == null && _paramsSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeBaseParam != null && _paramsSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeBaseParam.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeBaseParam = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_paramsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeBaseParam = (NameBaseParam) _paramsSource.getRowData();
		selection.addKey(_activeBaseParam.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeBaseParam != null) {
//			setInfo();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection( selection );
		_activeBaseParam = _itemSelection.getSingleSelection();
		if (_activeBaseParam != null) {
			//setInfo();
		}
	}

	public void search() {
		clearState();
		searching = true;		
	}
	
	public void clearFilter() {
		filter = new NameBaseParam();
		
		clearState();
		searching = false;		
	}
	
	public NameBaseParam getFilter() {
		if (filter == null)
			filter = new NameBaseParam();
		return filter;
	}

	public void setFilter(NameBaseParam filter) {
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
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		
		if (filter.getEntityType() != null && filter.getEntityType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim()
					.toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
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
	}

	public void add() {
		newBaseParam = new NameBaseParam();
		newBaseParam.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newBaseParam = (NameBaseParam) _activeBaseParam.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newBaseParam = _activeBaseParam;
		}
		newBaseParam.setLang(curLang);
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			newBaseParam = _rulesDao.addNameBaseParam( userSessionId, newBaseParam);
			if (isEditMode()) {
				_paramsSource.replaceObject(_activeBaseParam, newBaseParam);
			} else {
				_itemSelection.addNewObjectToList(newBaseParam);
			}
			_activeBaseParam = newBaseParam;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public NameBaseParam getNewBaseParam() {
		if (newBaseParam == null) {
			newBaseParam = new NameBaseParam();
		}
		return newBaseParam;
	}

	public void setNewBaseParam(NameBaseParam newBaseParam) {
		this.newBaseParam = newBaseParam;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeBaseParam = null;			
		_paramsSource.flushCache();
	}

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES);
	}
	
	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public void changeLanguage(ValueChangeEvent event) {	
		curLang = (String)event.getNewValue();
		
		List<Filter> filtersList = new ArrayList<Filter>();
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeBaseParam.getId().toString());
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
			NameBaseParam[] baseParams = _rulesDao.getNameBaseParams( userSessionId, params);
			if (baseParams != null && baseParams.length > 0) {
				_activeBaseParam = baseParams[0];				
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}		
	}
	
	public String select() {
		try {
//			List<ModParam> selectedParams = _itemSelection.getMultiSelection();
//			for (ModParam param : selectedParams) {
//				int scaleSeqNum = _rulesDao.includeParamInScale( userSessionId, param.getId(), modScale.getId(), modScale.getSeqNum());
//			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
		return backLink;
	}

	public String cancelSelect() {
		return backLink;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new NameBaseParam();
				if (filterRec.get("entityType") != null) {
					filter.setEntityType(filterRec.get("entityType"));
				}
				if (filterRec.get("name") != null) {
					filter.setName(filterRec.get("name"));
				}
				if (filterRec.get("description") != null) {
					filter.setDescription(filterRec.get("description"));
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
			filter = getFilter();
			if (filter.getEntityType() != null) {
				filterRec.put("entityType", filter.getEntityType());
			}
			if (filter.getName() != null) {
				filterRec.put("name", filter.getName());
			}
			if (filter.getDescription() != null) {
				filterRec.put("description", filter.getDescription());
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
