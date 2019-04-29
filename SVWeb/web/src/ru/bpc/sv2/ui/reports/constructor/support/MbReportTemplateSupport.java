package ru.bpc.sv2.ui.reports.constructor.support;

import javax.faces.context.FacesContext;

public abstract class MbReportTemplateSupport extends MbReportingEnvironmentSupport {
	
	@Override
	protected void init() {
		String reportTemplateId = FacesContext.getCurrentInstance()
				.getExternalContext().getRequestParameterMap()
				.get("reportTemplateId");
		initReportTemplate(null == reportTemplateId ? null : Long.valueOf(reportTemplateId));
	}

	protected abstract void initReportTemplate(Long reportTemplateId);
}
