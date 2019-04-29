package ru.bpc.sv2.scheduler;

import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.SchedulerException;
import org.quartz.Trigger;
import org.quartz.TriggerListener;

public class TaskTriggerListener implements TriggerListener {
	private static final Logger logger = Logger.getLogger("SCHEDULER");

	public String name;

	public void triggerFired(Trigger trigger, JobExecutionContext context) {
		System.out.println();
		System.out.println("TriggerListener: trigger fired. Trigger name:"
				+ trigger.getKey().getName() + "; trigger group: " + trigger.getKey().getGroup());
		Boolean errorMode = context.getJobDetail().getJobDataMap().getBooleanValue("ErrorMode");
		if (errorMode == null || errorMode.equals(Boolean.TRUE)) {
			System.out.println("TriggerListener: trigger paused. Trigger name:"
					+ trigger.getKey().getName() + "; trigger group: "
					+ trigger.getKey().getGroup() + "; nextFire: " + trigger.getNextFireTime()
					+ ";finalFire: " + trigger.getFinalFireTime());
		}
	}

	public boolean vetoJobExecution(Trigger trigger, JobExecutionContext context) {
		return false;
	}

	public void triggerMisfired(Trigger trigger) {

	}

	public void triggerComplete(Trigger trigger, JobExecutionContext context,
			Trigger.CompletedExecutionInstruction triggerInstructionCode) {
		try {
			Boolean errorMode = context.getJobDetail().getJobDataMap().getBooleanValue("ErrorMode");
			if (errorMode == null || errorMode.equals(Boolean.TRUE)) {
				System.out.println("TriggerListener: resuming trigger. Trigger name:"
						+ trigger.getKey().getName() + "; trigger group: "
						+ trigger.getKey().getGroup() + "; nextFire: " + trigger.getNextFireTime()
						+ ";finalFire: " + trigger.getFinalFireTime());
				if (context.getScheduler().isStarted()) {
//					context.getScheduler().resumeTrigger(trigger.getName(), trigger.getGroup());
					if (trigger.getNextFireTime() == null) {
						System.out
								.println("TriggerListener: deleting job and trigger. Trigger name:"
										+ trigger.getKey().getName() + "; trigger group: "
										+ trigger.getKey().getGroup());
						context.getScheduler().deleteJob(context.getJobDetail().getKey());
					}
				}
			}
			System.out.println("TriggerListener: trigger completed. Trigger name:"
					+ trigger.getKey().getName() + "; trigger group: "
					+ trigger.getKey().getGroup());
		} catch (SchedulerException e) {
			logger.error("", e);
		}
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

}
