package ru.bpc.sv2.ui.common.wizard.callcenter.account;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.common.Currency;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.ClientIdentificationTypes;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.UserException;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbAccountOperationDS")
public class MbAccountOperationDS extends AbstractWizardStep {
	private static final Logger classLogger = Logger.getLogger(MbAccountOperationDS.class);
	protected String PAGE = "/pages/common/wizard/callcenter/account/amountDS.jspx";
	protected static final String ACCOUNT = "ACCOUNT";
	private String defaultReason;

	protected AccountsDao accountsDao = new AccountsDao();
	protected OperationDao operationDao = new OperationDao();
	private OrgStructDao orgStructDao = new OrgStructDao();
	private AcquiringDao acquiringDao = new AcquiringDao();
	private IntegrationDao integrationDao = new IntegrationDao();
    private ApplicationDao applicationDao = new ApplicationDao();

	protected Account account;
	protected DictUtils dictUtils;
	protected String operReason;
	protected BigDecimal operAmount;
	private Long objectId;
	private Currency currency;
	protected List<SelectItem> operReasons;
	protected String operType;
	protected Date operDate;
	protected Date bookDate;
	protected Date invoiceDate;

	@Override
	public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);
		classLogger.trace("init...");
		defaultReason = null;
		reset();

		getDictUtils();
		String entityType = (String)context.get("ENTITY_TYPE");
		if (!"ENTTACCT".equalsIgnoreCase(entityType)){
			throw new IllegalStateException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "account_error"));
		}
		if (context.containsKey(MbOperTypeSelectionStep.OBJECT_ID)) {
			objectId = (Long) context.get(MbOperTypeSelectionStep.OBJECT_ID);
		} else {
			throw new IllegalStateException(MbOperTypeSelectionStep.OBJECT_ID + " is not defined in wizard context");
		}
		account = accountById(objectId);
		currency = CurrencyCache.getInstance().getCurrencyObjectsMap().get(account.getCurrency());
		String newOperType = (String) context.get(MbCommonWizard.OPER_TYPE);
		if(operType == null || newOperType == null || !operType.equals(newOperType)) {
			operReasons = null;
		}
		operType = newOperType;

		operDate = new Date();
		bookDate = new Date();
		try {
			invoiceDate = integrationDao.getInvoiceDate(userSessionId, entityType, objectId);
		} catch (UserException e) {
			classLogger.trace("Cannot get last invoice date, set date as null");
			invoiceDate = null;
		}
	}

	private Account accountById(Long id) {
		classLogger.trace("accountById...");
		SelectionParams sp = SelectionParams.build("id", id);
		Account[] accounts = accountsDao.getAccounts(userSessionId, sp);
		return accounts.length != 0 ? accounts[0] : null;
	}

	private void reset() {
		account = null;
		operReason = null;
		operAmount = null;
	}

	@Override
	public Map<String, Object> release(Direction direction) {
		classLogger.trace("release...");
		if (direction == Direction.FORWARD) {
			String operStatus = accountOperation();
			getContext().put(WizardConstants.OPER_STATUS, operStatus);
            getContext().put(ACCOUNT, account);
		}
		return getContext();
	}

	private Operation getOperationWithMerchant() {
		Operation operation = new Operation();

		Map <String, Object> accountParamsMap = new HashMap<String, Object>();
		accountParamsMap.put("accountId", account.getId());
		accountParamsMap.put("entityType", EntityNames.MERCHANT);
		Long merchantId = null;
		try {
			merchantId = acquiringDao.getAccountObjectId(userSessionId, accountParamsMap);
		} catch (Exception e) {}

		if (merchantId != null) {
			operation.setMerchantId(merchantId.intValue());
			List<Filter> filters = new ArrayList<Filter>();
			filters.add(new Filter("INST_ID", account.getInstId()));
			filters.add(new Filter("CONTRACT_ID", account.getContractId()));
			filters.add(new Filter("MERCHANT_ID", merchantId));
			filters.add(new Filter("LANG", curLang));
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
			Map<String, Object> paramsMap = new HashMap<String, Object>();
			paramsMap.put("param_tab", (Filter[]) filters.toArray(new Filter[filters.size()]));
			paramsMap.put("tab_name", "CONTRACT");
			Merchant[] merchants = null;

			try {
				merchants = acquiringDao.getMerchantsCur(userSessionId, params, paramsMap);
			} catch (Exception e) {}

			if (merchants != null) {
				for (int i = 0; i < merchants.length; i++) {
					if (merchantId.equals(merchants[i].getId())) {
						operation.setMerchantNumber(merchants[i].getMerchantNumber());
						operation.setMerchantName(merchants[i].getMerchantName());
						break;
					}
				}
			}
		}
		return operation;
	}

	private Integer getInstitutionNetwork(Integer instId) {
		classLogger.trace("Get institution network...");
		Integer result = null;
		SelectionParams sp = SelectionParams.build("instId", instId);
		try {
			Institution[] insts = orgStructDao.getInstitutions(userSessionId, sp, curLang, false);
			if (insts != null) {
				for (int i = 0; i < insts.length; i++) {
					if (insts[i].getNetworkId() != null) {
						result = insts[i].getNetworkId();
						break;
					}
				}
			}
		} catch(Exception e) {
			classLogger.error("", e);
		}
		return result;
	}

	private String accountOperation() {
		classLogger.trace("accountOperation...");
		Operation operation = getOperationWithMerchant();
		if (defaultReason == null) {
			operation.setOperReason(operReason);
		}else{
			operation.setOperReason(defaultReason);
		}
		operation.setMsgType(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
		operation.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
		operation.setSttlType(OperationsConstants.SETTLEMENT_INTERNAL_INTRAINST);
		operation.setOperType(operType);
		operation.setOperCount(1L);
		operation.setOperationDate(operDate);
		operation.setSourceHostDate(bookDate);
		operation.setOperationAmount(operAmount);
		operation.setParticipantType(getContext().get(MbOperTypeSelectionStep.OBJECT_TYPE).toString());
		operation.setCustomerId(account.getCustomerId());
		operation.setClientIdType(ClientIdentificationTypes.ACCOUNT);
		operation.setClientIdValue(account.getAccountNumber());
		operation.setAccountId(account.getId());
		operation.setAccountNumber(account.getAccountNumber());
		operation.setAccountType(account.getAccountType());
		operation.setOperationCurrency(account.getCurrency());
		operation.setIssInstId(account.getInstId());
		operation.setIssNetworkId(getInstitutionNetwork(account.getInstId()));
		operation.setCardNetworkId(operation.getAcqNetworkId());
		operation.setSplitHash(account.getSplitHash());
		if (Participant.ISS_PARTICIPANT.equals(operation.getParticipantType())) {
			operation.setSplitHashIss(account.getSplitHash());
		} else if (Participant.ACQ_PARTICIPANT.equals(operation.getParticipantType())) {
			operation.setSplitHashAcq(account.getSplitHash());
		}
		operation.setAccountAmount(account.getBalance());
		operation.setAccountCurrency(account.getCurrency());

        if (isMaker()) {
            ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, account.getInstId(), getFlowId());
            builder.buildFromOperation(operation, true);
            builder.createApplicationInDB();
            builder.addApplicationObject(account);
            return builder.getApplication().getStatus();
        } else {
            operationDao.addAdjusment(userSessionId, operation);
            return operationDao.processOperation(userSessionId, operation.getId());
        }
	}

	public List<SelectItem> getOperReasons() {
		if (operReasons == null) {
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("oper_type", operType);
			operReasons = getDictUtils().getLov(LovConstants.OPER_REASON, params);
		}
		return operReasons;
	}

	public boolean isOperationDateValid() {
		if (operDate != null && bookDate != null) {
			if (bookDate.getTime() >= operDate.getTime()) {
				if (invoiceDate == null) {
					return true;
				} else if (operDate.getTime() >= invoiceDate.getTime()) {
					return true;
				} else {
					FacesUtils.addMessageError("Operation date cannot be less than last invoice date");
				}
			} else {
				FacesUtils.addMessageError("Operation date cannot be greater than booking date");
			}
		} else {
			FacesUtils.addMessageError("Operation date cannot be empty");
		}
		return false;
	}

	@Override
	public boolean validate() {
		classLogger.trace("validate...");
		return isOperationDateValid();
	}

	public BigDecimal getOperAmount() {
		return operAmount;
	}
	public void setOperAmount(BigDecimal operAmount) {
		this.operAmount = operAmount;
	}

	public String getOperReason() {
		return operReason;
	}
	public void setOperReason(String operReason) {
		this.operReason = operReason;
	}

	public Currency getCurrency() {
		return currency;
	}
	public void setCurrency(Currency currency) {
		this.currency = currency;
	}

	public String getDefaultReason() {
		return defaultReason;
	}
	public void setDefaultReason(String defaultReason) {
		this.defaultReason = defaultReason;
	}

	public Date getOperDate() {
		return operDate;
	}
	public void setOperDate(Date operDate) {
		this.operDate = operDate;
	}

	public Date getBookDate() {
		return bookDate;
	}
	public void setBookDate(Date bookDate) {
		this.bookDate = bookDate;
	}
}
