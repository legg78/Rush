package ru.bpc.sv2.scheduler.process;

import java.util.Date;
import java.util.Map;

import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

public interface ExternalProcess {
	void execute() throws SystemException, UserException;
	void setParameters(Map<String, Object> parameters);
	void setProcessSession(ProcessSession processSession);
	void setProcess(ProcessBO process);
	void setEffectiveDate(Date effectiveDate);
	void setUserSessionId(Long userSessionId);
	void setThreadsNumber(int threadsNumber);
	void setUserName(String userName);
}
