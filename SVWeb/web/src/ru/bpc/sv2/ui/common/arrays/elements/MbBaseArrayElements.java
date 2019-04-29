package ru.bpc.sv2.ui.common.arrays.elements;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.arrays.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

public abstract class MbBaseArrayElements extends AbstractBean {
    private static final Logger logger = Logger.getLogger("COMMON");

    private CommonDao _commonDao = new CommonDao();

    private BaseArrayElement filter;
    private DaoDataModel<BaseArrayElement> _elementSource;   //was final
    private TableRowSelection<BaseArrayElement> _itemSelection;    //was final
    private BaseArrayElement _activeElement;
    private BaseArrayElement newElement;

    private Array array;
    private String oldLang;

    private static String COMPONENT_ID = "elementsTable";
    private String tabName;
    private String parentSectionId;

    public abstract void setFilters(); //todo ??? need clarify....
    public abstract int getElementsCount(SelectionParams params);
    public abstract BaseArrayElement[] getElements(SelectionParams params);
    public abstract void deleteElement(BaseArrayElement activeElement);
    public abstract BaseArrayElement addElement(BaseArrayElement newElement);
    public abstract BaseArrayElement editElement(BaseArrayElement newElement);
    public abstract BaseArrayElement newFilter();
    public abstract BaseArrayElement createNewElement();
    public abstract String getAssociatedPageName();


