package ru.bpc.sv2.ui.products.details;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.fcl.cycles.CycleCounter;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoPaymentOrder;
import ru.bpc.sv2.pmo.PmoTemplate;
import ru.bpc.sv2.pmo.PmoTemplateParameter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.SystemException;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbPaymentOrderDetails")
public class MbPaymentOrderDetails extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	private Long id;
	private PmoTemplate template;
	private String language;
	private Long userSessionId;
	private List<PmoTemplateParameter> templateParameters;
	private DictUtils dictUtils;	
	private PmoPaymentOrder paymentOrder;
	private SimpleSelection cycleItemSelection;
	
	private PaymentOrdersDao paymentOrdersDao = new PaymentOrdersDao();
	private CyclesDao cyclesDao = new CyclesDao();

	public MbPaymentOrderDetails(){
		language = SessionWrapper.getField("language");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
	}

    @Override
    public void clearFilter() {
        //do nothing
    }

    public void initializeModalPanel(){
		logger.debug("MbPaymentOrderDetails initializing...");
		reset();
		if (FacesUtils.getSessionMapValue(CTX_MENU_PARAMS) != null) {
			Map<String, Object> ctxMenuParams = (Map<String, Object>) FacesUtils
					.getSessionMapValue(CTX_MENU_PARAMS);
			FacesUtils.setSessionMapValue(CTX_MENU_PARAMS, null);
			if (ctxMenuParams.containsKey(OBJECT_ID)){
				id = (Long) ctxMenuParams.get(OBJECT_ID);
			} 
		} else {
			if (FacesUtils.getSessionMapValue(OBJECT_ID) != null) {
				id = (Long) FacesUtils.getSessionMapValue(OBJECT_ID);
			}	
		}
		if (id == null){
			objectIdIsNotSet();
		}
	}	
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}	
	
	public void setId(Long id){
		this.id = id;
	}
	
	public PmoPaymentOrder getPaymentOrder(){
		if (paymentOrder == null && id != null){
			SelectionParams sp = new SelectionParams(
				new Filter("id", id),
				new Filter("lang", language)
			);
			PmoPaymentOrder[] orders = paymentOrdersDao.getPaymentOrders(userSessionId, sp);
			if (orders.length > 0){
				paymentOrder = orders[0];
			}			
		}
		return paymentOrder;
	}
	
	public PmoTemplate getTemplate(){
		if (template == null && id != null){
			Filter[] filters = new Filter[] { 
					new Filter("id", id),
					new Filter("lang", language) };
			PmoTemplate[] templates = paymentOrdersDao.getTemplates(userSessionId, new SelectionParams(filters));
			if (templates.length > 0){
				template = templates[0];
			}
		}
		return template;
	}
	
	public void reset(){
		template = null;
		paymentOrder = null;
		cycleCounters = null;
		selectedCycleCounter = null;
		cycleItemSelection = null;
	}
	
	public void setLanguage(String language){
		this.language = language;
	}
	
	public String getLanguage(){
		return language;
	}
	
	private CycleCounter[] cycleCounters;
	
	public CycleCounter[] getCycleCounters(){
		if (cycleCounters == null){
			SelectionParams sp = new SelectionParams(
				new Filter("entityType", EntityNames.PAYMENT_ORDER),
				new Filter("objectId", id)
			);
			cycleCounters = cyclesDao.getCycleCounters(userSessionId, sp);
		}
		return cycleCounters;
	}
	
	public List<PmoTemplateParameter> getTemplateParameters(){
		if (templateParameters == null && template != null){
			Filter[] filters = new Filter[] { 
					new Filter("templateId", template.getId()),
					new Filter("lang", language) 
				};
			
			PmoTemplateParameter[] templateParametersArr = paymentOrdersDao.getTemplateParameters(userSessionId, new SelectionParams(filters));
			
			templateParameters = new ArrayList<PmoTemplateParameter>();
			for (PmoTemplateParameter param : templateParametersArr){
				templateParameters.add(param);
			}
		}
		return templateParameters;
	}

	private CycleCounter selectedCycleCounter;
	private CycleCounter editingCycleCounter;
	
	public SimpleSelection getCycleItemSelection() {
		return cycleItemSelection;
	}

	public void setCycleItemSelection(SimpleSelection cycleItemSelection) {
		this.cycleItemSelection = cycleItemSelection;
		if (cycleCounters == null || cycleCounters.length == 0) return;
		selectedCycleCounter = cycleCounters[selectedIdx()];
	}
	
	private Integer selectedIdx(){
		Iterator<Object> keys = cycleItemSelection.getKeys();
		if (!keys.hasNext()) return 0;
		Integer index = (Integer) keys.next();
		return index;
	}
	
	public void editCycleCounter(){	
		editingCycleCounter = (CycleCounter) selectedCycleCounter.clone();
	}
	
	public void saveEditingCycleCounter() throws SystemException{		
		try{
			editingCycleCounter = cyclesDao.modifyCycleCounter(userSessionId, editingCycleCounter);
		} catch (DataAccessException e){
			throw new SystemException(e);
		}
		cycleCounters[selectedIdx()] = editingCycleCounter;
		selectedCycleCounter = editingCycleCounter;
	}
	
	public void resetEditingCycleCounter(){
		editingCycleCounter = null;
	}
	
	public CycleCounter getSelectedCycleCounter(){
		return selectedCycleCounter;
	}
	
	public CycleCounter getEditingCycleCounter(){
		return editingCycleCounter;
	}
}
