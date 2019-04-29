package ru.bpc.sv2.ui.process;

import java.io.Serializable;

import ru.bpc.sv2.schedule.ScheduledTask;
import ru.bpc.sv2.scheduler.WebSchedule;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbContainerTasks")
public class MbContainerTasks implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private ScheduledTask task;
	private String tabName;
	private boolean managingNew;

	public MbContainerTasks() {
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void launchErrorMode() {
		WebSchedule schedule = (WebSchedule) ManagedBeanWrapper.getManagedBean("WebSchedule");
		schedule.setErrorMode(task);
	}

	public ScheduledTask getTask() {
		if (task == null)
			task = new ScheduledTask();
		return task;
	}

	public void setTask(ScheduledTask task) {
		this.task = task;
	}

	public boolean isManagingNew() {
		return managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		this.managingNew = managingNew;
	}

}
