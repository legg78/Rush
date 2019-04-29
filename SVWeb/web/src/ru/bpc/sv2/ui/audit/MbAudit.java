package ru.bpc.sv2.ui.audit;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.audit.AuditableObject;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbAudit")
public class MbAudit extends AbstractBean {

	private static final Logger logger = Logger.getLogger("AUDIT");
	
	private static String COMPONENT_ID = "1030:mainTable";

	private CommonDao _commonDao = new CommonDao();

	
	
	private AuditableObject _activeAudit;
	private AuditableObject filter;
	
	private final DaoDataModel<AuditableObject> _auditableSource;

	private final TableRowSelection<AuditableObject> _itemSelection;

	public MbAudit() {
		pageLink = "audit|audit";
		_auditableSource = new DaoDataModel<AuditableObject>()
		{
			@Override
			protected AuditableObject[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new AuditableObject[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getAuditableObjects( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AuditableObject[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getAuditableObjectsCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AuditableObject>( null, _auditableSource );
	}

	public DaoDataModel<AuditableObject> getAuditables() {
		return _auditableSource;
	}

	public AuditableObject getActiveAudit()	{
		return _activeAudit;
	}

	public void setActiveAudit(AuditableObject activeAudit)	{
		_activeAudit = activeAudit;
	}

	public SimpleSelection getItemSelection() {
		if (_activeAudit == null && _auditableSource.getRowCount() > 0) {
			setFirstRowActive();
		}else if (_activeAudit != null && _auditableSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeAudit.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeAudit = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_auditableSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAudit = (AuditableObject) _auditableSource.getRowData();
		selection.addKey(_activeAudit.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeAudit != null) {
//			setInfo();
		}
	}
	
	public void setItemSelection(SimpleSelection selection)	{
		_itemSelection.setWrappedSelection(selection);
		_activeAudit = _itemSelection.getSingleSelection();
	}

	public void changeAuditableStatus() {
		try {
			AuditableObject obj = _activeAudit.clone();
			obj.setActive(!obj.getActive());
			_commonDao.changeAuditableStatus( userSessionId, obj);
			_auditableSource.flushCache();
			//FacesUtils.addMessageInfo("Done!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}		
	}
	
	public void changeAllAuditableStatus(){
		for (AuditableObject obj : _auditableSource.getActivePage()){
			if(!obj.getActive().equals(obj.getActiveNew())){
				obj.setActive(obj.getActiveNew());
				_commonDao.changeAuditableStatus( userSessionId, obj);
			}
		}
		_auditableSource.flushCache();
	}

	public void search() {
		clearState();
		searching = true;		
	}
	
	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		
		if (filter.getEntityType() != null && filter.getEntityType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getEntityType().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getTableName() != null && filter.getTableName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("tableName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getTableName().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}		
	}
	
	public void clearFilter() {
		filter = new AuditableObject();		
		clearState();
		searching = false;		
	}
	
	public void clearState() {
		_itemSelection.clearSelection();
		_activeAudit = null;			
		_auditableSource.flushCache();
	}
	public void removeFromAuditables() {

	}

	public AuditableObject getFilter() {
		if (filter == null)
			filter = new AuditableObject();
		return filter;
	}

	public void setFilter(AuditableObject filter) {
		this.filter = filter;
	}

	public ArrayList<SelectItem> getEntityTypes() {
		return (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.AUDIT_ENTITY_TYPES);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
