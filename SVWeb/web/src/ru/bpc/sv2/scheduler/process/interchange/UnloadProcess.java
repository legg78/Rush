package ru.bpc.sv2.scheduler.process.interchange;

import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.util.Map;

public class UnloadProcess extends IbatisExternalProcess {
	private String module;
	ru.bpc.sv2.scheduler.process.interchange.visa.UnloadProcess visaProcess;
	ru.bpc.sv2.scheduler.process.interchange.mc.UnloadProcess mcProcess;
	ru.bpc.sv2.scheduler.process.interchange.amex.UnloadProcess amexProcess;
	ru.bpc.sv2.scheduler.process.interchange.cup.UnloadProcess cupProcess;
	ru.bpc.sv2.scheduler.process.interchange.diners.UnloadProcess dinersProcess;

	@Override
	public void execute() throws SystemException, UserException {
		try {
			getIbatisSession();
			startSession();
			startLogging();
			getModuleProcess().execute();
			getProcessSession().setResultCode(ProcessConstants.PROCESS_FINISHED);
			commit();
		} catch (Exception ex) {
			getProcessSession().setResultCode(ProcessConstants.PROCESS_FAILED);
			rollback();
		} finally {
			closeConAndSsn();
		}
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		module = parameters.get("I_MODULE").toString().substring(4).replaceAll("0", "");
		getModuleProcess().setParameters(parameters);
	}

	private InterchangeUnloadProcess getModuleProcess() {
		if (module.equalsIgnoreCase("MC")) {
			if (mcProcess == null) {
				mcProcess = new ru.bpc.sv2.scheduler.process.interchange.mc.UnloadProcess(this);
			}
			return mcProcess;
		} else if (module.equalsIgnoreCase("VISA")) {
			if (visaProcess == null) {
				visaProcess = new ru.bpc.sv2.scheduler.process.interchange.visa.UnloadProcess(this);
			}
			return visaProcess;
		} else if (module.equalsIgnoreCase("CUP")) {
			if (cupProcess == null) {
				cupProcess = new ru.bpc.sv2.scheduler.process.interchange.cup.UnloadProcess(this);
			}
			return cupProcess;
		} else if (module.equalsIgnoreCase("AMX")) {
			if (amexProcess == null) {
				amexProcess = new ru.bpc.sv2.scheduler.process.interchange.amex.UnloadProcess(this);
			}
			return amexProcess;
		}
		if (dinersProcess == null) {
			dinersProcess = new ru.bpc.sv2.scheduler.process.interchange.diners.UnloadProcess(this);
		}
		return dinersProcess;
	}
}
