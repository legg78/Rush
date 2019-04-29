package ru.bpc.sv2.ui.issuing;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.issuing.Card;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbCardSearchModal")
public class MbCardSearchModal extends MbCardsSearch {
    private static final long serialVersionUID = 1L;
    private String beanName;
    private String methodName;
    private String rerenderList;
    private String module = ModuleNames.CASE_MANAGEMENT;

    public MbCardSearchModal() {
        super();
    }

    public String getBeanName() {
        if (beanName == null || beanName.equals("")) {
            return "MbAppWizDspNew";
        }
        return beanName;
    }
    public void setBeanName(String beanName) {
        this.beanName = beanName;
    }

    public String getMethodName() {
        if (methodName == null || methodName.equals("")) {
            return "selectCard";
        }
        return methodName;
    }
    public void setMethodName(String methodName) {
        this.methodName = methodName;
    }

    public String getRenderList() {
        return rerenderList;
    }
    public void setRenderList(String rerenderList) {
        this.rerenderList = rerenderList;
    }

    public List<SelectItem> getAgents() {
        Map<String, Object> paramMap = new HashMap<String, Object>();
        if (getFilter().getInstId() != null) {
            paramMap.put("INSTITUTION_ID", getFilter().getInstId());
        }
        return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
    }

    @Override
    public String getModule() {
        return module;
    }
    @Override
    public void setModule(String module) {
        this.module = module;
    }
    @Override
    public void clearFilter() {
        sectionFilterModeEdit = true;
        sectionFilter = null;
        selectedSectionFilter = null;

        getFilter().setInstId(null);
        getFilter().setAgentId(null);
        getFilter().setCardTypeId(null);
        getFilter().setCardNumber(null);
        getFilter().setExpDate(null);
        getFilter().setCardholderNumber(null);
        getFilter().setProductNumber(null);

        clearState();
        searching = false;
    }
}
