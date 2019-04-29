package ru.bpc.sv2.scheduler.process.interchange.amex;

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
	private static final String DATA_TYPE_PARAM_KEY = "I_INTER_DATA_TYPE";
	private static final String EVENT_TYPE_KEY = "I_INT_UNLOAD_EVENT";

	private String mqUrl;//for tests use tcp://localhost:61616
	private int timeout;
	private String eventType;
	private InterchangeDataTypes dataType;

	public UnloadProcess(IbatisExternalProcess process) {
		super(process);
	}

	@Override
	protected String getMqUrl() {
		return mqUrl;
	}

	@Override
	protected String getModuleName() {
		return "AMX";
	}

	@Override
	protected int getTimeout() {
		return timeout;
	}

	@Override
	protected InterchangeDataTypes getDataType() {
		return dataType;
	}

	public void setParameters(Map<String, Object> parameters) {
		mqUrl = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
		if (parameters.get(TIMEOUT_PARAM_KEY) != null) {
			timeout = Integer.valueOf(parameters.get(TIMEOUT_PARAM_KEY).toString());
		}
		if (parameters.containsKey(EVENT_TYPE_KEY)) {
			eventType = (String) parameters.get(EVENT_TYPE_KEY);
		}
		if (parameters.containsKey(DATA_TYPE_PARAM_KEY)) {
			String str = (String) parameters.get(DATA_TYPE_PARAM_KEY);
			if (str.equals("INCHOPER")) {
				dataType = InterchangeDataTypes.OPERATIONS;
			} else if (str.equals("INCHBINS")) {
				dataType = InterchangeDataTypes.BINS;
			} else if (str.equals("INCHCURR")) {
				dataType = InterchangeDataTypes.CURRENCY_RATES;
			}

		}
	}

	@Override
	protected void writeCustomBinFields() throws Exception {}

	@Override
	protected ResultSet getOperations() throws Exception {
		String sql =
				"SELECT o.id as oper_id, o.oper_type, o.msg_type, o.sttl_type, o.oper_date, o.host_date, o.oper_count, o.oper_amount as oper_amount_value, o.oper_currency, o.oper_request_amount, o.oper_surcharge_amount, o.oper_cashback_amount" +
						", o.originator_refnum, o.sttl_amount as sttl_amount_value, o.sttl_currency, o.network_refnum, o.acq_inst_bin, o.status_reason, o.oper_reason, o.status, o.is_reversal, o.merchant_number" +
						", o.mcc, o.merchant_name, o.merchant_street, o.merchant_city, o.merchant_region, o.merchant_country, o.merchant_postcode" +
						", o.terminal_type, o.terminal_number, o.payment_order_id, opi.card_country as iss_card_country, c.card_number as iss_card_number, opi.network_id iss_network_id, opi.card_network_id, opi.inst_id iss_inst_id" +
						", opa.inst_id acq_inst_id, opa.network_id acq_network_id, v.id as event_id  " +
						"FROM opr_operation o, opr_card c, opr_participant opi, opr_participant opa, evt_event_object v, evt_event e " +
						"WHERE v.procedure_name=? AND v.entity_type='ENTTOPER' AND v.eff_date<= sysdate AND e.id=v.event_id AND o.id=v.object_id " +
						"AND v.status='EVST0001' AND e.event_type=? AND opi.oper_id(+)=o.id AND c.oper_id(+)=opi.oper_id " +
						"AND opa.oper_id(+)=o.id AND nvl(opi.participant_type,'PRTYISS')='PRTYISS' AND nvl(opa.participant_type,'PRTYACQ')='PRTYACQ'";
		pstm = process.getSsn().getCurrentConnection().prepareStatement(sql);
		pstm.setString(1, "RU.BPC.SV2.SCHEDULER.PROCESS.INTERCHANGE.UNLOADPROCESS");
		pstm.setString(2, eventType);
		return pstm.executeQuery();
	}

	@Override
	protected ResultSet getBins() throws Exception {
		String sql ="SELECT pan_low, pan_high, pan_length, priority, card_type_id, country, iss_network_id," +
				"iss_inst_id, card_network_id, card_inst_id FROM net_bin_range WHERE card_network_id=1004";
		pstm = process.getSsn().getCurrentConnection().prepareStatement(sql);
		return pstm.executeQuery();
	}

	@Override
	protected List<String> getTimestampFields() throws Exception {
		switch (dataType) {
			case OPERATIONS:
				return Arrays.asList("oper_date", "host_date");
			default://for rates
				return Arrays.asList("effective_date", "expiration_date");
		}
	}

	@Override
	protected void writeCustomOperationTags() throws Exception {
	}
}
