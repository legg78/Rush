package ru.bpc.sv2.ui.reports.constructor.support;

import java.text.MessageFormat;
import java.util.ResourceBundle;

import javax.annotation.PostConstruct;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedProperty;
import javax.faces.context.FacesContext;

import ru.bpc.sv2.ui.reports.constructor.dto.ReportTemplateDto;
import ru.jtsoft.dynamicreports.ReportingDataModel;
import ru.jtsoft.dynamicreports.report.ReportingEnvironment;
import ru.jtsoft.dynamicreports.report.dao.ReportTemplateDao;

public abstract class MbReportingEnvironmentSupport {

	@ManagedProperty("#{MbReportingEnvironment}")
	private transient ReportingEnvironment reportingEnvironment; 
		
	public void setReportingEnvironment(
			ReportingEnvironment reportingEnvironment) {
		this.reportingEnvironment = reportingEnvironment;
	}

	@PostConstruct
	public void postConstuct() {
		init();
	}
	
	protected abstract void init();
	
	protected final ReportingDataModel getReportingDataModel() {
		return reportingEnvironment.getReportingDataModel();
	}

	protected final ReportTemplateDao getReportTemplateDao() {
		return reportingEnvironment.getReportTemplateDao();
	}

	protected final ReportingEnvironment getEnvironment() {
		return reportingEnvironment;
	}
	
	public final ReportTemplateDto getReportTemplateById(Long reportTemplateId, boolean evaluateConditionsString, String curLang) {
		return ReportTemplateDto.converter(getReportingDataModel(), evaluateConditionsString, curLang)
				.apply(getReportTemplateDao().getReportTemplateById(reportTemplateId));
	}

	protected final void addErrorMessage(String messageKey, Object... args) {
		FacesContext context = FacesContext.getCurrentInstance();
		ResourceBundle resourceBundle = reportingEnvironment.getResourceBundle();

        String msg = messageKey;
        if (resourceBundle != null) {
            msg = resourceBundle.getString(messageKey);
            if (args != null && args.length > 0) {
                MessageFormat mf = new MessageFormat(msg);
                msg = mf.format(args);
            }
        }
        context.addMessage(null
				, new FacesMessage(FacesMessage.SEVERITY_ERROR
					, msg
					, null));
	}

}
