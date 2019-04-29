package ru.bpc.sv2.scheduler.process.interchange.cup;

import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.scheduler.process.interchange.InterchangeDataTypes;
import ru.bpc.sv2.scheduler.process.interchange.InterchangeUnloadProcess;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import java.sql.ResultSet;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

public class UnloadProcess extends InterchangeUnloadProcess {
	private static final String TIMEOUT_PARAM_KEY = "I_TIMEOUT";

	private String mqUrl;//for tests use tcp://localhost:61616
	private int timeout;

	public UnloadProcess(IbatisExternalProcess process) {
		super(process);
	}

	@Override
	protected String getMqUrl() {
		return mqUrl;
	}

	@Override
	protected String getModuleName() {
		return "CUP";
	}

	@Override
	protected int getTimeout() {
		return timeout;
	}

	@Override
	protected InterchangeDataTypes getDataType() {
		return InterchangeDataTypes.CURRENCY_RATES;
	}

	public void setParameters(Map<String, Object> parameters) {
		mqUrl = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
		if (parameters.get(TIMEOUT_PARAM_KEY) != null) {
			timeout = Integer.valueOf(parameters.get(TIMEOUT_PARAM_KEY).toString());
		}
	}

	@Override
	protected void writeCustomBinFields() throws Exception {
	}

	@Override
	protected ResultSet getOperations() throws Exception {
		return null;
	}

	@Override
	protected ResultSet getBins() throws Exception {
		return null;
	}

	@Override
	protected List<String> getTimestampFields() throws Exception {
		return Arrays.asList("effective_date", "expiration_date");
	}

	@Override
	protected void writeCustomOperationTags() throws Exception {
	}
}
