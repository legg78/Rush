package ru.bpc.sv2.ui.atm;

import org.ajax4jsf.model.KeepAlive;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.atm.MonitoredAtm;
import ru.bpc.sv2.common.arrays.Array;
import ru.bpc.sv2.common.arrays.ArrayElement;
import ru.bpc.sv2.common.arrays.AtmGroup;
import ru.bpc.sv2.constants.ArrayConstants;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;


@RequestScoped
@KeepAlive
@ManagedBean(name = "MbAtmGroups")
public class MbAtmGroups extends AbstractBean {
    private static final Logger logger = Logger.getLogger("ATM");

    private CommonDao commonDao = new CommonDao();

    MonitoredAtm atm;

    //private AtmGroup filter;


    private AtmGroup activeItem;
    private AtmGroup newAtmGroup;

    private final DaoDataModel<AtmGroup> dataModel;
    private final TableRowSelection<AtmGroup> tableRowSelection;

    private static String COMPONENT_ID = "atmGroupsTable";
    private String tabName;
    private String parentSectionId;

    public MbAtmGroups() {

        dataModel = new DaoDataModel<AtmGroup>(){
            @Override
            protected AtmGroup[] loadDaoData(SelectionParams params) {
                AtmGroup[] result = null;
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    try{
                        result = commonDao.getAtmGroups(userSessionId, params);
                    }catch (DataAccessException e){
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                } else {
                    result = new AtmGroup[0];
                }
                return result;
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                int result = 0;
                if (searching){
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    try{
                        result = commonDao.getAtmGroupsCount(userSessionId, params);
                    }catch (DataAccessException e){
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                } else {
                    result = 0;
                }
                return result;
            }
        };
        tableRowSelection = new TableRowSelection<AtmGroup>(null, dataModel);
    }

    private void setFilters() {



        filters = new ArrayList<Filter>();
        Filter paramFilter;
        paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setOp(Filter.Operator.eq);
        paramFilter.setValue(userLang);
        filters.add(paramFilter);

        paramFilter = new Filter();
        paramFilter.setElement("arrayTypeId");
        paramFilter.setOp(Filter.Operator.eq);
        paramFilter.setValue("1007"); // todo must be changed to constant
        filters.add(paramFilter);


        if (getAtm() != null && getAtm().getId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("atmId");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(getAtm().getId());
            filters.add(paramFilter);
        }
    }

    public void search() {
        clearBean();
        setSearching(true);
    }

    public void clearFilter() {
        curLang = userLang;
        //setFilter(null);
        setAtm(null);
        searching = false;
        clearBean();
    }

    public void clearBean() {
        dataModel.flushCache();
        tableRowSelection.clearSelection();
        activeItem = null;
    }

    public void setFirstRowActive() {
        dataModel.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (AtmGroup) dataModel.getRowData();
        selection.addKey(activeItem.getModelId());
        tableRowSelection.setWrappedSelection(selection);
    }

    public void setItemSelection(SimpleSelection selection) {
        tableRowSelection.setWrappedSelection(selection);
        activeItem = tableRowSelection.getSingleSelection();
    }

    public SimpleSelection getItemSelection() {
        try {
            if (activeItem == null && dataModel.getRowCount() > 0) {
                setFirstRowActive();
            } else if (activeItem != null && dataModel.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(activeItem.getModelId());
                tableRowSelection.setWrappedSelection(selection);
                activeItem = tableRowSelection.getSingleSelection();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return tableRowSelection.getWrappedSelection();
    }

//    public AtmGroup getFilter() {
//        if (filter == null) {
//            filter = new AtmGroup();
//        }
//        return filter;
//    }

    public DaoDataModel<AtmGroup> getDataModel(){
        return dataModel;
    }

    public AtmGroup getActiveItem(){
        return activeItem;
    }

    public List<SelectItem> getRespCodes(){
        List<SelectItem> result = getDictUtils().getArticles(DictNames.RESPONSE_CODE, true, true);
        return result;
    }

    public void updateData(){
        dataModel.flushCache();
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

    public MonitoredAtm getAtm() {
        return atm;
    }

    public void setAtm(MonitoredAtm atm) {
        this.atm = atm;
    }

//    public void setFilter(AtmGroup filter) {
//        this.filter = filter;
//    }

    public AtmGroup getNewAtmGroup() {
        if (newAtmGroup == null) {
            newAtmGroup = new AtmGroup();
        }
        return newAtmGroup;
    }

    public void setNewAtmGroup(AtmGroup newAtmGroup) {
        this.newAtmGroup = newAtmGroup;
    }

    public boolean getCanDeleteGroup(){
        return getActiveItem() != null && (getActiveItem().getModifierId() == null);
    }

    public void add() {

    }


    public void delete() {
        try {

            commonDao.removeAtmFromGroup(userSessionId, activeItem);
            String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "array_element_deleted",
                    "(id = " + activeItem.getElementId() + ")");

            activeItem = tableRowSelection.removeObjectFromList(activeItem);
            if (activeItem == null) {
                clearBean();
            }

            FacesUtils.addMessageInfo(msg);
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public List<SelectItem> getGroups() {
        if (getAtm() == null || getAtm().getInstId() == null) {
            return new ArrayList<SelectItem>();
        }

        Map<String, Object> paramMap = new HashMap<String, Object>();
        paramMap.put("INSTITUTION_ID", getAtm().getInstId());
        paramMap.put("ARRAY_TYPE_ID", ArrayConstants.ATM_GROUP);
        return getDictUtils().getLov(LovConstants.ARRAY_LIST, paramMap);
    }


    public void cancel() {

    }


    public void save() {
        try {

            Filter[] filters = new Filter[2];
            filters[0] = new Filter();
            filters[0].setElement("lang");
            filters[0].setValue(curLang);
            filters[1] = new Filter();
            filters[1].setElement("id");
            filters[1].setValue(newAtmGroup.getId());
            SelectionParams params = new SelectionParams();
            params.setFilters(filters);

            Array[] arrays = commonDao.getArrays(userSessionId, params);

            if(arrays == null || arrays.length < 1)
                throw new Exception("Atm group with id=" + newAtmGroup.getId() + " is not found.");

            ArrayElement arrayElement = new ArrayElement();
            arrayElement.setArrayId(newAtmGroup.getId());           // id from add form
            arrayElement.setDataType(arrays[0].getDataType());      // type from selected group
            arrayElement.setValueN(getAtm().getId());               // for atm group array use ValueN
            arrayElement.setElementNumber(0);                       // element number by default 0
            arrayElement.setLang(curLang);                          // language - current language
            arrayElement.setName(null);                             // element name is description from array
            arrayElement.setDescription(null);


            newAtmGroup = commonDao.addAtmToGroup(userSessionId, arrayElement);
            tableRowSelection.addNewObjectToList(newAtmGroup);
            activeItem = newAtmGroup;

            FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "array_element_saved"));
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }



}
