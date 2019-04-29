package ru.bpc.sv2.ui.ps.visa.vssreports;

import org.apache.log4j.Logger;
import org.openfaces.component.table.*;
import org.openfaces.util.Faces;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.VisaDao;
import ru.bpc.sv2.ps.visa.AbstractVisaVssReportDetail;
import ru.bpc.sv2.ps.visa.VisaVssReport;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.FilterFactory;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.UIForm;
import javax.faces.component.visit.VisitCallback;
import javax.faces.component.visit.VisitContext;
import javax.faces.component.visit.VisitResult;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbVisaVssReports")
public class MbVisaVssReports extends AbstractSearchBean<VisaVssReport, VisaVssReport> {
	private static final long serialVersionUID = 1L;
	public static final String LOCALE_VIS = "ru.bpc.sv2.ui.bundles.Vis";
	private static Logger logger = Logger.getLogger("VIS");
	private VisaDao visaDao = new VisaDao();
	private VssReportProcessor reportProcessor;

	private UIForm treeTableForm;
	private TreeTable treeTable;

	private List<SelectItem> reportCodes;
	private List<SelectItem> frequencyList;

	private String frequency;
	private List<? extends AbstractVisaVssReportDetail<?>> reportDetail = new ArrayList<AbstractVisaVssReportDetail<?>>();
	private boolean singleReportMode = false;
	private boolean initAfterBindDone = false;

	@Override
	@PostConstruct
	public void init() {
		super.init();
		initReportCodes();
		initFrequencyList();
		reportProcessor = new VssReportProcessor(visaDao);
		String reportIdStr = FacesContext.getCurrentInstance().getExternalContext().getRequestParameterMap().get("reportId");
		if (reportIdStr != null) {
			singleReportMode = true;
			getFilter().setId(Long.parseLong(reportIdStr));
			search();
			SelectionParams selectionParams = new SelectionParams();
			selectionParams.setRowIndexStart(0);
			selectionParams.setRowIndexEnd(1);
			List<VisaVssReport> reports = getDataModel().loadData(selectionParams);
			if (!reports.isEmpty()) {
				setActiveItem(reports.get(0));
			}
		}
	}

	private void initAfterBind() {
		if (treeTableForm != null && !initAfterBindDone) {
			if (getActiveItem() != null && (reportDetail == null || reportDetail.isEmpty()))
				onItemSelected(getActiveItem());
			initAfterBindDone = true;
		}
	}

	@Override
	protected VisaVssReport createFilter() {
		return new VisaVssReport();
	}

	@Override
	protected void initFilters(VisaVssReport filter, List<Filter> filters) {
		filters.addAll(FilterBuilder.createFiltersAsString(filter));
		if (getFrequency() != null)
			filters.add(new Filter("frequency", frequency));
	}

	@Override
	public void clearState() {
		super.clearState();
		reportDetail = Collections.emptyList();
	}

	@Override
	protected List<VisaVssReport> getObjectList(Long userSessionId, SelectionParams params) {
		List<VisaVssReport> result = visaDao.getVisaVssReports(userSessionId, params);
		for (VisaVssReport report : result)
			report.setReportTitle(FacesUtils.getMessage(LOCALE_VIS, report.getReportCode().toLowerCase()));
		return result;
	}

	@Override
	protected int getObjectCount(Long userSessionId, SelectionParams params) {
		return visaDao.getVisaVssReportsCount(userSessionId, params);
	}

	@Override
	protected void onItemSelected(VisaVssReport activeItem) {
		super.onItemSelected(activeItem);
		treeTable = getTreeTable();
		if (treeTable != null) {
			try {
				reportDetail = reportProcessor.buildTree(activeItem);
			} catch (Throwable e) {
				logger.error(e.getMessage(), e);
				FacesUtils.addMessageError(new RuntimeException(e.getMessage(), e));
				reportDetail = Collections.emptyList();
				return;
			}
			treeTable.setExpansionState(new DynamicNodeExpansionState(new SeveralLevelsExpanded(1)));
		} else
			reportDetail = Collections.emptyList();
	}

	private AbstractVisaVssReportDetail<?> getReportDataItem() {
		return (AbstractVisaVssReportDetail<?>) Faces.var("reportDataItem");
	}

	public List<? extends AbstractVisaVssReportDetail<?>> getNodeChildren() {
		initAfterBind();
		AbstractVisaVssReportDetail<?> item = getReportDataItem();
		if (item == null)
			return reportDetail;
		else
			return item.getChildren();
	}

	public boolean getNodeHasChildren() {
		return getReportDataItem() != null && getReportDataItem().isHasChildren();
	}

	public void expandAll() {
		expandCollapseAll(true);
	}

	public void collapseAll() {
		expandCollapseAll(false);
	}

	public void expandCollapseAll(boolean expanded) {
		if (treeTable != null) {
			ExpansionState state = treeTable.getExpansionState();
			Long itemId = new Long(FacesContext.getCurrentInstance().getExternalContext().getRequestParameterMap().get("reportDataItemId"));
			AbstractVisaVssReportDetail<?> node = reportDetail.get(reportDetail.indexOf(findNode(itemId, null)) + 1);
			expandCollapseSubtree(state, node, expanded);
			state.setNodeExpanded(getTreePath(node), true);
		}
	}

	public TreePath getTreePath(AbstractVisaVssReportDetail<?> node) {
		return new TreePath(node.getId(), node.getParent() != null ? getTreePath(node.getParent()) : null);
	}

