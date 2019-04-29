package ru.bpc.sv2.ui.cmn;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.cmn.CmnStandard;
import ru.bpc.sv2.cmn.ResponseCodeMapping;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbRespCodesMappings")
public class MbRespCodesMappings extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private CommunicationDao _cmnDao = new CommunicationDao();

	

	private ResponseCodeMapping mappingFilter;
	private ResponseCodeMapping newMapping;
	private LinkedHashMap<Long, CmnStandard> standards;

	public static final String OUT_DEVICE = "out";
	public static final String IN_DEVICE = "in";

	private final DaoDataModel<ResponseCodeMapping> _mappingsSource;
	private final TableRowSelection<ResponseCodeMapping> _itemSelection;
	private ResponseCodeMapping _activeMapping;
	private String tabName;
	private String deviceType = IN_DEVICE;
	private boolean mainForm; // is it main or dependent form
	private String standardName;
	private boolean isChgLang;
	private LinkedHashMap<Long, CmnStandard> standardsLang;
	private List<SelectItem> respReasons;
	
	private static String COMPONENT_ID = "respCodesTable";
	private String parentSectionId;

	public MbRespCodesMappings() {
		pageLink = "cmn|respCodes";
		mainForm = true;

		_mappingsSource = new DaoDataModel<ResponseCodeMapping>() {
			@Override
			protected ResponseCodeMapping[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ResponseCodeMapping[0];
				}
				try {
					setFilters();
					if (!mainForm) {
						params.setRowIndexEnd(-1);
					}
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getResponseCodesMappings(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ResponseCodeMapping[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getResponseCodesMappingsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ResponseCodeMapping>(null, _mappingsSource);
	}

	public DaoDataModel<ResponseCodeMapping> getMappings() {
		return _mappingsSource;
	}

	public ResponseCodeMapping getActiveMapping() {
		return _activeMapping;
	}

	public void setActiveMapping(ResponseCodeMapping activeMapping) {
		_activeMapping = activeMapping;
	}

	public SimpleSelection getItemSelection() {
		if (_activeMapping == null && _mappingsSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeMapping = _itemSelection.getSingleSelection();

		if (_activeMapping != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_mappingsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeMapping = (ResponseCodeMapping) _mappingsSource.getRowData();
		selection.addKey(_activeMapping.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeMapping != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void search() {

		clearBean();
		searching = true;
	}

	public void clearFilter() {
		clearBean();
		mappingFilter = new ResponseCodeMapping();
		searching = false;
	}

	public void setFilters() {
		mappingFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (OUT_DEVICE.equals(deviceType)) {
			paramFilter = new Filter();
			paramFilter.setElement("onlyOut");
			paramFilter.setValue("onlyOut");
			filters.add(paramFilter);
		}
		if (IN_DEVICE.equals(deviceType)) {
			paramFilter = new Filter();
			paramFilter.setElement("onlyIn");
			paramFilter.setValue("onlyIn");
			filters.add(paramFilter);
		}
		if (mappingFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(mappingFilter.getId() + "%");
			filters.add(paramFilter);
		}
		if (mappingFilter.getStandardId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("standardId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(mappingFilter.getStandardId().toString());
			filters.add(paramFilter);
		}
		if (mappingFilter.getRespCode() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("respCode");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(mappingFilter.getRespCode());
			filters.add(paramFilter);
		}
		if (mappingFilter.getDeviceCodeIn() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("deviceCodeIn");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(mappingFilter.getDeviceCodeIn());
			filters.add(paramFilter);
		}
		if (mappingFilter.getDeviceCodeOut() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("deviceCodeOut");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(mappingFilter.getDeviceCodeOut());
			filters.add(paramFilter);
		}
		if (mappingFilter.getRespReason() != null && !"".equals(mappingFilter.getRespReason())) {
			paramFilter = new Filter("respReason", mappingFilter.getRespReason());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newMapping = new ResponseCodeMapping();
		if (getFilter().getStandardId() != null) {
			newMapping.setStandardId(mappingFilter.getStandardId());
		}
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newMapping = (ResponseCodeMapping) _activeMapping.clone();
		} catch (CloneNotSupportedException e) {
			newMapping = _activeMapping;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_cmnDao.deleteResponseCodeMapping(userSessionId, _activeMapping);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
					"resp_code_map_deleted", "(id = " + _activeMapping.getId() + ")");

			_activeMapping = _itemSelection.removeObjectFromList(_activeMapping);
			if (_activeMapping == null) {
				clearBean();
			} else {
				setBeans();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		try {
			StringBuilder sb = new StringBuilder("");

			if (!checkUniqueness(sb)) {
				FacesUtils.addMessageError(new Exception(sb.toString()));
				return;
			}
			if (isNewMode()) {
				newMapping = _cmnDao.addResponseCodeMapping(userSessionId, newMapping);
				_itemSelection.addNewObjectToList(newMapping);
			} else {
				newMapping = _cmnDao.editResponseCodeMapping(userSessionId, newMapping);
				_mappingsSource.replaceObject(_activeMapping, newMapping);
			}
			_activeMapping = newMapping;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
					"resp_code_map_saved"));
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	private boolean checkUniqueness(StringBuilder sb) {
		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		setFilters();
		params.setFilters(filters.toArray(new Filter[filters.size()]));

		ResponseCodeMapping[] maps = _cmnDao.getResponseCodesMappings(userSessionId, params);

		if (OUT_DEVICE.equals(deviceType)) {
			for (ResponseCodeMapping map: maps) {
				if (map.getRespCode().equals(newMapping.getRespCode())
						&& map.getStandardId().equals(newMapping.getStandardId())
						&& !map.getId().equals(newMapping.getId())) {
					sb.append(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
							"code_out_for_rc_exists"));
					return false;
				}
			}
		} else if (IN_DEVICE.equals(deviceType)) {
			for (ResponseCodeMapping map: maps) {
				if (map.getStandardId().equals(newMapping.getStandardId())
						&& map.getDeviceCodeIn().equals(newMapping.getDeviceCodeIn())
						&& !map.getId().equals(newMapping.getId())) {
					sb.append(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
							"code_in_for_rc_exists"));
					return false;
				}
			}
		} else {
			sb.append(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn", "incorrect_device"));
			return false;
		}
		return true;
	}

	public ResponseCodeMapping getFilter() {
		if (mappingFilter == null) {
			mappingFilter = new ResponseCodeMapping();
		}
		return mappingFilter;
	}

	public void setFilter(ResponseCodeMapping mappingFilter) {
		this.mappingFilter = mappingFilter;
	}

	public ResponseCodeMapping getNewMapping() {
		if (newMapping == null) {
			newMapping = new ResponseCodeMapping();
		}
		return newMapping;
	}

	public void setNewMapping(ResponseCodeMapping newMapping) {
		this.newMapping = newMapping;
	}

	public ArrayList<SelectItem> getResponseCodes() {
		return getDictUtils().getArticles(DictNames.RESPONSE_CODE, true, true);
	}
	
	public List<SelectItem> getRespReasons(){
		if (respReasons == null) {
			respReasons = getDictUtils().getLov(LovConstants.UNHOLD_REASONS);
		}
		return respReasons;
	}

	public List<SelectItem> getDeviceCodes() {
		List<SelectItem> items;
		if (getNewMapping().getStandardId() != null) {
			try {
				Long standartIdLong = Long.valueOf(getNewMapping().getStandardId().longValue());
				items = getDictUtils().getLov(getStandardsMap().get(standartIdLong)
						.getRespCodeLovId());
			} catch (NullPointerException e) {
				items = new ArrayList<SelectItem>(0);
				logger.error(e.getMessage(), e);
			}
		} else {
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public void clearBean() {
		_mappingsSource.flushCache();
		_itemSelection.clearSelection();
		_activeMapping = null;
		curLang = userLang;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public LinkedHashMap<Long, CmnStandard> getStandardsMap() {
		if (standards == null) {
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);
				List<Filter> filtersStd = new ArrayList<Filter>();
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(curLang);
				filtersStd.add(paramFilter);
				params.setFilters(filtersStd.toArray(new Filter[filtersStd.size()]));
				CmnStandard[] stds = _cmnDao.getCommStandards(userSessionId, params);
				standards = new LinkedHashMap<Long, CmnStandard>(stds.length);
				for (CmnStandard std: stds) {
					standards.put(std.getId(), std); // Standard's ID is actually an integer
				}
			} catch (Exception e) {
				standards = new LinkedHashMap<Long, CmnStandard>(0);
				logger.error(e.getMessage(), e);
			}
		}
		return standards;
	}
	
	public LinkedHashMap<Long, CmnStandard> getStandardsMapLang() {
		if (isChgLang == true || standardsLang == null){
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);
				List<Filter> filtersStd = new ArrayList<Filter>();
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(curLang);
				filtersStd.add(paramFilter);
				params.setFilters(filtersStd.toArray(new Filter[filtersStd.size()]));
				CmnStandard[] stds = _cmnDao.getCommStandards(userSessionId, params);
				standardsLang = new LinkedHashMap<Long, CmnStandard>(stds.length);
				for (CmnStandard std: stds) {
					standardsLang.put(std.getId(), std); // Standard's ID is actually an integer
				}
				isChgLang = false;
			} catch (Exception e) {
				standardsLang = new LinkedHashMap<Long, CmnStandard>(0);
				logger.error(e.getMessage(), e);
			}
		}
		return standardsLang;
	}

	public ArrayList<SelectItem> getStandards() {
		ArrayList<SelectItem> items;
		getStandardsMap();

		items = new ArrayList<SelectItem>(standards.size());
		//items.add(new SelectItem(""));
		for (CmnStandard std: standards.values()) {
			items.add(new SelectItem(std.getId(), std.getWrittenLabel()));
		}
		return items;
	}

	public String getDeviceType() {
		return deviceType;
	}

	public void setDeviceType(String deviceType) {
		this.deviceType = deviceType;
	}

	public boolean isOutDevice() {
		return OUT_DEVICE.equals(deviceType);
	}

	public boolean getInDevice() {
		return IN_DEVICE.equals(deviceType);
	}

	public SelectItem[] getDeviceTypes() {
		SelectItem[] items = new SelectItem[2];
		items[0] = new SelectItem(IN_DEVICE);
		items[1] = new SelectItem(OUT_DEVICE);
		return items;
	}

	public boolean isMainForm() {
		return mainForm;
	}

	public void setMainForm(boolean mainForm) {
		this.mainForm = mainForm;
	}

	public void changeDeviceType(ValueChangeEvent event) {
		deviceType = (String) event.getNewValue();
		search();
	}

	public String getStandardName() {
		return standardName;
	}

	public void setStandardName(String standardName) {
		this.standardName = standardName;
	}

	public void resetStandards() {
		standards = null; // next time a user requests standards they will be
		// loaded from DB again
	}

	private ResponseCodeMapping getCurrentItem() {
		return (ResponseCodeMapping) Faces.var("item");
	}

	public String getLovValue() {
		ResponseCodeMapping currentItem = getCurrentItem();

		if (currentItem == null
				|| (currentItem.getDeviceCodeIn() == null && currentItem.getDeviceCodeOut() == null)) {
			return null;
		}
		
		CmnStandard standard = getStandardsMap().get(currentItem.getStandardId());
		if (standard == null) return null;
		Integer respCodeLovId = standard.getRespCodeLovId();
		if (respCodeLovId == null) return null;
		
		try {
			List<SelectItem> lovs = getDictUtils().getLov(respCodeLovId);
			for (SelectItem lov: lovs) {
				// lov.getValue() != null is redundant, i think, but
				// during development such situations are possible, unfortunately.
				if (lov.getValue() != null) {
					if ((lov.getValue().equals(currentItem.getDeviceCodeIn()) && IN_DEVICE
							.equals(deviceType))
							|| (lov.getValue().equals(currentItem.getDeviceCodeOut()) && OUT_DEVICE
									.equals(deviceType))) {
						return lov.getLabel();
					}
				}
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return IN_DEVICE.equals(deviceType) ? currentItem.getDeviceCodeIn() : currentItem
				.getDeviceCodeOut();
	}

	public String getComponentId() {
		if (parentSectionId != null && tabName != null) {
			return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
		} else {
			return "1111:respCodesTable";
		}
	}

	public Logger getLogger() {
		return logger;
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		isChgLang = true;
	}
	
	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
}
