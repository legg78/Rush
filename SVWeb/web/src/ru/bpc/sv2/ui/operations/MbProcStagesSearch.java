package ru.bpc.sv2.ui.operations;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.ProcStage;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Gasanov on 26.11.2015.
 */
@ViewScoped
@ManagedBean(name = "MbProcStagesSearch")
public class MbProcStagesSearch extends AbstractBean{
    private static final long serialVersionUID = 1L;

    private static final Logger logger = Logger.getLogger("ISSUING");

    private static String COMPONENT_ID = "procStagesTable";
    private static Integer DEFAULT_INST = 9999;

    private OperationDao _operationDao = new OperationDao();

    private ProcStage filter;
    private ProcStage _activeProcStage;
    private ProcStage newProcStage;

    protected String tabName;
    private String backLink;

    private List<SelectItem> msgTypes;
    private List<SelectItem> settlementTypes;
    private List<SelectItem> operTypes;
    private List<SelectItem> partTypes;
    private List<SelectItem> stages;
    private List<SelectItem> statuses;
    private List<SelectItem> commands;

    private final DaoDataModel<ProcStage> _procStagesSource;
    private final TableRowSelection<ProcStage> _itemSelection;

    public MbProcStagesSearch() {
        backLink = "operations|stages";
        tabName = "detailsTab";
        _procStagesSource = new DaoDataModel<ProcStage>() {
            private static final long serialVersionUID = 1L;

            @Override
            protected ProcStage[] loadDaoData(SelectionParams params) {
                if (!searching) {
                    return new ProcStage[0];
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return _operationDao.getProcStages(userSessionId, params);
                } catch (Exception e) {
                    FacesUtils.addMessageError(e);
                    setDataSize(0);
                    logger.error("", e);
                }
                return new ProcStage[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching) {
                    return 0;
                }
                int count = 0;
                int threshold = 1000;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    params.setThreshold(threshold);
                    count = _operationDao.getProcStagesCount(userSessionId, params);
                } catch (Exception e) {
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return count;
            }
        };

        HttpServletRequest req = RequestContextHolder.getRequest();
        String sectionId = req.getParameter("sectionId");
        String filterId = req.getParameter("filterId");

        if (sectionId != null && filterId != null && sectionId.equals("1012")) {
            selectedSectionFilter = Integer.parseInt(filterId);
            applySectionFilter(selectedSectionFilter);
        }

        _itemSelection = new TableRowSelection<ProcStage>(null, _procStagesSource);
    }

    public DaoDataModel<ProcStage> getProcStages() {
        return _procStagesSource;
    }

    public ProcStage getActiveProcStage() {
        return _activeProcStage;
    }

