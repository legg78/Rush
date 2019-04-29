package ru.bpc.sv2.ui.accounts.details;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.credit.CreditDetailsRecord;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.account.MbRestructureDebtInputDS;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbCreditAccountDetails")
public class MbCreditAccountDetails extends AbstractBean {
	private static final long serialVersionUID = 175440235963828804L;

	private static final Logger logger = Logger.getLogger("CREDIT");

	private CreditDao _creditDao = new CreditDao();
	private CommonDao _commonDao = new CommonDao();

	private CreditDetailsRecord filter;
	private CreditDetailsRecord _activeRecord;
	private final DaoDataModel<CreditDetailsRecord> _cardsSource;
	private final TableRowSelection<CreditDetailsRecord> _itemSelection;
	private List<CreditDetailsRecord> creditPayOffData;
	private List<CreditDetailsRecord> creditInterestData;

	private static String COMPONENT_ID = "mainTable";
	private String tabNameParam;
	private String parentSectionId;
	private Map<String, Object> paramMaps;
	private boolean payOffEnabled;
	
	public MbCreditAccountDetails() {
		_cardsSource = new DaoDataModel<CreditDetailsRecord>() {
			private static final long serialVersionUID = -9111805905889948423L;

			@Override
			protected CreditDetailsRecord[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new CreditDetailsRecord[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _creditDao.getCreditInfoCur(userSessionId, getFilter().getAccountId());
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					setDataSize(0);
				}
				return new CreditDetailsRecord[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				return 1;
			}
		};

		_itemSelection = new TableRowSelection<CreditDetailsRecord>(null, _cardsSource);
	}

	public DaoDataModel<CreditDetailsRecord> getRecords() {
		return _cardsSource;
	}

	public List<CreditDetailsRecord> getPayOffRecords() {
		if (creditPayOffData == null && !getNoData()) {
			creditPayOffData = getCreditPayOffData();
		}
		return creditPayOffData;
	}

	private List<CreditDetailsRecord> getCreditPayOffData() {
		creditPayOffData = new ArrayList<CreditDetailsRecord>();
		CreditDetailsRecord rec = new CreditDetailsRecord();
		try {
			setFilters();
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			creditPayOffData.addAll(Arrays.asList(_creditDao.getCreditPayOffCur(userSessionId, params)));
            if (creditPayOffData.size() > 0) {
                Collections.sort(creditPayOffData, CreditDetailsRecord.TREE_COMPARE);

                for (int i = 0; i < creditPayOffData.size(); i++ ) {
                    if (creditPayOffData.get(i).getParentName() != null) {
                        rec = creditPayOffData.get(i);
                        if (rec.getParentName() != null) {
                            rec.setName("....".concat(rec.getName()));
                            creditPayOffData.set(i, rec);
                        }
                    }
                }
            }
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return creditPayOffData;
	}

	public CreditDetailsRecord getActiveRecord() {
		return _activeRecord;
	}

	public void setActiveRecord(CreditDetailsRecord activeRecord) {
		_activeRecord = activeRecord;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeRecord == null && _cardsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeRecord != null && _cardsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeRecord.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeRecord = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_cardsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeRecord = (CreditDetailsRecord) _cardsSource.getRowData();
		selection.addKey(_activeRecord.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeRecord != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeRecord = _itemSelection.getSingleSelection();
		if (_activeRecord != null) {
			setInfo();
		}
	}

	public void setInfo() {
	}

	public void search() {
		clearState();
		searching = true;
	}

	public Boolean getNoData() {
		if (filter != null) {
			return (filter.getAccountId() == null);
		}
		return true;
	}

	public void clearFilter() {
		filter = new CreditDetailsRecord();
		paramMaps = new HashMap<String, Object>();
		clearState();
		searching = false;
	}

	public CreditDetailsRecord getFilter() {
		if (filter == null)
			filter = new CreditDetailsRecord();
		return filter;
	}

	public void setFilter(CreditDetailsRecord filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		if (getFilter().getAccountId() != null) {
			filters.add(Filter.create("accountId", filter.getAccountId()));
		}
		if (getFilter().getPayOffDate() != null) {
			filters.add(Filter.create("payOffDate", filter.getPayOffDate()));
		}
		if (getFilter().getStartDate() != null) {
			filters.add(Filter.create("startDate", filter.getStartDate()));
		}
		if (getFilter().getEndDate() != null) {
			filters.add(Filter.create("endDate", filter.getEndDate()));
		}
	}

	public void add() {}
	public void edit() {}
	public void view() {}

	public void recalculatePayOff() {
		curLang = userLang;
		creditPayOffData = getCreditPayOffData();
		payOffEnabled = checkPayOffEnabled();
	}

	private boolean checkPayOffEnabled() {
		UserSession usession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
		Date systemSttlDate  = usession.getOpenSttlDate();
		Date calculateDate = getFilter().getPayOffDate();

		return systemSttlDate.before(calculateDate);
	}

	public void payOff() {
		try {
			setFilters();
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			_creditDao.getCreditPayOffClose(userSessionId, params);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
		recalculatePayOff();
	}

	public void cancel() {
		creditPayOffData = new ArrayList<CreditDetailsRecord>();
		creditInterestData = new ArrayList<CreditDetailsRecord>();
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeRecord = null;
		_cardsSource.flushCache();
		curLang = userLang;
		clearBeansStates();
	}

	public void clearBeansStates() {
	}

	public String getComponentId() {
		return parentSectionId + ":" + tabNameParam + ":" + COMPONENT_ID;
	}

	public void setTabNameParam(String tabNameParam) {
		this.tabNameParam = tabNameParam;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	public Map<String, Object> getParamMaps() {
		if (paramMaps == null){
			paramMaps = new HashMap<String, Object>();
		}
		return paramMaps;
	}

	public void setParamMaps(Map<String, Object> paramMaps) {
		this.paramMaps = paramMaps;
	}

	public boolean isPayOffEnabled() {
		return payOffEnabled;
	}

	public void setPayOffEnabled(boolean payOffEnabled) {
		this.payOffEnabled = payOffEnabled;
	}

	public void restructureDebt() {
		List<Filter> filters = new ArrayList<Filter>();
		filters.add(Filter.create("wizardId", 1055));
		filters.add(Filter.create("lang", curLang));

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setSortElement(new SortElement("stepOrder", SortElement.Direction.ASC));
		params.setRowIndexEnd(999);

		List<CommonWizardStepInfo> stepsList = new ArrayList<CommonWizardStepInfo>();
		stepsList.addAll(Arrays.asList(_commonDao.getWizardSteps(userSessionId, params)));

		Map<String, Object> context = new HashMap<String, Object>();
		context.put(MbCommonWizard.STEPS, stepsList);
		context.put(MbCommonWizard.ENTITY_TYPE, EntityNames.CREDIT_INVOICE);
		if (filter != null && filter.getAccountId() != null) {
			if (_activeRecord.getAccountId() == null) {
				_activeRecord.setAccountId(filter.getAccountId());
			}
			context.put(MbCommonWizard.OBJECT_ID, filter.getAccountId());
		}
		if (filter.getPayOffDate() != null) {
			context.put(MbRestructureDebtInputDS.PAYOFF_DATE, filter.getPayOffDate());
		}
		context.put(MbCommonWizard.OBJECT, _activeRecord);

		MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
		wizard.init(context);
	}

	public void calculateInterest() {
		curLang = userLang;
		creditPayOffData = getCreditInterestData();
	}

	public List<CreditDetailsRecord> getInterestRecords() {
		return creditInterestData;
	}

	private List<CreditDetailsRecord> getCreditInterestData() {
		creditInterestData = new ArrayList<CreditDetailsRecord>();
		try {
			setFilters();
			SelectionParams params = new SelectionParams(Filter.asArray(filters));
			creditInterestData.addAll(_creditDao.getCreditInterestCalcCur(userSessionId, params));

			if (creditInterestData.size() > 0) {
				Collections.sort(creditInterestData, CreditDetailsRecord.TREE_COMPARE);
				for (int i = 0; i < creditInterestData.size(); i++ ) {
					if (creditInterestData.get(i).getParentName() != null) {
						CreditDetailsRecord rec = creditInterestData.get(i);
						if (rec.getParentName() != null) {
							rec.setName(".... ".concat(rec.getName()));
							creditInterestData.set(i, rec);
						}
					}
				}
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return creditInterestData;
	}
}
