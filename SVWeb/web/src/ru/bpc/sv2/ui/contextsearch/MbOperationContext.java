package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.process.ProcessTrace;
import ru.bpc.sv2.ui.amounts.MbAdditionalAmounts;
import ru.bpc.sv2.ui.aup.MbTagValues;
import ru.bpc.sv2.ui.aut.MbAuthorizations;
import ru.bpc.sv2.ui.dsp.MbAssociatedOperations;
import ru.bpc.sv2.ui.operations.MbEntriesForOperation;
import ru.bpc.sv2.ui.operations.MbOperations;
import ru.bpc.sv2.ui.operations.MbParticipants;
import ru.bpc.sv2.ui.operations.MbTechnicalMessages;
import ru.bpc.sv2.ui.pmo.MbPmoPaymentOrdersDependent;
import ru.bpc.sv2.ui.trace.logging.MbTrace;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbOperationContext")
public class MbOperationContext extends MbOperations {

	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	private Long id;
	private Operation operation;
	
	private OperationDao operationDao = new OperationDao();
	
	private MbEntriesForOperation entryBean;
	
	public Operation getActiveOperation() {
		super.setActiveOperation(getOperation());
		return super.getActiveOperation();
	}
	
	public Operation getOperation(){
		try {
			if (operation == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("id", id),
						new Filter("lang", curLang)};
				List<Operation> operations = operationDao.getOperations(userSessionId, new SelectionParams(filters), curLang);
				if (operations.size() > 0) {
					operation = operations.get(0);
				}
			}
			return operation;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return  null;
	}
	
	public void reset(){
		operation = null;
		id = null;
	}
	
	public void initializeModalPanel(){
		logger.debug("MbOperationDetails initializing...");
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
		
		if (id == null){
//			objectIdIsNotSet();
		}
		getActiveOperation();
	}
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
	
	public void loadCurrentTab(){
		loadOperTabs(tabName);
	}
	
	public void loadOperTabs(String tab){
		if (operation == null) {
			return;
		}
		if ("accContextTab".equals(tab)){
			entryBean = (MbEntriesForOperation) ManagedBeanWrapper
					.getManagedBean("MbEntriesForOperationContext");
			entryBean.clearFilter();
			entryBean.setOperationId(operation.getId());
			entryBean.setEntityType(EntityNames.OPERATION);
			entryBean.setBackLink(thisBackLink);
			entryBean.search();
		} else if ("paymentOrdersContextTab".equals(tab)){
			MbPmoPaymentOrdersDependent orderBean = (MbPmoPaymentOrdersDependent) ManagedBeanWrapper
					.getManagedBean("MbPmoPaymentOrdersDependentContext");
			orderBean.getOrder(operation.getPaymentOrderId());
		} else if ("traceContextTab".equals(tab)){
			MbTrace traceBean = (MbTrace) ManagedBeanWrapper.getManagedBean("MbTraceContext");
			traceBean.clearBean();
			ProcessTrace filterTrace = new ProcessTrace();
			filterTrace.setEntityType(EntityNames.OPERATION);
			filterTrace.setObjectId(operation.getId());
			traceBean.setFilter(filterTrace);
			traceBean.search();
		} else if ("tagsContextTab".equals(tab)){
			MbTagValues tagValues = (MbTagValues) ManagedBeanWrapper.getManagedBean("MbTagValuesContext");
			tagValues.clearFilter();
			tagValues.getFilter().setAuthId(operation.getId());
			tagValues.search();
		} else if ("authContextTab".equals(tab)){
			MbAuthorizations authBean = (MbAuthorizations) ManagedBeanWrapper
					.getManagedBean("MbAuthorizationsContext");
			authBean.loadAuthorization(operation.getId());
		} else if ("partContextTab".equals(tab)){
			MbParticipants partBean = (MbParticipants) ManagedBeanWrapper.getManagedBean("MbParticipantsContext");
			partBean.loadParticipantsForOperation(operation.getId());
		} else if ("messagesContextTab".equals(tab)){
			MbTechnicalMessages techMessages = (MbTechnicalMessages) ManagedBeanWrapper.getManagedBean("MbTechnicalMessagesContext");
			techMessages.clearFilter();
			techMessages.getFilter().setOperId(operation.getId());
			techMessages.search();
		} else if ("disputesContextTab".equals(tab)){
			MbAssociatedOperations assOperBean = (MbAssociatedOperations) ManagedBeanWrapper
					.getManagedBean("MbAssociatedOperationsContext");
			assOperBean.clearFilter();
			assOperBean.setOperId(operation.getId());
			assOperBean.search();
		} else if ("additionalAmountsContextTab".equals(tab)){
			MbAdditionalAmounts amountBean = (MbAdditionalAmounts) ManagedBeanWrapper
					.getManagedBean("MbAdditionalAmountsContext");
			amountBean.loadAmounts(operation.getId());
		}
	}
	
}
