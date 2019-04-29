package ru.bpc.sv2.ui.dsp;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.application.DspAppPrivileges;
import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.ArrayConstants;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.dsp.DisputeListCondition;
import ru.bpc.sv2.dsp.DisputeParameter;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.TechnicalMessage;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.common.wizard.dispute.MbStopListTypeSelectionStep;
import ru.bpc.sv2.ui.operations.MbTechnicalMessageDetails;
import ru.bpc.sv2.ui.rules.MbDspApplications;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.utils.StringUtils;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.*;

@SuppressWarnings("unused")
@ViewScoped
@ManagedBean (name = "mbAssociatedOperations")
public class MbAssociatedOperations extends AbstractTreeBean<Operation> {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");
	public static final String FIELD_CARD_NUMBER = "CARD_NUMBER";

	private static final int INIT_WRITE_OFF_POSITIVE = 1559;
	private static final int INIT_WRITE_OFF_NEGATIVE = 1562;
	private static final int GEN_WRITE_OFF_POSITIVE = 1560;
	private static final int GEN_WRITE_OFF_NEGATIVE = 1561;

	private static final int WRITE_OFF_FLOW_ID = 1605;

	private OperationDao operationDao = new OperationDao();
	private DisputesDao disputesDao = new DisputesDao();
	private VisaDao visaDao = new VisaDao();
	private CommonDao commonDao = new CommonDao();
	private ApplicationDao applicationDao = new ApplicationDao();

	private Long operId;
	private Long disputeId;
	private String cardMask;
	private String cardNumber;
	private String disputeModule;

	private Integer initRule;
	private Integer oldInitRule;
	private Map<Integer, Integer> genRulesMap;
	private Map<Integer, String> msgTypesMap;
	private List<DisputeParameter> disputeParams;
	private int wizardStep;
	private Map<Integer, Boolean> passedSteps;
	private Map<Integer, List<SelectItem>> lovs;
	private static final int wizardSteps = 2;
	private Operation[] prevOpers;
	private DspApplication parentDispute;

	private boolean isEditing = false;
	private boolean needRefreshApplications = false;

	private static final LinkedHashMap<String, Boolean> CURRENCY_FIELD_DB_NAME = new LinkedHashMap<String, Boolean>();
	private static final LinkedHashMap<String, Boolean> AMOUNT_FIELD_DB_NAME = new LinkedHashMap<String, Boolean>();

    static{
        CURRENCY_FIELD_DB_NAME.put("C_15", true);
        CURRENCY_FIELD_DB_NAME.put("DE_049", true);
        CURRENCY_FIELD_DB_NAME.put("PDS_0149_1", true);
        CURRENCY_FIELD_DB_NAME.put("OPER_CURRENCY", true);
        AMOUNT_FIELD_DB_NAME.put("C_14", true);
        AMOUNT_FIELD_DB_NAME.put("DE_004", true);
        AMOUNT_FIELD_DB_NAME.put("DE_030_1", true);
        AMOUNT_FIELD_DB_NAME.put("OPER_AMOUNT", true);
    }

	private boolean showConfirm = false;
	private boolean visaOperation;
	private List<SelectItem> disputeVisaReasonCodesThatSendCardNumber;
	private static final List<Integer> visaDisputesThatNeedCheckForReasonCode = Arrays.asList(1544, 1546);
	private String savedCardNumber;
	private boolean cardNumberInitiallyEnabled;

	private boolean disabledCreateButton = false;
	private boolean disabledDocumentsButton = false;

	public LinkedHashMap<String, Boolean> getAmountFieldDbName() {
        return AMOUNT_FIELD_DB_NAME;
    }

    public LinkedHashMap<String, Boolean> getCurrencyFieldDbName() {
        return CURRENCY_FIELD_DB_NAME;
    }

    public MbAssociatedOperations() {

	}

	public Operation getNode() {
//		if (currentNode == null) {
//			currentNode = new Operation();
//		}
		return currentNode;
	}
	
