package ru.bpc.jsf.taglib;

import com.sun.facelets.FaceletContext;
import com.sun.facelets.tag.TagAttribute;
import com.sun.facelets.tag.TagConfig;
import com.sun.facelets.tag.TagHandler;
import com.sun.facelets.tag.jsf.ComponentSupport;
import com.sun.faces.application.ApplicationAssociate;

import javax.el.ELContext;
import javax.el.ELException;
import javax.el.MethodExpression;
import javax.el.MethodNotFoundException;
import javax.faces.FacesException;
import javax.faces.component.UIComponent;
import javax.faces.component.UIViewRoot;
import javax.faces.context.FacesContext;
import javax.faces.event.*;
import javax.faces.view.facelets.ComponentHandler;
import java.io.IOException;
import java.io.Serializable;

public class EventHandler extends TagHandler {
	protected final TagAttribute type;
	protected final TagAttribute listener;

	public EventHandler(TagConfig config) {
		super(config);
		this.type = this.getRequiredAttribute("type");
		this.listener = this.getRequiredAttribute("listener");
	}

	@Override
	public void apply(FaceletContext ctx, UIComponent parent) throws IOException, FacesException, ELException {
		if (ComponentHandler.isNew(parent)) {
			Class<? extends SystemEvent> eventClass = getEventClass(ctx);
			UIViewRoot viewRoot = ComponentSupport.getViewRoot(ctx, parent);
			// ensure that f:event can be used anywhere on the page for preRenderView,
			// not just as a direct child of the viewRoot
			if (null != viewRoot && PreRenderViewEvent.class == eventClass &&
					parent != viewRoot) {
				parent = viewRoot;
			}
			if (eventClass != null) {
				parent.subscribeToEvent(eventClass,
						new DeclarativeSystemEventListener(
								listener.getMethodExpression(ctx, Object.class, new Class[]{ComponentSystemEvent.class}),
								listener.getMethodExpression(ctx, Object.class, new Class[]{})));
			}
		}
	}

	protected Class<? extends SystemEvent> getEventClass(FaceletContext ctx) {
		String eventType = (String) this.type.getValueExpression(ctx, String.class).getValue(ctx);
		if (eventType == null) {
			throw new FacesException("Attribute 'type' can not be null");
		}

		return ApplicationAssociate.getInstance(ctx.getFacesContext().getExternalContext())
				.getNamedEventManager().getNamedEvent(eventType);
	}

}


class DeclarativeSystemEventListener implements ComponentSystemEventListener, Serializable {

	private static final long serialVersionUID = 8945415935164238908L;

	private MethodExpression oneArgListener;
	private MethodExpression noArgListener;

	// Necessary for state saving
	@SuppressWarnings("unused")
	public DeclarativeSystemEventListener() {
	}

	public DeclarativeSystemEventListener(MethodExpression oneArg, MethodExpression noArg) {
		this.oneArgListener = oneArg;
		this.noArgListener = noArg;
	}

	public void processEvent(ComponentSystemEvent event) throws AbortProcessingException {
		final ELContext elContext = FacesContext.getCurrentInstance().getELContext();
		try {
			noArgListener.invoke(elContext, new Object[]{});
		} catch (MethodNotFoundException mnfe) {
			// Attempt to call public void method(ComponentSystemEvent event)
			oneArgListener.invoke(elContext, new Object[]{event});
		}
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) {
			return true;
		}
		if (o == null || getClass() != o.getClass()) {
			return false;
		}

		DeclarativeSystemEventListener that = (DeclarativeSystemEventListener) o;

		return noArgListener != null ?
				noArgListener.equals(that.noArgListener) :
				that.noArgListener == null && (oneArgListener != null ?
						oneArgListener.equals(that.oneArgListener) :
						that.oneArgListener == null);

	}

	@Override
	public int hashCode() {
		int result = oneArgListener != null ? oneArgListener.hashCode() : 0;
		result = 31 * result + (noArgListener != null
				? noArgListener.hashCode()
				: 0);
		return result;
	}
}
