package ru.bpc.sv2.ui.cmn;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.cmn.CmnParameter;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.scale.ScaleConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.CommunicationConstants;
import ru.bpc.sv2.rules.ModScale;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbCmnParameters" )
public class MbCmnParameters extends AbstractBean{

	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private CommunicationDao _cmnDao = new CommunicationDao();

	private RulesDao _rulesDao = new RulesDao();

	private CmnParameter parameterFilter;
	private CmnParameter newParameter;
	private Long standardId;
	private String standardType;
	
	private final String NETWORK_CLEARING_STANDARD = "STDT0201";
	private final String NETWORK_BASIC_STANDARD = "STDT0000";

	private final DaoDataModel<CmnParameter> _parameterSource;
	private final TableRowSelection<CmnParameter> _itemSelection;
	private CmnParameter _activeParameter;

	private static String COMPONENT_ID = "parametersTable";
	private String tabName;
	private String parentSectionId;
	private ArrayList<SelectItem> dataTypes;

	public MbCmnParameters() {
		

		_parameterSource = new DaoDataModel<CmnParameter>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected CmnParameter[] loadDaoData(SelectionParams params) {
				if (standardId == null) {
					return new CmnParameter[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getCmnParameters(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CmnParameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (standardId == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getCmnParametersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CmnParameter>(null, _parameterSource);
	}

	public DaoDataModel<CmnParameter> getParameters() {
		return _parameterSource;
	}

	public CmnParameter getActiveParameter() {
		return _activeParameter;
	}

	public void setActiveParameter(CmnParameter activeParameter) {
		_activeParameter = activeParameter;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeParameter = _itemSelection.getSingleSelection();
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		clearBean();
		parameterFilter = new CmnParameter();
		searching = false;
	}

	public void setFilters() {
		parameterFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("standardId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(standardId.toString());
		filters.add(paramFilter);

		if (parameterFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(parameterFilter.getId() + "%");
			filters.add(paramFilter);
		}

		if (parameterFilter.getSystemName() != null
				&& parameterFilter.getSystemName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(parameterFilter.getSystemName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newParameter = new CmnParameter();
		newParameter.setLang(userLang);
		newParameter.setStandardId(standardId);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newParameter = (CmnParameter) _activeParameter.clone();
		} catch (CloneNotSupportedException e) {
			newParameter = _activeParameter;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void delete() {
		try {
			_cmnDao.deleteCmnParameter(userSessionId, _activeParameter.getId());
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
					"parameter_deleted", "(id = " + _activeParameter.getId() + ")");

			_activeParameter = _itemSelection.removeObjectFromList(_activeParameter);
			if (_activeParameter == null) {
				clearBean();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newParameter = _cmnDao.addCmnParameter(userSessionId, newParameter);
				_itemSelection.addNewObjectToList(newParameter);	
			} else {
				newParameter = _cmnDao.editCmnParameter(userSessionId, newParameter);
				_parameterSource.replaceObject(_activeParameter, newParameter);		
			}
			_activeParameter = newParameter;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
					"parameter_saved"));
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
		newParameter = null;
	}

	public CmnParameter getFilter() {
		if (parameterFilter == null) {
			parameterFilter = new CmnParameter();
		}
		return parameterFilter;
	}

	public void setFilter(CmnParameter parameterFilter) {
		this.parameterFilter = parameterFilter;
	}

	public CmnParameter getNewParameter() {
		if (newParameter == null) {
			newParameter = new CmnParameter();
		}
		return newParameter;
	}

	public void setNewParameter(CmnParameter newParameter) {
		this.newParameter = newParameter;
	}

	public void clearBean() {
		_parameterSource.flushCache();
		_itemSelection.clearSelection();
		_activeParameter = null;
		curLang = userLang;
	}

	public void fullCleanBean() {
		clearFilter();
		standardId = null;
		standardType = null;
	}
	
	public ArrayList<SelectItem> getAppPlugins() {
		return getDictUtils().getArticles(DictNames.APPLICATION_PLUGIN, true, false);
	}

	public List<SelectItem> getCmnLovs() {
		List<SelectItem> lovs = getDictUtils().getLov(LovConstants.LOV_COMMUNICATION_PARAMS);
		return lovs;
	}

	public Long getStandardId() {
		return standardId;
	}

	public void setStandardId(Long standardId) {
		this.standardId = standardId;
	}

	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_parameterSource.flushCache();
	}

	public void disableLov() {
		if (getNewParameter().isDate()) {
			getNewParameter().setLovId(null);
		}
	}
	
	public List<SelectItem> getEntityTypes() {
		if (NETWORK_CLEARING_STANDARD.equals(standardType) ||
                CommunicationConstants.NETWORK_CMN_STANDARD.equals(standardType)) {
			return getDictUtils().getLov(LovConstants.CMN_PARAM_ENTITY_TYPES);
		} else if (CommunicationConstants.TERMINAL_CMN_STANDARD.equals(standardType) ||
				NETWORK_BASIC_STANDARD.equalsIgnoreCase(standardType)) {
            return getDictUtils().getLov(LovConstants.TERMINAL_ENTITY_TYPES);
        } else if (CommunicationConstants.HSM_CMN_STANDARD.equals(standardType)) {
            return getDictUtils().getLov(LovConstants.HSM_ENTITY_TYPE);
        } else {
			return new ArrayList<SelectItem>(0);
		}
	}

	public String getStandardType() {
		return standardType;
	}

	public void setStandardType(String standardType) {
		this.standardType = standardType;
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newParameter.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newParameter.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			CmnParameter[] parameters = _cmnDao.getCmnParameters(userSessionId, params);
			if (parameters != null && parameters.length > 0) {
				newParameter = parameters[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public List<SelectItem> getLovValues() {
		if (newParameter == null || newParameter.getLovId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		return getDictUtils().getLov(newParameter.getLovId()); 
	}

	public boolean isDateValue() {
		return newParameter == null ? false : DataTypes.DATE.equals(newParameter.getDataType());
	}

	public boolean isCharValue() {
		return newParameter == null ? true : DataTypes.CHAR.equals(newParameter.getDataType());
	}

	public boolean isNumberValue() {
		return newParameter == null ? false : DataTypes.NUMBER.equals(newParameter.getDataType());
	}

	public ArrayList<SelectItem> getScales() {
		if (newParameter == null) {
			return new ArrayList<SelectItem>(0);
		}

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);

		Filter[] filters = new Filter[3];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("scaleTypeList");
		List<String> paramScale = new ArrayList<String>();
		paramScale.add(ScaleConstants.COMM_PARAMS_SCALE);
		paramScale.add(ScaleConstants.STDR_PARAMS_SCALE);
		filters[1].setValueList(paramScale);
		filters[2] = new Filter();
		filters[2].setElement("instId");
		filters[2].setValue(SystemConstants.DEFAULT_INSTITUTION);
		params.setFilters(filters);

		ModScale[] scales;
		try {
			scales = _rulesDao.getModScales(userSessionId, params);
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			return new ArrayList<SelectItem>(0);
		}

		ArrayList<SelectItem> items = new ArrayList<SelectItem>(scales.length);
		for (ModScale scale: scales) {
			items.add(new SelectItem(scale.getId(), scale.getName()));
		}
		return items;
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

}
