package ru.bpc.jsf;

import org.apache.log4j.Logger;
import org.openfaces.util.AjaxUtil;

import javax.faces.FacesException;
import javax.faces.application.ViewHandler;
import javax.faces.component.UIViewRoot;
import javax.faces.context.FacesContext;
import java.io.IOException;

/**
 * User: Mamedov Eduard
 * Date: 25.09.13
 */
public class AjaxViewHandler extends org.ajax4jsf.application.AjaxViewHandler {
	private static final Logger logger = Logger.getLogger("SYSTEM");

    public AjaxViewHandler(ViewHandler parent) {
        super(parent);
    }

    public String getResourceURL(FacesContext context, String url) {
        return (url == null || url.isEmpty()) ?  null : super.getResourceURL(context, url);
    }

    @Override
    public UIViewRoot restoreView(FacesContext context, String viewId) {
        if (AjaxUtil.isAjaxRequest(context)) {
            return  new org.openfaces.ajax.AjaxViewHandler(getHandler()).restoreView(context, viewId);
        }
        return super.restoreView(context, viewId);
    }

    @Override
    public UIViewRoot createView(FacesContext facesContext, String viewId) {
        if (AjaxUtil.isAjaxRequest(facesContext)) {
            return new org.openfaces.ajax.AjaxViewHandler(getHandler()).createView(facesContext, viewId);
        }
        return super.createView(facesContext, viewId);
    }

    @Override
    public void renderView(FacesContext context, UIViewRoot root) throws IOException, FacesException {
	    try {
		    if (AjaxUtil.isAjaxRequest(context)) {
		        org.openfaces.ajax.AjaxViewRoot ofViewRoot = new org.openfaces.ajax.AjaxViewRoot(root);
		        new org.openfaces.ajax.AjaxViewHandler(getHandler()).renderView(context, ofViewRoot);
		    } else {
		        super.renderView(context, root);
		    }
	    } catch (IOException e) {
		    logError(e, context, root);
		    throw e;
	    } catch (FacesException e) {
		    logError(e, context, root);
		    throw e;
	    } catch (RuntimeException e) {
		    logError(e, context, root);
		    throw e;
	    }
    }

	private void logError(Throwable e, FacesContext context, UIViewRoot root) {
		StringBuilder buf = new StringBuilder();
		buf.append("Error while rendering jsf view: ").append(e.getClass()).append("; ").append(e.getMessage());
		ru.bpc.sv2.ui.utils.FacesUtils.dumpFacesContext(context, buf);
		logger.error(buf.toString());
	}
}
