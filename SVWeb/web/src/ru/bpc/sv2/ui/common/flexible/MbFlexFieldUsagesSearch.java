package ru.bpc.sv2.ui.common.flexible;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.FlexFieldUsage;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractSearchAllBean;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbFlexFieldUsagesSearch")
public class MbFlexFieldUsagesSearch extends AbstractSearchAllBean<FlexFieldUsage, FlexFieldUsage> {
    private static final Logger logger = Logger.getLogger("COMMON");

    private FlexFieldUsage newItem;

    private Integer fieldId;

    private CommonDao commonDao = new CommonDao();

    @Override
    protected FlexFieldUsage createFilter() {
        return new FlexFieldUsage();
    }

    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    protected FlexFieldUsage addItem(FlexFieldUsage item) {
        return null;
    }

    @Override
    protected FlexFieldUsage editItem(FlexFieldUsage item) {
        return null;
    }

    @Override
    protected void deleteItem(FlexFieldUsage item) {

    }

    @Override
    protected void initFilters(FlexFieldUsage filter, List<Filter> filters) {
        filters.add(Filter.create("lang", getCurLang()));
        if (filter.getId() != null) {
            filters.add(Filter.create("id", filter.getId()));
        }
        if (filter.getFieldId() != null) {
            filters.add(Filter.create("fieldId", filter.getFieldId()));
        }
    }

    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        return commonDao.getFlexFieldUsageCount(userSessionId, params);
    }

    @Override
    protected List<FlexFieldUsage> getObjectList(Long userSessionId, SelectionParams params) {
        return commonDao.getFlexFieldUsages(userSessionId, params);
    }

    private void setBeans() {

    }

    @Override
    public void clearFilter() {
        super.clearFilter();
        newItem = null;
        fieldId = null;
    }

    @Override
    public void clearState() {
        super.clearState();
    }


    public void add() {
        if (fieldId == null) return;
        curMode = NEW_MODE;
        newItem = new FlexFieldUsage();
        newItem.setFieldId(fieldId);
    }

    public void edit() {
        curMode = EDIT_MODE;
        try {
            newItem = activeItem.clone();
        } catch (CloneNotSupportedException e) {
            logger.error("", e);
            newItem = activeItem;
        }
    }

    public void delete() {
        try {
            commonDao.deleteFlexFieldUsage(userSessionId, activeItem);
            activeItem = tableRowSelection.removeObjectFromList(activeItem);

            if (activeItem == null) {
                clearState();
            } else {
                setBeans();
            }
            curMode = VIEW_MODE;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void save() {
        try {
            if (isEditMode()) {
                newItem = commonDao.updateFlexFieldUsage(userSessionId, newItem);
                dataModel.replaceObject(activeItem, newItem);
            } else if (isNewMode()) {
                newItem = commonDao.createFlexFieldUsage(userSessionId, newItem);
                tableRowSelection.addNewObjectToList(newItem);
            }

            activeItem = newItem;
            curMode = VIEW_MODE;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public Integer getFieldId() {
        return fieldId;
    }

    public void setFieldId(Integer fieldId) {
        this.fieldId = fieldId;
    }

    public FlexFieldUsage getNewItem() {
        return newItem;
    }

    public void setNewItem(FlexFieldUsage newItem) {
        this.newItem = newItem;
    }
}
