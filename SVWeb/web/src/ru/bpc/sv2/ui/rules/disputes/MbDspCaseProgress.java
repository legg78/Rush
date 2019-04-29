package ru.bpc.sv2.ui.rules.disputes;

import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.ui.rules.MbDspApplications;
import ru.bpc.sv2.ui.utils.AbstractBean;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbDspCaseProgress")
public class MbDspCaseProgress extends AbstractBean {
    public static final String BTN_CASE_PROGRESS = "BTN_CASE_PROGRESS";
    public static final String BTN_REASON_CODE = "BTN_REASON_CODE";

    private List<DspApplication> applications;
    private DspApplication application;
    private String mode = BTN_CASE_PROGRESS;

    private DisputesDao disputesDao = new DisputesDao();

    public List<DspApplication> getApplications() {
        return applications;
    }
    public void setApplications(List<DspApplication> applications) {
        this.applications = applications;
    }

    public DspApplication getApplication() {
        if (application == null) {
            application = new DspApplication();
        }
        return application;
    }
    public void setApplication(DspApplication application) {
        this.application = application;
    }

    public String getMode() {
        return mode;
    }
    public void setMode(String mode) {
        this.mode = mode;
    }

    public boolean isCaseProgress() {
        return BTN_CASE_PROGRESS.equals(mode);
    }
    public boolean isReasonCode() {
        return BTN_REASON_CODE.equals(mode);
    }

    public List<SelectItem> getProgresses() {
        return getListofValues(disputesDao.getProgressLovId(userSessionId, getApplication()));
    }

    public List<SelectItem> getReasons() {
        if(isCaseProgress() && getApplication().getCaseProgress() == null) {
            return new ArrayList<SelectItem>();
        }
        return getListofValues(disputesDao.getReasonLovId(userSessionId, getApplication()));
    }

    public boolean isChangeAllowed() {
        if (isCaseProgress()) {
            if (applications != null || getApplication().getCaseProgress() != null) {
                return true;
            }
        } else if (isReasonCode()) {
            return true;
        }
        return false;
    }

    public void change() {
        if (applications != null) {
            for (DspApplication app : applications) {
                app.setCaseProgress(getApplication().getCaseProgress());
                app.setReasonCode(getApplication().getReasonCode());
                app.setSeqNum(disputesDao.changeCaseProgress(userSessionId, app));
            }
        } else {
            getApplication().setSeqNum(disputesDao.changeCaseProgress(userSessionId, getApplication()));
            MbDspApplications dspApplications = (MbDspApplications) ManagedBeanWrapper.getManagedBean("MbDspApplications");
            dspApplications.update(getApplication().getId(), EDIT_MODE);
        }
    }

    @Override
    public void clearFilter() {}

    private List<SelectItem> getListofValues(Integer lovId) {
        return (lovId != null) ? getDictUtils().getLov(lovId) : new ArrayList<SelectItem>();
    }
}
