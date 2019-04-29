package ru.bpc.sv2.scheduler.process.mc;

import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import ru.bpc.sv2.process.file.SimpleFileRec;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.scheduler.process.mc.entity.FieldConfig;
import ru.bpc.sv2.scheduler.process.mc.entity.MCFieldsConfig;
import ru.bpc.sv2.scheduler.process.mc.utils.MsgUtil;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

import javax.xml.bind.DatatypeConverter;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.CallableStatement;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Gasanov on 17.10.2015.
 */
public class MCIPMFileSaver extends AbstractFileSaver {

    private final int NUM_IN_BATCH = 10000;
    Long bytesRead;
    Integer bytesInBlockRead;

    @Override
    public void save() throws Exception {
        setupTracelevel();
        long curtime = System.currentTimeMillis();

        String strLine = null;

        List<SimpleFileRec> rawsAsArray = new ArrayList<SimpleFileRec>();
        List<Integer> recNumList = new ArrayList<Integer>();
        ArrayDescriptor transactionsDescriptor;
        ArrayDescriptor transactionsDescriptor1;

        int i = 0;
        int num = 1;
        int num_in_batch = NUM_IN_BATCH;
        int rdw;
        byte[] source;
        bytesRead = new Long(0);
        bytesInBlockRead = new Integer(0);
        ByteArrayOutputStream baus = new ByteArrayOutputStream();
        while ((inputStream.available()) > 0) {
            baus.reset();
            readMessage(baus);
            source = baus.toByteArray();
            if (converter != null) {
                // long convTime = System.currentTimeMillis();
                strLine = converter.convertByteArrayToString(source);
                // System.out.println("Covert string time:" +
                // (System.currentTimeMillis() - convTime));
            } else {
                strLine = DatatypeConverter.printHexBinary(source);
            }

            rawsAsArray.add(new SimpleFileRec(strLine));
            recNumList.add(num);
            // ssn.insert("process.put-line", map);
            i++;
            if (i == num_in_batch) {
                ARRAY oracleRecNums = DBUtils.createArray(AuthOracleTypeNames.PRC_SESSION_FILE_RECNUM_TAB, con,
                        recNumList.toArray(new Integer[recNumList.size()]));
                ARRAY oracleRawData = DBUtils.createArray(AuthOracleTypeNames.PRC_SESSION_FILE_RAW_TAB, con,
                        rawsAsArray.toArray(new SimpleFileRec[rawsAsArray.size()]));

                CallableStatement cstmt = null;
                try {
                    cstmt = con.prepareCall("{call prc_api_file_pkg.put_bulk_web(?,?,?)}");
                    cstmt.setLong(1, fileAttributes.getSessionId());

                    cstmt.setArray(2, oracleRawData);
                    cstmt.setArray(3, oracleRecNums);
                    cstmt.execute();
                }finally {
                    DBUtils.close(cstmt);
                }

                rawsAsArray.clear();
                recNumList.clear();
                i = 0;
            }
            num++;
        }

        if (i > 0) {
            ARRAY oracleRecNums = DBUtils.createArray(AuthOracleTypeNames.PRC_SESSION_FILE_RECNUM_TAB, con,
                    recNumList.toArray(new Integer[recNumList.size()]));
            ARRAY oracleRawData = DBUtils.createArray(AuthOracleTypeNames.PRC_SESSION_FILE_RAW_TAB, con,
                    rawsAsArray.toArray(new SimpleFileRec[rawsAsArray.size()]));

            CallableStatement cstmt = null;
            try {
                cstmt = con.prepareCall("{call prc_api_file_pkg.put_bulk_web(?,?,?)}");
                cstmt.setLong(1, fileAttributes.getSessionId());
                cstmt.setArray(2, oracleRawData);
                cstmt.setArray(3, oracleRecNums);
                cstmt.execute();
            }finally {
                DBUtils.close(cstmt);
            }

            rawsAsArray.clear();
            recNumList.clear();
        }

        System.out.println("Saved in time: " + (System.currentTimeMillis() - curtime));
    }

    public void readMessage(OutputStream baus) {
        try {
            parse(inputStream, baus);
        } catch (IOException e) {
            logger.error("Error during reading bytes.", e);
        } catch (Exception e) {
            logger.error("Error during reading bytes.", e);
        }
    }

    public void parse(InputStream is, OutputStream baus) throws Exception{
        MCFieldsConfig fieldsConfig = new MCFieldsConfig();
        MsgUtil.getType(is, fieldsConfig, baus);
        byte[] fieldIdListSegment = MsgUtil.readBitMask(is, baus);
        int[] fieldIds = MsgUtil.decodeFullBitmask(fieldIdListSegment);
        for(int i=0; i<fieldIds.length; i++){
            FieldConfig fieldConfig = fieldsConfig.getField(fieldIds[i]);
            try{
                if (fieldConfig.isFixed())
                {
                    MsgUtil.readByteArray(is, fieldsConfig.getEncodeSpec().getEncodedLength(fieldConfig.getLength()), baus);
                }
                else
                {
                    MsgUtil.readByteArrayWithLength(is, fieldConfig.getLength(), fieldsConfig.getEncodeSpec(), fieldsConfig.getEncodeSpec(), baus);
                }
            }catch(Exception e){
                System.out.println("Error occurent " + fieldIds[i]);
                throw e;
            }
        }
    }
}
