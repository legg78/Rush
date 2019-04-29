package ru.bpc.sv2.ui.reconciliation;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReconciliationDao;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.reconciliation.RcnCondition;
import ru.bpc.sv2.reconciliation.RcnConstants;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbRcnConditions")
public class MbRcnConditions extends AbstractBean {
    private static final Logger logger = Logger.getLogger("OPER_PROCESSING");
    private static final String PAGE = "page";
    private static final String ADD_BTN = "addBtn";
    private static final String EDIT_BTN = "editBtn";
    private static final String REMOVE_BTN = "deleteBtn";
    private static final String PURPOSE_FIELD = "purpose";
    private static final String PROVIDER_FIELD = "provider";

    private RcnCondition filter;
    private RcnCondition newCondition;
    private List<SelectItem> institutions;
    private List<SelectItem> reconciliationTypes;
    private List<SelectItem> conditionTypes;

    private ReconciliationDao reconciliationDao = new ReconciliationDao();

    private String module;
    private final DaoDataListModel<RcnCondition> conditionsSource;
    private final TableRowSelection<RcnCondition> itemSelection;
    private RcnCondition activeCondition;

    public MbRcnConditions() {
        conditionsSource = new DaoDataListModel<RcnCondition>(logger) {
            @Override
            protected List<RcnCondition> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    params.setModule(getModule());
                    return reconciliationDao.getConditions(userSessionId, params);
                }
                return new ArrayList<RcnCondition>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    params.setModule(getModule());
                    return reconciliationDao.getConditionsCount(userSessionId, params);
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<RcnCondition>(null, conditionsSource);
    }

    public String getModule() {
        return module;
    }
    public void setModule(String module) {
        this.module = module;
    }

    public DaoDataListModel<RcnCondition> getConditions() {
        return conditionsSource;
    }

