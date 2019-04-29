package ru.bpc.sv2.ui.process.monitoring;

import ru.bpc.sv2.logic.ProcessDao;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.io.Serializable;

@ViewScoped
@ManagedBean(name = "MbOracleTracing")
public class MbOracleTracing implements Serializable {
    protected Long userSessionId = null;
    private Long sessionId = null;
    private Integer traceLevel = null;
    private Integer traceLimit = 10;
    private Integer threadNumber = -1;
    private Boolean applyImmediately = true;

    private ProcessDao processDao = new ProcessDao();

    public MbOracleTracing() {
    }

    public void setUserSessionId(Long userSessionId) {
        this.userSessionId = userSessionId;
    }
    public Long getUserSessionId() {
        return userSessionId;
    }

    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }
    public Long getSessionId() {
        return sessionId;
    }

    public void setTraceLimit(Integer traceLimit) {
        this.traceLimit = traceLimit;
    }
    public Integer getTraceLimit() {
        return traceLimit;
    }

    public void setThreadNumber(Integer threadNumber) {
        this.threadNumber = threadNumber;
    }
    public Integer getThreadNumber() {
        return threadNumber;
    }

    public void setTraceLevel(Integer traceLevel) {
        this.traceLevel = traceLevel;
    }
    public Integer getTraceLevel() {
        if (sessionId != null && applyImmediately) {
            traceLevel = OracleTraceLevelActivator.getLevel(processDao, userSessionId, sessionId, threadNumber);
        }
        return traceLevel;
    }

    public void setApplyImmediately(Boolean applyImmediately) {
        this.applyImmediately = applyImmediately;
    }
    public Boolean getApplyImmediately() {
        return applyImmediately;
    }

    public void enableTracing() {
        if (applyImmediately) {
            if (sessionId != null) {
                OracleTraceLevelActivator.enable(processDao, userSessionId, sessionId, traceLevel, traceLimit, threadNumber);
                OracleTraceLevelActivator.message(processDao, userSessionId, sessionId, threadNumber);
            }
        }
    }
    public void cleanup() {
        setSessionId(null);
        setTraceLevel(0);
        setThreadNumber(-1);
        setTraceLimit(10);
    }
}
