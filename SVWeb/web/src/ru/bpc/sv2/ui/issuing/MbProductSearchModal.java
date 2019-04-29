package ru.bpc.sv2.ui.issuing;

import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.ui.products.MbProducts;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean (name = "MbProductSearchModal")
public class MbProductSearchModal extends MbProducts {
    private static final long serialVersionUID = 1L;
    private String beanName;
    private String methodName;
    private String rerenderList;

    public MbProductSearchModal() {
        super();
    }

    public String getBeanName() {
        return beanName;
    }
    public void setBeanName(String beanName) {
        this.beanName = beanName;
    }

    public String getMethodName() {
        if (methodName == null || methodName.equals("")) {
            return "selectProduct";
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
}
