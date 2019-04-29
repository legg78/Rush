package ru.bpc.sv2.ui.common;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;


import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.html.HtmlInputText;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.ConverterException;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.common.PersonId;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.utils.UserException;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbPersonsSearch")
public class MbPersonsSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "personsTable";

	private CommonDao _commonDao = new CommonDao();

	private Integer day;
	private Integer month;
	private Integer year;

	private Person filterPerson;
	private String backLink;
	

	private final DaoDataModel<Person> _personSource;
	private Person _activePerson;
	private Person newPerson;
	private Person detailPerson;
	private final TableRowSelection<Person> _itemSelection;
	private boolean selectMode = false;
	private boolean updateOnCancel = false;

	private MbPerson sessBean;
	private HtmlInputText nameInput;
	private HtmlInputText surnameInput;

	private transient DaoDataModel<?> extObjectSource; // external object's data model

	private String oldLang;

	private boolean allowPasswordChange;

	public MbPersonsSearch() {
		
		sessBean = (MbPerson) ManagedBeanWrapper.getManagedBean("MbPerson");
		clearBeansStates();
		_personSource = new DaoDataModel<Person>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Person[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new Person[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getPersons(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Person[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getPersonsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Person>(null, _personSource);
		restoreFilter();
	}
	
	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbPersonsSearch");
		if (queueFilter==null)
			return;
		clearFilter();
		setSelectMode(true);

		if (queueFilter.containsKey("backLink")){
			backLink=(String)queueFilter.get("backLink");
		}
	}


	public DaoDataModel<Person> getPersons() {
		return _personSource;
	}

	public Person getActivePerson() {
		return _activePerson;
	}

	public void setActivePerson(Person activePerson) {
		_activePerson = activePerson;
	}

	public SimpleSelection getItemSelection() {
		if (_activePerson == null && _personSource.getRowCount() > 0) {
			_personSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activePerson = (Person) _personSource.getRowData();
			selection.addKey(_activePerson.getModelId());
			_itemSelection.setWrappedSelection(selection);
			setBeans();
			try {
				detailPerson = (Person) _activePerson.clone();
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		} else if (_activePerson != null && _personSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activePerson.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activePerson = _itemSelection.getSingleSelection();
		}

		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null
					&& !_itemSelection.getSingleSelection().getModelId().equals(_activePerson.getModelId())) {
				changeSelect = true;
			}
			_activePerson = _itemSelection.getSingleSelection();
	
			if (_activePerson != null) {
				setBeans();
				if (changeSelect) {
					detailPerson = (Person) _activePerson.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setBeans() {
		MbPersonId doc = (MbPersonId) ManagedBeanWrapper.getManagedBean("MbPersonId");
		doc.setIdOfPerson(_activePerson.getPersonId());
		doc.search();
	}

	public Person getFilterPerson() {
		if (filterPerson == null) {
			filterPerson = new Person();
		}
		return filterPerson;
	}

	public void setFilterPerson(Person filterPerson) {
		this.filterPerson = filterPerson;
	}

	public void clearFilter() {
		filterPerson = new Person();

		filters = new ArrayList<Filter>();

		clearBean();
	}

	public void search() {
		setSearching(true);
		_personSource.flushCache();
		_activePerson = null;
		if (_itemSelection != null) {
			_itemSelection.clearSelection();
		}

	}

	public void setFilters() {
		filterPerson = getFilterPerson();
		curLang = userLang;
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		if (filterPerson.getPersonId() != null && filterPerson.getPersonId() != null) {
			paramFilter.setElement("personId");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filterPerson.getPersonId().toString());
			filters.add(paramFilter);
		}

		if (filterPerson.getFirstName() != null && filterPerson.getFirstName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("firstName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filterPerson.getFirstName().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filterPerson.getSecondName() != null
				&& filterPerson.getSecondName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("secondName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filterPerson.getSecondName().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filterPerson.getSurname() != null && filterPerson.getSurname().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("surname");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filterPerson.getSurname().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (filterPerson.getBirthday() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("birthday");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(filterPerson.getBirthday()));
			filters.add(paramFilter);
		}

	}

	public void addPerson() {
		curMode = NEW_MODE;

		newPerson = new Person();
		newPerson.setLang(userLang);
		curLang = newPerson.getLang();
		resetDate();
		initIdsBean(false, null);
	}

	public void viewPerson() {
		curMode = VIEW_MODE;

		resetDate();
		if (_activePerson.getBirthday() != null) {
			Calendar cal = Calendar.getInstance();
			cal.setTime(_activePerson.getBirthday());
			day = cal.get(Calendar.DAY_OF_MONTH);
			month = cal.get(Calendar.MONTH);
			year = cal.get(Calendar.YEAR);
		}
		initIdsBean(true, _activePerson.getPersonId());
	}

	public void editPerson() {
		curMode = EDIT_MODE;

		try {
			newPerson = detailPerson.clone();
		} catch (CloneNotSupportedException e) {
			newPerson = detailPerson;
			logger.error("", e);
		}
		resetDate();

		if (newPerson.getBirthday() != null) {
			Calendar cal = Calendar.getInstance();
			cal.setTime(newPerson.getBirthday());
			day = cal.get(Calendar.DAY_OF_MONTH);
			month = cal.get(Calendar.MONTH);
			year = cal.get(Calendar.YEAR);
		}
		initIdsBean(false, newPerson.getPersonId());
	}

	public void addTranslation() {
		curMode = TRANSL_MODE;

		try {
			newPerson = _activePerson.clone();
		} catch (CloneNotSupportedException e) {
			newPerson = _activePerson;
			logger.error("", e);
		}
		resetDate();
		initIdsBean(true, newPerson.getPersonId());
	}

	public void deletePerson() {
		try {
			_commonDao.removePerson(userSessionId, _activePerson);
			_activePerson = _itemSelection.removeObjectFromList(_activePerson);
			if (_activePerson == null) {
				clearBean();
			} else {
				setBeans();
				detailPerson = (Person) _activePerson.clone();
			}

			FacesUtils.addMessageInfo("Person has been deleted.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			savePerson(null, null);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void saveWithIds() {
		MbPersonId idsBean = (MbPersonId) ManagedBeanWrapper.getManagedBean("MbPersonId");
		try {
			savePerson(idsBean.getStoredIds(), idsBean.getInitialIds());
			updateOnCancel = true;
			// We need to restore previous bean state to use only one bean
			// when actually two documents lists are used on the same page,
			// like on list_persons.jspx: one in modal panel, which is
			// managed from here, and one in bottom tab, which will be seen
			// after we close modal panel; it can contain information about
			// another person.
			// idsBean.clearBean();
			// idsBean.setIdOfPerson(prevPersonId);
			idsBean.setDontSave(false);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void savePerson(ArrayList<PersonId> newIds, ArrayList<PersonId> oldIds)
			throws Exception {
		// if (!checkForm()) {
		// return;
		// }
		
		boolean saveIds = (newIds != null || oldIds != null);
		if (day != null && month != null && year != null) {
			try {
				newPerson.setBirthday(checkDate());
			} catch (IllegalArgumentException e) {
				throw new Exception("Wrong birth date."); // TODO: i18n
			} catch (UserException e){
				throw new Exception(e.getMessage());
			}
		} else if (day == null && month == null && year == null) {
		} else {
			throw new Exception("Wrong birth date."); // TODO: i18n
		}

		if (isEditMode()) {
			if (saveIds) {
				newPerson = _commonDao
						.modifyPersonWithIds(userSessionId, newPerson, newIds, oldIds);
			} else {
				_commonDao.modifyPerson(userSessionId, newPerson);
			}
			
			detailPerson = (Person) newPerson.clone();
			//adjust newProvider according userLang
			if (!userLang.equals(newPerson.getLang())) {
				newPerson = getNodeByLang(newPerson.getPersonId(), userLang);
			}

			// if we modify person on "Persons" form replace old object with new
			// one
			// otherwise do nothing
			if (_personSource.getActivePage() != null) {
				_personSource.replaceObject(_activePerson, newPerson);
			}
		} else {
			if (saveIds) {
				newPerson = _commonDao.addPersonWithIds(userSessionId, newPerson, newIds);
			} else {
				newPerson = _commonDao.addPerson(userSessionId, newPerson);
			}
			detailPerson = (Person) newPerson.clone();
			_itemSelection.addNewObjectToList(newPerson);
		}
		updateOnCancel = true;
		_activePerson = newPerson;
		setBeans();
		curMode = VIEW_MODE;

		if (extObjectSource != null) {
			// TODO: can cause problems with new added objects (because they are
			// added without sorting)
			extObjectSource.flushCache();
		}

		FacesUtils.addMessageInfo("Saved!");
	}

	// /**
	// * <p>Check required fields here. We have to do manual check as
	// * we can't submit several forms simultaneously (and we have 2
	// * forms) so no check will be performed on field if you didn't
	// * set focus on it at least once. Never set <code>"required"</code>
	// * attribute to <code>true</code> because in that case you won't
	// * get invalid value here if there was valid value before.</p>
	// * @return <code>true</code> - if all required fields are set,
	// * <code>false</code> - if at least one field is empty.
	// */
	// private boolean checkForm() {
	// boolean result = true;
	//		
	// MbPersonBindings bindingsBean = (MbPersonBindings)
	// ManagedBeanWrapper.getManagedBean("MbPersonBindings");
	// if (newPerson.getFirstName() == null ||
	// newPerson.getFirstName().trim().length() == 0) {
	// HtmlInputText nameInput = bindingsBean.getNameInput();
	// nameInput.setValid(false);
	//
	// String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
	// "javax.faces.component.UIInput.REQUIRED", nameInput.getLabel());
	// FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg,
	// msg);
	// FacesContext.getCurrentInstance().addMessage(
	// nameInput.getClientId(FacesContext.getCurrentInstance()), message);
	// result = false;
	// }
	// if (newPerson.getSurname() == null ||
	// newPerson.getSurname().trim().length() == 0) {
	// HtmlInputText surnameInput = bindingsBean.getSurnameInput();
	// surnameInput.setValid(false);
	//
	// String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
	// "javax.faces.component.UIInput.REQUIRED", surnameInput.getLabel());
	// FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg,
	// msg);
	// FacesContext.getCurrentInstance().addMessage(
	// surnameInput.getClientId(FacesContext.getCurrentInstance()), message);
	// result = false;
	// }
	//		
	// return result;
	// }

	public Date checkDate() throws UserException{
		Calendar cal = Calendar.getInstance();
		Calendar now = Calendar.getInstance();
		cal.setLenient(false); // it will throw exception if date was set
		// incorrectly
		cal.set(year, month, day);
		if (cal.after(now)){
			String mes = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "birthday_future");
			UserException e = new UserException(mes);
			throw e;
		}
		return cal.getTime();
	}

	public void close() {
		curMode = VIEW_MODE;
		MbPersonId idsBean = (MbPersonId) ManagedBeanWrapper.getManagedBean("MbPersonId");
		idsBean.getPersonIds().flushCache();
		idsBean.setDontSave(false);
	}

	private void initIdsBean(boolean hideIdsButtons, Long personId) {
		MbPersonId idsBean = (MbPersonId) ManagedBeanWrapper.getManagedBean("MbPersonId");
		idsBean.setDontSave(true);
		idsBean.setHideButtons(hideIdsButtons);
		if (newPerson != null && newPerson.getBirthday() != null){
			idsBean.setBirthDay(newPerson.getBirthday());
		}
		idsBean.setCurMode(curMode); // curModes should be equal
		if (isNewMode()) {
			idsBean.setIdOfPerson(-1L);
		} else {
			idsBean.setIdOfPerson(personId);
		}
		idsBean.search();
	}

	private void resetDate() {
		day = null;
		month = null;
		year = null;
	}

	public void changeLanguage() {
		if (_activePerson != null) {
			detailPerson = getNodeByLang(_activePerson.getPersonId(), curLang);
		}
	}

	public Person getNodeByLang(Long id, String lang) {
		try {
			return _commonDao.getPersonById(userSessionId, id, lang);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}
	
	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		curLang = newPerson.getLang();
		Person tmp = getNodeByLang(newPerson.getPersonId(), newPerson.getLang());
		if (tmp != null) {
			newPerson.setFirstName(tmp.getFirstName());
			newPerson.setSurname(tmp.getSurname());
			newPerson.setSecondName(tmp.getSecondName());
		}
	}

	public void cancelEditLanguage() {
		newPerson.setLang(oldLang);
	}

	public String selectPerson() {
		sessBean.setPerson(_activePerson);
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		FacesUtils.setSessionMapValue("updateOnCancel", updateOnCancel);
		return backLink;
	}

	public void select(){
		sessBean.setPerson(_activePerson);
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		FacesUtils.setSessionMapValue("updateOnCancel", updateOnCancel);
	}

	public String cancelSelect() {
		sessBean.setPerson(new Person());
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		FacesUtils.setSessionMapValue("updateOnCancel", updateOnCancel);
		return backLink;
	}

	public void cancel() {
		sessBean.setPerson(new Person());
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		FacesUtils.setSessionMapValue("updateOnCancel", updateOnCancel);
	}

	public String back(){
		return backLink;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activePerson = null;
		detailPerson = null;
		_personSource.flushCache();

		clearBeansStates();
	}

	private void clearBeansStates() {
		MbPersonId idsBean = (MbPersonId) ManagedBeanWrapper.getManagedBean("MbPersonId");
		idsBean.clearBean();
	}

	public ArrayList<SelectItem> getTitles() {
		return getDictUtils().getArticles(DictNames.PERSON_TITLE, false, false);
	}

	public ArrayList<SelectItem> getSuffixes() {
		return getDictUtils().getArticles(DictNames.PERSON_SUFFIX, false, false);
	}

	public ArrayList<SelectItem> getGenders() {
		return getDictUtils().getArticles(DictNames.PERSON_GENDER, false, false);
	}

	public List<SelectItem> getDays() {
		List<SelectItem> arr = new ArrayList<SelectItem>(31);
		arr.add(new SelectItem("1"));
		arr.add(new SelectItem("2"));
		arr.add(new SelectItem("3"));
		arr.add(new SelectItem("4"));
		arr.add(new SelectItem("5"));
		arr.add(new SelectItem("6"));
		arr.add(new SelectItem("7"));
		arr.add(new SelectItem("8"));
		arr.add(new SelectItem("9"));
		arr.add(new SelectItem("10"));
		arr.add(new SelectItem("11"));
		arr.add(new SelectItem("12"));
		arr.add(new SelectItem("13"));
		arr.add(new SelectItem("14"));
		arr.add(new SelectItem("15"));
		arr.add(new SelectItem("16"));
		arr.add(new SelectItem("17"));
		arr.add(new SelectItem("18"));
		arr.add(new SelectItem("19"));
		arr.add(new SelectItem("20"));
		arr.add(new SelectItem("21"));
		arr.add(new SelectItem("22"));
		arr.add(new SelectItem("23"));
		arr.add(new SelectItem("24"));
		arr.add(new SelectItem("25"));
		arr.add(new SelectItem("26"));
		arr.add(new SelectItem("27"));
		arr.add(new SelectItem("28"));
		arr.add(new SelectItem("29"));
		arr.add(new SelectItem("30"));
		arr.add(new SelectItem("31"));
		return arr;
	}

	public List<SelectItem> getYears() {
		List<SelectItem> arr = new ArrayList<SelectItem>();
		for (int i = 1900; i <= 2020; i++) {
			arr.add(new SelectItem(new Integer(i)));
		}
		return arr;
	}

	public Integer getDay() {
		return day;
	}

	public void setDay(Integer day) {
		this.day = day;
	}

	public Integer getMonth() {
		return month;
	}

	public void setMonth(Integer month) {
		this.month = month;
	}

	public Integer getYear() {
		return year;
	}

	public void setYear(Integer year) {
		this.year = year;
	}

	public Converter getConvert() {
		return new Converter() {

			@Override
			public Object getAsObject(FacesContext context, UIComponent component, String newValue)
					throws ConverterException {
				// System.out.println("---===Entered Converter.getAsObject()===---");
				if (newValue == null || newValue.trim().length() < 1) {
					// System.out.println("---===Converter.getAsObject() newValue is NULL===---");

					String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
							"javax.faces.component.UIInput.REQUIRED", ((HtmlInputText) component)
									.getLabel());
					FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
					FacesContext.getCurrentInstance().addMessage(
							component.getClientId(FacesContext.getCurrentInstance()), message);
				}
				return newValue;
			}

			@Override
			public String getAsString(FacesContext context, UIComponent component, Object newValue)
					throws ConverterException {
				// System.out.println("---===Entered Converter.getAsString()===---");
				if (newValue == null) {
					// System.out.println("---===Converter.getAsString() newValue is NULL===---");
					newValue = "";
				}
				return newValue.toString();
			}

		};
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public Person getNewPerson() {
		return newPerson;
	}

	public void setNewPerson(Person newPerson) {
		this.newPerson = newPerson;
	}

	public HtmlInputText getNameInput() {
		return nameInput;
	}

	public void setNameInput(HtmlInputText nameInput) {
		this.nameInput = nameInput;
	}

	public HtmlInputText getSurnameInput() {
		return surnameInput;
	}

	public void setSurnameInput(HtmlInputText surnameInput) {
		this.surnameInput = surnameInput;
	}

	public DaoDataModel<?> getExtObjectSource() {
		return extObjectSource;
	}

	public void setExtObjectSource(DaoDataModel<?> extObjectSource) {
		this.extObjectSource = extObjectSource;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public Person getDetailPerson() {
		return detailPerson;
	}

	public void setDetailPerson(Person detailPerson) {
		this.detailPerson = detailPerson;
	}

	public boolean isAllowPasswordChange() {
		return allowPasswordChange;
	}

	public void setAllowPasswordChange(boolean allowPasswordChange) {
		this.allowPasswordChange = allowPasswordChange;
	}
}
