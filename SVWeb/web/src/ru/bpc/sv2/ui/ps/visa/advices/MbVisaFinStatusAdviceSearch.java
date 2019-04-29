package ru.bpc.sv2.ui.ps.visa.advices;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.VisaDao;
import ru.bpc.sv2.ps.visa.VisaFinStatusAdvice;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

@ViewScoped
@ManagedBean (name = "MbVisaFinStatusAdviceSearch")
public class MbVisaFinStatusAdviceSearch extends AbstractBean {
    private static final Logger logger = Logger.getLogger("VIS");
    private static final String PAGE = "visa|fin_status_advice";
    private static final String DETAILS_TAB = "detailsTab";

    private VisaDao visaDao = new VisaDao();

    private VisaFinStatusAdvice filter;
    private VisaFinStatusAdvice activeVisaFinStatusAdvice;
    private String tabName;
    private Card activeCard;

    private final DaoDataModel<VisaFinStatusAdvice> visaFinStatusAdvices;
    private final TableRowSelection<VisaFinStatusAdvice> itemSelection;

    public MbVisaFinStatusAdviceSearch() {
        pageLink = PAGE;
        tabName = DETAILS_TAB;
        visaFinStatusAdvices = new DaoDataModel<VisaFinStatusAdvice>() {
            @Override
            protected VisaFinStatusAdvice[] loadDaoData(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return visaDao.getVisaFinStatusAdvices(userSessionId, params);
                    } catch (Exception e) {
                        setDataSize(0);
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return new VisaFinStatusAdvice[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return visaDao.getVisaFinStatusAdvicesCount(userSessionId, params);
                    } catch (Exception e) {
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<VisaFinStatusAdvice>(null, visaFinStatusAdvices);
    }

    public DaoDataModel<VisaFinStatusAdvice> getVisaFinStatusAdvices() {
        return visaFinStatusAdvices;
    }

    public VisaFinStatusAdvice getActiveVisaFinStatusAdvice() {
        return activeVisaFinStatusAdvice;
    }
    public void setActiveVisaFinStatusAdvice(VisaFinStatusAdvice activeVisaFinStatusAdvice) {
        this.activeVisaFinStatusAdvice = activeVisaFinStatusAdvice;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (activeVisaFinStatusAdvice == null && visaFinStatusAdvices.getRowCount() > 0) {
                setFirstRowActive();
            } else if (activeVisaFinStatusAdvice != null && visaFinStatusAdvices.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(activeVisaFinStatusAdvice.getModelId());
                itemSelection.setWrappedSelection(selection);
                activeVisaFinStatusAdvice = itemSelection.getSingleSelection();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return itemSelection.getWrappedSelection();
    }
    public void setItemSelection(SimpleSelection selection) {
        try {
            itemSelection.setWrappedSelection(selection);
            boolean changeSelect = false;
            if (itemSelection.getSingleSelection() != null &&
                    !itemSelection.getSingleSelection().getId().equals(activeVisaFinStatusAdvice.getId())) {
                changeSelect = true;
            }
            activeVisaFinStatusAdvice = itemSelection.getSingleSelection();
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public VisaFinStatusAdvice getFilter() {
        if (filter == null) {
            filter = new VisaFinStatusAdvice();
        }
        return filter;
    }
    public void setFilter(VisaFinStatusAdvice filter) {
        this.filter = filter;
    }

    public String getTabName() {
        return tabName;
    }
    public void setTabName(String tabName) {
        this.tabName = tabName;
        if (tabName.equalsIgnoreCase(DETAILS_TAB)) {
            /* Do nothing */
        }
    }

    public Card getActiveCard() {
        if (activeCard == null) {
            setActiveCard(new Card());
        }
        return activeCard;
    }
    public void setActiveCard(Card activeCard) {
        this.activeCard = activeCard;
    }

    public void setFirstRowActive() throws CloneNotSupportedException {
        visaFinStatusAdvices.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeVisaFinStatusAdvice = (VisaFinStatusAdvice) visaFinStatusAdvices.getRowData();
        selection.addKey(activeVisaFinStatusAdvice.getModelId());
        itemSelection.setWrappedSelection(selection);
    }

    public void search() {
        clearBean();
        searching = true;
    }
    @Override
    public void clearFilter() {
        clearBean();
        curLang = userLang;
        filter = null;
        searching = false;
    }

    public void setFilters() {
        filters = new ArrayList<Filter>();
        SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
        df.setTimeZone(((CommonUtils)ManagedBeanWrapper.getManagedBean("CommonUtils")).getTimeZone());

        filters.add(Filter.create("lang", curLang));
        if (getFilter().getSessionId() != null) {
            filters.add(Filter.create("session_id", getFilter().getSessionId()));
        }
        if (getFilter().getFileName() != null && !getFilter().getFileName().trim().isEmpty()) {
            filters.add(Filter.create("file_name", Filter.mask(getFilter().getFileName(), true)));
        }
        if (getFilter().getPurchaseDateFrom() != null) {
            filters.add(Filter.create("date_from", df.format(getFilter().getPurchaseDateFrom())));
        }
        if (getFilter().getPurchaseDateTo() != null) {
            filters.add(Filter.create("date_to", df.format(getFilter().getPurchaseDateTo())));
        }
        if (getFilter().getCardNumber() != null && !getFilter().getCardNumber().trim().isEmpty()) {
            filters.add(Filter.create("card_number", Filter.mask(getFilter().getCardNumber())));
        }
        if (getFilter().getVrolCaseNumber() != null) {
            filters.add(Filter.create("case_number", getFilter().getVrolCaseNumber()));
        }
        if (getFilter().getAuthCode() != null && !getFilter().getAuthCode().trim().isEmpty()) {
            filters.add(Filter.create("auth_code", Filter.mask(getFilter().getAuthCode(), true)));
        }
    }

    public void clearBean() {
        visaFinStatusAdvices.flushCache();
        itemSelection.clearSelection();
        activeVisaFinStatusAdvice = null;
    }

    public void loadCurrentTab() {
        loadTab(tabName, false);
    }
    private void loadTab(String tab, boolean restoreBean) {
        if (tab != null && activeVisaFinStatusAdvice != null) {
            if (tab.equalsIgnoreCase(DETAILS_TAB)) {
                /* Do nothing */
            }
        }
    }

    public void viewCardNumber() {
        getActiveCard().setCardNumber(activeVisaFinStatusAdvice.getCardNumber());
        getActiveCard().setMask(activeVisaFinStatusAdvice.getCardMask());
    }
}
