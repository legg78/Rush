package ru.bpc.sv2.cup;

import java.io.Serializable;

public class SessionData implements Serializable {
	private long userSessionId;
	private long sessionId;
	private String fileName;
	private long processId;
	private Long processIdToRun;
	private DataTransferListener finishedListener;

	public long getUserSessionId() {
		return userSessionId;
	}

	public void setUserSessionId(long userSessionId) {
		this.userSessionId = userSessionId;
	}

	public long getSessionId() {
		return sessionId;
	}

	public void setSessionId(long sessionId) {
		this.sessionId = sessionId;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public long getProcessId() {
		return processId;
	}

	public void setProcessId(long processId) {
		this.processId = processId;
	}

	public Long getProcessIdToRun() {
		return processIdToRun;
	}

	public void setProcessIdToRun(Long processIdToRun) {
		this.processIdToRun = processIdToRun;
	}

	public DataTransferListener getFinishedListener() {
		return finishedListener;
	}

	public void setFinishedListener(DataTransferListener finishedListener) {
		this.finishedListener = finishedListener;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) {
			return true;
		}
		if (!(o instanceof SessionData)) {
			return false;
		}

		SessionData that = (SessionData) o;

		if (processId != that.processId) {
			return false;
		}
		if (sessionId != that.sessionId) {
			return false;
		}
		if (userSessionId != that.userSessionId) {
			return false;
		}
		if (!fileName.equals(that.fileName)) {
			return false;
		}
		if (processIdToRun != null ? !processIdToRun.equals(that.processIdToRun) : that.processIdToRun != null) {
			return false;
		}

		return true;
	}

	@Override
	public int hashCode() {
		int result = (int) (userSessionId ^ (userSessionId >>> 32));
		result = 31 * result + (int) (sessionId ^ (sessionId >>> 32));
		result = 31 * result + fileName.hashCode();
		result = 31 * result + (int) (processId ^ (processId >>> 32));
		result = 31 * result + (processIdToRun != null ? processIdToRun.hashCode() : 0);
		return result;
	}
}
