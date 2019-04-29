package ru.bpc.sv2.ui.dpp;

import org.ajax4jsf.model.KeepAlive;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.dpp.DefferedPaymentPlan;
import ru.bpc.sv2.dpp.DppMacros;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.DppDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.wizard.WizardPrivConstants;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbDualDppMacros")
public class MbDualDppMacros extends AbstractSearchBean<DppMacros, DppMacros> {
    private static Logger logger = Logger.getLogger(MbDualDppMacros.class);
    private CommonWizardStep.Mode mode = CommonWizardStep.Mode.NONE;
    private DppDao dppDao = new DppDao();

    public void select() {
        MbRegisterDppPaymentPlan bean = ManagedBeanWrapper.getManagedBean(MbRegisterDppPaymentPlan.class);
        bean.setDpp(getActiveItem().toDPP());
        reset();
    }

    public void reset() {
        clearFilter();
    }

    @Override
    protected DppMacros createFilter() {
        return new DppMacros();
    }
    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    protected DppMacros addItem(DppMacros item) {
        return null;
    }

    @Override
    protected DppMacros editItem(DppMacros item) {
        return null;
    }

    @Override
    protected void deleteItem(DppMacros item) {

    }

    @Override
    protected void initFilters(DppMacros filter, List<Filter> filters) {
        filters.addAll(FilterBuilder.createFiltersDatesAsString(filter));
        filters.add(Filter.create("lang", userLang));
    }
    @Override
    protected List<DppMacros> getObjectList(Long userSessionId, SelectionParams params) {
        return dppDao.getDppMacroses(userSessionId, params);
    }
    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        return dppDao.getDppMacrosesCount(userSessionId, params);
    }
}
