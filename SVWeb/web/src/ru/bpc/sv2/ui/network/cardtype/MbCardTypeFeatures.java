package ru.bpc.sv2.ui.network.cardtype;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.CardTypeFeature;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbCardTypeFeatures")
public class MbCardTypeFeatures extends AbstractBean{
	
	private NetworkDao networkDao = new NetworkDao();
	private CardTypeFeature activeItem;
	private CardTypeFeature filter;
	private final DaoDataModel<CardTypeFeature> dataModel;
	private final TableRowSelection <CardTypeFeature> tableRowSelection;
	private static final Logger logger = Logger.getLogger("NET");
	
	private List<SelectItem> features = null;
	private CardTypeFeature editingItem;
	private Integer cardTypeId;
	private DictUtils dictUtils;
	
	private static String COMPONENT_ID = "featuresTable";
	private String tabName;
	private String parentSectionId;
	
	public MbCardTypeFeatures(){
		dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		dataModel = new DaoDataModel<CardTypeFeature>(){
			@Override
			protected CardTypeFeature[] loadDaoData(SelectionParams params) {
				CardTypeFeature[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = networkDao.getCardTypeFeatures(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new CardTypeFeature[0];
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
						result = networkDao.getCardTypeFeaturesCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<CardTypeFeature>(null, dataModel);
	}
	
	@Override
	public void clearFilter() {
		filter  = null;
		searching = false;		
	}
	
	public void cancel(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}
	
	public CardTypeFeature getFilter(){
		if (filter == null){
			filter = new CardTypeFeature();
		}
		return filter;
	}
	
	public void setFilter(CardTypeFeature filter){
		this.filter = filter;
		if (this.filter != null){
			cardTypeId = filter.getCardTypeId();
		}
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		Filter f = new Filter();
		/*f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);*/
		
		if (filter.getCardTypeId() != null){
			f = new Filter("cardTypeId", filter.getCardTypeId());			
			filters.add(f);
			cardTypeId = filter.getCardTypeId();
		}
						
	}
	
	public void search() {
		clearState();	
		searching = true;
	}
	
	public void clearState() {
		tableRowSelection.clearSelection();
		dataModel.flushCache();
		curLang = userLang;
	}
	
	public void clearBeanState(){
		clearState();
	}
	
	public DaoDataModel<CardTypeFeature> getDataModel(){
		return dataModel;
	}
	
	public void add(){
		editingItem = new CardTypeFeature();
		editingItem.setCardTypeId(cardTypeId);		
		curMode = AbstractBean.NEW_MODE;
	}
	
	public Integer getCardTypeId(){
		return cardTypeId;
	}
	public void edit(){
		editingItem = (CardTypeFeature) activeItem.clone();
		curMode = AbstractBean.EDIT_MODE;
	}
	
	public void delete(){
		try{
			networkDao.deleteCardTypeFeatures(userSessionId, activeItem);
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);		
	}
	
	public CardTypeFeature getEditingItem(){
		return editingItem;
	}
	
	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0) {
			setFirstRowActive();
		} else if (activeItem != null && dataModel.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			tableRowSelection.setWrappedSelection(selection);
			activeItem = tableRowSelection.getSingleSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}
 	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();		
	}
 	
 	public void setFirstRowActive() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (CardTypeFeature) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
	}	
	
	public List<SelectItem> getFeatures(){
		if (features == null){
			features = dictUtils.getLov(LovConstants.CARD_FEATURES);
		}
		return features;
	}
	
	public void save(){
		try {
			CardTypeFeature updatedEditingItem = null;
			if (isNewMode()) {
				updatedEditingItem = networkDao.addCardTypeFeatures(userSessionId, editingItem);
			} else if (isEditMode()) {
				updatedEditingItem =  networkDao.editCardTypeFeatures(userSessionId, editingItem);
			}
			editingItem = updatedEditingItem;
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
			cancel();
			return;
		}
		if (isNewMode()) {
			tableRowSelection.addNewObjectToList(editingItem);
		} else {
			try {
				dataModel.replaceObject(activeItem, editingItem);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		activeItem = editingItem;
		cancel();
		search();
	}
	
	public CardTypeFeature getActiveItem(){
		return (activeItem);
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