    public void setActiveProcStage(ProcStage activeProcStage) {
        _activeProcStage = activeProcStage;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (_activeProcStage == null && _procStagesSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (_activeProcStage != null && _procStagesSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(_activeProcStage.getModelId());
                _itemSelection.setWrappedSelection(selection);
                _activeProcStage = _itemSelection.getSingleSelection();
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return _itemSelection.getWrappedSelection();
    }

    public void setFirstRowActive() {
        _procStagesSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        _activeProcStage = (ProcStage) _procStagesSource.getRowData();
        selection.addKey(_activeProcStage.getModelId());
        _itemSelection.setWrappedSelection(selection);
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        _activeProcStage = _itemSelection.getSingleSelection();
    }

    public void search() {
        clearState();
        searching = true;
    }

    public void clearFilter() {
        sectionFilterModeEdit = true;
        sectionFilter = null;
        selectedSectionFilter = null;

        filter = null;
        clearState();
        searching = false;
    }

    public ProcStage getFilter() {
        if (filter == null) {
            filter = new ProcStage();
        }
        return filter;
    }

    public void setFilter(ProcStage filter) {
        this.filter = filter;
    }

    private void setFilters() {
        filter = getFilter();
        filters = new ArrayList<Filter>();

        Filter paramFilter;
        if (filter.getId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("id");
            paramFilter.setValue(filter.getId());
            filters.add(paramFilter);
        }

        if (filter.getMsgType() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("msgType");
            paramFilter.setValue(filter.getMsgType());
            filters.add(paramFilter);
        }

        if (filter.getSttlType() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("sttlType");
            paramFilter.setValue(filter.getSttlType());
            filters.add(paramFilter);
        }

        paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setValue(curLang);
        filters.add(paramFilter);

        if (filter.getOperType() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("operType");
            paramFilter.setValue(filter.getOperType());
            filters.add(paramFilter);
        }

        if (filter.getProcStage() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("procStage");
            paramFilter.setValue(filter.getProcStage());
            filters.add(paramFilter);
        }

        if (filter.getName() != null && filter.getName().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("name");
            paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]",
                    "_").toUpperCase());
            filters.add(paramFilter);
        }
    }

    public void add() {
        newProcStage = new ProcStage();
        curMode = NEW_MODE;
    }

    public void edit() {
        try {
            newProcStage = _activeProcStage.clone();
        } catch (CloneNotSupportedException e) {
            logger.error("", e);
            newProcStage = _activeProcStage;
        }
        curMode = EDIT_MODE;
    }

    public void save() {
        try {
            if (isNewMode()) {
                newProcStage = _operationDao.addProcStage(userSessionId, newProcStage, curLang);
                _itemSelection.addNewObjectToList(newProcStage);
            } else {
                newProcStage = _operationDao.modifyProcStage(userSessionId, newProcStage, curLang);
                _procStagesSource.replaceObject(_activeProcStage, newProcStage);
            }
            _activeProcStage = newProcStage;
            curMode = VIEW_MODE;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void delete() {
        try {
            _operationDao.deleteProcStage(userSessionId, _activeProcStage);
            curMode = VIEW_MODE;

            _activeProcStage = _itemSelection.removeObjectFromList(_activeProcStage);
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void view() {

    }

    public void cancel(){
        curMode = NEW_MODE;
    }

    public void close() {
        curMode = VIEW_MODE;
    }

    public ProcStage getNewProcStage() {
        if (newProcStage == null) {
            newProcStage = new ProcStage();
        }
        return newProcStage;
    }

    public void setnewProcStage(ProcStage newProcStage) {
        this.newProcStage = newProcStage;
    }

    public void clearState() {
        _itemSelection.clearSelection();
        _activeProcStage = null;
        _procStagesSource.flushCache();
        curLang = userLang;
    }

    public ProcStage getStageByLanguage(String lang, Long id) {
        List<Filter> filtersList = new ArrayList<Filter>();


        Filter paramFilter = new Filter();
        paramFilter.setElement("id");
        paramFilter.setValue(id.toString());
        filtersList.add(paramFilter);

        paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setValue(lang);
        filtersList.add(paramFilter);

        filters = filtersList;
        SelectionParams params = new SelectionParams();
        params.setFilters(filters.toArray(new Filter[filters.size()]));
        try {
            ProcStage[] stages = _operationDao.getProcStages(userSessionId, params);
            if (stages != null && stages.length > 0) {
                return stages[0];
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return null;
    }

    public void changeLanguage(ValueChangeEvent event) {
        curLang = (String) event.getNewValue();
        ProcStage stage = getStageByLanguage(curLang, _activeProcStage.getId());
        if(stage != null){
            _activeProcStage = stage;
        }
    }

    public void confirmEditLanguage() {
        ProcStage stage = getStageByLanguage(newProcStage.getLang(), newProcStage.getId());
        if(stage != null){
            newProcStage = stage;
        }
    }

    @Override
    protected void applySectionFilter(Integer filterId) {
        try {
            FilterFactory factory = (FilterFactory) ManagedBeanWrapper
                    .getManagedBean("filterFactory");
            Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
            sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
            if (filterRec != null) {
                filter = new ProcStage();
                if (filterRec.get("msgType") != null) {
                    filter.setMsgType(filterRec.get("msgType"));
                }
                if (filterRec.get("sttlType") != null) {
                    filter.setSttlType(filterRec.get("sttlType"));
                }
                if (filterRec.get("operType") != null) {
                    filter.setOperType(filterRec.get("operType"));
                }
                if (filterRec.get("procStage") != null) {
                    filter.setProcStage(filterRec.get("procStage"));
                }
                if (filterRec.get("name") != null) {
                    filter.setName(filterRec.get("name"));
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
            if (filter.getMsgType() != null) {
                filterRec.put("msgType", filter.getMsgType());
            }
            if (filter.getSttlType() != null) {
                filterRec.put("sttlType", filter.getSttlType());
            }
            if (filter.getOperType() != null) {
                filterRec.put("operType", filter.getOperType());
            }
            if (filter.getProcStage() != null) {
                filterRec.put("procStage", filter.getProcStage());
            }
            if (filter.getName() != null && !filter.getName().trim().equals("")) {
                filterRec.put("name", filter.getName());
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

    public List<SelectItem> getMsgTypes(){
        if (msgTypes == null) {
            msgTypes = getDictUtils().getLov(LovConstants.MSG_TYPE);
        }
        if (msgTypes == null) {
            return new ArrayList<SelectItem>(0);
        }
        return msgTypes;
    }

    public List<SelectItem> getSettlementTypes() {
        if (settlementTypes == null) {
            settlementTypes = getDictUtils().getLov(LovConstants.SETTLEMENT_TYPES);
        }
        return settlementTypes;
    }

    public List<SelectItem> getOperTypes() {
        if (operTypes == null) {
            operTypes = getDictUtils().getLov(LovConstants.OPERATION_TYPE);
        }
        return operTypes;
    }

    public List<SelectItem> getPartTypes() {
        if (partTypes == null) {
	        partTypes = getDictUtils().getLov(LovConstants.PARTICIPANT_TYPES);
        }
        return partTypes;
    }

    public List<SelectItem> getStages() {
        if (stages == null) {
            stages = getDictUtils().getLov(LovConstants.PROC_STAGES);
        }
        return stages;
    }

    public List<SelectItem> getStatuses(){
        if (statuses == null) {
            statuses = getDictUtils().getLov(LovConstants.OPERATION_STATUSES);
        }
        return statuses;
    }

    public List<SelectItem> getCommands(){
        if (commands == null) {
            commands = getDictUtils().getLov(LovConstants.CONTROL_COMMANDS);
        }
        return commands;
    }

    public String getComponentId() {
        return COMPONENT_ID;
    }

    public Logger getLogger() {
        return logger;
    }
}
