package ru.bpc.sv2.ui.ps.mastercard.messages;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MastercardDao;
import ru.bpc.sv2.ps.mastercard.McwReject;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbMcwRejectSearchBottom")
public class MbMcwRejectSearchBottom extends AbstractBean {
	private static final Logger logger = Logger.getLogger("MCW");
    private static String COMPONENT_ID = "mcwRejectTable";
    private String parentSectionId;

	private MastercardDao mcwDao = new MastercardDao();
	
	private McwReject filter;
	private String tabName;


	private McwReject activeItem;
	
	private transient final DaoDataModel<McwReject> dataModel;
	private final TableRowSelection<McwReject> tableRowSelection;

	public MbMcwRejectSearchBottom(){
		dataModel = new DaoDataListModel<McwReject>(logger) {
			@Override
			protected List<McwReject> loadDaoListData(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setFilters(filters);
					return mcwDao.getMcwRejects(userSessionId, params);
				}
				return new ArrayList<McwReject>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setFilters(filters);
					return mcwDao.getMcwRejectsCount(userSessionId, params);
				}
				return 0;
			}
		};
		tableRowSelection = new TableRowSelection<McwReject>(null, dataModel);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		filters.add(new Filter("lang",userLang));
		
		if (params != null) {
			setFiltersFromMap();
			return; 
		}
		if (getFilter().getId() != null) {
			filters.add(new Filter("id", getFilter().getId()));
		}
        if (getFilter().getFileId() != null) {
            filters.add(new Filter("fileId", getFilter().getFileId()));
        }
	}
	
	private void setFiltersFromMap() {
		filters.add(new Filter("lang", userLang));
        Long param = (Long)params.get("finMessageId");
        if (param != null) {
        	filters.add(new Filter("finMessageId", param));
        }
        param = (Long)params.get("rejectId");
        if (param != null) {
        	filters.add(new Filter("id", param));
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

    public void setFilter(McwReject filter){
        this.filter = filter;
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
		activeItem = (McwReject)dataModel.getRowData();
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
	
	public McwReject getFilter() {
		if (filter == null) {
			filter = new McwReject();
		}
		return filter;
	}
	
	public DaoDataModel<McwReject> getRejects(){
		return dataModel;
	}
	
	public McwReject getActiveItem(){
		return activeItem;
	}
	
	public void loadReject(Long id) {
    	try {
    		activeItem = null;
    		SelectionParams sp = new SelectionParams(new Filter("id", id));
			List<McwReject> rejects = mcwDao.getMcwRejects(userSessionId, sp);
			if (rejects != null && rejects.size() > 0) {
				activeItem = rejects.get(0);
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
    }

    public String getComponentId() {
        return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
    }

    public void setParentSectionId(String parentSectionId) {
        this.parentSectionId = parentSectionId;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public void view() {

    }

    public void close() {

    }

}
