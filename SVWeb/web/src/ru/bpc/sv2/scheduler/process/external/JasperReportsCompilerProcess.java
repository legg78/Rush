package ru.bpc.sv2.scheduler.process.external;

import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.ReportTemplate;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.system.TemplateCompiler;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.util.*;

public class JasperReportsCompilerProcess extends IbatisExternalProcess {
	private static final String UNCOMPILED_ONLY = "I_UNCOMPILED_ONLY";
	private ReportsDao reportsDao;

	private boolean uncompiledOnly = false;

	@Override
	public void execute() throws SystemException, UserException {
		getIbatisSession();
		startSession();
		startLogging();
		initBean();

		try {
			info("Obtaining " + (uncompiledOnly ? "not compiled" : "") + " templates");
			List<Filter> filters = new ArrayList<Filter>();
			filters.add(new Filter("reportProcessor", ReportConstants.TEMPLATE_PROCESSOR_JASPER));
			filters.add(new Filter("hasText", true));
			if (uncompiledOnly) {
				filters.add(new Filter("notCompiled", true));
			}
			ReportTemplate[] reportTemplatesArr = reportsDao.getReportTemplatesLight(userSessionId, new SelectionParams(filters));
			Set<Integer> visitedTemplates = new HashSet<Integer>();
			List<ReportTemplate> reportTemplates = new ArrayList<ReportTemplate>();
			for (ReportTemplate template : reportTemplatesArr) {
				if (!visitedTemplates.contains(template.getId())) {
					visitedTemplates.add(template.getId());
					reportTemplates.add(template);
				}
			}
			int total = reportTemplates.size();
			info("Templates obtained: " + total);
			logEstimated(total);
			int successfullyCompiled = 0;
			int failed = 0;
			TemplateCompiler compiler = new TemplateCompiler();
			for (ReportTemplate template : reportTemplates) {
				try {
					ReportTemplate fullTemplate = reportsDao.getReportTemplates(userSessionId, SelectionParams.build("id", template.getId()))[0];
					compiler.compile(fullTemplate);
					reportsDao.modifyReportTemplate(userSessionId, fullTemplate);
					successfullyCompiled++;
				} catch (Throwable e) {
					failed++;
					String msg = String.format("Error compiling template %d (%s)", template.getId(), template.getName());
					error(msg, e);
				}
				logCurrent(successfullyCompiled, failed);
			}

			processSession.setResultCode(ProcessConstants.PROCESS_FINISHED);
			endLogging(successfullyCompiled, failed);

			if (successfullyCompiled == total) {
				info("Compilation done. Successfully compiled reports: " + successfullyCompiled);
			} else {
				throw new UserException("Compilation done with errors. Successfully compiled reports: " + successfullyCompiled);
			}
			commit();
		} catch (Exception e) {
			error(e.getMessage(), e);
			processSession.setResultCode(ProcessConstants.PROCESS_FAILED);
			endLogging(0, 0);
			rollback();
			if (e instanceof UserException) {
				throw new UserException(e);
			} else {
				throw new SystemException(e);
			}
		} finally {
			closeConAndSsn();
		}
	}

	private void initBean() throws SystemException {
		reportsDao = new ReportsDao();
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		if (parameters != null) {
			Object val = parameters.get(UNCOMPILED_ONLY);
			uncompiledOnly = val instanceof Number && ((Number) val).intValue() == 1;
		}
	}
}
