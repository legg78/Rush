package ru.bpc.sv2.ui.issuing;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.Report;
import ru.bpc.sv2.reports.ReportParameter;
import ru.bpc.sv2.reports.RptDocument;
import ru.bpc.sv2.ui.reports.ReportRunner;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbDocumentsViewing")
public class MbDocumentsViewing extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("REPORTS");

	private ReportsDao rptBean = new ReportsDao();

	private RptDocument filter;
	private Date filterDateFrom;
	private Date filterDateTo;
	private String filterDocumentNumberFrom;
	private String filterDocumentNumberTo;
	
	private RptDocument activeItem;

	private final DaoDataModel<RptDocument> dataModel;
	private final TableRowSelection<RptDocument> tableRowSelection;

	private List<SelectItem> documentTypes;

	private List<SelectItem> entityTypes;
	private Report showDocumentReport = null;
	private ReportRunner reportRunner;
	
	public MbDocumentsViewing() {
		logger.debug("MbDocumentsViewing construction...");
		pageLink = "issuing|documents";
		dataModel = new DaoDataModel<RptDocument>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected RptDocument[] loadDaoData(SelectionParams params) {
				RptDocument[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = rptBean.getPrintDocuments(userSessionId,
								params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = new RptDocument[0];
				}
				return result;
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = rptBean.getPrintDocumentsCount(userSessionId,
								params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = 0;
				}
				return result;
			}
		};
		tableRowSelection = new TableRowSelection<RptDocument>(null, dataModel);
		showDocumentReport = new Report();
		showDocumentReport.setId(10000034L);
		showDocumentReport.setSourceType(ReportConstants.REPORT_SOURCE_TYPE_XML);
		showDocumentReport.setLang(userLang);
		reportRunner = new ReportRunner(userSessionId);
		rowsNum = 50;
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		Filter f = null;
		if (filterDateFrom != null){
			f = new Filter("documentDateFrom", filterDateFrom);
			filters.add(f);
		}
		if (filterDateTo != null){
			f = new Filter("documentDateTo", filterDateTo);
			filters.add(f);
		}
		if (filterDocumentNumberFrom != null && filterDocumentNumberFrom.trim().length() > 0){
			f = new Filter("documentNumberFrom", filterDocumentNumberFrom);
			filters.add(f);
		}
		if (filterDocumentNumberTo != null && filterDocumentNumberTo.trim().length() > 0){
			f = new Filter("documentNumberTo", filterDocumentNumberTo);
			filters.add(f);
		}
		if (filter.getDocumentType() != null){
			f = new Filter("documentType", filter.getDocumentType());
			filters.add(f);
		}
		
		f = new Filter("lang", curLang);
		filters.add(f);
	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		dataModel.flushCache();
		curLang = userLang;
	}

	public void clearBeansStates() {

	}

	public void clearFilter() {
		filter = null;
		filterDocumentNumberFrom = null;
		filterDocumentNumberTo = null;
		filterDateFrom = null;
		filterDateTo = null;
		clearState();
		clearBeansStates();
		searching = false;
	}

	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0) {
			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}

	public void prepareItemSelection() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (RptDocument) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			setBeansState();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();
		if (activeItem != null) {
			setBeansState();
		}
	}

	private void setBeansState() {

	}

	public RptDocument getFilter() {
		if (filter == null) {
			filter = new RptDocument();
		}
		return filter;
	}

	public DaoDataModel<RptDocument> getDataModel() {
		return dataModel;
	}

	public RptDocument getActiveItem() {
		return activeItem;
	}

	public List<SelectItem> getDocumentTypes() {
		if (documentTypes == null) {
			documentTypes = getDictUtils().getLov(LovConstants.DOCUMENT_TYPES);
		}
		return documentTypes;
	}

	public Date getFilterDateFrom() {
		return filterDateFrom;
	}

	public void setFilterDateFrom(Date filterDateFrom) {
		this.filterDateFrom = filterDateFrom;
	}

	public Date getFilterDateTo() {
		return filterDateTo;
	}

	public void setFilterDateTo(Date filterDateTo) {
		this.filterDateTo = filterDateTo;
	}

	public String getFilterDocumentNumberTo() {
		return filterDocumentNumberTo;
	}

	public void setFilterDocumentNumberTo(String filterDocumentNumberTo) {
		this.filterDocumentNumberTo = filterDocumentNumberTo;
	}

	public String getFilterDocumentNumberFrom() {
		return filterDocumentNumberFrom;
	}

	public void setFilterDocumentNumberFrom(String filterDocumentNumberFrom) {
		this.filterDocumentNumberFrom = filterDocumentNumberFrom;
	}
	
	public void showReport(){
		ReportParameter objectId = new ReportParameter();
		objectId.setSystemName("I_OBJECT_ID");
		objectId.setValue(activeItem.getId());
		ReportParameter[] reportParameters = new ReportParameter[]{objectId};
		
		try {
			SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
			String date = sdf.format(activeItem.getDocumentDate());
			showDocumentReport.setName("document(" + activeItem.getDocumentNumber()+"_"+date+")");
			reportRunner.runReport(showDocumentReport, ReportConstants.REPORT_FORMAT_PDF, reportParameters, activeItem.getTemplateId());
		} catch (Exception e) {
			FacesUtils.addSystemError(e);
			logger.error("", e);
			return;
		}
		
		viewedReportName = reportRunner.getFilename();
		try {
			viewedReportName = URLEncoder.encode(viewedReportName, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			logger.error(e);
		}
		reportRunner.generateFileByServlet();
	}
	
	private String viewedReportName;
	
	public String getViewedReportName(){
		return viewedReportName;
	}

}
