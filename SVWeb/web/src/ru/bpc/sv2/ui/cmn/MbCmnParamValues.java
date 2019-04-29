package ru.bpc.sv2.ui.cmn;

import org.apache.log4j.Logger;
import org.richfaces.event.UploadEvent;
import org.richfaces.model.UploadItem;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.cmn.CmnParamValue;
import ru.bpc.sv2.cmn.CmnVersion;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.scale.ScaleConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@RequestScoped
@org.ajax4jsf.model.KeepAlive
@ManagedBean (name = "MbCmnParamValues")
public class MbCmnParamValues extends AbstractBean{
	private static final long serialVersionUID = 1L;
	private static final String MERCHANT_COMMISS_RATE = "MERCHANT_COMMISS_RATE";

	private static final Logger logger = Logger.getLogger("COMMUNICATIONS");
	
	private CommunicationDao _cmnDao = new CommunicationDao();

	private RulesDao _rulesDao = new RulesDao();

    private CmnParamValue searchFilter;
	private CmnParamValue newCmnParamValue;
	
	// additional parameters
	private Integer standardId;
	private Integer versionId;
	private Integer paramId;
	private Integer instId;
	private Long objectId;
	private String valuesEntityType;
	private String paramLevel;
	private String paramEntityType;
	
	private final DaoDataModel<CmnParamValue> _paramValuesSource;
	private final TableRowSelection<CmnParamValue> _itemSelection;
	private CmnParamValue _activeCmnParamValue;
	
	private boolean xmlUploaded;
	
	private static String COMPONENT_ID = "paramValuesTable";
	private String tabName;
	private String parentSectionId;
	private ArrayList<SelectItem> modifiers = null;
	
