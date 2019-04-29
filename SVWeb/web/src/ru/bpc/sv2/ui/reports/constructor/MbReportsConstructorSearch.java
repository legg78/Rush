package ru.bpc.sv2.ui.reports.constructor;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.reports.constructor.dto.ReportTemplateDto;
import ru.bpc.sv2.ui.reports.constructor.web.MbExportReport;
import ru.bpc.sv2.ui.reports.constructor.web.MbReportTemplateList;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.jtsoft.dynamicreports.db.PageRequest;
import ru.jtsoft.dynamicreports.db.PageRequest.Sort;
import ru.jtsoft.dynamicreports.report.ExportReportContext;
import ru.jtsoft.dynamicreports.report.ReportTemplate;
import ru.jtsoft.dynamicreports.report.ReportTemplateGeneric;
import ru.jtsoft.dynamicreports.report.ReportingEnvironment;
import ru.jtsoft.dynamicreports.report.dao.ReportTemplateDao;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ManagedProperty;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

@ViewScoped
@ManagedBean(name = "MbReportsConstructorSearch")
public class MbReportsConstructorSearch extends AbstractBean {
    private static final long serialVersionUID = 1L;
    private static Logger logger = Logger.getLogger("REPORTS");
    private static final String DETAILS_TAB = "detailsTab";

    private String tabName;
    @ManagedProperty("#{MbReportingEnvironment}")
    private ReportingEnvironment reportingEnvironment;
    @ManagedProperty("#{MbExportReport}")
    private MbExportReport mbExportReport;

    private ReportTemplateDto filter;
    private ReportTemplateDto activeItem;
    private ReportTemplateDto detailItem;
    private ReportTemplateDto cloneItem;
    private final TableRowSelection<ReportTemplateGenericWrapper> tableRowSelection;

    private DaoDataModel<ReportTemplateGenericWrapper> dataModel;

    private MbReportTemplateList reportTemplateList;

    private CommonDao _commonDao = new CommonDao();

    private String curLang;
    private String userLang;

