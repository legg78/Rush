package ru.bpc.sv2.ui.atm;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.atm.CapturedCard;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AtmDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbCapturedCard")
public class MbCapturedCard extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ATM");
	
	private AtmDao atmDao = new AtmDao();
	
	
	
	private CapturedCard filter;
	private Date filterStartDate;
	private Date filterEndDate;
	
	private CapturedCard activeItem;
	
	private final DaoDataModel<CapturedCard> dataModel;
	private final TableRowSelection<CapturedCard> tableRowSelection;
	
	private static String COMPONENT_ID = "capturedCardsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbCapturedCard(){
		
		dataModel = new DaoDataModel<CapturedCard>(){
			@Override
			protected CapturedCard[] loadDaoData(SelectionParams params) {
				CapturedCard[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = atmDao.getCapturedCards(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new CapturedCard[0];
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
						result = atmDao.getCapturedCardsCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<CapturedCard>(null, dataModel);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (getFilter().getTerminalId() != null){
			f = new Filter();
			f.setElement("terminalId");
			f.setValue(getFilter().getTerminalId());
			filters.add(f);
		}
		
		if (getFilter().getCardMask() != null && getFilter().getCardMask().trim().length() > 0){
			f = new Filter();
			f.setElement("cardMask");
			f.setValue(getFilter().getCardMask().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(f);
		}
		
		if (getFilter().getRespCode() != null){
			f = new Filter();
			f.setElement("respCode");
			f.setValue(getFilter().getRespCode());
			filters.add(f);
		}
		
		if (filterStartDate != null){
			f = new Filter();
			f.setElement("startDate");
			f.setValue(filterStartDate);
			filters.add(f);
		}
		
		if (filterEndDate != null){
			f = new Filter();
			f.setElement("endDate");
			f.setValue(filterEndDate);
			filters.add(f);
		}
		
	}
	
	public void search() {
		clearBeansStates();
		searching = true;
	}
	
	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		dataModel.flushCache();
		curLang = userLang;
		filter = null;
		filterStartDate = null;
		filterEndDate = null;
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
		activeItem = (CapturedCard)dataModel.getRowData();
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
	
	public CapturedCard getFilter() {
		if (filter == null) {
			filter = new CapturedCard();
		}
		return filter;
	}
	
	public DaoDataModel<CapturedCard> getDataModel(){
		return dataModel;
	}
	
	public CapturedCard getActiveItem(){
		return activeItem;
	}

	public Date getFilterStartDate() {
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
	
	public List<SelectItem> getRespCodes(){
		List<SelectItem> result = getDictUtils().getArticles(DictNames.RESPONSE_CODE, true, true);
		return result;
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