	public MbCmnParamValues() {
		_paramValuesSource = new DaoDataModel<CmnParamValue>() {
			private static final long serialVersionUID = 1L;
			
			@Override
			protected CmnParamValue[] loadDaoData(SelectionParams params) {
				if (!searching || standardId == null) {
					return new CmnParamValue[0]; 
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (EntityNames.STANDARD_VERSION.equals(valuesEntityType)) {
						return _cmnDao.getVersionParamValues(userSessionId, params);
					} else if (EntityNames.NETWORK_INTERFACE.equals(valuesEntityType)) {
						return _cmnDao.getInterfaceVersionParamValues(userSessionId, params);
					} else if (EntityNames.COM_DEVICE.equals(valuesEntityType)) {
						if (EntityNames.HOST.equals(paramEntityType)) {
							return _cmnDao.getNetDeviceVersionParamValues(userSessionId, params);
						} else if (EntityNames.TERMINAL.equals(paramEntityType)) {
							return _cmnDao.getAcqDeviceVersionParamValues(userSessionId, params);
						}
					} else if (EntityNames.TERMINAL.equals(valuesEntityType)) {
						return _cmnDao.getTerminalVersionParamValues(userSessionId, params);
                    } else if (EntityNames.HSM.equals(valuesEntityType)) {
                        return _cmnDao.getHsmDeviceVersionParamValues(userSessionId, params);
                    }
					return _cmnDao.getCmnParamValues(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CmnParamValue[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || standardId == null) {
					return 0; 
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (EntityNames.STANDARD_VERSION.equals(valuesEntityType)) {
						return _cmnDao.getVersionParamValuesCount(userSessionId, params);
					} else if (EntityNames.NETWORK_INTERFACE.equals(valuesEntityType)) {
						return _cmnDao.getInterfaceVersionParamValuesCount(userSessionId, params);
					} else if (EntityNames.COM_DEVICE.equals(valuesEntityType)) {
						if (EntityNames.HOST.equals(paramEntityType)) {
							return _cmnDao.getNetDeviceVersionParamValuesCount(userSessionId, params);
						} else if (EntityNames.TERMINAL.equals(paramEntityType)) {
							return _cmnDao.getAcqDeviceVersionParamValuesCount(userSessionId, params);
						}
					} else if (EntityNames.TERMINAL.equals(valuesEntityType)) {
						return _cmnDao.getTerminalVersionParamValuesCount(userSessionId, params);
					} else if (EntityNames.HSM.equals(valuesEntityType)) {
                        return _cmnDao.getHsmDeviceVersionParamValuesCount(userSessionId, params);
                    }
					return _cmnDao.getCmnParamValuesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CmnParamValue>(null, _paramValuesSource);
	}
	
	public DaoDataModel<CmnParamValue> getCmnParamValues() {
		return _paramValuesSource;
	}

	public CmnParamValue getActiveCmnParamValue() {
		return _activeCmnParamValue;
	}

	public void setActiveCmnParamValue(CmnParamValue activeCmnParamValue) {
		_activeCmnParamValue = activeCmnParamValue;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeCmnParamValue == null && _paramValuesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeCmnParamValue != null && _paramValuesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCmnParamValue.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeCmnParamValue = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCmnParamValue = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_paramValuesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCmnParamValue = (CmnParamValue) _paramValuesSource.getRowData();
		selection.addKey(_activeCmnParamValue.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void search() {
		searching = true;
		
		// search using new criteria
		_paramValuesSource.flushCache();
		// reset selection
		_itemSelection.clearSelection();
		_activeCmnParamValue = null;		
	}

	public void clearFilter() {
		curLang = userLang;
		searching = false;
		searchFilter = new CmnParamValue();
		clearBean();		
	}
	
	private void setFilters() {
		searchFilter = getFilter();
		filters = new ArrayList<Filter>();

		filters.add(Filter.create("lang", userLang));
		if (standardId != null) {
			filters.add(Filter.create("standardId", standardId));
		}
		if (versionId != null) {
			filters.add(Filter.create("versionId", versionId));
		}
		if (paramId != null) {
			filters.add(Filter.create("paramId", paramId));
		}
		if (objectId != null) {
			filters.add(Filter.create("objectId", objectId));
		} 
		if (valuesEntityType != null) {
			filters.add(Filter.create("entityType", valuesEntityType));
		}
		if (instId != null) {
			filters.add(Filter.create("instId", instId));
		}
		if (paramLevel != null) {
			filters.add(Filter.create("paramLevel", paramLevel));
		}
	}

	public CmnParamValue getFilter() {
		if (searchFilter == null) {
			searchFilter = new CmnParamValue();
		}
		return searchFilter;
	}

	public void setFilter(CmnParamValue searchFilter) {
		this.searchFilter = searchFilter;
	}

	public void edit() {
		try {
			newCmnParamValue = (CmnParamValue) _activeCmnParamValue.clone();
			xmlUploaded = newCmnParamValue.getParamValueXml() != null;
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newCmnParamValue = _activeCmnParamValue;
		}
		if (newCmnParamValue.getEntityType() == null || !newCmnParamValue.getEntityType().equals("")) {
			newCmnParamValue.setEntityType(valuesEntityType);
		}
		if (newCmnParamValue.getInstId() == null && !EntityNames.NETWORK_INTERFACE.equals(valuesEntityType)) {
			newCmnParamValue.setInstId(instId);
		}
	}
	
	public void save() {
		try {
			newCmnParamValue.setObjectId(objectId);
			newCmnParamValue.setVersionId(versionId);
			newCmnParamValue.setEntityType(valuesEntityType);

			_cmnDao.setCmnParamValue(userSessionId, newCmnParamValue);
			searching=true;
			_paramValuesSource.flushCache();
			_itemSelection.clearSelection();
		    _activeCmnParamValue = newCmnParamValue;
		
//			_paramValuesSource.flushCache();
//			FacesUtils.addMessageInfo(FacesUtils.getMessage(
//					"ru.bpc.sv2.ui.bundles.Cmn", "param_value_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	public void delete() {
		try {
			_cmnDao.removeParamValue(userSessionId, _activeCmnParamValue.getId());
			
			_paramValuesSource.flushCache();
			// _activeCmnParamValue = null;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	public void cancel() {
	}
	
	public CmnParamValue getNewCmnParamValue() {
		if (newCmnParamValue == null) {
			newCmnParamValue = new CmnParamValue();
		}
		return newCmnParamValue;
	}

	public void setNewCmnParamValue(CmnParamValue newCmnParamValue) {
		this.newCmnParamValue = newCmnParamValue;
	}

	public void clearBean() {
		if (_activeCmnParamValue != null) {
			if (_itemSelection != null) {
				_itemSelection.unselect(_activeCmnParamValue);
			}
			_activeCmnParamValue = null;
		}
		_paramValuesSource.flushCache();
	}
	
	public void fullCleanBean() {
		paramId = null;
		standardId = null;
		instId = null;
		objectId = null;
		valuesEntityType = null;
		versionId = null;
		paramLevel = null;
		
		clearBean();
	}
	
	/*
    private CmnParamValue getCurrentItem() {
        return (CmnParamValue) Faces.var("item");
    }

    
    public String getLovValue() {
    	CmnParamValue currentItem = getCurrentItem();
    	List<SelectItem> lovs = getDictUtils().getLov(currentItem.getLovId());
		for (SelectItem lov: lovs) {
			// lov.getValue() != null is redundant, i think, but 
			// during development such situations are possible, unfortunately.
			if (lov.getValue() != null) {
				if (lov.getValue().equals(currentItem.getParamValue())
						|| (DataTypes.NUMBER.equals(currentItem.getDataType())  && currentItem.getParamValueN() != null
								&& lov.getValue().equals(String.valueOf(currentItem.getParamValueN().longValue())))) {
					return lov.getLabel();
				}
			}
		}
		if (currentItem.getParamValue() == null)
			return null;
		return currentItem.getParamValue().toString();
	}
    */
    public boolean isDateValue() {
		if (newCmnParamValue != null) {
			return DataTypes.DATE.equals(newCmnParamValue.getDataType());
		}
		return false;
	}

	public boolean isCharValue() {
		if (newCmnParamValue != null) {
			return DataTypes.CHAR.equals(newCmnParamValue.getDataType());
		}
		return true;
	}

	public boolean isNumberValue() {
		if (newCmnParamValue != null) {
			return DataTypes.NUMBER.equals(newCmnParamValue.getDataType());
		}
		return false;
	}
	
	public boolean isClobValue() {
		if (newCmnParamValue != null) {
			return DataTypes.CLOB.equals(newCmnParamValue.getDataType());
		}
		return false;
	}

	public Integer getStandardId() {
		return standardId;
	}

	public void setStandardId(Integer standardId) {
		this.standardId = standardId;
	}

	public Integer getParamId() {
		return paramId;
	}

	public void setParamId(Integer paramId) {
		this.paramId = paramId;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getValuesEntityType() {
		return valuesEntityType;
	}

	public void setValuesEntityType(String valuesEntityType) {
		this.valuesEntityType = valuesEntityType;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getVersionId() {
		return versionId;
	}

	public void setVersionId(Integer versionId) {
		this.versionId = versionId;
	}

	public List<SelectItem> getValuesFromLov() {
		if (LovConstants.ACQUIRING_FEES == _activeCmnParamValue.getLovId()) {
			if (MERCHANT_COMMISS_RATE.equals(_activeCmnParamValue.getSystemName())) {
				Map<String, Object> lovParams = new HashMap<String, Object>(1);
				lovParams.put("entity_type", EntityNames.MERCHANT);
				return getDictUtils().getLov(_activeCmnParamValue.getLovId(), lovParams);
			}
		}
		return getDictUtils().getLov(_activeCmnParamValue.getLovId());
	}

	public List<SelectItem> getVersions() {
		if (standardId == null) {
			return new ArrayList<SelectItem>();
		}
		ArrayList<Filter> filters = new ArrayList<Filter>();
		filters.add(Filter.create("lang", curLang));
		filters.add(Filter.create("standardId", standardId.toString()));

		SelectionParams params = new SelectionParams(filters);
		params.setRowIndexEnd(-1);

		List<SelectItem> items = new ArrayList<SelectItem>();
		try {
			CmnVersion[] versions = _cmnDao.getCmnVersions(userSessionId, params);
			for (CmnVersion ver : versions) {
				items.add(new SelectItem(ver.getId(), ver.getVersionNumber()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		return items;
	}

	public String getParamLevel() {
		return paramLevel;
	}

	public void setParamLevel(String paramLevel) {
		this.paramLevel = paramLevel;
	}

	public String getParamEntityType() {
		return paramEntityType;
	}

	public void setParamEntityType(String paramEntityType) {
		this.paramEntityType = paramEntityType;
	}

	public void uploadListener(UploadEvent event) {
		UploadItem item = event.getUploadItem();
		if (!checkMaximumFileSize(item.getFileSize())) {
			FacesUtils.addMessageError("File size is too big");
			logger.error("File size is too big");
		}
		FileInputStream fis = null;
		try {
			fis = new FileInputStream(item.getFile());

			String str = "";
			int len;
			byte[] buf = new byte[1024];
			while ((len = fis.read(buf)) > 0) {
				str += new String(buf, 0, len, "UTF-8");
			}
			Matcher junkMatcher = (Pattern.compile("^([\\W]+)<")).matcher(str.trim());
			str = junkMatcher.replaceFirst("<");
			newCmnParamValue.setParamValueXml(str);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (fis != null) {
				try {
					fis.close();
				} catch (IOException e) {
					logger.error("", e);
				}
			}
		}
	}

	public boolean isXmlUploaded() {
		return xmlUploaded;
	}

	public void clearUpload() {
		xmlUploaded = false;
	}

	public void setUpload() {
		xmlUploaded = true;
	}
	
	public void viewXml() {
		newCmnParamValue = _activeCmnParamValue;
	}

	public ArrayList<SelectItem> getMods() {
		ArrayList<SelectItem> modsList;
		if (_activeCmnParamValue != null && _activeCmnParamValue.getScaleId() != null) {
				Map<String, Object> paramMap = new HashMap<String, Object>();
	            paramMap.put("SCALE_TYPE", ScaleConstants.COMM_PARAMS_SCALE);
	            paramMap.put("INSTITUTION_ID", (_activeCmnParamValue.getScaleId()==null)?9999:_activeCmnParamValue.getScaleId());
	            modsList =  (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.MODIFIER_LIST, paramMap);
		} else {
			if (modifiers == null) {
				Map<String, Object> paramMap = new HashMap<String, Object>();
	            paramMap.put("SCALE_TYPE", ScaleConstants.COMM_PARAMS_SCALE);
	            modifiers =  (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.MODIFIER_LIST, paramMap);
			}
			return modifiers;
		}
		return modsList;
	}
	
	public String getSelectedParValXml(){
		if (getNewCmnParamValue().getParamValueXml() != null && !getNewCmnParamValue().getParamValueXml().isEmpty()){
			return getNewCmnParamValue().getParamValueXml();
		} else {
			return getNewCmnParamValue().getDefaultXmlValue();
		}
	}
	
	public void setSelectedParValXml(String paramValueXml){
		getNewCmnParamValue().setParamValueXml(paramValueXml);
		save();
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
