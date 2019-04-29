package ru.bpc.sv2.ui.rules;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.ModParam;
import ru.bpc.sv2.rules.ModScale;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;

@ViewScoped
@ManagedBean (name = "MbModScaleParams")
public class MbModScaleParams extends AbstractBean {
	/**
	 * 
	 */
	private static final long serialVersionUID = 3378643317651879549L;

	private static final Logger logger = Logger.getLogger("RULES");

	private RulesDao _rulesDao = new RulesDao();

	private ModParam modParamFilter;
	private ModParam _activeModParam;
	private ModParam newModParam;

	private ModScale modScale;
	private MbModsSess sessBean;
	private String backLink;

	private final DaoDataModel<ModParam> _modParamSource;

	private final TableRowSelection<ModParam> _itemSelection;
	
	private static String COMPONENT_ID = "modParamsTable";
	private String tabName;
	private String parentSectionId;
	private ArrayList<SelectItem> dataTypes;

	public MbModScaleParams() {
		

		sessBean = (MbModsSess) ManagedBeanWrapper.getManagedBean("MbModsSess");

		_modParamSource = new DaoDataModel<ModParam>() {
			/**
			 * 
			 */
			private static final long serialVersionUID = -4289744374974551458L;

			@Override
			protected ModParam[] loadDaoData(SelectionParams params) {
				if (modScale == null) {
					return new ModParam[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getModParamsByScaleId(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ModParam[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (modScale == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getModParamsByScaleIdCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ModParam>(null, _modParamSource);
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

		sessBean.setActiveModParam(_activeModParam);
		sessBean.setParamsSelection(_itemSelection);
	}

	public void setFirstRowActive() {
		_modParamSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeModParam = (ModParam) _modParamSource.getRowData();
		selection.addKey(_activeModParam.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeModParam != null) {
//			setInfo();
		}
	}

	public void search() {
		clearState();

		sessBean.setParamsFilter(modParamFilter);
		searching = true;
	}

	public void clearFilter() {
		modParamFilter = new ModParam();
		clearState();
		curLang = userLang;

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

		Filter paramFilter;
		if (modScale != null && modScale.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("scaleId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(modScale.getId().toString());
			filters.add(paramFilter);
		}

		if (modParamFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(modParamFilter.getId().toString());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (modParamFilter.getDataType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("dataType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(modParamFilter.getDataType());
			filters.add(paramFilter);
		}

		if (modParamFilter.getName() != null && modParamFilter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(modParamFilter.getName().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void createAndAdd() {
		newModParam = new ModParam();
		curMode = CREATE_ADD_MODE;
	}

	public void edit() {
		try {
			newModParam = (ModParam) _activeModParam.clone();
		} catch (CloneNotSupportedException e) {
			newModParam = _activeModParam;
		}
		curMode = EDIT_MODE;
	}

	public String addToScale() {

		HashMap<String, Object> queqFilter = new HashMap<String, Object>();
		queqFilter.put("selectedMod", true);
		queqFilter.put("backLink", backLink);
		queqFilter.put("modScale", modScale);
		queqFilter.put("filter", getFilter());
		addFilterToQueue("MbModParams", queqFilter);
		Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		mbMenu.externalSelect("rules|params");
		return "rules|params";
	}

	public void removeFromScale() {
		try {
            int scaleSeqNum = _rulesDao.removeParamFromScale(userSessionId, _activeModParam.getId(),
					modScale.getId(), modScale.getSeqNum());
            modScale.setSeqNum(scaleSeqNum);
			_activeModParam = null;
			_modParamSource.flushCache();
//			FacesContext.getCurrentInstance().addMessage("modParamResultMessages", new FacesMessage("Entry set has been saved.2"));
			FacesUtils.addMessageInfo("Modparam has been removed.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isCreateAddMode()) {
				//_rulesDao.createModParamAndAddtoScale( userSessionId, newModParam, modScale.getId(), modScale.getSeqNum());
			}
			curMode = VIEW_MODE;
			_modParamSource.flushCache();
//			FacesContext.getCurrentInstance().addMessage("modParamResultMessages", new FacesMessage("Entry set has been saved.2"));
			FacesUtils.addMessageInfo("Modparam has been saved.");
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

	public ModScale getModScale() {
		return modScale;
	}

	public void setModScale(ModScale modScale) {
		this.modScale = modScale;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeModParam = null;
		_modParamSource.flushCache();
	}

	public void fullCleanBean() {
		clearFilter();
		modScale = null;
	}

	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = new ArrayList<SelectItem>();
			dataTypes.add(new SelectItem("", "All types"));
			dataTypes.addAll((ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES));
		}
		return dataTypes;
	}

	public void loadState() {
		_activeModParam = sessBean.getActiveModParam();

		// TODO: does it make sense if we have _activeModParam?
		if (sessBean.getParamsSelection() != null) {
			_itemSelection.setWrappedSelection(sessBean.getParamsSelection().getWrappedSelection());
		}
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
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