    public RcnCondition getActiveCondition() {
        return activeCondition;
    }
    public void setActiveCondition(RcnCondition activeCondition) {
        this.activeCondition = activeCondition;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (activeCondition == null && conditionsSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (activeCondition != null && conditionsSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(activeCondition.getModelId());
                itemSelection.setWrappedSelection(selection);
                activeCondition = itemSelection.getSingleSelection();
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
            activeCondition = itemSelection.getSingleSelection();
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void setFirstRowActive() throws CloneNotSupportedException {
        conditionsSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeCondition = (RcnCondition) conditionsSource.getRowData();
        selection.addKey(activeCondition.getModelId());
        itemSelection.setWrappedSelection(selection);
    }

    public void search() {
        clearBean();
        searching = true;
    }

    @Override
    public void clearFilter() {
        clearBean();
        curLang = userLang;
        filter = null;
        searching = false;
    }
    @Override
    public Logger getLogger() {
        return logger;
    }

    public void setFilters() {
        filter = getFilter();
        filters = new ArrayList<Filter>();

        filters.add(Filter.create("lang", curLang));
        if (filter.getId() != null) {
            filters.add(Filter.create("id", filter.getId()));
        }
        if (filter.getName() != null && !filter.getName().trim().isEmpty()) {
            filters.add(Filter.create("name", filter.getName().trim()));
        }
        if (filter.getInstId() != null && !filter.getInstId().equals(Institution.DEFAULT_INSTITUTION)) {
            filters.add(Filter.create("instId", filter.getInstId()));
        }
        if (filter.getReconType() != null && !filter.getReconType().trim().isEmpty()) {
            filters.add(Filter.create("reconType", filter.getReconType().trim()));
        } else {
            filters.add(Filter.create("reconTypes", getReconciliationTypesFilterValue()));
        }
        if (filter.getCondType() != null && !filter.getCondType().trim().isEmpty()) {
            filters.add(Filter.create("condType", filter.getCondType().trim()));
        }
        if (filter.getPurposeId() != null) {
            filters.add(Filter.create("purposeId", filter.getPurposeId()));
        }
        if (filter.getProviderId() != null) {
            filters.add(Filter.create("providerId", filter.getProviderId()));
        }
    }

    public void add() {
        newCondition = new RcnCondition();
        curMode = NEW_MODE;
    }

    public void edit() {
        try {
            newCondition = (RcnCondition) activeCondition.clone();
        } catch (CloneNotSupportedException e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
            newCondition = activeCondition;
        }
        curMode = EDIT_MODE;
    }

    public void delete() {
        try {
            activeCondition.setModule(getModule());
            reconciliationDao.removeCondition(userSessionId, activeCondition);
            activeCondition = itemSelection.removeObjectFromList(activeCondition);
            if (activeCondition == null) {
                clearBean();
            }
            FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rec", "rec_condition_deleted"));
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void save() {
        try {
            newCondition.setLang(curLang);
            newCondition.setModule(getModule());
            if (isNewMode()) {
                newCondition = reconciliationDao.addCondition(userSessionId, newCondition);
                itemSelection.addNewObjectToList(newCondition);
            } else {
                newCondition = reconciliationDao.modifyCondition(userSessionId, newCondition);
                conditionsSource.replaceObject(activeCondition, newCondition);
            }
            activeCondition = (RcnCondition) newCondition.clone();
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        cancel();
    }

    public void cancel() {
        curMode = VIEW_MODE;
        setNewCondition(null);
    }

    public RcnCondition getFilter() {
        if (filter == null) {
            filter = new RcnCondition();
            filter.setInstId(userInstId);
        }
        return filter;
    }
    public void setFilter(RcnCondition filter) {
        this.filter = filter;
    }

    public RcnCondition getNewCondition() {
        if (newCondition == null) {
            newCondition = new RcnCondition();
        }
        return newCondition;
    }
    public void setNewCondition(RcnCondition newCondition) {
        this.newCondition = newCondition;
    }

    public void clearBean() {
        conditionsSource.flushCache();
        itemSelection.clearSelection();
        activeCondition = null;
    }

    public void changeLanguage(ValueChangeEvent event) {
        if (activeCondition != null) {
            curLang = (String) event.getNewValue();
            activeCondition = getNodeByLang(activeCondition.getId(), curLang);
        }
    }

    public RcnCondition getNodeByLang(Long id, String lang) {
        List<Filter> filters = new ArrayList<Filter>();
        filters.add(Filter.create("id", id));
        filters.add(Filter.create("lang", lang));
        SelectionParams params = new SelectionParams(filters);
        try {
            List<RcnCondition> items = reconciliationDao.getConditions(userSessionId, params);
            if (items != null && items.size() > 0) {
                return items.get(0);
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return null;
    }

    public List<SelectItem> getInstitutions() {
        return getDictUtils().getLovUI(LovConstants.INSTITUTIONS_SYS, institutions);
    }

    public List<SelectItem> getReconciliationTypes() {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("type", getModule());
        return getDictUtils().getLovUI(LovConstants.RECONCILIATION_TYPES, params, reconciliationTypes);
    }

    public List<SelectItem> getConditionTypes() {
        return getDictUtils().getLovUI(LovConstants.RECONCILIATION_CONDITION_TYPES, conditionTypes);
    }

    public List<SelectItem> getPurposes() {
        Map<String, Object> params = new HashMap<String, Object>();
        if (getNewCondition().getProviderId() != null) {
            params.put("provider_id", getNewCondition().getProviderId());
        } else if (getFilter().getProviderId() != null) {
            params.put("provider_id", getFilter().getProviderId());
        }
        return getDictUtils().getLovUI(LovConstants.RECONCILIATION_PURPOSES, params);
    }

    public List<SelectItem> getProviders() {
        return getDictUtils().getLovUI(LovConstants.RECONCILIATION_PROVIDERS);
    }

    private String getReconciliationTypesFilterValue() {
        StringBuilder value = new StringBuilder();
        for (SelectItem type : getReconciliationTypes()) {
            if (value.length() == 0) {
                value.append("'");
            } else {
                value.append(", '");
            }
            value.append(type.getValue().toString());
            value.append("'");
        }
        return value.toString();
    }

    public boolean isRendered(String component) {
        if (StringUtils.isNotEmpty(component)) {
            Map<String, Boolean> role = ((UserSession) ManagedBeanWrapper.getManagedBean("usession")).getInRole();
            switch (component) {
                case PAGE:
                    switch (getModule()) {
                        case RcnConstants.MODULE_CBS:
                            return role.get(RcnConstants.VIEW_CBS_CONDITIONS);
                        case RcnConstants.MODULE_ATM:
                            return role.get(RcnConstants.VIEW_ATM_CONDITIONS);
                        case RcnConstants.MODULE_HOST:
                            return role.get(RcnConstants.VIEW_HOST_CONDITIONS);
                        case RcnConstants.MODULE_SP:
                            return role.get(RcnConstants.VIEW_SP_CONDITIONS);
                    }
                    break;
                case ADD_BTN:
                    switch (getModule()) {
                        case RcnConstants.MODULE_CBS:
                            return role.get(RcnConstants.ADD_CBS_CONDITIONS);
                        case RcnConstants.MODULE_ATM:
                            return role.get(RcnConstants.ADD_ATM_CONDITIONS);
                        case RcnConstants.MODULE_HOST:
                            return role.get(RcnConstants.ADD_HOST_CONDITIONS);
                        case RcnConstants.MODULE_SP:
                            return role.get(RcnConstants.ADD_SP_CONDITIONS);
                    }
                    break;
                case EDIT_BTN:
                    switch (getModule()) {
                        case RcnConstants.MODULE_CBS:
                            return role.get(RcnConstants.MODIFY_CBS_CONDITIONS);
                        case RcnConstants.MODULE_ATM:
                            return role.get(RcnConstants.MODIFY_ATM_CONDITIONS);
                        case RcnConstants.MODULE_HOST:
                            return role.get(RcnConstants.MODIFY_HOST_CONDITIONS);
                        case RcnConstants.MODULE_SP:
                            return role.get(RcnConstants.MODIFY_SP_CONDITIONS);
                    }
                    break;
                case REMOVE_BTN:
                    switch (getModule()) {
                        case RcnConstants.MODULE_CBS:
                            return role.get(RcnConstants.REMOVE_CBS_CONDITIONS);
                        case RcnConstants.MODULE_ATM:
                            return role.get(RcnConstants.REMOVE_ATM_CONDITIONS);
                        case RcnConstants.MODULE_HOST:
                            return role.get(RcnConstants.REMOVE_HOST_CONDITIONS);
                        case RcnConstants.MODULE_SP:
                            return role.get(RcnConstants.REMOVE_SP_CONDITIONS);
                    }
                    break;
                case PURPOSE_FIELD:
                    switch (getModule()) {
                        case RcnConstants.MODULE_SP:
                            return true;
                    }
                    break;
                case PROVIDER_FIELD:
                    switch (getModule()) {
                        case RcnConstants.MODULE_SP:
                            return true;
                    }
                    break;
            }
        }
        return false;
    }
}
