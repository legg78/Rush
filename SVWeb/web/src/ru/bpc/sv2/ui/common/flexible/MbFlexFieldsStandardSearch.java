package ru.bpc.sv2.ui.common.flexible;

import org.ajax4jsf.model.KeepAlive;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.FlexField;
import ru.bpc.sv2.common.FlexStandardField;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbFlexFieldsStandardSearch")
public class MbFlexFieldsStandardSearch extends AbstractBean {
    private static final Logger logger = Logger.getLogger("COMMON");

    private boolean hideButtons = true;
    private FlexStandardField filter;
    private FlexStandardField editFlexField;
    private FlexStandardField activeFlexField;

    private final DaoDataModel<FlexStandardField> dataSource;
    private final TableRowSelection<FlexStandardField> itemSelection;

    private CommonDao commonDao = new CommonDao();

    public MbFlexFieldsStandardSearch() {
        dataSource = new DaoDataListModel<FlexStandardField>(logger) {
            @Override
            protected List<FlexStandardField> loadDaoListData(SelectionParams params) {
                if (searching && StringUtils.isNotBlank(getFilter().getEntityType())) {
                    setFilters();
                    params.setFilters(filters);
                    return commonDao.getFlexStandardFields(userSessionId, params);
                }
                return new ArrayList<FlexStandardField>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching && StringUtils.isNotBlank(getFilter().getEntityType())) {
                    setFilters();
                    params.setFilters(filters);
                    return commonDao.getFlexStandardFieldsCount(userSessionId, params);
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<FlexStandardField>(null, dataSource);
    }

    public DaoDataModel<FlexStandardField> getItems() {
        return dataSource;
    }

    public FlexStandardField getFilter() {
        if (filter == null) {
            filter = new FlexStandardField();
        }
        return filter;
    }
    public void setFilter(FlexStandardField filter) {
        this.filter = filter;
    }

    public FlexStandardField getActiveFlexField() {
        return activeFlexField;
    }
    public void setActiveFlexField(FlexStandardField activeFlexField) {
        this.activeFlexField = activeFlexField;
    }

    public FlexStandardField getEditFlexField() {
        return editFlexField;
    }
    public void setEditFlexField(FlexStandardField editFlexField) {
        this.editFlexField = editFlexField;
    }

    public SimpleSelection getItemSelection() {
        if (activeFlexField == null && dataSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (activeFlexField != null && dataSource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(activeFlexField.getModelId());
            itemSelection.setWrappedSelection(selection);
            activeFlexField = itemSelection.getSingleSelection();
        }
        return itemSelection.getWrappedSelection();
    }
    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activeFlexField = itemSelection.getSingleSelection();
    }

    public void setFirstRowActive() {
        dataSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeFlexField = (FlexStandardField) dataSource.getRowData();
        selection.addKey(activeFlexField.getModelId());
        itemSelection.setWrappedSelection(selection);
    }

    public boolean isHideButtons() {
        return hideButtons;
    }
    public void setHideButtons(boolean hideButtons) {
        this.hideButtons = hideButtons;
    }

    public boolean isStandardMode() {
        return EntityNames.FLEXIBLE_FIELD.equals(getFilter().getEntityType());
    }
    public boolean isFieldMode() {
        return EntityNames.STANDARD.equals(getFilter().getEntityType());
    }

    public void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));

        if (getFilter().getId() != null) {
            filters.add(Filter.create("id", getFilter().getId()));
        }
        if (getFilter().getStandardId() != null) {
            filters.add(Filter.create("standardId", getFilter().getStandardId()));
        }
        if (getFilter().getFieldId() != null) {
            filters.add(Filter.create("fieldId", getFilter().getFieldId()));
        }
        if (getFilter().getInstId() != null) {
            filters.add(Filter.create("instId", getFilter().getInstId()));
        }
        if (StringUtils.isNotBlank(getFilter().getEntityType())) {
            filters.add(Filter.create("entityType", getFilter().getEntityType().trim()));
        }
        if (StringUtils.isNotBlank(getFilter().getDataType())) {
            filters.add(Filter.create("dataType", getFilter().getDataType().trim()));
        }
        if (StringUtils.isNotBlank(getFilter().getSystemName())) {
            filters.add(Filter.create("systemName", Filter.mask(getFilter().getSystemName())));
        }
        if (StringUtils.isNotBlank(getFilter().getName())) {
            filters.add(Filter.create("name", Filter.mask(getFilter().getName())));
        }
    }

    public void add() {
        editFlexField = new FlexStandardField();
        editFlexField.setLang(userLang);
        editFlexField.setStandardId(getFilter().getStandardId());
        curMode = NEW_MODE;
    }

    public void edit() {
        try {
            editFlexField = activeFlexField.clone();
        } catch (Exception e) {

        }
        curMode = EDIT_MODE;
    }

    public void remove() {
        editFlexField = activeFlexField;
        curMode = REMOVE_MODE;
    }

    public void save() {
        try {
            switch (curMode) {
                case NEW_MODE:
                    activeFlexField = commonDao.addFlexStandardField(userSessionId, editFlexField);
                    itemSelection.addNewObjectToList(activeFlexField);
                    break;
                case EDIT_MODE:
                    editFlexField = commonDao.modifyFlexStandardField(userSessionId, editFlexField);
                    dataSource.replaceObject(activeFlexField, editFlexField);
                    break;
                case REMOVE_MODE:
                    commonDao.removeFlexStandardField(userSessionId, editFlexField);
                    itemSelection.removeObjectFromList(editFlexField);
                    activeFlexField = null;
                    if (dataSource.getRowCount() > 0) {
                        setFirstRowActive();
                    }
                    break;
            }
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            FacesUtils.addMessageError(e);
        }
        curMode = VIEW_MODE;
    }

    public void cancel() {
        editFlexField = null;
        curMode = VIEW_MODE;
    }

    public List<SelectItem> getFlexFields() {
        List<SelectItem> out = new ArrayList<SelectItem>();
        for (FlexField field : commonDao.getFlexFieldItems(userSessionId, userLang)) {
            out.add(new SelectItem(field.getId(), field.getSystemName() + " - " + field.getName(), field.getSystemName()));
        }
        return out;
    }

    public void clearBean() {
        editFlexField = null;
        activeFlexField = null;
        itemSelection.clearSelection();
        dataSource.flushCache();
    }

    public void search() {
        clearBean();
        searching = true;
    }

    @Override
    public void clearFilter() {
        filter = null;
        searching = false;
        clearBean();
    }
}
