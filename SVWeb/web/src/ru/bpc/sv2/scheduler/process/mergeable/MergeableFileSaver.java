package ru.bpc.sv2.scheduler.process.mergeable;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.vfs.FileSystemException;
import org.apache.log4j.Logger;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.scheduler.process.mergeable.FileSaverCache;
import ru.bpc.sv2.utils.SystemException;

import java.io.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public abstract class MergeableFileSaver extends AbstractFileSaver implements Cloneable {
    private static final Logger logger = Logger.getLogger("PROCESSES");

    private Long fileId = null;
    private static String originalTrailer = null;
    private static String convertedTrailer = null;

    protected OutputStream outputStream = null;

    private static List<FileSaverCache> files = new ArrayList<FileSaverCache>();

    protected abstract String getOriginalTrailer();

    protected abstract String getOriginalHeader();

    protected abstract String getConvertedTrailer();

    protected abstract String getConvertedHeader();

    protected abstract String convert(String raw) throws Exception;

    public static void writeTrailer(OutputStream out, Connection connection, Long fileId, String fileFullName)
            throws Exception {
        if (StringUtils.isNotBlank(convertedTrailer)) {
            logger.debug("Write converted trailer into file " + fileFullName);
            if (out != null) {
                out.write(convertedTrailer.getBytes());
                out.flush();
            } else {
                try (OutputStream stream = new FileOutputStream(fileFullName, true)) {
                    stream.write(convertedTrailer.getBytes());
                    stream.flush();
                    stream.close();
                }
            }
        }
        if (StringUtils.isNotBlank(originalTrailer)) {
            logger.debug("Write original trailer into file id " + fileId);
            FileProcedures.append(connection, fileId, originalTrailer, null, true);
        }
    }

    public static void writeTrailer(Connection connection) throws Exception {
        if (files != null) {
            for (FileSaverCache file : files) {
                writeTrailer(null, connection, file.getId(), file.getFullName());
            }
            files.clear();
        }
        originalTrailer = null;
        convertedTrailer = null;
    }

    @Override
    public void save() throws Exception {
        setupTracelevel();
        try {
            if (process != null && process.getContainerBindId() == null) {
                debug("Start manual saving file " + getFileAttributes().getName());

                String raw = FileProcedures.select(getConnection(), getFileAttributes().getId());
                String content = convert(raw);

                outputStream = fileObject.getContent().getOutputStream();
                outputStream.write(content.getBytes());
                outputStream.flush();

                debug("Flushing manual file " + getFileAttributes().getName());
            } else if (isMergeByProcess()) {
                debug("Skip file " + getFileAttributes().getName());
            } else {
                debug("Start saving file " + getFileAttributes().getName());
                if (files != null) {
                    for(FileSaverCache file : files) {
                        if (file.getName().equalsIgnoreCase(getFileAttributes().getName())) {
                            warn("File is the merged one. Skip it");
                            return;
                        }
                    }
                }

                String raw = FileProcedures.select(getConnection(), getFileAttributes().getId());
                String content = convert(raw);

                if (isMergeByThread()) {
                    boolean isFirst = initializeFile();
                    FileProcedures.append(getConnection(), fileId, processData(raw, isFirst, false),
                                          getFileAttributes().getRecordCount(), !isFirst);
                    FileProcedures.update(getConnection(), getFileAttributes().getId(),
                                          getFileAttributes().getThreadNumber());
                    if (outputStream == null) {
                        outputStream = fileObject.getContent().getOutputStream();
                    }
                    outputStream.write(processData(content, isFirst, true).getBytes());
                } else {
                    outputStream = fileObject.getContent().getOutputStream();
                    outputStream.write(content.getBytes());
                }

                outputStream.flush();
                debug("Flushing file " + getFileAttributes().getName());
            }
        } catch (Exception e) {
            error(e);
            throw new SystemException(e);
        } finally {
            if (outputStream != null) {
                outputStream.close();
            }
        }
    }

    protected String processData(String data, boolean isFirst, boolean isConvert) {
        if (isConvert && StringUtils.isBlank(convertedTrailer)) {
            convertedTrailer = FileProcedures.getTrailer(data, getConvertedTrailer());
        } else if (!isConvert && StringUtils.isBlank(originalTrailer)) {
            originalTrailer = FileProcedures.getTrailer(data, getOriginalTrailer());
        }
        if (isConvert) {
            return FileProcedures.prepare(data, isFirst, getConvertedHeader(), getConvertedTrailer()).trim() + "\n";
        } else {
            return FileProcedures.prepare(data, isFirst, getOriginalHeader(), getOriginalTrailer());
        }
    }

    private boolean initializeByThread() throws FileNotFoundException {
        for (FileSaverCache file : files) {
            if (file.getThread().equals(fileAttributes.getThreadNumber())) {
                logger.debug("File " + fileAttributes.getName() + " will be written into " + file.getName());
                outputStream = new FileOutputStream(file.getFullName(), true);
                fileId = file.getId();
                file.setRecords(file.getRecords() + fileAttributes.getRecordCount());
                return false;
            }
        }
        return true;
    }

    private boolean initializeFile() throws FileSystemException, FileNotFoundException, SQLException {
        boolean firstFile = true;
        if (files == null) {
            files = new ArrayList<FileSaverCache>();
        }
        firstFile = initializeByThread();
        if (firstFile) {
            FileProcedures.initThread(getConnection(), fileAttributes.getThreadNumber());
            FileSaverCache file = FileProcedures.create(getConnection(), new FileSaverCache(
                                                        null,
                                                        fileAttributes.getThreadNumber(),
                                                        fileAttributes.getLocation(),
                                                        fileAttributes.getFileType(),
                                                        null,
                                                        fileAttributes.getRecordCount()));
            file.setFullName(getFileAttributes().getLocation(), file.getName());
            logger.debug("Merged file " + file.getName() + " has been created");

            outputStream = new FileOutputStream(file.getFullName(), true);
            fileId = file.getId();
            files.add(file);
        }
        return firstFile;
    }
}
