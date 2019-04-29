package ru.bpc.sv2.scheduler.process;


public abstract class ProcessExecutorAdapter {
	public void preProcessFailed(ProcessExecutor source){}
	public void processRunned(ProcessExecutor source){}
	public void processFinished(ProcessExecutor source) {}
	public void processFailed(ProcessExecutor source) {}
	
	public void beforeContainerLaunching(ContainerLauncher source) {}
	public void containerLaunched(ContainerLauncher source){}
	public void containerFinished(ContainerLauncher source) {}
	public void containerFailed(ContainerLauncher source) {}
	
	
}
