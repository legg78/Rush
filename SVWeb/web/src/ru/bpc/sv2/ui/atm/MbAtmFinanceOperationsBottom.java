package ru.bpc.sv2.ui.atm;


import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.atm.AtmCollection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.AtmDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ManagedProperty;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbAtmFinanceOperationsBottom")
public class MbAtmFinanceOperationsBottom extends AbstractBean {
    private static final Logger logger = Logger.getLogger("OPER_PROCESSING");
    private static final long serialVersionUID = 4946328375636270680L;

    private OperationDao operationDao = new OperationDao();
    private AtmDao atmDao = new AtmDao();

    public DaoDataModel<Operation> getOperations() {
        return dataModel;
    }

    @ManagedProperty(value="#{usession}")
    private UserSession mbUserSession;

    public void setMbUserSession(UserSession mbUserSession) {
        this.mbUserSession = mbUserSession;
    }

    @ManagedProperty(value="#{CommonUtils}")
    private CommonUtils mbCommonUtils;

    public void setMbCommonUtils(CommonUtils mbCommonUtils) {
        this.mbCommonUtils = mbCommonUtils;
    }



    private Operation operationFilter;
    private Operation activeItem;
    private final DaoDataModel<Operation> dataModel;
    private final TableRowSelection<Operation> tableRowSelection;
    private Date hostDateFrom;
    private Date hostDateTo;
    private static String COMPONENT_ID = "operationsTable";
    private String tabName;
    private String parentSectionId;
    private List<SelectItem> collections;
    private AtmCollection[] collectionSource;
    private Long atmCollectionIndex;
    private String displayFormat;
    private boolean disableOperType;
    private Date operDateTo;
    private Date operDateFrom;

    private static final long TIME_CONSTANT = 24*3600*1000;


    public MbAtmFinanceOperationsBottom() {
        displayFormat = "MMMM dd, yyyy";
        operationFilter = new Operation();

        dataModel = new DaoDataModel<Operation>() {
            private static final long serialVersionUID = -1514377742409280850L;

            @Override
            protected Operation[] loadDaoData(SelectionParams params) {
                Operation[] operations = null;
                if (searching)
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        operations = operationDao.getAtmOperationsByParticipant(userSessionId, params);
                    } catch (Exception e) {
                        setDataSize(0);
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                return operations == null ? new Operation[0] : operations;
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                int operationsSize = 0;
                if (searching)
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        operationsSize = operationDao.getAtmOperationsByParticipantCount(userSessionId, params);
                    } catch (Exception e) {
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                return operationsSize;
            }
        };

        tableRowSelection = new TableRowSelection<Operation>(null, dataModel);
    }

