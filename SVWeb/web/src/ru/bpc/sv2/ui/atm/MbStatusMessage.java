package ru.bpc.sv2.ui.atm;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.atm.AtmCollection;
import ru.bpc.sv2.atm.StatusMessage;
import ru.bpc.sv2.constants.DatePatterns;
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
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbStatusMessage")
public class MbStatusMessage extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ATM");
	
	private AtmDao atmDao = new AtmDao();
	
	private StatusMessage filter;
	
	private StatusMessage activeItem;
	
	private final DaoDataModel<StatusMessage> dataModel;
	private final TableRowSelection<StatusMessage> tableRowSelection;
	private Date filterStartDate;
	private Date filterEndDate;
	
	private static String COMPONENT_ID = "statusMessageTable";
	private String tabName;
	private String parentSectionId;

	private List<SelectItem> collections;
	private AtmCollection[] collectionSource;
	private int selectedCollectionIdx;
	
	public MbStatusMessage(){
		rowsNum = 300;
		dataModel = new DaoDataModel<StatusMessage>(){
			@Override
			protected StatusMessage[] loadDaoData(SelectionParams params) {
				StatusMessage[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = atmDao.getStatusMessages(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new StatusMessage[0];
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
						result = atmDao.getStatusMessagesCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<StatusMessage>(null, dataModel);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		filters.add(new Filter("lang", curLang));
		filters.add(new Filter("terminalId", getFilter().getTerminalId()));
		
		if (filter.getStatus() != null){
			filters.add(new Filter("status", filter.getStatus()));
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (getFilterStartDate() != null){
			filters.add(new Filter("startDate", df.format(getFilterStartDate())));
		}
		if (filterEndDate != null){
			filters.add(new Filter("endDate", df.format(filterEndDate)));
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
        activeItem = (StatusMessage)dataModel.getRowData();
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
	
	public StatusMessage getFilter() {
		if (filter == null) {
			filter = new StatusMessage();
		}
		return filter;
	}
	
	public DaoDataModel<StatusMessage> getDataModel(){
		return dataModel;
	}
	
	public StatusMessage getActiveItem(){
		return activeItem;
	}

	public Date getFilterStartDate() {
		if (filterStartDate == null) {
			GregorianCalendar cal = new GregorianCalendar();
			cal.setTime(new Date());
			cal.set(GregorianCalendar.HOUR_OF_DAY, 0);
			cal.set(GregorianCalendar.MINUTE, 0);
			cal.set(GregorianCalendar.SECOND, 0);
			cal.set(GregorianCalendar.MILLISECOND, 0);
			filterStartDate = cal.getTime();
		}
		return filterStartDate;
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
		tableRowSelection.clearSelection();
		activeItem = null;
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
