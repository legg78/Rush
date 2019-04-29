package ru.bpc.sv2.ui.process.monitoring;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessStat;
import ru.bpc.sv2.process.ProgressBarMap;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbProcessStat")
public class MbProcessStat extends AbstractBean {
	private ProcessDao _processDAO = new ProcessDao();

	private final DaoDataModel<ProcessStat> _processStatSource;

	private final TableRowSelection<ProcessStat> _processStatSelection;
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private ProcessStat activeProcessStat;

	private Long sessionId;
	private Integer selectionThreadNum = -1;
	private Integer selectionTraceLevel = 0;

	private String timeZone;
	private Integer currentThread;
	private boolean pollUpdating = false; 
	
	HashMap<Integer, Integer> progressBars;
	HashMap<Integer, ProgressBarMap> progressBars1;
	
	private static String COMPONENT_ID = "statTable";
	private String tabName;
	private String parentSectionId;

	public MbProcessStat() {
		DateFormat df = DateFormat.getInstance();
		df.setCalendar(Calendar.getInstance());
		timeZone = df.getTimeZone().getID();
		_processStatSource = new DaoDataModel<ProcessStat>() {
			@Override
			protected ProcessStat[] loadDaoData(SelectionParams params) {
				if (sessionId == null)
					return new ProcessStat[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					ProcessStat[] processStats = _processDAO.getProcessStat( userSessionId, params);
					loadProgressBars(processStats);
					loadProgressBars1(processStats);
					return processStats;
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProcessStat[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (sessionId == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _processDAO.getProcessStatCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_processStatSelection = new TableRowSelection<ProcessStat>(null, _processStatSource);
	}

	public DaoDataModel<ProcessStat> getProcessSessions() {
		return _processStatSource;
	}

	public SimpleSelection getItemSelection() {
		if (activeProcessStat == null && _processStatSource.getRowCount() > 0) {
			_processStatSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			activeProcessStat = (ProcessStat) _processStatSource.getRowData();
			selection.addKey(activeProcessStat.getModelId());
			_processStatSelection.setWrappedSelection(selection);
		}
		return _processStatSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_processStatSelection.setWrappedSelection(selection);
		activeProcessStat = _processStatSelection.getSingleSelection();
	}

	public Long getUserSessionId() {
		return userSessionId;
	}

	public Integer getSelectionThreadNum() {
		selectionThreadNum = -1;
		if (_processStatSelection != null) {
			if (_processStatSelection.getSingleSelection() != null) {
				selectionThreadNum = _processStatSelection.getSingleSelection().getThreadNumber();
			}
		}
		return selectionThreadNum;
	}
	public Integer getSelectionTraceLevel() {
		selectionTraceLevel = 0;
		if (_processStatSelection != null) {
			if (_processStatSelection.getSingleSelection() != null) {
				selectionTraceLevel = _processStatSelection.getSingleSelection().getTraceLevel();
			}
		}
		return selectionTraceLevel;
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (sessionId != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("sessionId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(sessionId.toString());
			filtersList.add(paramFilter);
		}
		filters = filtersList;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}
	public Long getSessionId() {
		return sessionId;
	}

	public void search() {
		_processStatSource.flushCache();
		progressBars = null;
		activeProcessStat = null;
	}

	public String getTimeZone() {
		return timeZone;
	}

	public HashMap<Integer, Integer> getProgressBars() {
		try {
			for (Integer threadNum : progressBars.keySet()) {
				int barValue = _processDAO.getProgressBarValue( userSessionId, sessionId, threadNum);
				progressBars.put(threadNum, barValue);
			}
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("",ee);
		}
		return progressBars;
	}

	public HashMap<Integer, ProgressBarMap> getProgressBars1() {
		try {
			for (Integer threadNum : progressBars1.keySet()) {
				ProgressBarMap barValue = _processDAO.getProgressBarValue1( userSessionId, sessionId, threadNum);
				progressBars1.put(threadNum, barValue);
			}
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("",ee);
		}
		return progressBars1;
	}
	
	public void setProgressBars(HashMap<Integer, Integer> progressBars) {
		this.progressBars = progressBars;
	}
	
	public void loadProgressBars(ProcessStat[] processStats){
		progressBars = new HashMap<Integer, Integer>();
		for (ProcessStat prcStat : processStats) {
			prcStat.setTraceLevel(OracleTraceLevelActivator.getLevel(_processDAO, userSessionId, sessionId, prcStat.getThreadNumber()));
			progressBars.put(prcStat.getThreadNumber(), 0);
		}
	}
	
	public void setProgressBars1(HashMap<Integer, ProgressBarMap> progressBars1) {
		this.progressBars1 = progressBars1;
	}
	
	public void loadProgressBars1(ProcessStat[] processStats){
		progressBars1 = new HashMap<Integer, ProgressBarMap>();
		for (ProcessStat prcStat : processStats) {			
			progressBars1.put(prcStat.getThreadNumber(), new ProgressBarMap());
		}
	}

	
	public int getProgressBar() {
		try {
			
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("",ee);
		}
		return 0;
	}
	
	public Integer getCurrentThread() {
		if (currentThread == null)
			currentThread = new Integer(1);
		return currentThread;
	}

	public void setCurrentThread(Integer currentThread) {
		this.currentThread = currentThread;
	}
	
	public boolean isPollUpdating(){
		return pollUpdating;
	}
	
	public void setPollUpdating(boolean pollUpdating){
		this.pollUpdating = pollUpdating;
	}
	
	public void checkProgressChanged(){
		List<ProcessStat> old = _processStatSource.getActivePage();	
		SelectionParams params = new SelectionParams();
		setFilters();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		ProcessStat[] current = null;
		try {
			current = _processDAO.getProcessStat( userSessionId, params);
		} catch (DataAccessException e){
			return;
		}
		
		boolean progressChanged = false;
		for (int i = 0; i < old.size() && !progressChanged; i++){
			for (int j = 0; j < current.length && !progressChanged; j++){
				ProcessStat oldStat = old.get(i);
				ProcessStat currStat = current[j];
				if (oldStat.getThreadNumber().equals(currStat.getThreadNumber())){
					if (oldStat.getProgress() != currStat.getProgress()){
						progressChanged = true;
					}
				}
			}
		}
		
		if (progressChanged){
			search();			
		}
	}
	
	private int updateInterval = 10;
	
	public int getUpdateInterval(){
		return updateInterval;
	}
	
	public void setUpdateInterval(int updateInterval){
		this.updateInterval = updateInterval;
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
}
