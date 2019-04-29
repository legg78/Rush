package ru.bpc.sv2.ui.common;

import java.util.ArrayList;
import java.util.Date;

import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.common.PersonId;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbPersonId")
public class MbPersonId extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMON");

	private CommonDao _commonDao = new CommonDao();

	private PersonId newDocument;
	private Long idOfPerson; // will it help to avoid ambiguity?

	

	private final DaoDataModel<PersonId> _personIdSource;
	private PersonId _activeDocument;
	private final TableRowSelection<PersonId> _itemSelection;

	private ArrayList<PersonId> initialIds; // to keep initial state
	private ArrayList<PersonId> storedIds; // for current work
	private boolean dontSave;
	private long fakeId; // is used for feeRates that are added but not saved yet (required for correct data table behaviour)
	private boolean hideButtons;
	private Date birthDay;

	private PersonId filter;

	private static String COMPONENT_ID = "personIdsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbPersonId() {
		fakeId = -1L;

		
		_personIdSource = new DaoDataModel<PersonId>() {
			@Override
			protected PersonId[] loadDaoData(SelectionParams params) {
				if (idOfPerson == null) {
					return new PersonId[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (dontSave) {

						// if we don't want to immediately save all changes that 
						// have been done to this ids set then we will
						// work with temporary array list which is first 
						// initiated with values from DB. To find changes that were made
						// one more array is created and is not changed (actually 
						// we could read it from DB again but then we would have to 
						// read it from DB :))

						if (storedIds == null) {
							PersonId[] ids = _commonDao.getObjectIds(userSessionId, params);
							storedIds = new ArrayList<PersonId>(ids.length);
							initialIds = new ArrayList<PersonId>(ids.length);
							for (PersonId id : ids) {
								storedIds.add(id);
								initialIds.add(id);
							}
						}
						// TODO: sort
						return (PersonId[]) storedIds.toArray(new PersonId[storedIds.size()]);
					}

					return _commonDao.getObjectIds(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PersonId[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (idOfPerson == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (dontSave && storedIds != null) {
						return storedIds.size();
					}
					return _commonDao.getObjectIdsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<PersonId>(null, _personIdSource);
	}

	public DaoDataModel<PersonId> getPersonIds() {
		return _personIdSource;
	}

	public PersonId getActiveDocument() {
		return _activeDocument;
	}

	public void setActiveDocument(PersonId activeDocument) {
		_activeDocument = activeDocument;
	}

	public SimpleSelection getItemSelection() {
		if (_activeDocument == null && _personIdSource.getRowCount() > 0) {
			_personIdSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activeDocument = (PersonId) _personIdSource.getRowData();
			selection.addKey(_activeDocument.getModelId());
			_itemSelection.setWrappedSelection(selection);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeDocument = _itemSelection.getSingleSelection();
	}

	public void addDocument() {
		curMode = NEW_MODE;
		newDocument = new PersonId();
		newDocument.setObjectId(idOfPerson);
		newDocument.setEntityType(EntityNames.PERSON);
		newDocument.setLang(userLang);
		if (dontSave) {
			newDocument.setId(fakeId--);
			if (storedIds == null) {
				storedIds = new ArrayList<PersonId>();
				initialIds = new ArrayList<PersonId>();
			}
		}
	}

	public void editDocument() {
		try {
			newDocument = (PersonId) _activeDocument.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newDocument = _activeDocument;
		}
		curMode = EDIT_MODE;
	}

	public void saveDocument() {
		try {
			if (existCheckDate()
					&& newDocument.getExpireDate().compareTo(newDocument.getIssueDate()) < 0) {
				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Form",
						"exp_date_gt_iss_date"));
			}
			
			if (newDocument.getIssueDate() != null && newDocument.getIssueDate().compareTo(new Date()) > 0){
				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Form",
						"iss_date_gt_now"));
			}

			if (existCheckDate() && birthDay != null &&
					(newDocument.getExpireDate().compareTo(birthDay) < 0 || 
							newDocument.getIssueDate().compareTo(birthDay) < 0)){
				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Form",
						"birth_less_exp_date_or_iss_date"));
			}

			if (isNewMode()) {
				if (dontSave) {
					storedIds.add(newDocument);
				} else {
					Person person = _commonDao.getPersonById(userSessionId, idOfPerson, newDocument.getLang());
					newDocument.setInstId(person.getInstId());
					newDocument = _commonDao.addPersonId(userSessionId, newDocument);
				}
				_itemSelection.addNewObjectToList(newDocument);
			} else if (isEditMode()) {
				if (dontSave) {
					int index = storedIds.indexOf(_activeDocument);
					storedIds.remove(index);
					storedIds.add(index, newDocument);
				} else {
					newDocument = _commonDao.modifyPersonId(userSessionId, newDocument);
				}
				_personIdSource.replaceObject(_activeDocument, newDocument);
			}

			_activeDocument = newDocument;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	private boolean existCheckDate(){
		return(newDocument.getExpireDate() != null && newDocument.getIssueDate() != null);
	}

//	public Date checkDate(int day, int month, int year) throws Exception {
//		Calendar cal = Calendar.getInstance();
//		cal.setLenient(false);	// it will throw exception if date was set incorrectly
//		cal.set(year, month - 1, day);
//		return cal.getTime();
//	}

	public void deleteDocument() {
		try {
			if (dontSave) {
//    			int index = storedIds.indexOf(_activeDocument);
				storedIds.remove(_activeDocument);
//    			_itemSelection.clearSelection();
//    			if (storedIds.size() > 0) {
//    				if (storedIds.size() > index) {
//    					_activeDocument = storedIds.get(index);
//    				} else {
//    					_activeDocument = storedIds.get(index - 1);
//    				}
//    				SimpleSelection selection = new SimpleSelection();
//    				selection.addKey(_activeDocument.getModelId());
//    				_itemSelection.setWrappedSelection(selection);
//    			} else {
//    				_activeDocument = null;
//    			}
			} else {
				_commonDao.removePersonId(userSessionId, _activeDocument.getId());
			}

			_activeDocument = _itemSelection.removeObjectFromList(_activeDocument);
			if (_activeDocument == null) {
				clearBean();
			}

			FacesUtils.addMessageInfo("ID card has been deleted.");
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public PersonId getNewDocument() {
		if (newDocument == null) {
			newDocument = new PersonId();
		}
		return newDocument;
	}

	public void setNewDocument(PersonId newDocument) {
		this.newDocument = newDocument;
	}

	public ArrayList<SelectItem> getIdTypes() {
		return getDictUtils().getArticles(DictNames.IDENTITY_CARD_TYPE, false);
	}

	public Long getIdOfPerson() {
		return idOfPerson;
	}

	public void setIdOfPerson(Long idOfPerson) {
		this.idOfPerson = idOfPerson;
	}

	public void search() {
		curMode = VIEW_MODE;

		clearBean();
		_activeDocument = null;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeDocument = null;

		storedIds = null;
		initialIds = null;

		_personIdSource.flushCache();
	}

	public ArrayList<PersonId> getInitialIds() {
		return initialIds;
	}

	public void setInitialIds(ArrayList<PersonId> initialIds) {
		this.initialIds = initialIds;
	}

	public ArrayList<PersonId> getStoredIds() {
		return storedIds;
	}

	public void setStoredIds(ArrayList<PersonId> storedIds) {
		this.storedIds = storedIds;
	}

	public boolean isDontSave() {
		return dontSave;
	}

	public void setDontSave(boolean dontSave) {
		this.dontSave = dontSave;
	}

	public boolean isHideButtons() {
		return hideButtons;
	}

	public void setHideButtons(boolean hideButtons) {
		this.hideButtons = hideButtons;
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter("entityType", EntityNames.PERSON);
		filtersList.add(paramFilter);

		paramFilter = new Filter("lang", userLang);
		filtersList.add(paramFilter);
		
		if (idOfPerson != null) {
			paramFilter = new Filter("objectId", idOfPerson);
			filtersList.add(paramFilter);
		}
		filters = filtersList;
	}

	public PersonId getFilter() {
		if (filter == null)
			filter = new PersonId();
		return filter;
	}

	public void setFilter(PersonId filter) {
		this.filter = filter;
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

	public Date getBirthDay() {
		return birthDay;
	}

	public void setBirthDay(Date birthDay) {
		this.birthDay = birthDay;
	}
}
