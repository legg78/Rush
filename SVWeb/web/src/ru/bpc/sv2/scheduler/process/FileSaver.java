package ru.bpc.sv2.scheduler.process;

import java.io.InputStream;
import java.sql.Connection;
import java.util.Map;

import org.apache.commons.vfs.FileObject;

import com.ibatis.sqlmap.client.SqlMapSession;

import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.process.ProcessTrace;
import ru.bpc.sv2.scheduler.process.converter.FileConverter;


public interface FileSaver {
	String FILES_MERGE_MODE			= "I_FILE_MERGE_MODE";
	String NOT_MERGE_FILES			= "FMMDNMRG";
	String MERGE_FILES_OF_THREAD	= "FMMDMTRD";
	String MERGE_FILES_OF_PROCESS	= "FMMDMPRC";

	void setInputStream(InputStream inputStream);

	void setFileObject(FileObject fileObject);

	void setConnection(Connection con);

	void setFileAttributes(ProcessFileAttribute fileAttributes);

	void setSsn(SqlMapSession ssn);

	void setThreadNum(int threadNum);

	void setParams(Map<String, Object> params);

	void setConverter(FileConverter converter);

	void setUserSessionId(Long userSessionId);

	void setSessionId(Long sessionId);

	void setUserName(String userName);

	void setProcess(ProcessBO proc);

	void setTraceLevel(Integer traceLevel);

	void setTraceLimit(Integer traceLimit);

	void setTraceThreadNumber(Integer traceThreadNumber);

	InputStream getInputStream();

	FileObject getFileObject();

	Connection getConnection();

	FileConverter getConverter();

	ProcessFileAttribute getFileAttributes();

	Map<String, Object> getOutParams();

	boolean isRequiredInFiles();

	boolean isRequiredOutFiles();

	void save() throws Exception;
}
