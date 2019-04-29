package ru.bpc.sv2.ui.reports;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.ReportLog;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbReportRunLogsSearch")
public class MbReportRunLogsSearch extends AbstractBean{	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("REPORTS");
	
	private ReportsDao _reportsDao = new ReportsDao();
	
	private final DaoDataModel<ReportLog> dataSource;
	private final TableRowSelection<ReportLog> itemSelection;	
	private ReportLog filter;
	private ReportLog activeItem;
	
	public MbReportRunLogsSearch() {
		dataSource = new DaoDataModel<ReportLog>() {
			
			/**
			 * 
			 */
			private static final long serialVersionUID = 1L;

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching){
					try{
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						result = _reportsDao.getReportRunLogsCount( userSessionId, params);
					}catch(Exception e){
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return result;
			}
			
			@Override
			protected ReportLog[] loadDaoData(SelectionParams params) {
				if (searching){
					try{
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						return _reportsDao.getReportRunLogs( userSessionId, params);
					}catch(Exception e){
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}	
				return new ReportLog[0];
			}
		};
		itemSelection = new TableRowSelection<ReportLog>(null, dataSource);
	}
	
	public DaoDataModel<ReportLog> getLogs() {
		return dataSource;
	}
	
	public void search() {
		clearState();
		searching = true;		
	}

	@Override
	public void clearFilter() {
		filter = new ReportLog();
		clearState();
		searching = false;
	}
	
	private void setFilters(){
		filter = getFilter();
		filters = new ArrayList<Filter>();
		if (filter.getEntityType() != null){
			filters.add(new Filter("entityType", filter.getEntityType()));
		}
		if (filter.getObjectId() != null){
			filters.add(new Filter("objectId", filter.getObjectId()));
		}
	}

	public ReportLog getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(ReportLog activeItem) {
		this.activeItem = activeItem;
	}

	public ReportLog getFilter() {
		if (filter == null){
			filter = new ReportLog();
		}
		return filter;
	}

	public void setFilter(ReportLog filter) {
		this.filter = filter;
	}
	
	public void clearState() {
		itemSelection.clearSelection();
		activeItem = null;			
		dataSource.flushCache();
		curLang = userLang;
	}
	
	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (activeItem != null && dataSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			itemSelection.setWrappedSelection(selection);
			activeItem = itemSelection.getSingleSelection();			
		}
		return itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		dataSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (ReportLog) dataSource.getRowData();
		selection.addKey(activeItem.getModelId());
		itemSelection.setWrappedSelection(selection);
		
	}
	
	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection( selection );
		activeItem = itemSelection.getSingleSelection();
	}

}
