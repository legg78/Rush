package ru.bpc.sv2.ui.scenario;

import java.util.ArrayList;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.ScenariosDao;
import ru.bpc.sv2.scenario.AuthParam;
import ru.bpc.sv2.scenario.AuthState;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAuthParams")
public class MbAuthParams extends AbstractBean {
	private static final Logger logger = Logger.getLogger("SCENARIO");

	private ScenariosDao _scenarioDao = new ScenariosDao();

	

	private AuthParam authParamFilter;
	private AuthParam newParam;
	private AuthState authState;

	private final DaoDataModel<AuthParam> _paramsSource;
	private final TableRowSelection<AuthParam> _itemSelection;
	private AuthParam _activeParam;
	
	private static String COMPONENT_ID = "stateParamsTable";
	private String tabName;
	private String parentSectionId;

	public MbAuthParams() {
		
		
		_paramsSource = new DaoDataModel<AuthParam>() {
			@Override
			protected AuthParam[] loadDaoData(SelectionParams params) {
				if (authState == null || !searching)
					return new AuthParam[0];

				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _scenarioDao.getStateParams(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AuthParam[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (authState == null || !searching)
					return 0;

				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _scenarioDao.getStateParamsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AuthParam>(null, _paramsSource);
	}

	public DaoDataModel<AuthParam> getParams() {
		return _paramsSource;
	}

	public AuthParam getActiveParam() {
		return _activeParam;
	}

	public void setActiveParam(AuthParam activeParam) {
		_activeParam = activeParam;
	}

	public SimpleSelection getItemSelection() {
		if (_activeParam == null && _paramsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeParam != null && _paramsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeParam.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeParam = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeParam = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_paramsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeParam = (AuthParam) _paramsSource.getRowData();
		selection.addKey(_activeParam.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeParam != null) {

		}
	}

	public void search() {
		// search using new criteria
		clearBean();
		setSearching(true);
	}

	public void clearFilter() {
		curLang = userLang;
		authParamFilter = new AuthParam();
	}

	public void setFilters() {
		authParamFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		if (authParamFilter.getParamId() != null) {
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(authParamFilter.getParamId().toString());
			filters.add(paramFilter);
		}
		if (authParamFilter.getStateId() != null) {
			paramFilter.setElement("stateId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(authParamFilter.getStateId().toString());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newParam = new AuthParam();
		newParam.setStateId(authState.getId());
		newParam.setStateSeqNum(authState.getSeqNum());
		newParam.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newParam = (AuthParam) _activeParam.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newParam = _activeParam;
		}
		newParam.setStateSeqNum(authState.getSeqNum());
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (newParam.getDataType().equals(DataTypes.NUMBER)) {
				newParam.setValue((newParam.getValueN()!=null)?newParam.getValueN().toString():null);
			}
			_scenarioDao.setParameter(userSessionId, newParam);
			authState.incrementSeqNum();
			_paramsSource.flushCache();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Asc",
					"param_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public AuthParam getFilter() {
		if (authParamFilter == null) {
			authParamFilter = new AuthParam();
		}
		return authParamFilter;
	}

	public void setFilter(AuthParam paramFilter) {
		this.authParamFilter = paramFilter;
	}

	public AuthParam getNewParam() {
		if (newParam == null) {
			newParam = new AuthParam();
		}
		return newParam;
	}

	public void setNewParam(AuthParam newParam) {
		this.newParam = newParam;
	}

	public AuthState getState() {
		return authState;
	}

	public void setState(AuthState authState) {
		this.authState = authState;
	}

	public void clearBean() {
		_paramsSource.flushCache();
		_itemSelection.clearSelection();
		_activeParam = null;

		authState = null;
	}
	
	public List<SelectItem> getLov() {
		if (LovConstants.AUTH_STATE_PARAMS_STATES == getNewParam().getLovId()) {
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("SCENARIO_ID", getNewParam().getScenarioId());
			return getDictUtils().getLov(getNewParam().getLovId(), map);
		}
		return getDictUtils().getLov(getNewParam().getLovId());
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
