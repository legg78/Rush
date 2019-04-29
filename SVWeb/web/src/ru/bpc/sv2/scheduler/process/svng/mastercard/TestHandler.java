package ru.bpc.sv2.scheduler.process.svng.mastercard;

import org.apache.log4j.Logger;
import ru.bpc.sv2.scheduler.process.AsyncProcessHandler;
import ru.bpc.sv2.scheduler.process.ConfigurationProvider;
import ru.bpc.sv2.scheduler.process.ExecutionContext;
import ru.bpc.sv2.scheduler.process.ExecutionFailedException;
import ru.bpc.sv2.scheduler.process.StatusConsumer;
import ru.bpc.sv2.trace.TraceLogInfo;

/**
 * @author Steshin Vladimir
 *         Created on 08.06.2016.
 * @version $Id$
 */
public class TestHandler implements AsyncProcessHandler {

    private static final Logger LOG = Logger.getLogger("PROCESSES");
    private static final Logger DB_LOG = Logger.getLogger("PROCESSES_DB");

    private static final int STATE_COUNT = 100;
    private static final int MILLS = 10000;

    protected HandlerState state = HandlerState.StandBy;
    protected ExecutionContext context;
    protected int stateCnt;

    @Override
    public void configure(ConfigurationProvider provider) {
        if(LOG.isDebugEnabled()) {
            LOG.debug("configure()");
            //DB_LOG.debug( new TraceLogInfo(context.getSessionId(), "configure()") );
        }
    }

    @Override
    public void execute( final ExecutionContext context) throws ExecutionFailedException {
        if(LOG.isDebugEnabled()) {
            LOG.debug("execute()");
            DB_LOG.debug( new TraceLogInfo(context.getSessionId(), "execute()") );
        }
        this.context = context;

        Tracer.instance().trace( context.getSessionId(),
                String.format("Started process: Testing. Container: %d", context.getContainerId()),
                TraceLevelType.INFO );

        //ExecutorService exec = Executors.newFixedThreadPool(2);
        //exec = Executors.newFixedThreadPool(2);
        //exec = Executors.newFixedThreadPool(2);

        state = HandlerState.InProgress;

        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    while(stateCnt < STATE_COUNT){
                        Thread.sleep(MILLS/STATE_COUNT);
                        ++stateCnt;
                    }
                } catch (InterruptedException e) {
                    LOG.warn("Unable to set state.");
                    DB_LOG.error( new TraceLogInfo(context.getSessionId(), "Unable to set state)") );
                }

                stateCnt = STATE_COUNT;
                state = HandlerState.Completed;
            }
        }).start();

    }

    @Override
    public void reset() {
        if(LOG.isDebugEnabled()) {
            LOG.debug("reset()");
            DB_LOG.debug( new TraceLogInfo(context.getSessionId(), "reset()") );
        }
        stateCnt = 0;
        state = HandlerState.StandBy;
    }

    @Override
    public HandlerState getState() {
        return state;
    }

    @Override
    public boolean isFileRequired() {
        return false;
    }

    @Override
    public void fillStatus(StatusConsumer consumer) {
        if(LOG.isDebugEnabled()) {
            LOG.debug("fillStatus()");
            DB_LOG.debug( new TraceLogInfo(context.getSessionId(), "fillStatus()") );
        }

        consumer.countEstimated(STATE_COUNT);
        consumer.countUpdated(stateCnt,0,0);
        consumer.phaseUpdated(1,1);
    }

    @Override
    public void destroy() {
        if (LOG.isDebugEnabled()) {
            LOG.debug("destroy()");
            DB_LOG.debug( new TraceLogInfo(context.getSessionId(), "destroy()") );
        }
    }
}