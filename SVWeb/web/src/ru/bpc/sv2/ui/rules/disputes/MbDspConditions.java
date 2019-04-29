package ru.bpc.sv2.ui.rules.disputes;

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
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.DspCondition;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbDspConditions")
public class MbDspConditions extends AbstractBean {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("RULES");

	private static String COMPONENT_ID = "1090:dspConditionsTable";

	private RulesDao _rulesDao = new RulesDao();


	private DspCondition filter;
	private DspCondition _activeDspCondition;
	private DspCondition newDspCondition;
	private DspCondition detailDspCondition;
	private ArrayList<SelectItem> scaleTypes;
	private ArrayList<SelectItem> modifiers;
	private String scaleType;
	private boolean updateModifiers;

	private final DaoDataModel<DspCondition> _dspConditionSource;

	private final TableRowSelection<DspCondition> _itemSelection;

	public MbDspConditions() {
		
		thisBackLink = "dispute|conditions";
		
		_dspConditionSource = new DaoDataModel<DspCondition>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected DspCondition[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new DspCondition[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getDspConditions(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new DspCondition[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getDspConditionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<DspCondition>(null, _dspConditionSource);

		
	}
	

	public DaoDataModel<DspCondition> getdspConditions() {
		return _dspConditionSource;
	}

	public DspCondition getActiveDspCondition() {
		return _activeDspCondition;
	}

	public void setActiveModScale(DspCondition activeDspCondition) {
		_activeDspCondition = activeDspCondition;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeDspCondition == null && _dspConditionSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeDspCondition != null && _dspConditionSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeDspCondition.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeDspCondition = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeDspCondition = _itemSelection.getSingleSelection();
		if(_activeDspCondition != null){
			try {
				detailDspCondition = (DspCondition)_activeDspCondition.clone();
			} catch (CloneNotSupportedException e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_dspConditionSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeDspCondition = (DspCondition) _dspConditionSource.getRowData();
		selection.addKey(_activeDspCondition.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeDspCondition != null) {
			detailDspCondition = (DspCondition) _activeDspCondition.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */

	public void clearFilter() {
		filter = null;
		curLang = userLang;
		clearBean();

		searching = false;

	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = null;

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		
		if (filter.getName() != null
				&& filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if(filter.getScaleType() != null){
			paramFilter = new Filter();
			paramFilter.setElement("scaleType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getScaleType());
			filters.add(paramFilter);
		}

	}

	public DspCondition getFilter() {
		if (filter == null) {
			filter = new DspCondition();
		}
		return filter;
	}

	public void setFilter(DspCondition filter) {
		this.filter = filter;
	}

	public void add() {
		newDspCondition = new DspCondition();
		newDspCondition.setLang(userLang);
		curLang = newDspCondition.getLang();
		curMode = NEW_MODE;
//		scaleType = null;
		modifiers = new ArrayList<SelectItem>();
	}

	public void edit() {
		try {
			newDspCondition = (DspCondition) detailDspCondition.clone();
			scaleType = newDspCondition.getScaleType();
			updateModifiers = true;
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {

		try {
			if (isEditMode()) {
				newDspCondition = _rulesDao.modifyDspCondition(userSessionId, newDspCondition);
				detailDspCondition = (DspCondition) newDspCondition.clone();
				if (!userLang.equals(newDspCondition.getLang())) {
					newDspCondition = getNodeByLang(_activeDspCondition.getId(), userLang);
				}
				_dspConditionSource.replaceObject(_activeDspCondition, newDspCondition);
			} else {
				newDspCondition = _rulesDao.addDspCondition(userSessionId, newDspCondition);
				detailDspCondition = (DspCondition) newDspCondition.clone();
				_itemSelection.addNewObjectToList(newDspCondition);
			}
			_activeDspCondition = newDspCondition;
			curMode = VIEW_MODE;

			// TODO: i18n
			FacesUtils.addMessageInfo("DspCondition has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}

	}

	public void delete() {

		try {
			_rulesDao.deleteDspCondition(userSessionId, _activeDspCondition);
			curMode = VIEW_MODE;

			_activeDspCondition = _itemSelection.removeObjectFromList(_activeDspCondition);
			if (_activeDspCondition == null) {
				clearBean();
			} else {
				detailDspCondition = (DspCondition) _activeDspCondition.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}

	}
	
	public void close() {
		curMode = VIEW_MODE;

	}

	public DspCondition getNewDspCondition() {
		if (newDspCondition == null) {
			newDspCondition = new DspCondition();
		}
		return newDspCondition;
	}

	public void setNewDspCondition(DspCondition newDspCondition) {
		this.newDspCondition = newDspCondition;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailDspCondition = getNodeByLang(detailDspCondition.getId(), curLang);
	}
	
	public DspCondition getNodeByLang(Integer id, String lang) {
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
			DspCondition[] dspCons = _rulesDao.getDspConditions(userSessionId, params);
			if (dspCons != null && dspCons.length > 0) {
				return dspCons[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeDspCondition = null;
		detailDspCondition = null;
		_dspConditionSource.flushCache();
	}

	public String getSectionId() {
		return SectionIdConstants.OPERATION_MODIFIER_SCALE;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public DspCondition getDetailDspCondition() {
		return detailDspCondition;
	}

	public void setDetailDspCondition(DspCondition detailDspCondition) {
		this.detailDspCondition = detailDspCondition;
	}
	
	public ArrayList<SelectItem> getScaleTypes() {
		if (scaleTypes == null) {
			scaleTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.SCALE_TYPE);
		}
		return scaleTypes;
	}

	public ArrayList<SelectItem> getModifiers(){
		if(scaleType == null){
			modifiers = new ArrayList<SelectItem>();
			return modifiers;
		}
		if (modifiers == null || updateModifiers) {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("SCALE_TYPE", scaleType);
			modifiers =  (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.MODIFIER_LIST, paramMap);
			updateModifiers = false;
		}		
		return modifiers;
	}
	
	public void changeScaleType(ValueChangeEvent event){
		scaleType = (String) event.getNewValue();
		updateModifiers = true;
	}
}
