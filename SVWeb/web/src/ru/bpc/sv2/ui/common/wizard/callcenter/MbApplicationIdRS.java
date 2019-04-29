package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbApplicationIdRS")
public class MbApplicationIdRS extends AbstractWizardStep {
    protected static final Logger logger = Logger.getLogger("COMMON");
    private static final String PAGE = "/pages/common/wizard/callcenter/applicationIdRS.jspx";

    private String detailsSubPage;
    private Long appId;

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");
        super.init(context, PAGE);

        if (getContext().containsKey(WizardConstants.APPLICATION_ID)) {
            appId = (Long) context.get(WizardConstants.APPLICATION_ID);
        }
        if (getContext().containsKey(WizardConstants.DETAILS_SUB_PAGE)) {
            detailsSubPage = (String) context.get(WizardConstants.DETAILS_SUB_PAGE);
        }
        getContext().put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        return getContext();
    }

    @Override
    public boolean validate() {
        return false;
    }

    public String getDetailsSubPage() {
        return detailsSubPage;
    }

    public void setDetailsSubPage(String detailsSubPage) {
        this.detailsSubPage = detailsSubPage;
    }

    public Long getAppId() {
        return appId;
    }

    public void setAppId(Long appId) {
        this.appId = appId;
    }

}
