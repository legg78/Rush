package ru.bpc.sv2.ui.session;

import javax.faces.context.FacesContext;
import javax.faces.event.PhaseEvent;
import javax.faces.event.PhaseId;
import javax.faces.event.PhaseListener;

import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

/**
 * Listens to RESTORE VIEW jsf phase and sets user language if it's not set 
 * @author Alexeev
 *
 */
public class SvPhaseListener implements PhaseListener {
	private static final long serialVersionUID = 5857055871778790348L;

	@Override
	public void afterPhase(PhaseEvent arg0) {
		if (SessionWrapper.getUserSessionIdStr() == null || FacesContext.getCurrentInstance().getExternalContext().getUserPrincipal() == null) {
			return;
		}
		UserSession us = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
		if (us.getUserLanguage() == null)
			us.flushUserLang();
		if (us.getUserInst() == null)
			us.flushUserInst();
		if (us.getDatePattern() == null)
			us.flushUserDatePattern();
		if (us.getArticleFormat() == null)
			us.flushArticleFormat();
		if (us.getUserAgent() == null){
			us.flushUserAgent();
		}
		if (us.getGroupSeparator() == null){
			us.flushGroupSeparator();
		}
	}

	@Override
	public void beforePhase(PhaseEvent arg0) {	
	}

	@Override
	public PhaseId getPhaseId() {
		return PhaseId.RESTORE_VIEW;
	}

}
