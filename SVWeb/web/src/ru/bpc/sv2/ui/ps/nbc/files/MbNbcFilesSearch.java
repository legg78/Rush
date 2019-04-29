package ru.bpc.sv2.ui.ps.nbc.files;

/**
 * Created by Viktorov on 07.12.2016.
 */

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NbcDao;
import ru.bpc.sv2.ps.nbc.NbcFile;
import ru.bpc.sv2.ps.nbc.NbcFinMessage;
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
@ManagedBean(name = "MbNbcFilesSearch")
public class MbNbcFilesSearch extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;

    private static final Logger logger = Logger.getLogger("NBC");

    private static final String FILE_FIN_MESSAGES_TAB = "fileFinMessagesTab";

    private static final String COMPONENT_ID = "fileFinMessageTable";

    private NbcDao nbcDao = new NbcDao();

    private NbcFile filter;
    private final DaoDataModel<NbcFile> fileSource;

    private NbcFile activeItem;
    private final TableRowSelection<NbcFile> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private Map<String, Object> paramMap;
    private Integer rejected;
    private List<SelectItem> yesNoLov;

    public MbNbcFilesSearch() {
        pageLink = "nbc|files";
        fileSource = new DaoDataListModel<NbcFile>(logger) {
            @Override
            protected List<NbcFile> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return nbcDao.getFiles(userSessionId, params);
                }
                return new ArrayList<NbcFile>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return nbcDao.getFilesCount(userSessionId, params);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<NbcFile>(null, fileSource);
        tabName = "detailsTab";
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters() {

        NbcFile fileFilter = getFilter();
        filters = new ArrayList<Filter>();
        Filter paramFilter;

        if (fileFilter.getId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("fileId");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(fileFilter.getId());
            filters.add(paramFilter);
        }

        if (fileFilter.getSessionId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("sessionId");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(fileFilter.getSessionId());
            filters.add(paramFilter);
        }

        if (fileFilter.getFileName() != null && fileFilter.getFileName().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("fileName");
            paramFilter.setOp(Filter.Operator.like);
            paramFilter.setValue(fileFilter.getFileName().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }

        String dbDateFormat = "dd.MM.yyyy";
        SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
        if (fileFilter.getDateFrom() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("dateFrom");
            paramFilter.setValue(df.format(fileFilter.getDateFrom()));
            filters.add(paramFilter);
        }
        if (fileFilter.getDateTo() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("dateTo");
            paramFilter.setValue(df.format(fileFilter.getDateTo()));
            filters.add(paramFilter);
        }

        paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setValue(userLang);
        filters.add(paramFilter);
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
        activeItem = (NbcFile) fileSource.getRowData();
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
        if (tabName.equalsIgnoreCase(FILE_FIN_MESSAGES_TAB)) {
            MbNbcFileFinMessagesBottom mbFileFinMessage = ManagedBeanWrapper.getManagedBean(MbNbcFileFinMessagesBottom.class);
            NbcFinMessage finMessageFilter = new NbcFinMessage();
            finMessageFilter.setFileId(activeItem.getId());
            mbFileFinMessage.setFilter(finMessageFilter);
            mbFileFinMessage.search();
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
        ManagedBeanWrapper.getManagedBean(MbNbcFileFinMessagesBottom.class).clearFilter();
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

        if (tabName.equalsIgnoreCase(FILE_FIN_MESSAGES_TAB)) {
            MbNbcFileFinMessagesBottom bean = ManagedBeanWrapper.getManagedBean(MbNbcFileFinMessagesBottom.class);
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

    public void setFilter(NbcFile filter) {
        this.filter = filter;
    }

    public NbcFile getFilter() {
        if (filter == null) {
            filter = new NbcFile();
        }
        return filter;
    }

    public DaoDataModel<NbcFile> getItems() {
        return fileSource;
    }

    public NbcFile getActiveItem() {
        return activeItem;
    }

    public void setRowsNum(int rowsNum) {
        this.rowsNum = rowsNum;
    }

    public int getRowsNum() {
        return rowsNum;
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
        filter = new NbcFile();
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

