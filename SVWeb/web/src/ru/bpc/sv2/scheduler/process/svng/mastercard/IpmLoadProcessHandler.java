package ru.bpc.sv2.scheduler.process.svng.mastercard;

import com.bpcbt.svng.mastercard.ws.ipm.load.IpmInFileInfo;
import com.bpcbt.svng.mastercard.ws.ipm.load.IpmInParametersHolder;
import com.bpcbt.svng.mastercard.ws.ipm.load.IpmInParams;
import com.bpcbt.svng.mastercard.ws.ipm.load.IpmInRunInfo;
import com.bpcbt.svng.mastercard.ws.ipm.load.IpmLoadManageService;
import com.bpcbt.svng.mastercard.ws.ipm.load.ServiceResult;
import ru.bpc.sv2.scheduler.process.AsyncProcessHandler;
import ru.bpc.sv2.scheduler.process.ConfigurationProvider;
import ru.bpc.sv2.scheduler.process.ExecutionContext;
import ru.bpc.sv2.scheduler.process.ExecutionFailedException;
import ru.bpc.sv2.scheduler.process.StatusConsumer;

import java.util.Map;

/**
 * @author Sergey Rastegaev
 * @version $Id$
 */
public final class IpmLoadProcessHandler extends AsyncSoapHandler implements AsyncProcessHandler {

    private IpmLoadManageService inst;
    private long lastEstimation;
    private ExecutionContext context;

    @Override
    public void configure(ConfigurationProvider provider) {
        final String address = provider.getValue("IPM_IN_ADDRESS");
        inst = createInstance(address, IpmLoadManageService.class);
        configureClient(inst);
    }

    @Override
    public void execute(ExecutionContext context) throws ExecutionFailedException {
        final IpmInParametersHolder holder = prepareParams(context);

        Tracer.instance().trace( context.getSessionId(),
                String.format("Started process: IPM loading. Container: %d", context.getContainerId()),
                TraceLevelType.INFO );

        final ServiceResult res = inst.run(holder);
        state = ConvertStateUtil.getIpmState(res);
    }

    @Override
    public void reset() {
        state = HandlerState.StandBy;
        lastEstimation = 0;
    }

    @Override
    public HandlerState getState() {
        return state;
    }

    @Override
    public boolean isFileRequired() {
        return true;
    }

    @Override
    public void fillStatus(StatusConsumer consumer) {
        final IpmInRunInfo inf = inst.status();

        Tracer.instance().trace( context.getSessionId(), TraceRecord.toTraceRecords(inf.getTraceRecords()) );

        if (lastEstimation != inf.getEstimatedCount()) {
            lastEstimation = inf.getEstimatedCount();
            consumer.countEstimated(lastEstimation);
        }

        consumer.countUpdated(inf.getProcessedCount(), inf.getExceptedCount(), inf.getRejectedCount());
        consumer.phaseUpdated(inf.getCurrentPhase(), inf.getPhasesTotal());
        state = ConvertStateUtil.getIpmState(inf.getProcessState());
    }

    @Override
    public void destroy() {
        destroyClient();
        inst = null;
    }

    private IpmInParametersHolder prepareParams(ExecutionContext context) {
        final IpmInParametersHolder config = new IpmInParametersHolder();
        this.context = context;

        config.setContainerId(context.getContainerId());
        config.setSessionId(context.getSessionId());
        config.setUserId(context.getUserId());
        final Integer processId = context.getProcessId();
        config.setProcessId(processId == null ? -1 : processId);

        final IpmInFileInfo fileInfo = new IpmInFileInfo();
        config.setFileInfo(fileInfo);
        fileInfo.setSourceCharset(context.getSourceFile().getCharset().name());
        fileInfo.setFilePath(context.getSourceFile().getPath().toString());

        final IpmInParams p = new IpmInParams();
        config.setParams(p);

        for (Map.Entry<String, Object> e : context.getParameters().entrySet()) {

            if (e.getValue() == null)
                continue;

            final String stringVal = e.getValue().toString();

            if ("I_NETWORK_ID".equalsIgnoreCase(e.getKey())) {
                p.setNetworkId(Integer.parseInt(stringVal));
            }
            if ("I_CREATE_OPERATION".equalsIgnoreCase(e.getKey())) {
                p.setCreateOperation(Integer.parseInt(stringVal) == 1);
            }
            if ("I_RECORD_FORMAT".equalsIgnoreCase(e.getKey())) {
                if ("RCFM1014".equalsIgnoreCase(stringVal)) {
                    fileInfo.setSourceBlocked(true);
                    fileInfo.setSourceRdw(true);
                } else if ("RCFMRDW".equalsIgnoreCase(stringVal)) {
                    fileInfo.setSourceBlocked(false);
                    fileInfo.setSourceRdw(true);
                }
            }
        }
        return config;
    }

}
