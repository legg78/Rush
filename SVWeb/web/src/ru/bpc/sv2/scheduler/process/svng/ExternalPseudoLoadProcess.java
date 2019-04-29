package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.util.Map;

public class ExternalPseudoLoadProcess extends IbatisExternalProcess {
    @Override
    public void execute() throws SystemException, UserException {
        try {
            getIbatisSession();
            startSession();
            processSession.setResultCode(ProcessConstants.PROCESS_FINISHED);
            commit();
        } catch (Exception e) {
            processSession.setResultCode(ProcessConstants.PROCESS_FAILED);
            rollback();
            if (e instanceof UserException) {
                throw (UserException) e;
            } else if (e instanceof SystemException) {
                throw (SystemException) e;
            } else {
                throw new SystemException(e);
            }
        } finally {
            closeConAndSsn();
        }
    }
    @Override
    public void setParameters(Map<String, Object> parameters) {}
}
