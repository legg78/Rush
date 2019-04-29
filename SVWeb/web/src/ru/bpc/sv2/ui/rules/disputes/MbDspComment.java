package ru.bpc.sv2.ui.rules.disputes;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.logic.NotesDao;
import ru.bpc.sv2.notes.ObjectNote;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbDspComment")
public class MbDspComment extends AbstractBean {
    private String systemComment;
    private String userComment;
    private DspApplication application;
    private List<DspApplication> applications;

    private NotesDao notesDao = new NotesDao();
    private DisputesDao disputesDao = new DisputesDao();

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

    public List<SelectItem> getComments() {
        return getDictUtils().getLov(LovConstants.APPLICATION_HISTORY_MESSAGES);
    }

    public void addComment() {
        if (StringUtils.isNotEmpty(systemComment) || StringUtils.isNotEmpty(userComment)) {
            Integer userId = null;
            UserSession userSession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
            if (userSession != null && userSession.getUser() != null) {
                userId = userSession.getUser().getId();
            }

            ObjectNote objectNote = new ObjectNote();
            objectNote.setLang(userLang);
            objectNote.setEntityType(EntityNames.APPLICATION);

            if (applications != null) {
                for (DspApplication app : applications) {
                    addNote(objectNote, app, userId);
                }
            } else if (application != null) {
                addNote(objectNote, application, userId);
            }
        }
    }

    @Override
    public void clearFilter() {}

    private void addNote(ObjectNote note, DspApplication app, Integer userId) throws IllegalStateException {
        try {
            note.setObjectId(app.getId());
            if (systemComment != null) {
                note.setText(disputesDao.getAticleText(userSessionId, systemComment));
            } else if (userComment != null) {
                note.setText(userComment);
            }
            notesDao.addNote(userSessionId, note);

            Map<String, Object> map = new HashMap<String, Object>();
            map.put("applId", app.getId());
            map.put("seqNum", app.getSeqNum());
            map.put("reasonCode", systemComment);
            map.put("userId", userId);
            disputesDao.modifyApplStatusAndResolution(userSessionId, map);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }
}
