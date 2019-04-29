package ru.bpc.sv2.ui.process;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbContainersBottomSearch")
public class MbContainersBottomSearch extends AbstractBean {

	private static final long serialVersionUID = 1L;

	private static String COMPONENT_ID = "1068:mainTable";

	private ProcessDao _processDao = new ProcessDao();

	private CommonDao commonDao = new CommonDao();

	private ProcessBO _activeProcess;
	
	private Map<String, String> filter;

	private final DaoDataModel<ProcessBO> _processesSource;
	private final TableRowSelection<ProcessBO> _itemSelection;
	
	private String tabName;
	private String parentSectionId;

	private static final Logger logger = Logger.getLogger("PROCESSES");

	public MbContainersBottomSearch() {

		_processesSource = new DaoDataModel<ProcessBO>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ProcessBO[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new ProcessBO[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					ProcessBO[] result = _processDao.getContainersAll(userSessionId, params);
					return result;
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProcessBO[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					int result = _processDao.getContainersAllCount(userSessionId, params);
					return result;
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ProcessBO>(null, _processesSource);
	}

	public DaoDataModel<ProcessBO> getProcesses() {
		return _processesSource;
	}

	public ProcessBO getActiveProcess() {
		return _activeProcess;
	}

	public void setActiveProcess(ProcessBO activeProcess) {
		_activeProcess = activeProcess;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeProcess == null && _processesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeProcess != null && _processesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeProcess.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeProcess = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addErrorExceptionMessage(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_processesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeProcess = (ProcessBO) _processesSource.getRowData();
		selection.addKey(_activeProcess.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeProcess = _itemSelection.getSingleSelection();
	}

	public void search() {
		clearState();
		setSearching(true);
	}

	public void setFilters() {
		Filter paramFilter = null;
		filters = new ArrayList<Filter>();
		filter = getFilter();

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.containsKey("processId")) {
			paramFilter = new Filter();
			paramFilter.setElement("processId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(String.valueOf(filter.get("processId")));
			filters.add(paramFilter);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public Map<String, String> getFilter() {
		if (filter == null) {
			filter = new HashMap<String, String>();
		}
		return filter;
	}

	public void setFilter(Map<String, String> filter) {
		this.filter = filter;
	}


	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public void clearState() {
		_processesSource.flushCache();
		_itemSelection.clearSelection();
		_activeProcess = null;
	}

	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Logger getLogger() {
		return logger;
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}
	
	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}
