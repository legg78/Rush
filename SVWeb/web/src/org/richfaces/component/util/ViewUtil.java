package org.richfaces.component.util;

import javax.faces.context.FacesContext;

/**
 * Created by Kubantseva on 26.09.2014.
 * Needs for working Richfaces 3.3.3 on Weblogic 12.1.3
 */
public class ViewUtil {

    public static String getResourceURL(String url) {
        if (null == url) return null;
        return ViewUtil.getResourceURL(url, FacesContext.getCurrentInstance());
    }

    public static String getResourceURL(String url, FacesContext context) {
        if (null == url) return null;
        String value = url;
        value = context.getApplication().getViewHandler().getResourceURL(context, value);
        return value != null ? (context.getExternalContext().encodeResourceURL(value)) : null;
    }
}
