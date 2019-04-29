package ru.bpc.sv2.scheduler;

import org.apache.log4j.Logger;
import org.quartz.*;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.logic.utility.db.UserContextHolder;
import ru.bpc.sv2.schedule.ScheduledTask;

import java.util.HashMap;
import java.util.Map;

@PersistJobDataAfterExecution
@DisallowConcurrentExecution
public class TraceJob implements Job {
    private static final String DEFAULT_JOB_USER_NAME = "jobuser";
    private static final Logger logger = Logger.getLogger("PROCESSES");

    private ProcessDao processDao;
    private RolesDao rolesDao;

    public TraceJob() {
        try {
            processDao = new ProcessDao();
            rolesDao = new RolesDao();
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
        }
    }

    public void execute(JobExecutionContext cntxt) throws JobExecutionException {
        try {
            UserContextHolder.setUserName(DEFAULT_JOB_USER_NAME);
            ScheduledTask scheduledTask = (ScheduledTask)cntxt.getJobDetail().getJobDataMap().get("ScheduledTask");
            Long sessionId = (Long)cntxt.getJobDetail().getJobDataMap().get("SessionId");
            Integer threadNumber = (Integer)cntxt.getJobDetail().getJobDataMap().get("ThreadNumber");
            Long userSessionId = rolesDao.setInitialUserContext(null, DEFAULT_JOB_USER_NAME, null);

            if (scheduledTask == null || sessionId == null || threadNumber == null || userSessionId == null) {
                cntxt.setResult(ProcessConstants.COMPLETED_ERROR);
                logger.error("ScheduledTask from jobDataMap is null");
                throw new JobExecutionException("Task is null");
            }

            Map<String, Object> params = new HashMap<String, Object>();
            params.put( "sessionId", sessionId );
            params.put( "threadNumber", threadNumber );
            logger.debug( "Disable trace for session " + sessionId + ", " + threadNumber + " threads" );

            processDao.changeOracleTrace( userSessionId, params, false );
            cntxt.setResult(ProcessConstants.COMPLETED_OK);
        } finally {
            UserContextHolder.setUserName(null);
        }
    }
}
