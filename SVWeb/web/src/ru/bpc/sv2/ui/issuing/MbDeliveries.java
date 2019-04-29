package ru.bpc.sv2.ui.issuing;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.deliveries.Delivery;
import ru.bpc.sv2.deliveries.DeliveryAmount;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.DeliveriesDao;
import ru.bpc.sv2.ui.events.MbStatusLogs;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.ui.utils.model.LoadableDetachableModel;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.*;

/**
 * Created by Viktorov on 21.02.2017.
 */

@ViewScoped
@ManagedBean(name = "MbDeliveries")
public class MbDeliveries extends AbstractBean {
    private static final long serialVersionUID = 1L;

    private static final Logger logger = Logger.getLogger("ISSUING");

    private static final String DETAILS_TAB = "detailsTab";

    private DeliveriesDao deliveriesDao = new DeliveriesDao();

    private final DaoDataModel<Delivery> deliverySource;
    private ArrayList<SelectItem> institutions;
    private LoadableDetachableModel<List<SelectItem>> agentsModel;
    private Delivery filter;
    private String tabName;
    private final TableRowSelection<Delivery> itemSelection;
    private Delivery activeDelivery;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String needRerender;
    private List<String> rerenderList;
    private Boolean allSelected = false;
    private List<DeliveryAmount> res;
    private String deliveryStatus;
    private String deliveryRefNum;

    private long selectedCount;

