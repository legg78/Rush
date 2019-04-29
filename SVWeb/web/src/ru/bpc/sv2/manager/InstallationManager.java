package ru.bpc.sv2.manager;


import javax.faces.bean.ApplicationScoped;
import javax.faces.bean.ManagedBean;

import ru.bpc.sv2.logic.ProcessDao;
import util.auxil.SessionWrapper;

@ApplicationScoped
@ManagedBean (name = "InstallationManager")
public class InstallationManager {

	private boolean inProgress;
	private boolean showPanel;
//	private Task activeTask;
	private ProcessDao _processDao = new ProcessDao();
	
	Long userSessionId = null;
	
	public InstallationManager()
	{
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		
	}

	public String completeCurrentTask()
	{
		String toForm ="installation|installation";
//		if (activeTask != null)
//		{
//			_processDao.completeTask( userSessionId, activeTask);
//		}
		return toForm;
	}
	
	public boolean isInProgress() {
		return inProgress;
	}

	public void setInProgress(boolean inProgress) {
		this.inProgress = inProgress;
	}

	public boolean isShowPanel() {
		return showPanel;
	}

	public void setShowPanel(boolean showPanel) {
		this.showPanel = showPanel;
	}

/**
	public Task getActiveTask() {
		return activeTask;
	}

	public void stopInstall()
	{
		inProgress = false;
	}

	public void setActiveTask(Task activeTask) {
		this.activeTask = activeTask;
	}
	*/
}
