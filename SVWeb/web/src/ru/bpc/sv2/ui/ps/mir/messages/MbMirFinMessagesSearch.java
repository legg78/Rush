package ru.bpc.sv2.ui.ps.mir.messages;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MirDao;
import ru.bpc.sv2.ps.mir.MirFinMessage;
import ru.bpc.sv2.ps.mir.MirFinMessageAddendum;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbMirFinMessagesSearch")
public class MbMirFinMessagesSearch extends AbstractBean {
    private static final long serialVersionUID = 9180917082872879256L;

    private static final Logger logger = Logger.getLogger("MIR");

    private static final String ADDENDUM_TAB = "addendumTab";
    private static final String REJECT_TAB = "rejectTab";
    private static final String REJECT_CODE_TAB = "rejectCodeTab";
    private static final String DETAILS_TAB = "mirFinMessageDetailsTab";

    private static final String COMPONENT_ID = "1982:finMessageTable"; //todo must be changed

    private MirDao mirDao = new MirDao();

    private ArrayList<SelectItem> institutions;
    private MirFinMessage filter;
    private final DaoDataListModel<MirFinMessage> messageSource;

    private MirFinMessage activeItem;
    private MirFinMessage newFinMessage;
    private final TableRowSelection<MirFinMessage> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private List<String> rerenderList;
    private Map<String, Object> paramMap;
    private Integer rejected;
    private List<SelectItem> yesNoLov;

