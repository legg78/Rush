package ru.bpc.sv2.ui.issuing.loyalty;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.LoyaltyDao;
import ru.bpc.sv2.loyalty.LotteryTicket;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.issuing.MbCardSearchModal;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbLotteryTickets")
public class MbLotteryTickets extends AbstractBean {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger("LOYALTY");
    private static Long DEFAULT_INST = 9999L;

    protected String tabName;
    private String backLink;

    private final DaoDataModel<LotteryTicket> lotteryTicketSource;
    private final TableRowSelection<LotteryTicket> itemSelection;

    private Date regDateFrom;
    private Date regDateTo;
    private List<SelectItem> ticketStatuses;
    private List<SelectItem> institutions;
    private LotteryTicket filter;
    private LotteryTicket activeLottetyTicket;
    private LotteryTicket newLottetyTicket;

    private LoyaltyDao loyaltyDao = new LoyaltyDao();

    public MbLotteryTickets() {
        pageLink = "issuing|loyalty|lottery_tickets";
        tabName = "detailsTab";
        beanEntityType = EntityNames.LOTTERY_TICKET;
        thisBackLink = "issuing|loyalty|lottery_tickets";
        curMode = VIEW_MODE;
        lotteryTicketSource = new DaoDataModel<LotteryTicket>() {
            private static final long serialVersionUID = 1L;

            @Override
            protected LotteryTicket[] loadDaoData(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return loyaltyDao.getLotteryTickets(userSessionId, params);
                    } catch (Exception e) {
                        FacesUtils.addMessageError(e);
                        setDataSize(0);
                        logger.error("", e);
                    }
                }
                return new LotteryTicket[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    try {
                        int threshold = 1000;
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        params.setThreshold(threshold);
                        return loyaltyDao.getLotteryTicketsCount(userSessionId, params);
                    } catch (Exception e) {
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<LotteryTicket>(null, lotteryTicketSource);
    }

    public DaoDataModel<LotteryTicket> getLotteryTickets() {
        return lotteryTicketSource;
    }
    public SimpleSelection getItemSelection() {
        try {
            if (activeLottetyTicket == null && lotteryTicketSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (activeLottetyTicket != null && lotteryTicketSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(activeLottetyTicket.getModelId());
                itemSelection.setWrappedSelection(selection);
                activeLottetyTicket = itemSelection.getSingleSelection();
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return itemSelection.getWrappedSelection();
    }
    public void setFirstRowActive() {
        lotteryTicketSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeLottetyTicket = (LotteryTicket) lotteryTicketSource.getRowData();
        selection.addKey(activeLottetyTicket.getModelId());
        itemSelection.setWrappedSelection(selection);
        if (activeLottetyTicket != null) {
            loadTab(getTabName());
        }
    }
    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activeLottetyTicket = itemSelection.getSingleSelection();
        if (activeLottetyTicket != null) {
            loadTab(getTabName());
        }
    }

    private void addFilter(String parameter, Object value, Filter.Operator operator) {
        Filter tmp = new Filter();
        tmp.setElement(parameter);
        if (operator != null) {
            tmp.setOp(operator);
        } else {
            tmp.setOp(Filter.Operator.eq);
        }
        tmp.setValue(value);
        filters.add(tmp);
    }
    private void addFilter(String parameter, Object value) {
        addFilter(parameter, value, Filter.Operator.eq);
    }
    private void setFilters() {
        filter = getFilter();
        filters = new ArrayList<Filter>();
        addFilter("lang", curLang);

        if (filter.getTicketNumber() != null && filter.getTicketNumber().trim().length() > 0) {
            addFilter("ticketNumber",
                      filter.getTicketNumber().trim().toUpperCase().replaceAll("[*]","%").replaceAll("[?]", "_"),
                      Filter.Operator.like);
        }
        if (filter.getStatus() != null) {
            addFilter("status", filter.getStatus());
        }
        if (filter.getCustomerId() != null) {
            addFilter("customerId", filter.getCustomerId());
        }
        if (filter.getInstId() != null) {
            addFilter("instId", filter.getInstId());
        }
        if (getRegDateFrom() != null) {
            addFilter("regDateFrom", getRegDateFrom());
        }
        if (getRegDateTo() != null) {
            addFilter("regDateTo", getRegDateTo());
        }
    }
    public void changeLanguage(ValueChangeEvent event) {
        curLang = (String) event.getNewValue();
    }

    @Override
    public void clearFilter() {
        sectionFilterModeEdit = true;
        sectionFilter = null;
        selectedSectionFilter = null;
        filter = null;
        clearState();
        searching = false;
    }
    public void clearState() {
        itemSelection.clearSelection();
        activeLottetyTicket = null;
        lotteryTicketSource.flushCache();
        curLang = userLang;
    }
    public void search() {
        clearState();
        searching = true;
    }

    public String getTabName() {
        return tabName;
    }
    public void setTabName(String tabName) {
        this.tabName = tabName;
    }
    private void loadTab(String tab) {
        if (tab != null && activeLottetyTicket != null) {
            // TODO Load specific tabs data
        }
    }
    public void loadCurrentTab() {
        loadTab(tabName);
    }

    public Date getRegDateFrom() {
        return regDateFrom;
    }
    public void setRegDateFrom(Date regDateFrom) {
        this.regDateFrom = regDateFrom;
    }

    public Date getRegDateTo() {
        return regDateTo;
    }
    public void setRegDateTo(Date regDateTo) {
        this.regDateTo = regDateTo;
    }

    public List<SelectItem> getTicketStatuses() {
        if (ticketStatuses == null) {
            ticketStatuses = getDictUtils().getLov(LovConstants.LOTTERY_TICKET_STATUS);
            if (ticketStatuses == null) {
                ticketStatuses = new ArrayList<SelectItem>();
            }
        }
        return ticketStatuses;
    }
    public List<SelectItem> getInstitutions() {
        if (institutions == null) {
            institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
            if (institutions == null) {
                institutions = new ArrayList<SelectItem>();
            }
        }
        return institutions;
    }

    public LotteryTicket getFilter() {
        if (filter == null) {
            filter = new LotteryTicket();
        }
        return filter;
    }
    public void setFilter(LotteryTicket filter) {
        this.filter = filter;
    }

    public LotteryTicket getActiveLottetyTicket() {
        return activeLottetyTicket;
    }
    public void setActiveLottetyTicket(LotteryTicket activeLottetyTicket) {
        this.activeLottetyTicket = activeLottetyTicket;
    }

    public LotteryTicket getNewLottetyTicket() {
        if (newLottetyTicket == null) {
            newLottetyTicket = new LotteryTicket();
        }
        return newLottetyTicket;
    }
    public void setNewLottetyTicket(LotteryTicket newLottetyTicket) {
        this.newLottetyTicket = newLottetyTicket;
    }

    public void showCustomers() {
        MbCustomerSearchModal bean = (MbCustomerSearchModal) ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
        bean.clearFilter();
        if (getFilter().getInstId() != null) {
            bean.setDefaultInstId(getFilter().getInstId().intValue());
        }
    }
    public void selectCustomer() {
        MbCustomerSearchModal bean = (MbCustomerSearchModal) ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
        Customer selected = bean.getActiveCustomer();
        if (selected != null) {
            if (curMode == NEW_MODE || curMode == EDIT_MODE) {
                getNewLottetyTicket().setCustomerId(selected.getId());
                getNewLottetyTicket().setCustomerNumber(selected.getCustomerNumber());
                getNewLottetyTicket().setCustomerInfo(selected.getName());
                if (selected.getInstId() != null) {
                    getNewLottetyTicket().setInstId(selected.getInstId().longValue());
                }
                getNewLottetyTicket().setInstName(selected.getInstName());
            } else {
                getFilter().setCustomerNumber(selected.getCustomerNumber());
                getFilter().setCustomerId(selected.getId());
                getFilter().setCustomerInfo(selected.getName());
                if (selected.getInstId() != null) {
                    getFilter().setInstId(selected.getInstId().longValue());
                }
                getFilter().setInstName(selected.getInstName());
            }
        }
    }
    public void displayCustInfo() {
        return;
    }

    public void showCards() {
        MbCardSearchModal bean = (MbCardSearchModal)ManagedBeanWrapper.getManagedBean("MbCardSearchModal");
        bean.clearFilter();
        bean.getFilter().setCustomerId(getNewLottetyTicket().getCustomerId());
        bean.getFilter().setCustomerNumber(getNewLottetyTicket().getCustomerNumber());
        bean.getFilter().setCustInfo(getNewLottetyTicket().getCustomerInfo());
        if (getNewLottetyTicket().getInstId() != null) {
            bean.getFilter().setInstId(getNewLottetyTicket().getInstId().intValue());
        }
        bean.getFilter().setInstName(getNewLottetyTicket().getInstName());
    }
    public void selectCard() {
        MbCardSearchModal bean = (MbCardSearchModal)ManagedBeanWrapper.getManagedBean("MbCardSearchModal");
        Card selected = bean.getActiveCard();
        if (selected != null) {
            getNewLottetyTicket().setCardMask(selected.getMask());
            getNewLottetyTicket().setCardId(selected.getId());
        }
    }
    public void displayOperInfo() {
        return;
    }

    public void addLotteryTicket() {
        curMode = NEW_MODE;
        newLottetyTicket = new LotteryTicket();
        newLottetyTicket.setLang(curLang);
    }
    public void editLotteryTicket() {
        try {
            curMode = EDIT_MODE;
            newLottetyTicket = new LotteryTicket();
            if (activeLottetyTicket != null) {
                newLottetyTicket = activeLottetyTicket.clone();
            }
        } catch (CloneNotSupportedException e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }
    public void deleteLotteryTicket() {
        try {
            curMode = VIEW_MODE;
            loyaltyDao.removeLotteryTicket(userSessionId, activeLottetyTicket);
            search();
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void save() {
        try {
            if (isNewMode()) {
                newLottetyTicket = loyaltyDao.addLotteryTicket(userSessionId, newLottetyTicket);
                activeLottetyTicket = (LotteryTicket) newLottetyTicket.clone();
            } else {
                newLottetyTicket = loyaltyDao.modifyLotteryTicket(userSessionId, newLottetyTicket);
                activeLottetyTicket = (LotteryTicket) newLottetyTicket.clone();
            }
            curMode = VIEW_MODE;
            search();
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void cancel() {
        curMode = VIEW_MODE;
    }
}
