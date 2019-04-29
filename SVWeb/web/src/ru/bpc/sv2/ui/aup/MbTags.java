package ru.bpc.sv2.ui.aup;


import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.aup.Tag;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AuthProcessingDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbTags")
public class MbTags extends AbstractBean {
	private static final Logger logger = Logger.getLogger("AUTH_PROCESSING");

	private static String COMPONENT_ID = "1718:tagsTable";

	private AuthProcessingDao _aupDao = new AuthProcessingDao();

	private SettingsDao settingsDao = new SettingsDao();
	
	

	private Tag filter;
	private Tag newTag;
	private Tag detailTag;

	private final DaoDataModel<Tag> _tagsSource;
	private final TableRowSelection<Tag> _itemSelection;
	private Tag _activeTag;

	public MbTags() {
		
		pageLink = "aup|tags";
		_tagsSource = new DaoDataModel<Tag>() {
			@Override
			protected Tag[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Tag[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _aupDao.getTags(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Tag[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _aupDao.getTagsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Tag>(null, _tagsSource);
	}

	public DaoDataModel<Tag> getTags() {
		return _tagsSource;
	}

	public Tag getActiveTag() {
		return _activeTag;
	}

	public void setActiveTag(Tag activeTag) {
		_activeTag = activeTag;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeTag == null && _tagsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeTag != null && _tagsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeTag.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeTag = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeTag.getId())) {
				changeSelect = true;
			}
			_activeTag = _itemSelection.getSingleSelection();
	
			if (_activeTag != null) {
				setBeans();
				if (changeSelect) {
					detailTag = (Tag) _activeTag.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_tagsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTag = (Tag) _tagsSource.getRowData();
		selection.addKey(_activeTag.getModelId());
		_itemSelection.setWrappedSelection(selection);

		if (_activeTag != null) {
			setBeans();
			detailTag = (Tag) _activeTag.clone();
		}
	}

	public void setBeans() {

	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		filter = new Tag();
		clearBean();
		searching = false;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getTagType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("tagType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getTagType());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newTag = new Tag();
		newTag.setLang(userLang);
		curLang = newTag.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newTag = (Tag) detailTag.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_aupDao.deleteTag(userSessionId, _activeTag);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Aup",
					"tag_deleted", "(id = " + _activeTag.getId() + ")");

			_activeTag = _itemSelection.removeObjectFromList(_activeTag);
			if (_activeTag == null) {
				clearBean();
			} else {
				setBeans();
				detailTag = (Tag) _activeTag.clone();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newTag = _aupDao.addTag(userSessionId, newTag);
				detailTag = (Tag) newTag.clone();
				_itemSelection.addNewObjectToList(newTag);
			} else {
				newTag = _aupDao.editTag(userSessionId, newTag);
				detailTag = (Tag) newTag.clone();
				if (!userLang.equals(newTag.getLang())) {
					newTag = getNodeByLang(_activeTag.getId(), userLang);
				}
				_tagsSource.replaceObject(_activeTag, newTag);
			}

			_activeTag = newTag;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Aup", "tag_saved"));
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Tag getFilter() {
		if (filter == null) {
			filter = new Tag();
		}
		return filter;
	}

	public void setFilter(Tag filter) {
		this.filter = filter;
	}

	public Tag getNewTag() {
		if (newTag == null) {
			newTag = new Tag();
		}
		return newTag;
	}

	public void setNewTag(Tag newTag) {
		this.newTag = newTag;
	}

	public void clearBean() {
		_tagsSource.flushCache();
		_itemSelection.clearSelection();
		_activeTag = null;
		detailTag = null;
	}

	public ArrayList<SelectItem> getTagTypes() {
		return getDictUtils().getArticles(DictNames.TAG_TYPE, true, false);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailTag = getNodeByLang(detailTag.getId(), curLang);
	}
	
	public Tag getNodeByLang(Integer id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(String.valueOf(id));
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(lang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			Tag[] tags = _aupDao.getTags(userSessionId, params);
			if (tags != null && tags.length > 0) {
				return tags[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public void confirmEditLanguage() {
		curLang = newTag.getLang();
		Tag tmp = getNodeByLang(newTag.getId(), newTag.getLang());
		if (tmp != null) {
			newTag.setName(tmp.getName());
			newTag.setDescription(tmp.getDescription());
		}
	}
	
	public List<Tag> getSelectedItems(){
		return _itemSelection.getMultiSelection();
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public Tag getDetailTag() {
		return detailTag;
	}

	public void setDetailTag(Tag detailTag) {
		this.detailTag = detailTag;
	}

}
