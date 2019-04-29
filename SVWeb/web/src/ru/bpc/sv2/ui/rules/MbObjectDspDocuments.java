package ru.bpc.sv2.ui.rules;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.RptDocument;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.cache.DictCache;
import ru.bpc.sv2.utils.SystemUtils;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.*;

/**
 * Created by Gasanov on 10.08.2016.
 */
@ViewScoped
@ManagedBean(name = "MbObjectDspDocuments")
public class MbObjectDspDocuments extends AbstractBean {

    private static final Logger logger = Logger.getLogger("RULES");

    private ReportsDao reportsDao = new ReportsDao();

    private RptDocument filter;

    private RptDocument activeItem;

    private final DaoDataModel<RptDocument> dataModel;
    private final TableRowSelection<RptDocument> tableRowSelection;

    private List<SelectItem> documentTypes;
    private Map<String, String> documentTypeNames;

    private static String COMPONENT_ID = "dspDocumentsTable";
    private String tabName;
    private String parentSectionId;
    private String fileLink = null;
    private boolean fileExists;

    private List<DspApplication> selectedObjects;
    private String module;
    private String submodule;

    public MbObjectDspDocuments() {
        dataModel = new DaoDataModel<RptDocument>() {
            @Override
            protected RptDocument[] loadDaoData(SelectionParams params) {
                RptDocument[] result = null;
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    params.setModule(ModuleNames.CASE_MANAGEMENT);
                    try {
                        result = reportsDao.getDocumentContents(userSessionId, params);
                    } catch (DataAccessException e) {
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                } else {
                    result = new RptDocument[0];
                }
                return result;
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                int result = 0;
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    params.setModule(ModuleNames.CASE_MANAGEMENT);
                    try {
                        result = reportsDao.getDocumentsCount(userSessionId, params);
                    } catch (DataAccessException e) {
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                } else {
                    result = 0;
                }
                return result;
            }
        };
        tableRowSelection = new TableRowSelection<RptDocument>(null, dataModel);
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(new Filter("lang", curLang));
        if (filter.getObjectId() != null)
            filters.add(new Filter("objectId", filter.getObjectId()));
        if (filter.getEntityType() != null)
            filters.add(new Filter("entityType", filter.getEntityType()));
        if (filter.getDocumentType() != null) {
            filters.add(new Filter("documentType", filter.getDocumentType()));
        }
    }

    public void search() {
        clearState();
        clearBeansStates();
        searching = true;
    }

    public void clearState() {
        tableRowSelection.clearSelection();
        activeItem = null;
        dataModel.flushCache();
        curLang = userLang;
    }

    public void clearBeansStates() {

    }

    public void clearFilter() {
        filter = null;
        clearState();
        clearBeansStates();
        searching = false;
    }

    public SimpleSelection getItemSelection() {
        if (activeItem == null && dataModel.getRowCount() > 0) {
            prepareItemSelection();
        }
        return tableRowSelection.getWrappedSelection();
    }

    public void prepareItemSelection() {
        dataModel.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (RptDocument) dataModel.getRowData();
        selection.addKey(activeItem.getModelId());
        tableRowSelection.setWrappedSelection(selection);
        if (activeItem != null) {
            setBeansState();
        }
    }

    public void setItemSelection(SimpleSelection selection) {
        tableRowSelection.setWrappedSelection(selection);
        activeItem = tableRowSelection.getSingleSelection();
        if (activeItem != null) {
            setBeansState();
        }
    }

    private void setBeansState() {

    }

    public RptDocument getFilter() {
        if (filter == null) {
            filter = new RptDocument();
        }
        return filter;
    }

    public void setFilter(RptDocument filter){
        this.filter = filter;
    }

    public DaoDataModel<RptDocument> getDataModel() {
        return dataModel;
    }

    public RptDocument getActiveItem() {
        return activeItem;
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

    public List<SelectItem> getDocumentTypes() {
        if (documentTypes == null) {
            documentTypes = getDictUtils().getLov(LovConstants.DISPUTE_DOCUMENT_TYPES, null, null, DictCache.NAME);
        }
        return documentTypes;
    }

    public Map<String, String> getDocumentTypeNames() {
        if (documentTypeNames == null) {
            documentTypeNames = getDictUtils().getArticlesMap("DSDT");
        }
        return documentTypeNames;
    }

    public void checkFile(){
        File file = new File(activeItem.getSavePath());
        if(file.exists()){
            fileExists = true;
        }else{
            fileExists = false;
        }
    }

    public void download() throws IOException {
        File file = new File(activeItem.getSavePath());
        HttpServletResponse res = RequestContextHolder.getResponse();
        res.setContentType("application/x-download");
        String URLEncodedFileName = URLEncoder.encode(activeItem.getFileName(), "UTF-8");
        res.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncodedFileName + "\"");
        SystemUtils.copy(file, res.getOutputStream());
        FacesContext.getCurrentInstance().responseComplete();
    }

    public boolean isAttachDisabled() {
        boolean attachDisabled = false;
        if (selectedObjects == null) {
            return true;
        }
        Iterator<DspApplication> iter = selectedObjects.iterator();
        if (ApplicationConstants.TYPE_DISPUTES.equals(module) && ApplicationConstants.TYPE_ISSUING.equals(submodule)) {
            while (iter.hasNext() && !attachDisabled){
                DspApplication appl = iter.next();
                attachDisabled = ApplicationStatuses.READY_FOR_REVIEW.equals(appl.getStatus()) || ApplicationStatuses.ACCEPTED.equals(appl.getStatus()) ||
                        ApplicationStatuses.REJECTED.equals(appl.getStatus());
            }
        } else if (ApplicationConstants.TYPE_ISSUING.equals(module) || ApplicationConstants.TYPE_ACQUIRING.equals(module)) {
            while (iter.hasNext() && !attachDisabled){
                DspApplication appl = iter.next();
                attachDisabled = ApplicationStatuses.CLOSED_STATUSES.contains(appl.getStatus());
            }
        }
        return attachDisabled;
    }

    public String getFileLink() {
        return fileLink;
    }

    public boolean isFileExists() {
        return fileExists;
    }

    public List<DspApplication> getSelectedObjects() {
        return selectedObjects;
    }

    public void setSelectedObjects(List<DspApplication> selectedObjects) {
        this.selectedObjects = selectedObjects;
    }

    public String getModule() {
        return module;
    }

    public void setModule(String module) {
        this.module = module;
    }

    public String getSubmodule() {
        return submodule;
    }

    public void setSubmodule(String submodule) {
        this.submodule = submodule;
    }
}
