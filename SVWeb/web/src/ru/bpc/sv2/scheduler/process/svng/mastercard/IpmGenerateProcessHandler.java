package ru.bpc.sv2.scheduler.process.svng.mastercard;


import com.bpcbt.svng.mastercard.ws.ipm.generate.InstType;
import com.bpcbt.svng.mastercard.ws.ipm.generate.IpmGenerateManageService;
import com.bpcbt.svng.mastercard.ws.ipm.generate.IpmGeneratorFileInfo;
import com.bpcbt.svng.mastercard.ws.ipm.generate.IpmGeneratorParametersHolder;
import com.bpcbt.svng.mastercard.ws.ipm.generate.IpmGeneratorParams;
import com.bpcbt.svng.mastercard.ws.ipm.generate.IpmGeneratorRunInfo;
import com.bpcbt.svng.mastercard.ws.ipm.generate.ServiceResult;
import ru.bpc.sv2.scheduler.process.AsyncProcessHandler;
import ru.bpc.sv2.scheduler.process.ConfigurationProvider;
import ru.bpc.sv2.scheduler.process.ExecutionContext;
import ru.bpc.sv2.scheduler.process.ExecutionFailedException;
import ru.bpc.sv2.scheduler.process.StatusConsumer;

import java.util.Date;
import java.util.Map;

/**
 * @author Sergey Rastegaev
 * @version $Id$
 */
public final class IpmGenerateProcessHandler extends AsyncSoapHandler implements AsyncProcessHandler {

    private IpmGenerateManageService inst;
    private long lastEstimation;
    private ExecutionContext context;

    @Override
    public void configure(ConfigurationProvider provider) {
        final String address = provider.getValue("IPM_GENERATE_ADDRESS");
        inst = createInstance(address, IpmGenerateManageService.class);
        configureClient(inst);
    }

    @Override
    public void execute(ExecutionContext context) throws ExecutionFailedException {
        final IpmGeneratorParametersHolder holder = prepareParams(context);

        Tracer.instance().trace( context.getSessionId(),
                String.format("Started process: IPM generating. Container: %d",
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
        return true;
    }

    @Override
    public void fillStatus(StatusConsumer consumer) {
        final IpmGeneratorRunInfo inf = inst.status();

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

    private IpmGeneratorParametersHolder prepareParams(ExecutionContext context) {
        final IpmGeneratorParametersHolder config = new IpmGeneratorParametersHolder();
        this.context = context;

        config.setContainerId(context.getContainerId());
        config.setSessionId(context.getSessionId());
        config.setUserId(context.getUserId());
        config.setContainerBindId(context.getContainerBindId());
        final Integer processId = context.getProcessId();
        config.setProcessId(processId == null ? -1 : processId);


        final IpmGeneratorFileInfo fileInfo = new IpmGeneratorFileInfo();
        config.setFileInfo(fileInfo);

        fileInfo.setTargetCharset(context.getDestinationFile().getCharset().name());

        final IpmGeneratorParams p = new IpmGeneratorParams();
        config.setParams(p);

        for (Map.Entry<String, Object> e : context.getParameters().entrySet()) {

            if (e.getValue() == null)
                continue;

            final String stringVal = e.getValue().toString();

            if ("I_INST_ID".equalsIgnoreCase(e.getKey())) {
                p.setInstId(Integer.parseInt(stringVal));
            }
            if ("I_NETWORK_ID".equalsIgnoreCase(e.getKey())) {
                p.setNetworkId(Integer.parseInt(stringVal));
            }
            if ("I_UPLOAD_INST".equalsIgnoreCase(e.getKey())) {
                if ("UPIN0010".equalsIgnoreCase(stringVal))
                    p.setInstType(InstType.UPIN_0010); // forwarding institution (default)
                else if("UPIN0020".equalsIgnoreCase(stringVal))
                    p.setInstType(InstType.UPIN_0020); // originator institution
            }
            if ("I_CONTAINER_SESSION_ID".equalsIgnoreCase(e.getKey())) {
                p.setParentSessionId(Long.valueOf(stringVal));
            }
            if ("I_START_DATE".equalsIgnoreCase(e.getKey())) {
                p.setStartDate(((Date) e.getValue()).getTime());
            }
            if ("I_END_DATE".equalsIgnoreCase(e.getKey())) {
                p.setEndDate(((Date) e.getValue()).getTime());
            }
        }
        return config;
    }

}
