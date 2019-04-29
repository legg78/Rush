package ru.bpc.sv2.ui.reports;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbEntityObjectInfoBottom")
public class MbEntityObjectInfoBottom extends AbstractBean{
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger("REPORTS");

	private final DaoDataModel<Parameter> _infoSource;
	
	private final TableRowSelection<Parameter> _itemSelection;
	
	private Parameter activeItem;
	
	private String entityType = null;
	private String objectType = null;
	private Long objectId = null;
	private static String COMPONENT_ID = "entitiesTable";
	private String parentSectionId;

	
	private ReportsDao _reportsDao = new ReportsDao();

	
	public MbEntityObjectInfoBottom() {
		_infoSource = new DaoDataModel<Parameter>() {
			@Override
			protected Parameter[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Parameter[0];
				}
				try {
					setFilters();
					params.setFilters(filters
							.toArray(new Filter[filters.size()]));
					return _reportsDao.getEntityObjectValues(userSessionId, params);
					
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new Parameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters
							.toArray(new Filter[filters.size()]));
					return _reportsDao.getEntityObjectValues(userSessionId,params).length;
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Parameter>(null,
				_infoSource);
	}
	
	public DaoDataModel<Parameter> getDataModel() {
		return _infoSource;
	}
	
	public Parameter getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(Parameter activeItem) {
		this.activeItem = activeItem;
	}
	
	public SimpleSelection getItemSelection() {
		if (activeItem == null
				&& _infoSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (activeItem != null
				&& _infoSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			_itemSelection.setWrappedSelection(selection);
			activeItem = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}
	
	public void setFirstRowActive() {
		_infoSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (Parameter) _infoSource.getRowData();
		selection.addKey(activeItem.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		activeItem = _itemSelection.getSingleSelection();
	}
	
	public void clearFilter() {

	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter paramFilter;
		if (entityType!=null){
			paramFilter = new Filter();
			paramFilter.setElement("entityTypes");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(entityType);
			filters.add(paramFilter);
		}
		if (entityType!=null){
			paramFilter = new Filter();
			paramFilter.setElement("objectTypes");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(objectType);
			filters.add(paramFilter);
		}
		if (entityType!=null){
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(objectId);
			filters.add(paramFilter);
		}
	}
	
	public void search() {
		searching = true;
		_infoSource.flushCache();
		activeItem = null;
	}
	
	public String getComponentId() {
		return parentSectionId + COMPONENT_ID;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}
}
