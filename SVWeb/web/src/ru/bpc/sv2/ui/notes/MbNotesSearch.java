package ru.bpc.sv2.ui.notes;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NotesDao;
import ru.bpc.sv2.notes.ObjectNote;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbNotesSearch")
public class MbNotesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("NOTES");

	private NotesDao _notesDao = new NotesDao();

	

	private ObjectNoteFilter filter;
	private ObjectNote _activeNote;
	private ObjectNote newNote;

	private final DaoDataModel<ObjectNote> _notesSource;

	private final TableRowSelection<ObjectNote> _itemSelection;
	
	private static String COMPONENT_ID = "notesTable";
	private String tabName;
	private String parentSectionId;
	private ArrayList<SelectItem> noteTypes;

	public MbNotesSearch() {
		

		_notesSource = new DaoDataModel<ObjectNote>() {
			@Override
			protected ObjectNote[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ObjectNote[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notesDao.getNotes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new ObjectNote[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notesDao.getNotesCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ObjectNote>(null, _notesSource);
		noteTypes = getDictUtils().getArticles(DictNames.NOTE_TYPES, false, false);
	}

	public DaoDataModel<ObjectNote> getNotes() {
		return _notesSource;
	}

	public ObjectNote getActiveNote() {
		return _activeNote;
	}

	public void setActiveNote(ObjectNote activeNote) {
		_activeNote = activeNote;
	}

	public SimpleSelection getItemSelection() {
		if (_activeNote == null && _notesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeNote != null && _notesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeNote.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeNote = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_notesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeNote = (ObjectNote) _notesSource.getRowData();
		selection.addKey(_activeNote.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeNote != null) {
//			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeNote = _itemSelection.getSingleSelection();
		if (_activeNote != null) {
			//setInfo();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new ObjectNoteFilter();
		clearState();
		searching = false;
	}

	public ObjectNoteFilter getFilter() {
		if (filter == null)
			filter = new ObjectNoteFilter();
		return filter;
	}

	public void setFilter(ObjectNoteFilter filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();


		filters.add(new Filter("lang", curLang));
		filters.add(new Filter("showAll", filter.isShowAll() ? "true" : "false"));

		if (filter.getId() != null) {
			filters.add(new Filter("id", filter.getId() + "%"));
		}

		if (StringUtils.isNotEmpty(filter.getNoteType())) {
			filters.add(new Filter("noteType", filter.getNoteType()));
		}

		if (StringUtils.isNotEmpty(filter.getEntityType())) {
			filters.add(new Filter("entityType", filter.getEntityType()));
		}

		if (filter.getObjectId() != null) {
			filters.add(new Filter("objectId",filter.getObjectId().toString()));
		}

		if (StringUtils.isNotEmpty(filter.getText())) {
		    filters.add(new Filter("text", filter.getText().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_") + "%"));
		}

		if (StringUtils.isNotEmpty(filter.getHeader())) {
			filters.add(new Filter("header", filter.getHeader().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_") + "%"));
		}

		if (StringUtils.isNotEmpty(filter.getUserName())) {
			filters.add(new Filter("userName",filter.getUserName().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_") + "%"));
		}
	}

	public void add() {
		newNote = new ObjectNote();
		newNote.setLang(curLang);
		newNote.setEntityType(getFilter().getEntityType());
		newNote.setObjectId(getFilter().getObjectId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newNote = (ObjectNote) _activeNote.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newNote = _activeNote;
		}
		newNote.setLang(curLang);
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		try {
			newNote = _notesDao.addNote(userSessionId, newNote);
			_itemSelection.addNewObjectToList(newNote);

			_activeNote = newNote;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ObjectNote getNewNote() {
		if (newNote == null) {
			newNote = new ObjectNote();
			newNote.setLang(userLang);
			newNote.setEntityType(getFilter().getEntityType());
			newNote.setObjectId(getFilter().getObjectId());
		}
		return newNote;
	}

	public void setNewNote(ObjectNote newNote) {
		this.newNote = newNote;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeNote = null;
		_notesSource.flushCache();
		curLang = userLang;
	}

	public ArrayList<SelectItem> getNoteTypes() {
		return noteTypes;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_notesSource.flushCache();
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
