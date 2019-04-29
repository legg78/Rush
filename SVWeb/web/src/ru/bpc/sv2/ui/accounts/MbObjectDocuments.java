package ru.bpc.sv2.ui.accounts;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.acm.AcmAction;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.reports.ReportParameter;
import ru.bpc.sv2.reports.RptDocument;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbObjectDocuments")
public class MbObjectDocuments extends AbstractBean {
	private static final long serialVersionUID = 6432573698216334797L;

	private static final Logger logger = Logger.getLogger("RPT");

	private ReportsDao reportsDao = new ReportsDao();

	private RptDocument filter;

	private RptDocument activeItem;
	
	private List<SelectItem> documentTypes;

	private final DaoDataModel<RptDocument> dataModel;
	private final TableRowSelection<RptDocument> tableRowSelection;

	private String backLink;
	private AcmAction selectedCtxItem;
	
	private static String COMPONENT_ID = "documentsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbObjectDocuments() {
		dataModel = new DaoDataModel<RptDocument>() {
			@Override
			protected RptDocument[] loadDaoData(SelectionParams params) {
				RptDocument[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = reportsDao.getDocuments(userSessionId, params);
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
						result = reportsDao.getDocumentsCount(userSessionId, params);
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
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		filters.add(new Filter("lang", curLang));
		if (filter.getObjectId() != null)
			filters.add(new Filter("objectId", filter.getObjectId()));
		if (filter.getEntityType() != null)
			filters.add(new Filter("entityType", filter.getEntityType()));
		if (filter.getDocumentType() != null) {
			filters.add(new Filter("documentType", filter.getDocumentType()));
		}
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
	
	public void setFilter(RptDocument filter){
		this.filter = filter;
	}

	public DaoDataModel<RptDocument> getDataModel() {
		return dataModel;
	}

	public RptDocument getActiveItem() {
		return activeItem;
	}

	public void initCtxParams() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");

		selectedCtxItem = ctxBean.getSelectedCtxItem();
		Map<String, ReportParameter> params = new HashMap<String, ReportParameter>();

		FacesUtils.setSessionMapValue("entityType", EntityNames.IDENTIFICATOR);
		ctxBean.initCtxParams(EntityNames.IDENTIFICATOR, activeItem.getId(), true);
		FacesUtils.setSessionMapValue("objectId", activeItem.getId());
		params.put("I_OBJECT_ID", new ReportParameter("I_OBJECT_ID", DataTypes.NUMBER,
				new BigDecimal(activeItem.getId())));

		FacesUtils.setSessionMapValue("reportParams", params);
	}

	public String ctxPageForward() {
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
		FacesUtils.setSessionMapValue("backLink", backLink);
		saveState();

		return selectedCtxItem.getAction();
	}

	public void initCtxMenu() {
		if (activeItem == null) {
			return;
		}
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setEntityType(EntityNames.DOCUMENT);
		ctxBean.setObjectType(activeItem.getDocumentType());
	}

	public void saveState() {
		FacesUtils.setSessionMapValue("activeDocumentFor" + filter.getEntityType(), activeItem);
	}

	public void restoreState() {
		activeItem = (RptDocument) FacesUtils.extractSessionMapValue("activeDocumentFor" + filter.getEntityType());
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}
	
	public List<SelectItem> getDocumentTypes() {
		if (documentTypes == null) {
			documentTypes = getDictUtils().getLov(LovConstants.DOCUMENT_TYPES);
		}
		return documentTypes;
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
