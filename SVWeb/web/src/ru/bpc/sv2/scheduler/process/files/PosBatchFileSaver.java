package ru.bpc.sv2.scheduler.process.files;

import org.apache.commons.vfs.FileObject;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.scheduler.process.files.batch.*;
import ru.bpc.sv2.utils.SystemException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PosBatchFileSaver extends AbstractFileSaver {
    private InputStream inputStream;
    private Connection connection;
    private ProcessFileAttribute fileAttributes;
    private FileObject fileObject;
    private Long sessionId;
    private Long userSessionId;
    private String userName;
    private ProcessBO process;
    private Map<String, Object> params;
    private Map<String, Object> outParams;

    @Override
    public InputStream getInputStream(){
        return inputStream;
    }
    @Override
    public void setInputStream(InputStream inputStream){
        this.inputStream = inputStream;
    }

    @Override
    public Connection getConnection(){
        return connection;
    }
    @Override
    public void setConnection(Connection connection){
        this.connection = connection;
    }

    @Override
    public FileObject getFileObject(){
        return fileObject;
    }
    @Override
    public void setFileObject(FileObject fileObject){
        this.fileObject = fileObject;
    }

    @Override
    public ProcessFileAttribute getFileAttributes(){
        return fileAttributes;
    }
    @Override
    public void setFileAttributes(ProcessFileAttribute fileAttributes){
        this.fileAttributes = fileAttributes;
    }

    public Long getSessionId(){
        return sessionId;
    }
    @Override
    public void setSessionId(Long sessionId){
        this.sessionId = sessionId;
    }

    public Long getUserSessionId(){
        return userSessionId;
    }
    @Override
    public void setUserSessionId(Long userSessionId){
        this.userSessionId = userSessionId;
    }

    public String getUserName(){
        return userName;
    }
    @Override
    public void setUserName(String userName){
        this.userName = userName;
    }

    public ProcessBO getProcess(){
        return process;
    }
    @Override
    public void setProcess(ProcessBO process){
        this.process = process;
    }

    @Override
    public Map<String, Object> getParams(){
        return params;
    }
    @Override
    public void setParams( Map<String, Object> params ){
        this.params = params;
    }

    @Override
    public boolean isRequiredInFiles(){
        return true;
    }
    @Override
    public boolean isRequiredOutFiles(){
        return false;
    }

    @Override
    public Map<String, Object> getOutParams(){
        if (outParams == null) {
            outParams = new HashMap<String, Object>();
        }
        if (outParams.get("processedFiles") == null) {
            outParams.put("processedFiles", (Integer) 0);
        }
        if (outParams.get("expectedFiles") == null) {
            outParams.put("expectedFiles", (Integer) 0);
        }
        return outParams;
    }

    @Override
    public void save() throws SQLException, Exception {
        setupTracelevel();
        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, PosBatchParser.getCharset()));
        boolean autoCommit = connection.getAutoCommit();
        try {
            PosBatchParser parser = null;
            String batchVersion = "";
            Long fileId = 0L;
            Long blockId = 0L;
            Map<String, Object> line = null;
            List<Map<String, Object>> lines = new ArrayList<Map<String, Object>>();
            Long count = 0L;
            connection.setAutoCommit(false);
            while ((parser = PosBatchParser.create(reader.readLine())) != null) {
                parser.setBatchVersion(batchVersion);
                parser.parse();
                if (parser.getRecordType().equals(PosBatchRecordParser.TYPE)) {
                    lines.add(parser.get(fileId, blockId));
                } else {
                    Long id = parser.save(connection, sessionId, fileId, blockId);
                    if (parser.getRecordType().equals(PosBatchFileHeaderParser.TYPE)) {
                        batchVersion = parser.getBatchVersion();
                        if (id != null) {
                            fileId = id;
                        }
                    } else if (parser.getRecordType().equals(PosBatchBlockHeaderParser.TYPE)) {
                        if (id != null) {
                            blockId = id;
                        }
                    } else if (lines.size() >= PosBatchParser.BUFFER_MAX_SIZE) {
                        parser.saveAll(connection, sessionId, lines);
                        lines.clear();
                    }
                }
                count++;
            }
            if (lines.size() > 0) {
                parser = PosBatchParser.create("");
                parser.saveAll(connection, sessionId, lines);
                lines.clear();
            }
        } catch (IOException e) {
            logger.error(e.getCause().getMessage(), e);
            throw new SystemException(e.getCause().getMessage(), e);
        } finally {
            try {
                connection.setAutoCommit(autoCommit);
                if (reader != null) {
                    reader.close();
                }
            } catch (Exception e) {}
        }
    }
}
