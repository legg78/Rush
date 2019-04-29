package ru.bpc.sv2.ui.rules.naming;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.UIInput;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.naming.NameBaseParam;
import ru.bpc.sv2.rules.naming.NameComponent;
import ru.bpc.sv2.rules.naming.NameFormat;
import ru.bpc.sv2.rules.naming.NameIndexRange;
import ru.bpc.sv2.rules.naming.constants.NamingRulesConstants;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbNameFormatsSearch")
public class MbNameFormatsSearch extends AbstractBean {
	private static final long serialVersionUID = 1508938580348349790L;

	private static final Logger logger = Logger.getLogger("RULES");

	private static String COMPONENT_ID = "1191:formatsTable";

	private RulesDao _rulesDao = new RulesDao();

	private NameFormat filter;
	private NameFormat _activeFormat;
	private NameFormat newFormat;

	private HashMap<Integer, String> instNames;
	private ArrayList<SelectItem> institutions;

	private String backLink;
	private boolean selectMode;
	private MbNameFormats formatBean;

	private final DaoDataModel<NameFormat> _formatSource;

	private final TableRowSelection<NameFormat> _itemSelection;

	public MbNameFormatsSearch() {
		pageLink = "rules|naming|formats";
		formatBean = (MbNameFormats) ManagedBeanWrapper.getManagedBean("MbNameFormats");

		_formatSource = new DaoDataModel<NameFormat>() {
			private static final long serialVersionUID = 4835164964627702081L;

			@Override
			protected NameFormat[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new NameFormat[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getNameFormats(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new NameFormat[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getNameFormatsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<NameFormat>(null, _formatSource);

		if (formatBean.isKeepState()) {
			_activeFormat = formatBean.getSavedActiveFormat();
			filter = formatBean.getSavedFilter();
			backLink = formatBean.getSavedBackLink();
			newFormat = formatBean.getSavedNewFormat();
			curMode = formatBean.getSavedCurMode();
			searching = formatBean.isSearching();
			if (newFormat == null)
				newFormat = new NameFormat();

			formatBean.setKeepState(false);

			// set parameter if we returned from parameters form
			if (formatBean.getCurMode() == MbNameFormats.MODE_SELECT_RANGE) {
				MbNameIndexRanges rangeBean = (MbNameIndexRanges) ManagedBeanWrapper
						.getManagedBean("MbNameIndexRanges");
				NameIndexRange range = rangeBean.getActiveIndexRange();
				if (range != null && newFormat != null) {
					newFormat.setIndexRangeId(range.getId());
					newFormat.setIndexRangeName(range.getName());
					rangeBean.setActiveIndexRange(null);
				}
				formatBean.setCurMode(MbNameFormats.MODE_FORMAT);
			}
			if (_activeFormat != null) {
				setInfo();
			}
		} else {
			formatBean.setKeepState(false);
		}
	}

	public DaoDataModel<NameFormat> getFormats() {
		return _formatSource;
	}

	public NameFormat getActiveFormat() {
		return _activeFormat;
	}

	public void setActiveFormat(NameFormat activeFormat) {
		_activeFormat = activeFormat;
	}

	public SimpleSelection getItemSelection() {
		if (_activeFormat == null && _formatSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeFormat != null && _formatSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeFormat.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeFormat = _itemSelection.getSingleSelection();
			formatBean.setFormat(_activeFormat);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeFormat = _itemSelection.getSingleSelection();
		if (_activeFormat != null) {
			setInfo();
		}
	}

	public void setFirstRowActive() {
		_formatSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeFormat = (NameFormat) _formatSource.getRowData();
		selection.addKey(_activeFormat.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeFormat != null) {
			setInfo();
		}
	}

	public void setInfo() {
		MbNameComponentsSearch compSearch = (MbNameComponentsSearch) ManagedBeanWrapper
				.getManagedBean("MbNameComponentsSearch");
		NameComponent componentFilter = new NameComponent();
		componentFilter.setFormatId(_activeFormat.getId());
		compSearch.setFilter(componentFilter);

		NameBaseParam baseParamFilter = new NameBaseParam();
		baseParamFilter.setEntityType(_activeFormat.getEntityType());
		compSearch.setBaseParamFilter(baseParamFilter);
		compSearch.search();
	}

	public void search() {
		clearState();
		clearBeansStates();
		setSearching(true);
	}

	public void clearFilter() {
		filter = null;
		clearState();
		setSearching(false);
	}

	public void clearBeansStates() {
		MbNameComponentsSearch componentsSearch = (MbNameComponentsSearch) ManagedBeanWrapper
				.getManagedBean("MbNameComponentsSearch");
		componentsSearch.clearState();
		componentsSearch.setFilter(null);
	}

	public void storeObjects() {
		formatBean.setSavedFilter(filter);
		formatBean.setSavedActiveFormat(_activeFormat);
		formatBean.setSavedNewFormat(newFormat);
		formatBean.setSavedBackLink(backLink);
		formatBean.setSavedCurMode(curMode);
		// for outer form (e.g. for Products)
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		menu.setKeepState(true);
	}

	public NameFormat getFilter() {
		if (filter == null) {
			filter = new NameFormat();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(NameFormat filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getLabel() != null && filter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getLabel().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null && filter.getEntityType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newFormat = new NameFormat();
		newFormat.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newFormat = (NameFormat) _activeFormat.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newFormat = _activeFormat;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		if (newFormat.getCheckBasePosition() != null && newFormat.getCheckBaseLength() != null
				&& newFormat.getNameLength() != null) {
			if ((newFormat.getCheckBasePosition() + newFormat.getCheckBaseLength() - 1) > newFormat
					.getNameLength()) {
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Rul", "interval_gt_length")));
				return;
			}
		}
		
		if (newFormat.getNameLength()!=null){
			if (newFormat.getEntityType().equals("ENTTACCT") && newFormat.getNameLength()>32){
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
														"ru.bpc.sv2.ui.bundles.Rul", "max_value_field",
														"\""+FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul", "name_length")+"\"",32)));
				return;
			} else if(newFormat.getEntityType().equals("ENTTCARD") && newFormat.getNameLength()>24){
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
										"ru.bpc.sv2.ui.bundles.Rul", "max_value_field", 24)));
				return;
			} else if (newFormat.getNameLength()>200){
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
										"ru.bpc.sv2.ui.bundles.Rul", "max_value_field", 200)));
				return;
			}
			
		}
		try {
			newFormat = _rulesDao.syncNameFormat(userSessionId, newFormat);

			if (isEditMode()) {
				_formatSource.replaceObject(_activeFormat, newFormat);
			} else {
				_itemSelection.addNewObjectToList(newFormat);
			}

			_activeFormat = newFormat;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void validateCheckPosition(FacesContext context, UIComponent toValidate, Object value) {
		Integer newValue = (Integer) value;
		// check position must be less than or equal to name length
		if (newFormat.getNameLength() != null && newFormat.getNameLength().compareTo(newValue) < 0) {
			((UIInput) toValidate).setValid(false);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul", "chk_pos_gt_length");
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(toValidate.getClientId(context), message);
		}
	}

	public void validateCheckBasePosition(FacesContext context, UIComponent toValidate, Object value) {
		Integer newValue = (Integer) value;
		// check base position must be less than or equal to name length
		if (newFormat.getNameLength() != null && newFormat.getNameLength().compareTo(newValue) < 0) {
			((UIInput) toValidate).setValid(false);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul",
					"chk_base_pos_gt_length");
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(toValidate.getClientId(context), message);
		}
		// check base position cannot be equal to check position
		if (newFormat.getCheckPosition() != null && newFormat.getCheckPosition().equals(newValue)) {
			((UIInput) toValidate).setValid(false);
			
			// we need to set value anyway to evade "deadlock" (see validateCheckPosition())
			newFormat.setCheckBasePosition(newValue);
			
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul",
					"chk_base_pos_eq_chk_pos");
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(toValidate.getClientId(context), message);
		}
	}

	public void validateCheckBaseLength(FacesContext context, UIComponent toValidate, Object value) {
		Integer newValue = (Integer) value;
		// check base length must be equal or less than name length
		if (newFormat.getNameLength() != null && newFormat.getNameLength().compareTo(newValue) < 0) {
			((UIInput) toValidate).setValid(false);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul",
					"chk_base_length_gte_length");
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(toValidate.getClientId(context), message);
		}
	}

	public void delete() {
		try {
			_rulesDao.deleteNameFormat(userSessionId, _activeFormat);

			_activeFormat = _itemSelection.removeObjectFromList(_activeFormat);
			if (_activeFormat == null) {
				clearState();
			} else {
				setInfo();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}
	
	public void close() {
	}

	public NameFormat getNewFormat() {
		if (newFormat == null) {
			newFormat = new NameFormat();
		}
		return newFormat;
	}

	public void setNewFormat(NameFormat newFormat) {
		this.newFormat = newFormat;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
		formatBean.setSearching(searching);
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeFormat = null;
		_formatSource.flushCache();
		
		clearBeansStates();
	}

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES);
	}

	public ArrayList<SelectItem> getPadTypes() {
		return getDictUtils().getArticles(DictNames.PAD_TYPES, true, false);
	}

	public ArrayList<SelectItem> getCheckAlgorithms() {
		return getDictUtils().getArticles(DictNames.CHECK_ALGORITHMS, true, false);
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeFormat.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			NameFormat[] formats = _rulesDao.getNameFormats(userSessionId, params);
			if (formats != null && formats.length > 0) {
				_activeFormat = formats[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public HashMap<Integer, String> getInstNames() {
		if (instNames == null)
			instNames = new HashMap<Integer, String>();
		return instNames;
	}

	public String selectIndexRange() {
		MbNameIndexRangesSearch rangesBean = (MbNameIndexRangesSearch) ManagedBeanWrapper
				.getManagedBean("MbNameIndexRangesSearch");
		rangesBean.setBackLink("rules|naming|formats");
		rangesBean.setSelectMode(true);

		formatBean.setCurMode(MbNameFormats.MODE_SELECT_RANGE);
		formatBean.setKeepState(true);
		storeObjects();

		return "rules|naming|ranges";
	}

	public boolean isShowModal() {
		return isEditMode() || isNewMode();
	}

	public boolean isAlgChecking() {
		if (getNewFormat().getCheckAlgorithm() == null
				|| NamingRulesConstants.CHECK_ALGORITHM_NO_CHECKING.equals(getNewFormat()
						.getCheckAlgorithm())) {
			return false;
		}
		return true;
	}
	
	public ArrayList<SelectItem> getIndexRanges() {
		ArrayList<SelectItem> items;
		if (getNewFormat().getEntityType() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Filter[] filters = new Filter[3];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("entityType");
		filters[1].setValue(newFormat.getEntityType());
		filters[2] = new Filter();
		filters[2].setElement("instId");
		if (getNewFormat().getInstId() == null) {
			filters[2].setValue(ApplicationConstants.DEFAULT_INSTITUTION);
		} else {
			filters[2].setValue(newFormat.getInstId());
		}
		
		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters);
		
		try {
			NameIndexRange[] ranges = _rulesDao.getNameIndexRanges(userSessionId, params);
			items = new ArrayList<SelectItem>(ranges.length);
			for (NameIndexRange range: ranges) {
				items.add(new SelectItem(range.getId(), range.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			return new ArrayList<SelectItem>(0);
		}
		
		return items;
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newFormat.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newFormat.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			NameFormat[] formats = _rulesDao.getNameFormats(userSessionId, params);
			if (formats != null && formats.length > 0) {
				newFormat = formats[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancelRange() {
	}

	public void saveRange() {
		try {
			MbNameIndexRangesSearch rangesBean = (MbNameIndexRangesSearch) ManagedBeanWrapper
					.getManagedBean("MbNameIndexRangesSearch");
			rangesBean.checkValues();
			_rulesDao.syncNameIndexRange(userSessionId, rangesBean.getNewIndexRange());
			
			newFormat.setIndexRangeId(rangesBean.getNewIndexRange().getId());
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void createIndexRange() {
		MbNameIndexRangesSearch rangesBean = (MbNameIndexRangesSearch) ManagedBeanWrapper
				.getManagedBean("MbNameIndexRangesSearch");
		rangesBean.add();
		rangesBean.getNewIndexRange().setInstId(newFormat.getInstId());
		rangesBean.getNewIndexRange().setEntityType(newFormat.getEntityType());
	}
	
	public boolean isCardEntityType() {
		return EntityNames.CARD.equals(getNewFormat().getEntityType());
	}
	
	public void changeEntityType(ValueChangeEvent event) {
		String newEntityType = (String) event.getNewValue();
		
		if (EntityNames.CARD.equals(newEntityType)) {
			newFormat.setIndexRangeId(null);
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}
	
	public boolean getAlg(){
		return true;
	}
	
	public void setAlg(boolean value){
		
	}
	

}
