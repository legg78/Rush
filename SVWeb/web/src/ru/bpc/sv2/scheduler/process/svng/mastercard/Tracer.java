package ru.bpc.sv2.scheduler.process.svng.mastercard;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import ru.bpc.sv2.trace.TraceLogInfo;

import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * @author Steshin Vladimir
 *         Created on 09.06.2016.
 * @version $Id$
 */
public final class Tracer {

    private static Tracer INST = new Tracer();

    private static final Logger loggerDB = Logger.getLogger("PROCESSES_DB");

    private Tracer(){
        exec  = Executors.newCachedThreadPool();
    }

    private final ExecutorService exec;

    public void trace(long sessionId, List<TraceRecord> traces) {
        if(traces.isEmpty())
            return;

        exec.execute(new TraceLogger(sessionId, traces));
    }

    public void trace(long sessionId, TraceRecord record){
        trace(sessionId,Arrays.asList(new TraceRecord[]{record}));
    }

    public void trace(long sessionId, final String msg, TraceLevelType level ){
        TraceRecord record = new TraceRecord();

        record.setMessage(msg);
        record.setLevel( level );

        trace(sessionId,record);
    }

    private final class TraceLogger implements Runnable {

        private final List<TraceRecord> traces;
        private final long sessionId;

        public TraceLogger(long sessionId, List<TraceRecord> traces) {
            this.traces = traces;
            this.sessionId = sessionId;
        }

        @Override
        public void run() {
            for (TraceRecord r : traces) {
                final TraceLogInfo msg = new TraceLogInfo(sessionId, r.getMessage());

//                msg.setEntityType(r.getEntityType());
//                msg.setObjectId(r.getObjectId());
//                msg.setContainerId((int) ctx.getContainerBindId());

                loggerDB.log(Level.toLevel(r.getLevel().value(), Level.DEBUG), msg);
            }
        }
    }

    public static Tracer instance() {
        return INST;
    }


}
