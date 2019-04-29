package ru.bpc.sv2.ui.rules.disputes;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.logic.NotesDao;
import ru.bpc.sv2.mastercom.api.MasterComException;
import ru.bpc.sv2.mastercom.api.types.claim.request.MasterComClaimUpdate;
import ru.bpc.sv2.notes.ObjectNote;
import ru.bpc.sv2.ui.session.UserSession;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbDspStatus")
public class MbDspStatus extends DspModal {
    public final static String BTN_STATUS     = "BTN_STATUS";
    public final static String BTN_COMMENT    = "BTN_COMMENT";
    public final static String BTN_RESOLUTION = "BTN_RESOLUTION";

    private String status;
    private String resolution;
    private String systemComment;
    private String userComment;

    private NotesDao notesDao = new NotesDao();
    private DisputesDao disputesDao = new DisputesDao();

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getResolution() {
        return resolution;
    }
    public void setResolution(String resolution) {
        this.resolution = resolution;
    }

    public String getSystemComment() {
        return systemComment;
    }
    public void setSystemComment(String systemComment) {
        this.systemComment = systemComment;
    }

    public String getUserComment() {
        return userComment;
    }
    public void setUserComment(String userComment) {
        this.userComment = userComment;
    }

    public boolean isStatusAction() {
        return BTN_STATUS.equals(getType());
    }
    public boolean isResolutionAction() {
        return BTN_RESOLUTION.equals(getType());
    }
    public boolean isCommentAction() {
        return BTN_COMMENT.equals(getType());
    }

    public List<SelectItem> getStatuses() {
        if (isSingleAction()) {
            Map<String, Object> params = new HashMap<String, Object>(2);
            params.put("flow_id", getApplication().getFlowId());
            params.put("curr_appl_status", getApplication().getStatus());
            List<SelectItem> list = getDictUtils().getLov(LovConstants.APP_STATUSES_FOR_TRANSITIONS, params);
            return getNonEmptyList(list);
        }
        return null;
    }
    public List<SelectItem> getResolutions() {
        if (isSingleAction()) {
            Map<String, Object> params = new HashMap<String, Object>(2);
            params.put("flow_id", getApplication().getFlowId());
            params.put("appl_status", status);
            List<SelectItem> list = getDictUtils().getLov(LovConstants.APP_REJECT_CODES_FOR_STATUS, params);
            return getNonEmptyList(list);
        }
        return null;
    }
    public List<SelectItem> getComments() {
        List<SelectItem> list = getDictUtils().getLov(LovConstants.APPLICATION_HISTORY_MESSAGES);
        return getNonEmptyList(list);
    }

    private List<SelectItem> getNonEmptyList(List<SelectItem> list) {
        if (list != null) {
            for (Iterator<SelectItem> iterator = list.iterator(); iterator.hasNext(); ) {
                SelectItem item = iterator.next();
                if (item.getValue() == null || StringUtils.isEmpty(item.getValue().toString())) {
                    iterator.remove();
                }
            }
        }
        return list;
    }

    @Override
    public void execute(DspApplication app) {
    	try {
    		if (isStatusAction() && ApplicationStatuses.CLOSED_STATUSES.contains(status)) {
			    MasterComClaimUpdate update = new MasterComClaimUpdate();
			    update.setClaimId(app.getExtClaimId());
			    update.setAction(MasterComClaimUpdate.ClaimAction.CLOSE);
			    update.setCloseClaimReasonCode("10");
			    updateMasterComClaim(app, update);
		    }
		    if (isStatusAction() || isResolutionAction()) {
			    changeStatusAndResolution(app);
		    }
		    if (isCommentAction()) {
			    addComment(app);
		    }
	    } catch (MasterComException e) {
		    throw new RuntimeException("Error when working with MasterCom", e);
	    }
    }

    private void changeStatusAndResolution(DspApplication app) {
        if (StringUtils.isNotEmpty(status) || StringUtils.isNotEmpty(resolution)) {
            app.setStatus(status);
            app.setRejectCode(resolution);
            disputesDao.changeCaseStatus(userSessionId, app);
        }
    }

    private void addComment(DspApplication app) {
        if (StringUtils.isNotEmpty(systemComment) || StringUtils.isNotEmpty(userComment)) {
            addNote(getObjectNote(), app, getCurrentUserId());
        }
    }

    private ObjectNote getObjectNote() {
        ObjectNote objectNote = new ObjectNote();
        objectNote.setLang(userLang);
        objectNote.setEntityType(EntityNames.APPLICATION);
        return objectNote;
    }

    private Integer getCurrentUserId() {
        Integer userId = null;
        UserSession userSession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
        if (userSession != null && userSession.getUser() != null) {
            userId = userSession.getUser().getId();
        }
        return userId;
    }

    private void addNote(ObjectNote note, DspApplication app, Integer userId) throws IllegalStateException {
        try {
            note.setObjectId(app.getId());
            if (systemComment != null) {
                note.setText(disputesDao.getAticleText(userSessionId, systemComment));
            } else if (userComment != null) {
                note.setText(userComment);
            }
            notesDao.addNote(userSessionId, note);

            /**
             * TODO: check if it is really needed to perform
             *
             * Map<String, Object> map = new HashMap<String, Object>();
             * map.put("applId", app.getId());
             * map.put("seqNum", app.getSeqNum());
             * map.put("reasonCode", systemComment);
             * map.put("userId", userId);
             * disputesDao.modifyApplStatusAndResolution(userSessionId, map);
             */
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private  List<SelectItem> getSelectItemObject(String object) {
        List<SelectItem> out = new ArrayList<SelectItem>(1);
        out.add(new SelectItem(object, object + " - " + getDictUtils().getAllArticlesDesc().get(object)));
        return out;
    }
}
