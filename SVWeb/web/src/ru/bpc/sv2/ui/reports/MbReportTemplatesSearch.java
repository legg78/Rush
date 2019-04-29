package ru.bpc.sv2.ui.reports;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.richfaces.event.UploadEvent;
import org.richfaces.model.UploadItem;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.ReportTemplate;
import ru.bpc.sv2.system.TemplateCompiler;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbReportTemplatesSearch")
public class MbReportTemplatesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("REPORTS");

	private ReportsDao reportsDao = new ReportsDao();

	private int uploadsAvailable;
	private ReportTemplate filter;
	private ReportTemplate activeReportTemplate;
	private ReportTemplate newReportTemplate;
	private boolean templateUploaded;

	private final DaoDataModel<ReportTemplate> reportTemplatesSource;

	private final TableRowSelection<ReportTemplate> itemSelection;

	private String oldLang;

	private static final String COMPONENT_ID = "templatesTable";
	private String tabName;
	private String parentSectionId;
	private List<SelectItem> templateProcessors;
	private List<SelectItem> templateFormats;

	public MbReportTemplatesSearch() {
		reportTemplatesSource = new DaoDataModel<ReportTemplate>() {
			@Override
			protected ReportTemplate[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ReportTemplate[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return reportsDao.getReportTemplates(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new ReportTemplate[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return reportsDao.getReportTemplatesCount(userSessionId,params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		itemSelection = new TableRowSelection<ReportTemplate>(null, reportTemplatesSource);
		templateProcessors = getDictUtils().getLov(LovConstants.REPORT_TEMPLATE_PROCESSORS);
		templateFormats = getDictUtils().getLov(LovConstants.REPORT_TEMPLATE_FORMATS);
	}

	public DaoDataModel<ReportTemplate> getReportTemplates() {
		return reportTemplatesSource;
	}

	public ReportTemplate getActiveReportTemplate() {
		return activeReportTemplate;
	}

	public void setActiveReportTemplate(ReportTemplate activeReportTemplate) {
		this.activeReportTemplate = activeReportTemplate;
	}

	public SimpleSelection getItemSelection() {
		if (activeReportTemplate == null
				&& reportTemplatesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (activeReportTemplate != null
				&& reportTemplatesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeReportTemplate.getModelId());
			itemSelection.setWrappedSelection(selection);
			activeReportTemplate = itemSelection.getSingleSelection();
		}
		return itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		reportTemplatesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeReportTemplate = (ReportTemplate) reportTemplatesSource.getRowData();
		selection.addKey(activeReportTemplate.getModelId());
		itemSelection.setWrappedSelection(selection);
		if (activeReportTemplate != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeReportTemplate = itemSelection.getSingleSelection();
		if (activeReportTemplate != null) {
			setInfo();
		}
	}

	public void setInfo() {

	}

	public void clearBeansStates() {

	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new ReportTemplate();
		clearState();
		searching = false;
	}

	public ReportTemplate getFilter() {
		if (filter == null)
			filter = new ReportTemplate();
		return filter;
	}

	public void setFilter(ReportTemplate filter) {
		this.filter = filter;
	}

	private void setFilters() {

		Filter paramFilter;
		filter = getFilter();
		filters = new ArrayList<Filter>();

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getReportId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("reportId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getReportId().toString());
			filters.add(paramFilter);
		}

		if (filter.getTemplateLang() != null
				&& !filter.getTemplateLang().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("templateLang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getTemplateLang());
			filters.add(paramFilter);
		}

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getDescription() != null&& filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void add() {
		uploadsAvailable = 1;
		newReportTemplate = new ReportTemplate();
		newReportTemplate.setReportId(getFilter().getReportId());
		newReportTemplate.setLang(userLang);
		curMode = NEW_MODE;
		templateUploaded = false;
	}

	public void edit() {
		try {
			newReportTemplate = activeReportTemplate.clone();
			templateUploaded = newReportTemplate.getText() != null;
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newReportTemplate = activeReportTemplate;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		if (isNewMode() && newReportTemplate.getText() == null) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Rpt", "template_file_needed")));
			return;
		}
		try {
			newReportTemplate = getNewReportTemplate();
			if (newReportTemplate.isProcessorJasper()) {
				compileJasperReportTemplate(newReportTemplate);
			}
			if (isNewMode()) {
				newReportTemplate = reportsDao.addReportTemplate(userSessionId, newReportTemplate);
				itemSelection.addNewObjectToList(newReportTemplate);
			} else if (isEditMode()) {
				newReportTemplate = reportsDao.modifyReportTemplate(userSessionId, newReportTemplate);
				reportTemplatesSource.replaceObject(activeReportTemplate,newReportTemplate);
			}

			activeReportTemplate = newReportTemplate;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void compileJasperReportTemplate(ReportTemplate report) throws Exception {
		try {
			new TemplateCompiler().compile(report);
		} catch (Exception e) {
			FacesUtils.addMessageError("Report compilation error:"+e.getMessage());
		}
	}

	public void recompile() {
		try {
			ReportTemplate activeReport = getActiveReportTemplate();
			if (activeReport.getText() == null) {
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rpt", "template_file_needed")));
				return;
			}
			compileJasperReportTemplate(activeReport);
			reportsDao.modifyReportTemplate(userSessionId, activeReport);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			reportsDao.removeReportTemplate(userSessionId, activeReportTemplate);
			itemSelection.clearSelection();
			reportTemplatesSource.flushCache();
			activeReportTemplate = null;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ReportTemplate getNewReportTemplate() {
		if (newReportTemplate == null) {
			newReportTemplate = new ReportTemplate();
		}
		return newReportTemplate;
	}

	public void setNewReportTemplate(ReportTemplate newReportTemplate) {
		this.newReportTemplate = newReportTemplate;
	}

	public void clearState() {
		itemSelection.clearSelection();
		activeReportTemplate = null;
		reportTemplatesSource.flushCache();
		curLang = userLang;
	}

	public List<SelectItem> getProcessors() {
		return templateProcessors;
	}

	public List<SelectItem> getFormats() {
		if (newReportTemplate != null && newReportTemplate.isProcessorXslt()) {
			List<SelectItem> items = new ArrayList<SelectItem>(1);
			items.add(new SelectItem(ReportConstants.REPORT_FORMAT_HTML, getDictUtils()
					.getAllArticlesDesc().get(ReportConstants.REPORT_FORMAT_HTML)));
			items.add(new SelectItem(ReportConstants.REPORT_FORMAT_TEXT, getDictUtils()
					.getAllArticlesDesc().get(ReportConstants.REPORT_FORMAT_TEXT)));
			return items;
		}
		return templateFormats;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		reportTemplatesSource.flushCache();
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newReportTemplate.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newReportTemplate.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ReportTemplate[] templates = reportsDao.getReportTemplates(userSessionId, params);
			if (templates != null && templates.length > 0) {
				newReportTemplate.setName(templates[0].getName());
				newReportTemplate.setDescription(templates[0].getDescription());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancelEditLanguage() {
		newReportTemplate.setLang(oldLang);
	}

	public void fileUploadListener(UploadEvent event) throws Exception {
		UploadItem item = event.getUploadItem();
		if (!checkMaximumFileSize(item.getFileSize())) {
			FacesUtils.addMessageError("File size is too big");
			logger.error("File size is too big");
		}
		try {
			FileInputStream fis = new FileInputStream(item.getFile());
			String str;
			int len;
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			byte[] buf = new byte[1024];
			while ((len = fis.read(buf)) > 0) {
				baos.write(buf, 0, len);
			}
			baos.flush();
			str = new String(baos.toByteArray(), "UTF-8");
			Matcher junkMatcher = (Pattern.compile("^([\\W]+)<")).matcher(str.trim());
			str = junkMatcher.replaceFirst("<");
			newReportTemplate.setText(str);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void clearUpload() {
		uploadsAvailable = 1;
		templateUploaded = false;
	}

	public void setUpload() {
		templateUploaded = true;
	}

	@SuppressWarnings("unused")
	public int getUploadsAvailable() {
		return uploadsAvailable;
	}

	@SuppressWarnings("unused")
	public void setUploadsAvailable(int uploadsAvailable) {
		this.uploadsAvailable = uploadsAvailable;
	}

	public boolean isTemplateUploaded() {
		return templateUploaded;
	}

	public void setTemplateUploaded(boolean templateUploaded) {
		this.templateUploaded = templateUploaded;
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
