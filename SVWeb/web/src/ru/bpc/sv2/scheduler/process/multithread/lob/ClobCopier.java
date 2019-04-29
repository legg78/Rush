package ru.bpc.sv2.scheduler.process.multithread.lob;


import org.apache.log4j.Logger;

import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.channels.Channels;
import java.nio.channels.FileChannel;
import java.nio.channels.ReadableByteChannel;
import java.sql.*;
import java.util.concurrent.BrokenBarrierException;
import java.util.concurrent.CyclicBarrier;

public class ClobCopier implements Runnable{
    private static final Logger logger = Logger.getLogger("PROCESSES");

    private final CyclicBarrier barrier;

    private long id;
    private int bufferSize;
    private long position;
    private long count;
    private String sqlText;
    private String contentFieldName;
    private String fileName;


    private Connection connection;

    public ClobCopier(CyclicBarrier barrier, Connection connection, String fileName,
                      String sqlText, String contentFieldName, long id, int bufferSize, long position,
                      long count) {

        this.barrier = barrier;

        this.id = id;
        this.fileName = fileName;
        this.bufferSize = bufferSize;
        this.position = position;
        this.count = count;
        this.connection = connection;
        this.sqlText = sqlText;
        this.contentFieldName = contentFieldName;
    }

    @Override
    public void run() {
        long startThreadTime =  System.currentTimeMillis();
        logger.debug("Started downloading at offset " + position + " byte(s)");
        copyClobToFile(fileName, sqlText, contentFieldName, id, bufferSize, position, count);
        logger.debug("Finished downloading " + (System.currentTimeMillis() - startThreadTime)/1000 + " seconds");

        try {
            logger.debug("The thread has finished work and expects synchronization." );
            barrier.await();
            logger.debug("The thread successfully syncing and ended." );
        } catch (InterruptedException e) {
            logger.error("The thread was interrupted. " + e);
        } catch (BrokenBarrierException e) {
            logger.error("The barrier which is used by thread was broken. " + e);

        }
    }

    private void copyClobToFile(String fileName, String sqlText, String contentFieldName, long id, int bufferSize, long position, long count) {

        PreparedStatement stmt=null;
        ResultSet rset=null;
        ReadableByteChannel inChannel=null;
        FileChannel outChannel = null;
        RandomAccessFile f=null;
        long iteration = count%bufferSize==0 ? count / bufferSize : count / bufferSize + 1;

        try {
            f = new RandomAccessFile(fileName, "rw");
            outChannel = f.getChannel();
            outChannel.position(position - 1);

            stmt = connection.prepareStatement(sqlText);
            stmt.setLong(1, position);
            stmt.setLong(2, count);
            stmt.setLong(3, id);
            rset = stmt.executeQuery();

            if (rset.next()) {
                Clob clob = rset.getClob(contentFieldName);
                inChannel = Channels.newChannel(clob.getAsciiStream());
                //long i=1;
                //long startTime = System.currentTimeMillis();
                for (ByteBuffer buffer = ByteBuffer.allocate(bufferSize);
                     inChannel.read(buffer) != -1; buffer.clear()) {

                    //logger.debug("D->B  F " + i + " of " + iteration + ", time:" + (System.currentTimeMillis() - startTime));
                    buffer.flip();

                    //Thread.yield();
                    //startTime = System.currentTimeMillis();
                    while (buffer.hasRemaining()) outChannel.write(buffer);
                    //logger.debug("D  B->F " + i + " of " + iteration + ", time:" + (System.currentTimeMillis() - startTime));
                    //i++;
                    //startTime = System.currentTimeMillis();
                }
                inChannel.close();
                f.close();
            }else {
                logger.debug("The query returned an empty document by id=" + id + "");
            }
            outChannel.close();
            rset.close();
            stmt.close();

        } catch (Exception e) {
            logger.error(e);
        } finally {
            try {
                if(rset!=null) rset.close();
                if(stmt!=null) stmt.close();
                if(connection!=null) connection.close();
                try {
                    if(inChannel!=null)inChannel.close();
                    if(outChannel!=null) outChannel.close();
                    if(f!=null)f.close();
                }catch(IOException e) {
                    logger.error(e);
                }
            }catch(SQLException e) {
                logger.error(e);
            }
        }
    }

}

