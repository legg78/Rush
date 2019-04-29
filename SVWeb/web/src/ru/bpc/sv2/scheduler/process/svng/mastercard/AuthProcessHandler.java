package ru.bpc.sv2.scheduler.process.svng.mastercard;

import com.bpcbt.svng.mastercard.ws.auth.AuthProcessManageService;
import com.bpcbt.svng.mastercard.ws.auth.AuthProcessParametersHolder;
import com.bpcbt.svng.mastercard.ws.auth.AuthProcessParams;
import com.bpcbt.svng.mastercard.ws.auth.AuthProcessRunInfo;
import com.bpcbt.svng.mastercard.ws.auth.ServiceResult;
import ru.bpc.sv2.scheduler.process.AsyncProcessHandler;
import ru.bpc.sv2.scheduler.process.ConfigurationProvider;
import ru.bpc.sv2.scheduler.process.ExecutionContext;
import ru.bpc.sv2.scheduler.process.ExecutionFailedException;
import ru.bpc.sv2.scheduler.process.StatusConsumer;

import java.math.BigDecimal;
import java.util.Map;

/**
 * @author Sergey Rastegaev
 * @version $Id$
 */
public final class AuthProcessHandler extends AsyncSoapHandler implements AsyncProcessHandler {

    private AuthProcessManageService inst;
    private long lastEstimation;
    private ExecutionContext context;

    @Override
    public void configure(ConfigurationProvider provider) {
        final String address = provider.getValue("AUTH_ADDRESS");
        inst = createInstance(address, AuthProcessManageService.class);
        configureClient(inst);
    }

    @Override
    public void execute(ExecutionContext context) throws ExecutionFailedException {
        final AuthProcessParametersHolder holder = prepareParams(context);

        Tracer.instance().trace( context.getSessionId(),
                String.format("Started process: authorization. Container: %d",
                        context.getContainerId()),
                TraceLevelType.INFO );

        final ServiceResult res = inst.run(holder);
        state = ConvertStateUtil.getAuthState(res);
    }

    private AuthProcessParametersHolder prepareParams(ExecutionContext context) {
        final AuthProcessParametersHolder config = new AuthProcessParametersHolder();
        this.context = context;

        config.setContainerId(context.getContainerId());
        config.setProcessId(context.getProcessId());
        config.setSessionId(context.getSessionId());
        config.setUserId(context.getUserId());

        final AuthProcessParams params = new AuthProcessParams();
        config.setParams(params);

        for (Map.Entry<String, Object> e : context.getParameters().entrySet()) {
            if (e.getValue() == null)
                continue;

            if ("I_IS_COLLECTION".equalsIgnoreCase(e.getKey())) {
                params.setCollection(((BigDecimal) e.getValue()).intValue() == 1);
            }
        }
        return config;
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
        final AuthProcessRunInfo inf = inst.status();

        Tracer.instance().trace( context.getSessionId(), TraceRecord.toTraceRecords(inf.getTraceRecords()) );

        if (lastEstimation != inf.getEstimatedCount()) {
            lastEstimation = inf.getEstimatedCount();
            consumer.countEstimated(lastEstimation);
        }

        consumer.countUpdated(inf.getProcessedCount(), inf.getExceptedCount(), inf.getRejectedCount());
        consumer.phaseUpdated(inf.getCurrentPhase(), inf.getPhasesTotal());
        state = ConvertStateUtil.getAuthState(inf.getProcessState());
    }

    @Override
    public void destroy() {
        destroyClient();
        inst = null;
    }

}
