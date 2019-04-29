package ru.bpc.sv2.ui.security;

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
import ru.bpc.sv2.utils.UserException;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbRsaKey")
public class MbRsaKey extends AbstractBean {
	private static final long serialVersionUID = -8298142896978304291L;

	private static final Logger logger = Logger.getLogger("SECURITY");

	private SecurityDao securityDao = new SecurityDao();

	private RsaKey filter;

	private RsaKey activeItem;

	private final DaoDataModel<RsaKey> dataModel;
	private final TableRowSelection<RsaKey> tableRowSelection;
	private final DaoDataModel<RsaCertificate> certsDataModel;
	private final TableRowSelection<RsaCertificate> certsTableRowSelection;

	private RsaKey editingItem;
    private List<RsaKey> addedItems;

	private Long objectId;
	private String subjectId;
	private String entityType;
	private List<SelectItem> hsms;
	private Map<Integer, String> algorithmsMap;
	private Map<Integer, String> hsmsMap;
	private Map<Integer, String> authoritiesMap;
	private List<SelectItem> cachedBins;
	private boolean bottom;
	private RsaCertificate activeCertificate;
	private String authorityKeyIndexHex;
	private Integer authorityKeyIndexDec;
	
	private static String COMPONENT_ID = "RsaKeyTable";
	private String tabName;
	private String parentSectionId;

