package ru.bpc.sv2.ui.security;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv.pctlpeerncr.PCtlPeerNCR;
import ru.bpc.sv.pctlpeerncr.PCtlPeerNCR_Service;
import ru.bpc.sv.pctlpeerwincorndc.PCtlPeerWincorNDC;
import ru.bpc.sv.pctlpeerwincorndc.PCtlPeerWincorNDC_Service;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.hsm.HsmDevice;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AtmDao;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.HsmDao;
import ru.bpc.sv2.logic.SecurityDao;
import ru.bpc.sv2.security.DesKey;
import ru.bpc.sv2.security.SecPrivConstants;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.ui.utils.model.LoadableDetachableModel;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.xml.ws.BindingProvider;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbDesKeysBottom")
public class MbDesKeysBottom extends AbstractBean {

	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("SECURITY");

	private static final String COMPONENT_ID = "desKeysTable";

	private SecurityDao _securityDao = new SecurityDao();

	private HsmDao _hsmDao = new HsmDao();

	private CommunicationDao _cmnDao = new CommunicationDao();

	private AtmDao atmDao = new AtmDao();

	private DesKey desKeyFilter;
	private DesKey newDesKey;

	private final DaoDataModel<DesKey> _keysSource;
	private final TableRowSelection<DesKey> _itemSelection;
	private DesKey _activeDesKey;
	private List<SelectItem> componentNumbers;

	private Long keyId;
	private HashMap<Integer, HsmDevice> hsmsMap;
	private Integer networkId;
	private Integer standardId;
	private Integer deviceId;
	private Integer instId;

	private boolean showWarning;

	private boolean showTranslate = true;

	private List<SelectItem> entityTypes;
	private List<SelectItem> keyLengthForFilter;

	private String tabName;
	private String parentSectionId;
	private ArrayList<SelectItem> keyPrefixes;

	private LoadableDetachableModel<List<SelectItem>> hsmListModel;
	private List<SelectItem> nameFormats;

