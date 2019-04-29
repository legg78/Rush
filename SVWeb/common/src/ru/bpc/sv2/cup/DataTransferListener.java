package ru.bpc.sv2.cup;

public interface DataTransferListener {
	void finished();
	void failed();
	void threadStarted(int threadId);
	void threadFinished(int threadId);
}
