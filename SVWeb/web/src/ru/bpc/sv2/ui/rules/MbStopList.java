package ru.bpc.sv2.ui.rules;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.application.StopList;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;

@ViewScoped
@ManagedBean (name = "MbStopList")
public class MbStopList extends AbstractBean {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger("APPLICATION");
    private static final String TAB_DETAILS = "detailsTab";

    private final DaoDataModel<StopList> stopListSource;
    private final TableRowSelection<StopList> itemSelection;

    private DisputesDao disputesDao = new DisputesDao();
    private IssuingDao issuingDao = new IssuingDao();

    private StopList filter;
    private StopList activeList;
    private Card activeCard;
    private String tabName = TAB_DETAILS;

    public MbStopList() {
        thisBackLink = "dispute|stop_list";
        stopListSource = new DaoDataModel<StopList>() {
            private static final long serialVersionUID = 1L;

            @Override
            protected StopList[] loadDaoData(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return disputesDao.getStopList(userSessionId, params);
                    } catch (Exception e) {
                        setDataSize(0);
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return new StopList[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return disputesDao.getStopListCount(userSessionId, params);
                    } catch (Exception e) {
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<StopList>(null, stopListSource);
    }

    private void addFilter(String name, Object value) {
        addFilter(name, value, Filter.Operator.eq);
    }
    private void addFilter(String name, Object value, Filter.Operator comparator) {
        Filter paramFilter = new Filter();
        paramFilter.setElement(name);
        paramFilter.setOp(comparator);
        paramFilter.setValue(value);
        filters.add(paramFilter);
    }
    private void setFilters() {
        filter = getFilter();
        filters = new ArrayList<Filter>();

        addFilter("LANG", userLang);

        if (filter.getId() != null) {
            addFilter("ID", filter.getId());
        }
        if (filter.getCardMask() != null && !filter.getCardMask().trim().isEmpty()) {
            addFilter("CARD_NUMBER", filter.getCardMask().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"), Filter.Operator.like);
        }
        if (filter.getEventType() != null) {
            addFilter("EVENT_TYPE", filter.getCardMask());
        }
        if (filter.getReasonCode() != null) {
            addFilter("REASON_CODE", filter.getReasonCode());
        }
        if (filter.getStatus() != null) {
            addFilter("STATUS", filter.getStatus());
        }
    }
    private void clearBean() {
        itemSelection.clearSelection();
        activeList = null;
        stopListSource.flushCache();
    }
    private void loadTab(String tab) {
        if ((tab == null) || (activeList == null)) {
            return;
        }
    }

    public StopList getFilter() {
        if (filter == null) {
            filter = new StopList();
        }
        return filter;
    }
    public void setFilter(StopList filter) {
        this.filter = filter;
    }

    public DaoDataModel<StopList> getStopList() {
        return stopListSource;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (activeList == null && stopListSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (activeList != null && stopListSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(activeList.getModelId());
                itemSelection.setWrappedSelection(selection);
                activeList = itemSelection.getSingleSelection();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return itemSelection.getWrappedSelection();
    }
    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activeList = itemSelection.getSingleSelection();
    }
    public void setFirstRowActive() throws CloneNotSupportedException {
        stopListSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeList = (StopList) stopListSource.getRowData();
        selection.addKey(activeList.getModelId());
        itemSelection.setWrappedSelection(selection);
    }
    public void loadCurrentTab() {
        loadTab(tabName);
    }

    public void search() {
        curMode = VIEW_MODE;
        clearBean();
        searching = true;
    }

    public StopList getActiveList() {
        return activeList;
    }
    public void setActiveList(StopList activeList) {
        this.activeList = activeList;
    }

    public String getTabName() {
        return tabName;
    }
    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public void viewCardNumber() {
        try {
            getActiveCard().setCardNumber(activeList.getCardNumber());
            getActiveCard().setMask(activeList.getCardMask());
            issuingDao.viewCardNumber(userSessionId, activeList.getCardInstanceId());
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
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

    @Override
    public void clearFilter() {
        filter = null;
        curLang = userLang;
        clearBean();
        searching = false;

    }
}
