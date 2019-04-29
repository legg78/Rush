package ru.bpc.sv2.ui.issuing;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.ui.accounts.MbAccountsAllSearchSelect;
import ru.bpc.sv2.ui.credit.debts.MbCreditDebts;
import ru.bpc.sv2.ui.credit.invoices.MbCreditInvoicesSearch;
import ru.bpc.sv2.ui.credit.payments.MbCreditPayments;
import ru.bpc.sv2.ui.dpp.MbDppPaymentPlan;
import ru.bpc.sv2.ui.operations.MbOperations;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbIssSelectObject")
public class MbIssSelectObject extends AbstractBean {
    private static final Logger logger = Logger.getLogger("ISSUING");

    public static final String MODAL_ID = "issComSelectObjectModalPanel";
    public static final String FORM_ID = "issComSelectObjectModalPanelForm";

    private String entityName = null;

    private String accountNumber;
    private String cardNumber;
    private int cardsSize;
    private int accountsSize;
    private Integer instId;
    private List<String> extRerenderList;

    private Account account;
    private Card card;

    private AbstractBean extBean;
    private List<String> rerenderList;
    private boolean noDataFound;

    public MbIssSelectObject() {

    }


    public int load(AbstractBean extBean) {
        clearFilter();

        loadExtBean(extBean);

        searchByAccount();
        if (accountsSize == 0) {
            // if accounts 0 then nothing found then exit
        } else if (accountsSize == 1 || accountsSize == -1) {
            // if founded only one account then auto search by card
            searchByCard();

            if (cardsSize == -1) {
                extSearch();
                return accountsSize;
            } else if (cardsSize == 1) {
                extSearch();
            } else if (cardsSize > 1) {
                setEntityName(EntityNames.CARD);
            }
            return cardsSize;
        } else if (accountsSize > 1) {
            setEntityName(EntityNames.ACCOUNT);
        }
        return accountsSize;
    }


    private void loadExtBean(AbstractBean extBean) {
        this.extBean = extBean;
        if (getExtBean() instanceof MbDppPaymentPlan) {
            MbDppPaymentPlan bean = (MbDppPaymentPlan) getExtBean();
            accountNumber = bean.getFilter().getAccountNumber();
            cardNumber = bean.getFilter().getCardNumber();
            setExtRerenderList(new ArrayList<String>(bean.getRerenderList()));
            getExtRerenderList().add("paymentPlanSearchForm:cardNumber");
            getExtRerenderList().add("paymentPlanSearchForm:accountNumber");

        } else if(getExtBean() instanceof MbCreditPayments) {
            MbCreditPayments bean = (MbCreditPayments) getExtBean();
            accountNumber = bean.getFilter().getAccountNumber();
            cardNumber = bean.getFilter().getCardNumber();
            setExtRerenderList(new ArrayList<String>(bean.getRerenderList()));
            getExtRerenderList().add("paymentsSearchForm:cardNumber");
            getExtRerenderList().add("paymentsSearchForm:accountNumber");

        } else if(getExtBean() instanceof MbCreditDebts) {
            MbCreditDebts bean = (MbCreditDebts) getExtBean();
            accountNumber = bean.getFilter().getAccountNumber();
            cardNumber = bean.getFilter().getCardNumber();
            setExtRerenderList(new ArrayList<String>(bean.getRerenderList()));
            getExtRerenderList().add("debtsSearchForm:cardNumber");
            getExtRerenderList().add("debtsSearchForm:accountNumber");

        } else if(getExtBean() instanceof MbCreditInvoicesSearch) {
            MbCreditInvoicesSearch bean = (MbCreditInvoicesSearch) getExtBean();
            accountNumber = bean.getFilter().getAccountNumber();
            setExtRerenderList(new ArrayList<String>(bean.getRerenderList()));
            getExtRerenderList().add("invoicesSearchForm:cardNumber");

        } else if(getExtBean() instanceof MbOperations) {
            MbOperations bean = (MbOperations) getExtBean();
            accountNumber = bean.getAccountNumber();
            if (MbOperations.SEARCH_TAB_PARTICIPANT.equals(bean.getSearchTabName())) {
                instId = bean.getParticipantFilter().getInstId();
            }
            setExtRerenderList(Arrays.asList(bean.getRerenderList().split(",")));
        }
    }

