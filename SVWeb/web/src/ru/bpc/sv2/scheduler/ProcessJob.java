package ru.bpc.sv2.scheduler;

import org.apache.log4j.Logger;
import org.quartz.*;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.logic.utility.db.UserContextHolder;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.schedule.ScheduledTask;
import ru.bpc.sv2.scheduler.process.ContainerLauncher;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.UserException;
import util.auxil.SessionWrapper;

import java.util.Calendar;
import java.util.Date;

// The StatefulJob interface has been deprecated in favor of new class-level
// annotations for Job classes (using both annotations produces equivalent to
// that of the old StatefulJob interface): 
// - PersistJobDataAfterExecution - instructs the scheduler to re-store the Job's
// JobDataMap contents after execution completes. 
// - DisallowConcurrentExecution - instructs the scheduler to block other
// instances of the same job (by JobKey) from executing when one already is.

@PersistJobDataAfterExecution
@DisallowConcurrentExecution
public class ProcessJob implements Job {
	private static final String DEFAULT_JOB_USER_NAME = "jobuser";
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static final Logger loggerDB = Logger.getLogger("PROCESSES_DB");

	private ProcessDao processDao;
	private RolesDao rolesDao;

	public ProcessJob() {
		try {
			processDao = new ProcessDao();
			rolesDao = new RolesDao();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void execute(JobExecutionContext cntxt) throws JobExecutionException {
		try {
			String userName = DEFAULT_JOB_USER_NAME;
			UserContextHolder.setUserName(userName);
			String triggerName = "TrName:" + cntxt.getTrigger().getKey().getName()
							   + "; gr: " + cntxt.getTrigger().getKey().getGroup() + ";";
			logger.trace(triggerName + "Executing scheduled event at: " + Calendar.getInstance().getTime());
			logger.trace(triggerName + "Getting Job Data Map");

			JobDataMap jobDataMap = cntxt.getJobDetail().getJobDataMap();
			logger.trace(triggerName + "Getting object ScheduledTask from jobDataMap");
			ScheduledTask scheduledTask = (ScheduledTask)jobDataMap.get("ScheduledTask");
			if (scheduledTask == null) {
				cntxt.setResult(ProcessConstants.COMPLETED_ERROR);
				logger.error("ScheduledTask from jobDataMap is null");
				throw new JobExecutionException("Task is null");
			}

			Long userSessionId = rolesDao.setInitialUserContext(null, userName, null);
			Integer containerId = scheduledTask.getPrcId();
			if (scheduledTask.isSkipHolidays()) {
				Filter[] filters = new Filter[2];
				filters[0] = new Filter();
				filters[0].setElement("id");
				filters[0].setValue(containerId);
				filters[1] = new Filter();
				filters[1].setElement("lang");
				filters[1].setValue("LANGENG");

				SelectionParams params = new SelectionParams();
				params.setFilters(filters);
				Integer instId = null;
				try {
					ProcessBO[] containers = processDao.getContainersAll(userSessionId, params);
					if (containers != null && containers.length > 0) {
						instId = containers[0].getInstId();
					}
				} catch (Exception e) {
					logger.error("Use default institution", e);
				}
				Date currentDate = Calendar.getInstance().getTime();
				logger.debug("Check the date " + currentDate);
				boolean skip = processDao.isHoliday(userSessionId, currentDate, instId);
				if (skip) {
					cntxt.setResult(ProcessConstants.COMPLETED_OK);
					logger.warn("ScheduledTask has been skipped because of holiday");
					return;
				}
			}

			ProcessBO container = new ProcessBO();
			container.setId(containerId);

			ContainerLauncher containerLauncher = new ContainerLauncher();
			containerLauncher.setContainer(container);
			containerLauncher.setProcessDao(processDao);
			containerLauncher.setUserName(userName);
			containerLauncher.setUserSessionId(userSessionId);

			try {
				String msg = String.format("Launching scheduled container %s; user session %s", String.valueOf(containerId), userSessionId);
				logger.debug(msg);
				loggerDB.debug(new TraceLogInfo(userSessionId, containerId, msg));
				containerLauncher.launch();
				if (containerLauncher.getContainer().isNotSuccessfullyCompleted()) {
					if (scheduledTask.isStopOnFatal()) {
						stopOnFatal();
					}
				}
				cntxt.setResult(ProcessConstants.COMPLETED_OK);
			} catch (UserException e) {
				logger.error(e.getMessage(), e);
				loggerDB.error(new TraceLogInfo(userSessionId, containerId, e.getMessage()), e);
				cntxt.setResult(ProcessConstants.COMPLETED_ERROR);
				FacesUtils.addErrorExceptionMessage(e);
				if (scheduledTask.isStopOnFatal()) {
					stopOnFatal();
				}
			} catch (Throwable e) {
				logger.error(e.getMessage(), e);
				loggerDB.error(new TraceLogInfo(userSessionId, containerId, e.getMessage()), e);
				cntxt.setResult(ProcessConstants.COMPLETED_ERROR);
				FacesUtils.addSystemError(e);
				if (scheduledTask.isStopOnFatal()) {
					stopOnFatal();
				}
			}

			String msg = triggerName + " " + scheduledTask.getAlias() + ": execution complete; result: " + cntxt.getResult();
			logger.debug(msg);
			loggerDB.debug(new TraceLogInfo(userSessionId, containerId, msg));
		} finally {
			UserContextHolder.setUserName(null);
		}
	}

	private void stopOnFatal() throws JobExecutionException {
		try {
			WebSchedule schedule = WebSchedule.getInstance();
			schedule.cancel();
			processDao.stopSheduler(SessionWrapper.getRequiredUserSessionId());
		} catch (SchedulerException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			throw new JobExecutionException(e.getMessage(), e);
		}
	}
}
