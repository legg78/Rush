package ru.bpc.sv2.ui.rules.disputes;

import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.ui.rules.MbDspApplications;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbDspReassignUser")
public class MbDspReassignUser extends AbstractBean {
    private Integer reassignUser;
    private DspApplication application;
    private List<DspApplication> applications;

    private ApplicationDao applicationDao = new ApplicationDao();

    public Integer getReassignUser() {
        return reassignUser;
    }
    public void setReassignUser(Integer reassignUser) {
        this.reassignUser = reassignUser;
    }

    public DspApplication getApplication() {
        return application;
    }
    public void setApplication(DspApplication application) {
        this.application = application;
    }

    public List<DspApplication> getApplications() {
        return applications;
    }
    public void setApplications(List<DspApplication> applications) {
        this.applications = applications;
    }

    public void reassign() {
        MbDspApplications bean = (MbDspApplications) ManagedBeanWrapper.getManagedBean("MbDspApplications");
        if (applications != null) {
            for (DspApplication app : applications) {
                reassignCase(app, bean);
            }
        } else {
            reassignCase(application, bean);
        }
    }

    public List<SelectItem> getChargebackTeamUsers() {
        return getDictUtils().getLov(LovConstants.CHARGEBACK_USERS_IN_ROLE);
    }

    @Override
    public void clearFilter() {}

    private void reassignCase(DspApplication app, MbDspApplications bean) {
        if (app != null) {
            try {
                app.setNewStatus(app.getStatus());
                if (reassignUser != null) {
                    app.setReassignUser(reassignUser);
                }
                app.setUserId(app.getReassignUser());
                applicationDao.setApplicationUser(userSessionId, app.toApplication());
                if (bean != null) {
                    bean.update(app.getId(), EDIT_MODE);
                }
            } catch (Exception e) {
                getLogger().error("", e);
                FacesUtils.addMessageError(e);
            }
        }
    }
}
