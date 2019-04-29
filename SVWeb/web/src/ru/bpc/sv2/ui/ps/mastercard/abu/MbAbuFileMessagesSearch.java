package ru.bpc.sv2.ui.ps.mastercard.abu;

import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MastercardDao;
import ru.bpc.sv2.ps.mastercard.AbuFileMessage;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbAbuFileMessagesSearch")
public class MbAbuFileMessagesSearch extends AbstractSearchBean<AbuFileMessage, AbuFileMessage> {
    private static final Logger logger = Logger.getLogger("MCW");

    private static final String COMPONENT_ID = "fileFinMessageTable";
    private String tabName;
    private String parentSectionId;

    private MastercardDao mcDao = new MastercardDao();

    @Override
    protected AbuFileMessage createFilter() {
        return new AbuFileMessage();
    }
    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    protected AbuFileMessage addItem(AbuFileMessage item) {
        return null;
    }

    @Override
    protected AbuFileMessage editItem(AbuFileMessage item) {
        return null;
    }

    @Override
    protected void deleteItem(AbuFileMessage item) {

    }

    @Override
    protected void initFilters(AbuFileMessage filter, List<Filter> filters) {
        filters.addAll(FilterBuilder.createFiltersDatesAsString(filter));
        filters.add(Filter.create(LANGUAGE, userLang));
    }
    @Override
    protected List<AbuFileMessage> getObjectList(Long userSessionId, SelectionParams params) {
        return mcDao.getAbuFileMessages(userSessionId, params);
    }
    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        return mcDao.getAbuFileMessagesCount(userSessionId, params);
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
