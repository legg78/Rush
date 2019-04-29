package ru.bpc.sv2.scheduler;

import org.apache.log4j.Logger;
import org.quartz.*;
import org.quartz.impl.StdSchedulerFactory;
import org.quartz.impl.matchers.GroupMatcher;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.schedule.CronFormatException;
import ru.bpc.sv2.schedule.ScheduledTask;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.UserException;

import javax.faces.bean.ApplicationScoped;
import javax.faces.bean.ManagedBean;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

import static org.quartz.CronScheduleBuilder.cronSchedule;
import static org.quartz.JobBuilder.newJob;
import static org.quartz.SimpleScheduleBuilder.simpleSchedule;
import static org.quartz.TriggerBuilder.newTrigger;

@ApplicationScoped
@ManagedBean (name = "WebSchedule")
public class WebSchedule {

	private static final Logger logger = Logger.getLogger("SCHEDULER");

	private static WebSchedule instance = null;
	private SchedulerFactory schedulerFactory = null;

	private final static String NORMAL_GROUP = "Normal_group";
	private final static String ERROR_GROUP = "Error_group";

	public WebSchedule() {
		schedulerFactory = new StdSchedulerFactory();
	}

	public static synchronized WebSchedule getInstance() {
		if (instance == null)
			instance = new WebSchedule();
		return instance;
	}

	public boolean isStarted() {
		try {
			Scheduler scheduler = schedulerFactory.getScheduler();
			return scheduler.isStarted();
		} catch (SchedulerException e) {
			logger.error("", e);
		}
		return false;
	}

	public void setListners() throws SchedulerException {
		logger.info("Setting listeners");
		TaskJobListener jobListener = new TaskJobListener();
		jobListener.setName("Global_job_listener");
		TaskTriggerListener triggerListener = new TaskTriggerListener();
		triggerListener.setName("Global_trigger_listener");
		Scheduler scheduler = schedulerFactory.getScheduler();
		scheduler.getListenerManager().addJobListener(jobListener);
		scheduler.getListenerManager().addTriggerListener(triggerListener);
	}

	public void restart() throws Exception {
		Scheduler scheduler = schedulerFactory.getScheduler();
		if (scheduler.isStarted()) {
			logger.info("Shutting down scheduler...");
			scheduler.shutdown();
			logger.info("Scheduler has been shut down.");
		}
		scheduler.clear();
		addJobs(scheduler);
		logger.info("Starting scheduler...");
		scheduler.start();
		setListners();

		logger.info("All scheduled jobTasks rescheduling");
	}

	private void addJobs(Scheduler scheduler) throws Exception {
		logger.info("Getting list of scheduled jobTasks");
		ProcessDao _processDao = new ProcessDao();
		List<ScheduledTask> scheduledTasks = new ArrayList<ScheduledTask>();

		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(SystemConstants.ENGLISH_LANGUAGE);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);

