package ru.bpc.sv2.ui.ps.mastercard.messages;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MastercardDao;
import ru.bpc.sv2.ps.mastercard.McwRejectCode;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbMcwRejectCodeSearchBottom")
public class MbMcwRejectCodeSearchBottom extends AbstractBean {
	private static final Logger logger = Logger.getLogger("MCW");
	
	private MastercardDao mcwDao = new MastercardDao();
	
	private McwRejectCode filter;
	
	private McwRejectCode activeItem;
	private String tabName;
    private String parentSectionId;
    private static String COMPONENT_ID = "rejectCodeTable";
    
	private transient final DaoDataModel<McwRejectCode> dataModel;
	private final TableRowSelection<McwRejectCode> tableRowSelection;

	public MbMcwRejectCodeSearchBottom(){
		dataModel = new DaoDataListModel<McwRejectCode>(logger){
			@Override
			protected List<McwRejectCode> loadDaoListData(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setFilters(filters);
					return mcwDao.getMcwRejectCodes(userSessionId, params);
				}
				return new ArrayList<McwRejectCode>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setFilters(filters);
					return mcwDao.getMcwRejectCodesCount(userSessionId, params);
				}
				return 0;
			}
		};
		tableRowSelection = new TableRowSelection<McwRejectCode>(null, dataModel);
	}
	
	public boolean isSearching() {
		return searching && (getFilter().getRejectId() != null || 
							(params != null && params.containsKey("rejectId")));
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		filters.add(new Filter("lang",userLang));
		
		if (params != null) {
			setFiltersFromMap();
			return; 
		}
		if (getFilter().getRejectId() != null) {
			filters.add(new Filter("rejectId", getFilter().getRejectId()));
		}
	}
	
	private void setFiltersFromMap() {
		filters.add(new Filter("lang", userLang));
        Long param = (Long)params.get("rejectId");
        if (param != null) {
        	filters.add(new Filter("rejectId", param));
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
	
	public void clearBeansStates(){
		
	}
	
	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		searching = false;
	}
	
	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0){
			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}
	
	public void prepareItemSelection(){
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (McwRejectCode)dataModel.getRowData();
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
	
	private void setBeansState(){
	
	}
	
	public McwRejectCode getFilter() {
		if (filter == null) {
			filter = new McwRejectCode();
		}
		return filter;
	}
	
	public DaoDataModel<McwRejectCode> getRejectCodes(){
		return dataModel;
	}
	
	public McwRejectCode getActiveItem(){
		return activeItem;
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
