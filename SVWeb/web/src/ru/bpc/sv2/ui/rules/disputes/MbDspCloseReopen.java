package ru.bpc.sv2.ui.rules.disputes;

import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.mastercom.api.MasterComException;
import ru.bpc.sv2.mastercom.api.types.claim.request.MasterComClaimUpdate;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Date;

@ViewScoped
@ManagedBean(name = "MbDspCloseReopen")
public class MbDspCloseReopen extends DspModal {
    public final static String BTN_CLOSE   = "BTN_CLOSE";
    public final static String BTN_REOPEN  = "BTN_REOPEN";

    private DisputesDao disputesDao = new DisputesDao();

    public boolean isClose() {
        return BTN_CLOSE.equals(getType());
    }
    public boolean isReopen() {
        return BTN_REOPEN.equals(getType());
    }

    @Override
    public void execute(DspApplication app) {
    	try {
		    MasterComClaimUpdate update = new MasterComClaimUpdate();
		    update.setClaimId(app.getExtClaimId());
		    if (isClose()) {
			    update.setAction(MasterComClaimUpdate.ClaimAction.CLOSE);
			    update.setCloseClaimReasonCode("10");

			    updateMasterComClaim(app, update);
			    disputesDao.closeCase(userSessionId, app);
		    } else if (isReopen()) {
			    update.setAction(MasterComClaimUpdate.ClaimAction.REOPEN);
			    update.setOpenClaimDueDate(new Date());
			    updateMasterComClaim(app, update);
			    disputesDao.reopenCase(userSessionId, app);
		    }
	    } catch (MasterComException e) {
		    throw new RuntimeException("Error when working with MasterCom", e);
	    }
    }
}
