package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

/**
 * Created by Gasanov on 10.08.2015.
 */

@ViewScoped
@ManagedBean(name = "MbFeeCollectionRS")
public class MbFeeCollectionRS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbFeeCollectionRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/cardFeeCollectionRS.jspx";

    private Map<String, Object> context;

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");
        this.context = context;
        context.put(MbCommonWizard.PAGE, PAGE);
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        return context;
    }

    @Override
    public boolean validate() {
        return false;
    }
}
