package ru.bpc.sv2.ui.security;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.SecurityDao;
import ru.bpc.sv2.security.RsaCertificate;
import ru.bpc.sv2.security.RsaKey;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.utils.KeyLabelItem;

@ViewScoped
@ManagedBean (name = "MbRsaCertificate")
public class MbRsaCertificate extends AbstractBean {
	private static final Logger logger = Logger.getLogger("SECURITY");
	
	private SecurityDao securityDao = new SecurityDao();
	
	
	
	private RsaCertificate filter;
	
	private RsaCertificate activeItem;
	
	private final DaoDataModel<RsaCertificate> dataModel;
	private final TableRowSelection<RsaCertificate> tableRowSelection;
	
	private RsaCertificate editingItem;
	private Map<Integer, String> authoritiesMap;
	private String keysLang;
	private RsaKey activeKey;
	private DaoDataModel<RsaKey> keysDataModel;
	private TableRowSelection<RsaKey> keysTableRowSelection;
	private boolean bottom;
	
	private static String COMPONENT_ID = "RsaKeyTable";
	private String tabName;
	private String parentSectionId;
	
	public MbRsaCertificate(){
		pageLink = "sec|rsaCertificates";
		tabName = "detailsTab";
		dataModel = new DaoDataModel<RsaCertificate>(){
			@Override
			protected RsaCertificate[] loadDaoData(SelectionParams params) {
				RsaCertificate[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = securityDao.getRsaCertificates(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addSystemError(e);
    					logger.error("", e);
					}
				} else {
					result = new RsaCertificate[0];
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
						result = securityDao.getRsaCertificatesCount(userSessionId, params);
					}catch (DataAccessException e){
						FacesUtils.addSystemError(e);
    					logger.error("", e);						
					}
				} else {
					result = 0;
				}
				return result;
			}
		};
		tableRowSelection = new TableRowSelection<RsaCertificate>(null, dataModel);
		
		keysDataModel = new DaoDataModel<RsaKey>(){

			@Override
			protected RsaKey[] loadDaoData(SelectionParams params) {
				RsaKey[] result;
				if (activeItem != null){
					result = securityDao.getRsaKeysForCertificate(userSessionId, activeItem, keysLang);
				} else {
					result = new RsaKey[0];
				}
				return result;
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (activeItem != null){
					result = securityDao.getRsaKeysForCertificateCount(userSessionId, activeItem, keysLang);
				}
				return result;
			}
			
		};
		keysTableRowSelection = new TableRowSelection<RsaKey>(null, keysDataModel);
		
		keysLang = curLang;
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (filter.getAuthorityId() != null){
			f = new Filter();
			f.setElement("authorityId");
			f.setValue(filter.getAuthorityId());
			filters.add(f);
		}
	
		if (filter.getExpirDate() != null){
			f = new Filter();
			f.setElement("expirDate");
			f.setValue(filter.getExpirDate());
			filters.add(f);
		}
	
		if (filter.getSubjectId() != null && !filter.getSubjectId().equals("")){
			f = new Filter();
			f.setElement("subjectId");
			f.setValue(filter.getSubjectId());
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
	}
	
	public void clearBeansStates(){
		if (bottom) return;
		keysDataModel.flushCache();
		keysTableRowSelection.clearSelection();
	}
	
	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		searching = false;
	}

	public void deleteActiveRsaCertificate(){
		try{
			securityDao.removeRsaCertificate(userSessionId, activeItem);
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);		
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
		activeItem = (RsaCertificate)dataModel.getRowData();
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
		if (bottom) return;
		keysDataModel.flushCache();
		keysTableRowSelection.clearSelection();
		activeKey = null;
	}
	
	public RsaCertificate getFilter() {
		if (filter == null) {
			filter = new RsaCertificate();
		}
				
		return filter;
	}
	
	public DaoDataModel<RsaCertificate> getDataModel(){
		return dataModel;
	}
	
	public RsaCertificate getActiveItem(){
		return activeItem;
	}
	
	public RsaCertificate getEditingItem(){
		return editingItem;
	}
	
	public List<SelectItem> getAuthorities(){
		List<SelectItem> result = getDictUtils().getLov(LovConstants.CERTIFICATE_AUTHORITY_CENTERS);
		return result;
	}

	public Map<Integer, String> getAuthoritiesMap(){
		if (authoritiesMap == null){
			authoritiesMap = new HashMap<Integer, String>();
			KeyLabelItem[] items = getDictUtils().getLovItems(LovConstants.CERTIFICATE_AUTHORITY_CENTERS);
			for (KeyLabelItem item : items){
				Integer integerKey = new Integer((String)item.getValue());
				authoritiesMap.put(integerKey, item.getLabel());
			}
			
		}
		return authoritiesMap;
	}
	
	public DaoDataModel<RsaKey> getKeys(){
		return keysDataModel;
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		keysLang = (String) event.getNewValue();
		keysDataModel.flushCache();
		keysTableRowSelection.clearSelection();
	}
	
	public String getKeysLang(){
		return keysLang;
	}
	
	public void setKeysLang(String keysLang){
		this.keysLang = keysLang;
	}
	
	public void setKeysItemSelection(SimpleSelection selection) {		
		keysTableRowSelection.setWrappedSelection(selection);
		activeKey = keysTableRowSelection.getSingleSelection();
	}
	
	public SimpleSelection getKeysItemSelection() {
		if (activeKey == null && keysDataModel.getRowCount() > 0){
			prepareKeysItemSelection();
		}
		return keysTableRowSelection.getWrappedSelection();
	}
	
	public void prepareKeysItemSelection(){
		keysDataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeKey = (RsaKey)keysDataModel.getRowData();
		selection.addKey(activeKey.getModelId());
		keysTableRowSelection.setWrappedSelection(selection);
	}
	
	public RsaKey getKeysActiveItem(){
		return activeKey;
	}

	public boolean isBottom() {
		return bottom;
	}

	public void setBottom(boolean bottom) {
		this.bottom = bottom;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("rsaKeysTab")) {
			setParentSectionId(getSectionId());
			setTableState(getSateFromDB(getComponentId()));
		}
	}
	
	public String getTabName() {
		return tabName;
	}

	public String getSectionId() {
		return SectionIdConstants.ISSUING_RSA_CERT;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}
