package ru.bpc.sv2.ui.accounts;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.accounts.AccountAlgorithmStep;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbAccountAlgorithmSteps")
public class MbAccountAlgorithmSteps extends AbstractBean{
	private static final Logger logger = Logger.getLogger("ISSUING");

	private AccountsDao _accDao = new AccountsDao();

	private AccountAlgorithmStep newAlgoStep;

	private Integer algorithmId;

	private final DaoDataModel<AccountAlgorithmStep> _algoStepsSource;
	private final TableRowSelection<AccountAlgorithmStep> _itemSelection;
	private AccountAlgorithmStep _activeAlgoStep;
	
	private static String COMPONENT_ID = "algoStepsTable";
	private String tabName;
	private String parentSectionId;

	public MbAccountAlgorithmSteps() {
		_algoStepsSource = new DaoDataModel<AccountAlgorithmStep>() {
			@Override
			protected AccountAlgorithmStep[] loadDaoData(SelectionParams params) {
				if (algorithmId == null) {
					return new AccountAlgorithmStep[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accDao.getAccountAlgorithmSteps(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AccountAlgorithmStep[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (algorithmId == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accDao.getAccountAlgorithmStepsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AccountAlgorithmStep>(null, _algoStepsSource);
	}

	public DaoDataModel<AccountAlgorithmStep> getAlgorithmSteps() {
		return _algoStepsSource;
	}

	public AccountAlgorithmStep getActiveAlgoStep() {
		return _activeAlgoStep;
	}

	public void setActiveAlgoStep(AccountAlgorithmStep activeAlgoStep) {
		_activeAlgoStep = activeAlgoStep;
	}

	public SimpleSelection getItemSelection() {
		if (_activeAlgoStep == null && _algoStepsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeAlgoStep != null && _algoStepsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeAlgoStep.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeAlgoStep = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_algoStepsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAlgoStep = (AccountAlgorithmStep) _algoStepsSource.getRowData();
		selection.addKey(_activeAlgoStep.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeAlgoStep = _itemSelection.getSingleSelection();
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter = new Filter();
		paramFilter.setElement("algoId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(algorithmId.toString());
		filters.add(paramFilter);
	}

	public void search() {
		clearBean();
	}

	public void add() {
		newAlgoStep = new AccountAlgorithmStep();
		newAlgoStep.setAlgoId(algorithmId);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newAlgoStep = (AccountAlgorithmStep) _activeAlgoStep.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newAlgoStep = _activeAlgoStep;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_accDao.deleteAccountAlgorithmStep(userSessionId, _activeAlgoStep);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Iss", "algo_step_deleted",
					"(id = " + _activeAlgoStep.getId() + ")");

			_activeAlgoStep = _itemSelection.removeObjectFromList(_activeAlgoStep);
			if (_activeAlgoStep == null) {
				clearBean();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newAlgoStep = _accDao.addAccountAlgorithmStep(userSessionId, newAlgoStep);
				_itemSelection.addNewObjectToList(newAlgoStep);
			} else {
				newAlgoStep = _accDao.modifyAccountAlgorithmStep(userSessionId, newAlgoStep);
				_algoStepsSource.replaceObject(_activeAlgoStep, newAlgoStep);
			}
			_activeAlgoStep = newAlgoStep;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Iss",
					"algo_step_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public AccountAlgorithmStep getNewAlgoStep() {
		if (newAlgoStep == null) {
			newAlgoStep = new AccountAlgorithmStep();
		}
		return newAlgoStep;
	}

	public void setNewAlgoStep(AccountAlgorithmStep newAlgoStep) {
		this.newAlgoStep = newAlgoStep;
	}

	public void clearBean() {
		_algoStepsSource.flushCache();
		_itemSelection.clearSelection();
		_activeAlgoStep = null;
	}

	public void fullCleanBean() {
		algorithmId = null;
		clearBean();
	}

	public Integer getAlgorithmId() {
		return algorithmId;
	}

	public void setAlgorithmId(Integer algorithmId) {
		this.algorithmId = algorithmId;
	}

	public ArrayList<SelectItem> getAlgorithmStepsArticles() {
		return getDictUtils().getArticles(DictNames.ALGORITHM_STEP, true);
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
