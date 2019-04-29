package ru.bpc.sv2.scheduler.process.amex;

import ru.bpc.sv2.process.file.SimpleFileRec;
import ru.bpc.sv2.scheduler.process.SimpleFileSaver;
import ru.bpc.sv2.utils.SystemException;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.lang3.StringUtils;

public class AmExRcnFileSaver extends SimpleFileSaver {
    private static final int REC_LENGTH = 500;

    @Override
    public void save() throws Exception {
        String string = null;
        String recordType;
        DataInputStream stream = new DataInputStream(inputStream);
        List<SimpleFileRec> raws = new ArrayList<SimpleFileRec>();
        List<Integer> lines = new ArrayList<Integer>();
        Integer lastLineNumber = 1;
        while (StringUtils.isNotEmpty(string = getString(readBytes(stream, REC_LENGTH)))) {
            writeString(raws, lines, lastLineNumber++, string);
            storeBatch(raws, lines);
        }
        storeBatch(raws, lines, true);
    }

    private byte[] readBytes(DataInputStream in, int length) throws IOException, SystemException {
        if (in == null) {
            throw new SystemException(getClass().getSimpleName() + ": input data stream is not initialized");
        } else if (length > REC_LENGTH) {
            throw new SystemException(getClass().getSimpleName() +
                    ": file " + fileAttributes.getFileName() +
                    " probably contains incorrect data. Line has extra length [" + length + "]");
        }
        if (in.available() == 0)
            return new byte[0];

        byte[] line = new byte[length];
        for (int i = 0; i < length;) {
            try {
                line[i] = in.readByte();
            } catch (IOException e) {
                logger.error("Error during reading bytes", e);
                break;
            } finally {
                i++;
            }
        }
        return line;
    }

    private String getString(byte[] raw) throws UnsupportedEncodingException {
        if (converter != null) {
            return converter.convert(new String(raw, getCharset()));
        } else {
            return new String(raw, getCharset());
        }
    }

    private void writeString(List<SimpleFileRec> raws, List<Integer> recs, Integer line, String str) throws SQLException {
        raws.add(new SimpleFileRec(str));
        recs.add(line);
    }

    private void storeBatch(List<SimpleFileRec> raws, List<Integer> recs) throws SQLException {
        storeBatch(raws, recs, false);
    }
    private void storeBatch(List<SimpleFileRec> raws, List<Integer> recs, boolean forced) throws SQLException {
        if (raws.size() >= NUM_IN_BATCH || forced) {
            if (raws.size() > 0)
                storeData(raws, recs);
            raws.clear();
            recs.clear();
        }
    }
}
