package ru.bpc.sv2.ui.reports.constructor.web;

import java.io.Serializable;
import java.util.List;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.richfaces.model.DataProvider;
import org.richfaces.model.ExtendedTableDataModel;
import org.richfaces.model.selection.Selection;

import ru.bpc.sv2.ui.reports.constructor.dto.ReportTemplateDto;
import ru.bpc.sv2.ui.reports.constructor.support.MbReportingEnvironmentSupport;
import ru.bpc.sv2.ui.reports.constructor.support.SortableTableDataModel;
import ru.jtsoft.dynamicreports.report.ReportTemplateGeneric;

@ManagedBean(name="MbReportTemplateList")
@ViewScoped
public final class MbReportTemplateList extends MbReportingEnvironmentSupport implements
		Serializable {
	private static final long serialVersionUID = 8110746535853709335L;

	private String searchName;

	private transient Selection selection;
	private transient SortableTableDataModel<ReportTemplateGeneric> dataModel;
	private transient ReportTemplateDto selectedReportTemplate;
	private int scrollerPage = 1;

	public String getSearchName() {
		return searchName;
	}

	public void setSearchName(String searchName) {
		this.searchName = searchName;
	}

	public ReportTemplateDto getSelectedReportTemplate() {
		return selectedReportTemplate;
	}

	public Selection getSelection() {
		return selection;
	}

	public void setSelection(Selection selection) {
		this.selection = selection;
	}

	private boolean isSearchingAll() {
		return null == searchName || searchName.isEmpty();
	}

	public ExtendedTableDataModel<ReportTemplateGeneric> getDataModel() {
		return dataModel;
	}

	public int getScrollerPage() {
		return scrollerPage;
	}

	public void setScrollerPage(int scrollerPage) {
		this.scrollerPage = scrollerPage;
		search();
	}

	public void search() {
		selectedReportTemplate = null;
		dataModel.reset();
	}

	public String export() {
		return "export_report";
	}

	public String create() {
		return "edit_report_template";
	}

	public String edit() {
		return "edit_report_template";
	}

	public void remove() {
		getReportTemplateDao().deleteReportTemplateById(
				selectedReportTemplate.getId());
		selectedReportTemplate = null;
		search();
	}

	@Override
	protected void init() {
		dataModel = new SortableTableDataModel<ReportTemplateGeneric>(
				new DataProvider<ReportTemplateGeneric>() {
					private static final long serialVersionUID = -8767304610936267687L;

					public ReportTemplateGeneric getItemByKey(Object key) {
						return null; // using wrapped data
					}

					public List<ReportTemplateGeneric> getItemsByRange(
							int firstRow, int endRow) {
						List<ReportTemplateGeneric> result;
						if (isSearchingAll()) {
							result = getReportTemplateDao().find(
									dataModel.getPageRequest(firstRow,
											endRow));
						} else {
							result = getReportTemplateDao().findByNameLike(
									searchName,
									dataModel.getPageRequest(firstRow,
											endRow));
						}

						return result;
					}

					public Object getKey(ReportTemplateGeneric item) {
						return item.getId();
					}

					public int getRowCount() {
						int result;
						if (isSearchingAll()) {
							result = getReportTemplateDao().countAll();
						} else {
							result = getReportTemplateDao()
									.countByNameLike(searchName);
						}
						return result;
					}
				});
	}
}
