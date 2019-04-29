package ru.bpc.sv2.ui.trace.logging;

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
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbTrace")
public class MbTrace extends AbstractBean {
	private CommonDao commonDAO = new CommonDao();

	private final DaoDataModel<ProcessTrace> processTraceSource;

	private final TableRowSelection<ProcessTrace> processTraceSelection;
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private ProcessTrace activeProcessTrace;
	private List<SelectItem> traceLevels;
	private List<SelectItem> oracleTraceLevels;

	DictUtils dictUtils;

	private ProcessTrace filter;

	private String timeZone;

	private static final String COMPONENT_ID = "traceTable";
	private String tabName;
	private String parentSectionId;

	public MbTrace() {
		dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");

		DateFormat df = DateFormat.getInstance();
		df.setCalendar(Calendar.getInstance());
		timeZone = df.getTimeZone().getID();
		processTraceSource = new DaoDataModel<ProcessTrace>() {
			@Override
			protected ProcessTrace[] loadDaoData(SelectionParams params) {
				if (!searching || filter.getObjectId() == null)
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
				if (!searching || filter.getObjectId() == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return commonDAO.getProcessTraceCount(userSessionId, params);
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
			setFirstRowActive();
		} else if (activeProcessTrace != null && processTraceSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeProcessTrace.getModelId());
			processTraceSelection.setWrappedSelection(selection);
			activeProcessTrace = processTraceSelection.getSingleSelection();
		}
		return processTraceSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		processTraceSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeProcessTrace = (ProcessTrace) processTraceSource.getRowData();
		selection.addKey(activeProcessTrace.getModelId());
		processTraceSelection.setWrappedSelection(selection);
	}

	public void setItemSelection(SimpleSelection selection) {
		processTraceSelection.setWrappedSelection(selection);
		activeProcessTrace = processTraceSelection.getSingleSelection();
	}

	public void setFilters() {
		Filter paramFilter;
		filter = getFilter();
		filters = new ArrayList<Filter>();

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);


		if (filter.getTraceLevelFilter() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("traceLevel");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getTraceLevelFilter());
			filters.add(paramFilter);
		}

		if (filter.getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getObjectId().toString());
			filters.add(paramFilter);
		}

		if (filter.getEntityType() != null && !filter.getEntityType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}

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
		curLang = userLang;
	}

	public void fullCleanBean() {
		clearBean();
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		filter = new ProcessTrace();
		clearBean();
		searching = false;
	}

	public ProcessTrace getFilter() {
		if (filter == null)
			filter = new ProcessTrace();
		return filter;
	}

	public void setFilter(ProcessTrace filter) {
		this.filter = filter;
	}

	public List<SelectItem> getTraceLevels() {
		if (traceLevels == null) {
			traceLevels = getDictUtils().getLov(LovConstants.TRACE_LEVELS, null, Collections.singletonList(("code != 1")));
		}
		return traceLevels;
	}

	public List<SelectItem> getOracleTraceLevels() {
		if (oracleTraceLevels == null) {
			oracleTraceLevels = getDictUtils().getLov(LovConstants.ORACLE_TRACE_LEVELS, null, Collections.singletonList(("code != 1")));
		}
		return oracleTraceLevels;
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
			ExportUtils.exportXML(outStream, traceList, rootEle,
					traceAdapter, traceDTO, ProcessTraceDTO.class);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void exportXLS(final List<ProcessTrace> traceList) {
		final UserSession session = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
		final ExportUtils ex = new ExportUtils() {
			@Override
			public void createHeadRow() {
				Row rowhead = sheet.createRow((short) 0);
				rowhead.createCell(0).setCellValue("Trace timestamp");
				rowhead.createCell(1).setCellValue("Trace level");
				rowhead.createCell(2).setCellValue("Trace text");
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
				}
			}

		};

		try {
			ex.exportXLS(outStream);
		} catch (IOException e) {
			e.printStackTrace();
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
		return "trace." + exportFormat;
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
}
