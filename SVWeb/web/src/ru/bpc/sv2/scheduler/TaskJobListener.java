package ru.bpc.sv2.scheduler;

import java.text.ParseException;

import org.apache.log4j.Logger;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.JobListener;
import org.quartz.SchedulerException;

import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.schedule.CronFormatException;
import ru.bpc.sv2.schedule.ScheduledTask;

public class TaskJobListener implements JobListener {

	private static final Logger logger = Logger.getLogger("SCHEDULER");

	public String name;

	public void jobToBeExecuted(JobExecutionContext context) {

	}

	public void jobExecutionVetoed(JobExecutionContext context) {

	}

	public void jobWasExecuted(JobExecutionContext context, JobExecutionException jobException) {

		try {
			boolean errorMode = context.getJobDetail().getJobDataMap().getBooleanValue("ErrorMode");
			logger.trace(String.format("JobListener: job was executed. Job name: %s; error mode:%s; result:%s",
					context.getJobDetail().getKey().getName(), String.valueOf(errorMode), String.valueOf(context.getResult())));

			if (!errorMode) {
				//If it's a normal mode, not an error mode
				if (context.getResult() == null || context.getResult().equals(ProcessConstants.COMPLETED_ERROR)) {
					//If errors occurred while executing
					restartInErrorMode(context);
				}
			} else {
				if (context.getResult() != null && context.getResult().equals(ProcessConstants.COMPLETED_OK)) {
					if (context.getScheduler().isStarted()) {
						logger.trace("Removing job that was scheduled in error mode");
						//If execution in errorMode completed successfully remove error mode trigger 
						context.getScheduler().unscheduleJob(context.getTrigger().getKey());
						context.getScheduler().deleteJob(context.getJobDetail().getKey());
					}
				}
			}
		} catch (SchedulerException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void restartInErrorMode(JobExecutionContext context) {
		try {
			logger.info(String.format("Error occured while executing job '%s'. Generating the same job with 'error mode' trigger",
					context.getJobDetail().getKey().getName()));
			JobDataMap ma = context.getJobDetail().getJobDataMap();
			System.out.println("Getting object ScheduledTask from jobDataMap ");
			ScheduledTask scheduledTask = (ScheduledTask) ma.get("ScheduledTask");
			if (scheduledTask == null) {
				logger.error("ScheduledTask from jobDataMap is null");
				return;
			}
			WebSchedule webSchedule = WebSchedule.getInstance();
			webSchedule.addTaskInErrorMode(scheduledTask);
		} catch (SchedulerException e) {
			logger.error(e.getMessage(), e);
		} catch (ParseException e) {
			logger.error(e.getMessage(), e);
		} catch (CronFormatException e) {
			logger.error(e.getMessage(), e);
		}
	}

}
