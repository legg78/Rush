package ru.bpc.sv2.scheduler.process;

import ru.bpc.sv2.process.ProcessBO;

public interface IProcess {

	public void launch() throws Exception ;
	
	public void preProcess() throws Exception ;
	
	public void postProcess() throws Exception ;
	
	public void setProcessInDialog(ProcessBO procInDialog);
}
