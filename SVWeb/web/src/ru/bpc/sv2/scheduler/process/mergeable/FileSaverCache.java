package ru.bpc.sv2.scheduler.process.mergeable;

import org.apache.commons.lang3.StringUtils;

import java.io.OutputStream;

public class FileSaverCache {
    private Long id = 0L;
    private Integer thread = -1;
    private String name = null;
    private String fullName = null;
    private Long records = null;
    private String type = null;

    public FileSaverCache(Long id,
                          Integer threadNumber,
                          String fileLocation,
                          String type,
                          String fileName,
                          Long recordCount) {
        setId(id);
        setThread(threadNumber);
        setType(type);
        setName(fileName);
        if (StringUtils.isNotBlank(fileName)) {
            setFullName(formatFullFileName(fileLocation, fileName));
        } else {
            setFullName(fileLocation);
        }
        setRecords(recordCount);
    }

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Integer getThread() {
        return thread;
    }
    public void setThread(Integer thread) {
        this.thread = thread;
    }

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }

    public String getFullName() {
        return fullName;
    }
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    public void setFullName(String location, String name) {
        this.fullName = formatFullFileName(location, name);
    }

    public Long getRecords() {
        return records;
    }
    public void setRecords(Long records) {
        this.records = records;
    }

    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }

    private String formatFullFileName(String fileLocation, String fileName) {
        if (fileLocation != null) {
            fileLocation = fileLocation.replace("\\\\", "/").replace("\\", "/");
            if (fileLocation.endsWith("/")) {
                return fileLocation + fileName;
            } else {
                return fileLocation + "/" + fileName;
            }
        }
        return fileName;
    }
}
