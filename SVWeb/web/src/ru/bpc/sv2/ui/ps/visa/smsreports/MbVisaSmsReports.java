package ru.bpc.sv2.ui.ps.visa.smsreports;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.VisaDao;
import ru.bpc.sv2.ps.visa.VisaSmsReport;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbVisaSmsReports")
public class MbVisaSmsReports extends AbstractSearchBean<VisaSmsReport, VisaSmsReport> {
    private static final long serialVersionUID = 1L;
    private static Logger logger = Logger.getLogger("VIS");
    public static final String VISA_LOCALE = "ru.bpc.sv2.ui.bundles.Vis";

    private List<SelectItem> recordTypes;

    private VisaDao visaDao = new VisaDao();

    @Override
    @PostConstruct
    public void init() {
        super.init();
        initRecordTypes();
        String reportIdStr = FacesContext.getCurrentInstance().getExternalContext().getRequestParameterMap().get("reportId");
        if (reportIdStr != null) {
            getFilter().setId(Long.parseLong(reportIdStr));
            search();
            SelectionParams selectionParams = new SelectionParams();
            selectionParams.setRowIndexStart(0);
            selectionParams.setRowIndexEnd(1);
            List<VisaSmsReport> reports = getDataModel().loadData(selectionParams);
            if (!reports.isEmpty()) {
                setActiveItem(reports.get(0));
            }
        }
    }
    @Override
    protected VisaSmsReport createFilter() {
        return new VisaSmsReport();
    }
    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    protected VisaSmsReport addItem(VisaSmsReport item) {
        return null;
    }

    @Override
    protected VisaSmsReport editItem(VisaSmsReport item) {
        return null;
    }

    @Override
    protected void deleteItem(VisaSmsReport item) {

    }

    @Override
    protected void initFilters(VisaSmsReport filter, List<Filter> filters) {
        if (StringUtils.isEmpty(filter.getLang())) {
            filter.setLang(userLang);
        }
        if (StringUtils.isNotEmpty(filter.getCardNumber())) {
            filter.setCardNumber(Filter.mask(filter.getCardNumber()));
        }
        filters.addAll(FilterBuilder.createFiltersAsString(filter));
    }
    @Override
    protected List<VisaSmsReport> getObjectList(Long userSessionId, SelectionParams params) {
        List<VisaSmsReport> out = visaDao.getVisaSmsReports(userSessionId, params);
        return out;
    }
    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        int out = visaDao.getVisaSmsReportsCount(userSessionId, params);
        return out;
    }

    public List<SelectItem> getRecordTypes() {
        if (recordTypes == null) {
            initRecordTypes();
        }
        return recordTypes;
    }

    public List<SelectItem> getInstitutions() {
        return getDictUtils().getLov(LovConstants.INSTITUTIONS);
    }

    public ArrayList<SelectItem> getStatuses() {
        return getDictUtils().getArticles(DictNames.VISA_SMS_REPORT_STATUSES, true);
    }

    private void initRecordTypes() {
        recordTypes = new ArrayList<SelectItem>();
        recordTypes.add(new SelectItem("V23200", "V23200 - " + FacesUtils.getMessage(VISA_LOCALE, "fin_trans_rec_1")));
        recordTypes.add(new SelectItem("V23201", "V23201 - " + FacesUtils.getMessage(VISA_LOCALE, "fin_trans_rec_2")));
        recordTypes.add(new SelectItem("V23202", "V23202 - " + FacesUtils.getMessage(VISA_LOCALE, "fin_trans_rec_3")));
    }
}
