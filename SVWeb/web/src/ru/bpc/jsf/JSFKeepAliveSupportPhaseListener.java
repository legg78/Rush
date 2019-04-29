package ru.bpc.jsf;

import javax.faces.context.FacesContext;
import javax.faces.event.PhaseEvent;
import javax.faces.event.PhaseId;
import javax.faces.event.PhaseListener;
import java.util.Map;

/**
 * User: Mamedov Eduard
 * Date: 10.10.13
 */
public class JSFKeepAliveSupportPhaseListener implements PhaseListener {

    private static final long serialVersionUID = -3689434283608539768L;

    @SuppressWarnings("unchecked")
    public void afterPhase(PhaseEvent event) {
        if (PhaseId.RESTORE_VIEW.equals(event.getPhaseId())) {
            FacesContext facesContext = FacesContext.getCurrentInstance();
            Map<String, Object> map = (Map<String, Object>) facesContext.getViewRoot().getAttributes().get("keepAliveMap");
            if (map != null) {
                Map<String, Object> requestMap = facesContext.getExternalContext().getRequestMap();
                requestMap.putAll(map);
            }
        }
    }

    public void beforePhase(PhaseEvent event) {
    }

    public PhaseId getPhaseId() {
        return PhaseId.ANY_PHASE;
    }
}