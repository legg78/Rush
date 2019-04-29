package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoPaymentOrder;
import ru.bpc.sv2.pmo.PmoPaymentOrderParameter;
import ru.bpc.sv2.process.ProcessTrace;
import ru.bpc.sv2.reports.RptDocument;
import ru.bpc.sv2.ui.accounts.MbObjectDocuments;
import ru.bpc.sv2.ui.pmo.MbPmoOrderParameters;
import ru.bpc.sv2.ui.trace.logging.MbTrace;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.HashMap;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbPmoPaymentOrdersContext")
public class MbPmoPaymentOrdersContext extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	private Long id;
	private PmoPaymentOrder pmo;
	private String tabName;
	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	
	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();
	
	public PmoPaymentOrder getCurrentPaymentOrder() {
		return getPaymentOrder();
	}
	
	public PmoPaymentOrder getPaymentOrder(){
		try {
			if (pmo == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("id", id),
						new Filter("lang", curLang)};
				PmoPaymentOrder[] pmos = _paymentOrdersDao.getPaymentOrders(userSessionId,
						new SelectionParams(filters));
				if (pmos.length > 0) {
					pmo = pmos[0];
				}
				loadedTabs.clear();
			}
			return pmo;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return  null;
	}
	
	public void reset(){
		pmo = null;
		id = null;
	}
	
	public void initializeModalPanel(){
		logger.debug("MbCardDetails initializing...");
		reset();
		if (FacesUtils.getSessionMapValue(CTX_MENU_PARAMS) != null) {
			Map<String, Object> ctxMenuParams = (Map<String, Object>) FacesUtils.getSessionMapValue(CTX_MENU_PARAMS);
			FacesUtils.setSessionMapValue(CTX_MENU_PARAMS, null);
			if (ctxMenuParams.containsKey(OBJECT_ID)){
				id = (Long) ctxMenuParams.get(OBJECT_ID);
			} 
		} else {
			if (FacesUtils.getSessionMapValue(OBJECT_ID) != null) {
				id = (Long) FacesUtils.getSessionMapValue(OBJECT_ID);
//				FacesUtils.setSessionMapValue(OBJECT_ID, null);
			}	
		}
		getCurrentPaymentOrder();
	}
	
	public void setTabName(String tabName) {

		this.tabName = tabName;
	}
	
	public String getTabName() {
		return tabName;
	}
	
	public void loadCurrentTab() {
		loadTab(tabName);
	}
	
	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (pmo == null)
			return;
		try {
			if (tab.equalsIgnoreCase("paramsContextTab")) {
				MbPmoOrderParameters beanSearch = (MbPmoOrderParameters) ManagedBeanWrapper
						.getManagedBean("MbPmoOrderParametersContext");
				PmoPaymentOrderParameter paramFilter = new PmoPaymentOrderParameter();
				paramFilter.setOrderId(pmo.getId());
				beanSearch.setFilter(paramFilter);
				beanSearch.search();
			} else if (tab.equalsIgnoreCase("documentsContextTab")){
				MbObjectDocuments mbObjectDocuments = (MbObjectDocuments) ManagedBeanWrapper
						.getManagedBean("MbObjectDocumentsContext");
				RptDocument filter = mbObjectDocuments.getFilter();
				filter.setObjectId(pmo.getId().longValue());
				filter.setEntityType(EntityNames.PAYMENT_ORDER);
				mbObjectDocuments.setFilter(filter);
				mbObjectDocuments.search();
			} else if (tab.equals("traceContextTab")){
				MbTrace traceBean = ManagedBeanWrapper.getManagedBean(MbTrace.class);
				traceBean.clearBean();
				ProcessTrace filterTrace = new ProcessTrace();
				filterTrace.setEntityType(EntityNames.PAYMENT_ORDER);
				filterTrace.setObjectId(pmo.getId());
				traceBean.setFilter(filterTrace);
				traceBean.search();
			}

			loadedTabs.put(tab, Boolean.TRUE);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}
	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub

	}

}