	public MbRsaKey() {
		pageLink = "sec|rsaKeys";
		tabName = "detailsTab";
		dataModel = new DaoDataModel<RsaKey>() {
			private static final long serialVersionUID = 7012335661763213162L;

			@Override
			protected RsaKey[] loadDaoData(SelectionParams params) {
				RsaKey[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = securityDao.getRsaKeys(userSessionId, params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = new RsaKey[0];
				}
				return result;
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = securityDao.getRsaKeysCount(userSessionId,
								params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = 0;
				}
				return result;
			}
		};
		tableRowSelection = new TableRowSelection<RsaKey>(null, dataModel);

		certsDataModel = new DaoDataModel<RsaCertificate>() {
			private static final long serialVersionUID = 3882441567373290126L;

			@Override
			protected RsaCertificate[] loadDaoData(SelectionParams params) {
				RsaCertificate[] result;
				if (activeItem != null) {
					result = securityDao.getRsaCertificesByKey(userSessionId,
							activeItem);
				} else {
					result = new RsaCertificate[0];
				}
				return result;
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result;
				if (activeItem != null) {
					result = securityDao.getRsaCertificesCountByKey(
							userSessionId, activeItem);
				} else {
					result = 0;
				}
				return result;
			}

		};
		certsTableRowSelection = new TableRowSelection<RsaCertificate>(null,
				certsDataModel);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();

		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);

		if (getFilter().getLmkId() != null) {
			f = new Filter();
			f.setElement("lmkId");
			f.setValue(filter.getLmkId());
			filters.add(f);
		}

		if (getFilter().getExpirDate() != null) {
			f = new Filter();
			f.setElement("expirDate");
			f.setValue(filter.getExpirDate());
			filters.add(f);
		}

		if (objectId != null) {
			f = new Filter();
			f.setElement("objectId");
			f.setValue(objectId);
			filters.add(f);
		}

		if (entityType != null) {
			f = new Filter();
			f.setElement("entityType");
			f.setValue(entityType);
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

	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		searching = false;
	}

	public void createNewRsaKey() {
		editingItem = new RsaKey();
		editingItem.setExponent("03");
		editingItem.setObjectId(objectId);
		editingItem.setEntityType(entityType);
		editingItem.setLang(curLang);
		editingItem.setSubjectId(subjectId);
		curMode = AbstractBean.NEW_MODE;
	}

	public void editActiveRsaKey() {
		editingItem = activeItem;
		curMode = AbstractBean.EDIT_MODE;
	}

	public void saveEditingRsaKey() {
		try {
			if (editingItem.getAuthorityKeyIndex() == null && authorityKeyIndexHex != null && authorityKeyIndexHex.trim().length()>0){
					editingItem.setAuthorityKeyIndex(Integer.parseInt(authorityKeyIndexHex.trim(),16));
			}
			
			if (isNewMode()) {
				addedItems = securityDao.createRsaKey(userSessionId,
						editingItem);
			} else if (isEditMode()) {
			}
		} catch (DataAccessException e) {
			FacesUtils.addSystemError(e);
			logger.error("", e);
			return;
		} catch (UserException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}

		if (isNewMode()) {
            for (RsaKey key : addedItems){
                tableRowSelection.addNewObjectToList(key);
            }
		} else {
			try {
				dataModel.replaceObject(activeItem, editingItem);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		activeItem = tableRowSelection.getSingleSelection();
		setCaIndex();
		resetEditingRsaKey();
	}

	public void resetEditingRsaKey() {
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}

	public void deleteActiveRsaKey() {
		try {
			securityDao.removeRsaKey(userSessionId, activeItem);
		} catch (DataAccessException e) {
			FacesUtils.addSystemError(e);
			logger.error("", e);
			return;
		} catch (UserException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);
		if (activeItem == null) {
			clearState();
		}
	}

	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0) {
			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}

	public void prepareItemSelection() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (RsaKey) dataModel.getRowData();
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

	public SimpleSelection getCertItemSelection() {
		if (activeCertificate == null && certsDataModel.getRowCount() > 0) {
			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}

	public void prepareCertItemSelection() {
		certsDataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeCertificate = (RsaCertificate) certsDataModel.getRowData();
		selection.addKey(activeCertificate.getModelId());
		certsTableRowSelection.setWrappedSelection(selection);
		if (activeCertificate != null) {
			setBeansState();
		}
	}

	public void setCertItemSelection(SimpleSelection selection) {
		certsTableRowSelection.setWrappedSelection(selection);
		activeCertificate = certsTableRowSelection.getSingleSelection();
		if (activeCertificate != null) {
			setBeansState();
		}
	}

	public void clearBeansStates() {
		if (bottom)
			return;
		certsDataModel.flushCache();
		certsTableRowSelection.clearSelection();
	}

	private void setBeansState() {
		if (bottom)
			return;
		certsDataModel.flushCache();
		certsTableRowSelection.clearSelection();
		activeCertificate = null;
	}

	public RsaKey getFilter() {
		if (filter == null) {
			filter = new RsaKey();
		}
		return filter;
	}

	public DaoDataModel<RsaKey> getDataModel() {
		return dataModel;
	}

	public RsaKey getActiveItem() {
		return activeItem;
	}

	public RsaKey getEditingItem() {
		return editingItem;
	}

    public List<RsaKey> getAddedItems() {
        if (addedItems == null)
            return new ArrayList<RsaKey>(0);
        return addedItems;
    }

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}
	
	public void setSubjectId(String subjectId){
		this.subjectId = subjectId;
	}

	public List<SelectItem> getHsms() {
		return getDictUtils().getLov(LovConstants.HSM_DEVICE);
	}

	public List<SelectItem> getAlgorithms() {
		List<SelectItem> result = getDictUtils()
				.getLov(LovConstants.SIGNATURE_ALGORITHM);
		return result;
	}

	public List<SelectItem> getAuthorities() {
		List<SelectItem> result = getDictUtils()
				.getLov(LovConstants.CERTIFICATE_AUTHORITY_CENTERS);
		return result;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void confirmEditLanguage() {
		filters = new ArrayList<Filter>();

		Filter f = new Filter();
		f.setElement("id");
		f.setValue(editingItem.getId());
		filters.add(f);

		f = new Filter();
		f.setElement("lang");
		f.setValue(editingItem.getLang());
		filters.add(f);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			RsaKey[] rsaKeys = securityDao.getRsaKeys(userSessionId, params);
			if (rsaKeys != null && rsaKeys.length > 0) {
				editingItem = rsaKeys[0];
			}
		} catch (Exception e) {
			FacesUtils.addSystemError(e);
			logger.error("", e);
		}
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		if (bottom){
			dataModel.flushCache();
		} else {
			List<Filter> filtersList = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(activeItem.getId());
			filtersList.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setValue(curLang);
			filtersList.add(paramFilter);

			filters = filtersList;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			try {
				RsaKey[] keys = securityDao.getRsaKeys(userSessionId, params);
				if (keys != null && keys.length > 0) {
					activeItem = keys[0];
				}
			} catch (Exception e) {
				FacesUtils.addSystemError(e);
				logger.error("", e);
			}
		}
	}

	public Map<Integer, String> getAlgorithmsMap() {
		if (algorithmsMap == null) {
			algorithmsMap = new HashMap<Integer, String>();
			KeyLabelItem[] items = getDictUtils().getLovItems(LovConstants.SIGNATURE_ALGORITHM);
			for (KeyLabelItem item : items) {
				algorithmsMap.put(new Integer(item.getValue().toString()),
						item.getLabel());
			}
		}
		return algorithmsMap;
	}

	public Map<Integer, String> getHsmsMap() {
		if (hsmsMap == null) {
			getHsms();
		}
		return hsmsMap;
	}

	public Map<Integer, String> getAuthoritiesMap() {
		if (authoritiesMap == null) {
			authoritiesMap = new HashMap<Integer, String>();
			KeyLabelItem[] items = getDictUtils().getLovItems(LovConstants.CERTIFICATE_AUTHORITY_CENTERS);
			for (KeyLabelItem item : items) {
				Integer integerKey = new Integer((String) item.getValue());
				authoritiesMap.put(integerKey, item.getLabel());
			}
		}
		return authoritiesMap;
	}

	public List<SelectItem> getBins() {
		if (cachedBins == null) {
			cachedBins = getDictUtils().getLov(LovConstants.ISSUING_BINS);
		}
		return cachedBins;
	}

	public boolean isBottom() {
		return bottom;
	}

	public void setBottom(boolean bottom) {
		this.bottom = bottom;
	}

	public DaoDataModel<RsaCertificate> getCertsDataModel() {
		return certsDataModel;
	}

	public String getAuthorityKeyIndexHex() {
		return authorityKeyIndexHex;
	}

	public void setAuthorityKeyIndexHex(String authorityKeyIndexHex) {
		this.authorityKeyIndexHex = authorityKeyIndexHex;
	}

	public Integer getAuthorityKeyIndexDec() {
		return authorityKeyIndexDec;
	}

	public void setAuthorityKeyIndexDec(Integer authorityKeyIndexDec) {
		this.authorityKeyIndexDec = authorityKeyIndexDec;
	}

	public void setCaIndex() {
		Integer authorityKeyIndex = null;
		if (authorityKeyIndexHex != null && !"".equals(authorityKeyIndexHex)) {
			try {
				authorityKeyIndex = Integer.parseInt(authorityKeyIndexHex, 16);
			} catch (NumberFormatException e) {
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Sec", "is_not_hexadecimal_value", authorityKeyIndexHex);
				FacesUtils.addErrorExceptionMessage(msg);
			}
		} else if (authorityKeyIndexDec != null) {
			authorityKeyIndex = authorityKeyIndexDec;
		}

		if (authorityKeyIndex != null) {
			try {
				securityDao.setCaIndex(userSessionId, activeItem.getId(),
						authorityKeyIndex);
			} catch (DataAccessException e) {
				FacesUtils.addSystemError(e);
				logger.error("", e);
			} catch (UserException e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		authorityKeyIndexHex = null;
		authorityKeyIndexDec = null;
	}

	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("rsaCertsTab")) {
			setParentSectionId(getSectionId());
			setTableState(getSateFromDB(getComponentId()));
		}
	}
	
	public String getTabName() {
		return tabName;
	}

	public String getSectionId() {
		return SectionIdConstants.ISSUING_RSA_KEY;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
	public void updateSubject(){
		String bin = securityDao.get_iss_bin(userSessionId, getEditingItem().getObjectId());
		 getEditingItem().setSubjectId(bin);
	}
}
