package ru.bpc.sv2.ui.dpp;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.dpp.DefferedPaymentPlan;
import ru.bpc.sv2.dpp.DppAttributeValue;
import ru.bpc.sv2.dpp.DppInstalment;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.DppDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.ui.issuing.MbIssSelectObject;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import javax.faces.validator.ValidatorException;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbDppPaymentPlan")
public class MbDppPaymentPlan extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("DPP");

	private static String COMPONENT_ID = "2223:paymentPlanTable";

	private DppDao dppDao = new DppDao();

	private MbDualDppMacros mbDppMacros;
	private MbDppPaymentInstalments dppPaymentInstalments;
	private MbDppAttributes mbDppAttributes;

	private DefferedPaymentPlan filter;
	private final DaoDataModel<DefferedPaymentPlan> dataModel;
	private final TableRowSelection<DefferedPaymentPlan> tableRowSelection;

	private DefferedPaymentPlan activeItem;
	private DefferedPaymentPlan newDefferedPaymentPlan;
	private DefferedPaymentPlan acceleratingDefferedPaymentPlan;

	private List<SelectItem> savedAccelerationTypes;
    private List<String> rerenderList;

	private String tabName;

	public MbDppPaymentPlan() {
		pageLink = "dpp|paymentPlan";
		tabName = "detailsTab";
		dataModel = new DaoDataModel<DefferedPaymentPlan>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected DefferedPaymentPlan[] loadDaoData(SelectionParams params) {
				if (searching) {
					try {
						setFilters();
						params.setFilters(filters);
						return dppDao.getDefferedPaymentPlans(userSessionId, params);
					} catch (Exception e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}

				return new DefferedPaymentPlan[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (searching) {
					try {
						setFilters();
						params.setFilters(filters);
						return dppDao.getDefferedPaymentPlansCount(userSessionId, params);
					} catch (Exception e) {
						setDataSize(0);
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return 0;
			}
		};
		tableRowSelection = new TableRowSelection<DefferedPaymentPlan>(null, getDataModel());
		filter = new DefferedPaymentPlan();
		mbDppMacros = ManagedBeanWrapper.getManagedBean(MbDualDppMacros.class);
		dppPaymentInstalments = ManagedBeanWrapper.getManagedBean(MbDppPaymentInstalments.class);
		mbDppAttributes = ManagedBeanWrapper.getManagedBean(MbDppAttributes.class);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getOperId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operId");
			paramFilter.setValue(filter.getOperId());
			filters.add(paramFilter);
		}

		if (filter.getCardId() != null) {
            paramFilter = new Filter("cardId", filter.getCardId());
            filters.add(paramFilter);
        } else if (filter.getCardNumber() != null && filter.getCardNumber().trim().length() > 0){
            String filterValue = filter.getCardNumber();
            Filter filter = null;

            String mask = filterValue.trim().replaceAll("[*]", "%").replaceAll("[?]",
                    "_").toUpperCase();
            filter = new Filter("cardMask", mask);
            filter.setCondition("like");
            filters.add(filter);
        }

        if (filter.getAccountId() != null) {
            paramFilter = new Filter("accountId", filter.getAccountId());
            filters.add(paramFilter);
        } else if (filter.getAccountNumber() != null && filter.getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("accountNumber");
			paramFilter.setValue(filter.getAccountNumber().trim().toUpperCase().replaceAll("[*]", "%")
										 .replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getDateFrom() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("dateFrom");
			paramFilter.setOp(Operator.eq);
			SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
			paramFilter.setValue(df.format(filter.getDateFrom()));
			filters.add(paramFilter);
		}

		if (filter.getDateTo() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("dateTo");
			paramFilter.setOp(Operator.eq);
			SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
			paramFilter.setValue(df.format(filter.getDateTo()));
			filters.add(paramFilter);
		}
	}

	public void search() {
        search(true);
	}

	public void search(boolean selectObject) {
	    if (selectObject) {
            reset();
            MbIssSelectObject bean = ManagedBeanWrapper.getManagedBean(MbIssSelectObject.class);
            searching = false;
            int size = bean.load(this);
            if (size > 1) {
                getRerenderList().clear();
                getRerenderList().add("searchBtn"); // need for open dialog
                getRerenderList().add(MbIssSelectObject.MODAL_ID);
            } else if(size == 0) {
                searching = true;
            }
        } else {
            searching = true;
        }
    }

    public boolean isNeedOpenSelectObjectDialog() {
	    return getRerenderList().contains(MbIssSelectObject.MODAL_ID);
    }

    public List<String> getRerenderList() {
	    if (rerenderList == null) {
            rerenderList = new ArrayList<String>(Arrays.asList("paymentPlanTable", "dspayments", "pagesNum", "btns_limit", getTabName()));
        }
	    return rerenderList;
    }


	private void reset() {
		tableRowSelection.clearSelection();
        dataModel.flushCache();
		activeItem = null;
		rerenderList = null;
	}

	public void searchOperations() {
		mbDppMacros.search();
	}

	public void resetOperation() {
		mbDppMacros.clearFilter();
	}

	public void saveDefferedPaymentPlan(DefferedPaymentPlan dpp) {
		try {
			DefferedPaymentPlan registredDefferedPaymentPlan = dpp.clone();
			tableRowSelection.addNewObjectToList(registredDefferedPaymentPlan);
			activeItem = registredDefferedPaymentPlan;
			setBeans();
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void resetDefferedPaymentPlan() {
		setNewDefferedPaymentPlan(null);
	}

	public void createAcceleratingDpp() {
		acceleratingDefferedPaymentPlan = new DefferedPaymentPlan();
		acceleratingDefferedPaymentPlan.setId(activeItem.getId());

	}

	public void accelerateDefferedPaymentPlan() {
		try {
			dppDao.accelerateDefferedPaymentPlan(userSessionId,
												 getAcceleratingDefferedPaymentPlan());
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		resetDefferedPaymentPlan();
	}

	public void clearFilter(){
		filter = new DefferedPaymentPlan();
		searching = false;
		reset();
		setBeans();
	}

	private void setBeans() {
		if (activeItem == null) {
			dppPaymentInstalments.setFilter(null);
			mbDppAttributes.setFilter(null);
		} else {
			DppInstalment di = new DppInstalment();
			di.setDppId(activeItem.getId());
			dppPaymentInstalments.setFilter(di);

			DppAttributeValue dav = new DppAttributeValue();
			dav.setDppId(activeItem.getId());
			mbDppAttributes.setFilter(dav);
			mbDppAttributes.search();
		}
	}

	public void validateInstalmentTotal(FacesContext context,
										UIComponent component, Object value) throws ValidatorException {

		long insTotal = (Long) value;
		if (insTotal <= 0L) {
			FacesMessage message = new FacesMessage();
			String summary = "Value must be greater than '0'";
			message.setDetail(summary);
			message.setSummary(summary);
			message.setSeverity(FacesMessage.SEVERITY_ERROR);
			throw new ValidatorException(message);
		}
	}

	public void validateInstalmentAmount(FacesContext context,
										 UIComponent component, Object value) throws ValidatorException {
		BigDecimal insAmount = (BigDecimal) value;
		BigDecimal etalone = activeItem.getInstalmentAmount();
		if (etalone.compareTo(insAmount) > 0) {
			FacesMessage message = new FacesMessage();
			String summary = "Value is less than allowable minimum of '"
					+ etalone + "'";
			message.setDetail(summary);
			message.setSummary(summary);
			message.setSeverity(FacesMessage.SEVERITY_ERROR);
			throw new ValidatorException(message);
		}
	}

	public boolean getIsFirstAccelerationType() {
		if (savedAccelerationTypes == null || savedAccelerationTypes.isEmpty()
				|| acceleratingDefferedPaymentPlan == null) {
			return false;
		}
		String firstAccType = (String) savedAccelerationTypes.get(1).getValue();
		String curAccType = acceleratingDefferedPaymentPlan
				.getAccelerationType();
		return firstAccType.equals(curAccType);
	}

	public SimpleSelection getItemSelection() {
		try {
			if (activeItem == null && dataModel.getRowCount() > 0) {
				setFirstRowActive();
			} else if (activeItem != null && dataModel.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(activeItem.getModelId());
				tableRowSelection.setWrappedSelection(selection);
				activeItem = tableRowSelection.getSingleSelection();
			}
			ManagedBeanWrapper.getManagedBean(MbDeleteDppPaymentPlan.class).setDpp(activeItem);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return tableRowSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (DefferedPaymentPlan) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		setBeans();
	}

	public void setItemSelection(SimpleSelection simpleSelection) {
		tableRowSelection.setWrappedSelection(simpleSelection);
		activeItem = tableRowSelection.getSingleSelection();
		setBeans();
	}

	public List<SelectItem> getPaymentPlanStatuses() {
		List<SelectItem> result = getDictUtils().getArticles(
				DictNames.OPERATION_STATUS, true, true);
		return result;
	}

	public DefferedPaymentPlan getFilter() {
		return filter;
	}

	public void setFilter(DefferedPaymentPlan filter) {
		this.filter = filter;
	}

	public DaoDataModel<DefferedPaymentPlan> getDataModel() {
		return dataModel;
	}

	public DefferedPaymentPlan getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(DefferedPaymentPlan activeItem) {
		this.activeItem = activeItem;

	}

	public DefferedPaymentPlan getNewDefferedPaymentPlan() {
		return newDefferedPaymentPlan;
	}

	public void setNewDefferedPaymentPlan(DefferedPaymentPlan newDefferedPaymentPlan) {
		this.newDefferedPaymentPlan = newDefferedPaymentPlan;
	}

	public void resetAcceleratingDpp() {
		acceleratingDefferedPaymentPlan = null;
	}

	public List<SelectItem> getFees() {
		if (newDefferedPaymentPlan == null)
			return new ArrayList<SelectItem>(0);
		Long accountId = newDefferedPaymentPlan.getAccountId();
		Map<String, Object> parameters = new HashMap<String, Object>();
		parameters.put("account_id", accountId);
		List<SelectItem> fees = getDictUtils().getLov(
				LovConstants.DPP_INTEREST_FEES, parameters);
		return fees;
	}

	public List<SelectItem> getAccelerationTypes() {
		List<SelectItem> result;
		result = getDictUtils().getLov(LovConstants.DEFFERED_PLAN_ACCELERATION_TYPE);
		if(activeItem != null && activeItem.getInstalmentAlgorithm() != null
				&& activeItem.getInstalmentAlgorithm().equals("DPPAFIXD")) {
			for (Iterator<SelectItem> iter = result.iterator(); iter.hasNext(); ) {
				SelectItem item = iter.next();
				if(!item.getValue().toString().equals("DPAT0200"))
					iter.remove();
			}
		}
		savedAccelerationTypes = result;
		return result;
	}

	public DefferedPaymentPlan getAcceleratingDefferedPaymentPlan() {
		return acceleratingDefferedPaymentPlan;
	}

	public void setAcceleratingDefferedPaymentPlan(
			DefferedPaymentPlan acceleratingDefferedPaymentPlan) {
		this.acceleratingDefferedPaymentPlan = acceleratingDefferedPaymentPlan;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		if (tabName.equalsIgnoreCase("instalmentsTab")) {
			MbDppPaymentInstalments bean = (MbDppPaymentInstalments) ManagedBeanWrapper
					.getManagedBean("MbDppPaymentInstalments");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public String getSectionId() {
		return SectionIdConstants.ISSUING_CREDIT_PAYMENT_PLAN;
	}

	public boolean getPaymentAmountRequired() {
		if(acceleratingDefferedPaymentPlan != null && acceleratingDefferedPaymentPlan.getAccelerationType() != null
			&& !(acceleratingDefferedPaymentPlan.getAccelerationType().equals("DPAT0100")
		        || acceleratingDefferedPaymentPlan.getAccelerationType().equals("DPAT0400"))) {
			return true;
		}
		return false;
	}
	public boolean getCountRendered() {
		if(acceleratingDefferedPaymentPlan != null && acceleratingDefferedPaymentPlan.getAccelerationType() != null
				&& (acceleratingDefferedPaymentPlan.getAccelerationType().equals("DPAT0100")
					|| acceleratingDefferedPaymentPlan.getAccelerationType().equals("DPAT0400"))) {
			return true;
		}
		return false;
	}
	public boolean getAmountRendered() {
		if(acceleratingDefferedPaymentPlan != null && acceleratingDefferedPaymentPlan.getAccelerationType() != null) {
			return true;
		}
		return false;
	}
}
