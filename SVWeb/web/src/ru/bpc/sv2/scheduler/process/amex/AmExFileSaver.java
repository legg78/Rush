package ru.bpc.sv2.scheduler.process.amex;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.process.file.SimpleFileRec;
import ru.bpc.sv2.scheduler.process.SimpleFileSaver;
import ru.bpc.sv2.utils.SystemException;

import javax.xml.bind.DatatypeConverter;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class AmExFileSaver extends SimpleFileSaver {
    private static final int DEFAULT_LENGTH = 1400;
    private static final int DAF_LENGTH = 600;
    private static final int MAX_LENGTH = 4000;
    private static final int MESSAGE_TYPE_LENGTH = 4;
    private static final int ADDENDUM_TYPE_LENGTH = 2;
    private static final int ADDENDUM_ASCII_BLOCK_LENGTH_1 = 585;
    private static final int ADDENDUM_ASCII_BLOCK_LENGTH_2 = 559;
    private static final int ADDENDUM_ASCII_BLOCK_START = 837;
    private static final int ADDENDUM_START_OFFSET = 0;
    private static final String ADDENDUM_EMV_CODE = "07";
    private static final List<Integer> MTID_DAF = Arrays.asList(1324, 1325, 1644);

    enum RecordTypes {
        UNDEFINED,
        HEADER,
        BODY,
        TRAILER;
    }

    @Override
    public void save() throws Exception {
        String string = null;
        int mtid = 0;
        DataInputStream stream = new DataInputStream(inputStream);
        List<SimpleFileRec> raws = new ArrayList<SimpleFileRec>();
        List<Integer> lines = new ArrayList<Integer>();
        Integer lastLineNumber = 1;

        while ((mtid = readMTID(stream)) > 0) {
            string = mtid + readData(stream, mtid);
            switch (getStringType(string)) {
                default:
                    writeString(raws, lines, lastLineNumber++, string);
                    storeBatch(raws, lines);
                    break;
            }
        }
        storeBatch(raws, lines, true);
    }

    private int readMTID(DataInputStream in) throws IOException, SystemException {
        try {
            return Integer.parseInt(getString(readBytes(in, MESSAGE_TYPE_LENGTH)));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String readData(DataInputStream in, int mtid) throws IOException, SystemException {
        return getString(readBytes(in, getDataLength(mtid)), mtid);
    }

    private byte[] readBytes(DataInputStream in, int length) throws IOException, SystemException {
        if (in == null) {
            throw new SystemException(getClass().getSimpleName() + ": input data stream is not initialized");
        } else if (length > MAX_LENGTH) {
            throw new SystemException(getClass().getSimpleName() +
                                      ": file " + fileAttributes.getFileName() +
                                      " probably contains incorrect data. Line has extra length [" + length + "]");
        }
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
        return getString(raw, null);
    }
    private String getString(byte[] raw, Integer mtid) throws UnsupportedEncodingException {
        if (isEmvAddendum(raw, mtid)) {
            String block1 = new String(raw, ADDENDUM_START_OFFSET, ADDENDUM_ASCII_BLOCK_LENGTH_1, getCharset());
            String block2 = "";
            if (converter != null) {
                block2 = converter.convertByteArrayToString(raw);
            } else {
                block2 = DatatypeConverter.printHexBinary(raw);
            }
            block2 = block2.substring(ADDENDUM_ASCII_BLOCK_LENGTH_1*2, ADDENDUM_ASCII_BLOCK_START*2);
            String block3 = new String(raw, ADDENDUM_ASCII_BLOCK_START, ADDENDUM_ASCII_BLOCK_LENGTH_2, getCharset());
            return block1 + block2 + block3;
        } else if (converter != null) {
            return converter.convert(new String(raw, getCharset()));
        } else {
            return new String(raw, getCharset());
        }
    }

    private int getDataLength(Integer mtid) {
        if (MTID_DAF.contains(mtid)) {
            return DAF_LENGTH - MESSAGE_TYPE_LENGTH;
        } else if (mtid > 0) {
            return DEFAULT_LENGTH - MESSAGE_TYPE_LENGTH;
        }
        return 0;
    }

    private RecordTypes getStringType(String converted) {
        return RecordTypes.UNDEFINED;
    }

    private boolean isEmvAddendum(byte[] raw, Integer mtid) throws UnsupportedEncodingException {
        if (mtid != null && (mtid == 9240 || mtid == 9340)) {
            if (ADDENDUM_EMV_CODE.equals(new String(raw, ADDENDUM_START_OFFSET, ADDENDUM_TYPE_LENGTH, getCharset()))) {
                return true;
            }
        }
        return false;
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
            storeData(raws, recs);
            raws.clear();
            recs.clear();
        }
    }
}