		ScheduledTask[] tasks;
		try {
			 tasks = _processDao.getSchedulerTasks(params);
		} catch (UserException e){
			String msg = e.getMessage();
			int containerId = (Integer) e.getDetails();
			String fmsg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "schedule_preparation_error", msg, containerId);
			throw new UserException(fmsg);
		} 
        
		for (ScheduledTask task : tasks) {
			if (task.getCronString() == null || task.getCronString().equals("") || !task.isActive()) {
				// TODO: delete or unschedule
				if (scheduler.checkExists(JobKey.jobKey(task.getAlias().replaceAll(" ", "_"),
						NORMAL_GROUP))) {
					removeScheduledTask(task);
				}
				continue;
			}

			
			task.setFormedCronString(task.getCronString());

			scheduledTasks.add(task);
		}

		logger.info("Scheduled jobTasks list gotten successfully");

		logger.info("Iterating jobTasks list");

		for (ScheduledTask jobTask : scheduledTasks) {
			this.addScheduledTask(jobTask);
		}
		logger.info("Iterating finished");
	}
	
	public void cancel() throws SchedulerException {
		logger.info("All scheduled jobTasks cancelling");

		Scheduler scheduler = schedulerFactory.getScheduler();

		if (!scheduler.isShutdown()) {
			scheduler.shutdown();
		}
		logger.info("Shutdown complete");

	}

	public JobDetail createProcessJobDetail(ScheduledTask jobTask) throws Exception {
		logger.info("Setting ProcessJobDetail name: " +
					jobTask.getAlias().replaceAll(" ", "_") +
					", group: " + NORMAL_GROUP);

		JobDetail jobDetail = newJob(ProcessJob.class) // just for autoformat
							.withIdentity(jobTask.getAlias().replaceAll(" ", "_"), NORMAL_GROUP) // just for autoformat
							.requestRecovery(false) // ask scheduler to re-execute this job if it was in progress when the scheduler went down
							.build();

		jobDetail.getJobDataMap().put("ScheduledTask", jobTask);
		jobDetail.getJobDataMap().put("ErrorMode", Boolean.FALSE);

		return jobDetail;
	}

	public JobDetail createTraceJobDetail(ScheduledTask jobTask, Long sessionId, Integer threadNumber) throws Exception {
		logger.info("Setting TraceJobDetail name: " +
					jobTask.getAlias().replaceAll(" ", "_") +
					", group: " + NORMAL_GROUP);

		JobDetail jobDetail = newJob(TraceJob.class)
							.withIdentity(jobTask.getAlias().replaceAll(" ", "_"), NORMAL_GROUP)
							.requestRecovery(false)
							.build();

		jobDetail.getJobDataMap().put("ScheduledTask", jobTask);
		jobDetail.getJobDataMap().put("ErrorMode", Boolean.FALSE);
		jobDetail.getJobDataMap().put("SessionId", sessionId);
		jobDetail.getJobDataMap().put("ThreadNumber", threadNumber);

		return jobDetail;
	}

	public void addScheduledTask(ScheduledTask jobTask) throws Exception {
		Scheduler scheduler = schedulerFactory.getScheduler();

		// why do we start scheduler? 
		// startScheduler(scheduler);

		CronTrigger trigger = newTrigger()
				.withIdentity(TriggerKey.triggerKey(jobTask.getAlias().replaceAll(" ", "_"), NORMAL_GROUP))
				.withSchedule(cronSchedule(jobTask.getCronString()))
				.build();
		
		JobDetail jobDetail = createProcessJobDetail(jobTask);

		logger.info("Scheduling jobTask: " + jobTask.getAlias().replaceAll(" ", "_"));
		scheduler.scheduleJob(jobDetail, trigger);

		logger.info("Job scheduled successfully");
	}

	public void addTaskInErrorMode(ScheduledTask jobTask) throws SchedulerException,
			ParseException, CronFormatException {
		logger.info("Scheduling jobTask in error mode: " + jobTask.getAlias() + ", cron: 10 sec");

		Scheduler scheduler = schedulerFactory.getScheduler();
		startScheduler(scheduler);

		//cancel if repeat or active time for error mode are not defined 
		if (jobTask.getTimeActive() == null || jobTask.getTimeActive().equals(new Long(0))
				|| jobTask.getTimePeriod() == null || jobTask.getTimePeriod().equals(new Long(0))) {
			logger.info("Error mode was not started as error periods are not defined");
			return;
		}

		long startTime = System.currentTimeMillis() + jobTask.getTimePeriod() * 60 * 1000L;
		long endTime = System.currentTimeMillis() + jobTask.getTimeActive() * 60 * 1000L + jobTask.getTimePeriod() * 60 * 1000L;
		long errorRepeatPeriod = jobTask.getTimePeriod() * 60 * 1000L;
		logger.info("start:" + startTime + "; end: " + endTime + "; period: "
				+ errorRepeatPeriod);
//		long startTime = System.currentTimeMillis() + 15000L;
//		long endTime = System.currentTimeMillis() + 40000L;
//		long errorRepeatPeriod = 10L * 1000L;

		SimpleTrigger trigger = newTrigger().withIdentity(jobTask.getAlias().replaceAll(" ", "_"),
				ERROR_GROUP).startAt(new Date(startTime)).endAt(new Date(endTime)).withSchedule(
				simpleSchedule().withIntervalInMilliseconds(errorRepeatPeriod)
						.withMisfireHandlingInstructionNextWithRemainingCount().repeatForever())
				.withPriority(10).build();

		JobDetail jobDetail = newJob(ProcessJob.class).withIdentity(
				jobTask.getAlias().replaceAll(" ", "_"), ERROR_GROUP).build();

		jobDetail.getJobDataMap().put("ScheduledTask", jobTask);
		jobDetail.getJobDataMap().put("ErrorMode", Boolean.TRUE);

		//delete job after executing
//		jobDetail.setDurability(false);
		if (scheduler.isStarted()) {
			scheduler.scheduleJob(jobDetail, trigger);
		}
		logger.info("Job scheduled successfully");
	}

	public void setErrorMode(ScheduledTask jobTask) {
		try {
			//TODO remove setErrorMode method. It's just for debugging
			Scheduler scheduler = schedulerFactory.getScheduler();
//			scheduler.deleteJob(jobTask.getAlias().replaceAll(" ", "_"), REPORT_GROUP);
//			scheduler.pauseTrigger(jobTask.getAlias().replaceAll(" ", "_"), REPORT_GROUP);
			TriggerKey key = TriggerKey.triggerKey(jobTask.getAlias(), NORMAL_GROUP);
			CronTrigger trigger = (CronTrigger) scheduler.getTrigger(key);
			Date nextFireTime = new Date();
			logger.info("Current time: " + nextFireTime.getTime());
			logger.info("Next fire time in normal mode: "
					+ trigger.getNextFireTime().getTime());
			long millis = nextFireTime.getTime() + 15000;
			nextFireTime.setTime(millis);

			// TODO: shouldn't we set here ERROR_GROUP?
			trigger = (CronTrigger) newTrigger().withIdentity(trigger.getKey().getName() + "_e",
					NORMAL_GROUP).startAt(nextFireTime).build();
			Date scheduledTime = scheduler.rescheduleJob(key, trigger);
			logger.info("Next fire time in error mode: " + scheduledTime.getTime());

		} catch (SchedulerException e) {
			logger.error("", e);
		}
	}

	public void modifyScheduledTask(ScheduledTask jobTask) {
		try {
			Scheduler scheduler = schedulerFactory.getScheduler();
			if (scheduler.checkExists(JobKey.jobKey(jobTask.getAlias().replaceAll(" ", "_"), NORMAL_GROUP))) {
				TriggerKey key = TriggerKey.triggerKey(jobTask.getAlias().replaceAll(" ", "_"), NORMAL_GROUP);
				CronTrigger trigger = newTrigger()
						.withIdentity(key)
						.withSchedule(cronSchedule(jobTask.getCronString()))
						.build();
				scheduler.rescheduleJob(key, trigger);
			} else {
				addScheduledTask(jobTask);
			}
//			
//			this.removeScheduledTask(jobTask);
//			this.addScheduledTask(jobTask);
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	public void removeScheduledTask(ScheduledTask jobTask) throws SchedulerException {
		logger.info("Removing scheduled jobTask: " + jobTask.getAlias() + ", cron: "
				+ jobTask.getCronString());

		Scheduler scheduler = schedulerFactory.getScheduler();

		logger.info("Deleting job: " + jobTask.getAlias().replaceAll(" ", "_"));

		// delete job and any associated Triggers
		scheduler.deleteJob(JobKey.jobKey(jobTask.getAlias().replaceAll(" ", "_"), NORMAL_GROUP));

		logger.info("Scheduled jobTask removed successfully");
	}

	public void addTaskDelayed(Long delay, Long sessionId, Integer threadNumber) throws Exception {
		ScheduledTask jobTask = new ScheduledTask();
		jobTask.setPrcId(sessionId.intValue());
		jobTask.setId(threadNumber);
		jobTask.setTimePeriod(1L);
		jobTask.setTimeActive(1L);

		logger.info("Scheduling delayed jobTask: " + jobTask.getAlias() + ", cron: " + delay + "sec");

		Scheduler scheduler = schedulerFactory.getScheduler();
		SimpleTrigger trigger = newTrigger()
								.withIdentity(jobTask.getAlias().replaceAll(" ", "_"), NORMAL_GROUP)
								.startAt(new Date(System.currentTimeMillis() + delay*1000))
								.withSchedule(simpleSchedule().withMisfireHandlingInstructionNextWithRemainingCount()
								.withIntervalInMilliseconds(0).withRepeatCount(0))
								.build();
		JobDetail jobDetail = createTraceJobDetail(jobTask, sessionId, threadNumber);

		try{
			if (scheduler.unscheduleJob( trigger.getKey() ) == true) {
				scheduler.deleteJob( jobDetail.getKey() );
			}
		} catch (SchedulerException e) {
			logger.info("Can't delete job task by key");
		}
		startScheduler(scheduler);

		if (scheduler.isStarted()) {
			scheduler.scheduleJob(jobDetail, trigger);
		}

		logger.info("Job scheduled successfully");
	}

	public void addTaskImmediately(Integer processId) throws SchedulerException, ParseException,
			CronFormatException {

		ScheduledTask jobTask = new ScheduledTask();
		jobTask.setPrcId(processId);

		logger.info("Scheduling jobTask immediately: " + jobTask.getAlias() + ", cron: 10 sec");

		Scheduler scheduler = schedulerFactory.getScheduler();
		startScheduler(scheduler);

		long startTime = System.currentTimeMillis() + 10000L; //after 10 sec
		jobTask.setTimePeriod(30L);
		jobTask.setTimeActive(60L);
		SimpleTrigger trigger = newTrigger().withIdentity(jobTask.getAlias().replaceAll(" ", "_"),
				NORMAL_GROUP).startAt(new Date(startTime)).withSchedule(
				simpleSchedule().withMisfireHandlingInstructionNextWithRemainingCount()
						.withIntervalInMilliseconds(0).withRepeatCount(0)).build();

		JobDetail jobDetail = newJob(ProcessJob.class).withIdentity(
				jobTask.getAlias().replaceAll(" ", "_"), NORMAL_GROUP).build();
		jobDetail.getJobDataMap().put("ScheduledTask", jobTask);
		jobDetail.getJobDataMap().put("ErrorMode", Boolean.FALSE);

		//delete job after executing
//		jobDetail.setDurability(false);
		boolean isCurrentProcessRunning = false;
		if (scheduler.isStarted()) {
			Set<TriggerKey> triggerKeys = scheduler.getTriggerKeys(GroupMatcher
					.triggerGroupEquals(NORMAL_GROUP));
			for (TriggerKey triggerKey : triggerKeys) {
				if (triggerKey.getName().equals(trigger.getKey().getName())) {
					isCurrentProcessRunning = true;
				}
			}
			if (!isCurrentProcessRunning) {
				scheduler.scheduleJob(jobDetail, trigger);
			}
		}
		logger.info("Job scheduled successfully");
	}

	public void startScheduler(Scheduler scheduler) throws SchedulerException {
		if (!scheduler.isStarted()) {
			logger.info("Starting scheduler");
			scheduler.start();
			setListners();
		}
	}
}