    public MbMirFinMessagesSearch() {
        pageLink = "mastercard|financial_messages";
        messageSource = new DaoDataListModel<MirFinMessage>(logger) {
            private static final long serialVersionUID = 6886825197574225937L;

            @Override
            protected List<MirFinMessage> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return mirDao.getFinancialMessages(userSessionId, params);
                }
                return new ArrayList<MirFinMessage>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return mirDao.getFinancialMessagesCount(userSessionId, params);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<MirFinMessage>(null, messageSource);
        tabName = DETAILS_TAB;
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters() {
        //todo must be revisited
        MirFinMessage messageFilter = getFilter();
        filters = new ArrayList<Filter>();
        Filter paramFilter;

        if (messageFilter.getSessionId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("sessionId");
            paramFilter.setOp(Operator.eq);
            paramFilter.setValue(messageFilter.getSessionId());
            filters.add(paramFilter);
        }

        if (messageFilter.getFileName() != null && messageFilter.getFileName().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("fileName");
            paramFilter.setOp(Operator.like);
            paramFilter.setValue(messageFilter.getFileName().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }

        String dbDateFormat = "dd.MM.yyyy";
        SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
        if (messageFilter.getDateFrom() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("dateFrom");
            paramFilter.setValue(df.format(messageFilter.getDateFrom()));
            filters.add(paramFilter);
        }
        if (messageFilter.getDateTo() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("dateTo");
            paramFilter.setValue(df.format(messageFilter.getDateTo()));
            filters.add(paramFilter);
        }

        if (rejected != null) {
            filters.add(new Filter("isRejected", rejected));
        }

        paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setValue(userLang);
        filters.add(paramFilter);
    }

    public SimpleSelection getItemSelection() {
        if (activeItem == null && messageSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (activeItem != null && messageSource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(activeItem.getModelId());
            itemSelection.setWrappedSelection(selection);
            activeItem = itemSelection.getSingleSelection();
        }
        return itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activeItem = itemSelection.getSingleSelection();
        if (activeItem != null) {
            setInfo();
        }
    }

    private void setFirstRowActive() {
        messageSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (MirFinMessage) messageSource.getRowData();
        selection.addKey(activeItem.getModelId());
        itemSelection.setWrappedSelection(selection);
        if (activeItem != null) {
            setInfo();
        }
    }

    private void setInfo() {
        loadedTabs.clear();
        loadTab(getTabName());
    }

    public void edit() {
        try {
            newFinMessage = (MirFinMessage) activeItem.clone();
        } catch (CloneNotSupportedException e) {
            logger.error("", e);
            newFinMessage = activeItem;
        }
        curMode = EDIT_MODE;
    }

    private void loadTab(String tabName) {
        if (tabName == null) {
            return;
        }

        if (activeItem == null) {
            return;
        }

        if (tabName.equalsIgnoreCase(ADDENDUM_TAB)) {
            MbMirFinMessageAddendum mbAddendum = (MbMirFinMessageAddendum) ManagedBeanWrapper
                    .getManagedBean("MbMirFinMessageAddendum");
            MirFinMessageAddendum addendumFilter = new MirFinMessageAddendum();
            addendumFilter.setFinId(activeItem.getId());
            mbAddendum.setFilter(addendumFilter);
            mbAddendum.search();
        } else if (tabName.equalsIgnoreCase(REJECT_TAB)) {
            MbMirRejectSearchBottom mbReject = (MbMirRejectSearchBottom) ManagedBeanWrapper
                    .getManagedBean("MbMirRejectSearchBottom");
            mbReject.loadReject(activeItem.getRejectId());
        } else if (tabName.equalsIgnoreCase(REJECT_CODE_TAB)) {
            MbMirRejectCodeSearchBottom mbRejectCode = (MbMirRejectCodeSearchBottom) ManagedBeanWrapper
                    .getManagedBean("MbMirRejectCodeSearchBottom");
            if (activeItem.getRejectId() != null) {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("rejectId", activeItem.getRejectId());
                mbRejectCode.setFilterMap(params);
                mbRejectCode.search();
            }
        }

        needRerender = tabName;
        loadedTabs.put(tabName, Boolean.TRUE);
    }

    public void search() {
        setSearching(true);
        clearBean();
        paramMap = new HashMap<String, Object>();
    }

    private void clearBean() {
        messageSource.flushCache();
        clearDependencies();
        itemSelection.clearSelection();
        activeItem = null;
    }

    public void clearFilter() {
        filter = null;
        rejected = null;
        setSearching(false);
        clearBean();
        setDefaultValues();
    }

    private void clearDependencies() {
        MbMirFinMessageAddendum bean = (MbMirFinMessageAddendum) ManagedBeanWrapper
                .getManagedBean("MbMirFinMessageAddendum");
        bean.clearFilter();

        MbMirRejectSearchBottom rejectBean = (MbMirRejectSearchBottom) ManagedBeanWrapper
                .getManagedBean("MbMirRejectSearchBottom");
        rejectBean.clearFilter();

        MbMirRejectCodeSearchBottom rejectCodeBean = (MbMirRejectCodeSearchBottom) ManagedBeanWrapper
                .getManagedBean("MbMirRejectCodeSearchBottom");
        rejectCodeBean.clearFilter();
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

        if (tabName.equalsIgnoreCase(ADDENDUM_TAB)) {
            MbMirFinMessageAddendum bean = (MbMirFinMessageAddendum) ManagedBeanWrapper
                    .getManagedBean("MbMirFinMessageAddendum");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }
        if (tabName.equalsIgnoreCase(REJECT_CODE_TAB)) {
            MbMirRejectCodeSearchBottom bean = (MbMirRejectCodeSearchBottom) ManagedBeanWrapper
                    .getManagedBean("MbMirRejectCodeSearchBottom");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }
    }

    public String getSectionId() {
        return SectionIdConstants.ISSUING_CREDIT_DEBT;
    }

    public boolean getSearching() {
        return searching;
    }

    public String getTabName() {
        return tabName;
    }

    public void setFilter(MirFinMessage filter) {
        this.filter = filter;
    }

    public MirFinMessage getFilter() {
        if (filter == null) {
            filter = new MirFinMessage();
        }
        return filter;
    }

    public DaoDataModel<MirFinMessage> getItems() {
        return messageSource;
    }

    public MirFinMessage getActiveItem() {
        return activeItem;
    }

    public void setRowsNum(int rowsNum) {
        this.rowsNum = rowsNum;
    }

    public int getRowsNum() {
        return rowsNum;
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

    public String getComponentId() {
        return COMPONENT_ID;
    }

    public Logger getLogger() {
        return logger;
    }

    private void setDefaultValues() {
        filter = new MirFinMessage();
    }

    public Map<String, Object> getParamMap() {
        if (paramMap == null) {
            paramMap = new HashMap<String, Object>();
        }
        return paramMap;
    }

    public void setParamMap(Map<String, Object> paramMap) {
        this.paramMap = paramMap;
    }

    public Integer getRejected() {
        return rejected;
    }

    public void setRejected(Integer rejected) {
        this.rejected = rejected;
    }

    public List<SelectItem> getYesNoLov() {
        if (yesNoLov == null) {
            yesNoLov = getDictUtils().getLov(LovConstants.BOOLEAN);
        }
        return yesNoLov;
    }

    public MirFinMessage getNewFinMessage() {
        if (newFinMessage == null) {
            newFinMessage = new MirFinMessage();
        }
        return newFinMessage;
    }

    public void setNewFinMessage(MirFinMessage newFinMessage) {
        this.newFinMessage = newFinMessage;
    }

    @Override
    protected void applySectionFilter(Integer filterId) {
        try {
            FilterFactory factory = (FilterFactory) ManagedBeanWrapper
                    .getManagedBean("filterFactory");
            Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
            sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
            if (filterRec != null) {
                filter = new MirFinMessage();
                if (filterRec.get("sessionId") != null) {
                    filter.setSessionId(Long.parseLong(filterRec.get("sessionId")));
                }

                String dbDateFormat = "dd.MM.yyyy";
                SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
                if (filterRec.get("dateFrom") != null) {
                    filter.setDateFrom(df.parse(filterRec.get("dateFrom")));
                }
                if (filterRec.get("fileName") != null) {
                    filter.setFileName(filterRec.get("fileName"));
                }
                if (filterRec.get("dateTo") != null) {
                    filter.setDateTo(df.parse(filterRec.get("dateTo")));
                }
                if (filterRec.get("rejected") != null) {
                    setRejected(Integer.parseInt(filterRec.get("rejected")));
                }
            }
            if (searchAutomatically) {
                search();
            }
            sectionFilterModeEdit = true;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    @Override
    public void saveSectionFilter() {
        try {
            FilterFactory factory = (FilterFactory) ManagedBeanWrapper
                    .getManagedBean("filterFactory");

            Map<String, String> filterRec = new HashMap<String, String>();
            filter = getFilter();
            if (filter.getSessionId() != null) {
                filterRec.put("sessionId", filter.getSessionId().toString());
            }
            String dbDateFormat = "dd.MM.yyyy";
            SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
            if (filter.getDateFrom() != null) {
                filterRec.put("dateFrom", df.format(filter.getDateFrom()));
            }
            if (filter.getFileName() != null) {
                filterRec.put("fileName", filter.getFileName());
            }
            if (filter.getDateTo() != null) {
                filterRec.put("dateTo", df.format(filter.getDateTo()));
            }
            if (getRejected() != null) {
                filterRec.put("rejected", getRejected().toString());
            }
            sectionFilter = getSectionFilter();
            sectionFilter.setRecs(filterRec);

            factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
            selectedSectionFilter = sectionFilter.getId();
            sectionFilterModeEdit = true;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }
}
