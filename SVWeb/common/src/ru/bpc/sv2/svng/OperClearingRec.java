package ru.bpc.sv2.svng;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.SQLOutput;
import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

public class OperClearingRec extends SQLDataRec {
    private ClearingOperation operation;

    public OperClearingRec(ClearingOperation operation, Connection con) {
        this.operation = operation;
        setConnection(DBUtils.getNativeConnection(con));
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return AuthOracleTypeNames.T_OPER_CLEARING_REC;
    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        writeValueN(stream, operation.getId());                                                                  // oper_id
        writeValueN(stream, operation.getInstId());                                                              // default_inst_id
        writeValueV(stream, operation.getOperType());                                                            // oper_type
        writeValueV(stream, operation.getMsgType());                                                             // msg_type
        writeValueV(stream, operation.getSttlType());                                                            // sttl_type
        writeValueV(stream, operation.getReconType());                                                           // recon_type
        writeValueT(stream, operation.getOperDate());                                                            // oper_date
        writeValueT(stream, operation.getHostDate());                                                            // host_date
        writeValueN(stream, operation.getOperCount());                                                           // oper_count
        writeValueN(stream, operation.getOperAmount());                                                          // oper_amount_value
        writeValueV(stream, operation.getOperCurrency());                                                        // oper_amount_currency
        writeValueN(stream, operation.getOperRequestAmount());                                                   // oper_request_amount_value
        writeValueV(stream, operation.getOperRequestAmountCurrency());                                           // oper_request_amount_currency
        writeValueN(stream, operation.getOperSurchargeAmount());                                                 // oper_surcharge_amount_value
        writeValueV(stream, operation.getOperSurchargeAmountCurrency());                                         // oper_surcharge_amount_currency
        writeValueN(stream, operation.getOperCashbackAmount());                                                  // oper_cashback_amount_value
        writeValueV(stream, operation.getOperCashbackAmountCurrency());                                          // oper_cashback_amount_currency
        writeValueN(stream, operation.getSttlAmount());                                                          // sttl_amount_value
        writeValueV(stream, operation.getSttlCurrency());                                                        // sttl_amount_currency
        writeValueN(stream, operation.getInterchangeFee());                                                      // interchange_fee_value
        writeValueV(stream, operation.getInterchangeFeeCurrency());                                              // interchange_fee_currency
        writeValueV(stream, operation.getOperReason());                                                          // oper_reason
        writeValueV(stream, operation.getStatus());                                                              // status
        writeValueV(stream, operation.getStatusReason());                                                        // status_reason
        writeValueN(stream, (operation.getIsReversal()) ? Integer.valueOf(1) : Integer.valueOf(0));              // is_reversal
        writeValueV(stream, operation.getOriginatorRefnum());                                                    // originator_refnum
        writeValueV(stream, operation.getNetworkRefnum());                                                       // network_number
        writeValueN(stream, operation.getAcqInstBin() != null ? Long.valueOf(operation.getAcqInstBin()) : null); // acq_inst_bin
        writeValueV(stream, operation.getMerchantNumber());                                                      // merchant_number
        writeValueV(stream, operation.getMccCode());                                                             // mcc
        writeValueV(stream, operation.getMerchantName());                                                        // merchant_name
        writeValueV(stream, operation.getMerchantStreet());                                                      // merchant_street
        writeValueV(stream, operation.getMerchantCity());                                                        // merchant_city
        writeValueV(stream, operation.getMerchantRegion());                                                      // merchant_region
        writeValueV(stream, operation.getMerchantCountry());                                                     // merchant_country
        writeValueV(stream, operation.getMerchantPostCode());                                                    // merchant_postcode
        writeValueV(stream, operation.getTerminalType());                                                        // terminal_type
        writeValueV(stream, operation.getTerminalNumber());                                                      // terminal_number
        writeValueT(stream, operation.getSttlData());                                                            // sttl_date
        writeValueV(stream, operation.getExternalAuthId());                                                      // external_auth_id
        writeValueV(stream, operation.getExternalOrigId());                                                      // external_orig_id
        writeValueV(stream, operation.getTraceNumber());                                                         // trace_number
        writeValueN(stream, operation.getDisputeId());                                                           // dispute_id
        writeValueN(stream, operation.getPaymentOrderId());                                                      // payment_order_id
        writeValueV(stream, operation.getPaymentOrderStatus());                                                  // payment_order_status
        writeValueV(stream, operation.getPaymentOrderNumber());                                                  // payment_order_number
        writeValueN(stream, operation.getPurposeId());                                                           // purpose_id
        writeValueV(stream, operation.getPurposeNumber());                                                       // purpose_number
        writeValueN(stream, operation.getPaymentOrderAmount());                                                  // payment_order_amount
        writeValueV(stream, operation.getPaymentOrderCurrency());                                                // payment_order_currency
        writeValueV(stream, operation.getPaymentOrderPrtyType());                                                // payment_order_prty_type
        writeValueV(stream, operation.getIssClientIdType());                                                     // issuer_client_id_type
        writeValueV(stream, operation.getIssClientIdValue());                                                    // issuer_client_id_value
        writeValueV(stream, operation.getIssCardNumber());                                                       // issuer_card_number
        writeValueN(stream, operation.getIssCardId());                                                           // issuer_card_id
        writeValueN(stream, operation.getIssCardSeqNumber());                                                    // issuer_card_seq_number
        writeValueT(stream, operation.getIssCardExpirDate());                                                    // issuer_card_expir_date
        writeValueN(stream, operation.getIssInstId());                                                           // issuer_inst_id
        writeValueN(stream, operation.getIssNetworkId());                                                        // issuer_network_id
        writeValueV(stream, operation.getIssAuthCode());                                                         // issuer_auth_code
        writeValueN(stream, operation.getIssAccountAmount());                                                    // issuer_account_amount
        writeValueV(stream, operation.getIssAccountCurrency());                                                  // issuer_account_currency
        writeValueV(stream, operation.getIssAccountNumber());                                                    // issuer_account_number
        writeValueV(stream, operation.getAcqClientIdType());                                                     // acquirer_client_id_type       varchar2
        writeValueV(stream, operation.getAcqClientIdvalue());                                                    // acquirer_client_id_value      varchar2
        writeValueV(stream, operation.getAcqCardNumber());                                                       // acquirer_card_number          varchar2
        writeValueN(stream, operation.getAcqCardSeqNumber());                                                    // acquirer_card_seq_number      number
        writeValueT(stream, operation.getAcqCardExpirDate());                                                    // acquirer_card_expir_date      date
        writeValueN(stream, operation.getAcqInstId());                                                           // acquirer_inst_id              number
        writeValueN(stream, operation.getAcqNetworkId());                                                        // acquirer_network_id           number
        writeValueV(stream, operation.getAcqAuthCode());                                                         // acquirer_auth_code            varchar2
        writeValueN(stream, operation.getAcqAccountAmount());                                                    // acquirer_account_amount       number
        writeValueV(stream, operation.getAcqAccountCurrency());                                                  // acquirer_account_currency     varchar2
        writeValueV(stream, operation.getAcqAccountNumber());                                                    // acquirer_account_number       varchar2
        writeValueV(stream, operation.getDestinationClientIdType());                                             // destination_client_id_type    varchar2
        writeValueV(stream, operation.getDestinationClientIdvalue());                                            // destination_client_id_value   varchar2
        writeValueV(stream, operation.getDestinationCardNumber());                                               // destination_card_number       varchar2
        writeValueN(stream, operation.getDestinationCardId());                                                   // destination_card_id           number
        writeValueN(stream, operation.getDestinationCardSeqNumber());                                            // destination_card_seq_number   number
        writeValueT(stream, operation.getDestinationCardExpirDate());                                            // destination_card_expir_date   date
        writeValueN(stream, operation.getDestinationInstId());                                                   // destination_inst_id           number
        writeValueN(stream, operation.getDestinationNetworkId());                                                // destination_network_id        number
        writeValueV(stream, operation.getDestinationAuthCode());                                                 // destination_auth_code         varchar2
        writeValueN(stream, operation.getDestinationAccountAmount());                                            // destination_account_amount    number
        writeValueV(stream, operation.getDestinationAccountCurrency());                                          // destination_account_currency  varchar2
        writeValueV(stream, operation.getDestinationAccountNumber());                                            // destination_account_number    varchar2
        writeValueV(stream, operation.getAggregatorClientIdType());                                              // aggregator_client_id_type     varchar2
        writeValueV(stream, operation.getAggregatorClientIdvalue());                                             // aggregator_client_id_value    varchar2
        writeValueV(stream, operation.getAggregatorCardNumber());                                                // aggregator_card_number        varchar2
        writeValueN(stream, operation.getAggregatorCardSeqNumber());                                             // aggregator_card_seq_number    number
        writeValueT(stream, operation.getAggregatorCardExpirDate());                                             // aggregator_card_expir_date    date
        writeValueN(stream, operation.getAggregatorInstId());                                                    // aggregator_inst_id            number
        writeValueN(stream, operation.getAggregatorNetworkId());                                                 // aggregator_network_id         number
        writeValueV(stream, operation.getAggregatorAuthCode());                                                  // aggregator_auth_code          varchar2
        writeValueN(stream, operation.getAggregatorAccountAmount());                                             // aggregator_account_amount     number
        writeValueV(stream, operation.getAggregatorAccountCurrency());                                           // aggregator_account_currency   varchar2
        writeValueV(stream, operation.getAggregatorAccountNumber());                                             // aggregator_account_number     varchar2
        writeValueV(stream, operation.getSrvpClientIdType());                                                    // srvp_client_id_type           varchar2
        writeValueV(stream, operation.getSrvpClientIdvalue());                                                   // srvp_client_id_value          varchar2
        writeValueV(stream, operation.getSrvpCardNumber());                                                      // srvp_card_number              varchar2
        writeValueN(stream, operation.getSrvpCardSeqNumber());                                                   // srvp_card_seq_number          number
        writeValueT(stream, operation.getSrvpCardExpirDate());                                                   // srvp_card_expir_date          date
        writeValueN(stream, operation.getSrvpInstId());                                                          // srvp_inst_id                  number
        writeValueN(stream, operation.getSrvpNetworkId());                                                       // srvp_network_id               number
        writeValueV(stream, operation.getSrvpAuthCode());                                                        // srvp_auth_code                varchar2
        writeValueN(stream, operation.getSrvpAccountAmount());                                                   // srvp_account_amount           number
        writeValueV(stream, operation.getSrvpAccountCurrency());                                                 // srvp_account_currency         varchar2
        writeValueV(stream, operation.getSrvpAccountNumber());                                                   // srvp_account_number           varchar2
        writeValueN(stream, operation.isPaymentOrderExists() ? Integer.valueOf(1) : Integer.valueOf(0));         // payment_order_exists          number
        writeValueN(stream, operation.isIssuerExists() ? Integer.valueOf(1) : Integer.valueOf(0));               // issuer_exists                 number
        writeValueN(stream, operation.isAcquirerExists() ? Integer.valueOf(1) : Integer.valueOf(0));             // acquirer_exists               number
        writeValueN(stream, operation.isDestinationExists() ? Integer.valueOf(1) : Integer.valueOf(0));          // destination_exists            number
        writeValueN(stream, operation.isAggregatorExists() ? Integer.valueOf(1) : Integer.valueOf(0));           // aggregator_exists             number
        writeValueN(stream, operation.isServiceProviderExists() ? Integer.valueOf(1) : Integer.valueOf(0));      // service_provider_exists       number
        writeValueN(stream, operation.getIncomSessFileId());                                                     // incom_sess_file_id            number
        writeValueV(stream, operation.getMatchStatus());                                                         // match_status                  varchar2
        writeValueClob(stream, operation.getPaymentParameters());                                                // payment_parameters            clob
        writeValueClob(stream, operation.getParticipant());                                                      // participant                   clob
        writeValueClob(stream, operation.getNote());                                                             // note                          clob
        writeValueClob(stream, operation.getAuthData());                                                         // auth_data                     clob
        writeValueClob(stream, operation.getIpmData());                                                          // ipm_data                      clob
        writeValueClob(stream, operation.getBaseiiData());                                                       // baseii_data                   clob
        writeValueClob(stream, operation.getAdditionalAmount());                                                 // additional_amount             clob
        writeValueClob(stream, operation.getProcessingStage());                                                  // processing_stage              clob
        writeValueT(stream, operation.getAcqSttlDate());                                                         // acq_sttl_date                 date
        writeValueNull(stream);                                                                                  // flexible_data                 clob
        writeValueN(stream, operation.getOriginalId());                                                          // original_id                   number
        writeValueNull(stream);                                                                                  // issuer_prty_type              varchar2
        writeValueNull(stream);                                                                                  // issuer_card_instance_id       number
        writeValueNull(stream);                                                                                  // acquirer_prty_type            varchar2
        writeValueNull(stream);                                                                                  // acquirer_card_id              number
        writeValueNull(stream);                                                                                  // acquirer_card_instance_id     number
        writeValueNull(stream);                                                                                  // destination_prty_type         varchar2
        writeValueNull(stream);                                                                                  // destination_card_instance_id  number
        writeValueNull(stream);                                                                                  // aggregator_prty_type          varchar2
        writeValueNull(stream);                                                                                  // aggregator_card_id            number
        writeValueNull(stream);                                                                                  // aggregator_card_instance_id   number
        writeValueNull(stream);                                                                                  // srvp_prty_type                varchar2
        writeValueNull(stream);                                                                                  // srvp_card_id                  number
        writeValueNull(stream);                                                                                  // srvp_card_instance_id         number
        writeValueN(stream, operation.getOperIdBatch());                                                         // oper_id_batch                 number
        writeValueV(stream, operation.getForwInstBin());                                                         // forwarding_inst_bin           varchar2
    }
}
