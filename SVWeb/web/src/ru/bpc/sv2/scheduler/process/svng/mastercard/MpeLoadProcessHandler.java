package ru.bpc.sv2.scheduler.process.svng.mastercard;

import com.bpcbt.svng.mastercard.ws.mpe.MpeFileFormat;
import com.bpcbt.svng.mastercard.ws.mpe.MpeFileInfo;
import com.bpcbt.svng.mastercard.ws.mpe.MpeLoadManageService;
import com.bpcbt.svng.mastercard.ws.mpe.MpeParametersHolder;
import com.bpcbt.svng.mastercard.ws.mpe.MpeProcessInfo;
import com.bpcbt.svng.mastercard.ws.mpe.MpeProcessParams;
import com.bpcbt.svng.mastercard.ws.mpe.MpeProcessRunInfo;
import com.bpcbt.svng.mastercard.ws.mpe.ServiceResult;
import ru.bpc.sv2.scheduler.process.AsyncProcessHandler;
import ru.bpc.sv2.scheduler.process.ConfigurationProvider;
import ru.bpc.sv2.scheduler.process.ExecutionContext;
import ru.bpc.sv2.scheduler.process.ExecutionFailedException;
import ru.bpc.sv2.scheduler.process.StatusConsumer;

import java.util.List;
import java.util.Map;

/**
 * @author Sergey Rastegaev
 * @version $Id$
 */
public final class MpeLoadProcessHandler extends AsyncSoapHandler implements AsyncProcessHandler {

    private MpeLoadManageService inst;
    private long lastEstimation;
    private ExecutionContext context;

    @Override
    public void configure(ConfigurationProvider provider) {
        final String address = provider.getValue("MPE_ADDRESS");
        inst = createInstance(address, MpeLoadManageService.class);
        configureClient(inst);
    }

    @Override
    public void execute(ExecutionContext context) throws ExecutionFailedException {
        final MpeParametersHolder holder = prepareParams(context);

        Tracer.instance().trace( context.getSessionId(),
                String.format("Started process: MPE loading. Container: %d",
                        context.getContainerId()),
                TraceLevelType.INFO );

        final ServiceResult res = inst.run(holder);
        state = ConvertStateUtil.getMpeState(res);
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
        final MpeProcessRunInfo inf = inst.status();

        Tracer.instance().trace( context.getSessionId(), TraceRecord.toTraceRecords(inf.getTraceRecords()) );

        if(lastEstimation != inf.getEstimatedCount()) {
            lastEstimation = inf.getEstimatedCount();
            consumer.countEstimated(lastEstimation);
        }

        consumer.countUpdated(inf.getProcessedCount(), inf.getExceptedCount(), inf.getRejectedCount());
        consumer.phaseUpdated(inf.getCurrentPhase(), inf.getPhasesTotal());
        state = ConvertStateUtil.getMpeState(inf.getProcessState());
    }

    @Override
    public void destroy() {
        destroyClient();
        inst = null;
    }

    private MpeParametersHolder prepareParams(ExecutionContext context) {
        final MpeParametersHolder config = new MpeParametersHolder();
        this.context = context;

        config.setContainerId(context.getContainerId());
        config.setSessionId(context.getSessionId());

        final Integer processId = context.getProcessId();
        config.setProcessId(processId == null ? -1 : processId);

        final MpeFileInfo fileInfo = new MpeFileInfo();
        config.setFileInfo(fileInfo);

        final ExecutionContext.FileInfo file = context.getSourceFile();

        fileInfo.setFilePath(file.getPath().toString());
        fileInfo.setSourceCharset(file.getCharset().name());

        final MpeProcessInfo pInfo = new MpeProcessInfo();
        config.setProcessInfo(pInfo);

        pInfo.setName("test process");
        pInfo.setDescription("Mpe ");
        pInfo.setParallel(false); //TODO: parallel file executions.

        final MpeProcessParams pParams = new MpeProcessParams();
        config.setParams(pParams);

        final List<String> tableNames = pParams.getTableNames();
        for (Map.Entry<String, Object> e : context.getParameters().entrySet()) {

            if (e.getValue() == null)
                continue;

            final String stringVal = e.getValue().toString();

            if ("I_EXPANSION".equalsIgnoreCase(e.getKey())) {
                final boolean expanding = Integer.parseInt(stringVal) == 1;
                fileInfo.setSourceFormat(expanding ? MpeFileFormat.COMPRESSED : MpeFileFormat.EXPANDED);
                fileInfo.setExpanding(expanding);
            }
            if ("I_TABLE".equalsIgnoreCase(e.getKey())) {
                tableNames.add(stringVal);
            }
            if ("I_RECORD_FORMAT".equalsIgnoreCase(e.getKey())) {

                if ("RCFM1014".equalsIgnoreCase(stringVal)) { // blocked
                    fileInfo.setSourceBlocked(true);
                    fileInfo.setSourceRdw(true);
                } else if ("RCFMRDW".equalsIgnoreCase(stringVal)) { // rdw
                    fileInfo.setSourceBlocked(false);
                    fileInfo.setSourceRdw(true);
                }
            }
        }
        return config;
    }

}
