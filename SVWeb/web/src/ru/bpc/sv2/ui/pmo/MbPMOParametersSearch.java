package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.aup.Tag;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AuthProcessingDao;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoParameter;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

/**
 * Manage Bean for List PMO Parameters page.
 */
@ViewScoped
@ManagedBean (name = "MbPMOParametersSearch")
public class MbPMOParametersSearch extends AbstractBean {
    private static final long serialVersionUID = 4031545152332242977L;
    private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

    private static String COMPONENT_ID = "2182:mainTable";

    private PaymentOrdersDao paymentOrdersDao = new PaymentOrdersDao();
    private AuthProcessingDao aupDao = new AuthProcessingDao();

    private PmoParameter activeParameter;
    private PmoParameter newParameter;
    private PmoParameter detailParameter;

    private PmoParameter parameterFilter;
    private List<Filter> parameterFilters;

    private boolean selectMode;

    private final DaoDataModel<PmoParameter> parametersSource;
    private final TableRowSelection<PmoParameter> parameterSelection;

    private String tabName;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String needRerender;
    private List<String> rerenderList;
    private ArrayList<SelectItem> dataTypes;

    public MbPMOParametersSearch() {
        pageLink = "pmo|parameters";
        tabName = "detailsTab";

        parametersSource = new DaoDataListModel<PmoParameter>(logger) {
            private static final long serialVersionUID = 2278067784920717755L;

            @Override
            protected List<PmoParameter> loadDaoListData(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(parameterFilters);
                    return paymentOrdersDao.getParameters(userSessionId, params);
                }
                return new ArrayList<PmoParameter>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(parameterFilters.toArray(new Filter[parameterFilters.size()]));
                    return paymentOrdersDao.getParametersCount(userSessionId, params);
                }
                return 0;
            }
        };
        parameterSelection = new TableRowSelection<PmoParameter>(null, parametersSource);
    }

    public DaoDataModel<PmoParameter> getParameters() {
        return parametersSource;
    }

    public PmoParameter getActiveParameter() {
        return activeParameter;
    }

    public void setActiveParameter(PmoParameter activeParameter) {
        this.activeParameter = activeParameter;
    }

    public void setFirstRowActive() throws CloneNotSupportedException {
        parametersSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeParameter = (PmoParameter) parametersSource.getRowData();
        selection.addKey(activeParameter.getModelId());
        parameterSelection.setWrappedSelection(selection);
        if (activeParameter != null) {
            setInfo();
            detailParameter = (PmoParameter) activeParameter.clone();
        }
    }

    public void setInfo() {
        loadedTabs.clear();
        loadTab(getTabName());
    }

    public SimpleSelection getParameterSelection() {
        try {
            if (activeParameter == null && parametersSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (activeParameter != null && parametersSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(activeParameter.getModelId());
                parameterSelection.setWrappedSelection(selection);
                activeParameter = parameterSelection.getSingleSelection();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return parameterSelection.getWrappedSelection();
    }

    public void setParameterSelection(SimpleSelection selection) {
        try {
            parameterSelection.setWrappedSelection(selection);
            boolean changeSelect = false;
            if (parameterSelection.getSingleSelection() != null
                    && !parameterSelection.getSingleSelection().getId().equals(activeParameter.getId())) {
                changeSelect = true;
            }
            activeParameter = parameterSelection.getSingleSelection();
            if (activeParameter != null) {
                setInfo();
                if (changeSelect) {
                    detailParameter = (PmoParameter) activeParameter.clone();
                }
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void search() {
        clearBean();
        clearBeansStates();
        searching = true;
    }

    public void clearFilter() {
        parameterFilter = null;
        clearBean();
        clearBeansStates();
    }

    public void clearBeansStates() {
        MbPurposesHasParameter bean = (MbPurposesHasParameter) ManagedBeanWrapper
                .getManagedBean("MbPurposesHasParameter");
        bean.clearFilter();
//		bean.search();
    }

    public void clearBean() {
        searching = false;
        curLang = userLang;
        parametersSource.flushCache();
        if (parameterSelection != null) {
            parameterSelection.clearSelection();
        }
        activeParameter = null;
        detailParameter = null;
        loadedTabs.clear();
    }

    public void add() {
        newParameter = new PmoParameter();
        newParameter.setLang(userLang);
        curLang = newParameter.getLang();
        curMode = NEW_MODE;
    }

    public void edit() {
        try {
            newParameter = (PmoParameter) detailParameter.clone();
        } catch (CloneNotSupportedException e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
            newParameter = activeParameter;
        }
        curMode = EDIT_MODE;
    }

    public void save() {
        try {
            if (isEditMode()) {
                newParameter = paymentOrdersDao.editParameter(userSessionId, newParameter);
                detailParameter = (PmoParameter) newParameter.clone();
                if (!userLang.equals(newParameter.getLang())) {
                    newParameter = getNodeByLang(activeParameter.getId(), userLang);
                }
                parametersSource.replaceObject(activeParameter, newParameter);
            } else {
                newParameter = paymentOrdersDao.addParameter(userSessionId, newParameter);
                detailParameter = (PmoParameter) newParameter.clone();
                parameterSelection.addNewObjectToList(newParameter);
            }
            activeParameter = newParameter;
            setInfo();
            curMode = VIEW_MODE;
            FacesUtils.addMessageInfo("Saved!");
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);

        }
    }

    public void delete() {
        try {
            paymentOrdersDao.removeParameter(userSessionId, activeParameter);
            FacesUtils.addMessageInfo("Parameter (id = " + activeParameter.getId() + ") has been deleted.");
            activeParameter = parameterSelection.removeObjectFromList(activeParameter);
            if (activeParameter == null) {
                clearBean();
            } else {
                setInfo();
                detailParameter = (PmoParameter) activeParameter.clone();
            }
            curMode = VIEW_MODE;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void cancel() {

    }

    public void setFilters() {
        parameterFilters = new ArrayList<Filter>();
        parameterFilters.add(Filter.create("lang", userLang));
        if (getParameterFilter().getId() != null) {
            parameterFilters.add(Filter.create("id", getParameterFilter().getId()));
        }
        if (getParameterFilter().getSystemName() != null && !getParameterFilter().getSystemName().equals("")) {
            parameterFilters.add(Filter.create("paramName", getParameterFilter().getSystemName()));
        }
        if (getParameterFilter().getName() != null && !getParameterFilter().getName().equals("")) {
            parameterFilters.add(Filter.create("label", Operator.like, Filter.mask(getParameterFilter().getName(), true)));
        }
        if (getParameterFilter().getDataType() != null && !getParameterFilter().getDataType().equals("")) {
            parameterFilters.add(Filter.create("dataType", getParameterFilter().getDataType()));
        }
    }

    public PmoParameter getParameterFilter() {
        if (parameterFilter == null) {
            parameterFilter = new PmoParameter();
        }
        return parameterFilter;
    }

    public void setParameterFilter(PmoParameter parameterFilter) {
        this.parameterFilter = parameterFilter;
    }

    public List<Filter> getParameterFilters() {
        return parameterFilters;
    }

    public void setParameterFilters(List<Filter> parameterFilters) {
        this.parameterFilters = parameterFilters;
    }

    public boolean isSelectMode() {
        return selectMode;
    }

    public void setSelectMode(boolean selectMode) {
        this.selectMode = selectMode;
    }

    public PmoParameter getNewParameter() {
        if (newParameter == null) {
            newParameter = new PmoParameter();
        }
        return newParameter;
    }

    public void setNewParameter(PmoParameter newParameter) {
        this.newParameter = newParameter;
    }

    public void changeLanguage(ValueChangeEvent event) {
        curLang = (String) event.getNewValue();
        detailParameter = getNodeByLang(detailParameter.getId(), curLang);
    }

    public PmoParameter getNodeByLang(Integer id, String lang) {
        List<Filter> filters = new ArrayList<Filter>(2);
        filters.add(Filter.create("id", id.toString()));
        filters.add(Filter.create("lang", lang));
        SelectionParams params = new SelectionParams(filters);

        try {
            List<PmoParameter> parameters = paymentOrdersDao.getParameters(userSessionId, params);
            if (parameters != null && parameters.size() > 0) {
                return parameters.get(0);
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return null;
    }

    public void confirmEditLanguage() {
        curLang = newParameter.getLang();
        PmoParameter tmp = getNodeByLang(newParameter.getId(), newParameter.getLang());
        if (tmp != null) {
            newParameter.setName(tmp.getName());
            newParameter.setDescription(tmp.getDescription());
        }
    }

    public ArrayList<SelectItem> getDataTypes() {
        if (dataTypes == null) {
            dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
        }
        return dataTypes;
    }

    public ArrayList<SelectItem> getParamFunctions() {
        if (dataTypes == null) {
            dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
        }
        return dataTypes;
    }

    public List<SelectItem> getLovs() {
        if (StringUtils.isNotEmpty(getNewParameter().getDataType())) {
            Map<String, Object> params = new HashMap<String, Object>(1);
            params.put("DATA_TYPE", getNewParameter().getDataType());
            return getDictUtils().getLov(LovConstants.LOVS_LOV, params);
        }
        return new ArrayList<SelectItem>(0);
    }

    public String getTabName() {
        return tabName;
    }

    public void setTabName(String tabName) {
        needRerender = null;
        this.tabName = tabName;

        Boolean isLoadedCurrentTab = loadedTabs.get(tabName);
        if (isLoadedCurrentTab == null) {
            isLoadedCurrentTab = Boolean.FALSE;
        }
        if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
            return;
        }

        loadTab(tabName);
        if (tabName.equalsIgnoreCase("valuesTab")) {
            MbPurposesHasParameter bean1 = ManagedBeanWrapper.getManagedBean(MbPurposesHasParameter.class);
            bean1.setTabName(tabName);
            bean1.setParentSectionId(getSectionId());
            bean1.setTableState(getSateFromDB(bean1.getComponentId()));

            MbPMOParameterValues bean2 = ManagedBeanWrapper.getManagedBean(MbPMOParameterValues.class);
            bean2.setTabName(tabName);
            bean2.setParentSectionId(getSectionId());
            bean2.setTableState(getSateFromDB(bean2.getComponentId()));
        }
    }

    public String getSectionId() {
        return SectionIdConstants.PAYMENT_ORDER_PARAMETER;
    }

    public void loadCurrentTab() {
        loadTab(tabName);
    }

    private void loadTab(String tab) {
        if (tab == null || getActiveParameter() == null || getActiveParameter().getId() == null) {
            return;
        }
        if (tab.toUpperCase().equals("VALUESTAB")) {
            MbPurposesHasParameter valueBean = ManagedBeanWrapper.getManagedBean(MbPurposesHasParameter.class);
            valueBean.clearFilter();
            valueBean.getFilter().setParamId(getActiveParameter().getId());
            valueBean.search();
        }
        needRerender = tab;
        loadedTabs.put(tab, Boolean.TRUE);
    }

    public HashMap<String, Boolean> getLoadedTabs() {
        return loadedTabs;
    }

    public List<String> getRerenderList() {
        rerenderList = new ArrayList<String>();
        rerenderList.clear();
        if (needRerender != null) {
            rerenderList.add(needRerender);
        }
        rerenderList.add("err_ajax");
        return rerenderList;
    }

    public String getComponentId() {
        return COMPONENT_ID;
    }

    public Logger getLogger() {
        return logger;
    }

    public List<SelectItem> getAupTags() {
        if (isEditMode() || isNewMode()) {
            Filter[] filters = new Filter[1];
            filters[0] = new Filter();
            filters[0].setElement("lang");
            filters[0].setValue(userLang);

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            params.setRowIndexEnd(Integer.MAX_VALUE);

            try {
                Tag[] tags = aupDao.getTags(userSessionId, params);
                List<SelectItem> items = new ArrayList<SelectItem>(tags.length);

                for (Tag tag : tags) {
                    items.add(new SelectItem(tag.getId(), tag.getName()));
                }
                return items;
            } catch (Exception e) {
                logger.error("", e);
                if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
                    FacesUtils.addMessageError(e);
                }
            }
        }
        return new ArrayList<SelectItem>(0);
    }

    public PmoParameter getDetailParameter() {
        return detailParameter;
    }

    public void setDetailParameter(PmoParameter detailParameter) {
        this.detailParameter = detailParameter;
    }

    @Override
    protected void applySectionFilter(Integer filterId) {
        try {
            FilterFactory factory = (FilterFactory) ManagedBeanWrapper
                    .getManagedBean("filterFactory");
            Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
            sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
            if (filterRec != null) {
                parameterFilter = new PmoParameter();
                if (filterRec.get("id") != null) {
                    parameterFilter.setId(Integer.parseInt(filterRec.get("id")));
                }
                if (filterRec.get("systemName") != null) {
                    parameterFilter.setSystemName(filterRec.get("systemName"));
                }
                if (filterRec.get("name") != null) {
                    parameterFilter.setName(filterRec.get("name"));
                }
                if (filterRec.get("dataType") != null) {
                    parameterFilter.setDataType(filterRec.get("dataType"));
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
            FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");

            Map<String, String> filterRec = new HashMap<String, String>();
            parameterFilter = getParameterFilter();
            if (parameterFilter.getId() != null) {
                filterRec.put("id", parameterFilter.getId().toString());
            }
            if (parameterFilter.getSystemName() != null) {
                filterRec.put("systemName", parameterFilter.getSystemName());
            }
            if (parameterFilter.getName() != null) {
                filterRec.put("name", parameterFilter.getName());
            }
            if (parameterFilter.getDataType() != null) {
                filterRec.put("dataType", parameterFilter.getDataType());
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
}
