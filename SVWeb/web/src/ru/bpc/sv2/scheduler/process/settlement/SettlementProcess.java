package ru.bpc.sv2.scheduler.process.settlement;

import com.bpcbt.sv.merge.message.v1.ResultResponse;
import ru.bpc.sv.ws.cup.jms.DataMessageSender;
import ru.bpc.sv.ws.settlement.MergeClient;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import javax.xml.ws.Response;
import java.util.Map;

/**
 * Settlement bank interface for RedSys
 */
public class SettlementProcess extends IbatisExternalProcess {
	private static final String TIMEOUT_PARAM_KEY = "I_TIMEOUT";
	private static final String IN_FILE_PARAM_KEY = "I_IN_FILE";
	private static final String OUT_FILE_PARAM_KEY = "I_OUT_FILE";
	private static final String QUEUE_PARAM_KEY = "I_QUEUE";
	private String mqUrl;//for tests use tcp://localhost:61616
	private String queue;
	private String inFile;
	private String outFile;
	private int timeout = 60;

	@Override
	public void execute() throws SystemException, UserException {
		int cnt = 0;
		try {
			getIbatisSession();
			startSession();
			startLogging();
			trace("Settlement process started");
			MergeClient client = new MergeClient(mqUrl, queue + "_WS", processSessionId());
			trace("Sending merge request");
			Response<ResultResponse> response = client.sendMerge(queue, inFile, outFile);
			trace("Start waiting for result. Sending data");
			DataMessageSender sender = new DataMessageSender(mqUrl, processSessionId(), queue);
			//TODO add select from db
			String data = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
					"<pack><header><session-id>" + processSessionId() + "</session-id>" +
					"<data-type>POSTING</data-type><file-name>/home/smartfe/output/posting/OPS_20150408_152946_1001.dat</file-name>" +
					"<number>205</number><packs-total>205</packs-total><records-number>1</records-number>" +
					"<records-total>407926</records-total><additional-inf/></header><body><![CDATA[<?xml version=\"1.0\" encoding=\"UTF-8\"?><clearing xmlns=\"http://bpc.ru/sv/SVXP/clearing\"><file_type>FLTP1700</file_type><start_date>2015-04-13T12:27:48</start_date><operation><issuer><card_number>4213240068349163</card_number><account_amount>0</account_amount><card_expir_date>2016-01-31T23:59:59</card_expir_date><card_seq_number>0</card_seq_number><auth_code>122372</auth_code><account_currency>710</account_currency><account_number>000001</account_number><inst_id>1001</inst_id></issuer><destination><account_amount>0</account_amount></destination><sttl_amount><amount_value>0</amount_value><currency>710</currency></sttl_amount><oper_date>2015-08-26T17:38:07</oper_date><auth_data><network_cnvt_rate>0</network_cnvt_rate><bin_cnvt_rate>0</bin_cnvt_rate><network_cnvt_date>2015-11-30T00:00:00</network_cnvt_date><pos_entry_mode>000</pos_entry_mode><pos_cond_code>00</pos_cond_code><addr_verif_result>AVRS0000</addr_verif_result><cvv2_result>CV2R0003</cvv2_result><is_completed>CMPF0010</is_completed><card_data_input_cap>F2210001</card_data_input_cap><crdh_auth_cap>F2220000</crdh_auth_cap><card_capture_cap>F2230000</card_capture_cap><crdh_presence>F2250000</crdh_presence><card_presence>F2260000</card_presence><card_data_input_mode>F227000S</card_data_input_mode><crdh_auth_method>F2280000</crdh_auth_method><crdh_auth_entity>F2290000</crdh_auth_entity><card_data_output_cap>F22A0000</card_data_output_cap><terminal_output_cap>F22B0000</terminal_output_cap><pin_capture_cap>F22C0001</pin_capture_cap><addl_data>0070950206</addl_data><auth_tag><tag_name>DF8411</tag_name><tag_value>0</tag_value></auth_tag><auth_tag><tag_name>DF8423</tag_name><tag_value>140826173807</tag_value></auth_tag></auth_data><is_reversal>0</is_reversal><msg_type>MSGTAUTH</msg_type><host_date>2015-04-13T12:39:10</host_date><mcc>0000</mcc><oper_surcharge_amount><amount_value>0</amount_value><currency>000</currency></oper_surcharge_amount><acq_inst_bin>999999</acq_inst_bin><originator_refnum>000000122372</originator_refnum><terminal_number>50000007</terminal_number><acquirer><client_id_value>50000007</client_id_value><client_id_type>CITPTRMN</client_id_type><inst_id>1001</inst_id></acquirer><merchant_name>E-Pay</merchant_name><merchant_street>Street</merchant_street><merchant_city>Pretoria</merchant_city><merchant_region>RU</merchant_region><merchant_country>710</merchant_country><merchant_postcode>0000000000</merchant_postcode><oper_amount><currency>000</currency><amount_value>000000000000</amount_value></oper_amount><participant><account_currency>710</account_currency></participant><oper_type>OPTP9999</oper_type><merchant_number>10000020</merchant_number><terminal_type>TRMT0004</terminal_type><sttl_type>STTT0010</sttl_type><match_status>MTST0200</match_status><oper_reason>CSTS0006</oper_reason></operation></clearing>]]></body>" +
					"</pack>";
			long total = 1;
			sender.sendOperationsNoPack(data);

			int i = 0;
			while (!response.isDone() && i < timeout) {
				Thread.sleep(1000);
				i++;
			}
			if (!response.get().isResult()) {
				throw new Exception("Remote error: " + response.get().getError());
			}
			trace("Settlement process finished");
			endLogging(cnt, 0);
			commit();
		} catch (Exception ex) {
			error(ex);
			endLogging(0, 0);
			rollback();
			throw new UserException(ex);
		} finally {
			closeConAndSsn();
		}
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		mqUrl = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
		if (parameters.get(TIMEOUT_PARAM_KEY) != null) {
			timeout = Integer.valueOf(parameters.get(TIMEOUT_PARAM_KEY).toString());
		}
		queue = (String) parameters.get(QUEUE_PARAM_KEY);
		inFile = (String) parameters.get(IN_FILE_PARAM_KEY);
		outFile = (String) parameters.get(OUT_FILE_PARAM_KEY);
	}
}
