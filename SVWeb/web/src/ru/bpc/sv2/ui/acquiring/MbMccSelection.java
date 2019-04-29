package ru.bpc.sv2.ui.acquiring;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.acquiring.MccSelection;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbMccSelection")
public class MbMccSelection extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ACQUIRING");
	
	private AcquiringDao acquiringDao = new AcquiringDao();
	
	private MccSelection filter;
	
	private MccSelection activeItem;
	
	private final DaoDataModel<MccSelection> dataModel;
	private final TableRowSelection<MccSelection> tableRowSelection;
	
	private List<SelectItem> operTypes;
	private List<SelectItem> merchantCategoryCodes;	
	
	private MccSelection editingItem;
	
	private Integer terminalId;
	
	private static String COMPONENT_ID = "selectionBtnTable";
	private String tabName;
	private String parentSectionId;

	private String terminalNumber;
	private String terminalName;

	public MbMccSelection(){
		
		dataModel = new DaoDataModel<MccSelection>(){
			private static final long serialVersionUID = 1L;

			@Override
			protected MccSelection[] loadDaoData(SelectionParams params) {
				MccSelection[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = acquiringDao.getMccSelections(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new MccSelection[0];
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
						result = acquiringDao.getMccSelectionsCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<MccSelection>(null, dataModel);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		getFilter();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (filter.getTerminalId() != null){
			f = new Filter("terminalId", filter.getTerminalId());
			filters.add(f);
		}
		if (filter.getOperType() != null) {
			f = new Filter("operType", filter.getOperType());
			filters.add(f);
		}
		if (filter.getMcc() != null) {
			f = new Filter("mcc", filter.getMcc());
			filters.add(f);
		}
		
		f = new Filter("mccTemplateId", filter.getMccTemplateId());
		filters.add(f);
		
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
	
	public void fullCleanBean() {
		terminalId = null;
		clearFilter();
	}
	
	public void createNewMccSelection(){
		editingItem = new MccSelection();
		if (filter.getMccTemplateId() != null){
			editingItem.setMccTemplateId(filter.getMccTemplateId());
		}
		editingItem.setLang(curLang);
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void editActiveMccSelection(){
		editingItem = activeItem;
		curMode = AbstractBean.EDIT_MODE;
		setTerminalName(null);
		setTerminalNumber(null);
		if (editingItem.getTerminalId() != null) {
			Terminal[] terminals = acquiringDao.getTerminals(userSessionId, SelectionParams.build("id", editingItem.getTerminalId()));
			if (terminals.length > 0) {
				setTerminalNumber(terminals[0].getTerminalNumber());
				setTerminalName(terminals[0].getTerminalName());
			}
		}
	}
	
	public void saveEditingMccSelection(){
		try {
			if (isNewMode()) {
				editingItem = acquiringDao.createMccSelection(userSessionId, editingItem);
			} else if (isEditMode()) {
				editingItem = acquiringDao.modifyMccSelection(userSessionId, editingItem);
			}
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		if (isNewMode()) {
			tableRowSelection.addNewObjectToList(editingItem);
		} else {
			try{
				dataModel.replaceObject(activeItem, editingItem);
			}catch(Exception e){
				e.printStackTrace();
			}
		}
		activeItem = editingItem;
		resetEditingMccSelection();
	}
	
	public void resetEditingMccSelection(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}
	
	public void deleteActiveMccSelection(){
		try{
			acquiringDao.removeMccSelection(userSessionId, activeItem);
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);		
		if (activeItem == null){
			clearState();
		}
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
		activeItem = (MccSelection)dataModel.getRowData();
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
	
	public MccSelection getFilter() {
		if (filter == null) {
			filter = new MccSelection();
		}
		return filter;
	}
	
	public DaoDataModel<MccSelection> getDataModel(){
		return dataModel;
	}
	
	public MccSelection getActiveItem(){
		return activeItem;
	}
	
	public MccSelection getEditingItem(){
		return editingItem;
	}
	
	public List<SelectItem> getOperTypes(){
		if (operTypes == null){
			operTypes = getDictUtils().getLov(LovConstants.OPERATION_TYPE);
		}
		return operTypes;
	}
	
	public List<SelectItem> getMerchantCategoryCodes(){
		if (merchantCategoryCodes == null){
			merchantCategoryCodes = getDictUtils().getLov(LovConstants.MCC);
		}
		return merchantCategoryCodes;
	}
	
	public void setFilter(MccSelection filter){
		this.filter = filter;
	}

	public Integer getTerminalId() {
		return terminalId;
	}

	public void setTerminalId(Integer terminalId) {
		this.terminalId = terminalId;
		getFilter().setTerminalId(terminalId);
	}
	
	private List<SelectItem> operReasons;
	private List<SelectItem> purposes;
	
	public List<SelectItem> getOperReasons(){
		if (operReasons == null){
			operReasons = getDictUtils().getLov(LovConstants.OPER_REASON);
		}
		return operReasons;
	}
	
	public List<SelectItem> getPurposes(){
		if (purposes == null){
			purposes = new ArrayList<SelectItem>();
			purposes = getDictUtils().getLov(LovConstants.PAYMENT_PURPOSE);
		}
		return purposes;
	}

    public Map<Long, String> getPurposesMap(){
        List<SelectItem> purposeItems = getPurposes();
        Map<Long, String> purposes = new HashMap<Long, String>(purposeItems.size());
        for (SelectItem purposeItem : purposeItems){
            purposes.put(Long.parseLong((String)purposeItem.getValue()), purposeItem.getLabel());
        }
        return purposes;
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

	public void showTerminals() {
		MbTerminalSearchModal bean = getMbTerminalSearchModal();
		bean.clearFilter();
		Terminal filter = new Terminal();
		bean.setFilter(filter);
	}

	private MbTerminalSearchModal getMbTerminalSearchModal() {
		return (MbTerminalSearchModal) ManagedBeanWrapper
				.getManagedBean("MbTerminalSearchModal");
	}

	public void selectNewTerminal() {
		MbTerminalSearchModal termBean = getMbTerminalSearchModal();
		Terminal selected = termBean.getActiveTerminal();
		if (selected != null) {
			getEditingItem().setTerminalId(selected.getId());
			setTerminalNumber(selected.getTerminalNumber());
			setTerminalName(selected.getTerminalName());
		}
	}

	public String getTerminalNumber() {
		return terminalNumber;
	}

	public void setTerminalNumber(String terminalNumber) {
		this.terminalNumber = terminalNumber;
	}

	public String getTerminalName() {
		return terminalName;
	}

	public void setTerminalName(String terminalName) {
		this.terminalName = terminalName;
	}
}
