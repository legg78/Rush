package ru.bpc.sv2.ui.pmo;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.pmo.PmoPaymentOrder;
import ru.bpc.sv2.pmo.PmoPaymentOrderFilter;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.utils.AbstractSearchTabbedBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ViewScoped
@ManagedBean(name = "MbPmoPaymentOrdersSearch")
public class MbPmoPaymentOrdersSearch extends AbstractSearchTabbedBean<PmoPaymentOrderFilter, PmoPaymentOrder> {
	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	private static final String PARAMS_TAB  = "paramsTab";
	private static final String OBJECTS_TAB = "linkedObjectsTab";

	private List<SelectItem> purposes;
	private List<SelectItem> entityTypes;
	private List<SelectItem> statuses;
	private List<SelectItem> paymentOrderParams;

	private PaymentOrdersDao paymentOrdersDao = new PaymentOrdersDao();
	private ProductsDao productsDao = new ProductsDao();

	@Override
	protected void onLoadTab(String tabName) {
		if (PARAMS_TAB.equals(tabName)) {
			MbPmoOrderParameters bean = ManagedBeanWrapper.getManagedBean(MbPmoOrderParameters.class);
			bean.clearFilter();
			bean.getFilter().setOrderId(activeItem.getId());
			bean.search();
		} else if (OBJECTS_TAB.equals(tabName)) {
			MbPmoPaymentOrderDetailsSearch bean = ManagedBeanWrapper.getManagedBean(MbPmoPaymentOrderDetailsSearch.class);
			bean.clearFilter();
			bean.getFilter().setOrderId(activeItem.getId());
			bean.search();
		}

	}

	@Override
	protected PmoPaymentOrderFilter createFilter() {
		PmoPaymentOrderFilter filter = new PmoPaymentOrderFilter();
		Calendar calendar = new GregorianCalendar();
		calendar.set(Calendar.HOUR_OF_DAY, 0);
		calendar.set(Calendar.MINUTE, 0);
		calendar.set(Calendar.SECOND, 0);
		calendar.set(Calendar.MILLISECOND, 0);
		filter.setOrderDateFrom(new Date(calendar.getTimeInMillis()));
		return filter;
	}

