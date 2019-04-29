package ru.bpc.sv2.ui.ps.mastercard.abu;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MastercardDao;
import ru.bpc.sv2.ps.mastercard.AbuIssMessage;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;
import ru.bpc.sv2.ui.utils.AbstractSearchTabbedBean;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbAbuIssMessagesSearch")
public class MbAbuIssMessagesSearch extends AbstractSearchTabbedBean<AbuIssMessage, AbuIssMessage> {
    private static Logger logger = Logger.getLogger("MCW");
    private static final String DETAILS_TAB = "detailsTab";

    private MastercardDao mcDao = new MastercardDao();

    private List<SelectItem> institutions;
    private List<SelectItem> statuses;
    private List<String> rerenderList;

    @Override
    protected AbuIssMessage createFilter() {
        return new AbuIssMessage();
    }
    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    protected AbuIssMessage addItem(AbuIssMessage item) {
        return null;
    }

    @Override
    protected AbuIssMessage editItem(AbuIssMessage item) {
        return null;
    }

    @Override
    protected void deleteItem(AbuIssMessage item) {

    }

    @Override
    protected void initFilters(AbuIssMessage filter, List<Filter> filters) {
        filters.addAll(FilterBuilder.createFiltersDatesAsString(filter));
        filters.add(Filter.create(LANGUAGE, userLang));
    }
    @Override
    protected List<AbuIssMessage> getObjectList(Long userSessionId, SelectionParams params) {
        return mcDao.getAbuIssMessages(userSessionId, params);
    }
    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        return mcDao.getAbuIssMessagesCount(userSessionId, params);
    }
    @Override
    protected void onLoadTab(String tabName) {
        if (DETAILS_TAB.equals(tabName)) {
            /** Nothing to do */
        }
    }

    public List<SelectItem> getStatuses() {
        if (statuses == null) {
            statuses = getDictUtils().getArticles(DictNames.MC_ABU_MESSAGE_STATUSES, false, true);
            if (statuses == null) {
                statuses = new ArrayList<SelectItem>();
            }
        }
        return statuses;
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
        return rerenderList;
    }
}