	public MbDesKeysBottom() {
		pageLink = "sec|desKeys";
		_keysSource = new DaoDataModel<DesKey>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected DesKey[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new DesKey[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setPrivilege(SecPrivConstants.VIEW_TAB_DES_KEY);
					return _securityDao.getDesKeys(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new DesKey[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setPrivilege(SecPrivConstants.VIEW_TAB_DES_KEY);
					return _securityDao.getDesKeysCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<DesKey>(null, _keysSource);
		keyPrefixes = getDictUtils().getArticles(DictNames.ENCRYPTION_KEY_PREFIX, true);
		nameFormats = getDictUtils().getLov(LovConstants.PRINT_FORMATS);
		hsmListModel = new LoadableDetachableModel<List<SelectItem>>() {
			@Override
			protected List<SelectItem> load() {
				final String ACTION_HSM_PERSONALIZATION = "HSMAPSWE";
				ArrayList<SelectItem> items = new ArrayList<SelectItem>();
				try {
					HsmDevice[] hsms = _hsmDao.getHsmLov(userSessionId, instId, null, ACTION_HSM_PERSONALIZATION);
					hsmsMap = new HashMap<Integer, HsmDevice>(hsms.length);
					for (HsmDevice hsm : hsms) {
						items.add(new SelectItem(hsm.getId(), hsm.getId() + " - " + hsm.getDescription()));
						hsmsMap.put(hsm.getId(), hsm);
					}
					logger.debug(String.format("HSM records obtained: %d", items.size()));
				} catch (Exception e) {
					logger.error("", e);
					if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
						FacesUtils.addMessageError(e);
					}
				}
				return items;
			}
		};
	}

	public DaoDataModel<DesKey> getDesKeys() {
		return _keysSource;
	}

	public DesKey getActiveDesKey() {
		return _activeDesKey;
	}

	public void setActiveDesKey(DesKey activeDesKey) {
		_activeDesKey = activeDesKey;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeDesKey == null && _keysSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeDesKey != null && _keysSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeDesKey.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeDesKey = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_keysSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeDesKey = (DesKey) _keysSource.getRowData();
		selection.addKey(_activeDesKey.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeDesKey = _itemSelection.getSingleSelection();
	}

	public void search() {
		clearBean();
		setSearching(true);
	}

	public void clearFilter() {
		desKeyFilter = new DesKey();
		clearBean();
		searching = false;
	}

	public void fullCleanBean() {
		standardId = null;
		networkId = null;
		deviceId = null;
		clearFilter();
	}

	public void setFilters() {
		desKeyFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (desKeyFilter.getEntityType() != null && !desKeyFilter.getEntityType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(desKeyFilter.getEntityType());
			filters.add(paramFilter);
		}

		if (desKeyFilter.getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(desKeyFilter.getObjectId().toString());
			filters.add(paramFilter);
		}
		if (desKeyFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(desKeyFilter.getId() + "%");
			filters.add(paramFilter);
		}
		if (desKeyFilter.getKeyType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("keyType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(desKeyFilter.getKeyType());
			filters.add(paramFilter);
		}

		if (desKeyFilter.getKeyValue() != null && desKeyFilter.getKeyValue().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("key");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(desKeyFilter.getKeyValue().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (desKeyFilter.getKeyPrefix() != null && desKeyFilter.getKeyPrefix().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("keyPrefix");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(desKeyFilter.getKeyPrefix().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (desKeyFilter.getKeyLength() != null && desKeyFilter.getKeyLength().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("keyLength");
			paramFilter.setValue(Integer.valueOf(desKeyFilter.getKeyLength().substring(4), 10));
			filters.add(paramFilter);
		}
		if (desKeyFilter.getHsmId() != null) {
			paramFilter = new Filter("hsmId", desKeyFilter.getHsmId());
			filters.add(paramFilter);
		}
		if (desKeyFilter.getLmkId() != null) {
			paramFilter = new Filter("lmkId", desKeyFilter.getLmkId());
			filters.add(paramFilter);
		}
	}

	public void generate() {
		newDesKey = new DesKey();
		newDesKey.setEntityType(getFilter().getEntityType());
		newDesKey.setObjectId(getFilter().getObjectId());
		keyId = null;
		showWarning = false;
		curMode = NEW_MODE;
	}

	public void translate() {
		newDesKey = new DesKey();
		newDesKey.setEntityType(getFilter().getEntityType());
		newDesKey.setObjectId(getFilter().getObjectId());
		curMode = NEW_MODE;
	}

	public void add() {
		newDesKey = new DesKey();
		newDesKey.setEntityType(getFilter().getEntityType());
		newDesKey.setObjectId(getFilter().getObjectId());
		newDesKey.setCheckKcv(Boolean.TRUE);
		showWarning = false;
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newDesKey = _activeDesKey.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newDesKey = _activeDesKey;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void delete() {
		try {
			_securityDao.deleteDesKey(userSessionId, _activeDesKey);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Sec", "des_key_deleted",
					"(id = " + _activeDesKey.getId() + ")");

			_activeDesKey = _itemSelection.removeObjectFromList(_activeDesKey);
			if (_activeDesKey == null) {
				clearBean();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newDesKey = _securityDao.addDesKey(userSessionId, newDesKey, userLang);
				_itemSelection.addNewObjectToList(newDesKey);
			} else {
				newDesKey = _securityDao.editDesKey(userSessionId, newDesKey, userLang);
				_keysSource.replaceObject(_activeDesKey, newDesKey);
			}
			_activeDesKey = newDesKey;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Sec",
					"des_key_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void generateKey() {
		try {
			boolean overwrite = false;
			if (!newDesKey.isPrintComponents()) {
				newDesKey.setComponentsNumber(null);
				newDesKey.setFormatId(null);
			}

			if (keyId == null) {
				// check if such key exists
				keyId = _securityDao.checkDesKey(userSessionId, newDesKey);
				if (keyId != null) {
					showWarning = true;
					// FacesUtils.addMessageError(new Exception("KEY_EXISTS"));
					return;
				}
			} else {
				// if keyId is not null it means that user has confirmed
				// overwriting of existing key, so we just set this keyId as id
				// for newDesKey and proceed with generating
				newDesKey.setId(keyId);
				overwrite = true;
				showWarning = false;
			}
			newDesKey = _securityDao.generateDesKey(userSessionId, newDesKey, userLang);

			if (overwrite) {
				// remove current instance of key (getModelId() for previous and new key
				// should return same value)
				_itemSelection.removeObjectFromList(newDesKey);
			}
			_itemSelection.addNewObjectToList(newDesKey);
			_activeDesKey = newDesKey;

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancelGenerateKey() {
		keyId = null;
		showWarning = false;
	}

	public void translateKey() {
		try {
			newDesKey.setKeyValue(newDesKey.getKeyValue().toUpperCase());
			newDesKey = _securityDao.translateDesKey(userSessionId, newDesKey, userLang);
			_itemSelection.addNewObjectToList(newDesKey);
			_activeDesKey = newDesKey;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void generateKeyCheckValue() {
		try {
			// String checkValue = _securityDao.generateDesKeyCheckValue(
			// userSessionId, newDesKey);
			// TODO implement in form
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public DesKey getFilter() {
		if (desKeyFilter == null) {
			desKeyFilter = new DesKey();
		}
		return desKeyFilter;
	}

	public void setFilter(DesKey desKeyFilter) {
		this.desKeyFilter = desKeyFilter;
	}

	public DesKey getNewDesKey() {
		if (newDesKey == null) {
			newDesKey = new DesKey();
		}
		return newDesKey;
	}

	public void setNewDesKey(DesKey newDesKey) {
		this.newDesKey = newDesKey;
	}

	public void clearBean() {
		_keysSource.flushCache();
		_itemSelection.clearSelection();
		_activeDesKey = null;
	}

	public ArrayList<SelectItem> getKeyTypes() {
		return getDictUtils().getArticles(DictNames.DES_KEY_TYPE, true, false);
	}

	public List<SelectItem> getKeyTypesEdit() {
		Map<String, Object> paramMap = new HashMap<String, Object>();

		if (getFilter().getEntityType() != null && !getFilter().getEntityType().equals("")) {
			paramMap.put("ENTITY_TYPE", getFilter().getEntityType());
		}

		if (networkId != null && standardId == null) {
			try {
				if (getFilter().getKeySchemaId() != null) {
					paramMap.put("KEY_SCHEMA_ID", getFilter().getKeySchemaId());
					return getDictUtils().getLov(LovConstants.DES_KEY_TYPES, paramMap);
				} else {
					return getDictUtils().getLov(LovConstants.SEC_DES_KEY_TYPE, paramMap);
				}
			} catch (Exception e) {
				logger.error("", e);
			}
		} else if (deviceId != null && standardId == null) {
			try {
				standardId = _cmnDao.getStandardByDeviceId(userSessionId, deviceId);
			} catch (Exception e) {
				logger.error("", e);
			}
		}
		if (standardId != null) {
			paramMap.put("STANDARD_ID", standardId);
			return getDictUtils().getLov(LovConstants.SEC_DES_KEY_TYPE_STD, paramMap);
		}
		return new ArrayList<SelectItem>(0);
	}

	public List<SelectItem> getKeyEntities() {
		if (entityTypes == null) {
			entityTypes = getDictUtils().getLov(LovConstants.KEY_ENTITIES);
		}
		return entityTypes;
	}

	public List<SelectItem> getKeyLengths() {
		List<SelectItem> result;
		if (curMode == VIEW_MODE) {
			if (keyLengthForFilter == null) {
				keyLengthForFilter = getDictUtils().getArticles(DictNames.ENCRYPTION_KEY_LENGTH, true);
			}
			result = keyLengthForFilter;
		} else {
			if (getNewDesKey().getHsmId() != null &&
					(getNewDesKey().getStandardKeyType() != null || getNewDesKey().getKeyType() != null)) {
				HashMap<String, Object> params = new HashMap<String, Object>();
				params.put("hsm_manufacturer", hsmsMap.get(getNewDesKey().getHsmId())
						.getManufacturer());
				try {
					String keyType = _securityDao.getKeyType(userSessionId, newDesKey);
					params.put("key_type", keyType);
				} catch (Exception e) {
					logger.error("", e);
					if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
						FacesUtils.addMessageError(e);
					}
					return new ArrayList<SelectItem>(0);
				}

				result = getDictUtils().getLov(LovConstants.DES_KEY_LENGTH_VALUES, params);
			} else {
				result = new ArrayList<SelectItem>(0);
			}
		}
		return result;
	}

	public List<SelectItem> getComponentNumbers() {
		if (componentNumbers == null) {
			try {
				componentNumbers = new ArrayList<SelectItem>();
				for (Integer i = 2; i <= 9; i++) {
					componentNumbers.add(new SelectItem(i, i.toString()));
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			} finally {
				if (componentNumbers == null)
					componentNumbers = new ArrayList<SelectItem>();
			}
		}
		return componentNumbers;
	}

	public List<SelectItem> getNameFormats() {
		return nameFormats;
	}

	public void changePrintComponents(ValueChangeEvent event) {
		Boolean enabled = (Boolean) event.getNewValue();
		newDesKey.setPrintComponents(enabled);
	}

	public List<SelectItem> getHsms() {
		return hsmListModel.getObject();
	}

	public List<SelectItem> getLmks() {
		return getDictUtils().getLov(LovConstants.LMKS);
	}

	public Long getKeyId() {
		return keyId;
	}

	public List<SelectItem> getKeyPrefixes() {
		List<SelectItem> result;
		if (curMode == VIEW_MODE) {
			result = keyPrefixes;
		} else {
			if (getNewDesKey().getKeyLength() != null && getNewDesKey().getHsmId() != null) {
				HashMap<String, Object> params = new HashMap<String, Object>();
				params.put("hsm_manufacturer", hsmsMap.get(newDesKey.getHsmId()).getManufacturer());
				if (getNewDesKey().getKeyLength() != null) {
					params.put("key_length", newDesKey.getKeyLength());
				}
				result = getDictUtils().getLov(LovConstants.DES_KEY_PREFIXES, params);
			} else {
				result = new ArrayList<SelectItem>(0);
			}
		}
		return result;
	}

	public boolean isShowWarning() {
		return showWarning;
	}

	public boolean isShowTranslate() {
		return showTranslate;
	}

	public void setShowTranslate(boolean showTranslate) {
		this.showTranslate = showTranslate;
	}

	public Integer getNetworkId() {
		return networkId;
	}

	public void setNetworkId(Integer networkId) {
		this.networkId = networkId;
	}

	public Integer getStandardId() {
		return standardId;
	}

	public void setStandardId(Integer standardId) {
		this.standardId = standardId;
	}

	public Integer getDeviceId() {
		return deviceId;
	}

	public void setDeviceId(Integer deviceId) {
		this.deviceId = deviceId;
	}

	public Logger getLogger() {
		return logger;
	}

	public void encryptionKeyChange() {
		String selectedKeyType = _activeDesKey.getKeyType();
		if (!"ENKTTPK".equals(selectedKeyType) && !"ENKTTAK".equals(selectedKeyType))
			return;
		if (!EntityNames.TERMINAL.equals(desKeyFilter.getEntityType()) || desKeyFilter.getObjectId() == null)
			return;


		String atmPlugin;
		try {
			atmPlugin = atmDao.getAtmPlugin(userSessionId, desKeyFilter.getObjectId(), curLang);
		} catch (DataAccessException e) {
			FacesUtils.addSystemError(e);
			return;
		}
		if (atmPlugin == null)
			return;

		if ("APPLWNDC".equals(atmPlugin)) {
			WNDCencKeyChange(desKeyFilter.getObjectId().intValue());
		} else if ("APPLNCR".equals(atmPlugin)) {
			NCRencKeyChange(desKeyFilter.getObjectId().intValue());
		}
		search();
	}

	private void NCRencKeyChange(int terminalId) {
		String endPoint = prepareEndPoint(SettingsConstants.NCR_WS_PORT);
		if (endPoint == null)
			return;

		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		PCtlPeerNCR port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, endPoint);

		ru.bpc.sv.pctlpeerncr.ObjectFactory of = new ru.bpc.sv.pctlpeerncr.ObjectFactory();
		ru.bpc.sv.pctlpeerncr.EncryptionKeyChangeType ek = of.createEncryptionKeyChangeType();
		ek.setTerminalID(terminalId);

		try {
			port.encryptionKeyChange(ek);
		} catch (Exception e) {
			String msg = e.getMessage() + ". Please check front-end settings";
			FacesUtils.addErrorExceptionMessage(msg);
			logger.error("", e);
		}
	}

	private void WNDCencKeyChange(int terminalId) {
		String endPoint = prepareEndPoint(SettingsConstants.WNDC_WS_PORT);
		if (endPoint == null)
			return;

		PCtlPeerWincorNDC_Service service = new PCtlPeerWincorNDC_Service();
		PCtlPeerWincorNDC port = service.getPCtlPeerWincorNDCSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, endPoint);

		ru.bpc.sv.pctlpeerwincorndc.ObjectFactory of = new ru.bpc.sv.pctlpeerwincorndc.ObjectFactory();
		ru.bpc.sv.pctlpeerwincorndc.EncryptionKeyLoadType ek = of.createEncryptionKeyLoadType();
		ek.setTerminalID(terminalId);

		try {
			port.encryptionKeyLoad(ek);
		} catch (Exception e) {
			String msg = e.getMessage() + ". Please check front-end settings";
			FacesUtils.addErrorExceptionMessage(msg);
			logger.error("", e);
		}
	}

	private String prepareEndPoint(String portParamName) {
		String endPoint = settingsDao.getParameterValueV(userSessionId,
				SettingsConstants.FRONT_END_LOCATION, LevelNames.SYSTEM,
				null);
		if (endPoint == null || endPoint.trim().length() == 0) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty", SettingsConstants.FRONT_END_LOCATION);
			FacesUtils.addErrorExceptionMessage(msg);
			return null;
		}
		Double wsPort = settingsDao.getParameterValueN(userSessionId,
				portParamName, LevelNames.SYSTEM, null);
		if (wsPort == null) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
					portParamName);
			FacesUtils.addErrorExceptionMessage(msg);
			return null;
		}
		endPoint = endPoint + ":" + wsPort.intValue();
		return endPoint;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
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
