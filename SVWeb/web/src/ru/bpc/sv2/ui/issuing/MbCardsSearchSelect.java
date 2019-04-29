package ru.bpc.sv2.ui.issuing;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbCardsSearchSelect")
public class MbCardsSearchSelect extends MbCardsSearch{

    private static String COMPONENT_ID = "issComSelectCard";

    public MbCardsSearchSelect() {
        super();
    }

    public String getComponentId() {
        return COMPONENT_ID;
    }
}