	public void setNode(Operation node) {
		try {
			if (node == null)
				return;
			
//			boolean changeSelect = false;
//			if (!node.getId().equals(currentNode.getId())) {
//				changeSelect = true;
//			}
			
			this.currentNode = node;
			setBeans();
			
//			if (changeSelect) {
//				detailNode = (Agent) currentNode.clone();
//			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	@Override
	protected void loadTree() {
		try {
			coreItems = new ArrayList<Operation>();

			if (!searching)
				return;

			setFilters();

			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			Operation[] opers = operationDao.getAssociatedOperations(userSessionId, params);
			if (opers != null && opers.length > 0) {
				addNodes(0, coreItems, opers);
				findNewNode(opers);
				if (nodePath == null) {
					if (currentNode == null) {
						currentNode = coreItems.get(0);
//						detailNode = (Operation) currentNode.clone();
						setNodePath(new TreePath(currentNode, null));
					} else {
						if (currentNode.getParentId() != null) {
							setNodePath(formNodePath(opers));
						} else {
							setNodePath(new TreePath(currentNode, null));
						}
					}
				}
				setBeans();
			}
			prevOpers = opers;
			treeLoaded = true;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	@Override
	protected int addNodes(int startIndex, List<Operation> branches, Operation[] items) {
//      int counter = 1;
		int i;
		int level = items[startIndex].getLevel();

		for (i = startIndex; i < items.length; i++) {
			if (items[i].getLevel() != level) {
				break;
			}
			branches.add(items[i]);
			addMatchingOperation(items[i]);
			if ((i + 1) != items.length && items[i + 1].getLevel() > level) {
				if (items[i].getChildren() == null) {
					items[i].setChildren(new ArrayList<Operation>());
				}
				i = addNodes(i + 1, items[i].getChildren(), items);
			}
//          counter++;
		}
		return i - 1;
	}

	private void addMatchingOperation(Operation oper) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", curLang);
		filters[1] = new Filter("matchId", oper.getMatchId());
		
		SelectionParams params = new SelectionParams(filters);
		try {
			List<Operation> matchedOpers = operationDao.getOperations(userSessionId, params, curLang);
			if (matchedOpers.size() > 0) {
				ArrayList<Operation> children = new ArrayList<Operation>();
				children.add(matchedOpers.get(0)); // there is at most only one operation with matchId = oper.getId()
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}
	
	/**
	 * A way to select node after we've created a new one when we can't get this new node directly.
	 * 
	 * @param newOpers
	 */
	private void findNewNode(Operation[] newOpers) {
		if (prevOpers == null || prevOpers.length == 0) {
			return;
		}
		
		List<Operation> unique = new ArrayList<Operation>();
		for (Operation newOper : newOpers) {
			boolean exists = false;
			for (Operation oldOper : prevOpers) {
				if (oldOper.getId().equals(newOper.getId())) {
					exists = true;
					break;
				}
			}
			if (!exists) {
				unique.add(newOper);
			}
		}
		if (unique.size() == 1) {
			// select new operation only if there's only one new operation 
			// because only this way we can be sure that it's our just created operation
			currentNode = unique.get(0);
			nodePath = null;
		}
	}
	
	@Override
	public TreePath getNodePath() {
		return nodePath;
	}

	@Override
	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("lang", curLang);
		filters.add(paramFilter);

		paramFilter = new Filter("operId", operId);
		filters.add(paramFilter);
	}
	
	private Operation getOperation() {
		return (Operation) Faces.var("oper");
	}

	public boolean getNodeHasChildren() {
		return (getOperation() != null) && getOperation().isHasChildren();
	}

	public List<Operation> getNodeChildren() {
		Operation oper = getOperation();
		if (oper == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return oper.getChildren();
		}
	}

	public void setBeans() {
		
	}

	public void clearBeans() {
		
	}

	@Override
	public void clearFilter() {
		operId = null;
		needRefreshApplications = false;
		clearState();
	}

	public Long getOperId() {
		return operId;
	}
	public void setOperId(Long operId) {
		if (!CommonUtils.equals(operId, this.operId)) {
			visaOperation =  operId != null && visaDao.isVisaOperation(userSessionId, operId);
		}
		this.operId = operId;
	}

	public Long getDisputeId() {
		return disputeId;
	}
	public void setDisputeId(Long disputeId) {
		this.disputeId = disputeId;
	}

	public String getCardMask() {
		return cardMask;
	}
	public void setCardMask(String cardMask) {
		this.cardMask = cardMask;
	}

	public String getCardNumber() {
		return cardNumber;
	}
	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}

	public void clearState() {
		nodePath = null;
		currentNode = null;
		coreItems = null;
		treeLoaded = false;
		searching = false;
		prevOpers = null;
		
		clearBeans();
	}

	public void search() {
		clearState();
		
		searching = true;
	}
	
	public void startDispute() {
		initRule = null;
		isEditing = false;
		wizardStep = 1;
		passedSteps = new HashMap<Integer, Boolean>(); 
	}

	public void next() {
		if (wizardStep == 1 && !initRule.equals(oldInitRule) && checkDuplicatedMessage()){
			showConfirm = true;
			return;
		}
		doNext();
	}

	public void doNext() {
		showConfirm = false;
		passedSteps.put(wizardStep, Boolean.TRUE);

		if (wizardStep == 1 && (!passedSteps.containsKey(wizardStep + 1) || !initRule.equals(oldInitRule))) {
			oldInitRule = initRule;
			// if we first time moved to the next step or if we changed operation type on first step
			prepareDispute();
		}

		wizardStep++;
	}

	private boolean checkDuplicatedMessage(){
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("operId", operId);
		params.put("msgType", msgTypesMap.get(initRule));
		params.put("params", new HashMap<String, Object>());
		boolean check = false;
		try {
			check = disputesDao.checkDuplicatedMessage(userSessionId, params);
		} catch (UserException e) {
			logger.debug(e);
			FacesUtils.addMessageError(e);
		}
		return check;
	}
	
	public void back() {
		passedSteps.put(wizardStep, Boolean.TRUE); // to keep parameters if they were already filled
		wizardStep--;
	}

	public List<SelectItem> getOperationTypes() {
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("operId", (currentNode != null) ? currentNode.getId() : null);
		params.put("lang", userLang);

		try {
			List<DisputeListCondition> condList = disputesDao.getDisputesList(userSessionId, params);
			List<SelectItem> result = new ArrayList<SelectItem>(condList.size());
			genRulesMap = new HashMap<Integer, Integer>(condList.size());
			msgTypesMap = new HashMap<Integer, String>(condList.size());

			for (DisputeListCondition cond : condList) {
				result.add(new SelectItem(cond.getInitRule(), cond.getType()));
				genRulesMap.put(cond.getInitRule(), cond.getGenRule());
				msgTypesMap.put(cond.getInitRule(), cond.getMsgType());
			}
			return result;
		} catch (Exception e) {
			logger.error("", e);
		}

		return new ArrayList<SelectItem>(0);
	}

    private String selectedOperationCurrency;

    public String getSelectedOperationCurrency() {
        return selectedOperationCurrency;
    }

    public void setSelectedOperationCurrency(String selectedOperationCurrency) {
        this.selectedOperationCurrency = selectedOperationCurrency;
    }

    public String getCurrencyExponent() {
        if(selectedOperationCurrency == null) return "2";
        return CurrencyCache.getInstance().getCurrencyObjectsMap().get(selectedOperationCurrency).getExponent().toString();
    }

    public void lovValueChanged(DisputeParameter param){
	    if (CURRENCY_FIELD_DB_NAME.containsKey(param.getSystemName())) {
		    selectedOperationCurrency = param.getValueV();
	    }
	    if (param.getSystemName().equals("REASON_CODE") && visaOperation && visaDisputesThatNeedCheckForReasonCode.contains(initRule)) {
		    if (disputeVisaReasonCodesThatSendCardNumber == null) {
			    disputeVisaReasonCodesThatSendCardNumber = ManagedBeanWrapper.getManagedBean(DictUtils.class).getArray(ArrayConstants.DISPUTE_VISA_REASON_CODES_THAT_SEND_CARD_NUMBER);
		    }
		    boolean cardIsMandatory = param.getValueV() == null;
		    for (SelectItem item : disputeVisaReasonCodesThatSendCardNumber) {
			    if (item.getValue() != null && item.getValue().toString().equals(param.getValueV())) {
				    cardIsMandatory = true;
				    break;
			    }
		    }
		    for (DisputeParameter dParam : disputeParams) {
			    if (dParam.getSystemName().equals(FIELD_CARD_NUMBER)) {
				    boolean wasEditable = Boolean.TRUE.equals(dParam.getEditable());
				    if (wasEditable) {
					    savedCardNumber = dParam.getValueV();
				    }
				    dParam.setMandatory(cardIsMandatory);
				    if (!cardIsMandatory) {
					    dParam.setValueV(null);
					    dParam.setEditable(false);
				    } else {
					    dParam.setEditable(cardNumberInitiallyEnabled);
					    dParam.setValueV(savedCardNumber);
				    }
			    }
		    }
	    }
    }

	public DspApplication getParentDispute() {
		return parentDispute;
	}
	public void setParentDispute(DspApplication parentDispute) {
		this.parentDispute = parentDispute;
	}

	private void prepareDispute() {
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("operId", (currentNode != null) ? currentNode.getId() : null);
		params.put("procId", initRule);
		params.put("lang", userLang);

		try {
			disputeParams = disputesDao.prepareDispute(userSessionId, params);

			lovs = new HashMap<Integer, List<SelectItem>>();
			for (DisputeParameter param : disputeParams) {
				if (param.getLovId() != null) {
					lovs.put(param.getLovId(), getDictUtils().getLov(param.getLovId()));
					param.setEditableLov(isLovEditable(param.getLovId().longValue()));
				}
				if(CURRENCY_FIELD_DB_NAME.containsKey(param.getSystemName())) {
					selectedOperationCurrency = param.getValueV();
				}
				if (param.getSystemName().equals(FIELD_CARD_NUMBER)) {
					cardNumberInitiallyEnabled = Boolean.TRUE.equals(param.getEditable());
					savedCardNumber = param.getValueV();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
	}

	private boolean isGeneralProcedure(Integer procId) {
		if (procId != null) {
			if (INIT_WRITE_OFF_POSITIVE == procId ||
				INIT_WRITE_OFF_NEGATIVE == procId ||
				GEN_WRITE_OFF_POSITIVE == procId ||
				GEN_WRITE_OFF_NEGATIVE == procId) {
				Map<String, Boolean> role = ((UserSession)ManagedBeanWrapper.getManagedBean("usession")).getInRole();
				if (role != null && role.get(DspAppPrivileges.ADD_DISPUTE_WRITEOFF)) {
					return true;
				}
				return false;
			}
		}
		return true;
	}

	private void execGeneralDispute() {
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("operId", (currentNode != null) ? currentNode.getId() : null);
		params.put("initRule", initRule);
		params.put("genRule", genRulesMap.get(initRule));
		params.put("isEdit", isEditing);

		Map<String, Object> disputeParamsMap = new HashMap<String, Object>(disputeParams.size());
		for (DisputeParameter param : disputeParams) {
			if (param.getValueN() != null) {
				if (AMOUNT_FIELD_DB_NAME.containsKey(param.getSystemName())) {
					param.setValueN(new BigDecimal(param.getValueN().longValue()));
				}
				disputeParamsMap.put(param.getSystemName(), param.getValueN());
			} else if (param.getValueV() != null) {
				if (param.isRaw()) {
					StringUtils utils = new StringUtils();
					disputeParamsMap.put(param.getSystemName(), utils.getHexString1(param.getValueV().getBytes()));
				} else {
					disputeParamsMap.put(param.getSystemName(), param.getValueV());
				}
			} else if (param.getValueD() != null) {
				disputeParamsMap.put(param.getSystemName(), param.getValueD());
			} else if (param.getLovValue() != null) {
				disputeParamsMap.put(param.getSystemName(), param.getLovValue());
			} else {
				disputeParamsMap.put(param.getSystemName(), param.getValue());
			}
		}
		params.put("params", disputeParamsMap);

		try {
			disputesDao.execDispute(userSessionId, params);
			loadTree();
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public List<SelectItem> autocomplete(Object suggest) {
		Map<String,String> params = FacesContext.getCurrentInstance().getExternalContext().getRequestParameterMap();
		String lovIdParam = params.get("lovId");
		if (lovIdParam != null && org.apache.commons.lang3.StringUtils.isNumeric(lovIdParam)) {
			Integer lovId = Integer.parseInt(lovIdParam);
			if (suggest != null) {
				List<SelectItem> filetLovs = lovs.get(lovId);
				List<SelectItem> result = new ArrayList<SelectItem>();
				for (SelectItem selectItem : filetLovs)
					if (selectItem.getValue().toString().contains(suggest.toString()))
						result.add(selectItem);
				return result;
			} else {
				return lovs.get(lovId);
			}
		}
		return new ArrayList<>();
	}

	private void execFinancialRequest() {
		try {
			int instId;
			if (parentDispute != null && parentDispute.getInstId() != null) {
				instId = parentDispute.getInstId().intValue();
			} else {
				instId = disputesDao.getDisputeInstId(userSessionId, currentNode.getId());
			}

			if (currentNode.getDisputeId() == null && parentDispute != null) {
				currentNode.setDisputeId(parentDispute.getId());
			}

			if (disputeParams != null) {
				for (DisputeParameter param : disputeParams) {
					if (AppElements.OPER_AMOUNT.equals(param.getSystemName())) {
						currentNode.setOperAmount(param.getValueN());
					} else if (AppElements.OPER_CURRENCY.equals(param.getSystemName())) {
						currentNode.setOperCurrency(param.getValueV());
					}
				}
			}

			ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, instId, WRITE_OFF_FLOW_ID);
			builder.buildFromOperation(currentNode, true);
			builder.createApplicationInDB();
			builder.addApplicationObject(currentNode);
		} catch (Exception e) {
			FacesUtils.addMessageError(e.getLocalizedMessage());
			logger.error("", e);
		}
	}

	public void finish() {
		if (isGeneralProcedure(genRulesMap.get(initRule))) {
			execGeneralDispute();
		} else {
			execFinancialRequest();
		}

		if (isNeedRefreshApplications()) {
			MbDspApplications dspApplications = ManagedBeanWrapper.getManagedBean(MbDspApplications.class);
			dspApplications.refreshActiveDspApplications();
		}
	}

	public List<DisputeParameter> getDisputeParams() {
		return disputeParams;
	}

	public void setDisputeParams(List<DisputeParameter> disputeParams) {
		this.disputeParams = disputeParams;
	}

	public boolean isDisputeParamsEmpty() {
		return disputeParams == null || disputeParams.isEmpty();
	}
	
	public int getWizardStep() {
		return wizardStep;
	}
	
	public Map<Integer, List<SelectItem>> getLovs() {
		if (lovs == null) {
			lovs = new HashMap<Integer, List<SelectItem>>(0);
		}
		return lovs;
	}
	
	public boolean isHasNextInWizard() {
		return wizardStep < wizardSteps;
	}
	public boolean isHasBackInWizard() {
		return !isEditing && (wizardStep > 1);
	}

	public Integer getInitRule() {
		return initRule;
	}
	public void setInitRule(Integer initRule) {
		this.initRule = initRule;
	}

	public String getDisputeModule() {
		return disputeModule;
	}
	public void setDisputeModule(String disputeModule) {
		this.disputeModule = disputeModule;
	}

	public boolean isShowConfirm() {
		return showConfirm;
	}

	public void documentsUnloaded() {
		if (currentNode != null) {
			try {
				FlexFieldData ffdata = new FlexFieldData();
				ffdata.setDataType(DataTypes.NUMBER);
				ffdata.setSystemName("IS_DOCUMENT_UPUNLOADED");
				ffdata.setObjectId(currentNode.getId());
				if (currentNode.getDocumentsUnloaded() == null) {
					currentNode.setDocumentsUnloaded(true);
				}
				ffdata.setSeqNum(1);
				ffdata.setValueN(currentNode.getDocumentsUnloaded() ? 0 : 1);
				ffdata.setEntityType(EntityNames.OPERATION);
				commonDao.setFlexFieldData(userSessionId, ffdata);
				search();
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
			}
		}
	}

	public void selectStopListType() {
		CommonWizardStepInfo step = new CommonWizardStepInfo();
		step.setOrder(0);
		step.setSource(MbStopListTypeSelectionStep.class.getSimpleName());
		step.setName(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "select_stop_list_type"));
		List<CommonWizardStepInfo> stepsList = new ArrayList<CommonWizardStepInfo>();
		stepsList.add(step);
		Map<String, Object> context = new HashMap<String, Object>();
		context.put(MbCommonWizard.STEPS, stepsList);
		context.put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.STOP_LIST);
		context.put(MbOperTypeSelectionStep.OBJECT_ID, disputeId);
		context.put("CARD_NUMBER", cardNumber);
		context.put("CARD_MASK", cardMask);
		if (getDisputeModule() != null && getDisputeModule().equals(ApplicationConstants.TYPE_ACQUIRING)) {
			context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ACQ_PARTICIPANT);
		} else {
			context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ISS_PARTICIPANT);
		}
		MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
		wizard.init(context);
	}

	public void putIntoStopList() {
		logger.trace("New card has been put into stop list");
	}

	public boolean isEditable() {
		if (getNode() != null) {
			try {
				return disputesDao.isItemEditable(userSessionId, getNode().getId());
			} catch (Exception e) {
				logger.debug("", e);
			}
		}
		return false;
	}

	public void removeItem() {
		if (getNode() != null) {
			try {
				disputesDao.removeItem(userSessionId, getNode().getId());
				removeItemTree(coreItems, getNode().getId());
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e.getLocalizedMessage());
			}
		}
	}

	private boolean removeItemTree(List<Operation> items, Long operId) {
		boolean isRemoved = false;
		if(items != null) {
			for (int i = 0; i < items.size() && !isRemoved; ++i) {
				if (items.get(i).getId().equals(operId)) {
					items.remove(i);
					isRemoved = true;
				} else isRemoved = removeItemTree(items.get(i).getChildren(), operId);
			}
		}
		return isRemoved;
	}

	public void getDisputeRule() {
		if (getNode() != null) {
			try {
				startDispute();
				isEditing = true;
				oldInitRule = initRule;

				Map<String, Object> map = disputesDao.getDisputeRule(userSessionId, getNode().getId());
				initRule = (map.get("initRule") != null) ? (Integer)map.get("initRule") : null;
				if (map.get("genRule") != null) {
					if (genRulesMap == null) {
						genRulesMap = new HashMap<Integer, Integer>(1);
					} else {
						genRulesMap.remove(initRule);
					}
					genRulesMap.put(initRule, (Integer)map.get("genRule"));
				}

				passedSteps.put(wizardStep, Boolean.TRUE);
				prepareDispute();
				wizardStep++;
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e.getLocalizedMessage());
			}
		}
	}

	public void setDisabledCreateButton(boolean disabledCreateButton) {
		this.disabledCreateButton = disabledCreateButton;
	}

	public boolean isDisabledDocumentsButton() {
		return disabledDocumentsButton || getNode() == null;
	}

	public void setDisabledDocumentsButton(boolean disabledDocumentsButton) {
		this.disabledDocumentsButton = disabledDocumentsButton;
	}

	public boolean isNeedRefreshApplications() {
		return needRefreshApplications;
	}

	public void setNeedRefreshApplications(boolean needRefreshApplications) {
		this.needRefreshApplications = needRefreshApplications;
	}

	public boolean isLovEditable(Long lovId) {
		try {
			return commonDao.isLovEditable(userSessionId, lovId);
		} catch (Exception e) {
			logger.debug("", e);
		}
		return false;
	}

	public boolean isDisabled(String component) {
		boolean result = false;
		if("showDetails".equals(component)) {
			if (currentNode == null || OperationsConstants.MESSAGE_TYPE_PRESENTMENT.equals(currentNode.getMsgType()) &&
					!(OperationsConstants.FEE_COLLECTION_CREDIT_TO_ORIGINATOR.equals(currentNode.getOperType()) ||
					OperationsConstants.FEE_COLLECTION_DEBIT_TO_ORIGINATOR.equals(currentNode.getOperType()))) {
				result = true;
			}
		} else if ("createBtn".equals(component)) {
			result = disabledCreateButton || operId == null;
		} else if ("changeBtn".equals(component) || "removeBtn".equals(component)) {
			result = !isEditable();
		} else if ("stopListBtn".equals(component)) {
			result = !disputesDao.isPutStopListEnabled(userSessionId, currentNode != null ? currentNode.getDisputeId() : null);
		} else if ("documentsUnloaded".equals(component)) {
			result = disabledDocumentsButton || currentNode == null || !disputesDao.isDocExportImportEnabled(userSessionId, currentNode.getId());
		}
		return result;
	}

	private TechnicalMessage getTechnicalMessageByOperId(Long operId) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", userLang);
		filters[1] = new Filter("operId", operId);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			TechnicalMessage[] technicalMessages = operationDao.getTechnicalMessages(userSessionId, params);
			if (technicalMessages != null && technicalMessages.length > 0) {
				return technicalMessages[0];
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return null;
	}

	public void showDetails() {
    	TechnicalMessage message = getTechnicalMessageByOperId(currentNode.getId());
    	if (message != null) {
			MbTechnicalMessageDetails techMessages = (MbTechnicalMessageDetails) ManagedBeanWrapper.getManagedBean("mbTechnicalMessageDetails");
			techMessages.clearFilter();
			techMessages.setFilter(message);
			techMessages.search();
		}
	}
}
