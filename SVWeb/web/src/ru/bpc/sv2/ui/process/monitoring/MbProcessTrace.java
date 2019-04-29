package ru.bpc.sv2.ui.process.monitoring;

import org.apache.log4j.Logger;
import org.apache.poi.ss.usermodel.Row;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.process.ProcessTrace;
import ru.bpc.sv2.process.ProcessTraceAdapter;
import ru.bpc.sv2.process.ProcessTraceDTO;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;
import util.servlet.FileServlet;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbProcessTrace")
public class MbProcessTrace extends AbstractBean {
	private CommonDao commonDAO = new CommonDao();


	private static final String ANY_MESSAGE = FacesUtils.getMessage(
			"ru.bpc.sv2.ui.bundles.Form", "all_any");

	private final DaoDataModel<ProcessTrace> processTraceSource;

	private final TableRowSelection<ProcessTrace> processTraceSelection;
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private ProcessTrace activeProcessTrace;

	private ProcessTrace filter;

	private Long sessionId;
	private Integer threadCount;

	private List<SelectItem> traceLevels;

	private String timeZone;

	private static final String COMPONENT_ID = "traceTable";
	private String tabName;
	private String parentSectionId;

	public MbProcessTrace() {

		DateFormat df = DateFormat.getInstance();
		df.setCalendar(Calendar.getInstance());
		timeZone = df.getTimeZone().getID();
		processTraceSource = new DaoDataModel<ProcessTrace>() {
			@Override
			protected ProcessTrace[] loadDaoData(SelectionParams params) {
				if (!searching || (sessionId == null && getFilter().getObjectId() == null))
					return new ProcessTrace[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return commonDAO.getProcessTrace(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProcessTrace[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || (sessionId == null && getFilter().getObjectId() == null))
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return commonDAO
							.getProcessTraceCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		processTraceSelection = new TableRowSelection<ProcessTrace>(null,
				processTraceSource);
	}

	public DaoDataModel<ProcessTrace> getProcessSessions() {
		return processTraceSource;
	}

	public SimpleSelection getItemSelection() {
		if (activeProcessTrace == null && processTraceSource.getRowCount() > 0) {
			processTraceSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			activeProcessTrace = (ProcessTrace) processTraceSource.getRowData();
			selection.addKey(activeProcessTrace.getModelId());
			processTraceSelection.setWrappedSelection(selection);
		}
		return processTraceSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		processTraceSelection.setWrappedSelection(selection);
		activeProcessTrace = processTraceSelection.getSingleSelection();
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		ProcessTrace filter = getFilter();
		Filter paramFilter;

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filtersList.add(paramFilter);

		if (sessionId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("sessionId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(sessionId.toString());
			filtersList.add(paramFilter);
		}
		if (filter.getTraceLevelFilter() != null && filter.getTraceLevelFilter() > 1) {
			paramFilter = new Filter();
			paramFilter.setElement("traceLevel");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getTraceLevelFilter());
			filtersList.add(paramFilter);
		}
		if (filter.getThreadNumber() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("threadNumber");
			paramFilter.setValue(filter.getThreadNumber());
			filtersList.add(paramFilter);
		}

		if (filter.getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getObjectId());
			filtersList.add(paramFilter);
		}

		if (filter.getEntityType() != null && !filter.getEntityType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getEntityType());
			filtersList.add(paramFilter);
		}
		filters = filtersList;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public void search() {
		processTraceSource.flushCache();
		processTraceSelection.clearSelection();
		activeProcessTrace = null;
		searching = true;
	}

	public ProcessTrace getActiveProcessTrace() {
		return activeProcessTrace;
	}

	public void setActiveProcessTrace(ProcessTrace activeProcessTrace) {
		this.activeProcessTrace = activeProcessTrace;
	}

	public String getTimeZone() {
		return timeZone;
	}

	public void cancel() {

	}

	public void view() {

	}

	public void clearBean() {
		processTraceSelection.clearSelection();
		activeProcessTrace = null;
		processTraceSource.flushCache();
		searching = false;
	}

	public void fullCleanBean() {
		sessionId = null;
		clearBean();
	}

	public ProcessTrace getFilter() {
		if (filter == null)
			filter = new ProcessTrace();
		return filter;
	}

	public void setFilter(ProcessTrace filter) {
		this.filter = filter;
	}

	public List<SelectItem> getThreadNumbers() {
		List<SelectItem> threadNumbers = new ArrayList<SelectItem>();
		if (threadCount != null && threadCount > 1) {
			SelectItem item = new SelectItem(null, ANY_MESSAGE);
			threadNumbers.add(item);
			for (int i = 0; i < threadCount; i++) {
				item = new SelectItem(i + 1);
				threadNumbers.add(item);
			}

		}
		return threadNumbers;
	}

	public Integer getThreadCount() {
		return threadCount;
	}

	public void setThreadCount(Integer threadCount) {
		this.threadCount = threadCount;
	}

	public List<SelectItem> getTraceLevels() {
		if (traceLevels == null) {
			traceLevels = getDictUtils().getLov(LovConstants.TRACE_LEVELS, null, Collections.singletonList("code != 1"));
		}
		return traceLevels;
	}

	@Override
	public void clearFilter() {
		filter = new ProcessTrace();
		clearBean();
	}

	private String exportFormat;
	private static final String FORMAT_XML = "XML";
	private static final String FORMAT_XLS = "XLS";

	public String getExportFormat() {
		return exportFormat;
	}

	public void setExportFormat(String exportFormat) {
		this.exportFormat = exportFormat;
	}

	public void export() {
		outStream = new ByteArrayOutputStream();
		// get process Trace list
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		params.setRowIndexEnd(-1);
		ProcessTrace[] procTraces = commonDAO.getProcessTrace(userSessionId, params);
		List<ProcessTrace> traceList = Arrays.asList(procTraces);

		if (FORMAT_XML.equals(exportFormat)) {
			exportXML(traceList);
		} else if (FORMAT_XLS.equals(exportFormat)) {
			exportXLS(traceList);
		}
		generateFileByServlet();
	}

	@SuppressWarnings("unchecked")
	public void exportXML(final List<ProcessTrace> traceList) {
		final String rootEle = "processTraceList";
		final ProcessTraceAdapter traceAdapter = new ProcessTraceAdapter();
		ProcessTraceDTO traceDTO = new ProcessTraceDTO();
		try {
			ExportUtils.exportXML(outStream, traceList, rootEle, traceAdapter, traceDTO, ProcessTraceDTO.class);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void exportXLS(final List<ProcessTrace> traceList) {
		try {
			final UserSession session = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
			final ExportUtils ex = new ExportUtils() {
				@Override
				public void createHeadRow() {
					Row rowhead = sheet.createRow((short) 0);
					rowhead.createCell(0).setCellValue("Trace timestamp");
					rowhead.createCell(1).setCellValue("Trace level");
					rowhead.createCell(2).setCellValue("Trace text");
					rowhead.createCell(3).setCellValue("Trace section");
					rowhead.createCell(4).setCellValue("User id");
					rowhead.createCell(5).setCellValue("Session id");
					rowhead.createCell(6).setCellValue("Thread number");
					rowhead.createCell(7).setCellValue("Entity type");
					rowhead.createCell(8).setCellValue("Entity description");
					rowhead.createCell(9).setCellValue("Object id");
					rowhead.createCell(10).setCellValue("Event id");
					rowhead.createCell(11).setCellValue("Label id");
					rowhead.createCell(12).setCellValue("Inst id");
					rowhead.createCell(13).setCellValue("Who called");
					rowhead.createCell(14).setCellValue("Text");
					rowhead.createCell(15).setCellValue("Details");
					sheet.setColumnWidth(0, 20 * 256);
				}

				@Override
				public void createRows() {
					int i = 1;
					for (ProcessTrace trace : traceList) {
						Row row = sheet.createRow(i++);
						fillCellDate(row.createCell(0), trace.getTraceTimestamp(), session.getFullDatePatternSeconds(), session.getCurrentLocale());
						row.createCell(1).setCellValue(trace.getTraceLevel());
						row.createCell(2).setCellValue(trace.getTraceText());
						row.createCell(3).setCellValue(trace.getTraceSection());
						row.createCell(4).setCellValue(trace.getUserId());
						row.createCell(5).setCellValue(trace.getSessionId() == null ? "" : trace.getSessionId().toString());
						row.createCell(6).setCellValue(trace.getThreadNumber() == null ? "" : trace.getThreadNumber().toString());
						row.createCell(7).setCellValue(trace.getEntityType());
						row.createCell(8).setCellValue(trace.getEntityDescription());
						row.createCell(9).setCellValue(trace.getObjectId() == null ? "" : trace.getObjectId().toString());
						row.createCell(10).setCellValue(trace.getEventId() == null ? "" : trace.getEventId().toString());
						row.createCell(11).setCellValue(trace.getLabelId() == null ? "" : trace.getLabelId().toString());
						row.createCell(12).setCellValue(trace.getInstId() == null ? "" : trace.getInstId().toString());
						row.createCell(13).setCellValue(trace.getWhoCalled());
						row.createCell(14).setCellValue(trace.getText());
						row.createCell(15).setCellValue(trace.getDetails() == null ? "" : trace.getDetails());
					}
				}
			};
			ex.exportXLS(outStream);
		} catch (IOException e) {
			e.printStackTrace();
			FacesUtils.addMessageError(e);
		} catch (Exception e) {
			e.printStackTrace();
			FacesUtils.addMessageError(e);
		}
	}

	private ByteArrayOutputStream outStream;

	public void generateFileByServlet() {
		if (outStream == null) return;

		byte[] reportContent = outStream.toByteArray();
		try {
			outStream.close();
		} catch (IOException ignored) {
		}

		HttpServletRequest req = RequestContextHolder.getRequest();
		HttpSession session = req.getSession();
		session.setAttribute(FileServlet.FILE_SERVLET_CONTENT_TYPE, "application/x-download");
		session.setAttribute(FileServlet.FILE_SERVLET_FILE_CONTENT, reportContent);
	}

	public String getReportName() {
		Date today = new Date();
		SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyyMMdd-HHmmss");
		String date = DATE_FORMAT.format(today);
		return "trace-" + date + "." + exportFormat;
	}

	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	@Override
	public String getTableState() {
		MbProcessUserSessions bean = (MbProcessUserSessions) ManagedBeanWrapper
				.getManagedBean("MbProcessUserSessions");
		if (bean != null) {
			setTabName(bean.getTabName());
			setParentSectionId(bean.getSectionId());
		}
		return super.getTableState();
	}
}
