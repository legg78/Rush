package ru.bpc.sv2.ui.reports;

import org.openfaces.component.table.TreePath;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.reports.Report;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.RequestContextHolder;
import ru.bpc.sv2.utils.SystemUtils;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.Serializable;

@SessionScoped
@ManagedBean (name = "MbReports")
public class MbReports implements Serializable {

	private static final long serialVersionUID = 1L;
	
	private Report activeReport;
	private boolean searching;
	private Report filter;
	private String activeTabName;
	private TreePath activeReportTreePath;
	transient private File outFile;
	private String reportFormat;
	private String fileName;
	private Integer tagIdFilter;

	public Report getActiveReport() {
		return activeReport;
	}

	public void setActiveReport(Report activeReport) {
		this.activeReport = activeReport;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public Report getFilter() {
		return filter;
	}

	public void setFilter(Report filter) {
		this.filter = filter;
	}

	public String getActiveTabName() {
		return activeTabName;
	}

	public void setActiveTabName(String activeTabName) {
		this.activeTabName = activeTabName;
	}

	public TreePath getActiveReportTreePath() {
		return activeReportTreePath;
	}

	public void setActiveReportTreePath(TreePath activeReportTreePath) {
		this.activeReportTreePath = activeReportTreePath;
	}

	public void setOutFile(File outFile) {
		this.outFile = outFile;
	}

	public String getReportFormat() {
		return reportFormat;
	}

	public void setReportFormat(String reportFormat) {
		this.reportFormat = reportFormat;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}
	
	public void generateFile() {
		try {
			if (outFile != null) {
				HttpServletResponse res = RequestContextHolder.getResponse();
				if (ReportConstants.REPORT_FORMAT_HTML.equals(reportFormat)) {
					res.setContentType("text/html");
				} else {
					res.setContentType("application/x-download");
					res.setHeader("Content-Disposition", "attachment; filename=" + fileName);
				}
				SystemUtils.copy(outFile, res.getOutputStream());
				FacesContext.getCurrentInstance().responseComplete();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
	}
	
	public void clearReportData() {
		outFile = null;
		reportFormat = null;
		fileName = null;		
	}
	
	public void flush() {
		activeReport = null;
		searching = false;
		filter = null;
		activeTabName = null;
		activeReportTreePath = null;
		clearReportData();
	}

	public Integer getTagIdFilter() {
		return tagIdFilter;
	}

	public void setTagIdFilter(Integer tagIdFilter) {
		this.tagIdFilter = tagIdFilter;
	}
}
