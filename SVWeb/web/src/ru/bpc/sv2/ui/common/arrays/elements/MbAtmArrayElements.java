package ru.bpc.sv2.ui.common.arrays.elements;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.common.arrays.AtmArrayElement;
import ru.bpc.sv2.common.arrays.BaseArrayElement;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;

import java.util.ArrayList;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAtmArrayElements")
public class MbAtmArrayElements extends MbBaseArrayElements {

    public String getAssociatedPageName(){
        return "list_atm_array_elements";
    }


    @Override
    public BaseArrayElement newFilter() {
        return new AtmArrayElement();
    }

//    @Override
//    public AtmArrayElement newElement(){
//        return new AtmArrayElement();
//    }

    public AtmArrayElement createNewElement(){
        return new AtmArrayElement();
    }



    @Override
    public void deleteElement(BaseArrayElement activeElement){
        get_commonDao().deleteAtmArrayElement(userSessionId, (AtmArrayElement) activeElement);
    }

    @Override
    public AtmArrayElement addElement(BaseArrayElement newElement){
        return get_commonDao().addAtmArrayElement(userSessionId, (AtmArrayElement) newElement);
    }

    @Override
    public AtmArrayElement editElement(BaseArrayElement newElement){
        return get_commonDao().editAtmArrayElement(userSessionId, (AtmArrayElement) newElement);
    }

    @Override
    public AtmArrayElement[] getElements(SelectionParams params){
        return get_commonDao().getAtmArrayElements(userSessionId, params);
    }

    @Override
    public int getElementsCount(SelectionParams params){
        return get_commonDao().getAtmArrayElementsCount(userSessionId, params);
    }

    public void setFilters() {
        //AtmArrayElement filter = (AtmArrayElement)getFilter();
        filters = new ArrayList<Filter>();

        filters = new ArrayList<Filter>();

        Filter paramFilter;
        paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setOp(Filter.Operator.eq);
        paramFilter.setValue(userLang);
        filters.add(paramFilter);

        if (getArray().getId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("arrayId");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(getArray().getId());
            filters.add(paramFilter);
        }

        /*
        if you need to define filter make it here...


         */
    }


}

