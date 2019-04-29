package ru.bpc.sv2.ui.accounts;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbAccountsAllSearchSelect")
public class MbAccountsAllSearchSelect extends MbAccountsAllSearch {
    private static String COMPONENT_ID = "issComSelectAccount";

    public MbAccountsAllSearchSelect() {
        super();
    }

    public String getComponentId() {
        return COMPONENT_ID;
    }
}
