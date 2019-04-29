package ru.bpc.sv2.ui.common;

import java.util.ArrayList;

import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.PersonId;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbObjectIdsSearch")
public class MbObjectIdsSearch extends AbstractBean{
	private static final Logger logger = Logger.getLogger("ACCOUNTING");

	private CommonDao _commonDao = new CommonDao();

	

	private PersonId filter;
	
	private String backLink;
	private PersonId _activeDocument;
	private final DaoDataModel<PersonId> _documentsSource;
	private final TableRowSelection<PersonId> _itemSelection;
	
	private static String COMPONENT_ID = "personIdsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbObjectIdsSearch() {
		

		_documentsSource = new DaoDataModel<PersonId>() {
			@Override
			protected PersonId[] loadDaoData(SelectionParams params) {
				if (!searching || getFilter().getObjectId() == null)
					return new PersonId[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getObjectIds(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error(e.getMessage(), e);
					FacesUtils.addMessageError(e);
				}
				return new PersonId[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || getFilter().getObjectId() == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getObjectIdsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error(e.getMessage(), e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<PersonId>(null, _documentsSource);
	}

	public DaoDataModel<PersonId> getDocuments() {
		return _documentsSource;
	}

	public PersonId getActiveDocument() {
		return _activeDocument;
	}

	public void setActiveDocument(PersonId activeDocument) {
		_activeDocument = activeDocument;
	}

	public SimpleSelection getItemSelection() {
		if (_activeDocument == null && _documentsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeDocument != null && _documentsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeDocument.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeDocument = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_documentsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeDocument = (PersonId) _documentsSource.getRowData();
		selection.addKey(_activeDocument.getModelId());
		_itemSelection.setWrappedSelection(selection);		
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeDocument = _itemSelection.getSingleSelection();		
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void view() {

	}

	public void close() {

	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();

		filter = getFilter();
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filtersList.add(paramFilter);

		if (filter.getEntityType() != null
				&& !filter.getEntityType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getEntityType());
			filtersList.add(paramFilter);
		}
		if (filter.getObjectId() != null
				&& !filter.getObjectId().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getObjectId().toString());
			filtersList.add(paramFilter);
		}
		if (filter.getIdSeries() != null && filter.getIdSeries().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idSeries");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getIdSeries().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getIdNumber() != null && filter.getIdNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idNumber");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getIdNumber().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getIdIssuer() != null && filter.getIdIssuer().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idIssuer");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getIdIssuer().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
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

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public void clearState() {
		_activeDocument = null;
		_itemSelection.clearSelection();
		_documentsSource.flushCache();
	}
	
	public void clearFilter() {
		filter = new PersonId();		
		clearState();		
	}
	
	public ArrayList<SelectItem> getIdTypes() {
		return getDictUtils().getArticles(DictNames.IDENTITY_CARD_TYPE, false);
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
