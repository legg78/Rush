package ru.bpc.sv2.scheduler.process.interchange.mc;

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
			{"is_incoming", "impact", "mti", "de024", "de003_1", "de014", "de022_1", "de022_2", "de022_3", "de022_4",
			 "de022_5", "de022_6", "de022_7", "de022_8", "de022_9", "de022_10", "de022_11", "de022_12",
			 "de031", "de032", "de033", "de037", "de038", "de040", "de042", "p0043", "p0158_1", "p0158_2", "p0158_3",
			 "p0158_4", "p0505", "p0506", "p0508", "p0520", "p0521", "p0523", "p0524", "p0544", "p0545", "p0546",
			 "p0550", "p0551", "p0568", "p0574", "p0575", "p0576", "p0596", "p0597", "p0600", "p0620", "p0623", "p0629",
			 "p0630", "p0631", "p0632", "p0641", "p0642", "p0643", "p0646", "p0648", "p0664", "p0665", "p0682",
			 "p0757"};

	private static final String[] binCustomTags = {"product_id", "brand", "member_id", "product_type", "region"};

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
		return "MC";
	}

	@Override
	protected int getTimeout() {
		return timeout;
	}

	@Override
	protected InterchangeDataTypes getDataType() {
		return dataType;
	}

	@Override
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
		writeTags(binCustomTags, "mastercard_bin", null);
	}

	@Override
	protected ResultSet getOperations() throws Exception {
		String sql =
				"SELECT /*+ parallel(auto)*/ o.id as oper_id, o.oper_type, o.msg_type, o.sttl_type, o.oper_date, o.host_date, o.oper_amount as oper_amount_value, o.oper_currency, o.oper_request_amount," +
						"o.sttl_amount as sttl_amount_value, o.sttl_currency, o.network_refnum, o.acq_inst_bin, o.status, o.is_reversal, o.merchant_number, o.mcc, o.merchant_name, o.merchant_street," +
						"o.merchant_city, o.merchant_region, o.merchant_country, o.merchant_postcode, o.terminal_type, o.terminal_number, pi.network_id iss_network_id," +
						"pi.inst_id as iss_inst_id, pi.card_country as iss_card_country, c.card_number as iss_card_number, pa.inst_id as acq_inst_id, pa.network_id acq_network_id," +
						"m.is_incoming, m.impact, m.mti, m.de024, m.de003_1, m.de014, m.de022_1, m.de022_2, m.de022_3, m.de022_4, m.de022_5, m.de022_6, m.de022_7, m.de022_8," +
						"m.de022_9, m.de022_10, m.de022_11, m.de022_12, m.de031, m.de032, m.de033, m.de037, m.de038, m.de040, m.de042, m.p0043, m.p0158_1, m.p0158_2," +
						"m.p0158_3, m.p0158_4, pds.p0505, pds.p0506, pds.p0508, pds.p0520, pds.p0521, pds.p0523, pds.p0524, pds.p0544, pds.p0545, pds.p0546, pds.p0550, pds.p0551," +
						"pds.p0568, pds.p0574, pds.p0575, pds.p0576, pds.p0596, pds.p0597, pds.p0600, pds.p0620, pds.p0623, pds.p0629, pds.p0630, pds.p0631, pds.p0632, pds.p0641," +
						"pds.p0642, pds.p0643, pds.p0646, pds.p0648, pds.p0664, pds.p0665, pds.p0682, pds.p0757, eo.id as event_id " +
						"FROM opr_operation o, mcw_fin m, opr_participant pi, opr_card c, opr_participant pa, evt_event_object eo, evt_event ee," +
						"(SELECT * FROM (SELECT msg_id, pds_number, pds_body FROM mcw_msg_pds) pivot (MAX(pds_body) FOR pds_number IN (505 as p0505, 506 as p0506, 508 as p0508, 520 as p0520," +
						"521 as p0521, 523 as p0523, 524 as p0524, 544 as p0544, 545 as p0545, 546 as p0546, 550 as p0550, 551 as p0551, 568 as p0568, 574 as p0574, 575 as p0575, 576 as p0576," +
						"596 as p0596, 597 as p0597, 600 as p0600, 620 as p0620, 623 as p0623, 629 as p0629, 630 as p0630, 631 as p0631, 632 as p0632, 641 as p0641, 642 as p0642, 643 as p0643," +
						"646 as p0646, 648 as p0648, 664 as p0664, 665 as p0665, 682 as p0682, 757 as p0757))) pds " +
						"WHERE eo.procedure_name=? AND eo.entity_type='ENTTOPER' AND ee.event_type=? AND o.id=eo.object_id AND pi.oper_id(+)=o.id AND pi.participant_type(+)='PRTYISS' " +
						"AND c.oper_id(+)=pi.oper_id AND pa.oper_id(+)=o.id AND pa.participant_type(+)='PRTYACQ' AND m.id(+)=o.id AND pds.msg_id(+)=o.id AND eo.status='EVST0001' AND eo.event_id=ee.id";
		pstm = process.getSsn().getCurrentConnection().prepareStatement(sql);
		pstm.setString(1, "RU.BPC.SV2.SCHEDULER.PROCESS.INTERCHANGE.UNLOADPROCESS");
		pstm.setString(2, eventType);
		return pstm.executeQuery();
	}

	@Override
	protected ResultSet getBins() throws Exception {
		String sql =
				"SELECT DISTINCT n.pan_low, n.pan_high, n.pan_length, n.priority, n.card_type_id, n.country, n.iss_inst_id, " +
						"n.iss_network_id, n.card_network_id, n.card_inst_id, MIN(m.product_id) keep (DENSE_RANK FIRST ORDER BY m.priority) product_id, " +
						"MIN(m.brand) keep (DENSE_RANK FIRST ORDER BY m.priority) brand, MIN(m.member_id) member_id, MIN(m.product_type) product_type, MIN(m.region) region " +
						"FROM net_bin_range n, mcw_bin_range m WHERE n.pan_high = m.pan_high AND n.pan_low= m.pan_low GROUP BY n.pan_low, n.pan_high, n.pan_length, " +
						"n.priority, n.card_type_id, n.country, n.iss_inst_id, n.iss_network_id, n.card_network_id, n.card_inst_id ";
		pstm = process.getSsn().getCurrentConnection().prepareStatement(sql);
		return pstm.executeQuery();
	}

	@Override
	protected List<String> getTimestampFields() throws Exception {
		switch (dataType) {
			case OPERATIONS:
				return Arrays.asList("de014", "oper_date", "host_date");
			default://for rates
				return Arrays.asList("effective_date", "expiration_date");
		}
	}

	@Override
	protected void writeCustomOperationTags() throws Exception {
		writeTags(operationCustomTags, "ipm_data", null);
	}
}
