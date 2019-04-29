package ru.bpc.sv2.ui.cmn;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.cmn.StandardKeyTypeMap;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbCmnStandardKeyTypeMaps")
public class MbCmnStandardKeyTypeMaps extends AbstractBean{
	
	private static final Logger logger = Logger.getLogger("COMMUNICATION");
		
	private CommunicationDao cmnDao = new CommunicationDao();
	
	
	
	private transient DaoDataModel<StandardKeyTypeMap> standardKeyTypeMapSource;
	private final TableRowSelection<StandardKeyTypeMap> itemSelection;
	private StandardKeyTypeMap activeStandardKeyTypeMap;
	private StandardKeyTypeMap newStandardKeyTypeMap;
	private StandardKeyTypeMap filter;
	
	private Integer standardId;
	private Integer standardKeyTypesLovId;
	
	private static String COMPONENT_ID = "standardKeyTypeMapTable";
	private String tabName;
	private String parentSectionId;
	
	public MbCmnStandardKeyTypeMaps(){
		
		standardKeyTypeMapSource = new DaoDataModel<StandardKeyTypeMap>(){
			@Override
			protected StandardKeyTypeMap[] loadDaoData(SelectionParams params) {
				if (standardId == null)
					return new StandardKeyTypeMap[0];
				try {
					setFilters();
					params.setFilters(filters
							.toArray(new Filter[filters.size()]));
					return cmnDao.getStandardKeyTypeMaps(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new StandardKeyTypeMap[0];
			}
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (standardId == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters
							.toArray(new Filter[filters.size()]));
					return cmnDao.getStandardKeyTypeMapsCount(userSessionId,
							params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		itemSelection = new TableRowSelection<StandardKeyTypeMap>(null, standardKeyTypeMapSource);
	}
	
	
	public void search(){
		clearBean();
	}
	
	public void clearBean(){
		standardKeyTypeMapSource.flushCache();
		itemSelection.clearSelection();
		activeStandardKeyTypeMap = null;
	}
	
	public void setFilters(){
		filters = new ArrayList<Filter>();
		
		Filter paramFilter;
		
		paramFilter = new Filter();
		paramFilter.setElement("standardId");
		paramFilter.setValue(standardId);
		filters.add(paramFilter);
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}
	
	private void prepareSelection(){
		if (standardKeyTypeMapSource.getRowCount() > 0){
			if (activeStandardKeyTypeMap == null){
				setFirstRowActive();
			} else {
				setRowActive();
			}
		}
	}
	
	private void setFirstRowActive(){
		standardKeyTypeMapSource.setRowIndex(0);
		activeStandardKeyTypeMap = (StandardKeyTypeMap) standardKeyTypeMapSource.getRowData();
		
		SimpleSelection selection = new SimpleSelection();	
		selection.addKey(activeStandardKeyTypeMap.getModelId());
		itemSelection.setWrappedSelection(selection);

		setDependentBeans();
	}
	
	private void setRowActive(){
		SimpleSelection selection = new SimpleSelection();
		selection.addKey(activeStandardKeyTypeMap.getModelId());
		itemSelection.setWrappedSelection(selection);
		activeStandardKeyTypeMap = itemSelection.getSingleSelection();
	}
	
	private void setDependentBeans(){}
	
	public void add(){
		curMode = NEW_MODE;
		newStandardKeyTypeMap = new StandardKeyTypeMap();
		newStandardKeyTypeMap.setStandardId(standardId);
		newStandardKeyTypeMap.setLang(userLang);
	}
	
	public void edit(){
		curMode = EDIT_MODE;
		newStandardKeyTypeMap = activeStandardKeyTypeMap;
	}
	
	public void save(){
		try {
			if (this.isNewMode()) {			
				newStandardKeyTypeMap = cmnDao.addStandardKeyTypeMap(userSessionId,
						newStandardKeyTypeMap);
	
			} else if (this.isEditMode()){
				newStandardKeyTypeMap = cmnDao.editStandardKeyTypeMap(userSessionId,
						newStandardKeyTypeMap);
			}
			clearBean();
			activeStandardKeyTypeMap = newStandardKeyTypeMap;
			
			cancel();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
			
	}
	
	public void delete(){
		try {
			cmnDao.removeStandardKeyTypeMap(userSessionId, activeStandardKeyTypeMap);
			activeStandardKeyTypeMap = itemSelection.removeObjectFromList(activeStandardKeyTypeMap);
			clearBean();	
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void cancel(){
		curMode = VIEW_MODE;
		newStandardKeyTypeMap = null;
	}
	
	
	public StandardKeyTypeMap getNewStandardKeyTypeMap() {
		return newStandardKeyTypeMap;
	}
	
	public StandardKeyTypeMap getActiveStandardKeyTypeMap() {
		return activeStandardKeyTypeMap;
	}

	public void setItemSelection(SimpleSelection selection){
		itemSelection.setWrappedSelection(selection);
		activeStandardKeyTypeMap = itemSelection.getSingleSelection();
		setDependentBeans();
	}
	
	public SimpleSelection getItemSelection() {
		prepareSelection();
		return itemSelection.getWrappedSelection();
	}

	public ExtendedDataModel getStandardKeyTypeMaps(){
		return standardKeyTypeMapSource;
	}
	
	public List<SelectItem> getKeyTypes(){
		return getDictUtils().getLov(LovConstants.ENCRYPTION_KEY_TYPES);
	}
	
	public List<SelectItem> getStandardKeyTypes(){
		List<SelectItem> result = null;
		if (standardKeyTypesLovId != null){
			result = getDictUtils().getLov(standardKeyTypesLovId);
		} else {
			result = new ArrayList<SelectItem>();
		}
		return result;
	}
		
	public StandardKeyTypeMap getFilter() {
		if (filter == null){
			filter = new StandardKeyTypeMap();
		}
		return filter;
	}


	
	public Integer getStandardKeyTypesLovId() {
		return standardKeyTypesLovId;
	}


	public void setStandardKeyTypesLovId(Integer standardKeyTypesLovId) {
		this.standardKeyTypesLovId = standardKeyTypesLovId;
	}

	public Integer getStandardId() {
		return standardId;
	}

	public void setStandardId(Integer standardId) {
		this.standardId = standardId;
	}


	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
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
