package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.EntityOperTypeBundle;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.terminal.MbWzTermDetails;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbOperTypeSelectionStep")
public class MbOperTypeSelectionStep implements CommonWizardStep{

	private static final Logger classLogger = Logger.getLogger(MbOperTypeSelectionStep.class);

	private static final String PAGE_CARD = "/pages/common/wizard/callcenter/cardOperTypeSelectionStep.jspx";
	private static final String PAGE_ACCOUNT = "/pages/common/wizard/callcenter/accOperTypeSelectionStep.jspx";
	private static final String PAGE_TERMINAL = "/pages/common/wizard/callcenter/terminal/termOperTypeSelectionStep.jspx";
	private static final String PAGE_PERSONALIZATION_BATCH ="/pages/common/wizard/callcenter/batch/batchOperTypeSelectionStep.jspx";
	private static final String PAGE_OPERATION_REPROCESS ="/pages/common/wizard/callcenter/operation/operationOperTypeSelectionStep.jspx";
	private static final String PAGE_RECONCILIATION = "/pages/common/wizard/callcenter/reconciliation/rcnOperTypeSelectionStep.jspx";
	private static final String PAGE_DEFAULT ="/pages/common/wizard/callcenter/operTypeSelectionStepBase.jspx";

	public static final String OPERATION = "OPERATION";
	public static final String OBJECT_ID = "OBJECT_ID";
	public static final String OBJECT_ID_NEED = "OBJECT_ID_NEED";
	public static final String OBJECT_TYPE = "OBJECT_TYPE";
	public static final String OBJECT_TYPE_STRICT = "OBJECT_TYPE_STRICT";
	public static final String ENTITY_TYPE = "ENTITY_TYPE";
	public static final String ENTITY_OBJECT_TYPE = "ENTITY_OBJECT_TYPE";
	private static final String INVOKE_METHOD = "INVOKE_METHOD";
	public static final String INST_ID = "INST_ID";
	public static final String MODULE = "MODULE";

	private OperationDao operationDao = new OperationDao();
	private CommonDao commonDao = new CommonDao();

	private long userSessionId;
	private String curLang;
	private Integer instId;
	private List<SelectItem> oprTypes = new ArrayList<SelectItem>(1);
	private EntityOperTypeBundle[] entityOperTypeBundles;
	private String entityType;
	private String entityObjectType;
	private String objectType;
	private Long objectId;
	private Boolean objectIdNeed;
	private Integer bundleId;
	private Map<String, Object> context;
	private boolean objectTypeRestricted;
	
	@Override
	public void init(Map<String, Object> context) {
		classLogger.trace("init...");
		reset();
		resetSteps(context);
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = SessionWrapper.getField("language");
		if (context.containsKey(ENTITY_TYPE)) {
			entityType = (String) context.get(ENTITY_TYPE);
		} else {
			throw new IllegalStateException(ENTITY_TYPE
					+ " is not defined in wizard context");
		}
		if (context.containsKey(ENTITY_OBJECT_TYPE)) {
			entityObjectType = (String) context.get(ENTITY_OBJECT_TYPE);
		} else {
			entityObjectType = null;
		}
		if (context.containsKey(INST_ID)){
			instId = (Integer)context.get(INST_ID);
		}
		if (context.containsKey(OBJECT_TYPE)){
			objectType = (String)context.get(OBJECT_TYPE);
			Boolean objectTypeStrict = (Boolean)context.get(OBJECT_TYPE_STRICT);
			objectTypeRestricted = objectTypeStrict != null && objectTypeStrict;
		}
		if (context.containsKey(OBJECT_ID)) {
			objectId = (Long)context.get(OBJECT_ID);
		} else {
			objectIdNeed = (Boolean)context.get(OBJECT_ID_NEED);
			if (objectIdNeed == null || objectIdNeed) {
				throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
			}
		}
		updateOperTypes();
		updateDetails(context);
		if (EntityNames.CARD.equals(entityType)){
			context.put(MbCommonWizard.PAGE, PAGE_CARD);
		} else if (EntityNames.ACCOUNT.equals(entityType)){
			context.put(MbCommonWizard.PAGE, PAGE_ACCOUNT);
		} else if (EntityNames.TERMINAL.equals(entityType)){
			context.put(MbCommonWizard.PAGE, PAGE_TERMINAL);
		} else if (EntityNames.PERSONALIZATION_BATCH.equals(entityType)) {
			context.put(MbCommonWizard.PAGE, PAGE_PERSONALIZATION_BATCH);
		} else if (EntityNames.OPERATION.equals(entityType)){
			context.put(MbCommonWizard.PAGE, PAGE_OPERATION_REPROCESS);
		} else if (EntityNames.HOST_RECONCILIATION.equals(entityType)){
			context.put(MbCommonWizard.PAGE, PAGE_RECONCILIATION);
		} else {
			context.put(MbCommonWizard.PAGE, PAGE_DEFAULT);
		}

		context.put(MbCommonWizard.FORCE_NEXT, Boolean.TRUE);
		this.context = context;
	}
	
	private void resetSteps(Map<String, Object> context){
		//noinspection unchecked
		ArrayList<CommonWizardStepInfo> steps = ((ArrayList<CommonWizardStepInfo>)context.get(MbCommonWizard.STEPS));
		CommonWizardStepInfo step = steps.get(0);
		steps.clear();
		steps.add(step);
	}

