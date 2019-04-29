package ru.bpc.sv2.ui.ps.amex.files;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.*;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AmexDao;
import ru.bpc.sv2.ps.amex.AmexFile;
import ru.bpc.sv2.ps.amex.AmexFinMessage;
import ru.bpc.sv2.ps.amex.AmexReject;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.TableRowSelection;
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
@ManagedBean(name = "MbAmexFilesSearch")
public class MbAmexFilesSearch extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;
    private static final Logger logger = Logger.getLogger("AMEX");

    private static final String FILE_FIN_MESSAGES_TAB = "fileFinMessagesTab";
    private static final String REJECT_TAB = "rejectTab";
    private static final String COMPONENT_ID = "fileFinMessageTable";

    private AmexDao amexDao = new AmexDao();

    private AmexFile filter;
    private final DaoDataModel<AmexFile> fileSource;

    private AmexFile activeItem;
    private final TableRowSelection<AmexFile> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private Map<String, Object> paramMap;
    private Integer rejected;
    private List<SelectItem> yesNoLov;

    public MbAmexFilesSearch() {
        pageLink = "amx|files";
        tabName = "detailsTab";
        fileSource = new DaoDataListModel<AmexFile>(logger) {
            @Override
            protected List<AmexFile> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return amexDao.getFiles(userSessionId, params);
                }
                return new ArrayList<AmexFile>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return amexDao.getFilesCount(userSessionId, params);
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<AmexFile>(null, fileSource);
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));

        if (getFilter().getId() != null) {
            filters.add(Filter.create("fileId", getFilter().getId()));
        }
        if (getFilter().getSessionId() != null) {
            filters.add(Filter.create("sessionId", getFilter().getSessionId()));
        }
        if (getFilter().getFileName() != null && getFilter().getFileName().trim().length() > 0) {
            filters.add(Filter.create("sessionId", Operator.like, Filter.mask(getFilter().getFileName())));
        }
        if (getFilter().getDateFrom() != null) {
            filters.add(Filter.create("dateFrom",
                                      new SimpleDateFormat(DatePatterns.DATE_PATTERN).format(getFilter().getDateFrom())));
        }
        if (getFilter().getDateTo() != null) {
            filters.add(Filter.create("dateTo",
                                      new SimpleDateFormat(DatePatterns.DATE_PATTERN).format(getFilter().getDateTo())));
        }
        if (rejected != null) {
            filters.add(Filter.create("isRejected", rejected));
        }
    }

    public SimpleSelection getItemSelection() {
        if (activeItem == null && fileSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (activeItem != null && fileSource.getRowCount() > 0) {
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
        fileSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (AmexFile) fileSource.getRowData();
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
        if (tabName != null && activeItem != null) {
            if (FILE_FIN_MESSAGES_TAB.equalsIgnoreCase(tabName)) {
                MbAmexFileFinMessagesBottom mbFileFinMessage = ManagedBeanWrapper.getManagedBean(MbAmexFileFinMessagesBottom.class);
                AmexFinMessage finMessageFilter = new AmexFinMessage();
                finMessageFilter.setFileId(activeItem.getId());
                mbFileFinMessage.setFilter(finMessageFilter);
                mbFileFinMessage.search();
            } else if (REJECT_TAB.equalsIgnoreCase(tabName)) {
                MbAmexRejectSearchBottom mbReject = ManagedBeanWrapper.getManagedBean(MbAmexRejectSearchBottom.class);
                AmexReject rejectFilter = new AmexReject();
                rejectFilter.setFileId(activeItem.getId());
                mbReject.setFilter(rejectFilter);
                mbReject.search();
            }
            needRerender = tabName;
            loadedTabs.put(tabName, Boolean.TRUE);
        }
    }

    public void search() {
        setSearching(true);
        clearBean();
        paramMap = new HashMap<String, Object>();
    }

    private void clearBean() {
        fileSource.flushCache();
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
        ManagedBeanWrapper.getManagedBean(MbAmexFileFinMessagesBottom.class).clearFilter();
        ManagedBeanWrapper.getManagedBean(MbAmexRejectSearchBottom.class).clearFilter();
    }

    public void setTabName(String tabName) {
        needRerender = null;
        this.tabName = tabName;
        if (!((loadedTabs.get(tabName) != null) ? loadedTabs.get(tabName) : false)) {
            loadTab(tabName);
            if (FILE_FIN_MESSAGES_TAB.equalsIgnoreCase(tabName)) {
                MbAmexFileFinMessagesBottom bean = ManagedBeanWrapper.getManagedBean(MbAmexFileFinMessagesBottom.class);
                bean.setTabName(tabName);
                bean.setParentSectionId(getSectionId());
                bean.setTableState(getSateFromDB(bean.getComponentId()));
            } else if (REJECT_TAB.equalsIgnoreCase(tabName)) {
                MbAmexRejectSearchBottom bean = ManagedBeanWrapper.getManagedBean(MbAmexRejectSearchBottom.class);
                bean.setTabName(tabName);
                bean.setParentSectionId(getSectionId());
                bean.setTableState(getSateFromDB(bean.getComponentId()));
            }
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

    public void setFilter(AmexFile filter) {
        this.filter = filter;
    }

    public AmexFile getFilter() {
        if (filter == null) {
            filter = new AmexFile();
        }
        return filter;
    }

    public DaoDataModel<AmexFile> getItems() {
        return fileSource;
    }

    public AmexFile getActiveItem() {
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
        filter = new AmexFile();
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
}

