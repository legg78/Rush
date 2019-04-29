package ru.bpc.sv2.ui.operations;

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
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.ReasonMapping;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbReasonMapping")
public class MbReasonMapping extends AbstractBean {
	private static final long serialVersionUID = -7045851240929905639L;

	private static String COMPONENT_ID = "1047:rulesTable";

	private OperationDao _operationDao = new OperationDao();

	private ReasonMapping ruleFilter;
	private String defaultLang;
	private ArrayList<SelectItem> allLanguages;

	private final DaoDataModel<ReasonMapping> _rulesSource;
	private final TableRowSelection<ReasonMapping> _itemSelection;
	private ReasonMapping _activeReasonMapping;
	private ReasonMapping newReasonMapping;

	private static final Logger logger = Logger.getLogger("RULES");
	
	public MbReasonMapping() {
		_rulesSource = new DaoDataModel<ReasonMapping>() {
			private static final long serialVersionUID = -8950021912248335371L;

			@Override
			protected ReasonMapping[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ReasonMapping[0];
				}
				try {
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationDao.getReasonMappings(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ReasonMapping[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationDao.getReasonMappingsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ReasonMapping>(null, _rulesSource);
	}

	public DaoDataModel<ReasonMapping> getReasonMappings() {
		return _rulesSource;
	}

	public ReasonMapping getActiveReasonMapping() {
		return _activeReasonMapping;
	}

	public void setActiveReasonMapping(ReasonMapping activeReasonMapping) {
		_activeReasonMapping = activeReasonMapping;
	}

	public SimpleSelection getItemSelection() {
		if (_activeReasonMapping == null && _rulesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeReasonMapping != null && _rulesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeReasonMapping.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeReasonMapping = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeReasonMapping = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_rulesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeReasonMapping = (ReasonMapping) _rulesSource.getRowData();
		selection.addKey(_activeReasonMapping.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void search() {

		setFilters();
		searching = true;
		_rulesSource.flushCache();
		_itemSelection.clearSelection();
		_activeReasonMapping = null;
	}

	public void clearFilter() {
		curLang = defaultLang;
		ruleFilter = new ReasonMapping();
		searching = false;

		clearBean();
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeReasonMapping = null;
		_rulesSource.flushCache();
	}

	public void setFilters() {
		getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = null;

		if (ruleFilter.getOperType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(ruleFilter.getOperType());
			filters.add(paramFilter);
		}
		if (ruleFilter.getReasonDict() != null && !"".equals(ruleFilter.getReasonDict())) {
			paramFilter = new Filter();
			paramFilter.setElement("reasonDict");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(ruleFilter.getReasonDict());
			filters.add(paramFilter);
		}
	}

	public void resetBean() {
	}

	public ReasonMapping getFilter() {
		if (ruleFilter == null) {
			ruleFilter = new ReasonMapping();
		}
		return ruleFilter;
	}

	public void setFilter(ReasonMapping ruleFilter) {
		this.ruleFilter = ruleFilter;
	}

	public void add() {
		curMode = NEW_MODE;
		newReasonMapping = new ReasonMapping();
	}

	public void edit() {
		curMode = EDIT_MODE;
		try {
			newReasonMapping = _activeReasonMapping.clone();
		} catch (CloneNotSupportedException e) {
			newReasonMapping = new ReasonMapping();
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newReasonMapping = _operationDao.addReasonMapping(userSessionId, newReasonMapping);
				_itemSelection.addNewObjectToList(newReasonMapping);
			} else {
				newReasonMapping = _operationDao.modifyReasonMapping(userSessionId, newReasonMapping);
				_rulesSource.replaceObject(_activeReasonMapping, newReasonMapping);
			}

			_activeReasonMapping = newReasonMapping;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
	}

	public void delete() {
		try {
			_operationDao.deleteReasonMapping(userSessionId, _activeReasonMapping);
			_activeReasonMapping = _itemSelection.removeObjectFromList(_activeReasonMapping);

			if (_activeReasonMapping == null) {
				clearBean();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ArrayList<SelectItem> getOperTypes() {
		return getDictUtils().getArticles(DictNames.OPER_TYPE, true);
	}
	
	private List<SelectItem> operReasons;
	
	public List<SelectItem> getOperReasons() {
		if (operReasons == null){
			updateOperReasons();
		}
		return operReasons;
	}

	public void updateOperReasons(){
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("oper_type", getNewReasonMapping().getOperType());
		operReasons = getDictUtils().getLov(LovConstants.OPER_REASON, params);
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_PROCESSING_TEMPLATE;
	}
	
	public List<SelectItem> getReasonDicts() {
		return getDictUtils().getLov(LovConstants.REASON_DICT);
	}

	public ReasonMapping getNewReasonMapping() {
		if (newReasonMapping == null) {
			newReasonMapping = new ReasonMapping();
		}
		return newReasonMapping;
	}

	public void setNewReasonMapping(ReasonMapping newReasonMapping) {
		this.newReasonMapping = newReasonMapping;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeReasonMapping = null;
		_rulesSource.flushCache();
		curLang = userLang;
	}
	
}
