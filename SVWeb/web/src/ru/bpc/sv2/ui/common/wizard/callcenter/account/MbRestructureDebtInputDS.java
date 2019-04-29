package ru.bpc.sv2.ui.common.wizard.callcenter.account;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.accounts.AccountConstants;
import ru.bpc.sv2.common.Currency;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.credit.CreditDetailsRecord;
import ru.bpc.sv2.credit.DppCalculation;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbRestructureDebtInputDS")
public class MbRestructureDebtInputDS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbRestructureDebtInputDS.class);
    public static final String PAGE = "/pages/common/wizard/callcenter/account/restructureDebtInputDS.jspx";
    public static final String CLOSING_BALANCE = "CRD_CLOSING_BALANCE";
    public static final String DPP_CALCULATION = "DPP_CALCULATION";
    public static final String PAYOFF_DATE = "PAYOFF_DATE";
    public static final int UNDEFINED_MODE = 0;
    public static final int COUNT_MODE = 1;
    public static final int AMOUNT_MODE = 2;

    protected CreditDao creditDao = new CreditDao();
    protected AccountsDao accountsDao = new AccountsDao();

    protected Map<String, Object> context;
    protected long userSessionId;
    protected String curLang;
    protected Account account;
    protected Currency currency;
    protected CreditDetailsRecord creditDetails;
    protected DictUtils dictUtils;
    protected Integer usageMode;

    protected DppCalculation calculation;

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");
        reset();
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        curLang = SessionWrapper.getField("language");
        this.context = context;

        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE);
        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
        calculation = new DppCalculation();

        if (context.containsKey(MbCommonWizard.ENTITY_TYPE)) {
            String entityType = (String)context.get(MbCommonWizard.ENTITY_TYPE);
            if (!EntityNames.CREDIT_INVOICE.equalsIgnoreCase(entityType)) {
                throw new IllegalStateException(MbCommonWizard.ENTITY_TYPE + " is not appropriate for wizard context");
            }
        } else {
            throw new IllegalStateException(MbCommonWizard.ENTITY_TYPE + " is not defined in wizard context");
        }

        if (context.containsKey(MbCommonWizard.OBJECT)) {
            creditDetails = (CreditDetailsRecord)context.get(MbCommonWizard.OBJECT);
        } else {
            throw new IllegalStateException(MbCommonWizard.OBJECT + " is not defined in wizard context");
        }
        account = accountById(creditDetails.getAccountId());
        if (account == null) {
            throw new IllegalStateException("Unable to find account with ID " + creditDetails.getAccountId());
        }
        if (!AccountConstants.ACCOUNT_STATUS_ACTIVE.equals(account.getStatus())) {
            throw new IllegalStateException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acc", "status_invalid"));
        }

        currency = CurrencyCache.getInstance().getCurrencyObjectsMap().get(account.getCurrency());
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        if (Direction.FORWARD.equals(direction)) {
            calculation.setInstId(account.getInstId());
            calculation.setAccountId(account.getId());
            calculation.setAccountNumber(account.getAccountNumber());
            calculation.setCurrency(currency.getCode());
            calculation.setDppAmount(getDppAmount());
            calculation = creditDao.getDppCalculation(userSessionId, calculation);
            context.put(DPP_CALCULATION, calculation);
        }
        return context;
    }

    @Override
    public boolean validate() {
        if (calculation == null) {
            FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acc", "initialize_fail"));
        } else if (calculation.getFeeId() == null) {
            FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acc", "interest_rate_not_set"));
        } else if (StringUtils.isEmpty(calculation.getCalcAlgorithm())) {
            FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acc", "dpp_alg_not_set"));
        } else if (calculation.getInstalmentCount() == null && calculation.getInstalmentAmount() == null) {
            FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acc", "count_amount_not_set"));
        } else {
            return true;
        }
        return false;
    }

    public Account getAccount() {
        return account;
    }
    public void setAccount(Account account) {
        this.account = account;
    }

    public Currency getCurrency() {
        return currency;
    }
    public void setCurrency(Currency currency) {
        this.currency = currency;
    }

    public Integer getUsageMode() {
        return usageMode;
    }
    public void setUsageMode(Integer usageMode) {
        this.usageMode = usageMode;
    }

    public DppCalculation getCalculation() {
        return calculation;
    }
    public void setCalculation(DppCalculation calculation) {
        this.calculation = calculation;
    }

    public List<SelectItem> getDppAlgorithms() {
        return getDictUtils().getLov(LovConstants.DPP_ALGORITHMS);
    }

    public List<SelectItem> getInterestRates() {
        if (account != null && account.getId() != null) {
            Map<String, Object> parameters = new HashMap<String, Object>();
            parameters.put("account_id", account.getId());
            return getDictUtils().getLov(LovConstants.DPP_INTEREST_FEES, parameters);
        }
        return new ArrayList<SelectItem>(0);
    }

    private void reset() {
        curLang = null;
        account = null;
        creditDetails = null;
        calculation = null;
        usageMode = UNDEFINED_MODE;
    }

    private Date getSttlDate() {
        UserSession usession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
        return usession.getOpenSttlDate();
    }

    private BigDecimal getDppAmount() {
        List<Filter> filters = new ArrayList<Filter>();
        filters.add(Filter.create("accountId", account.getId()));
        filters.add(Filter.create("payOffDate", (Date)context.get("PAYOFF_DATE")));

        SelectionParams params = new SelectionParams();
        params.setFilters(filters.toArray(new Filter[filters.size()]));

        CreditDetailsRecord[] result = creditDao.getCreditPayOffCur(userSessionId, params);
        if (result != null && result.length > 0) {
            for (CreditDetailsRecord record : Arrays.asList(result)) {
                if (CLOSING_BALANCE.equalsIgnoreCase(record.getSystemName())) {
                    return new BigDecimal(record.getValue()).multiply(new BigDecimal(Math.pow(10, currency.getExponent())));
                }
            }
        } else {
            FacesUtils.addMessageError("DPP amount is not found");
        }
        return null;
    }

    protected Account accountById(Long id) {
        SelectionParams sp = SelectionParams.build("id", id);
        Account[] accounts = accountsDao.getAccounts(userSessionId, sp);
        return (accounts != null && accounts.length != 0) ? accounts[0] : null;
    }

    protected DictUtils getDictUtils(){
        if (dictUtils == null) {
            dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
        }
        return  dictUtils;
    }
}
