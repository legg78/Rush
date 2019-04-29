package ru.bpc.jsf;

import javax.faces.event.PhaseEvent;
import javax.faces.event.PhaseId;
import javax.faces.event.PhaseListener;

public class PagePhaseListener implements PhaseListener {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	public static final String AJAX_ABORT_PHASE = "ajax.abortPhase" ;

	public void beforePhase(PhaseEvent event) {}
	public PhaseId getPhaseId() {
		return PhaseId.ANY_PHASE;
	}
	
	public void afterPhase(PhaseEvent event) {
		// see if this is an abortPhase request
		String abortPhaseParam = (String)event.getFacesContext().getExternalContext().getRequestParameterMap().get(AJAX_ABORT_PHASE);
		int phaseOrdinal = -1;
		if(abortPhaseParam != null) {
			try{
				phaseOrdinal = Integer.valueOf(abortPhaseParam).intValue();
			}
			catch (NumberFormatException e) {}
			
			if(phaseOrdinal == event.getPhaseId().getOrdinal()) {
				//Abort the rest of the request processing if after 
				//the phase specified by the parameter.
				event.getFacesContext().responseComplete();
			}
		}
	}
}