    private DaoDataModel<?> getExtDataMode() {
        if (getExtBean() instanceof MbDppPaymentPlan) {
            MbDppPaymentPlan bean = (MbDppPaymentPlan) getExtBean();
            return bean.getDataModel();

        } else if(getExtBean() instanceof MbCreditPayments) {
            MbCreditPayments bean = (MbCreditPayments) getExtBean();
            return bean.getPayments();

        } else if(getExtBean() instanceof MbCreditDebts) {
            MbCreditDebts bean = (MbCreditDebts) getExtBean();
            return bean.getDebts();

        } else if(getExtBean() instanceof MbCreditInvoicesSearch) {
            MbCreditInvoicesSearch bean = (MbCreditInvoicesSearch) getExtBean();
            return bean.getInvoices();

        } else if(getExtBean() instanceof MbOperations) {
            MbOperations bean = (MbOperations) getExtBean();
            return bean.getOperations();
        }
        return null;
    }

    private void extSearch() {
        Long accountId = null;
        Integer accountSplitHash = null;
        Long cardId = null;
        String cardNumber = null;
        String accountNumber = null;

        if (account != null) {
            if (accountsSize > 1) {
                accountNumber = account.getAccountNumber();
            }
            accountId = account.getId();
            accountSplitHash = account.getSplitHash();
        }

        if (card != null) {
            if (cardsSize > 1) {
                cardNumber = card.getMask();
            }
            cardId = card.getId();
        }

        if (getExtBean() instanceof MbDppPaymentPlan) {
            MbDppPaymentPlan bean = (MbDppPaymentPlan) getExtBean();
            bean.getFilter().setAccountId(accountId);
            bean.getFilter().setCardId(cardId);
            if (cardNumber != null) bean.getFilter().setCardNumber(cardNumber);
            if (accountNumber != null) bean.getFilter().setAccountNumber(accountNumber);
            bean.search(false);

        } else if(getExtBean() instanceof MbCreditPayments) {
            MbCreditPayments bean = (MbCreditPayments) getExtBean();
            bean.getFilter().setAccountId(accountId);
            bean.getFilter().setCardId(cardId);
            if (cardNumber != null) bean.getFilter().setCardNumber(cardNumber);
            if (accountNumber != null) bean.getFilter().setAccountNumber(accountNumber);
            bean.search(false);

        } else if(getExtBean() instanceof MbCreditDebts) {
            MbCreditDebts bean = (MbCreditDebts) getExtBean();
            bean.getFilter().setAccountId(accountId);
            bean.getFilter().setCardId(cardId);
            if (cardNumber != null) bean.getFilter().setCardNumber(cardNumber);
            if (accountNumber != null) bean.getFilter().setAccountNumber(accountNumber);
            bean.search(false);

        } else if(getExtBean() instanceof MbCreditInvoicesSearch) {
            MbCreditInvoicesSearch bean = (MbCreditInvoicesSearch) getExtBean();
            bean.getFilter().setAccountId(accountId);
            if (accountNumber != null) bean.getFilter().setAccountNumber(accountNumber);
            bean.search(false);

        } else if(getExtBean() instanceof MbOperations) {
            MbOperations bean = (MbOperations) getExtBean();
            bean.setAccountId(accountId);
            bean.setAccountSplitHash(accountSplitHash);
            if (accountNumber != null) bean.setAccountNumber(accountNumber);
            bean.search(false);
        }

        if (!noDataFound) {
            DaoDataModel<?> model = getExtDataMode();
            if (model != null) model.flushCache();
        }

        if (getExtRerenderList() != null) {
            getRerenderList().clear();
            getRerenderList().addAll(getExtRerenderList());
        }
        setEntityName(null);
    }

    private void noDataFound() {
        DaoDataModel<?> model = getExtDataMode();
        if (model == null) return;
        noDataFound = true;
        model.flushCache();
        model.setDataSize(0);
    }

    public boolean isRenderedAccountsTable() {
        return EntityNames.ACCOUNT.equals(entityName) && getAccountsBean().getAccounts().getDataSize() > 1;
    }

    public boolean isRenderedCardsTable() {
        return EntityNames.CARD.equals(entityName) && getCardsBean().getCards().getDataSize() > 1;
    }

