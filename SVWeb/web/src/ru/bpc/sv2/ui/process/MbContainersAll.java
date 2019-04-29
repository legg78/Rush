package ru.bpc.sv2.ui.process;

import java.io.Serializable;

import org.apache.log4j.Logger;

import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.scheduler.WebSchedule;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbContainersAll")
public class MbContainersAll implements Serializable {
	private static final long serialVersionUID = 1L;

	private ProcessBO process;

	private ProcessBO savedFilter;

	private ProcessDao _processDao = new ProcessDao();

	private String tabName;
	private String backLink;
	private boolean _modalMode = false;
	private boolean managingNew;
	private boolean searching;
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private int pageNumber;

	public MbContainersAll() {

	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void start() {
		WebSchedule schedule = WebSchedule.getInstance();
		try {
			schedule.restart();
			_processDao.runSheduler(SessionWrapper.getRequiredUserSessionId());
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void launchImmediately() {
		WebSchedule schedule = WebSchedule.getInstance();

		try {
			schedule.addTaskImmediately(process.getId());
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public boolean isStarted() {
		WebSchedule schedule = WebSchedule.getInstance();
		return schedule.isStarted();
	}

	public void stop() {
		WebSchedule schedule = WebSchedule.getInstance();

		try {
			schedule.cancel();
			_processDao.stopSheduler(SessionWrapper.getRequiredUserSessionId());
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public boolean isModalMode() {
		return _modalMode;
	}

	public void setModalMode(boolean modalMode) {
		_modalMode = modalMode;
	}

	public ProcessBO getProcess() {
		if (process == null) {
			process = new ProcessBO();
			process.setLang(SessionWrapper.getField("language"));
		}
		return process;
	}

	public void setProcess(ProcessBO process) {
		this.process = process;
	}

	public boolean isManagingNew() {
		return managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		this.managingNew = managingNew;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public ProcessBO getSavedFilter() {
		return savedFilter;
	}

	public void setSavedFilter(ProcessBO savedFilter) {
		this.savedFilter = savedFilter;
	}

	public int getPageNumber() {
		return pageNumber;
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
	}

}