    public MbReportsConstructorSearch() {
    	pageLink = "reports|constructor";
        
        tabName = DETAILS_TAB;

        curLang = userLang = SessionWrapper.getField("language");

        reportTemplateList = (MbReportTemplateList) ManagedBeanWrapper.getManagedBean("MbReportTemplateList");
        Locale.setDefault(new Locale(curLang.substring(4, 6).toLowerCase()));

        dataModel = new DaoDataModel<ReportTemplateGenericWrapper>() {
   
			private static final long serialVersionUID = -8709903188093977444L;

			@Override
            protected ReportTemplateGenericWrapper[] loadDaoData(SelectionParams params) {
            	
            	List<ReportTemplateGeneric> listRes = null;
                
            	if (searching) {
	                PageRequest pageRequest = buildPageRequest(params);
	            	try {
	            		String reportName = getReportNameFilterValue();
                        _commonDao.setUserContext(Long.valueOf(SessionWrapper.getField("userSessionId")),
                                FacesContext.getCurrentInstance().getExternalContext().getUserPrincipal().getName());
	                    listRes = (reportName == null) 
	                    		? getReportTemplateDao().find(pageRequest)
	                    		: getReportTemplateDao().findByNameLike(reportName, pageRequest);
	                } catch(Exception e) {
	                    FacesUtils.addMessageError(e);
	                    setDataSize(0);
	                    logger.error("", e);
	                } 
            	}
              
            	return wrapResults(listRes);
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                int result = 0;
                if(searching) {
                    try {
                    	String reportName = getReportNameFilterValue();
                        _commonDao.setUserContext(Long.valueOf(SessionWrapper.getField("userSessionId")),
                                FacesContext.getCurrentInstance().getExternalContext().getUserPrincipal().getName());
                        result =  (reportName == null) 
                        		? getReportTemplateDao().countAll()
                        		: getReportTemplateDao().countByNameLike(reportName);
                    } catch(Exception e) {
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return result;
            }
        };

        tableRowSelection = new TableRowSelection<ReportTemplateGenericWrapper>(null, dataModel);
    }

    public void exportReport(){
        mbExportReport.exportReport(activeItem.getId());
    }

    public void exportReportHtml(){
        mbExportReport.setReportFormat(ExportReportContext.ExportType.HTML);
        mbExportReport.exportReport(activeItem.getId());
    }

    public void exportReportPdf(){
        mbExportReport.setReportFormat(ExportReportContext.ExportType.PDF);
        mbExportReport.exportReport(activeItem.getId());
    }

    public void exportReportXls(){
        mbExportReport.setReportFormat(ExportReportContext.ExportType.XLS);
        mbExportReport.exportReport(activeItem.getId());
    }

    public void downloadFile() {
        try {
            mbExportReport.downloadFile();
        } catch (IOException e) {
            logger.error("Can't download file");
        }
    }

    public String create() {
        return "edit_report_template";
    }

    public String edit() {
        return "edit_report_template";
    }

    public void cloneReport() {
        try {
            cloneItem = activeItem.clone();
            cloneItem.setId(null);
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void saveCopy() {
        try {
            ReportTemplate savable = ReportTemplateDto.BACK_CONVERTER
                    .apply(cloneItem);
            getReportTemplateDao().persist(savable);
            clearState();
            curMode = VIEW_MODE;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void delete() {
        try {
            getReportTemplateDao().deleteReportTemplateById(activeItem.getId());
            ReportTemplateGenericWrapper removedWrapper = tableRowSelection.removeObjectFromList(activeItem.getWrapped());
            if(removedWrapper != null){
                activeItem = reportTemplateList.getReportTemplateById(removedWrapper.getId(), true, curLang);
            }
            if (activeItem == null) {
                clearBeansStates();
            } else {
                detailItem = (ReportTemplateDto) activeItem.clone();
            }
            clearState();
            curMode = VIEW_MODE;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public DaoDataModel<ReportTemplateGenericWrapper> getDataModel() {
        return dataModel;
    }

    public void search() {
        curMode = VIEW_MODE;
        clearState();
        clearBeansStates();
        searching = true;
    }

    public void clearFilter() {
        filter = null;
        searching = false;
        clearState();
    }

    public ReportTemplateDto getFilter() {
        if(filter == null) {
            filter = new ReportTemplateDto(userLang);
        }
        return filter;
    }

    public void changeLanguage(ValueChangeEvent event) {
        curLang = (String) event.getNewValue();
        detailItem = getNodeByLang(detailItem.getId(), curLang);

    }

    public ReportTemplateDto getNodeByLang(Long id, String lang) {
        Locale.setDefault(new Locale(curLang.substring(4, 6).toLowerCase()));
        detailItem = reportTemplateList.getReportTemplateById(id, true, curLang);
        return detailItem;
    }

    public void clearState() {
        tableRowSelection.clearSelection();
        activeItem = null;
        detailItem = null;
        dataModel.flushCache();
        curLang = userLang;
    }

    public void clearBeansStates() {
    }

    protected final ReportTemplateDao getReportTemplateDao() {
        return reportingEnvironment.getReportTemplateDao();
    }

    public ReportTemplateDto getActiveItem() {
        return activeItem;
    }

    public void setActiveItem(ReportTemplateDto activeItem) {
        this.activeItem = activeItem;
    }

    public ReportTemplateDto getCloneItem() {
        return cloneItem;
    }

    public void setCloneItem(ReportTemplateDto cloneItem) {
        this.cloneItem = cloneItem;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (activeItem == null && dataModel.getRowCount() > 0){
                prepareItemSelection();
            } else if (activeItem != null && dataModel.getRowCount() > 0){
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(activeItem.getModelId());
                tableRowSelection.setWrappedSelection(selection);
                ReportTemplateGenericWrapper wrapper = tableRowSelection.getSingleSelection();
                if(wrapper!=null)
                    activeItem = reportTemplateList.getReportTemplateById(tableRowSelection.getSingleSelection().getId(), true, curLang);
                else
                    activeItem = null;
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return tableRowSelection.getWrappedSelection();
    }

    public void prepareItemSelection() throws CloneNotSupportedException{
        dataModel.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        ReportTemplateGenericWrapper activeItemWrapper = (ReportTemplateGenericWrapper)dataModel.getRowData();
        activeItem = reportTemplateList.getReportTemplateById(activeItemWrapper.getId(), true, curLang);
        selection.addKey(activeItem.getModelId());
        tableRowSelection.setWrappedSelection(selection);
        if (activeItem != null) {
            detailItem = (ReportTemplateDto) activeItem.clone();
        }
    }

    public void setItemSelection(SimpleSelection selection) {
    	if (!searching) return;
    	try {
            tableRowSelection.setWrappedSelection(selection);
            boolean changeSelect = false;
            if (tableRowSelection.getSingleSelection() != null) {
                changeSelect = true;
                activeItem = reportTemplateList.getReportTemplateById(tableRowSelection.getSingleSelection().getId(), true, curLang);
            }
            if (activeItem != null) {
                if (changeSelect) {
                    detailItem = (ReportTemplateDto) activeItem.clone();
                }
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }


    public ReportTemplateDto getDetailItem() {
        return detailItem;
    }

    public void setDetailItem(ReportTemplateDto detailItem) {
        this.detailItem = detailItem;
    }

    public ReportingEnvironment getReportingEnvironment() {
        return reportingEnvironment;
    }

    public void setReportingEnvironment(ReportingEnvironment reportingEnvironment) {
        this.reportingEnvironment = reportingEnvironment;
    }

    public MbExportReport getMbExportReport() {
        return mbExportReport;
    }

    public void setMbExportReport(MbExportReport mbExportReport) {
        this.mbExportReport = mbExportReport;
    }

    public String getTabName() {
        return tabName;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
    }
    
    private PageRequest buildPageRequest(SelectionParams params) {
    	List<Sort> sorts = null;
    	if (params.getSortElement() == null || params.getSortElement().length == 0) {
    		sorts = Collections.<Sort>emptyList();
    	} else {
    		sorts = new ArrayList<PageRequest.Sort>(params.getSortElement().length);
    		for (SortElement e : params.getSortElement()) {
    			Sort sort = new Sort(e.getProperty(), e.getDirection() == Direction.ASC);
    			sorts.add(sort);
    		}
    	}
    	return new PageRequest(params.getRowIndexStart()+1, params.getRowIndexEnd()+1, sorts);
    }
    
    private String getReportNameFilterValue() {
    	return filter.getName();
    }
    
	private ReportTemplateGenericWrapper[] wrapResults(List<ReportTemplateGeneric> listRes) {
		ReportTemplateGenericWrapper[] result = null;
		if (listRes == null || listRes.isEmpty()) {
			result = new ReportTemplateGenericWrapper[0];
		} else {
			result = new ReportTemplateGenericWrapper[listRes.size()];
			int i = 0;
			for (ReportTemplateGeneric rpt : listRes) {
				result[i] = new ReportTemplateGenericWrapper(rpt.getId(),
						rpt.getName(), rpt.getDescription());
				i++;
			}
		}
		return result;
	}
}
