package ru.bpc.sv2.ui.utils;

import org.openfaces.util.ResourceFilter;
import org.openfaces.util.Resources;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import java.io.Serializable;

@SessionScoped
@ManagedBean(name = "MbUIUtils")
public class MbUIUtils implements Serializable {
	public String getOpenfacesDefaulsCssUri() {
		return RequestContextHolder.getRequest().getContextPath() + ResourceFilter.INTERNAL_RESOURCE_PATH +
				Resources.META_INF_RESOURCES_ROOT.substring(1) + "default" + "-" + Resources.getVersionString() + ".css";
	}

	public String getOpenfacesUtilJsUri() {
		return Resources.utilJsURL(FacesContext.getCurrentInstance());
	}
}
