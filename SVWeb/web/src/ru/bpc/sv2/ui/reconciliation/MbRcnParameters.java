package ru.bpc.sv2.ui.reconciliation;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReconciliationDao;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.reconciliation.RcnConstants;
import ru.bpc.sv2.reconciliation.RcnParameter;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbRcnParameters")
public class MbRcnParameters extends AbstractBean {
    private static final Logger logger = Logger.getLogger("OPER_PROCESSING");
    private static final String PAGE = "page";
    private static final String ADD_BTN = "addBtn";
    private static final String EDIT_BTN = "editBtn";
    private static final String REMOVE_BTN = "deleteBtn";

    private RcnParameter filter;
    private RcnParameter newParameter;

    private List<SelectItem> institutions;
    private List<RcnParameter> dataSource;

    private ReconciliationDao reconciliationDao = new ReconciliationDao();

    private String module;
    private final DaoDataListModel<RcnParameter> parametersSource;
    private final TableRowSelection<RcnParameter> itemSelection;
    private RcnParameter activeParameter;

    public MbRcnParameters() {
        dataSource = null;
        parametersSource = new DaoDataListModel<RcnParameter>(logger) {
            @Override
            protected List<RcnParameter> loadDaoListData(SelectionParams params) {
                if (searching) {
                    if (dataSource == null) {
                        setFilters();
                        params.setFilters(filters);
                        params.setModule(getModule());
                        return reconciliationDao.getParameters(userSessionId, params);
                    } else {
                        return dataSource;
                    }
                }
                return new ArrayList<RcnParameter>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    if (dataSource == null) {
                        setFilters();
                        params.setFilters(filters);
                        params.setModule(getModule());
                        return reconciliationDao.getParametersCount(userSessionId, params);
                    } else {
                        return dataSource.size();
                    }
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<RcnParameter>(null, parametersSource);
    }

    public String getModule() {
        return module;
    }
    public void setModule(String module) {
        this.module = module;
    }

    public void setFilters() {
        filter = getFilter();
        filters = new ArrayList<Filter>();

        filters.add(Filter.create("lang", curLang));
        if (filter.getId() != null) {
            filters.add(Filter.create("id", filter.getId()));
        }
        if (filter.getInstId() != null && !filter.getInstId().equals(Institution.DEFAULT_INSTITUTION)) {
            filters.add(Filter.create("instId", filter.getInstId()));
        }
        if (filter.getPurposeId() != null) {
            filters.add(Filter.create("purposeId", filter.getPurposeId()));
        }
        if (filter.getProviderId() != null) {
            filters.add(Filter.create("providerId", filter.getProviderId()));
        }
    }

    public DaoDataListModel<RcnParameter> getParameters() {
        return parametersSource;
    }

    public RcnParameter getActiveParameter() {
        return activeParameter;
    }
    public void setActiveParameter(RcnParameter activeParameter) {
        this.activeParameter = activeParameter;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (activeParameter == null && parametersSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (activeParameter != null && parametersSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(activeParameter.getModelId());
                itemSelection.setWrappedSelection(selection);
                activeParameter = itemSelection.getSingleSelection();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return itemSelection.getWrappedSelection();
    }
    public void setItemSelection(SimpleSelection selection) {
        try {
            itemSelection.setWrappedSelection(selection);
            boolean changeSelect = false;
            if (itemSelection.getSingleSelection() != null &&
                    !itemSelection.getSingleSelection().getId().equals(activeParameter.getId())) {
                changeSelect = true;
            }
            activeParameter = itemSelection.getSingleSelection();
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public RcnParameter getFilter() {
        if (filter == null) {
            filter = new RcnParameter();
        }
        return filter;
    }
    public void setFilter(RcnParameter filter) {
        this.filter = filter;
    }

    public RcnParameter getNewParameter() {
        if (newParameter == null) {
            newParameter = new RcnParameter();
        }
        return newParameter;
    }
    public void setNewParameter(RcnParameter newParameter) {
        this.newParameter = newParameter;
    }

    public List<RcnParameter> getDataSource() {
        return dataSource;
    }
    public void setDataSource(List<RcnParameter> dataSource) {
        this.dataSource = dataSource;
    }

    public List<SelectItem> getInstitutions() {
        return getDictUtils().getLovUI(LovConstants.INSTITUTIONS_SYS, institutions);
    }

    public List<SelectItem> getPurposes() {
        Map<String, Object> params = new HashMap<String, Object>();
        if (getNewParameter().getProviderId() != null) {
            params.put("provider_id", getNewParameter().getProviderId());
        } else if (getFilter().getProviderId() != null) {
            params.put("provider_id", getFilter().getProviderId());
        }
        return getDictUtils().getLovUI(LovConstants.RECONCILIATION_PURPOSES, params);
    }

    public List<SelectItem> getProviders() {
        return getDictUtils().getLovUI(LovConstants.RECONCILIATION_PROVIDERS);
    }

    public List<SelectItem> getParameterList() {
        Map<String, Object> params = new HashMap<String, Object>();
        if (getNewParameter().getPurposeId() != null) {
            params.put("purpose_id", getNewParameter().getPurposeId());
        } else if (getFilter().getPurposeId() != null) {
            params.put("purpose_id", getFilter().getPurposeId());
        }
        return getDictUtils().getLovUI(LovConstants.RECONCILIATION_PARAMETERS, params);
    }

    public void setFirstRowActive() throws CloneNotSupportedException {
        parametersSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeParameter = (RcnParameter) parametersSource.getRowData();
        selection.addKey(activeParameter.getModelId());
        itemSelection.setWrappedSelection(selection);
    }

    public void search() {
        clearBean(true);
        searching = true;
    }
    public void searchByDataSource() {
        clearBean(false);
        searching = true;
    }

    @Override
    public void clearFilter() {
        clearBean(true);
        curLang = userLang;
        filter = null;
        searching = false;
    }
    @Override
    public Logger getLogger() {
        return logger;
    }

    public void clearBean(boolean cleanDataSource) {
        parametersSource.flushCache();
        itemSelection.clearSelection();
        activeParameter = null;
        if (cleanDataSource) {
            dataSource = null;
        }
    }

    public void add() {
        newParameter = new RcnParameter();
        curMode = NEW_MODE;
    }

    public void edit() {
        try {
            newParameter = (RcnParameter) activeParameter.clone();
        } catch (CloneNotSupportedException e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
            newParameter = activeParameter;
        }
        curMode = EDIT_MODE;
    }

    public void delete() {
        try {
            activeParameter.setModule(getModule());
            reconciliationDao.removeParameter(userSessionId, activeParameter);
            activeParameter = itemSelection.removeObjectFromList(activeParameter);
            if (activeParameter == null) {
                clearBean(true);
            }
            FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rec", "rec_parameter_deleted"));
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void save() {
        try {
            newParameter.setLang(curLang);
            newParameter.setModule(getModule());
            if (isNewMode()) {
                newParameter = reconciliationDao.addParameter(userSessionId, newParameter);
                itemSelection.addNewObjectToList(newParameter);
            } else {
                newParameter = reconciliationDao.modifyParameter(userSessionId, newParameter);
                parametersSource.replaceObject(activeParameter, newParameter);
            }
            activeParameter = (RcnParameter) newParameter.clone();
            activeParameter.setModule(getModule());
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        cancel();
    }

    public void cancel() {
        curMode = VIEW_MODE;
        setNewParameter(null);
    }

    public boolean isRendered(String component) {
        if (StringUtils.isNotEmpty(component)) {
            Map<String, Boolean> role = ((UserSession) ManagedBeanWrapper.getManagedBean("usession")).getInRole();
            switch (component) {
                case PAGE:
                    switch (getModule()) {
                        case RcnConstants.MODULE_SP:
                            return role.get(RcnConstants.VIEW_SP_PARAMETERS);
                    }
                    break;
                case ADD_BTN:
                    switch (getModule()) {
                        case RcnConstants.MODULE_SP:
                            return role.get(RcnConstants.ADD_SP_PARAMETERS);
                    }
                    break;
                case EDIT_BTN:
                    switch (getModule()) {
                        case RcnConstants.MODULE_SP:
                            return role.get(RcnConstants.MODIFY_SP_PARAMETERS);
                    }
                    break;
                case REMOVE_BTN:
                    switch (getModule()) {
                        case RcnConstants.MODULE_SP:
                            return role.get(RcnConstants.REMOVE_SP_PARAMETERS);
                    }
                    break;
            }
        }
        return false;
    }
}
