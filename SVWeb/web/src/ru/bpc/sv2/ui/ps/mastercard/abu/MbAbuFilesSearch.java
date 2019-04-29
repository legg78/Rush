package ru.bpc.sv2.ui.ps.mastercard.abu;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MastercardDao;
import ru.bpc.sv2.ps.mastercard.AbuFile;
import ru.bpc.sv2.ui.utils.AbstractSearchTabbedBean;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbAbuFilesSearch")
public class MbAbuFilesSearch extends AbstractSearchTabbedBean<AbuFile, AbuFile> {
    private static final Logger logger = Logger.getLogger("MCW");
    private static final String DETAILS_TAB = "detailsTab";
    private static final String MESSAGES_TAB = "fileMessagesTab";

    private MastercardDao mcDao = new MastercardDao();

    private List<SelectItem> institutions;
    private List<SelectItem> fileTypes;
    private List<String> rerenderList;

    @Override
    protected AbuFile createFilter() {
        return new AbuFile();
    }
    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    protected AbuFile addItem(AbuFile item) {
        return null;
    }

    @Override
    protected AbuFile editItem(AbuFile item) {
        return null;
    }

    @Override
    protected void deleteItem(AbuFile item) {

    }

    @Override
    protected void initFilters(AbuFile filter, List<Filter> filters) {
        filters.addAll(FilterBuilder.createFiltersDatesAsString(filter));
        filters.add(Filter.create(LANGUAGE, userLang));
    }
    @Override
    protected List<AbuFile> getObjectList(Long userSessionId, SelectionParams params) {
        return mcDao.getAbuFiles(userSessionId, params);
    }
    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        return mcDao.getAbuFilesCount(userSessionId, params);
    }
    @Override
    protected void onLoadTab(String tabName) {
        if (DETAILS_TAB.equals(tabName)) {
            /** Nothing to do */
        } else if (MESSAGES_TAB.equals(tabName)) {
            MbAbuFileMessagesSearch bean = ManagedBeanWrapper.getManagedBean(MbAbuFileMessagesSearch.class);
            if (bean != null) {
                bean.clearFilter();
                bean.getFilter().setFileId(activeItem.getId());
                bean.getFilter().setIssuing(isIssuingFile());
                bean.getFilter().setLang(userLang);
                bean.setParentSectionId(getSectionId());
                bean.search();
            }
        }
    }

    public String getSectionId() {
        return SectionIdConstants.MC_ABU_FILES;
    }

    public List<SelectItem> getFileTypes() {
        if (fileTypes == null) {
            Map<String, Object> params = new HashMap<String, Object>(1);
            params.put(DictNames.MAIN_DICTIONARY, DictNames.PROCESS_FILE_TYPE);
            fileTypes = getDictUtils().getLov(LovConstants.ABU_FILE_TYPES, params);
            if (fileTypes == null) {
                fileTypes = new ArrayList<SelectItem>();
            }
        }
        return fileTypes;
    }

    public List<SelectItem> getInstitutions() {
        if (institutions == null) {
            institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
            if (institutions == null) {
                institutions = new ArrayList<SelectItem>();
            }
        }
        return institutions;
    }

    public List<String> getRerenderList(){
        rerenderList = new ArrayList<String>();
        rerenderList.add("err_ajax");
        rerenderList.add(tabName);
        if (MESSAGES_TAB.equals(tabName)) {
            rerenderList.add("fileFinMessagesBottomForm, fileFinMessagesBottomForm:fileFinMessagesTable");
        }
        return rerenderList;
    }

    private boolean isIssuingFile() {
        if (activeItem != null) {
            if ("FLTPT626".equals(activeItem.getFileType()) || "FLTPR625".equals(activeItem.getFileType())) {
                return false;
            } else if ("ABUFT626".equals(activeItem.getFileType()) || "ABUFR625".equals(activeItem.getFileType())) {
                return false;
            }
        }
        return true;
    }
}
