package ru.bpc.sv2.ui.operations;

import ru.bpc.sv2.application.ApplicationPrivConstants;
import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.operations.OperationPrivConstants;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.pmo.PmoPaymentOrder;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.reports.RptDocument;
import ru.bpc.sv2.tags.Tag;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import java.util.HashMap;

@ViewScoped
@ManagedBean (name = "MbOperationSearchModal")
public class MbOperationSearchModal extends MbOperations {
    private static final long serialVersionUID = 1L;
    private String beanName;
    private String methodName;
    private DspApplication disputeFilter;

    public MbOperationSearchModal() {
        super();
        searchTabName = SEARCH_TAB_DISPUTE;
    }

    public DspApplication getDisputeFilter() {
        if (disputeFilter == null) {
            disputeFilter = new DspApplication();
        }
        return disputeFilter;
    }
    public void setDisputeFilter(DspApplication disputeFilter) {
        this.disputeFilter = disputeFilter;
    }

    @Override
    public void clearFilter() {
        curLang = userLang;
        setFilter(new Operation());
        setHostDateFrom(null);
        setHostDateTo(null);
        setOperDateFrom(null);
        setOperDateTo(null);
        setDocumentFilter(new RptDocument());
        setDisputeFilter(new DspApplication());
        setParticipantFilter(new Participant());
        setPmoFilter(new PmoPaymentOrder());
        setTagFilter(new Tag());
        setCustomerFilter(new Customer());
        setParticipantCustomerId(null);
        setParticipantCustomerInfo(null);
        setParticipantCustomerNumber(null);
        setFilterCustomerNumber(null);
        setFilterCustomerInfo(null);
        setFilterRecieverCustomerNumber(null);
        setFilterRecieverCustomerInfo(null);
        setRrn(null);
        setArn(null);
        setAuthCode(null);
        setReversal(null);
        clearState();
    }
    @Override
    public void setFilters() {
        paramMap = new HashMap<String, Object>();
        if (isSearchByDocument()) {
            setFiltersOperation(false);
            setFiltersDocument(false);
            paramMap.put("tab_name", "DOCUMENT");
        } else if (isSearchByPaymentOrder()) {
            setFiltersOperation(false);
            setFiltersPmo(false);
            paramMap.put("tab_name", "PAYMENT_ORDER");
        } else if (isSearchByParticipant()) {
            setFiltersOperation(false);
            setFiltersParticipant(false);
            paramMap.put("tab_name", "PARTICIPANT");
        } else if (isSearchByTag()) {
            setFiltersOperation(false);
            setFiltersTag(false);
            paramMap.put("tab_name", "TAG");
        } else if (isSearchByCustomer()) {
            setFiltersOperation(false);
            setFiltersCustomer(false);
            paramMap.put("tab_name", "PARTICIPANT");
        } else if (isSearchByDispute()) {
            setFiltersOperation(false);
            setFiltersDispute(false);
            paramMap.put("tab_name", "DISPUTE");
        } else {
            setFiltersOperation(true);
        }
        if (disputeFilter.getSubType().equals(ApplicationConstants.TYPE_ISSUING)) {
            filters.add(new Filter("PARTICIPANT_MODE", "PRTYISS"));
        } else {
            filters.add(new Filter("PARTICIPANT_MODE", "PRTYACQ"));
        }
    }

    @Override
    public String getBeanName() {
        if (beanName == null || beanName.equals("")) {
            return "MbAppWizDspNew";
        }
        return beanName;
    }
    @Override
    public void setBeanName(String beanName) {
        this.beanName = beanName;
    }

    @Override
    public String getMethodName() {
        if (methodName == null || methodName.equals("")) {
            return "selectOperation";
        }
        return methodName;
    }
    @Override
    public void setMethodName(String methodName) {
        this.methodName = methodName;
    }


    @Override
    public String getPrivName() {
        if (isSearchByDispute()) {
            return ApplicationPrivConstants.VIEW_DISPUTE_APPLICATIONS;
        } else if (isIssOperation()) {
            return OperationPrivConstants.VIEW_ISSUING_OPERATIONS;
        } else if (isAcqOperation()) {
            return OperationPrivConstants.VIEW_ACQUIRING_OPERATIONS;
        } else {
            return OperationPrivConstants.VIEW_OPERATION;
        }
    }

    public void searchByDispute() {
        searchType = EntityNames.OPERATION;
        searchTabName = SEARCH_TAB_DISPUTE;
        toSetForceSearch();
        search();
    }

    protected void setFiltersDispute(boolean clearFilters) {
        getDisputeFilter();
        Filter paramFilter;
        if (disputeFilter.getCardMask() != null && disputeFilter.getCardMask().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setValue(disputeFilter.getCardMask().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
            paramFilter.setElement("CARD_MASK");
            paramFilter.setCondition("like");
            filters.add(paramFilter);
        }
        if (accountId != null) {
            paramFilter = new Filter("ACCOUNT_ID", accountId);
            filters.add(paramFilter);
        } else if (accountNumber != null && accountNumber.trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("ACCOUNT_NUMBER");
            paramFilter.setCondition("=");
            paramFilter.setValue(accountNumber.trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
            if (((String) paramFilter.getValue()).indexOf("%") != -1 || accountNumber.indexOf("?") != -1) {
                paramFilter.setCondition("like");
            }
            filters.add(paramFilter);
        }
        if (accountSplitHash != null) {
            filters.add(new Filter("SPLIT_HASH", accountSplitHash));
        }
        if (disputeFilter.getCustomerId() != null) {
            filters.add(new Filter("CUSTOMER_ID", disputeFilter.getCustomerId()));
        }
        if (disputeFilter.getCustomerNumber() != null && !disputeFilter.getCustomerNumber().trim().isEmpty()) {
            paramFilter = new Filter();
            paramFilter.setValue(disputeFilter.getCustomerNumber().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
            paramFilter.setElement("CUSTOMER_NUMBER");
            paramFilter.setCondition("like");
            filters.add(paramFilter);
        }
        if (disputeFilter.getFlowId() != null) {
            filters.add(new Filter("FLOW_ID", disputeFilter.getFlowId()));
        }
    }

    private boolean isSearchByDispute() {
        return EntityNames.OPERATION.equals(searchType) && SEARCH_TAB_DISPUTE.equals(searchTabName);
    }
}
