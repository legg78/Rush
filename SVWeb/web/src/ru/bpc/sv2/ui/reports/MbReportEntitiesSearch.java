package ru.bpc.sv2.ui.reports;

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

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.reports.ReportEntity;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbReportEntitiesSearch")
public class MbReportEntitiesSearch extends AbstractBean{
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger("REPORTS");

	private final DaoDataModel<ReportEntity> _reportEntitiesSource;
	
	private final TableRowSelection<ReportEntity> _itemSelection;
	
	private ReportEntity activeItem;
	private ReportEntity editingItem;
	
	private List<SelectItem> entityTypes = null;
	private List<SelectItem> objectTypes = null;
	private static String COMPONENT_ID = "entitiesTable";
	private String tabName;
	private String parentSectionId;
	private boolean customObjectType;
	
	private ReportsDao _reportsDao = new ReportsDao();

	
	public MbReportEntitiesSearch() {
		_reportEntitiesSource = new DaoDataModel<ReportEntity>() {
			@Override
			protected ReportEntity[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ReportEntity[0];
				}
				try {
					setFilters();
					params.setFilters(filters
							.toArray(new Filter[filters.size()]));
					return _reportsDao.getReportObject(userSessionId, params);
					
					//return _reportsDao
					//		.getReportTemplates(userSessionId, params);
					//return new ReportEntity[0];
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new ReportEntity[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters
							.toArray(new Filter[filters.size()]));
					return _reportsDao.getReportObjectCount(userSessionId,params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ReportEntity>(null,
				_reportEntitiesSource);
	}
	
	public DaoDataModel<ReportEntity> getReportEntities() {
		return _reportEntitiesSource;
	}
	
	public ReportEntity getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(ReportEntity activeItem) {
		this.activeItem = activeItem;
	}
	
	public SimpleSelection getItemSelection() {
		if (activeItem == null
				&& _reportEntitiesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (activeItem != null
				&& _reportEntitiesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			_itemSelection.setWrappedSelection(selection);
			activeItem = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}
	
	public void setFirstRowActive() {
		_reportEntitiesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (ReportEntity) _reportEntitiesSource.getRowData();
		selection.addKey(activeItem.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			//setInfo();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		activeItem = _itemSelection.getSingleSelection();
		if (activeItem != null) {
			//setInfo();
		}
	}
	
	public void setInfo() {

	}
	
	public void clearFilter() {

	}

	private void setFilters() {
		params = getFilterMap();
		filters = new ArrayList<Filter>();
		
		Filter paramFilter;
		if (params.containsKey("reportId")){
			paramFilter = new Filter();
			paramFilter.setElement("reportId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(params.get("reportId").toString());
			filters.add(paramFilter);
		}
	}
	
	public void search() {
		clearState();
		searching = true;
	}
	
	public void clearState() {
		_itemSelection.clearSelection();
		activeItem = null;
		_reportEntitiesSource.flushCache();
	}
	
	public Map<String, Object> getFilterMap() {
		if(params == null)
			setFilterMap(new HashMap<String,Object>());
		return this.params;
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
	
	public void add(){
		editingItem = new ReportEntity();
		editingItem.setReportId((Integer)getFilterMap().get("reportId"));
		onEntityTypeChanged();
		curMode = NEW_MODE;
	}
	
	public ReportEntity getEditingItem(){
		return editingItem;
	}
		
	public void delete() {
		try {
			_reportsDao.removeReportObject(userSessionId,
					activeItem);
			_itemSelection.clearSelection();
			_reportEntitiesSource.flushCache();
			activeItem = null;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void edit() {
		editingItem = activeItem;
		onEntityTypeChanged();
		curMode = EDIT_MODE;
	}
	
	public void save() {
		try {
			if (isNewMode()) {
				editingItem = _reportsDao.addReportObject(userSessionId, editingItem);
			} else if (isEditMode()){
				editingItem = _reportsDao.modifyReportObject(userSessionId, editingItem);
			}
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
			return;
		}
		
		
		if (isNewMode()) {
			_itemSelection.addNewObjectToList(editingItem);
		} else {
			try {
				_reportEntitiesSource.replaceObject(activeItem, editingItem);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		activeItem = editingItem;
		cancel();		
		search();
	}
	
	public void cancel() {
		editingItem=null;
		curMode = VIEW_MODE;
	}
	
	public List<SelectItem> getEntityTypes() {
		if (entityTypes == null) {
			entityTypes=getDictUtils().getArticles(DictNames.BUSINESS_ENTITIES, false, true);
			
			onEntityTypeChanged();
		}
		return entityTypes;
	}
	
	public void onEntityTypeChanged(){
		objectTypes = new ArrayList<SelectItem>();
		customObjectType=true;
		
		if (editingItem==null) return;
		if (editingItem.getEntityType()==null) return;
		
		if (editingItem.getEntityType().equals("ENTTSSFL")){
			objectTypes=(ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.FILE_TYPES);
			customObjectType=false;
		}else if (editingItem.getEntityType().equals("ENTTACCT")){
			objectTypes=(ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.ACCOUNT_TYPES_ALL);
			customObjectType=false;
		}else if (editingItem.getEntityType().equals("ENTTCARD")){
			objectTypes=(ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CARD_TYPES);
			customObjectType=false;
		}
	}
		
	
	public List<SelectItem> getObjectTypes(){
		return objectTypes;
	}

	public boolean isCustomObjectType() {
		return customObjectType;
	}

	public void setCustomObjectType(boolean customObjectType) {
		this.customObjectType = customObjectType;
	}
}