    public MbBaseArrayElements() {

        set_elementSource(new DaoDataModel<BaseArrayElement>() {
            @Override
            protected BaseArrayElement[] loadDaoData(SelectionParams params) {
                if (getArray() == null || !searching) {
                    return new BaseArrayElement[0];
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return getElements(params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new BaseArrayElement[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (getArray() == null || !searching) {
                    return 0;
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return getElementsCount(params); //get_commonDao().getArrayElementsCount(userSessionId, params);
                } catch (Exception e) {
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return 0;
            }
        });

        set_itemSelection(new TableRowSelection<BaseArrayElement>(null, get_elementSource()));
    }

    public TableRowSelection<BaseArrayElement> get_itemSelection() {
        return _itemSelection;
    }

    public void set_itemSelection(TableRowSelection<BaseArrayElement> _itemSelection) {
        this._itemSelection = _itemSelection;
    }

    public CommonDao get_commonDao() {
        return _commonDao;
    }

    public void set_commonDao(CommonDao _commonDao) {
        this._commonDao = _commonDao;
    }

    public List<Filter> getFilters() {
        return filters;
    }

    public void setFilters(List<Filter> filters) {
        this.filters = filters;
    }

    public DaoDataModel<BaseArrayElement> get_elementSource() {
        return _elementSource;
    }

    public void set_elementSource(DaoDataModel<BaseArrayElement> _elementSource) {
        this._elementSource = _elementSource;
    }


    public DaoDataModel<BaseArrayElement> getSourceElements() {
        return _elementSource;
    }

    public BaseArrayElement getActiveElement() {
        return _activeElement;
    }

    public void setActiveElement(BaseArrayElement activeElement) {
        _activeElement = activeElement;
    }

    public SimpleSelection getItemSelection() {
        if (_activeElement == null && _elementSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (_activeElement != null && _elementSource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(_activeElement.getModelId());
            _itemSelection.setWrappedSelection(selection);
            _activeElement = _itemSelection.getSingleSelection();
        }
        return _itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        _activeElement = _itemSelection.getSingleSelection();
    }

    public void setFirstRowActive() {
        _elementSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        _activeElement = (BaseArrayElement) _elementSource.getRowData();
        selection.addKey(_activeElement.getModelId());
        _itemSelection.setWrappedSelection(selection);
    }

    public void search() {
        clearBean();
        setSearching(true);
    }

    public void clearFilter() {
        curLang = userLang;
        setFilter(null);
        searching = false;
        clearBean();
    }

    public void add() {
        newElement = createNewElement();
        newElement.setLang(userLang);
        newElement.setArrayId(array.getId());
        newElement.setLovId(array.getLovId());
        newElement.setDataType(array.getDataType());
        curMode = NEW_MODE;
    }

    public void edit() {
        try {
            newElement = (BaseArrayElement) _activeElement.clone();
        } catch (CloneNotSupportedException e) {
            logger.error("", e);
            newElement = _activeElement;
        }
        curMode = EDIT_MODE;
    }

    public void delete() {
        try {

            deleteElement(_activeElement);

            String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "array_element_deleted",
                    "(id = " + _activeElement.getId() + ")");

            _activeElement = _itemSelection.removeObjectFromList(_activeElement);
            if (_activeElement == null) {
                clearBean();
            }

            FacesUtils.addMessageInfo(msg);
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void save() {
        try {
            if (isNewMode()) {
                newElement = addElement(newElement);

                _itemSelection.addNewObjectToList(newElement);
            } else {
                newElement = editElement(newElement);


                _elementSource.replaceObject(_activeElement, newElement);
            }
            _activeElement = newElement;
            curMode = VIEW_MODE;

            FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
                    "array_element_saved"));

        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void close() {
        curMode = VIEW_MODE;
    }

    public void view() {
        curMode = VIEW_MODE;
    }



//    public BaseArrayElement getNewElement() {
//        if (newElement == null) {
//            newElement = newElement();
//        }
//        return newElement;
//    }

    public BaseArrayElement getNewElement() {
        if (newElement == null) {
            newElement = createNewElement();
        }
        return newElement;
    }


    public void setNewElement(BaseArrayElement newElement) {
        this.newElement = newElement;
    }

    public Array getArray() {
        return array;
    }

    public void setArray(Array array) {
        this.array = array;
    }

    public void clearBean() {
        _elementSource.flushCache();
        _itemSelection.clearSelection();
        _activeElement = null;
    }

    public void fullCleanBean() {
        clearBean();
        array = null;
    }




    public void changeLanguage(ValueChangeEvent event) {
        if (_activeElement != null) {
            curLang = (String) event.getNewValue();
            List<Filter> filtersList = new ArrayList<Filter>();

            Filter paramFilter = new Filter();
            paramFilter.setElement("id");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(_activeElement.getId().toString());
            filtersList.add(paramFilter);

            paramFilter = new Filter();
            paramFilter.setElement("lang");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(curLang);
            filtersList.add(paramFilter);

            filters = filtersList;
            SelectionParams params = new SelectionParams();
            params.setFilters(filters.toArray(new Filter[filters.size()]));
            try {
                BaseArrayElement[] arrayElements = getElements(params);
                if (arrayElements != null && arrayElements.length > 0) {
                    _activeElement = arrayElements[0];
                }
            } catch (Exception e) {
                FacesUtils.addMessageError(e);
                logger.error("", e);
            }
        }
    }

    public void editLanguage(ValueChangeEvent event) {
        oldLang = (String) event.getOldValue();
    }

    public void confirmEditLanguage() {
        Filter[] filters = new Filter[2];
        filters[0] = new Filter();
        filters[0].setElement("id");
        filters[0].setValue(newElement.getId());
        filters[1] = new Filter();
        filters[1].setElement("lang");
        filters[1].setValue(newElement.getLang());

        SelectionParams params = new SelectionParams();
        params.setFilters(filters);
        try {
            BaseArrayElement[] items = getElements(params);
            if (items != null && items.length > 0) {
                newElement.setName(items[0].getName());
                newElement.setDescription(items[0].getDescription());
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void cancelEditLanguage() {
        newElement.setLang(oldLang);
    }

    public List<SelectItem> getValuesFromLov() {
        return getDictUtils().getLov(newElement.getLovId());
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

    public BaseArrayElement getFilter() {
        if (filter == null) {
            filter = newFilter();
        }
        return filter;
    }

    public boolean getCanEditElements(){
        return getArray() != null && (getArray().getModifierId() == null);
    }


    public void setFilter(BaseArrayElement filter) {
        this.filter = filter;
    }


}
