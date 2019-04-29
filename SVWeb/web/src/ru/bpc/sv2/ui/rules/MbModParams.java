package ru.bpc.sv2.ui.rules;

import java.util.ArrayList;
import java.util.Arrays;
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
import ru.bpc.sv2.rules.ModParam;
import ru.bpc.sv2.rules.ModScale;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbModParams")
public class MbModParams extends AbstractBean {
	private static final Logger logger = Logger.getLogger("RULES");

	private static String COMPONENT_ID = "1091:modParamsTable";

	private RulesDao _rulesDao = new RulesDao();

	private ModParam modParamFilter;
	private ModParam _activeModParam;
	private ModParam newModParam;

	private String backLink;
	private ModScale modScale;
	private boolean selectMode;
	private String tabName;

	private final DaoDataModel<ModParam> _modParamSource;

	private final TableRowSelection<ModParam> _itemSelection;
	private ArrayList<SelectItem> dataTypes;

	public MbModParams() {
		
		pageLink = "rules|params";
		_modParamSource = new DaoDataModel<ModParam>() {
			@Override
			protected ModParam[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ModParam[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getModParams(userSessionId, params, curLang);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ModParam[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getModParamsCount(userSessionId, params, curLang);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ModParam>(null, _modParamSource);
		restoreFilter();
	}
	
	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbModParams");
		clearFilter();
		if (queueFilter==null)
			return;
		if (queueFilter.containsKey("selectedMod")){
			setSelectMode((Boolean)queueFilter.get("selectedMod"));
		}
		
		if (queueFilter.containsKey("backLink")){
			setBackLink((String)queueFilter.get("backLink"));
		}
		
		if (queueFilter.containsKey("modScale")){
			setModScale((ModScale)queueFilter.get("modScale"));
		}
		
		search();
	}

	public DaoDataModel<ModParam> getModParams() {
		return _modParamSource;
	}

	public ModParam getActiveModParam() {
		return _activeModParam;
	}

	public void setActiveModParam(ModParam activeModParam) {
		_activeModParam = activeModParam;
	}

	public SimpleSelection getItemSelection() {
		if (_activeModParam == null && _modParamSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeModParam != null && _modParamSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeModParam.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeModParam = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeModParam = _itemSelection.getSingleSelection();
		if (_activeModParam != null) {
			// invoke setInfo() if needed
		}
	}

	public void setFirstRowActive() {
		_modParamSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeModParam = (ModParam) _modParamSource.getRowData();
		selection.addKey(_activeModParam.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeModParam != null) {
			// setInfo();
		}
	}

	public String search() {
		clearState();
		searching = true;
		return "";
	}

	public void clearFilter() {
		modParamFilter = new ModParam();

		clearState();
		searching = false;
	}

	public ModParam getFilter() {
		if (modParamFilter == null)
			modParamFilter = new ModParam();
		return modParamFilter;
	}

	public void setFilter(ModParam filter) {
		this.modParamFilter = filter;
	}

	private void setFilters() {
		modParamFilter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (modParamFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(modParamFilter.getId() + "%");
			filters.add(paramFilter);
		}

		if (modParamFilter.getDataType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("dataType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(modParamFilter.getDataType());
			filters.add(paramFilter);
		}

		if (modParamFilter.getSystemName() != null &&
				modParamFilter.getSystemName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(modParamFilter.getSystemName().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (modParamFilter.getDescription() != null &&
				modParamFilter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("fullDesc");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(modParamFilter.getDescription().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (modParamFilter.getName() != null && modParamFilter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("shortDesc");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(modParamFilter.getName().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (modScale != null && modScale.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("excludeScale");
			paramFilter.setValue(modScale.getId());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newModParam = new ModParam();
		newModParam.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newModParam = (ModParam) _activeModParam.clone();
		} catch (CloneNotSupportedException e) {
			newModParam = _activeModParam;
		}
		curMode = EDIT_MODE;
	}

	public String select() {
		if ("rules|procedures".equals(backLink)) {
			MbProcedureParams procedureParams = (MbProcedureParams) ManagedBeanWrapper
					.getManagedBean("MbProcedureParams");
			procedureParams.setModParam(_activeModParam);
			procedureParams.restoreBean();
		} else {
			try {
				List<ModParam> selectedParams = _itemSelection.getMultiSelection();
				for (ModParam param : selectedParams) {
					int scaleSeqNum = _rulesDao.includeParamInScale(userSessionId, param.getId(),
							modScale.getId(), modScale.getSeqNum());
					modScale.setSeqNum(scaleSeqNum);
				}
				// FacesContext.getCurrentInstance().addMessage("modParamResultMessages",
				// new FacesMessage("Entry set has been saved.2"));
				FacesUtils.addMessageInfo("Modparam has been added.");
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public String cancelSelect() {
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newModParam = _rulesDao.modifyModParam(userSessionId, newModParam);

				_modParamSource.replaceObject(_activeModParam, newModParam);
			} else if (isNewMode()) {
				newModParam = _rulesDao.addModParam(userSessionId, newModParam);
				_itemSelection.addNewObjectToList(newModParam);
			}
			_activeModParam = newModParam;
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo("Modparam has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_rulesDao.deleteModParam(userSessionId, _activeModParam.getId());
			curMode = VIEW_MODE;

			_activeModParam = _itemSelection.removeObjectFromList(_activeModParam);
			if (_activeModParam == null) {
				clearState();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ModParam getNewModParam() {
		if (newModParam == null) {
			newModParam = new ModParam();
		}
		return newModParam;
	}

	public void setNewModParam(ModParam newModParam) {
		this.newModParam = newModParam;
	}

	public void clearState() {
		if (_activeModParam != null) {
			if (_itemSelection != null) {
				_itemSelection.clearSelection();
			}
			_activeModParam = null;
		}

		_modParamSource.flushCache();
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

	public ModScale getModScale() {
		return modScale;
	}

	public void setModScale(ModScale modScale) {
		this.modScale = modScale;
	}

	public List<SelectItem> getLovsList() {
		if (getNewModParam().getDataType() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("DATA_TYPE", getNewModParam().getDataType());
		
		String where = "code not in (" + LovConstants.LOVS_LOV + ", "
				+ LovConstants.NOT_PARAMETRIZED_LOVS + ", " + LovConstants.PARAMETRIZED_LOVS + ")";

		return getDictUtils().getLov(LovConstants.NOT_PARAMETRIZED_LOVS, params, Arrays.asList(where));
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeModParam.getId().toString());
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
			ModParam[] modParams = _rulesDao.getModParams(userSessionId, params, curLang);
			if (modParams != null && modParams.length > 0) {
				_activeModParam = modParams[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public List<SelectItem> getLovValues() {
		if (newModParam != null && newModParam.getLovId() != null) {
			return getDictUtils().getLov(newModParam.getLovId());
		} else {
			return new ArrayList<SelectItem>(0);
		}
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newModParam.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newModParam.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ModParam[] modParams = _rulesDao.getModParams(userSessionId, params, curLang);
			if (modParams != null && modParams.length > 0) {
				newModParam = modParams[0];
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

}
