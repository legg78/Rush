package ru.bpc.sv2.ui.common.callcenter;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.EntityOperTypeBundle;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbWzCardDetails;
import ru.bpc.sv2.ui.utils.AbstractBean;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbOprTypeSelection")
public class MbOprTypeSelection extends AbstractBean {
	private static final Logger logger = Logger.getLogger(MbOprTypeSelection.class);
	
	private static final String OBJECT_ID = "OBJECT_ID";
	
	private OperationDao operationDao = new OperationDao();
	
	private CommonDao commonDao = new CommonDao();
	
	/*private EntityOperTypeBundle entityOperTypeBundle;*/
	
	private Integer bundleId;
	private List<SelectItem> oprTypes = new ArrayList<SelectItem>(1);

	private long userSessionId;
	private Object curLang;
	
	private String entityType;
	private String objectType;
	private Long objectId;
	private EntityOperTypeBundle[] entityOperTypeBundles;
	
	public MbOprTypeSelection(){
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = SessionWrapper.getField("language");
	}

    @Override
    public void clearFilter() {
        // do nothing
    }

    public void updateOperTypes(){
		logger.trace("MbOprTypeSelection::updateOperTypes...");
		oprTypes = new ArrayList<SelectItem>();
		entityOperTypeBundles = getOperationTypesBundles();
		for (EntityOperTypeBundle item : entityOperTypeBundles){
			String label = null;
			if (item.getName() != null && !item.getName().trim().isEmpty()){
				label = String.format("%s - %s", item.getWizardId(), item.getName());
			} else {
				label = String.format("%s - %s", item.getOperType(), item.getOperTypeName());
			}
			SelectItem si = new SelectItem(item.getId(), label);
			oprTypes.add(si);
		}
		updateDetails();
	}
	
	private void updateDetails(){
		if (EntityNames.CARD.equals(entityType)){
			MbWzCardDetails cardDetails = ManagedBeanWrapper.getManagedBean(MbWzCardDetails.class);
			cardDetails.init(objectId);
		}
	}
	
	private EntityOperTypeBundle[] getOperationTypesBundles(){
		logger.trace("MbOprTypeSelection::test...");
		EntityOperTypeBundle[] result;
		List<Filter> filters = new ArrayList<Filter>();
		filters.add(new Filter("entityType", entityType));
		filters.add(new Filter("lang", curLang));
		if (objectType != null){
			filters.add(new Filter("objectType", objectType));
		}
		SelectionParams sp = new SelectionParams(filters);
		result = operationDao.getEntityOperTypeBundles(userSessionId, sp);
		return result;
	}
	
	private CommonWizardStepInfo[] getWizardSteps(Long wizardId){
		logger.trace("MbOprTypeSelection::getWizardSteps...");
		SelectionParams sp = SelectionParams.build("wizardId", wizardId, "lang", curLang);
		sp.setRowIndexEnd(999);
		CommonWizardStepInfo[] result = commonDao.getWizardSteps(userSessionId, sp);
		return result;
	}
	
	public void select(){
		logger.trace("MbOprTypeSelection::select...");
		Long wizardId = null;
		EntityOperTypeBundle selectedBundle = null;
		for (EntityOperTypeBundle bundle: entityOperTypeBundles){
			if (bundle.getId().equals(bundleId)){
				selectedBundle = bundle;
				break;
			}
		}
		wizardId = selectedBundle.getWizardId();
		String invokeMethod = selectedBundle.getInvokeMethod();
		CommonWizardStepInfo[] steps = getWizardSteps(wizardId);		
		List<CommonWizardStepInfo> stepsList = Arrays.asList(steps);
		Map<String, Object> context = new HashMap<String, Object>();
		context.put(MbCommonWizard.STEPS, stepsList);
		context.put(OBJECT_ID, objectId);
		context.put("INVOKE_METHOD", invokeMethod);
		context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ISS_PARTICIPANT);
		MbCommonWizard mbCommonWizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
		mbCommonWizard.init(context);
		reset();
	}
	
	public void reset(){
		bundleId = null;
		entityType = null;
		objectType = null;
	}
	
	public void cancel(){
		logger.trace("MbOprTypeSelection::cancel...");
		reset();
	}

	public List<SelectItem> getOprTypes() {
		return oprTypes;
	}

	public void setOprTypes(List<SelectItem> oprTypes) {
		this.oprTypes = oprTypes;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public Integer getBundleId() {
		return bundleId;
	}

	public void setBundleId(Integer bundleId) {
		this.bundleId = bundleId;
	}

}
