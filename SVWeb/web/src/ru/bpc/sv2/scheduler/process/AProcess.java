package ru.bpc.sv2.scheduler.process;

import java.util.Date;
import java.util.Map;

import javax.sql.DataSource;

import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessSession;

public abstract class AProcess implements IProcess {

	ProcessSession sess = null;
	Long containerSessionId = null;
	int numthreads = 0;
	boolean parallel = false;
	DataSource ds = null;
	ProcessBO proc = null;
	Long userSessionId = null;
	Map<String, Object> uiParams = null;
	Date effectiveDate = null;
	ProcessBO procInDialog;
	
	public AProcess() {
		sess = new ProcessSession();
	}
	@Override
	public void launch() throws Exception {
		// TODO Auto-generated method stub
		launchInternal();
	}

	@Override
	public void postProcess() throws Exception {
		// TODO Auto-generated method stub
		postProcessInternal();
	}

	@Override
	public void preProcess() throws Exception {
		// TODO Auto-generated method stub
		preProcessInternal();
	}
	
	protected abstract void launchInternal() throws Exception ;
	
	protected abstract void postProcessInternal() throws Exception ;
	
	protected abstract void preProcessInternal() throws Exception ;

	public void setProcessInDialog(ProcessBO procInDialog) {
		this.procInDialog = procInDialog;
	}

}