    public void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(new Filter("lang", userLang));
        filters.addAll(getDateFilters());
        filters.add(new Filter("terminalId", getFilter().getTerminalId()));
        String operType = getFilter().getOperType();
        if(operType != null)
            filters.add(new Filter("operType", operType));
    }

    public void search() {
        clearState();
        searching = true;
    }

    public void clearState() {
        tableRowSelection.clearSelection();
        activeItem = null;
        dataModel.flushCache();
        curLang = userLang;
        atmCollectionIndex = null;
        collections = null;
        collectionSource = null;
    }

    public void clearFilter() {
        clearState();
        curLang = userLang;
        operationFilter = new Operation();
        operDateFrom = null;
        operDateTo = null;
        searching = false;
    }

    public SimpleSelection getItemSelection() {
        setFirstRowActive();
        return tableRowSelection.getWrappedSelection();
    }

    public Operation getActiveOperation() {
        return activeItem;
    }

    public void setActiveOperation(Operation activeOperation) {
        activeItem = activeOperation;
    }

    public void setItemSelection(SimpleSelection selection) {
        tableRowSelection.setWrappedSelection(selection);
        activeItem = tableRowSelection.getSingleSelection();
    }

    public void setFirstRowActive() {
        if (activeItem == null && dataModel.getRowCount() > 0) {
            dataModel.setRowIndex(0);
            SimpleSelection selection = new SimpleSelection();
            activeItem = (Operation) dataModel.getRowData();
            selection.addKey(activeItem.getModelId());
            tableRowSelection.setWrappedSelection(selection);
        }
    }

    private List<Filter> getDateFilters() {

        List<Filter> filters = new ArrayList<Filter>();
        String dbDateFormat = mbUserSession.getDatePattern();
        SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
        df.setTimeZone(mbCommonUtils.getTimeZone());

        if(hostDateFrom != null)
            filters.add(new Filter("hostDateFrom", df.format(hostDateFrom)));

        if(hostDateTo != null)
            filters.add(new Filter("hostDateTo", df.format(hostDateTo)));

        if (operDateFrom != null) {
            filters.add(new Filter("operDateFrom", df.format(operDateFrom)));
            if (hostDateFrom == null)
                filters.add(new Filter("hostDateFrom", df.format(new Date(operDateFrom.getTime() - TIME_CONSTANT))));
        }

        if (operDateTo != null) {
            filters.add(new Filter("operDateTo", df.format(operDateTo)));
            if (hostDateTo == null)
                filters.add(new Filter("hostDateTo", df.format(new Date(operDateTo.getTime() + TIME_CONSTANT))));
        }

        return filters;
    }


    public void resetBean() {
    }

    public Operation getFilter() {
        return operationFilter == null ? new Operation() : operationFilter;
    }

    public void setFilter(Operation operationFilter) {
        this.operationFilter = operationFilter;
    }

    public ArrayList<SelectItem> getAllAccountTypes() {
        return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
    }

    public Date getHostDateFrom() {
        return hostDateFrom;
    }

    public void setHostDateFrom(Date hostDateFrom) {
        this.hostDateFrom = hostDateFrom;
    }

    public Date getHostDateTo() {
        return hostDateTo;
    }

    public void setHostDateTo(Date hostDateTo) {
        this.hostDateTo = hostDateTo;
    }

    public String getDisplayFormat() {
        return displayFormat;
    }

    public void setDisplayFormat(String displayFormat) {
        this.displayFormat = displayFormat;
    }

    public void view() {

    }

    public List<SelectItem> getCollections(){

        collections = new ArrayList<SelectItem>();
        collections.add(new SelectItem("-1",""));
        if (getFilter().getTerminalId() == null) return collections;
        SelectionParams sp = SelectionParams.build("terminalId", getFilter().getTerminalId());
        sp.setRowIndexEnd(-1);
        sp.setSortElement(new SortElement("startDate", SortElement.Direction.ASC));
        collectionSource = atmDao.getAtmCollections(userSessionId, sp);

        if(collectionSource != null)
            for (int i = 0; i < collectionSource.length; i++)
                collections.add(
                        new SelectItem("" + i,
                                String.format("%d - %tc", collectionSource[i].getId(), collectionSource[i].getStartDate())));
        return collections;

    }

    public Long getAtmCollectionIndex() {
        return atmCollectionIndex;
    }

    public void setAtmCollectionIndex(Long atmCollectionIndex) {

        this.atmCollectionIndex = atmCollectionIndex;
        if(atmCollectionIndex == -1) {
            operDateFrom = initOperDateFrom();
            operDateTo = null;
            return;
        }

        AtmCollection start = collectionSource[atmCollectionIndex.intValue()];
        operDateFrom = start.getStartDate();
        if (atmCollectionIndex.intValue() + 1 < collectionSource.length){
            AtmCollection end = collectionSource[atmCollectionIndex.intValue() + 1];
            operDateTo = end.getStartDate();
        }else operDateTo = null;
    }

    public boolean isDisableOperType() {
        return disableOperType;
    }

    public void setDisableOperType(boolean disableOperType) {
        this.disableOperType = disableOperType;
    }

    public Date getOperDateTo() {
        return operDateTo;
    }

    public void setOperDateTo(Date operDateTo) {
        this.operDateTo = operDateTo;
    }

    private Date initOperDateFrom() {
            GregorianCalendar cal = new GregorianCalendar();
            cal.setTime(new Date());
            cal.set(GregorianCalendar.HOUR_OF_DAY, 0);
            cal.set(GregorianCalendar.MINUTE, 0);
            cal.set(GregorianCalendar.SECOND, 0);
            cal.set(GregorianCalendar.MILLISECOND, 0);
            return cal.getTime();
    }


    public Date getOperDateFrom() {
        return operDateFrom == null ? initOperDateFrom() : operDateFrom;
    }

    public void setOperDateFrom(Date operDateFrom) {
        this.operDateFrom = operDateFrom;
    }

    public void updateData(){
        dataModel.flushCache();
    }

    public List<SelectItem> getOperationTypes(){
        List<SelectItem> result = getDictUtils().getArticles(DictNames.OPER_TYPE, true, true);
        return result;
    }

    public String getComponentId() {
        return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public void setParentSectionId(String parentSectionId) {
        this.parentSectionId = parentSectionId;
    }

}

