package ru.bpc.sv2.scheduler.process.mergeable;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.apache.log4j.Logger;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.utils.SystemException;

import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.util.List;

public abstract class PostFileSaver extends MergeableFileSaver implements Cloneable {
    private static final Logger logger = Logger.getLogger("PROCESSES");

    protected abstract String convert(String raw) throws Exception;

    public void save(boolean useParent) throws Exception {
        if (useParent) {
            super.save();
        } else {
            this.process();
        }
    }

    @Override
    public void save() throws Exception {
        this.process();
    }

    private void process() throws Exception {
        setupTracelevel();
        try {
            debug("Merge files of session [" + sessionId + "]");
            List<Pair<Long, String>> files = FileProcedures.selectAll(getConnection(), sessionId);
            if (!files.isEmpty()) {
                FileSaverCache mergeFile = FileProcedures.create(getConnection(), new FileSaverCache(
                                                                 null, -1,
                                                                 getFileAttributes().getLocation(),
                                                                 getFileAttributes().getFileType(),
                                                                 null, 0L));
                mergeFile.setFullName(getFileAttributes().getLocation(), mergeFile.getName());
                try (OutputStream out = new FileOutputStream(mergeFile.getFullName(), true)) {
                    boolean isFirst = true;
                    for (Pair<Long, String> file : files) {
                        FileProcedures.append(getConnection(), mergeFile.getId(),
                                              processData(file.getValue(), isFirst, false),
                                              null, !isFirst);
                        String content = convert(file.getValue());
                        out.write(processData(content, isFirst, true).getBytes());
                        isFirst = false;
                        out.flush();
                        FileProcedures.update(getConnection(), file.getKey(), null);
                    }
                    FileProcedures.updateRecord(getConnection(), sessionId, mergeFile.getId());
                    writeTrailer(out, getConnection(), mergeFile.getId(), mergeFile.getFullName());
                    out.flush();
                    out.close();
                }
                debug("Files of session [" + sessionId + "] have been merged into");
            }
        } catch (Exception e) {
            error(e);
            throw new SystemException(e);
        }
    }
}
