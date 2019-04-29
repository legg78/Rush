package ru.bpc.sv2.ui.aup;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.aup.TagValue;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AuthProcessingDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbTagValues")
public class MbTagValues extends AbstractBean {
	private static final Logger logger = Logger.getLogger("AUTH_PROCESSING");

	private AuthProcessingDao _aupDao = new AuthProcessingDao();

	

	private TagValue filter;
	private TagValue newTagValue;

	private final DaoDataModel<TagValue> _tagValuesSource;
	private final TableRowSelection<TagValue> _itemSelection;
	private TagValue _activeTagValue;
	
	private static String COMPONENT_ID = "tagValuesTable";
	private String tabName;
	private String parentSectionId;

	public MbTagValues() {
		
		
		_tagValuesSource = new DaoDataModel<TagValue>() {
			@Override
			protected TagValue[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new TagValue[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _aupDao.getTagValues(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new TagValue[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _aupDao.getTagValuesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<TagValue>(null, _tagValuesSource);
	}

	public DaoDataModel<TagValue> getTagValues() {
		return _tagValuesSource;
	}

	public TagValue getActiveTagValue() {
		return _activeTagValue;
	}

	public void setActiveTagValue(TagValue activeTagValue) {
		_activeTagValue = activeTagValue;
	}

	public SimpleSelection getItemSelection() {
		if (_activeTagValue == null && _tagValuesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeTagValue != null && _tagValuesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeTagValue.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeTagValue = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTagValue = _itemSelection.getSingleSelection();

		if (_activeTagValue != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_tagValuesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTagValue = (TagValue) _tagValuesSource.getRowData();
		selection.addKey(_activeTagValue.getModelId());
		_itemSelection.setWrappedSelection(selection);

		if (_activeTagValue != null) {
			setBeans();
		}
	}

	public void setBeans() {

	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		filter = new TagValue();
		clearBean();
		searching = false;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter("lang", userLang);
		filters.add(paramFilter);

		if (filter.getAuthId() != null) {
			paramFilter = new Filter("authId", filter.getAuthId());
			filters.add(paramFilter);
		}
		if (filter.getTag() != null) {
			paramFilter = new Filter("tag", filter.getTag());
			filters.add(paramFilter);
		}
	}

	public void add() {
		curMode = NEW_MODE;
	}

	public void edit() {
		curMode = EDIT_MODE;
	}

	public void delete() {
	}

	public void save() {
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public TagValue getFilter() {
		if (filter == null) {
			filter = new TagValue();
		}
		return filter;
	}

	public void setFilter(TagValue filter) {
		this.filter = filter;
	}

	public TagValue getNewTagValue() {
		if (newTagValue == null) {
			newTagValue = new TagValue();
		}
		return newTagValue;
	}

	public void setNewTagValue(TagValue newTagValue) {
		this.newTagValue = newTagValue;
	}

	public void clearBean() {
		_tagValuesSource.flushCache();
		_itemSelection.clearSelection();
		_activeTagValue = null;
	}

	public Logger getLogger() {
		return logger;
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
