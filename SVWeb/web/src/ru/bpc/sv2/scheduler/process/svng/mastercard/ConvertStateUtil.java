package ru.bpc.sv2.scheduler.process.svng.mastercard;

import ru.bpc.sv2.scheduler.process.AsyncProcessHandler;

/**
 * @author Sergey Rastegaev
 * @version $Id$
 */
public final class ConvertStateUtil {

    private ConvertStateUtil() {
    }

    public static AsyncProcessHandler.HandlerState getMpeState(com.bpcbt.svng.mastercard.ws.mpe.ServiceResult result) {
        switch (result) {
            case PRSR_0000:
                return AsyncProcessHandler.HandlerState.AlreadyRunning;
            case PRSR_0001:
                return AsyncProcessHandler.HandlerState.InProgress;
            case PRSR_0002:
                return AsyncProcessHandler.HandlerState.Completed;
            case PRSR_0003:
                return AsyncProcessHandler.HandlerState.Failed;
            case PRSR_0004:
                return AsyncProcessHandler.HandlerState.CompletedWithErrors;
            case PRSR_0005:
                return AsyncProcessHandler.HandlerState.Cancelled;
            case STANDBY:
            default:
                return AsyncProcessHandler.HandlerState.StandBy;
        }
    }

    public static AsyncProcessHandler.HandlerState getIpmState(com.bpcbt.svng.mastercard.ws.ipm.load.ServiceResult result) {
        switch (result) {
            case PRSR_0000:
                return AsyncProcessHandler.HandlerState.AlreadyRunning;
            case PRSR_0001:
                return AsyncProcessHandler.HandlerState.InProgress;
            case PRSR_0002:
                return AsyncProcessHandler.HandlerState.Completed;
            case PRSR_0003:
                return AsyncProcessHandler.HandlerState.Failed;
            case PRSR_0004:
                return AsyncProcessHandler.HandlerState.CompletedWithErrors;
            case PRSR_0005:
                return AsyncProcessHandler.HandlerState.Cancelled;
            case STANDBY:
            default:
                return AsyncProcessHandler.HandlerState.StandBy;
        }
    }

    public static AsyncProcessHandler.HandlerState getIpmState(com.bpcbt.svng.mastercard.ws.ipm.save.ServiceResult result) {
        switch (result) {
            case PRSR_0000:
                return AsyncProcessHandler.HandlerState.AlreadyRunning;
            case PRSR_0001:
                return AsyncProcessHandler.HandlerState.InProgress;
            case PRSR_0002:
                return AsyncProcessHandler.HandlerState.Completed;
            case PRSR_0003:
                return AsyncProcessHandler.HandlerState.Failed;
            case PRSR_0004:
                return AsyncProcessHandler.HandlerState.CompletedWithErrors;
            case PRSR_0005:
                return AsyncProcessHandler.HandlerState.Cancelled;
            case STANDBY:
            default:
                return AsyncProcessHandler.HandlerState.StandBy;
        }
    }

    public static AsyncProcessHandler.HandlerState getIpmState(com.bpcbt.svng.mastercard.ws.ipm.generate.ServiceResult result) {
        switch (result) {
            case PRSR_0000:
                return AsyncProcessHandler.HandlerState.AlreadyRunning;
            case PRSR_0001:
                return AsyncProcessHandler.HandlerState.InProgress;
            case PRSR_0002:
                return AsyncProcessHandler.HandlerState.Completed;
            case PRSR_0003:
                return AsyncProcessHandler.HandlerState.Failed;
            case PRSR_0004:
                return AsyncProcessHandler.HandlerState.CompletedWithErrors;
            case PRSR_0005:
                return AsyncProcessHandler.HandlerState.Cancelled;
            case STANDBY:
            default:
                return AsyncProcessHandler.HandlerState.StandBy;
        }
    }

    public static AsyncProcessHandler.HandlerState getAuthState(com.bpcbt.svng.mastercard.ws.auth.ServiceResult result) {
        switch (result) {
            case PRSR_0000:
                return AsyncProcessHandler.HandlerState.AlreadyRunning;
            case PRSR_0001:
                return AsyncProcessHandler.HandlerState.InProgress;
            case PRSR_0002:
                return AsyncProcessHandler.HandlerState.Completed;
            case PRSR_0003:
                return AsyncProcessHandler.HandlerState.Failed;
            case PRSR_0004:
                return AsyncProcessHandler.HandlerState.CompletedWithErrors;
            case PRSR_0005:
                return AsyncProcessHandler.HandlerState.Cancelled;
            case STANDBY:
            default:
                return AsyncProcessHandler.HandlerState.StandBy;
        }
    }
}
