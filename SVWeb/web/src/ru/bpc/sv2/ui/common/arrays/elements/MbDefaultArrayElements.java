package ru.bpc.sv2.ui.common.arrays.elements;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.common.arrays.BaseArrayElement;
import ru.bpc.sv2.common.arrays.DefaultArrayElement;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import java.util.ArrayList;


@RequestScoped
@KeepAlive
@ManagedBean(name = "MbDefaultArrayElements")
public class MbDefaultArrayElements extends MbBaseArrayElements {

    public String getAssociatedPageName(){
        return "list_default_array_elements";
    }

    @Override
    public BaseArrayElement newFilter() {
        return new DefaultArrayElement();
    }

 //   @Override
//    public DefaultArrayElement newElement(){
//        return new DefaultArrayElement();
//    }

    public DefaultArrayElement getActiveElement() {
        return (DefaultArrayElement) super.getActiveElement();
    }


    @Override
    public DefaultArrayElement createNewElement(){
        return new DefaultArrayElement();
    }

    @Override
    public void deleteElement(BaseArrayElement activeElement){
        get_commonDao().deleteDefaultArrayElement(userSessionId, (DefaultArrayElement)activeElement);
    }

    @Override
    public DefaultArrayElement addElement(BaseArrayElement newElement){
        return get_commonDao().addDefaultArrayElement(userSessionId, (DefaultArrayElement)newElement);
    }

    @Override
    public DefaultArrayElement editElement(BaseArrayElement newElement){
        return get_commonDao().editDefaultArrayElement(userSessionId, (DefaultArrayElement)newElement);
    }

    @Override
    public DefaultArrayElement[] getElements(SelectionParams params){
        return get_commonDao().getDefaultArrayElements(userSessionId, params);
    }

    @Override
    public int getElementsCount(SelectionParams params){
        return get_commonDao().getDefaultArrayElementsCount(userSessionId, params);
    }

    @Override
    public DefaultArrayElement getFilter() {
        return (DefaultArrayElement)super.getFilter();
    }


    public void setFilters() {

        DefaultArrayElement filter = (DefaultArrayElement)getFilter();

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
        if (filter.getId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("id");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(filter.getId().toString());
            filters.add(paramFilter);
        }

        if (filter.getElementNumber() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("elementNumber");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(filter.getElementNumber().toString());
            filters.add(paramFilter);
        }
        if (filter.getName() != null && filter.getName().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("name");
            paramFilter.setOp(Filter.Operator.like);
            paramFilter.setValue(filter.getName().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }
        if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("description");
            paramFilter.setOp(Filter.Operator.like);
            paramFilter.setValue(filter.getDescription().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }
    }

}

