package ru.bpc.sv2.scheduler.process.svng.mastercard;

import com.bpcbt.svng.mastercard.ws.ipm.save.IpmSaveManageService;
import com.bpcbt.svng.mastercard.ws.ipm.save.IpmSaverFileInfo;
import com.bpcbt.svng.mastercard.ws.ipm.save.IpmSaverParametersHolder;
import com.bpcbt.svng.mastercard.ws.ipm.save.IpmSaverParams;
import com.bpcbt.svng.mastercard.ws.ipm.save.IpmSaverRunInfo;
import com.bpcbt.svng.mastercard.ws.ipm.save.ServiceResult;
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
public final class IpmSaveProcessHandler extends AsyncSoapHandler implements AsyncProcessHandler {

    private IpmSaveManageService inst;
    private long lastEstimation;
    private ExecutionContext context;

    @Override
    public void configure(ConfigurationProvider provider) {
        final String address = provider.getValue("IPM_SAVE_ADDRESS");
        inst = createInstance(address, IpmSaveManageService.class);
        configureClient(inst);
    }

    @Override
    public void execute(ExecutionContext context) throws ExecutionFailedException {
        final IpmSaverParametersHolder holder = prepareParams(context);

        Tracer.instance().trace( context.getSessionId(),
                String.format("Started process: IPM saving. Container: %d",
                        context.getContainerId()),
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
        return false;
    }

    @Override
    public void fillStatus(StatusConsumer consumer) {
        final IpmSaverRunInfo inf = inst.status();

        Tracer.instance().trace( context.getSessionId(), TraceRecord.toTraceRecords(inf.getTraceRecords()) );

        if(lastEstimation != inf.getEstimatedCount()) {
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

    private IpmSaverParametersHolder prepareParams(ExecutionContext context) {
        final IpmSaverParametersHolder config = new IpmSaverParametersHolder();
        this.context = context;

        config.setContainerId(context.getContainerId());
        config.setContainerBindId(context.getContainerBindId());
        config.setSessionId(context.getSessionId());
        config.setUserId(context.getUserId());

        final Integer processId = context.getProcessId();
        config.setProcessId(processId == null ? -1 : processId);

        final IpmSaverFileInfo fileInfo = new IpmSaverFileInfo();
        config.setFileInfo(fileInfo);

        final IpmSaverParams params = new IpmSaverParams();
        config.setParams(params);

        if (context.getDestinationFile() != null)
            fileInfo.setDirectoryUri(context.getDestinationFile().getPath().toString());

        for (Map.Entry<String, Object> e : context.getParameters().entrySet()) {

            if (e.getValue() == null)
                continue;

            final String stringVal = e.getValue().toString();
            if ("I_MAIN_SESSION_ID".equalsIgnoreCase(e.getKey())) { // previous process session id
                params.setParentSessionId(Long.valueOf(stringVal));
            } else if ("I_RECORD_FORMAT".equalsIgnoreCase(e.getKey())) {
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
