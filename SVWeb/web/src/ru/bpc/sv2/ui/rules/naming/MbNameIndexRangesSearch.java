package ru.bpc.sv2.ui.rules.naming;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.naming.NameIndexRange;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbNameIndexRangesSearch")
public class MbNameIndexRangesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("RULES");

	private static String COMPONENT_ID = "1210:rangesTable";

	private RulesDao _rulesDao = new RulesDao();
	
	

	private final String RANDOM_ALGORITHM = "IRAGRNDM"; // see database
	private final String SEQUENTIAL_ALGORITHM = "IRAGSQNC";
	private final String RANDOM = "IRAGRNGR";
	private final String SEQUENTIAL = "IRAGRNGS";

	private ArrayList<SelectItem> institutions;
	
	private NameIndexRange filter;
	private NameIndexRange _activeIndexRange;
	private NameIndexRange newIndexRange;

	private String backLink;
	private boolean selectMode;
	private MbNameIndexRanges rangeBean;

	private final DaoDataModel<NameIndexRange> _rangesSource;

	private final TableRowSelection<NameIndexRange> _itemSelection;

	public MbNameIndexRangesSearch() {
		pageLink = "rules|naming|ranges";
		rangeBean = (MbNameIndexRanges) ManagedBeanWrapper.getManagedBean("MbNameIndexRanges");

		_rangesSource = new DaoDataModel<NameIndexRange>() {
			@Override
			protected NameIndexRange[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new NameIndexRange[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getNameIndexRanges(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new NameIndexRange[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getNameIndexRangesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<NameIndexRange>(null, _rangesSource);
	}

	public DaoDataModel<NameIndexRange> getIndexRanges() {
		return _rangesSource;
	}

	public NameIndexRange getActiveIndexRange() {
		return _activeIndexRange;
	}

	public void setActiveIndexRange(NameIndexRange activeIndexRange) {
		_activeIndexRange = activeIndexRange;
	}

	public SimpleSelection getItemSelection() {
		if (_activeIndexRange == null && _rangesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeIndexRange != null && _rangesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeIndexRange.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeIndexRange = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_rangesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeIndexRange = (NameIndexRange) _rangesSource.getRowData();
		selection.addKey(_activeIndexRange.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeIndexRange != null) {
			setBeans();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeIndexRange = _itemSelection.getSingleSelection();
		if (_activeIndexRange != null) {
			setBeans();
		}
	}

	public void setBeans() {
		MbNameIndexPools pools = (MbNameIndexPools) ManagedBeanWrapper.getManagedBean("MbNameIndexPools");
		pools.clearFilter();
		pools.getFilter().setIndexRangeId(_activeIndexRange.getId());
		pools.getFilter().setHighValue(_activeIndexRange.getHighValue());
		pools.getFilter().setLowValue(_activeIndexRange.getLowValue());
		pools.search();
	}
	
	public void clearBeansStates() {
		MbNameIndexPools pools = (MbNameIndexPools) ManagedBeanWrapper.getManagedBean("MbNameIndexPools");
		pools.clearFilter();
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public NameIndexRange getFilter() {
		if (filter == null) {
			filter = new NameIndexRange();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(NameIndexRange filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
		if (filter.getLowValue() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("lowValue");
			paramFilter.setValue(filter.getLowValue().toString());
			filters.add(paramFilter);
		}
		if (filter.getHighValue() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("highValue");
			paramFilter.setValue(filter.getHighValue().toString());
			filters.add(paramFilter);
		}
		if (filter.getAlgorithm() != null && filter.getAlgorithm().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("algorithm");
			paramFilter.setValue(filter.getAlgorithm());
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newIndexRange = new NameIndexRange();
		newIndexRange.setLang(userLang);
		
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newIndexRange = (NameIndexRange) _activeIndexRange.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newIndexRange = _activeIndexRange;
		}
		curMode = EDIT_MODE;
	}

	public void saveRange() {
		try {
			checkValues();

			newIndexRange = _rulesDao.syncNameIndexRange(userSessionId, newIndexRange);

			if (isEditMode()) {
				_rangesSource.replaceObject(_activeIndexRange, newIndexRange);
			} else {
				_itemSelection.addNewObjectToList(newIndexRange);
			}
			_activeIndexRange = newIndexRange;
//			FacesContext.getCurrentInstance().addMessage("formatResultMessages", new FacesMessage("Entry set has been saved.2"));
			setBeans();
			FacesUtils.addMessageInfo("Modparam has been saved.");
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_rulesDao.deleteNameIndexRange(userSessionId, _activeIndexRange);
			_activeIndexRange = _itemSelection.removeObjectFromList(_activeIndexRange);
			if (_activeIndexRange == null) {
				clearState();
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

	public void cancelRange() {
		curMode = VIEW_MODE;
	}

	public void checkValues() throws Exception {
		if (newIndexRange.getLowValue() > newIndexRange.getHighValue()) {
			throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
					"low_value_greater"));
		}
		if (!isRandomAlgorithm() && (newIndexRange.getCurrentValue() != null 
				&& (newIndexRange.getCurrentValue() < newIndexRange.getLowValue() || newIndexRange
						.getCurrentValue() > newIndexRange.getHighValue()))) {
			throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
					"curr_value_not_in_range"));
		}
	}

	public NameIndexRange getNewIndexRange() {
		if (newIndexRange == null) {
			newIndexRange = new NameIndexRange();
		}
		return newIndexRange;
	}

	public void setNewIndexRange(NameIndexRange newIndexRange) {
		this.newIndexRange = newIndexRange;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeIndexRange = null;
		_rangesSource.flushCache();
		
		clearBeansStates();
	}

	public ArrayList<SelectItem> getAlgorithms() {
		ArrayList<SelectItem> items = getDictUtils().getArticles(DictNames.INDEX_RANGE_ALGORITHMS,
				false, false);
		return items;
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
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeIndexRange.getId().toString());
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
			NameIndexRange[] ranges = _rulesDao.getNameIndexRanges(userSessionId, params);
			if (ranges != null && ranges.length > 0) {
				_activeIndexRange = ranges[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
	}

	public String select() {
		try {
//			List<ModParam> selectedParams = _itemSelection.getMultiSelection();
//			for (ModParam param : selectedParams) {
//				int scaleSeqNum = _rulesDao.includeParamInScale( userSessionId, param.getId(), modScale.getId(), modScale.getSeqNum());
//			}
			rangeBean.setActiveIndexRange(_activeIndexRange);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return backLink;
	}

	public String cancelSelect() {
		return backLink;
	}

	public boolean isRandomAlgorithm() {
		return RANDOM_ALGORITHM.equals(newIndexRange.getAlgorithm());
	}
	
	public boolean isSequentialAlgorithm(){
		return SEQUENTIAL_ALGORITHM.equals(newIndexRange.getAlgorithm());
	}
	
	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}
	
	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES);
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newIndexRange.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newIndexRange.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			NameIndexRange[] ranges = _rulesDao.getNameIndexRanges(userSessionId, params);
			if (ranges != null && ranges.length > 0) {
				newIndexRange = ranges[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}
	
	public boolean isRandom(){
		return RANDOM.equalsIgnoreCase(newIndexRange.getAlgorithm());
	}
	
	public boolean isSequential(){
		return SEQUENTIAL.equalsIgnoreCase(newIndexRange.getAlgorithm());
	}
	
	public boolean getAlg(){
		return true;
	}
	
	public void setAlg(boolean value){
		
	}

}