    public MbDeliveries() {
        selectedCount = 0;
        pageLink = "issuing|deliveries";
        tabName = DETAILS_TAB;
        deliverySource = new DaoDataModel<Delivery>() {
            private static final long serialVersionUID = 1L;

            @Override
            protected Delivery[] loadDaoData(SelectionParams params) {
                if (!searching)
                    return new Delivery[0];
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return deliveriesDao.getDeliveries(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new Delivery[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching)
                    return 0;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return deliveriesDao.getDeliveriesCount(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<Delivery>(null, deliverySource);

        agentsModel = new LoadableDetachableModel<List<SelectItem>>() {
            @Override
            protected List<SelectItem> load() {
                Map<String, Object> paramMap = new HashMap<String, Object>();
                paramMap.put("INSTITUTION_ID", getFilter().getInstId());
                return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
            }
        };

    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters() {
        Delivery deliveryFilter = getFilter();
        filters = new ArrayList<Filter>();
        Filter paramFilter = null;

        if (deliveryFilter.getCardNumber() != null &&
                deliveryFilter.getCardNumber().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("cardNumber");
            paramFilter.setValue(deliveryFilter.getCardNumber().trim().toUpperCase().replaceAll(
                    "[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }

        if (deliveryFilter.getInstId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("instId");
            paramFilter.setValue(deliveryFilter.getInstId());
            filters.add(paramFilter);
        }

        if (deliveryFilter.getAgentId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("agentId");
            paramFilter.setValue(deliveryFilter.getAgentId());
            filters.add(paramFilter);
        }

        if (deliveryFilter.getDeliveryRefNum() != null &&
                deliveryFilter.getDeliveryRefNum().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("deliveryRefNum");
            paramFilter.setValue(deliveryFilter.getDeliveryRefNum().trim().replaceAll(
                    "[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }

        if (deliveryFilter.getDeliveryStatus() != null &&
                deliveryFilter.getDeliveryStatus().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("deliveryStatus");
            paramFilter.setValue(deliveryFilter.getDeliveryStatus());
            filters.add(paramFilter);
        }

        if (deliveryFilter.getDateFrom() != null) {
            filters.add(new Filter("dateFrom", deliveryFilter.getDateFrom()));
        }
        if (deliveryFilter.getDateTo() != null) {
            filters.add(new Filter("dateTo", deliveryFilter.getDateTo()));
        }

        if (deliveryFilter.getCardTypeId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("cardTypeId");
            paramFilter.setValue(deliveryFilter.getCardTypeId());
            filters.add(paramFilter);
        }
    }

    public void search() {
        searching = true;
        clearBean();
    }

    public void clearFilter() {
        searching = false;
        filter = null;
        clearBean();
        setDefaultValues();
    }

    private void clearBean() {
        allSelected = false;
        selectedCount = 0;
        deliverySource.flushCache();
        itemSelection.clearSelection();
        activeDelivery = null;
    }

    private SimpleSelection prepareSelection() {
        if (activeDelivery == null && deliverySource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (activeDelivery != null && deliverySource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(activeDelivery.getModelId());
            itemSelection.setWrappedSelection(selection);
            activeDelivery = itemSelection.getSingleSelection();
        }
        return itemSelection.getWrappedSelection();
    }

    private void setFirstRowActive() {
        deliverySource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeDelivery = (Delivery) deliverySource.getRowData();
        selection.addKey(activeDelivery.getModelId());
        itemSelection.setWrappedSelection(selection);
        if (activeDelivery != null) {
            setInfo();
        }
    }

    private void setInfo() {
        loadedTabs.clear();
        loadTab(tabName);
    }

    private void loadTab(String tabName) {
        if (tabName == null) {
            return;
        }
        if (activeDelivery == null) {
            return;
        }

        if (tabName.equalsIgnoreCase("statusLogsTab")) {
            MbStatusLogs statusLogs = (MbStatusLogs) ManagedBeanWrapper
                    .getManagedBean("MbStatusLogs");
            statusLogs.clearFilter();
            statusLogs.getFilter().setObjectId(activeDelivery.getCardId());

            statusLogs.getFilter().setEntityType(EntityNames.CARD_INSTANCE);
            statusLogs.getFilter().setStatus("CRDS%");
            statusLogs.search();
        }

        if (tabName.equalsIgnoreCase("statisticTab")) {
            MbDeliveryStatistic deliveryStatistic = (MbDeliveryStatistic) ManagedBeanWrapper
                    .getManagedBean("MbDeliveryStatistic");
            deliveryStatistic.clearFilter();
            deliveryStatistic.loadDeliveryStatistic(activeDelivery.getDeliveryRefNum());
        }
        needRerender = tabName;
        loadedTabs.put(tabName, Boolean.TRUE);
    }

    public ArrayList<SelectItem> getInstitutions() {
        if (institutions == null) {
            institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
        }
        if (institutions == null)
            institutions = new ArrayList<SelectItem>();
        return institutions;
    }

    public List<SelectItem> getDeliveryStatuses() {
        return getDictUtils().getLov(LovConstants.DELIVERY_STATUS);
    }

    public List<SelectItem> getCardTypes() {
        return getDictUtils().getLov(LovConstants.CARD_TYPES);
    }

    public String getTabName() {
        return tabName;
    }

    public void setTabName(String tabName) {
        needRerender = null;
        this.tabName = tabName;

        Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

        if (isLoadedCurrentTab == null) {
            isLoadedCurrentTab = Boolean.FALSE;
        }

        if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
            return;
        }

        loadTab(tabName);

        if (tabName.equalsIgnoreCase("statusLogsTab")) {
            MbStatusLogs bean = (MbStatusLogs) ManagedBeanWrapper
                    .getManagedBean("MbStatusLogs");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }

        if (tabName.equalsIgnoreCase("statisticTab")) {
            MbDeliveryStatistic bean = (MbDeliveryStatistic) ManagedBeanWrapper
                    .getManagedBean("MbDeliveryStatistic");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }

    }

    public String getSectionId() {
        return SectionIdConstants.ISSUING_DELIVERY;
    }

    public ExtendedDataModel getDeliveries() {
        return deliverySource;
    }

    public SimpleSelection getItemSelection() {
        return prepareSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activeDelivery = itemSelection.getSingleSelection();
        if (activeDelivery != null) {
            setInfo();
        }
    }

    public String getNeedRerender() {
        return this.needRerender;
    }

    public Delivery getActiveDelivery() {
        return activeDelivery;
    }

    public void setActiveDelivery(Delivery activeDelivery) {
        this.activeDelivery = activeDelivery;
    }

    /**
     * @return <code>filter</code>, if it's null then this method creates new
     *         filter with default values and returns it.
     */
    public Delivery getFilter() {
        if (filter == null) {
            filter = new Delivery();
        }
        return filter;
    }

    public List<String> getRerenderList() {
        rerenderList = new ArrayList<String>();
        if (needRerender != null) {
            rerenderList.add(needRerender);
        }
        rerenderList.add("err_ajax");
        rerenderList.add(tabName);
        return rerenderList;
    }

    public Logger getLogger() {
        return logger;
    }

    private void setDefaultValues() {
        if (sectionFilterModeEdit) return;

        Integer defaultInstId = null;
        List<SelectItem> instList = getInstitutions();
        if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
            defaultInstId = Integer.valueOf((String) getInstitutions().get(0).getValue());
        } else {
            defaultInstId = userInstId;
        }

        filter = new Delivery();
        Calendar today = Calendar.getInstance();
        today.set(Calendar.HOUR, 0);
        today.set(Calendar.MINUTE, 0);
        today.set(Calendar.SECOND, 0);
        filter.setDateFrom(today.getTime());
        filter.setInstId(defaultInstId);
    }

    public List<SelectItem> getAgents() {
        return agentsModel.getObject();
    }

    public void initPanel() {

    }

    public void selectDelivery() {
        MbDeliveryRefNumModal deliveryBean = ManagedBeanWrapper
                .getManagedBean("MbDeliveryRefNumModal");
        Delivery delivery = deliveryBean.getActiveDelivery();
        filter.setDeliveryRefNum(delivery.getDeliveryRefNum());
    }

    public Boolean getAllSelected() {
        return allSelected;
    }

    public void setAllSelected(Boolean allSelected) {
        if(this.allSelected != allSelected) {
            List<Delivery> deliv = (List<Delivery>) deliverySource.getActivePage();
            if (deliv != null)
                for (Delivery each : deliv) {
                    each.setSelected(allSelected);
                }
            if (allSelected)
                selectedCount = deliv.size();
            else
                selectedCount = 0;
            this.allSelected = allSelected;
        }
    }

    public List<DeliveryAmount> getStatistics() {
        if(activeDelivery != null && activeDelivery.getDeliveryRefNum() != null
                && activeDelivery.getDeliveryRefNum().trim().length() > 0) {
            filters = new ArrayList<Filter>();
            filters.add(new Filter("deliveryRefNum", activeDelivery.getDeliveryRefNum()));
            SelectionParams statParams = new SelectionParams();
            statParams.setFilters(filters.toArray(new Filter[filters.size()]));
            statParams.setRowIndexStart(0);
            statParams.setRowIndexEnd(19);
            res = deliveriesDao.getStatistics(userSessionId, statParams);
            return res;
        }
        return new ArrayList<DeliveryAmount>();
    }

    public void selectedCounts(ValueChangeEvent e) {
        boolean oldValue = false;
        boolean newValue = (Boolean)e.getNewValue();;
        if(e.getOldValue() != null)
            oldValue = (Boolean)e.getOldValue();
        if (newValue == true && oldValue == false)
            ++selectedCount;
        if (newValue == false && oldValue == true)
            --selectedCount;
    }

    public long getSelectedCount() {
        return selectedCount;
    }

    public void setSelectedCount(long selectedCount) {
        this.selectedCount = selectedCount;
    }

    public String getDeliveryStatus() {
        return deliveryStatus;
    }

    public void setDeliveryStatus(String deliveryStatus) {
        this.deliveryStatus = deliveryStatus;
    }

    public String getDeliveryRefNum() {
        return deliveryRefNum;
    }

    public void setDeliveryRefNum(String deliveryRefNum) {
        this.deliveryRefNum = deliveryRefNum;
    }

    public void changeDeliveryStatus() {
        if(selectedCount <= 0)
            return;
        List<Delivery> deliv = (List<Delivery>) deliverySource.getActivePage();
        List<Long> selectedIds = new ArrayList<Long>();
        for (Delivery each : deliv) {
            if(each.getSelected() != null && each.getSelected())
                selectedIds.add(each.getId());
        }
        deliveriesDao.modifyDeliveryStatus(userSessionId, selectedIds.toArray(new Long[selectedIds.size()]), deliveryStatus);

    }

    public void changeDeliveryRefNum() {
        if(selectedCount <= 0)
            return;
        List<Delivery> deliv = (List<Delivery>) deliverySource.getActivePage();
        List<Long> selectedIds = new ArrayList<Long>();
        for (Delivery each : deliv) {
            if(each.getSelected() != null && each.getSelected())
                selectedIds.add(each.getId());
        }
        Integer instId = deliv.get(0).getInstId();
        Integer agentId = deliv.get(0).getAgentId();
        Integer cardTypeId = deliv.get(0).getCardTypeId();
        deliveriesDao.modifyDeliveryRefNum(userSessionId, selectedIds.toArray(new Long[selectedIds.size()]), deliveryRefNum, instId, agentId, cardTypeId);

    }

}