	@Override
	public void clearState() {
		super.clearState();
		ManagedBeanWrapper.getManagedBean(MbPmoOrderParameters.class).clearFilter();
		ManagedBeanWrapper.getManagedBean(MbPmoPaymentOrderDetailsSearch.class).clearFilter();
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	protected PmoPaymentOrder addItem(PmoPaymentOrder item) {
		return null;
	}

	@Override
	protected PmoPaymentOrder editItem(PmoPaymentOrder item) {
		return null;
	}

	@Override
	protected void deleteItem(PmoPaymentOrder item) {

	}

	@Override
	protected void initFilters(PmoPaymentOrderFilter filter, List<Filter> filters) {
		if (filter.getOrderDateFrom() != null) {
			filters.add(Filter.create("ORDER_ID", filter.getId()));
		}
		if (filter.getOrderDateFrom() != null) {
			filters.add(Filter.create("ORDER_DATE_FROM", filter.getOrderDateFrom()));
		}
		if (filter.getOrderDateTo() != null) {
			filters.add(Filter.create("ORDER_DATE_TO", filter.getOrderDateTo()));
		}
		if (filter.getInstId() != null) {
			filters.add(Filter.create("INST_ID", filter.getInstId()));
		}
		if (filter.getCustomerId() != null) {
			filters.add(Filter.create("CUSTOMER_ID", filter.getCustomerId()));
		}
		if (filter.getEntityType() != null) {
			filters.add(Filter.create("ENTITY_TYPE", filter.getEntityType()));
		}
		if (filter.getObjectId() != null) {
			filters.add(Filter.create("OBJECT_ID", filter.getObjectId()));
		}
		if (filter.getStatus() != null) {
			filters.add(Filter.create("STATUS", filter.getStatus()));
		}
		if (filter.getPurposeId() != null) {
			filters.add(Filter.create("PURPOSE_ID", filter.getPurposeId()));
		}
		if (filter.getParameterId() != null) {
			filters.add(Filter.create("PARAM_ID", filter.getParameterId()));
		}
		if (StringUtils.isNotBlank(filter.getParameterValue())) {
			filters.add(Filter.create("PARAM_VALUE", Filter.mask(filter.getParameterValue())));
		}
	}

	@Override
	protected List<PmoPaymentOrder> getObjectList(Long userSessionId, SelectionParams params) {
		return paymentOrdersDao.getPmoPaymentOrders(userSessionId, params);
	}

	@Override
	protected int getObjectCount(Long userSessionId, SelectionParams params) {
		return paymentOrdersDao.getPmoPaymentOrdersCount(userSessionId, params);
	}

	public List<SelectItem> getPurposes() {
		if (purposes == null) {
			purposes = getDictUtils().getLov(LovConstants.PAYMENT_PURPOSE);
		}
		return purposes;
	}

	public List<SelectItem> getEntityTypes() {
		if (entityTypes == null) {
			entityTypes = getDictUtils().getLov(LovConstants.PMO_TEMPLATE_ENTITIES);
		}
		return entityTypes;
	}

	public List<SelectItem> getStatuses() {
		if (statuses == null) {
			statuses = getDictUtils().getLov(LovConstants.PMO_STATUSES);
		}
		return statuses;
	}

	public List<SelectItem> getPaymentOrderParams() {
		if (paymentOrderParams == null) {
			paymentOrderParams = getDictUtils().getLov(LovConstants.PAYMENT_ORDER_PARAMETERS);
		}
		return paymentOrderParams;
	}

	public void prepareObject() {
		getFilter().setObjectId(null);
		getFilter().setObjectNumber(null);
	}

	public void prepareObjectId(){
		MbObjectIdModalPanel modalPanel = (MbObjectIdModalPanel)ManagedBeanWrapper
				.getManagedBean(MbObjectIdModalPanel.class);
		modalPanel.clearFilter();
		modalPanel.clearState();
		modalPanel.setEntityType(getFilter().getEntityType());
		modalPanel.setInstId(getFilter().getInstId());
		modalPanel.setCustomerId(getFilter().getCustomerId());
		modalPanel.setCustomerNumber(getFilter().getCustomerNumber());
		modalPanel.setSearching(false);
	}

	public void selectObject(){
		MbObjectIdModalPanel modalPanel = (MbObjectIdModalPanel)ManagedBeanWrapper
				.getManagedBean(MbObjectIdModalPanel.class);
		if (modalPanel.isAccount()){
			getFilter().setObjectId(modalPanel.getActiveAccount().getId());
			getFilter().setObjectNumber(modalPanel.getActiveAccount().getAccountNumber());
		} else if (modalPanel.isCard()){
			getFilter().setObjectId(modalPanel.getActiveCard().getId());
			getFilter().setObjectNumber(modalPanel.getActiveCard().getMask());
		} else if (modalPanel.isCustomer()){
			getFilter().setObjectId(modalPanel.getActiveCustomer().getId());
			getFilter().setObjectNumber(modalPanel.getActiveCustomer().getCustomerNumber());
			getFilter().setInstId(modalPanel.getInstId());
		} else if (modalPanel.isTerminal()){
			getFilter().setObjectId(modalPanel.getActiveTerminal().getId().longValue());
			getFilter().setObjectNumber(modalPanel.getActiveTerminal().getTerminalNumber());
		} else if (modalPanel.isMerchant()){
			getFilter().setObjectId(modalPanel.getActiveMerchant().getId());
			getFilter().setObjectNumber(modalPanel.getActiveMerchant().getMerchantNumber());
		}

	}

	public void displayCustInfo() {

		if (getFilter().getCustInfo() == null || "".equals(getFilter().getCustInfo())) {
			getFilter().setCustomerNumber(null);
			getFilter().setCustomerId(null);
			return;
		}

		// process wildcard
		Pattern p = Pattern.compile("\\*|%|\\?");
		Matcher m = p.matcher(getFilter().getCustInfo());
		if (m.find() || getFilter().getInstId() == null) {
			getFilter().setCustomerNumber(getFilter().getCustInfo());
			return;
		}

		// search and redisplay
		Filter[] filters  = new Filter[3];
		filters[0] = new Filter("LANG", curLang);
		filters[1] = new Filter("INST_ID", getFilter().getInstId());
		filters[2] = new Filter("CUSTOMER_NUMBER", getFilter().getCustInfo());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Customer[] cust = productsDao.getCombinedCustomersProc(userSessionId, params, "CUSTOMER");
			if (cust != null && cust.length > 0) {
				getFilter().setCustInfo(cust[0].getName());
				getFilter().setCustomerNumber(cust[0].getCustomerNumber());
				getFilter().setCustomerId(cust[0].getId());
			} else {
				getFilter().setCustomerNumber(getFilter().getCustInfo());
				getFilter().setCustomerId(null);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void showCustomers() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		custBean.clearFilter();
		if (getFilter().getInstId() != null) {
			custBean.setBlockInstId(true);
			custBean.setDefaultInstId(getFilter().getInstId());
		} else {
			custBean.setBlockInstId(false);
		}
	}

	public void selectCustomer() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		Customer selected = custBean.getActiveCustomer();
		if (selected != null) {
			getFilter().setCustomerNumber(selected.getCustomerNumber());
			getFilter().setCustomerId(selected.getId());
			getFilter().setCustInfo(selected.getName());
			getFilter().setInstId(custBean.getFilter().getInstId());
		}
	}

	public void onInstitutionChange() {
		prepareObject();
		getFilter().setCustomerNumber(null);
		getFilter().setCustomerId(null);
		getFilter().setCustInfo(null);
	}
}