	public void reset(){
		classLogger.trace("reset...");
		bundleId = null;
		entityType = null;
		entityObjectType = null;
		objectType = null;
		context = null;
	}
	
	private void updateOperTypes(){
		classLogger.trace("MbOprTypeSelection::updateOperTypes...");
		oprTypes = new ArrayList<SelectItem>();
		entityOperTypeBundles = getOperationTypesBundles();
		for (EntityOperTypeBundle item : entityOperTypeBundles){
			String label;
			if (item.getName() != null && !item.getName().trim().isEmpty()){
				label = String.format("%s - %s", item.getWizardId(), item.getName());
			} else {
				label = String.format("%s - %s", item.getOperType(), item.getOperTypeName());
			}
			SelectItem si = new SelectItem(item.getId(), label);
			oprTypes.add(si);
		}
	}
	
	private void updateDetails(Map<String, Object> context){
		classLogger.trace("updateDetails...");
		if (EntityNames.CARD.equals(entityType)){
			MbWzCardDetails cardDetails = ManagedBeanWrapper.getManagedBean(MbWzCardDetails.class);
			cardDetails.init(objectId);
		} else if (EntityNames.ACCOUNT.equals(entityType)){
			MbWzAccDetails accDetails = ManagedBeanWrapper.getManagedBean(MbWzAccDetails.class);
			accDetails.init(objectId);
		} else if (EntityNames.TERMINAL.equals(entityType)){
			MbWzTermDetails termDetails = ManagedBeanWrapper.getManagedBean(MbWzTermDetails.class);
			termDetails.init(objectId);
		} else if (EntityNames.HOST_RECONCILIATION.equals(entityType)){
			MbWzRcnDetails rcnDetails = ManagedBeanWrapper.getManagedBean(MbWzRcnDetails.class);
			rcnDetails.init(objectId, (String) context.get(MODULE));
		}
	}
	
	private EntityOperTypeBundle[] getOperationTypesBundles(){
		classLogger.trace("getOperationTypesBundles...");
		EntityOperTypeBundle[] result;
		List<Filter> filters = new ArrayList<Filter>();
		filters.add(new Filter("entityType", entityType));
		filters.add(new Filter("lang", curLang));
		if (objectType != null){
			if (objectTypeRestricted) {
				filters.add(new Filter("objectTypeOnly", objectType));
			} else {
				filters.add(new Filter("objectType", objectType));
			}
		}
		if (entityObjectType != null) {
			filters.add(new Filter("entityObjectTypeOrNull", entityObjectType));
		}
		if (instId != null){
			filters.add(new Filter("instId", instId));
		}
		if (objectId == null && (objectIdNeed == null || !objectIdNeed)){
			filters.add(new Filter("operType", null));
		}
		SelectionParams sp = new SelectionParams(filters);
		result = operationDao.getEntityOperTypeBundles(userSessionId, sp);
		return result;
	}
	
	private CommonWizardStepInfo[] getWizardSteps(Long wizardId){
		classLogger.trace("MbOprTypeSelection::getWizardSteps...");
        Filter[] filters = new Filter[]{new Filter("wizardId", wizardId), new Filter("lang", curLang)};
        SelectionParams params = new SelectionParams();
        params.setFilters(filters);
        params.setSortElement(new SortElement("stepOrder", SortElement.Direction.ASC));
        params.setRowIndexEnd(999);
		return commonDao.getWizardSteps(userSessionId, params);
	}	
	
	@Override
	public Map<String, Object> release(Direction direction) {
		classLogger.trace("release...");
		EntityOperTypeBundle bundle = getBundle();
		List<CommonWizardStepInfo> newSteps = prepareSteps(bundle.getWizardId());
		//noinspection unchecked
		List<CommonWizardStepInfo> steps = (List<CommonWizardStepInfo>) context.get(MbCommonWizard.STEPS);
		steps.addAll(newSteps);
		context.put(MbCommonWizard.STEPS_CHANGED, Boolean.TRUE);
		context.put(INVOKE_METHOD, bundle.getInvokeMethod());
		context.remove(MbCommonWizard.OPER_TYPE);
		if (bundle.getOperType() != null && bundle.getOperType().trim().length() > 0) {
			context.put(MbCommonWizard.OPER_TYPE, bundle.getOperType());
		}
//		context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
		return context;
	}
	
	private List<CommonWizardStepInfo> prepareSteps(Long wizardId){
		classLogger.trace("prepareSteps...");
		return Arrays.asList(getWizardSteps(wizardId));
	}
	
	private EntityOperTypeBundle getBundle(){
		classLogger.trace("getBundle...");
		EntityOperTypeBundle selectedBundle = null;
		for (EntityOperTypeBundle bundle: entityOperTypeBundles){
			if (bundle.getId().equals(bundleId)){
				selectedBundle = bundle;
				break;
			}
		}
		return selectedBundle;
	}
	
	@Override
	public boolean validate() {
		classLogger.trace("validate...");
		throw new UnsupportedOperationException("validate");
	}

	public Integer getBundleId() {
		return bundleId;
	}

	public void setBundleId(Integer bundleId) {
		this.bundleId = bundleId;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public List<SelectItem> getOprTypes() {
		return oprTypes;
	}

	public void setOprTypes(List<SelectItem> oprTypes) {
		this.oprTypes = oprTypes;
	}

	public String getEntityObjectType() {
		return entityObjectType;
	}

	public void setEntityObjectType(String entityObjectType) {
		this.entityObjectType = entityObjectType;
	}
}
