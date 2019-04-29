package ru.bpc.sv2.scheduler.process;

import java.util.Map;

import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

public interface ProcessExecutor {
	public void execute() throws SystemException, UserException;
	public void setViewProcess(ProcessBO viewProcess);
	public ProcessBO getViewProcess();
	public void updateProgress() throws SystemException;
	public ProcessBO getProcess();
	public void setParameters(Map<String, Object> parameters);
}
