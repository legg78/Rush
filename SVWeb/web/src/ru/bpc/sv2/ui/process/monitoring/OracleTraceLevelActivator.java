package ru.bpc.sv2.ui.process.monitoring;

import org.apache.log4j.Logger;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.scheduler.WebSchedule;
import ru.bpc.sv2.ui.utils.FacesUtils;

import java.util.HashMap;
import java.util.Map;

public class OracleTraceLevelActivator{
    private static final Long SECONDS_IN_MINUTE = 60L;

    private static Integer getThread(Integer thread) {
        return (thread == null) ? -1 : thread;
    }
    private static Integer getLimit(Integer limit) {
        return (limit == null) ? 10 : limit;
    }

    public OracleTraceLevelActivator(){}

    public static void message(ProcessDao dao, Long userSessionId,
                               Long sessionId, Integer threadNumber) {
        if (dao == null || userSessionId == null || sessionId == null) {
            Logger.getLogger("PROCESSES").error(new Exception( "DAO object or session IDs is null"));
            return;
        }
        String message = dao.getTraceMessage(userSessionId, sessionId, getThread(threadNumber));
        if (message != null && !message.isEmpty()) {
            FacesUtils.addInfoMessage( message );
        }
    }

    public static Integer getLevel(ProcessDao dao, Long userSessionId,
                                   Long sessionId, Integer threadNumber) {
        if (dao == null || userSessionId == null || sessionId == null) {
            Logger.getLogger("PROCESSES").error(new Exception( "DAO object or session IDs is null"));
            return new Integer(0);
        }
        return dao.getOracleTraceLevel(userSessionId, sessionId, getThread(threadNumber));
    }

    public static void enable(ProcessDao dao, Long userSessionId,
                              Long sessionId, Integer traceLevel,
                              Integer traceLimit, Integer threadNumber){
        if (dao == null || userSessionId == null) {
            Logger.getLogger("PROCESSES").error("DAO object or user session ID is null");
            return;
        }
        if (sessionId == null || traceLevel == null) {
            Logger.getLogger("PROCESSES").error("Session ID or tracle level is null");
            return;
        }

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("traceLevel", traceLevel);
        params.put("sessionId", sessionId);
        params.put("threadNumber", getThread(threadNumber));

        Logger.getLogger("PROCESSES").debug("Enable trace level " + traceLevel +
                                            " for session[" + sessionId +
                                            "], threads[" + getThread(threadNumber) +
                                            "] for " + getLimit(traceLimit) +
                                            " minutes" );

        dao.changeOracleTrace( userSessionId, params, Boolean.TRUE );

        if (traceLimit > 0) {
            try {
                WebSchedule.getInstance().addTaskDelayed(traceLimit*SECONDS_IN_MINUTE,
                                                         sessionId, threadNumber);
            } catch (Exception e) {
                Logger.getLogger("PROCESSES").error("", e);
            }
        }
    }
}
