package ru.bpc.sv2.ui.atm;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.atm.AtmCollection;
import ru.bpc.sv2.atm.FraudOperation;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.AtmDao;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbFraudOperation")
public class MbFraudOperation extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ATM");
	
	private AtmDao atmDao = new AtmDao();
	
	private FraudOperation filter;
	
	private FraudOperation activeItem;
	
	private final DaoDataModel<FraudOperation> dataModel;
	private final TableRowSelection<FraudOperation> tableRowSelection;
	private Date operDateFrom;
	private Date operDateTo;
	
	private List<SelectItem> collections;
	private AtmCollection[] collectionSource;
	private int selectedCollectionIdx;
	
	public MbFraudOperation(){
		
		dataModel = new DaoDataModel<FraudOperation>(){
			@Override
			protected FraudOperation[] loadDaoData(SelectionParams params) {
				FraudOperation[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = atmDao.getFraudOperations(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new FraudOperation[0];
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
						result = atmDao.getFraudOperationsCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<FraudOperation>(null, dataModel);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		UserSession usession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
		String dbDateFormat = usession.getDatePattern();
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		
		if (operDateFrom != null) {
			f = new Filter();
			f.setElement("operDateFrom");
			f.setValue(String.valueOf(df.format(operDateFrom)));
			filters.add(f);
		}

		if (operDateTo != null) {
			f = new Filter();
			f.setElement("operDateTo");
			f.setValue(String.valueOf(df.format(operDateFrom)));
			filters.add(f);
		}
		
		if (filter.getOperType() != null && !"".equals(filter.getOperType())){
			f = new Filter();
			f.setElement("operType");
			f.setValue(filter.getOperType());
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
		operDateFrom = null;
		operDateTo = null;
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
		activeItem = (FraudOperation)dataModel.getRowData();
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
	
	public FraudOperation getFilter() {
		if (filter == null) {
			filter = new FraudOperation();
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
		
		setSelectedCollectionIdx(collectionSource.length - 1);
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
			operDateFrom = start.getStartDate();
			if (selectedCollectionIdx + 1 < collectionSource.length){
				AtmCollection end = collectionSource[selectedCollectionIdx + 1];
				operDateTo = end.getStartDate();
			}
		}
	}
	
	public Integer getSelectedCollectionIdx(){
		return selectedCollectionIdx;
	}	
	
	public DaoDataModel<FraudOperation> getDataModel(){
		return dataModel;
	}
	
	public FraudOperation getActiveItem(){
		return activeItem;
	}

	public Date getOperDateFrom() {
		return operDateFrom;
	}

	public void setOperDateFrom(Date operDateFrom) {
		this.operDateFrom = operDateFrom;
	}

	public Date getOperDateTo() {
		return operDateTo;
	}

	public void setOperDateTo(Date operDateTo) {
		this.operDateTo = operDateTo;
	}
	
	public void updateData(){
		dataModel.flushCache();
	}
	
	public List<SelectItem> getOperationTypes(){
		List<SelectItem> result = getDictUtils().getArticles(DictNames.OPER_TYPE, true, true);
		return result;
	}
}