	public void expandCollapseSubtree(ExpansionState state, AbstractVisaVssReportDetail<?> parent, boolean expanded) {
		state.setNodeExpanded(getTreePath(parent), expanded);
		for (AbstractVisaVssReportDetail<?> child : parent.getChildren()) {
			expandCollapseSubtree(state, child, expanded);
		}
	}

	private AbstractVisaVssReportDetail<?> findNode(Long id, AbstractVisaVssReportDetail<?> parent) {
		List<? extends AbstractVisaVssReportDetail<?>> children;
		if (parent == null) {
			children = reportDetail;
		} else {
			if (parent.getId().equals(id))
				return parent;
			children = parent.getChildren();
		}
		for (AbstractVisaVssReportDetail<?> rep : children) {
			if (rep.getId().equals(id))
				return rep;
			AbstractVisaVssReportDetail<?> nested = findNode(id, rep);
			if (nested != null)
				return nested;
		}
		return null;
	}

	private TreeTable getTreeTable() {
		final TreeTable[] searchResult = new TreeTable[]{null};
		final String idToFind = "reportDataTable" + getActiveItem().getReportIdNum();
		treeTableForm.visitTree(VisitContext.createVisitContext(FacesContext.getCurrentInstance()), new VisitCallback() {
			@Override
			public VisitResult visit(VisitContext context, UIComponent target) {
				if (target instanceof TreeTable) {
					if (target.getId().equals(idToFind)) {
						searchResult[0] = (TreeTable) target;
						return VisitResult.COMPLETE;
					} else
						return VisitResult.REJECT;
				}
				return VisitResult.ACCEPT;
			}
		});
		return searchResult[0];
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	protected VisaVssReport addItem(VisaVssReport item) {
		return null;
	}

	@Override
	protected VisaVssReport editItem(VisaVssReport item) {
		return null;
	}

	@Override
	protected void deleteItem(VisaVssReport item) {

	}

	public List<SelectItem> getReportCodes() {
		return reportCodes;
	}

	public List<SelectItem> getFrequencyList() {
		return frequencyList;
	}

	public String getFrequency() {
		return frequency;
	}

	public void setFrequency(String frequency) {
		this.frequency = frequency;
	}

	public UIForm getTreeTableForm() {
		return treeTableForm;
	}

	public void setTreeTableForm(UIForm treeTableForm) {
		this.treeTableForm = treeTableForm;
	}

	public boolean isSingleReportMode() {
		return singleReportMode;
	}

	private void initReportCodes() {
		reportCodes = new ArrayList<SelectItem>();
		reportCodes.add(new SelectItem(null, ""));
		reportCodes.add(new SelectItem("110", "VSS-110"));
		reportCodes.add(new SelectItem("120", "VSS-120"));
		reportCodes.add(new SelectItem("130", "VSS-130"));
		reportCodes.add(new SelectItem("140", "VSS-140"));
		reportCodes.add(new SelectItem("900", "VSS-900"));
	}

	private void initFrequencyList() {
		frequencyList = new ArrayList<SelectItem>();
		frequencyList.add(new SelectItem(null, ""));
		frequencyList.add(new SelectItem("D", FacesUtils.getMessage(LOCALE_VIS, "daily")));
		frequencyList.add(new SelectItem("M", FacesUtils.getMessage(LOCALE_VIS, "monthly")));
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				if (filterRec.get("id") != null) {
					getFilter().setId(Long.parseLong(filterRec.get("id")));
				}
				if (filterRec.get("reportIdNum") != null) {
					getFilter().setReportIdNum(filterRec.get("reportIdNum"));
				}
				if (filterRec.get("sreName") != null) {
					getFilter().setSreName(filterRec.get("sreName"));
				}
				String dbDateFormat = "dd.MM.yyyy";
				SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
				if (filterRec.get("reportDate") != null) {
					getFilter().setReportDate(df.parse(filterRec.get("reportDate")));
				}
				if (filterRec.get("settlementDate") != null) {
					getFilter().setSettlementDate(df.parse(filterRec.get("settlementDate")));
				}
				if (filterRec.get("changeDate") != null) {
					getFilter().setChangeDate(df.parse(filterRec.get("changeDate")));
				}
				if (filterRec.get("dstBin") != null) {
					getFilter().setDstBin(filterRec.get("dstBin"));
				}
				if (filterRec.get("frequency") != null) {
					setFrequency(filterRec.get("frequency"));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			if (getFilter().getId() != null) {
				filterRec.put("id", getFilter().getId().toString());
			}
			if (getFilter().getReportIdNum() != null) {
				filterRec.put("reportIdNum", getFilter().getReportIdNum());
			}
			if (getFilter().getSreName() != null) {
				filterRec.put("sreName", getFilter().getSreName());
			}
			String dbDateFormat = "dd.MM.yyyy";
			SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
			if (getFilter().getReportDate() != null) {
				filterRec.put("reportDate", df.format(getFilter().getReportDate()));
			}
			if (getFilter().getSettlementDate() != null) {
				filterRec.put("settlementDate", df.format(getFilter().getSettlementDate()));
			}
			if (getFilter().getChangeDate() != null) {
				filterRec.put("changeDate", df.format(getFilter().getChangeDate()));
			}
			if (getFilter().getDstBin() != null) {
				filterRec.put("dstBin", getFilter().getDstBin());
			}
			if (getFrequency() != null) {
				filterRec.put("frequency", getFrequency());
			}
			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
}
