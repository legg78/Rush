package ru.bpc.sv2.ui.atm;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.atm.AdminOperation;
import ru.bpc.sv2.atm.AtmCollection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.AtmDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAdminOperation")
public class MbAdminOperation extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ATM");
	
	private AtmDao atmDao = new AtmDao();
	
	private AdminOperation filter;
	
	private AdminOperation activeItem;
	
	private final DaoDataModel<AdminOperation> dataModel;
	private final TableRowSelection<AdminOperation> tableRowSelection;
	
	private Date filterStartDate;
	private Date filterEndDate;
	
	private static String COMPONENT_ID = "accountsTable";
	private String tabName;
	private String parentSectionId;
	
	private List<SelectItem> collections;
	private AtmCollection[] collectionSource;
	private int selectedCollectionIdx;
	
	public MbAdminOperation(){
		
		dataModel = new DaoDataModel<AdminOperation>(){
			@Override
			protected AdminOperation[] loadDaoData(SelectionParams params) {
				AdminOperation[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = atmDao.getAdminOperations(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new AdminOperation[0];
				}
				return result;
			}
			
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching){
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = atmDao.getAdminOperationsCount(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);						
					}
				} else {
					result = 0;
				}
				return result;
			}
		};
		tableRowSelection = new TableRowSelection<AdminOperation>(null, dataModel);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (filter.getTerminalId() != null){
			f = new Filter();
			f.setElement("terminalId");
			f.setValue(filter.getTerminalId());
			filters.add(f);
		}
	
		if (filter.getCommandDate() != null){
			f = new Filter();
			f.setElement("commandDate");
			f.setValue(filter.getCommandDate());
			filters.add(f);
		}
	
		if (filter.getCommand() != null){
			f = new Filter();
			f.setElement("command");
			f.setValue(filter.getCommand());
			filters.add(f);
		}
	
		if (filter.getCommandName() != null){
			f = new Filter();
			f.setElement("commandName");
			f.setValue(filter.getCommandName());
			filters.add(f);
		}
	
		if (filter.getCommandResult() != null){
			f = new Filter();
			f.setElement("commandResult");
			f.setValue(filter.getCommandResult());
			filters.add(f);
		}
	
		if (filter.getCommandResultName() != null){
			f = new Filter();
			f.setElement("commandResultName");
			f.setValue(filter.getCommandResultName());
			filters.add(f);
		}
	
		if (filter.getUserId() != null){
			f = new Filter();
			f.setElement("userId");
			f.setValue(filter.getUserId());
			filters.add(f);
		}
	
		if (filter.getUserName() != null && filter.getUserName().trim().length() > 0) {
			f = new Filter();
			f.setElement("userName");
			f.setValue(filter.getUserName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());

			filters.add(f);
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
		filterStartDate = null;
		filterEndDate = null;
		selectedCollectionIdx = 0;
		collections = null;
		collectionSource = null;
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
		activeItem = (AdminOperation)dataModel.getRowData();
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
	
	public AdminOperation getFilter() {
		if (filter == null) {
			filter = new AdminOperation();
		}
		return filter;
	}
	
	private void prepareCollections(){
		collections = new ArrayList<SelectItem>(0);
		if (getFilter().getTerminalId() == null) return;
		
		SelectionParams sp = SelectionParams.build("terminalId", getFilter().getTerminalId());
		sp.setRowIndexEnd(-1);
		sp.setSortElement(new SortElement("startDate", Direction.ASC));
		collectionSource = atmDao.getAtmCollections(userSessionId, sp);
		
		if (collectionSource.length == 0) return;
		
		for (int i=0; i < collectionSource.length; i++ ){
			AtmCollection collection = collectionSource[i];
			SelectItem si = new SelectItem(i, String.format("%d - %tc", collection.getId(), collection.getStartDate()));
			collections.add(si);
		}
		
		selectedCollectionIdx = collectionSource.length - 1;
	}
	
	public List<SelectItem> getCollections(){
		if (collections == null){
			prepareCollections();
		}
		return collections;
	}
	
	public void setSelectedCollectionIdx(Integer index){
		if (index != null && index != selectedCollectionIdx){
			selectedCollectionIdx = index;
			AtmCollection start = collectionSource[selectedCollectionIdx];
			filterStartDate = start.getStartDate();
			if (selectedCollectionIdx + 1 < collectionSource.length){
				AtmCollection end = collectionSource[selectedCollectionIdx + 1];
				filterEndDate = end.getStartDate();
			}
		}
	}
	
	public Integer getSelectedCollectionIdx(){
		return selectedCollectionIdx;
	}	
	
	public DaoDataModel<AdminOperation> getDataModel(){
		return dataModel;
	}
	
	public AdminOperation getActiveItem(){
		return activeItem;
	}

	public Date getFilterStartDate() {
		if (filterStartDate == null){
			filterStartDate = new Date();
		}
		return filterStartDate;
	}

	public void setFilterStartDate(Date filterStartDate) {
		this.filterStartDate = filterStartDate;
	}

	public Date getFilterEndDate() {
		return filterEndDate;
	}

	public void setFilterEndDate(Date filterEndDate) {
		this.filterEndDate = filterEndDate;
	}
	
	public void updateData(){
		dataModel.flushCache();
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
