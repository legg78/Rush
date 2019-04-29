package ru.bpc.sv2.ui.rules;

import java.util.ArrayList;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.rules.ModParam;
import ru.bpc.sv2.rules.ProcedureParam;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbProcedureParams")
public class MbProcedureParams extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("RULES");

	private RulesDao _rulesDao = new RulesDao();

	private ProcedureParam procedureParamFilter;
	private Integer procedureId;

	private final DaoDataModel<ProcedureParam> _procedureParamSource;
	private final TableRowSelection<ProcedureParam> _itemSelection;
	private ProcedureParam _activeProcedureParam;
	private ProcedureParam newProcedureParam;

	private MbProcedureParamSess procParamBean;
	private ModParam modParam;
	private String backLink;
	private boolean showModal;
	
	private static String COMPONENT_ID = "procedureParamsTable";
	private String tabName;
	private String parentSectionId;

	public MbProcedureParams() {
		filters = new ArrayList<Filter>();
		procParamBean = (MbProcedureParamSess) ManagedBeanWrapper.getManagedBean("MbProcedureParamSess");
		showModal = false;

		_procedureParamSource = new DaoDataModel<ProcedureParam>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ProcedureParam[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new ProcedureParam[0];

				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getProcedureParams(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProcedureParam[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;

				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getProcedureParamsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ProcedureParam>(null,
				_procedureParamSource);
	}

	public DaoDataModel<ProcedureParam> getProcedureParams() {
		return _procedureParamSource;
	}

	public ProcedureParam getActiveProcedureParam() {
		return _activeProcedureParam;
	}

	public void setActiveProcedureParam(ProcedureParam activeProcedureParam) {
		_activeProcedureParam = activeProcedureParam;
	}

	public SimpleSelection getItemSelection() {
		if (_activeProcedureParam == null && _procedureParamSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeProcedureParam != null
				&& _procedureParamSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeProcedureParam.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeProcedureParam = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeProcedureParam = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_procedureParamSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeProcedureParam = (ProcedureParam) _procedureParamSource.getRowData();
		selection.addKey(_activeProcedureParam.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public ModParam getModParam() {
		return modParam;
	}

	public void setModParam(ModParam modParam) {
		this.modParam = modParam;
	}

	public boolean isShowModal() {
		return showModal;
	}

	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}

	public void clearBean() {
		_procedureParamSource.flushCache();
		_itemSelection.clearSelection();
		_activeProcedureParam = null;
		curLang = userLang;
		showModal = false;
	}

	public ProcedureParam getProcedureParamFilter() {
		if (procedureParamFilter == null) {
			procedureParamFilter = new ProcedureParam();
		}
		return procedureParamFilter;
	}

	public void setProcedureParamFilter(ProcedureParam procedureParamFilter) {
		this.procedureParamFilter = procedureParamFilter;
	}

	public void add() {
		curMode = NEW_MODE;
		newProcedureParam = new ProcedureParam();
		newProcedureParam.setProcedureId(procedureId);
		newProcedureParam.setLang(userLang);
	}

	public void edit() {
		curMode = EDIT_MODE;
		try {
			newProcedureParam = _activeProcedureParam.clone();
		} catch (CloneNotSupportedException e) {
			newProcedureParam = new ProcedureParam();
			logger.error("", e);
		}
	}

	public void view() {

	}

	public void save() {
		try {
			if (newProcedureParam.getName() != null && newProcedureParam.getName().isEmpty()){
				newProcedureParam.setName(null);
			}
			if (isEditMode()) {
				newProcedureParam = _rulesDao.modifyProcedureParam(userSessionId, newProcedureParam);

				_procedureParamSource.replaceObject(_activeProcedureParam, newProcedureParam);
			} else {
				newProcedureParam = _rulesDao.addProcedureParam(userSessionId, newProcedureParam);
				_itemSelection.addNewObjectToList(newProcedureParam);
			}
			showModal = false;
			_activeProcedureParam = newProcedureParam;
			curMode = VIEW_MODE;

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_rulesDao.deleteProcedureParam(userSessionId, _activeProcedureParam);
			
			_activeProcedureParam = _itemSelection.removeObjectFromList(_activeProcedureParam);
			if (_activeProcedureParam == null) {
				clearBean();
			}
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
		showModal = false;
	}

	public String selectParameter() {
		procParamBean.setBackLink(backLink);
		procParamBean.setCurMode(curMode);
		procParamBean.setNewProcedureParam(newProcedureParam);
		procParamBean.setProcedureParam(_activeProcedureParam);
		
		MbModParams pers = (MbModParams) ManagedBeanWrapper.getManagedBean("MbModParams");
		pers.clearFilter();
		pers.setBackLink(backLink);
		pers.setSelectMode(true);

		return "rules|params";
	}

	public ArrayList<SelectItem> getAllAccountTypes() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
	}

	public Integer getProcedureId() {
		return procedureId;
	}

	public void setProcedureId(Integer procedureId) {
		this.procedureId = procedureId;
		procParamBean.setProcedureId(procedureId);
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		procedureParamFilter = getProcedureParamFilter();
		Filter paramFilter = new Filter();
		paramFilter.setElement("procedureId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(procedureId == null ? "null" : procedureId.toString());
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (procedureParamFilter.getSystemName() != null
				&& procedureParamFilter.getSystemName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("paramName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(procedureParamFilter.getSystemName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (procedureParamFilter.getName() != null
		        && procedureParamFilter.getName().trim().length() > 0)
		{
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(procedureParamFilter.getName().trim().toUpperCase()
			        .replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public ProcedureParam getNewProcedureParam() {
		if (newProcedureParam == null) {
			newProcedureParam = new ProcedureParam();
		}
		return newProcedureParam;
	}

	public void setNewProcedureParam(ProcedureParam newProcedureParam) {
		this.newProcedureParam = newProcedureParam;
	}

	public List<SelectItem> getLovs() {		
		if (getNewProcedureParam().getDataType() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("DATA_TYPE", getNewProcedureParam().getDataType());
		
		return getDictUtils().getLov(LovConstants.LOVS_LOV, params);		
	}

	public List<SelectItem> getParameters() {
		return getDictUtils().getLov(LovConstants.PROCEDURE_PARAM);
	}

	public void changeParameter(ValueChangeEvent event) {
		Integer paramId = (Integer) event.getNewValue();
		try {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(paramId);
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(curLang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			ModParam[] paramList = _rulesDao.getModParams(userSessionId, params, curLang);
			if (paramList != null && paramList.length > 0 && paramList[0] != null) {
				newProcedureParam.setParamId(paramList[0].getId());
				newProcedureParam.setSystemName(paramList[0].getSystemName());
				newProcedureParam.setDataType(paramList[0].getDataType());
				newProcedureParam.setLovId(paramList[0].getLovId());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public boolean isLovAppliable() {
		return newProcedureParam != null && newProcedureParam.getDataType() != null ? (newProcedureParam.getDataType()
				.startsWith(DictNames.DATA_TYPE) && !newProcedureParam.getDataType().equals(DataTypes.DATE))
				: false;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_procedureParamSource.flushCache();
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newProcedureParam.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newProcedureParam.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ProcedureParam[] procParams = _rulesDao.getProcedureParams(userSessionId, params);
			if (procParams != null && procParams.length > 0) {
				newProcedureParam = procParams[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public void restoreBean() {
		_activeProcedureParam = procParamBean.getProcedureParam();
		newProcedureParam = procParamBean.getNewProcedureParam();
		backLink = procParamBean.getBackLink();
		curMode = procParamBean.getCurMode();
		procedureId = procParamBean.getProcedureId();
		showModal = true;
		if (modParam != null) {
			newProcedureParam.setParamId(modParam.getId());
			newProcedureParam.setSystemName(modParam.getSystemName());
			newProcedureParam.setDataType(modParam.getDataType());
			newProcedureParam.setLovId(modParam.getLovId());
		}
		searching = true;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
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
