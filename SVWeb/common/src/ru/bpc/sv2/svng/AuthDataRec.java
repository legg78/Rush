package ru.bpc.sv2.svng;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.SQLOutput;
import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

/**
 * BPC Group 2018 (c) All Rights Reserved
 */
public class AuthDataRec extends SQLDataRec {

	private final AuthData authData;

	public AuthDataRec(AuthData authData, Connection c) {
		super();
		this.authData = authData;
		setConnection(DBUtils.getNativeConnection(c));
	}

	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.AUTH_DATA_REC;
	}

	@Override
	public void writeSQL(SQLOutput s) throws SQLException {
		writeValueN(s, authData.getOperId()); 					// oper_id                           number(16)
		writeValueV(s, authData.getRespCode());					// resp_code                         varchar2(8)
		writeValueV(s, authData.getProcType());					// proc_type                         varchar2(8)
		writeValueV(s, authData.getProcMode());					// proc_mode                         varchar2(8)
		writeValueN(s, authData.getIsAdvice());					// is_advice                         number(1)
		writeValueN(s, authData.getIsRepeat());					// is_repeat                         number(1)
		writeValueN(s, authData.getBinAmount());				// bin_amount                        number
		writeValueV(s, authData.getBinCurrency());				// bin_currency                      varchar(3)
		writeValueN(s, authData.getBinCnvtRate());				// bin_cnvt_rate                     number
		writeValueN(s, authData.getNetworkAmount());			// network_amount                    number
		writeValueV(s, authData.getNetworkCurrency());			// network_currency                  varchar(3)
		writeValueV(s, authData.getNetworkCnvtDate());			// network_cnvt_date                 varchar2(20)
		writeValueN(s, authData.getNetworkCnvtRate());			// network_cnvt_rate                 number
		writeValueN(s, authData.getAccountCnvtRate());			// account_cnvt_rate                 number
		writeValueV(s, authData.getAddrVerifResult());			// addr_verif_result                 varchar2(8)
		writeValueV(s, authData.getAcqRespCode());				// acq_resp_code                     varchar2(8)
		writeValueV(s, authData.getAcqDeviceProcResult());		// acq_device_proc_result            varchar2(8)
		writeValueV(s, authData.getCatLevel());					// cat_level                         varchar2(8)
		writeValueV(s, authData.getCardDataInputCap());			// card_data_input_cap               varchar2(8)
		writeValueV(s, authData.getCrdhAuthCap());				// crdh_auth_cap                     varchar2(8)
		writeValueV(s, authData.getCardCaptureCap());			// card_capture_cap                  varchar2(8)
		writeValueV(s, authData.getTerminalOperatingEnv());		// terminal_operating_env            varchar2(8)
		writeValueV(s, authData.getCrdhPresence());				// crdh_presence                     varchar2(8)
		writeValueV(s, authData.getCardPresence());				// card_presence                     varchar2(8)
		writeValueV(s, authData.getCardDataInputMode());		// card_data_input_mode              varchar2(8)
		writeValueV(s, authData.getCrdhAuthMethod());			// crdh_auth_method                  varchar2(8)
		writeValueV(s, authData.getCrdhAuthEntity());			// crdh_auth_entity                  varchar2(8)
		writeValueV(s, authData.getCardDataOutputCap());		// card_data_output_cap              varchar2(8)
		writeValueV(s, authData.getTerminalOutputCap());		// terminal_output_cap               varchar2(8)
		writeValueV(s, authData.getPinCaptureCap());			// pin_capture_cap                   varchar2(8)
		writeValueV(s, authData.getPinPresence());				// pin_presence                      varchar2(8)
		writeValueV(s, authData.getCvv2Presence());				// cvv2_presence                     varchar2(8)
		writeValueV(s, authData.getCvcIndicator());				// cvc_indicator                     varchar2(8)
		writeValueV(s, authData.getPosEntryMode());				// pos_entry_mode                    varchar(3)
		writeValueV(s, authData.getPosCondCode());				// pos_cond_code                     varchar2(2)
		writeValueV(s, authData.getEmvData());					// emv_data                          varchar2(2000)
		writeValueV(s, authData.getAtc());						// atc                               varchar2(4)
		writeValueV(s, authData.getTvr());						// tvr                               varchar2(200)
		writeValueV(s, authData.getCvr());						// cvr                               varchar2(200)
		writeValueV(s, authData.getAddlData());					// addl_data                         varchar2(2000)
		writeValueV(s, authData.getServiceCode());				// service_code                      varchar(3)
		writeValueV(s, authData.getDeviceDate());				// device_date                       varchar2(20)
		writeValueV(s, authData.getCvv2Result());				// cvv2_result                       varchar2(8)
		writeValueV(s, authData.getCertificateMethod());		// certificate_method                varchar2(8)
		writeValueV(s, authData.getCertificateType());			// certificate_type                  varchar2(8)
		writeValueV(s, authData.getMerchantCertif());			// merchant_certif                   varchar2(100)
		writeValueV(s, authData.getCardholderCertif());			// cardholder_certif                 varchar2(100)
		writeValueV(s, authData.getUcafIndicator());			// ucaf_indicator                    varchar2(8)
		writeValueN(s, authData.getIsEarlyEmv());				// is_early_emv                      number(1)
		writeValueV(s, authData.getIsCompleted());				// is_completed                      varchar2(8)
		writeValueV(s, authData.getAmounts());					// amounts                           varchar2(4000)
		writeValueV(s, authData.getSystemTraceAuditNumber());	// system_trace_audit_number         varchar2(6)
		writeValueV(s, authData.getTransactionId());			// transaction_id                    varchar2(15)
		writeValueV(s, authData.getExternalAuthId());			// external_auth_id                  varchar2(30)
		writeValueV(s, authData.getExternalOrigId());			// external_orig_id                  varchar2(30)
		writeValueV(s, authData.getAgentUniqueId());			// agent_unique_id                   varchar2(5)
		writeValueV(s, authData.getNativeRespCode());			// native_resp_code                  varchar2(2)
		writeValueV(s, authData.getTraceNumber());				// trace_number                      varchar2(30)
		writeValueN(s, authData.getAuthPurposeId());			// auth_purpose_id                   number(16)
	}
}
