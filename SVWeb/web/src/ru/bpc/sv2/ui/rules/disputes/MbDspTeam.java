package ru.bpc.sv2.ui.rules.disputes;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.ui.rules.MbDspApplications;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbDspTeam")
public class MbDspTeam extends AbstractBean {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger("APPLICATIONS");

    private List<SelectItem> teams;
    private List<DspApplication> applications;
    private Long teamId;

    private DisputesDao disputesDao = new DisputesDao();

    public List<SelectItem> getTeams() {
        if (teams == null) {
            teams = getDictUtils().getLov(LovConstants.CSM_DISPUTE_TEAMS);
            if (teams == null) {
                teams = new ArrayList<SelectItem>();
            }
        }
        return teams;
    }
    public void setTeams(List<SelectItem> teams) {
        this.teams = teams;
    }

    public List<DspApplication> getApplications() {
        if (applications == null) {
            applications = new ArrayList<DspApplication>();
        }
        return applications;
    }
    public void setApplications(List<DspApplication> applications) {
        this.applications = applications;
    }

    public void change() {
        for (DspApplication dspApp : getApplications()) {
            try {
                if (getTeamId() != null) {
                    dspApp.setTeamId(getTeamId());
                }
                dspApp.setSeqNum(disputesDao.setApplicationTeam(userSessionId, dspApp));
            } catch (Exception e) {
                logger.error("", e);
                FacesUtils.addMessageError(e);
            }
        }
        if (getApplications().size() == 1) {
            MbDspApplications dspApplications = (MbDspApplications) ManagedBeanWrapper.getManagedBean("MbDspApplications");
            dspApplications.update(getApplications().get(0).getId(), EDIT_MODE);
        }
    }

    @Override
    public void clearFilter() {}

    public Long getTeamId() {
        return teamId;
    }

    public void setTeamId(Long teamId) {
        this.teamId = teamId;
    }
}