    public void select() {
        if (EntityNames.ACCOUNT.equals(entityName)) {
            MbAccountsAllSearchSelect bean = getAccountsBean();
            account = bean.getActiveAccount();
            searchByCard();
            if (cardsSize > 1) {
                setEntityName(EntityNames.CARD);
            } else {
                extSearch();
            }
            accountsSize = 1;
        } else if (EntityNames.CARD.equals(entityName)) {
            MbCardsSearchSelect bean = getCardsBean();
            card = bean.getActiveCard();
            extSearch();
        }
    }

    public boolean isSelectDisabled() {
        if (EntityNames.ACCOUNT.equals(entityName)) {
            MbAccountsAllSearchSelect bean = getAccountsBean();
            if (bean.getActiveAccount() == null) return true;
        } else if (EntityNames.CARD.equals(entityName)) {
            MbCardsSearchSelect bean = getCardsBean();
            if (bean.getActiveCard() == null) return true;
        }
        return false;
    }

    public List<String> getRerenderList() {
        if (rerenderList == null) {
            rerenderList = new ArrayList<String>();
            rerenderList.add(FORM_ID);
            rerenderList.add(MODAL_ID + "Header");
        }
        return rerenderList;
    }

    private void searchByAccount() {
        accountsSize = -1;
        if (!isEmptyString(accountNumber)) {
            MbAccountsAllSearchSelect bean = getAccountsBean();
            bean.clearFilter();
            bean.getFilter().setAccountNumber(accountNumber);
            bean.getFilter().setInstId(instId);
            bean.search();
            accountsSize = bean.getAccounts().getRowCount();
            if (accountsSize == 0) {
                noDataFound();
                return;
            }
            if (accountsSize == 1) account = bean.loadAccount();
        }
    }

    private void searchByCard() {
        cardsSize = -1;
        if (!isEmptyString(cardNumber)) {
            MbCardsSearchSelect bean = getCardsBean();
            bean.clearFilter();
            bean.getFilter().setCardNumber(cardNumber);
            if (account != null) {
                bean.getFilter().setAccountId(account.getId());
            }
            bean.getFilter().setInstId(null);
            bean.search();
            cardsSize = bean.getCards().getRowCount();
            if (cardsSize == 0) {
                noDataFound();
                return;
            }
            if (cardsSize == 1) card = bean.loadCard();
        }
    }

    private boolean isEmptyString(String value) {
        return value == null || "".equals(value);
    }


    @Override
    public void clearFilter() {
        entityName = null;
        accountNumber = null;
        cardNumber = null;
        instId = null;
        extRerenderList = null;
        extBean = null;
        rerenderList = null;
        noDataFound = false;
        account = null;
        card = null;
        cardsSize = -1;
        accountsSize = -1;
    }

    public MbCardsSearchSelect getCardsBean() {
        return ManagedBeanWrapper.getManagedBean(MbCardsSearchSelect.class);
    }

    public MbAccountsAllSearchSelect getAccountsBean() {
        return ManagedBeanWrapper.getManagedBean(MbAccountsAllSearchSelect.class);
    }

    public String getAccountNumber() {
        return accountNumber;
    }

    public void setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
    }


    public String getCardNumber() {
        return cardNumber;
    }

    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public String getEntityName() {
        return entityName;
    }

    public void setEntityName(String entityName) {
        this.entityName = entityName;
    }

    public AbstractBean getExtBean() {
        return extBean;
    }

    public void setExtBean(AbstractBean extBean) {
        this.extBean = extBean;
    }

    public List<String> getExtRerenderList() {
        return extRerenderList;
    }

    public void setExtRerenderList(List<String> extRerenderList) {
        this.extRerenderList = extRerenderList;
    }

    public void setRerenderList(List<String> rerenderList) {
        this.rerenderList = rerenderList;
    }

    public String getModalId() {
        return MODAL_ID;
    }

    public boolean isNoDataFound() {
        return noDataFound;
    }

    public void setNoDataFound(boolean noDataFound) {
        this.noDataFound = noDataFound;
    }

    public int getCardsSize() {
        return cardsSize;
    }

    public void setCardsSize(int cardsSize) {
        this.cardsSize = cardsSize;
    }

    public int getAccountsSize() {
        return accountsSize;
    }

    public void setAccountsSize(int accountsSize) {
        this.accountsSize = accountsSize;
    }
}
