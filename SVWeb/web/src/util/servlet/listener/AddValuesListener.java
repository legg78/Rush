package util.servlet.listener;

import javax.faces.event.PhaseEvent;
import javax.faces.event.PhaseId;
import javax.faces.event.PhaseListener;
import javax.security.auth.Subject;

import util.auxil.SessionWrapper;


public class AddValuesListener implements PhaseListener {
	private static final long serialVersionUID = 5857055871778790348L;

	@Override
	public void afterPhase(PhaseEvent arg0) {
//		String mbeanName = SessionWrapper.getField("MbAddName");
//		
//		if (mbeanName == null)
//			return;
//		
//		Object mbean = ManagedBeanWrapper.getManagedBean(mbeanName);
//		Class cls = mbean.getClass();
//		try {
//			Class partypes[] = new Class[0];
//            Method meth = cls.getMethod("add", partypes);
//            
//            Object arglist[] = new Object[0];
//            Object retobj = meth.invoke(mbean, arglist);            
//            SessionWrapper.setField("MbAddName", null);
//		} catch (Exception e) {
//			e.printStackTrace();
//		} 
	}

	@Override
	public void beforePhase(PhaseEvent arg0) {
		Subject subj = (Subject)SessionWrapper.getObjectField("subject");
		if (subj == null)
			return;
		
	}

	@Override
	public PhaseId getPhaseId() {
		return PhaseId.INVOKE_APPLICATION;
	}

}
