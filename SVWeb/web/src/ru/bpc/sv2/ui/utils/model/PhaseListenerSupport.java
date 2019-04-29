package ru.bpc.sv2.ui.utils.model;

import javax.faces.event.PhaseEvent;
import javax.faces.event.PhaseId;
import javax.faces.event.PhaseListener;
import java.util.WeakHashMap;

public class PhaseListenerSupport implements PhaseListener {
	private static final WeakHashMap<IDetachable, Integer> detachables = new WeakHashMap<IDetachable, Integer>();
	private static final WeakHashMap<PhaseListener, Integer> phaseListeners = new WeakHashMap<PhaseListener, Integer>();

	public static void registerDetachable(IDetachable detachable) {
		synchronized (detachables) {
			detachables.put(detachable, 0);
		}
	}

	public static void registerPhaseListener(PhaseListener phaseListener) {
		synchronized (phaseListeners) {
			phaseListeners.put(phaseListener, 0);
		}
	}

	@Override
	public void afterPhase(PhaseEvent event) {
		if (event.getPhaseId() == PhaseId.RENDER_RESPONSE)
			synchronized (detachables) {
				for (IDetachable model : detachables.keySet()) {
					model.detach();
				}
			}
		synchronized (phaseListeners) {
			for (PhaseListener phaseListener : phaseListeners.keySet()) {
				PhaseId listenerPhaseId = phaseListener.getPhaseId();
				if (listenerPhaseId == PhaseId.ANY_PHASE || listenerPhaseId == event.getPhaseId())
					phaseListener.afterPhase(event);
			}
		}
	}

	@Override
	public void beforePhase(PhaseEvent event) {
		synchronized (phaseListeners) {
			for (PhaseListener phaseListener : phaseListeners.keySet()) {
				PhaseId listenerPhaseId = phaseListener.getPhaseId();
				if (listenerPhaseId == PhaseId.ANY_PHASE || listenerPhaseId == event.getPhaseId())
					phaseListener.beforePhase(event);
			}
		}
	}

	@Override
	public PhaseId getPhaseId() {
		return PhaseId.ANY_PHASE;
	}
}
