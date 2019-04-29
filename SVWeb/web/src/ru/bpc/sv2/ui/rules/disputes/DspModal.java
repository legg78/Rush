package ru.bpc.sv2.ui.rules.disputes;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.dsp.CaseNetworkContext;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.mastercom.api.MasterCom;
import ru.bpc.sv2.mastercom.api.MasterComException;
import ru.bpc.sv2.mastercom.api.types.claim.request.MasterComClaimUpdate;
import ru.bpc.sv2.ui.rules.MbDspApplications;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import java.util.List;

public abstract class DspModal extends AbstractBean {
	private static final Logger logger = Logger.getLogger("RULES");

	private DspApplication application;
    private List<DspApplication> applications;

    private String type;
    private Object parent;

	private DisputesDao disputesDao = new DisputesDao();

	protected boolean isBulkAction() {
        return (applications != null && application == null);
    }
    protected boolean isSingleAction() {
        return (applications == null && application != null);
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

    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }

    public void execute() {
	    try {
		    MbDspApplications bean = (MbDspApplications)ManagedBeanWrapper.getManagedBean("MbDspApplications");
		    if (applications != null) {
			    for (DspApplication app : applications) {
				    execute(app);
				    bean.update(app.getId(), EDIT_MODE);
			    }
		    } else if (application != null) {
			    execute(application);
			    bean.update(application.getId(), EDIT_MODE);
		    }
	    } catch (Exception e) {
		    logger.error("", e);
		    FacesUtils.addMessageError(e);
	    }
    }
    public abstract void execute(DspApplication app);

    public void initialize(List<DspApplication> app, String type) {
        initialize(app);
        this.type = type;
    }

    public void initialize(List<DspApplication> apps) {
        clearFilter();
        if (apps != null) {
            if (apps.size() == 1) {
                setApplication(apps.get(0));
            } else {
                setApplications(apps);
            }
        }
    }

    @Override
    public void clearFilter() {
        application = null;
        applications = null;
        type = null;
        parent = null;
    }

	protected void updateMasterComClaim(DspApplication app, MasterComClaimUpdate update) throws MasterComException {
		logger.debug(String.format("Trying to set status %s for claim %d in MasterCom (extClaimId=%s, operId=%d)", update.getAction(), app.getId(), app.getExtClaimId(), app.getOperId()));
		if (StringUtils.isEmpty(app.getExtClaimId()) || app.getOperId() == null) {
			return;
		}

		CaseNetworkContext context = new CaseNetworkContext();
		context.setOperId(app.getOperId());

		if (disputesDao.isMasterComEnabled(userSessionId, context)) {
			MasterCom mc = new MasterCom();
			mc.requireValidHealth();

			mc.updateClaim(update);

			logger.debug(update.getAction() + " status is set for claim " + app.getId() + " in MasterCom");
		}
	}
}
