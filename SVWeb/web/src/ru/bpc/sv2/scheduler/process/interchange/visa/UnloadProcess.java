package ru.bpc.sv2.scheduler.process.interchange.visa;

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

	private static final String[] operationCustomTags =
			{"trans_code_qualifier", "req_pay_service", "auth_code", "pos_terminal_cap", "crdh_id_method",
			 "pos_entry_mode", "central_proc_date", "reimburst_attr", "spec_cond_ind", "fee_program_ind",
			 "electr_comm_ind", "unatt_accept_term_ind", "pos_environment", "cvv2_result_code", "auth_resp_code"};

	private static final String[] binCustomTags =
			{"region", "country", "product_id", "fast_funds", "funding_source", "tech_indicator"};

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
		return "VISA";
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
	protected void writeCustomBinFields() throws Exception {
		writeTags(binCustomTags, "visa_bin", null);
	}

	@Override
	protected ResultSet getOperations() throws Exception {
		String sql =
				"SELECT /*+ parallel(auto)*/ o.id as oper_id, o.oper_type, o.msg_type, o.sttl_type, o.oper_date, o.host_date, o.oper_amount as oper_amount_value, o.oper_currency, o.oper_request_amount, " +
						"o.sttl_amount as sttl_amount_value, o.sttl_currency, o.network_refnum, o.acq_inst_bin, o.status, o.is_reversal, o.merchant_number, o.mcc, o.merchant_name, o.merchant_street, o.merchant_city, " +
						"o.merchant_region, o.merchant_country, o.merchant_postcode, o.terminal_type as terminal_type, o.terminal_number, pi.network_id iss_network_id, pi.inst_id as iss_inst_id, pi.card_country as iss_card_country, " +
						"c.card_number as iss_card_number, pa.inst_id as acq_inst_id, pa.network_id acq_network_id, " +
						"v.trans_code_qualifier, v.req_pay_service, v.auth_code, v.pos_terminal_cap, v.crdh_id_method, v.pos_entry_mode, v.central_proc_date, v.reimburst_attr, v.spec_cond_ind, " +
						"v.fee_program_ind, v.electr_comm_ind, v.unatt_accept_term_ind, v.pos_environment, v.cvv2_result_code, v.auth_resp_code, eo.id as event_id " +
						"FROM  opr_operation o, vis_fin_message v, opr_participant pi, opr_card c, opr_participant pa, evt_event_object eo, evt_event ee " +
						"WHERE eo.procedure_name=? AND eo.entity_type='ENTTOPER' AND ee.event_type=? AND o.id=eo.object_id AND pi.oper_id(+)=o.id AND pi.participant_type(+)='PRTYISS' " +
						"AND c.oper_id(+)=pi.oper_id AND pa.oper_id(+)=o.id AND pa.participant_type(+)='PRTYACQ' AND v.id(+)=o.id AND eo.status='EVST0001' AND eo.event_id=ee.id";
		pstm = process.getSsn().getCurrentConnection().prepareStatement(sql);
		pstm.setString(1, "RU.BPC.SV2.SCHEDULER.PROCESS.INTERCHANGE.UNLOADPROCESS");
		pstm.setString(2, eventType);
		return pstm.executeQuery();
	}

	@Override
	protected ResultSet getBins() throws Exception {
		String sql =
				"SELECT n.pan_low, n.pan_high, n.pan_length, n.priority, n.card_type_id, n.country, n.iss_inst_id, n.iss_network_id, n.card_network_id, n.card_inst_id, v.product_id," +
				"v.country, v.region, v.fast_funds, v.account_funding_source as funding_source, v.technology_indicator as tech_indicator " +
				"FROM net_bin_range n, vis_bin_range v WHERE n.pan_high=rpad(v.pan_high,v.pan_length,'9') AND n.pan_low=rpad(v.pan_low,v.pan_length,'0')";
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
		writeTags(operationCustomTags, "baseII_data", null);
	}
}
