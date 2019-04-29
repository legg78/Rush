package ru.bpc.sv2.scheduler.process;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.reports.Report;
import ru.bpc.sv2.reports.ReportParameter;
import ru.bpc.sv2.reports.RptDocument;
import ru.bpc.sv2.ui.reports.ReportRunner;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class DeterministicReportProcessing extends IbatisExternalProcess {
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");
	
	private Map<String, Object> parameters;
	
	private ExecutorService executor;
	
	private ReportsDao rptBean;
	
	private String fault_code;
	
	public DeterministicReportProcessing(){
		
	}

	@Override
	public void execute() throws SystemException, UserException {
		// TODO Auto-generated method stub
		this.executor = Executors.newFixedThreadPool(threadsNumber);
		initBean();
		fault_code=ProcessConstants.PROCESS_FINISHED_WITH_ERRORS;
		RptDocument[] docs = getProcessDocuments();
		Future<Object>[] futures = new Future[docs.length-1];
		int i = 0;
		try {
			for(RptDocument doc : docs){
				futures[i] = executor.submit(new GenerateReportTask(doc, process.getContainerBindId(), processSessionId()));
				i++;
			}
			boolean stop = false;
			Exception exc = null;
			int countErr = 0;
			for(int j = 0; j < docs.length-1; j++){
				if(stop && !futures[i].isDone()){
					futures[i].cancel(true);
					if(futures[i].isCancelled()){
						fault_code=ProcessConstants.PROCESS_FAILED;
						logger.debug("--process stoped--");
					}
					continue;
				}
				Object result = futures[j].get();
				if (result instanceof Exception) {
					if (process.isInterruptThreads()){
						stop = true;
					}
					exc = (Exception)result;
					countErr++;
					if(countErr>1){
						fault_code=ProcessConstants.PROCESS_FAILED;
					}	
				}
			}
			if (exc != null) throw (Exception)exc;
			processSession.setResultCode(ProcessConstants.PROCESS_FINISHED);
		}catch(Exception e){
			processSession.setResultCode(fault_code);
		}
		// TODO: add condition when process is failed
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		// TODO Auto-generated method stub
		this.parameters = parameters;
	}
	

	private void initBean() throws SystemException{
		rptBean = new ReportsDao();
	}
	
	private RptDocument[] getProcessDocuments(){
		SelectionParams params = new SelectionParams();
		List<Filter> filters = new ArrayList<Filter>();
		
		Filter f = new Filter("procedureName", process.getProcedureName());
		filters.add(f);
		
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		RptDocument[] result = null;
		try {
			result = rptBean.getProcessDocuments(userSessionId,
					params);
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return result;
	}
	
	
	private class GenerateReportTask implements Callable {
		private RptDocument rptDoc;
		private ReportRunner reportRunner;
		private Report showDocumentReport = null;
		private Integer containerId;
		private Long sessionId;

		public GenerateReportTask(RptDocument rptDoc, Integer containerId, Long sessionId) {
			this.rptDoc = rptDoc;
			this.containerId = containerId;
			this.sessionId = sessionId;
		}

		public Object call() {
			reportRunner = new ReportRunner(userSessionId);
			showDocumentReport = new Report();
			showDocumentReport.setId(10000034L);
			showDocumentReport.setSourceType(ReportConstants.REPORT_SOURCE_TYPE_XML);
			showDocumentReport.setLang("LANGENG");
			
			ReportParameter objectId = new ReportParameter();
			objectId.setSystemName("I_OBJECT_ID");
			objectId.setValue(rptDoc.getId());
			ReportParameter[] reportParameters = new ReportParameter[]{objectId};
			
			try {
				SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
				String date = sdf.format(rptDoc.getDocumentDate());
				showDocumentReport.setName("document(" + rptDoc.getDocumentNumber()+"_"+date+")");
				reportRunner.runReportToFile(showDocumentReport, ReportConstants.REPORT_FORMAT_PDF, reportParameters, rptDoc.getTemplateId(), containerId, sessionId);
			} catch (Exception e) {
				FacesUtils.addSystemError(e);
				logger.error("", e);
				return e;
			}
			return "OK";
		}
	}
}
