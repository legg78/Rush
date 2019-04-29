package ru.bpc.sv2.ui.ps.mir.messages;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MirDao;
import ru.bpc.sv2.ps.mir.MirReject;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbMirRejectSearch")
public class MbMirRejectSearch extends AbstractBean {
    private static final long serialVersionUID = 9180917082872879256L;

    private static final Logger logger = Logger.getLogger("MIR");

    private static final String REJECT_CODE_TAB = "rejectCodeTab";

    private static final String COMPONENT_ID = "1982:rejectsTable"; //todo must be changed

    private MirDao mirDao = new MirDao();

    private MirReject filter;
    private final DaoDataModel<MirReject> messageSource;

    private MirReject activeItem;
    private final TableRowSelection<MirReject> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;

    public MbMirRejectSearch() {
        pageLink = "mir|rejects";
        messageSource = new DaoDataListModel<MirReject>(logger) {
            private static final long serialVersionUID = 6886825197574225937L;

            @Override
            protected List<MirReject> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return mirDao.getMirRejects(userSessionId, params);
                }
                return new ArrayList<MirReject>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return mirDao.getMirRejectsCount(userSessionId, params);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<MirReject>(null, messageSource);
        tabName = "detailsTab";
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters() {
        //todo must be revisited
        MirReject messageFilter = getFilter();
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
        activeItem = (MirReject) messageSource.getRowData();
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

    private void loadTab(String tabName) {
        if (tabName == null) {
            return;
        }

        if (activeItem == null) {
            return;
        }

        if (tabName.equalsIgnoreCase(REJECT_CODE_TAB)) {
            MbMirRejectCodeSearchBottom mbRejectCode =
                    (MbMirRejectCodeSearchBottom) ManagedBeanWrapper.getManagedBean("MbMirRejectCodeSearchBottom");
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("rejectId", activeItem.getId());
            mbRejectCode.setFilterMap(params);
            mbRejectCode.search();
        }

        needRerender = tabName;
        loadedTabs.put(tabName, Boolean.TRUE);
    }

    public void search() {
        setSearching(true);
        clearBean();
    }

    private void clearBean() {
        messageSource.flushCache();
        clearDependencies();
        itemSelection.clearSelection();
        activeItem = null;
    }

    public void clearFilter() {
        filter = null;
        setSearching(false);
        clearBean();
        setDefaultValues();
    }

    private void clearDependencies() {
        MbMirRejectCodeSearchBottom rejectCodeBean = (MbMirRejectCodeSearchBottom)
                ManagedBeanWrapper.getManagedBean("MbMirRejectCodeSearchBottom");
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

        if (tabName.equalsIgnoreCase(REJECT_CODE_TAB)) {
            MbMirRejectCodeSearchBottom bean = (MbMirRejectCodeSearchBottom)
                    ManagedBeanWrapper.getManagedBean("MbMirRejectCodeSearchBottom");
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

    public void setFilter(MirReject filter) {
        this.filter = filter;
    }

    public MirReject getFilter() {
        if (filter == null) {
            filter = new MirReject();
        }
        return filter;
    }

    public DaoDataModel<MirReject> getItems() {
        return messageSource;
    }

    public MirReject getActiveItem() {
        return activeItem;
    }

    public List<String> getRerenderList() {
        List<String> rerenderList = new ArrayList<String>();
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
        filter = new MirReject();
    }

}
