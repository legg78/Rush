package ru.bpc.sv2.ui.issuing.personalization;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.rates.RateConstants;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.personalization.KeySchema;
import ru.bpc.sv2.issuing.personalization.PrsMethod;
import ru.bpc.sv2.issuing.personalization.PrsTemplate;
import ru.bpc.sv2.logic.PersonalizationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.UIInput;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbPersoMethodsSearch")
public class MbPersoMethodsSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger("PERSONALIZATION");

	private static String COMPONENT_ID = "1373:methodsTable";

	private final String PVK_KEY = "ENKTPVK";
	private final String IBM_PIN_VERIFY = "PNVM0020";
	private final String PVV_STORE_METHOD_NO = "PVSM0020";
	private final String PIN_STORE_METHOD_NO = "PNSM0020";
	private final String PIN_VERIFY_METHOD_NOT_REQUIRED = "PNVM0030";
	private final String PIN_VERIFY_METHOD_COMBINED = "PNVM0040";
	private final int MODAl_MODE_SIMPLE = 1;
	private final int MODAl_MODE_ADVANCED = 2;

	private PersonalizationDao _personalizationDao = new PersonalizationDao();

	private PrsMethod filter;
	private PrsMethod _activeMethod;
	private PrsMethod newMethod;

	private ArrayList<SelectItem> institutions;
	private List<SelectItem> cvv2DateFormats;

	private final DaoDataModel<PrsMethod> _methodsSource;

	private final TableRowSelection<PrsMethod> _itemSelection;

	private boolean hasPvk;
	private boolean checkHasPvk;
	private boolean pinRequiredOrHasPVK;
	private int modalMode;

	private String tabName;

	public MbPersoMethodsSearch() {
		pageLink = "issuing|perso|methods";
		tabName ="detailsTab";
		_methodsSource = new DaoDataModel<PrsMethod>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected PrsMethod[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new PrsMethod[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getMethods(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new PrsMethod[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getMethodsCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<PrsMethod>(null, _methodsSource);
	}

	public DaoDataModel<PrsMethod> getMethods() {
		return _methodsSource;
	}

	public PrsMethod getActiveMethod() {
		return _activeMethod;
	}

	public void setActiveMethod(PrsMethod activeMethod) {
		_activeMethod = activeMethod;
	}

	public SimpleSelection getItemSelection() {
		if (_activeMethod == null && _methodsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeMethod != null && _methodsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeMethod.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeMethod = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_methodsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeMethod = (PrsMethod) _methodsSource.getRowData();
		selection.addKey(_activeMethod.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeMethod != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeMethod = _itemSelection.getSingleSelection();
		if (_activeMethod != null) {
			setInfo();
		}
	}

	public void setInfo() {
		MbPersoTemplatesSearch templatesSearch = (MbPersoTemplatesSearch) ManagedBeanWrapper
				.getManagedBean("MbPersoTemplatesSearch");
		PrsTemplate templateFilter = new PrsTemplate();
		templateFilter.setMethodId(_activeMethod.getId());
		templatesSearch.setFilter(templateFilter);
		templatesSearch.setInstId(_activeMethod.getInstId());
		templatesSearch.search();
	}

	private void clearBeansStates() {
		MbPersoTemplatesSearch templatesSearch = (MbPersoTemplatesSearch) ManagedBeanWrapper
				.getManagedBean("MbPersoTemplatesSearch");
		templatesSearch.clearState();
		templatesSearch.setFilter(null);
		templatesSearch.setSearching(false);
	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;
	}

	public PrsMethod getFilter() {
		if (filter == null) {
			filter = new PrsMethod();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(PrsMethod filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getKeySchemaId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("keySchemaId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getKeySchemaId());
			filters.add(paramFilter);
		}

		if (filter.getServiceCode() != null && filter.getServiceCode().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("serviceCode");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getServiceCode().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getPinStoreMethod() != null && filter.getPinStoreMethod().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("pinStoreMethod");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getPinStoreMethod().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getPinVerifyMethod() != null && filter.getPinVerifyMethod().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("pinVerifyMethod");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getPinVerifyMethod().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newMethod = new PrsMethod();
		newMethod.setLang(userLang);
		checkHasPvk = false;
		hasPvk = false;
		pinRequiredOrHasPVK = false;
		curMode = NEW_MODE;
		checkPinRequiredOrPVKPresent();
	}

	public void edit() {
		try {
			newMethod = (PrsMethod) _activeMethod.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newMethod = _activeMethod;
		}
		if (newMethod.getKeySchemaId() != null) {
			checkHasPvk = true;
			pinRequiredOrHasPVK = true;	// just no to nullify values
		} else {
			checkHasPvk = false;
			hasPvk = false;
			pinRequiredOrHasPVK = false;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		try {
			if (isNewMode()) {
				newMethod = _personalizationDao.addMethod(userSessionId, newMethod);
				_itemSelection.addNewObjectToList(newMethod);
			} else if (isEditMode()) {
				newMethod = _personalizationDao.modifyMethod(userSessionId, newMethod);
				_methodsSource.replaceObject(_activeMethod, newMethod);
			}

			_activeMethod = newMethod;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_personalizationDao.deleteMethod(userSessionId, _activeMethod);
			_activeMethod = _itemSelection.removeObjectFromList(_activeMethod);
			if (_activeMethod == null) {
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

	public void close() {
		curMode = VIEW_MODE;
	}

	public PrsMethod getNewMethod() {
		if (newMethod == null) {
			newMethod = new PrsMethod();
		}
		return newMethod;
	}

	public void setNewMethod(PrsMethod newMethod) {
		this.newMethod = newMethod;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeMethod = null;
		_methodsSource.flushCache();
		curLang = userLang;

		clearBeansStates();
	}

	public ArrayList<SelectItem> getPvvStoreMethods() {
		return getDictUtils().getArticles(DictNames.PVV_STORE_METHODS);
	}

	public ArrayList<SelectItem> getPinStoreMethods() {
		return getDictUtils().getArticles(DictNames.PIN_STORE_METHODS);
	}

	public List<SelectItem> getPinVerifyMethods() {
		return getDictUtils().getLov(LovConstants.PIN_VERIFY_METHODS);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeMethod.getId().toString());
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
			PrsMethod[] methods = _personalizationDao.getMethods(userSessionId, params);
			if (methods != null && methods.length > 0) {
				_activeMethod = methods[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getKeySchemas() {
		if (newMethod == null || newMethod.getInstId() == null) {
			return new ArrayList<SelectItem>(0);
		}

		ArrayList<SelectItem> keySchemas = null;
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(newMethod.getInstId().toString());
			filtersList.add(paramFilter);

			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			KeySchema[] schemas = _personalizationDao.getKeySchemas(userSessionId, params);
			keySchemas = new ArrayList<SelectItem>(schemas.length);
			for (KeySchema schema : schemas) {
				keySchemas.add(new SelectItem(schema.getId(), schema.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			keySchemas = new ArrayList<SelectItem>(0);
		}

		return keySchemas;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public void changeKeySchema(ValueChangeEvent event) {
		if (event.getNewValue() == null) {
			checkHasPvk = false;
			hasPvk = false;
		} else {
			checkHasPvk = true;
		}
	}

	public boolean getHasPVK() {
		if (getNewMethod().getKeySchemaId() != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(newMethod.getKeySchemaId().toString());
			filters[1] = new Filter();
			filters[1].setElement("keyType");
			filters[1].setValue(PVK_KEY);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			try {
				KeySchema[] schemas = _personalizationDao.getKeySchemas(userSessionId, params);
				if (schemas != null && schemas.length > 0) {
					hasPvk = true;
				} else {
					hasPvk = false;
				}
//				checkHasPvk = false;
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
			}
		}

		return hasPvk;
	}

	public void changeEmvApplSchema(ValueChangeEvent event) {
		if (event.getNewValue() == null) {
			getNewMethod().setIcvvRequired(false);
		}
	}

	public boolean isPinRequired() {
		if (getNewMethod().getServiceCode() == null) {
			return false;
		}

		if (newMethod.getServiceCode().length() == 3
				&& (newMethod.getServiceCode().charAt(2) == '0'
						|| newMethod.getServiceCode().charAt(2) == '3' || newMethod
						.getServiceCode().charAt(2) == '5')) {
			return true;
		}

		return false;
	}
	
	public void checkPinRequiredOrPVKPresent(){
		isPinRequiredOrPVKPresent();
	}

	public boolean isPinRequiredOrPVKPresent() {
		if (isPinRequired() || getHasPVK()) {
			if (!pinRequiredOrHasPVK) {
				getNewMethod().setPvvStoreMethod(null);
				getNewMethod().setPinStoreMethod(null);
				getNewMethod().setPinVerifyMethod(null);
				getNewMethod().setPvkIndex(null);
			}
			pinRequiredOrHasPVK = true;
		} else {
			getNewMethod().setPvvStoreMethod(PVV_STORE_METHOD_NO);
			getNewMethod().setPinStoreMethod(PIN_STORE_METHOD_NO);
			getNewMethod().setPinVerifyMethod(PIN_VERIFY_METHOD_NOT_REQUIRED);
			getNewMethod().setPvkIndex(null);
			pinRequiredOrHasPVK = false;
		}
		return pinRequiredOrHasPVK;
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newMethod.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newMethod.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			PrsMethod[] items = _personalizationDao.getMethods(userSessionId, params);
			if (items != null && items.length > 0) {
				newMethod.setName(items[0].getName());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public boolean isShowDecTable() {
		return IBM_PIN_VERIFY.equals(getNewMethod().getPinVerifyMethod()) || 
		       PIN_VERIFY_METHOD_COMBINED.equals(getNewMethod().getPinVerifyMethod()) ;
	}

	public List<SelectItem> getPvkComponents() {
		return getDictUtils().getLov(LovConstants.PVK_COMPONENTS);
	}

	public List<SelectItem> getPvkFormats() {
		return getDictUtils().getLov(LovConstants.PVK_FORMATS);
	}

	public void validateModuleLength(FacesContext context, UIComponent toValidate, Object value) {
		Integer newValue = (Integer) value;
		// module length must be in multiples of 8
		if (newValue != null && (newValue % 8 != 0)) {
			((UIInput) toValidate).setValid(false);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
					"value_is_multiples_of", FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prs",
							"module_length"), 8);
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(toValidate.getClientId(context), message);
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}
	
	public List<SelectItem> getCvv2DateFormats(){
		if (cvv2DateFormats == null){
			cvv2DateFormats = getDictUtils().getLov(LovConstants.CVV_DATE_FORMAT);
		}
		return cvv2DateFormats;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("TEMPLATESTAB")) {
			MbPersoTemplatesSearch bean = (MbPersoTemplatesSearch) ManagedBeanWrapper
					.getManagedBean("MbPersoTemplatesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public String getSectionId() {
		return SectionIdConstants.ISSUING_PERSO_METHOD;
	}

	public boolean isSimpleMode() {
		return modalMode != MODAl_MODE_ADVANCED;
	}
	public boolean isAdvancedMode() {
		return modalMode == MODAl_MODE_ADVANCED;
	}

	public int getModalMode() {
		return modalMode;
	}
	public void setModalMode(int modalMode) {
		this.modalMode = modalMode;
	}
}
