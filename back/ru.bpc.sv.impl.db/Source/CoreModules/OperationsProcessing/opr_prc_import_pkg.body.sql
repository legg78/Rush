create or replace package body opr_prc_import_pkg as
/*********************************************************
*  Import posting file <br />
*  Created by Filimonov A.(filimonov@bpc.ru) at 30.03.2010 <br />
*  Module: opr_prc_import_pkg <br />
*  @headcom
**********************************************************/

-- If i_import_clear_pan == FALSE then process expects encoded
-- PANs (tokens) in incoming file(s) when tokenization is enabled.
-- Also decoding tokens is executed with masking errors to prevent
-- process' failure on fetching cursor if there is any problem token in XML.
cursor cur_operations(
    i_session_id          in     com_api_type_pkg.t_long_id
  , i_thread_number       in     com_api_type_pkg.t_tiny_id
  , i_import_clear_pan    in     com_api_type_pkg.t_boolean
  , i_splitted_files      in     com_api_type_pkg.t_boolean
) is
select
    opr.oper_id
  , opr.def_inst
  , opr.oper_type
  , opr.msg_type
  , opr.sttl_type
  , opr.recon_type
  , opr.oper_date
  , opr.host_date
  , opr.oper_count
  , opr.oper_amount_value
  , opr.oper_amount_currency
  , opr.oper_request_amount_value
  , opr.oper_request_amount_currency
  , opr.oper_surcharge_amount_value
  , opr.oper_surcharge_amount_currency
  , opr.oper_cashback_amount_value
  , opr.oper_cashback_amount_currency
  , opr.sttl_amount_value
  , opr.sttl_amount_currency
  , opr.interchange_fee_value
  , opr.interchange_fee_currency
  , opr.oper_reason
  , opr.status
  , opr.status_reason
  , opr.is_reversal
  , opr.originator_refnum
  , opr.network_refnum
  , opr.acq_inst_bin
  , opr.forw_inst_bin
  , opr.merchant_number
  , opr.mcc
  , opr.merchant_name
  , opr.merchant_street
  , opr.merchant_city
  , opr.merchant_region
  , opr.merchant_country
  , opr.merchant_postcode
  , opr.terminal_type
  , opr.terminal_number
  , opr.sttl_date
  , opr.acq_sttl_date

  , opr.external_auth_id
  , opr.external_orig_id
  , trim(leading '0' from opr.trace_number) as trace_number
  , to_number(null)                         as dispute_id

  , opr.payment_order_id
  , opr.payment_order_status
  , opr.payment_order_number
  , opr.purpose_id
  , opr.purpose_number
  , opr.payment_order_amount
  , opr.payment_order_currency
  , opr.payment_date
  , opr.payment_order_prty_type
  , opr.payment_parameters

  , opr.issuer_client_id_type
  , opr.issuer_client_id_value
  , case i_import_clear_pan
        when com_api_const_pkg.TRUE
        then opr.issuer_card_number
        else iss_api_token_pkg.decode_card_number(i_card_number => opr.issuer_card_number
                                                , i_mask_error  => com_api_const_pkg.TRUE)
    end as issuer_card_number
  , opr.issuer_card_id
  , opr.issuer_card_seq_number
  , opr.issuer_card_expir_date
  , opr.issuer_inst_id
  , opr.issuer_network_id
  , opr.issuer_auth_code
  , opr.issuer_account_amount
  , opr.issuer_account_currency
  , opr.issuer_account_number

  , opr.acquirer_client_id_type
  , opr.acquirer_client_id_value
  , case i_import_clear_pan
        when com_api_const_pkg.TRUE
        then opr.acquirer_card_number
        else iss_api_token_pkg.decode_card_number(i_card_number => opr.acquirer_card_number
                                                , i_mask_error  => com_api_const_pkg.TRUE)
    end as acquirer_card_number
  , opr.acquirer_card_seq_number
  , opr.acquirer_card_expir_date
  , opr.acquirer_inst_id
  , opr.acquirer_network_id
  , opr.acquirer_auth_code
  , opr.acquirer_account_amount
  , opr.acquirer_account_currency
  , opr.acquirer_account_number

  , opr.destination_client_id_type
  , opr.destination_client_id_value
  , case i_import_clear_pan
        when com_api_const_pkg.TRUE
        then opr.destination_card_number
        else iss_api_token_pkg.decode_card_number(i_card_number => opr.destination_card_number
                                                , i_mask_error  => com_api_const_pkg.TRUE)
    end
  , opr.destination_card_id
  , opr.destination_card_seq_number
  , opr.destination_card_expir_date
  , opr.destination_inst_id
  , opr.destination_network_id
  , opr.destination_auth_code
  , opr.destination_account_amount
  , opr.destination_account_currency
  , opr.destination_account_number

  , opr.aggregator_client_id_type
  , opr.aggregator_client_id_value
  , case i_import_clear_pan
        when com_api_const_pkg.TRUE
        then opr.aggregator_card_number
        else iss_api_token_pkg.decode_card_number(i_card_number => opr.aggregator_card_number
                                                , i_mask_error  => com_api_const_pkg.TRUE)
    end as aggregator_card_number
  , opr.aggregator_card_seq_number
  , opr.aggregator_card_expir_date
  , opr.aggregator_inst_id
  , opr.aggregator_network_id
  , opr.aggregator_auth_code
  , opr.aggregator_account_amount
  , opr.aggregator_account_currency
  , opr.aggregator_account_number

  , opr.srvp_client_id_type
  , opr.srvp_client_id_value
  , case i_import_clear_pan
        when com_api_const_pkg.TRUE
        then opr.srvp_card_number
        else iss_api_token_pkg.decode_card_number(i_card_number => opr.srvp_card_number
                                                , i_mask_error  => com_api_const_pkg.TRUE)
    end as srvp_card_number
  , opr.srvp_card_seq_number
  , opr.srvp_card_expir_date
  , opr.srvp_inst_id
  , opr.srvp_network_id
  , opr.srvp_auth_code
  , opr.srvp_account_amount
  , opr.srvp_account_currency
  , opr.srvp_account_number

  , opr.participant

  , opr.payment_order_exists
  , opr.issuer_exists
  , opr.acquirer_exists
  , opr.destination_exists
  , opr.aggregator_exists
  , opr.service_provider_exists
  , opr.incom_sess_file_id
  , opr.note
  , opr.auth_data
  , opr.ipm_data
  , opr.baseii_data
  , opr.match_status
  , opr.additional_amount
  , opr.processing_stage
  , opr.flexible_data
from (
    select
        x.oper_id
      , z.inst_id def_inst
      , x.oper_type
      , x.msg_type
      , x.sttl_type
      , x.recon_type
      , to_date(x.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT) oper_date
      , to_date(x.host_date, com_api_const_pkg.XML_DATETIME_FORMAT) host_date
      , nvl(oper_count, 1) oper_count
      , x.oper_amount_value
      , x.oper_amount_currency
      , x.oper_request_amount_value
      , x.oper_request_amount_currency
      , x.oper_surcharge_amount_value
      , x.oper_surcharge_amount_currency
      , x.oper_cashback_amount_value
      , x.oper_cashback_amount_currency
      , x.sttl_amount_value
      , x.sttl_amount_currency
      , x.interchange_fee_value
      , x.interchange_fee_currency
      , x.oper_reason
      , x.status
      , x.status_reason
      , x.is_reversal
      , x.originator_refnum
      , x.network_refnum
      , x.acq_inst_bin
      , x.forw_inst_bin
      , x.merchant_number
      , x.mcc
      , x.merchant_name
      , x.merchant_street
      , x.merchant_city
      , x.merchant_region
      , x.merchant_country
      , x.merchant_postcode
      , x.terminal_type
      , x.terminal_number
      , to_date(x.sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT) sttl_date
      , to_date(x.acq_sttl_date, com_api_const_pkg.XML_DATETIME_FORMAT) acq_sttl_date

      , x.external_auth_id
      , x.external_orig_id
      , x.trace_number

      , x.payment_order_id
      , x.payment_order_status
      , x.payment_order_number
      , x.purpose_id
      , x.purpose_number
      , x.payment_order_amount
      , x.payment_order_currency
      , to_date(x.payment_date, com_api_const_pkg.XML_DATETIME_FORMAT) payment_date
      , x.payment_order_prty_type
      , x.payment_parameters

      , x.issuer_client_id_type
      , x.issuer_client_id_value
      , x.issuer_card_number
      , x.issuer_card_id
      , x.issuer_card_seq_number
      , to_date(x.issuer_card_expir_date, com_api_const_pkg.XML_DATETIME_FORMAT) issuer_card_expir_date
      , x.issuer_inst_id
      , x.issuer_network_id
      , x.issuer_auth_code
      , x.issuer_account_amount
      , x.issuer_account_currency
      , x.issuer_account_number

      , x.acquirer_client_id_type
      , x.acquirer_client_id_value
      , x.acquirer_card_number
      , x.acquirer_card_seq_number
      , to_date(x.acquirer_card_expir_date, com_api_const_pkg.XML_DATETIME_FORMAT) acquirer_card_expir_date
      , x.acquirer_inst_id
      , x.acquirer_network_id
      , x.acquirer_auth_code
      , x.acquirer_account_amount
      , x.acquirer_account_currency
      , x.acquirer_account_number

      , x.destination_client_id_type
      , x.destination_client_id_value
      , x.destination_card_number
      , x.destination_card_id
      , x.destination_card_seq_number
      , to_date(x.destination_card_expir_date, com_api_const_pkg.XML_DATETIME_FORMAT) destination_card_expir_date
      , x.destination_inst_id
      , x.destination_network_id
      , x.destination_auth_code
      , x.destination_account_amount
      , x.destination_account_currency
      , x.destination_account_number

      , x.aggregator_client_id_type
      , x.aggregator_client_id_value
      , x.aggregator_card_number
      , x.aggregator_card_seq_number
      , to_date(x.aggregator_card_expir_date, com_api_const_pkg.XML_DATETIME_FORMAT) aggregator_card_expir_date
      , x.aggregator_inst_id
      , x.aggregator_network_id
      , x.aggregator_auth_code
      , x.aggregator_account_amount
      , x.aggregator_account_currency
      , x.aggregator_account_number

      , x.srvp_client_id_type
      , x.srvp_client_id_value
      , x.srvp_card_number
      , x.srvp_card_seq_number
      , to_date(x.srvp_card_expir_date, com_api_const_pkg.XML_DATETIME_FORMAT) srvp_card_expir_date
      , x.srvp_inst_id
      , x.srvp_network_id
      , x.srvp_auth_code
      , x.srvp_account_amount
      , x.srvp_account_currency
      , x.srvp_account_number

      , x.participant

      , x.payment_order_exists
      , x.issuer_exists
      , x.acquirer_exists
      , x.destination_exists
      , x.aggregator_exists
      , x.service_provider_exists
      , s.id incom_sess_file_id
      , x.note
      , x.auth_data
      , x.ipm_data
      , x.baseii_data
      , x.match_status
      , x.additional_amount
      , x.processing_stage
      , x.flexible_data

      , case
            when x.oper_type = opr_api_const_pkg.OPERATION_TYPE_VIRTUAL_CARD
                 and x.issuer_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD
            then
                (
                    select opr_api_const_pkg.CLIENT_ID_TYPE_CARD || '/' || xt.tag_value
                      from xmltable(
                               xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing'),
                               '/auth_data/auth_tag'
                               passing x.auth_data
                               columns tag_id       number          path 'tag_id'
                                     , tag_value    varchar2(2000)  path 'tag_value'
                           ) xt
                     where xt.tag_id = aup_api_const_pkg.TAG_SECOND_CARD_NUMBER
                       and rownum = 1
                )
            else x.issuer_client_id_type || '/' || x.issuer_client_id_value
        end  as  split_hash
    from prc_session_file s
       , prc_file_attribute a
       , prc_file f
       , xmltable(
             xmlnamespaces('http://bpc.ru/sv/SVXP/clearing' as "svxp")
           , '/svxp:clearing'
             passing s.file_xml_contents
             columns
                 inst_id                             number        path 'svxp:inst_id'
               , opers                               xmltype       path 'svxp:operation'
         ) z
       , xmltable(
             xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing')
           , '/operation'
             passing z.opers
             columns
                 oper_id                           number        path 'oper_id'
               , oper_type                         varchar2(8)   path 'oper_type'
               , msg_type                          varchar2(8)   path 'msg_type'
               , sttl_type                         varchar2(8)   path 'sttl_type'
               , recon_type                        varchar2(8)   path 'reconciliation_type'
               , oper_date                         varchar2(20)  path 'oper_date'
               , host_date                         varchar2(20)  path 'host_date'
               , oper_count                        number        path 'oper_count'
               , oper_amount_value                 number        path 'oper_amount/amount_value'
               , oper_amount_currency              varchar2(3)   path 'oper_amount/currency'
               , oper_request_amount_value         number        path 'oper_request_amount/amount_value'
               , oper_request_amount_currency      varchar2(3)   path 'oper_request_amount/currency'
               , oper_surcharge_amount_value       number        path 'oper_surcharge_amount/amount_value'
               , oper_surcharge_amount_currency    varchar2(3)   path 'oper_surcharge_amount/currency'
               , oper_cashback_amount_value        number        path 'oper_cashback_amount/amount_value'
               , oper_cashback_amount_currency     varchar2(3)   path 'oper_cashback_amount/currency'
               , sttl_amount_value                 number        path 'sttl_amount/amount_value'
               , sttl_amount_currency              varchar2(3)   path 'sttl_amount/currency'
               , interchange_fee_value             number        path 'interchange_fee/amount_value'
               , interchange_fee_currency          varchar2(3)   path 'interchange_fee/currency'
               , oper_reason                       varchar2(8)   path 'oper_reason'
               , status                            varchar2(8)   path 'status'
               , status_reason                     varchar2(8)   path 'status_reason'
               , is_reversal                       number        path 'is_reversal'
               , originator_refnum                 varchar2(36)  path 'originator_refnum'
               , network_refnum                    varchar2(36)  path 'network_refnum'
               , acq_inst_bin                      varchar2(12)  path 'acq_inst_bin'
               , forw_inst_bin                     varchar2(12)  path 'forwarding_inst_bin'
               , merchant_number                   varchar2(15)  path 'merchant_number'
               , mcc                               varchar2(4)   path 'mcc'
               , merchant_name                     varchar2(200) path 'merchant_name'
               , merchant_street                   varchar2(200) path 'merchant_street'
               , merchant_city                     varchar2(200) path 'merchant_city'
               , merchant_region                   varchar2(3)   path 'merchant_region'
               , merchant_country                  varchar2(3)   path 'merchant_country'
               , merchant_postcode                 varchar2(10)  path 'merchant_postcode'
               , terminal_type                     varchar2(8)   path 'terminal_type'
               , terminal_number                   varchar2(16)  path 'terminal_number'
               , sttl_date                         varchar2(20)  path 'sttl_date'
               , acq_sttl_date                     varchar2(20)  path 'acq_sttl_date'

               , external_auth_id                  varchar2(30)  path 'auth_data/external_auth_id'
               , external_orig_id                  varchar2(30)  path 'auth_data/external_orig_id'
               , trace_number                      varchar2(30)  path 'auth_data/trace_number'

               , payment_order_id                  number        path 'payment_order/payment_order_id'
               , payment_order_status              varchar2(8)   path 'payment_order/payment_order_status'
               , payment_order_number              varchar2(200) path 'payment_order/payment_order_number'
               , purpose_id                        number        path 'payment_order/purpose_id'
               , purpose_number                    varchar2(200) path 'payment_order/purpose_number'
               , payment_order_amount              number        path 'payment_order/payment_amount/amount_value'
               , payment_order_currency            varchar2(3)   path 'payment_order/payment_amount/currency'
               , payment_date                      varchar2(20)  path 'payment_order/payment_date'
               , payment_order_prty_type           varchar2(8)   path 'payment_order/participant_type'
               , payment_parameters                xmltype       path 'payment_order/payment_parameter'

               , issuer_client_id_type             varchar2(8)   path 'issuer/client_id_type'
               , issuer_client_id_value            varchar2(200) path 'issuer/client_id_value'
               , issuer_card_number                varchar2(24)  path 'issuer/card_number'
               , issuer_card_id                    number(12)    path 'issuer/card_id'
               , issuer_card_seq_number            number        path 'issuer/card_seq_number'
               , issuer_card_expir_date            varchar2(20)  path 'issuer/card_expir_date'
               , issuer_inst_id                    number        path 'issuer/inst_id'
               , issuer_network_id                 number        path 'issuer/network_id'
               , issuer_auth_code                  varchar2(6)   path 'issuer/auth_code'
               , issuer_account_amount             number        path 'issuer/account_amount'
               , issuer_account_currency           varchar2(3)   path 'issuer/account_currency'
               , issuer_account_number             varchar2(32)  path 'issuer/account_number'

               , acquirer_client_id_type           varchar2(8)   path 'acquirer/client_id_type'
               , acquirer_client_id_value          varchar2(200) path 'acquirer/client_id_value'
               , acquirer_card_number              varchar2(24)  path 'acquirer/card_number'
               , acquirer_card_seq_number          number        path 'acquirer/card_seq_number'
               , acquirer_card_expir_date          varchar2(20)  path 'acquirer/card_expir_date'
               , acquirer_inst_id                  number        path 'acquirer/inst_id'
               , acquirer_network_id               number        path 'acquirer/network_id'
               , acquirer_auth_code                varchar2(6)   path 'acquirer/auth_code'
               , acquirer_account_amount           number        path 'acquirer/account_amount'
               , acquirer_account_currency         varchar2(3)   path 'acquirer/account_currency'
               , acquirer_account_number           varchar2(32)  path 'acquirer/account_number'

               , destination_client_id_type        varchar2(8)   path 'destination/client_id_type'
               , destination_client_id_value       varchar2(200) path 'destination/client_id_value'
               , destination_card_number           varchar2(24)  path 'destination/card_number'
               , destination_card_id               number(12)    path 'destination/card_id'
               , destination_card_seq_number       number        path 'destination/card_seq_number'
               , destination_card_expir_date       varchar2(20)  path 'destination/card_expir_date'
               , destination_inst_id               number        path 'destination/inst_id'
               , destination_network_id            number        path 'destination/network_id'
               , destination_auth_code             varchar2(6)   path 'destination/auth_code'
               , destination_account_amount        number        path 'destination/account_amount'
               , destination_account_currency      varchar2(3)   path 'destination/account_currency'
               , destination_account_number        varchar2(32)  path 'destination/account_number'

               , aggregator_client_id_type         varchar2(8)   path 'aggregator/client_id_type'
               , aggregator_client_id_value        varchar2(200) path 'aggregator/client_id_value'
               , aggregator_card_number            varchar2(24)  path 'aggregator/card_number'
               , aggregator_card_seq_number        number        path 'aggregator/card_seq_number'
               , aggregator_card_expir_date        varchar2(20)  path 'aggregator/card_expir_date'
               , aggregator_inst_id                number        path 'aggregator/inst_id'
               , aggregator_network_id             number        path 'aggregator/network_id'
               , aggregator_auth_code              varchar2(6)   path 'aggregator/auth_code'
               , aggregator_account_amount         number        path 'aggregator/account_amount'
               , aggregator_account_currency       varchar2(3)   path 'aggregator/account_currency'
               , aggregator_account_number         varchar2(32)  path 'aggregator/account_number'

               , srvp_client_id_type               varchar2(8)   path 'service_provider/client_id_type'
               , srvp_client_id_value              varchar2(200) path 'service_provider/client_id_value'
               , srvp_card_number                  varchar2(24)  path 'service_provider/card_number'
               , srvp_card_seq_number              number        path 'service_provider/card_seq_number'
               , srvp_card_expir_date              varchar2(20)  path 'service_provider/card_expir_date'
               , srvp_inst_id                      number        path 'service_provider/inst_id'
               , srvp_network_id                   number        path 'service_provider/network_id'
               , srvp_auth_code                    varchar2(6)   path 'service_provider/auth_code'
               , srvp_account_amount               number        path 'service_provider/account_amount'
               , srvp_account_currency             varchar2(3)   path 'service_provider/account_currency'
               , srvp_account_number               varchar2(32)  path 'service_provider/account_number'

               , participant                       xmltype       path 'participant'

               , payment_order_exists              number        path 'fn:exists(payment_order)'
               , issuer_exists                     number        path 'fn:exists(issuer)'
               , acquirer_exists                   number        path 'fn:exists(acquirer)'
               , destination_exists                number        path 'fn:exists(destination)'
               , aggregator_exists                 number        path 'fn:exists(aggregator)'
               , service_provider_exists           number        path 'fn:exists(service_provider)'
               , note                              xmltype       path 'note'
               , auth_data                         xmltype       path 'auth_data'
               , ipm_data                          xmltype       path 'ipm_data'
               , baseii_data                       xmltype       path 'baseII_data'
               , match_status                      varchar2(8)   path 'match_status'
               , additional_amount                 xmltype       path 'additional_amount'
               , processing_stage                  xmltype       path 'processing_stage'
               , flexible_data                     xmltype       path 'flexible_data'
         ) x
    where s.session_id    = i_session_id
      and (
              i_splitted_files   = com_api_const_pkg.FALSE
              or s.thread_number = i_thread_number
      )
      and s.file_attr_id  = a.id
      and f.id            = a.file_id
      and f.file_type     = opr_api_const_pkg.FILE_TYPE_LOADING
) opr
where (
          i_splitted_files = com_api_const_pkg.TRUE
          or com_api_hash_pkg.get_split_hash(i_value => opr.split_hash) in (select split_hash from com_api_split_map_vw)
      )
order by opr.is_reversal
       , opr.host_date
       , decode(opr.external_orig_id, opr.external_auth_id, 0, 1)
       , opr.external_auth_id;

cursor cur_oper_count (
    i_session_id          in     com_api_type_pkg.t_long_id
  , i_thread_number       in     com_api_type_pkg.t_tiny_id
  , i_splitted_files      in     com_api_type_pkg.t_boolean
) is
select count(split_hash) oper_count
  from (select case
                   when x.oper_type = opr_api_const_pkg.OPERATION_TYPE_VIRTUAL_CARD
                        and x.issuer_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                   then
                       (
                           select opr_api_const_pkg.CLIENT_ID_TYPE_CARD || '/' || xt.tag_value
                             from xmltable(
                                      xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing'),
                                      '/auth_data/auth_tag'
                                      passing x.auth_data
                                      columns tag_id       number          path 'tag_id'
                                            , tag_value    varchar2(2000)  path 'tag_value'
                                  ) xt
                            where xt.tag_id = aup_api_const_pkg.TAG_SECOND_CARD_NUMBER
                              and rownum = 1
                       )
                   else x.issuer_client_id_type || '/' || x.issuer_client_id_value
               end  as  split_hash
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
             , xmltable(
                   xmlnamespaces('http://bpc.ru/sv/SVXP/clearing' as "svxp")
                 , '/svxp:clearing'
                   passing s.file_xml_contents
                   columns inst_id                   number        path 'svxp:inst_id'
                         , opers                     xmltype       path 'svxp:operation'
               ) z
             , xmltable(
                   xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing')
                 , '/operation'
                   passing z.opers
                   columns oper_id                   number        path 'oper_id'
                         , oper_type                 varchar2(8)   path 'oper_type'
                         , issuer_client_id_type     varchar2(8)   path 'issuer/client_id_type'
                         , issuer_client_id_value    varchar2(200) path 'issuer/client_id_value'
                         , auth_data                 xmltype       path 'auth_data'
               ) x
         where s.session_id    = i_session_id
           and (
                   i_splitted_files   = com_api_const_pkg.FALSE
                   or s.thread_number = i_thread_number
           )
           and s.file_attr_id  = a.id
           and f.id            = a.file_id
           and f.file_type     = opr_api_const_pkg.FILE_TYPE_LOADING
       ) opr
 where (
           i_splitted_files = com_api_const_pkg.TRUE
           or com_api_hash_pkg.get_split_hash(i_value => opr.split_hash) in (select split_hash from com_api_split_map_vw)
       );

cursor cur_update is
    select x.oper_id
         , x.status
         , x.status_reason
         , s.id
      from prc_session_file s
         , prc_file_attribute a
         , prc_file f
         , xmltable(
               xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing')
             , '/clearing/operation'
               passing s.file_xml_contents
               columns
                   oper_id             number       path 'oper_id'
                   , status            varchar2(8)  path 'status'
                   , status_reason     varchar2(8)  path 'status_reason'
           ) x
     where s.session_id = get_session_id
       and s.file_attr_id = a.id
       and f.id = a.file_id;

cursor cur_update_count is
    select nvl(sum(opr_count), 0) opr_count
      from prc_session_file s
         , prc_file_attribute a
         , prc_file f
         , xmltable(
               xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing')
             , '/clearing/operation'
               passing s.file_xml_contents
               columns
                   opr_count           number       path 'fn:count(oper_id)'
           ) x
     where s.session_id = get_session_id
       and s.file_attr_id = a.id
       and f.id = a.file_id;

cursor cur_sttt is
   select x.oper_id
        , x.status
        , x.sttt_amount
        , x.sttt_currency
        , s.id
     from prc_session_file s
        , prc_file_attribute a
        , prc_file f
        , xmltable(
              xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing')
            , '/clearing/operation'
              passing s.file_xml_contents
              columns
                  oper_id              number       path 'oper_id'
                  , status             varchar2(8)  path 'status'
                  , sttt_amount        number       path 'sttt_amount'
                  , sttt_currency      varchar2(3)  path 'sttt_currency'
          ) x
    where s.session_id = get_session_id
      and s.file_attr_id = a.id
      and f.id = a.file_id;

cursor cur_sttt_count is
    select nvl(sum(opr_count), 0) opr_count
      from prc_session_file s
         , prc_file_attribute a
         , prc_file f
         , xmltable(
               xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing')
             , '/clearing/operation'
               passing s.file_xml_contents
               columns
                   opr_count           number       path 'fn:count(oper_id)'
           ) x
     where s.session_id = get_session_id
       and s.file_attr_id = a.id
       and f.id = a.file_id;

type t_update_rec is record (
    oper_id              number
    , status             varchar2(8)
    , status_reason      varchar2(8)
    , session_file_id    number
);

type t_update_tab is varray(1000) of t_update_rec;

type t_sttt_rec is record (
    oper_id              number
    , status             varchar2(8)
    , sttt_amount        number
    , sttt_currency      varchar2(3)
    , session_file_id    number
);

type t_sttt_tab is varray(1000) of t_sttt_rec;

-- Maximum number of preceding days from a reversal operation for searching an original operation
REVERSAL_SEARCH_TIME_WINDOW constant number := 30;

type t_oper_tab is varray(1000) of t_oper_clearing_rec;
l_oper_tab                  t_oper_tab;

g_participants              opr_api_type_pkg.t_oper_part_by_type_tab;
g_operations                com_api_type_pkg.t_number_tab;

-- fraud control
cursor cur_fraud_control is
   select x.oper_id
        , x.external_auth_id
        , x.is_reversal
        , x.command
     from prc_session_file s
        , prc_file_attribute a
        , prc_file f
        , xmltable(
              xmlnamespaces(default 'http://bpc.ru/sv/SVXP/fraud_control')
            , '/fraud_control/operation'
              passing s.file_xml_contents
              columns
                   oper_id                 number              path 'oper_id'
                 , external_auth_id        varchar2(200)       path 'external_auth_id'
                 , is_reversal             number(1)           path 'is_reversal'
                 , command                 varchar2(8)         path 'command'
    ) x
    where s.session_id   = get_session_id
      and s.file_attr_id = a.id
      and f.id           = a.file_id;

cursor cur_frd_control_count is
   select nvl(count(1), 0)
     from prc_session_file s
        , prc_file_attribute a
        , prc_file f
        , xmltable(
              xmlnamespaces(default 'http://bpc.ru/sv/SVXP/fraud_control')
            , '/fraud_control/operation'
              passing s.file_xml_contents
              columns
                   oper_id                 number              path 'oper_id'
                 , external_auth_id        varchar2(200)       path 'external_auth_id'
                 , is_reversal             number(1)           path 'is_reversal'
                 , command                 varchar2(8)         path 'command'
    ) x
    where s.session_id   = get_session_id
      and s.file_attr_id = a.id
      and f.id           = a.file_id;

type t_fraud_tab is varray(1000) of t_fraud_rec;
l_fraud_tab                         t_fraud_tab;

procedure add_event_to_cache(
    io_split_hash_tab    in out nocopy com_api_type_pkg.t_tiny_tab
  , io_inst_id_tab       in out nocopy com_api_type_pkg.t_inst_id_tab
  , i_new_split_hash     in            com_api_type_pkg.t_tiny_id
  , i_new_inst_id        in            com_api_type_pkg.t_inst_id
) is
begin
    for i in 1 .. io_split_hash_tab.count loop
        if io_split_hash_tab(i) = i_new_split_hash and io_inst_id_tab(i) = i_new_inst_id then
            return;
        end if;
    end loop;

    io_split_hash_tab(io_split_hash_tab.count + 1) := i_new_split_hash;
    io_inst_id_tab   (io_inst_id_tab.count    + 1) := i_new_inst_id;
end add_event_to_cache;

procedure register_events(
    io_oper              in out nocopy opr_prc_import_pkg.t_oper_clearing_rec
  , i_resp_code          in            com_api_type_pkg.t_dict_value
  , io_split_hash_tab    in out nocopy com_api_type_pkg.t_tiny_tab
  , io_inst_id_tab       in out nocopy com_api_type_pkg.t_inst_id_tab
  , io_event_params      in out nocopy com_api_type_pkg.t_param_tab
) is
    l_event_type                com_api_type_pkg.t_dict_value;
begin
    l_event_type := case
                        when i_resp_code = aup_api_const_pkg.RESP_CODE_OK
                        then opr_api_const_pkg.EVENT_LOADED_SUCCESSFULLY
                        else opr_api_const_pkg.EVENT_LOADED_WITH_ERRORS
                    end;

    for i in 1 .. io_split_hash_tab.count loop
        evt_api_event_pkg.register_event(
            i_event_type     => l_event_type
          , i_eff_date       => nvl(io_oper.host_date, get_sysdate)
          , i_entity_type    => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id      => io_oper.oper_id
          , i_inst_id        => io_inst_id_tab(i)
          , i_split_hash     => io_split_hash_tab(i)
          , i_param_tab      => io_event_params
          , i_is_used_cache  => com_api_const_pkg.TRUE
        );
    end loop;

end register_events;

procedure register_auth_tag(
    io_tags             in out nocopy xmltype
  , i_oper_id           in            com_api_type_pkg.t_long_id
  , i_import_clear_pan  in            com_api_type_pkg.t_boolean
  , o_is_incremental       out        com_api_type_pkg.t_boolean
  , io_is_error         in out        com_api_type_pkg.t_boolean
  , i_original_id       in            com_api_type_pkg.t_long_id
  , i_msg_type          in            com_api_type_pkg.t_dict_value
) is
    l_tag_idx                         com_api_type_pkg.t_count        := 0;
    l_tags_tab                        aup_api_type_pkg.t_aup_tag_tab;
    l_tag_eci_value                   com_api_type_pkg.t_text;
    l_is_eci_tag                      com_api_type_pkg.t_boolean      := com_api_const_pkg.FALSE;
begin
    trc_log_pkg.debug(
        i_text          => 'opr_prc_import_pkg.register_auth_tag'
    );

    if i_original_id  is not null
       and i_msg_type  = aut_api_const_pkg.MESSAGE_TYPE_COMPLETION
    then
        l_tag_eci_value := aup_api_tag_pkg.get_tag_value(
                               i_auth_id => i_original_id
                             , i_tag_id  => aup_api_const_pkg.TAG_ELECTR_COMMERCE_INDICATOR
                           );
    end if;

    for tag in (
        select tag_id
             , tag_value
             , tag_name
             , seq_number
          from xmltable(
                   xmlnamespaces('http://bpc.ru/sv/SVXP/clearing' as "svxp")
                 , '/svxp:auth_tag'
                   passing io_tags
                   columns tag_id       number          path 'svxp:tag_id'
                         , tag_value    varchar2(2000)  path 'svxp:tag_value'
                         , tag_name     varchar2(4000)  path 'svxp:tag_name'
                         , seq_number   number          path 'svxp:seq_number'
               )
    ) loop
        if tag.tag_id is null then
            tag.tag_id := aup_api_tag_pkg.find_tag_by_reference(
                              i_reference => tag.tag_name
                          );
        end if;

        if tag.tag_id is null then
            trc_log_pkg.error(
                i_text        => 'AUP_TAG_NOT_FOUND'
              , i_env_param1  => tag.tag_name
            );

            io_is_error := com_api_const_pkg.TRUE;
        else
            -- tokenization card number
            if tag.tag_id         = aup_api_const_pkg.TAG_SECOND_CARD_NUMBER then
                tag.tag_value    := case i_import_clear_pan
                                        when com_api_const_pkg.FALSE
                                        then tag.tag_value
                                        else iss_api_token_pkg.encode_card_number(i_card_number => tag.tag_value)
                                    end;

            elsif tag.tag_id      = aup_api_const_pkg.TAG_IS_INCREMENTAL then
                o_is_incremental := tag.tag_value;

            elsif tag.tag_id      = aup_api_const_pkg.TAG_ELECTR_COMMERCE_INDICATOR then
                tag.tag_value    := nvl(l_tag_eci_value, tag.tag_value);
                l_is_eci_tag     := com_api_const_pkg.TRUE;

            end if;

            l_tag_idx                        := l_tags_tab.count + 1;
            l_tags_tab(l_tag_idx).tag_id     := tag.tag_id;
            l_tags_tab(l_tag_idx).tag_value  := tag.tag_value;
            l_tags_tab(l_tag_idx).seq_number := nvl(tag.seq_number, 1);
        end if;
    end loop;

    if l_is_eci_tag = com_api_const_pkg.FALSE then
        l_tag_idx                            := l_tags_tab.count + 1;
        l_tags_tab(l_tag_idx).tag_id         := aup_api_const_pkg.TAG_ELECTR_COMMERCE_INDICATOR;
        l_tags_tab(l_tag_idx).tag_value      := l_tag_eci_value;
        l_tags_tab(l_tag_idx).seq_number     := 1;
    end if;

    aup_api_tag_pkg.insert_tag(
        i_auth_id => i_oper_id
      , i_tags    => l_tags_tab
    );

exception
    when others then
        trc_log_pkg.error(
            i_text        => 'AUTH_DATA_NOT_FOUND'
          , i_env_param1  => i_oper_id
          , i_env_param2  => sqlerrm
        );

        io_is_error := com_api_const_pkg.TRUE;

end register_auth_tag;

procedure register_auth_tag(
    io_auth_tag_tab     in out nocopy aut_api_type_pkg.t_auth_tag_tab
  , i_oper_id           in            com_api_type_pkg.t_long_id
  , i_import_clear_pan  in            com_api_type_pkg.t_boolean
  , o_is_incremental       out        com_api_type_pkg.t_boolean
  , io_is_error         in out        com_api_type_pkg.t_boolean
  , i_original_id       in            com_api_type_pkg.t_long_id
  , i_msg_type          in            com_api_type_pkg.t_dict_value
) is
    l_tag_idx                         com_api_type_pkg.t_count        := 0;
    l_tags_tab                        aup_api_type_pkg.t_aup_tag_tab;
    l_tag_eci_value                   com_api_type_pkg.t_text;
    l_is_eci_tag                      com_api_type_pkg.t_boolean      := com_api_const_pkg.FALSE;
begin
    trc_log_pkg.debug(
        i_text          => 'opr_prc_import_pkg.register_auth_tag'
    );

    if i_original_id  is not null
       and i_msg_type  = aut_api_const_pkg.MESSAGE_TYPE_COMPLETION
    then
        l_tag_eci_value := aup_api_tag_pkg.get_tag_value(
                               i_auth_id => i_original_id
                             , i_tag_id  => aup_api_const_pkg.TAG_ELECTR_COMMERCE_INDICATOR
                           );
    end if;

    for i in 1 .. io_auth_tag_tab.count loop
        if io_auth_tag_tab(i).tag_id is null then
            io_auth_tag_tab(i).tag_id := aup_api_tag_pkg.find_tag_by_reference(
                                             i_reference => io_auth_tag_tab(i).tag_name
                                         );
        end if;

        if io_auth_tag_tab(i).tag_id is null then
            trc_log_pkg.error(
                i_text        => 'AUP_TAG_NOT_FOUND'
              , i_env_param1  => io_auth_tag_tab(i).tag_name
            );

            io_is_error := com_api_const_pkg.TRUE;
        else
            -- tokenization card number
            if io_auth_tag_tab(i).tag_id      = aup_api_const_pkg.TAG_SECOND_CARD_NUMBER then
                io_auth_tag_tab(i).tag_value := case i_import_clear_pan
                                                    when com_api_const_pkg.FALSE
                                                    then io_auth_tag_tab(i).tag_value
                                                    else iss_api_token_pkg.encode_card_number(i_card_number => io_auth_tag_tab(i).tag_value)
                                                end;

            elsif io_auth_tag_tab(i).tag_id   = aup_api_const_pkg.TAG_IS_INCREMENTAL then
                o_is_incremental             := io_auth_tag_tab(i).tag_value;

            elsif io_auth_tag_tab(i).tag_id   = aup_api_const_pkg.TAG_ELECTR_COMMERCE_INDICATOR then
                io_auth_tag_tab(i).tag_value := nvl(l_tag_eci_value, io_auth_tag_tab(i).tag_value);
                l_is_eci_tag                 := com_api_const_pkg.TRUE;

            end if;

            l_tag_idx                        := l_tags_tab.count + 1;
            l_tags_tab(l_tag_idx).tag_id     := io_auth_tag_tab(i).tag_id;
            l_tags_tab(l_tag_idx).tag_value  := io_auth_tag_tab(i).tag_value;
            l_tags_tab(l_tag_idx).seq_number := nvl(io_auth_tag_tab(i).seq_number, 1);
        end if;
    end loop;

    if l_is_eci_tag = com_api_const_pkg.FALSE then
        l_tag_idx                            := l_tags_tab.count + 1;
        l_tags_tab(l_tag_idx).tag_id         := aup_api_const_pkg.TAG_ELECTR_COMMERCE_INDICATOR;
        l_tags_tab(l_tag_idx).tag_value      := l_tag_eci_value;
        l_tags_tab(l_tag_idx).seq_number     := 1;
    end if;

    aup_api_tag_pkg.insert_tag(
        i_auth_id => i_oper_id
      , i_tags    => l_tags_tab
    );

exception
    when others then
        trc_log_pkg.error(
            i_text        => 'AUTH_DATA_NOT_FOUND'
          , i_env_param1  => i_oper_id
          , i_env_param2  => sqlerrm
        );

        io_is_error := com_api_const_pkg.TRUE;

end register_auth_tag;

procedure register_auth_data(
    io_auth_data_rec      in out nocopy   aut_api_type_pkg.t_auth_rec
  , io_auth_tag_tab       in out nocopy   aut_api_type_pkg.t_auth_tag_tab
  , io_auth_data          in out nocopy   xmltype
  , i_oper_id             in              com_api_type_pkg.t_long_id
  , i_import_clear_pan    in              com_api_type_pkg.t_boolean
  , o_auth_resp_code         out          com_api_type_pkg.t_dict_value
  , o_auth_acq_resp_code     out          com_api_type_pkg.t_dict_value
  , io_is_error           in out          com_api_type_pkg.t_boolean
  , i_use_auth_data_rec   in              com_api_type_pkg.t_boolean
  , i_original_id         in              com_api_type_pkg.t_long_id
  , i_msg_type            in              com_api_type_pkg.t_dict_value
) is
    l_auth_data                           aut_api_type_pkg.t_auth_rec;
    l_auth_tags                           xmltype;
    l_is_incremental                      com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text          => 'opr_prc_import_pkg.register_auth_data; i_oper_id [#1] start'
      , i_env_param1    => i_oper_id
    );

    if i_use_auth_data_rec = com_api_const_pkg.TRUE then
        l_auth_data := io_auth_data_rec;

    else
        select resp_code
             , proc_type
             , proc_mode
             , is_advice
             , is_repeat
             , bin_amount
             , bin_currency
             , bin_cnvt_rate
             , network_amount
             , network_currency
             , to_date(network_cnvt_date, com_api_const_pkg.XML_DATETIME_FORMAT) network_cnvt_date
             , network_cnvt_rate
             , account_cnvt_rate
             , addr_verif_result
             , acq_resp_code
             , acq_device_proc_result
             , cat_level
             , card_data_input_cap
             , crdh_auth_cap
             , card_capture_cap
             , terminal_operating_env
             , crdh_presence
             , card_presence
             , card_data_input_mode
             , crdh_auth_method
             , crdh_auth_entity
             , card_data_output_cap
             , terminal_output_cap
             , pin_capture_cap
             , pin_presence
             , cvv2_presence
             , cvc_indicator
             , pos_entry_mode
             , pos_cond_code
             , emv_data
             , atc
             , tvr
             , cvr
             , addl_data
             , service_code
             , to_date(device_date, com_api_const_pkg.XML_DATETIME_FORMAT) device_date
             , cvv2_result
             , certificate_method
             , certificate_type
             , merchant_certif
             , cardholder_certif
             , ucaf_indicator
             , is_early_emv
             , is_completed
             , amounts
             , system_trace_audit_number
             , transaction_id
             , external_auth_id
             , external_orig_id
             , agent_unique_id
             , native_resp_code
             , trace_number
             , auth_purpose_id
             , auth_tag
          into l_auth_data.resp_code
             , l_auth_data.proc_type
             , l_auth_data.proc_mode
             , l_auth_data.is_advice
             , l_auth_data.is_repeat
             , l_auth_data.bin_amount
             , l_auth_data.bin_currency
             , l_auth_data.bin_cnvt_rate
             , l_auth_data.network_amount
             , l_auth_data.network_currency
             , l_auth_data.network_cnvt_date
             , l_auth_data.network_cnvt_rate
             , l_auth_data.account_cnvt_rate
             , l_auth_data.addr_verif_result
             , l_auth_data.acq_resp_code
             , l_auth_data.acq_device_proc_result
             , l_auth_data.cat_level
             , l_auth_data.card_data_input_cap
             , l_auth_data.crdh_auth_cap
             , l_auth_data.card_capture_cap
             , l_auth_data.terminal_operating_env
             , l_auth_data.crdh_presence
             , l_auth_data.card_presence
             , l_auth_data.card_data_input_mode
             , l_auth_data.crdh_auth_method
             , l_auth_data.crdh_auth_entity
             , l_auth_data.card_data_output_cap
             , l_auth_data.terminal_output_cap
             , l_auth_data.pin_capture_cap
             , l_auth_data.pin_presence
             , l_auth_data.cvv2_presence
             , l_auth_data.cvc_indicator
             , l_auth_data.pos_entry_mode
             , l_auth_data.pos_cond_code
             , l_auth_data.emv_data
             , l_auth_data.atc
             , l_auth_data.tvr
             , l_auth_data.cvr
             , l_auth_data.addl_data
             , l_auth_data.service_code
             , l_auth_data.device_date
             , l_auth_data.cvv2_result
             , l_auth_data.certificate_method
             , l_auth_data.certificate_type
             , l_auth_data.merchant_certif
             , l_auth_data.cardholder_certif
             , l_auth_data.ucaf_indicator
             , l_auth_data.is_early_emv
             , l_auth_data.is_completed
             , l_auth_data.amounts
             , l_auth_data.system_trace_audit_number
             , l_auth_data.transaction_id
             , l_auth_data.external_auth_id
             , l_auth_data.external_orig_id
             , l_auth_data.agent_unique_id
             , l_auth_data.native_resp_code
             , l_auth_data.trace_number
             , l_auth_data.auth_purpose_id
             , l_auth_tags
          from xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing'),
                   '/auth_data'
                   passing io_auth_data
                   columns resp_code               varchar2(8)         path 'resp_code'
                         , proc_type               varchar2(8)         path 'proc_type'
                         , proc_mode               varchar2(8)         path 'proc_mode'
                         , is_advice               number(1)           path 'is_advice'
                         , is_repeat               number(1)           path 'is_repeat'
                         , bin_amount              number              path 'bin_amount'
                         , bin_currency            varchar(3)          path 'bin_currency'
                         , bin_cnvt_rate           number              path 'bin_cnvt_rate'
                         , network_amount          number              path 'network_amount'
                         , network_currency        varchar(3)          path 'network_currency'
                         , network_cnvt_date       varchar2(20)        path 'network_cnvt_date'
                         , network_cnvt_rate       number              path 'network_cnvt_rate'
                         , account_cnvt_rate       number              path 'account_cnvt_rate'
                         , addr_verif_result       varchar2(8)         path 'addr_verif_result'
                         , acq_resp_code           varchar2(8)         path 'acq_resp_code'
                         , acq_device_proc_result  varchar2(8)         path 'acq_device_proc_result'
                         , cat_level               varchar2(8)         path 'cat_level'
                         , card_data_input_cap     varchar2(8)         path 'card_data_input_cap'
                         , crdh_auth_cap           varchar2(8)         path 'crdh_auth_cap'
                         , card_capture_cap        varchar2(8)         path 'card_capture_cap'
                         , terminal_operating_env  varchar2(8)         path 'terminal_operating_env'
                         , crdh_presence           varchar2(8)         path 'crdh_presence'
                         , card_presence           varchar2(8)         path 'card_presence'
                         , card_data_input_mode    varchar2(8)         path 'card_data_input_mode'
                         , crdh_auth_method        varchar2(8)         path 'crdh_auth_method'
                         , crdh_auth_entity        varchar2(8)         path 'crdh_auth_entity'
                         , card_data_output_cap    varchar2(8)         path 'card_data_output_cap'
                         , terminal_output_cap     varchar2(8)         path 'terminal_output_cap'
                         , pin_capture_cap         varchar2(8)         path 'pin_capture_cap'
                         , pin_presence            varchar2(8)         path 'pin_presence'
                         , cvv2_presence           varchar2(8)         path 'cvv2_presence'
                         , cvc_indicator           varchar2(8)         path 'cvc_indicator'
                         , pos_entry_mode          varchar(3)          path 'pos_entry_mode'
                         , pos_cond_code           varchar2(2)         path 'pos_cond_code'
                         , emv_data                varchar2(2000)      path 'emv_data'
                         , atc                     varchar2(4)         path 'atc'
                         , tvr                     varchar2(200)       path 'tvr'
                         , cvr                     varchar2(200)       path 'cvr'
                         , addl_data               varchar2(2000)      path 'addl_data'
                         , service_code            varchar(3)          path 'service_code'
                         , device_date             varchar2(20)        path 'device_date'
                         , cvv2_result             varchar2(8)         path 'cvv2_result'
                         , certificate_method      varchar2(8)         path 'certificate_method'
                         , certificate_type        varchar2(8)         path 'certificate_type'
                         , merchant_certif         varchar2(100)       path 'merchant_certif'
                         , cardholder_certif       varchar2(100)       path 'cardholder_certif'
                         , ucaf_indicator          varchar2(8)         path 'ucaf_indicator'
                         , is_early_emv            number(1)           path 'is_early_emv'
                         , is_completed            varchar2(8)         path 'is_completed'
                         , amounts                 varchar2(4000)      path 'amounts'
                         , system_trace_audit_number varchar2(6)       path 'system_trace_audit_number'
                         , transaction_id          varchar2(15)        path 'auth_transaction_id'
                         , external_auth_id        varchar2(30)        path 'external_auth_id'
                         , external_orig_id        varchar2(30)        path 'external_orig_id'
                         , agent_unique_id         varchar2(5)         path 'agent_unique_id'
                         , native_resp_code        varchar2(2)         path 'native_resp_code'
                         , trace_number            varchar2(30)        path 'trace_number'
                         , auth_purpose_id         number(16)          path 'auth_purpose_id'
                         , auth_tag                xmltype             path 'auth_tag'
               );
    end if;

    l_auth_data.id := i_oper_id;

    if i_use_auth_data_rec = com_api_const_pkg.TRUE then
        if io_auth_tag_tab.count > 0 then
            register_auth_tag(
                io_auth_tag_tab    => io_auth_tag_tab
              , i_oper_id          => i_oper_id
              , i_import_clear_pan => i_import_clear_pan
              , o_is_incremental   => l_is_incremental
              , io_is_error        => io_is_error
              , i_original_id      => i_original_id
              , i_msg_type         => i_msg_type
            );

            if l_is_incremental = com_api_const_pkg.TRUE then
                g_operations(g_operations.count + 1) := i_oper_id;
            end if;
        end if;
    else
        if l_auth_tags is not null then
            register_auth_tag(
                io_tags            => l_auth_tags
              , i_oper_id          => i_oper_id
              , i_import_clear_pan => i_import_clear_pan
              , o_is_incremental   => l_is_incremental
              , io_is_error        => io_is_error
              , i_original_id      => i_original_id
              , i_msg_type         => i_msg_type
            );

            if l_is_incremental = com_api_const_pkg.TRUE then
                g_operations(g_operations.count + 1) := i_oper_id;
            end if;
        end if;
    end if;

    if i_original_id  is not null
       and i_msg_type  = aut_api_const_pkg.MESSAGE_TYPE_COMPLETION
    then
        select c.emv_data
             , c.addl_data
             , c.network_cnvt_date
             , c.card_data_input_mode
             , c.crdh_auth_method
             , c.cvv2_result
             , c.pos_entry_mode
          into l_auth_data.emv_data
             , l_auth_data.addl_data
             , l_auth_data.network_cnvt_date
             , l_auth_data.card_data_input_mode
             , l_auth_data.crdh_auth_method
             , l_auth_data.cvv2_result
             , l_auth_data.pos_entry_mode
          from aut_auth c
         where c.id = i_original_id;
    end if;

    insert into aut_auth (
        id
      , resp_code
      , proc_type
      , proc_mode
      , is_advice
      , is_repeat
      , bin_amount
      , bin_currency
      , bin_cnvt_rate
      , network_amount
      , network_currency
      , network_cnvt_date
      , network_cnvt_rate
      , account_cnvt_rate
      , parent_id
      , addr_verif_result
      , iss_network_device_id
      , acq_device_id
      , acq_resp_code
      , acq_device_proc_result
      , cat_level
      , card_data_input_cap
      , crdh_auth_cap
      , card_capture_cap
      , terminal_operating_env
      , crdh_presence
      , card_presence
      , card_data_input_mode
      , crdh_auth_method
      , crdh_auth_entity
      , card_data_output_cap
      , terminal_output_cap
      , pin_capture_cap
      , pin_presence
      , cvv2_presence
      , cvc_indicator
      , pos_entry_mode
      , pos_cond_code
      , emv_data
      , atc
      , tvr
      , cvr
      , addl_data
      , service_code
      , device_date
      , cvv2_result
      , certificate_method
      , certificate_type
      , merchant_certif
      , cardholder_certif
      , ucaf_indicator
      , is_early_emv
      , is_completed
      , amounts
      , cavv_presence
      , aav_presence
      , system_trace_audit_number
      , transaction_id
      , external_auth_id
      , external_orig_id
      , agent_unique_id
      , native_resp_code
      , trace_number
      , auth_purpose_id
      , is_incremental
     ) values (
        l_auth_data.id
      , l_auth_data.resp_code
      , l_auth_data.proc_type
      , l_auth_data.proc_mode
      , l_auth_data.is_advice
      , l_auth_data.is_repeat
      , l_auth_data.bin_amount
      , l_auth_data.bin_currency
      , l_auth_data.bin_cnvt_rate
      , l_auth_data.network_amount
      , l_auth_data.network_currency
      , l_auth_data.network_cnvt_date
      , l_auth_data.network_cnvt_rate
      , l_auth_data.account_cnvt_rate
      , l_auth_data.parent_id
      , l_auth_data.addr_verif_result
      , l_auth_data.iss_network_device_id
      , l_auth_data.acq_device_id
      , l_auth_data.acq_resp_code
      , l_auth_data.acq_device_proc_result
      , l_auth_data.cat_level
      , l_auth_data.card_data_input_cap
      , l_auth_data.crdh_auth_cap
      , l_auth_data.card_capture_cap
      , l_auth_data.terminal_operating_env
      , l_auth_data.crdh_presence
      , l_auth_data.card_presence
      , l_auth_data.card_data_input_mode
      , l_auth_data.crdh_auth_method
      , l_auth_data.crdh_auth_entity
      , l_auth_data.card_data_output_cap
      , l_auth_data.terminal_output_cap
      , l_auth_data.pin_capture_cap
      , l_auth_data.pin_presence
      , l_auth_data.cvv2_presence
      , l_auth_data.cvc_indicator
      , l_auth_data.pos_entry_mode
      , l_auth_data.pos_cond_code
      , l_auth_data.emv_data
      , l_auth_data.atc
      , l_auth_data.tvr
      , l_auth_data.cvr
      , l_auth_data.addl_data
      , l_auth_data.service_code
      , l_auth_data.device_date
      , l_auth_data.cvv2_result
      , l_auth_data.certificate_method
      , l_auth_data.certificate_type
      , l_auth_data.merchant_certif
      , l_auth_data.cardholder_certif
      , l_auth_data.ucaf_indicator
      , l_auth_data.is_early_emv
      , l_auth_data.is_completed
      , l_auth_data.amounts
      , l_auth_data.cavv_presence
      , l_auth_data.aav_presence
      , l_auth_data.system_trace_audit_number
      , l_auth_data.transaction_id
      , l_auth_data.external_auth_id
      , l_auth_data.external_orig_id
      , l_auth_data.agent_unique_id
      , l_auth_data.native_resp_code
      , l_auth_data.trace_number
      , l_auth_data.auth_purpose_id
      , l_is_incremental
    );

    o_auth_resp_code      := l_auth_data.resp_code;
    o_auth_acq_resp_code  := l_auth_data.acq_resp_code;

    trc_log_pkg.debug(
        i_text          => 'opr_prc_import_pkg.register_auth_data; i_oper_id [#1] end'
      , i_env_param1    => i_oper_id
    );

exception
    when no_data_found then
        trc_log_pkg.error(
            i_text        => 'AUTH_DATA_NOT_FOUND'
          , i_env_param1  => i_oper_id
          , i_env_param2  => sqlerrm
        );

        io_is_error := com_api_const_pkg.TRUE;

    when others then
        trc_log_pkg.error(
            i_text        => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_env_param2  => i_oper_id
          , i_env_param3  => sqlerrm
        );

        io_is_error := com_api_const_pkg.TRUE;

end register_auth_data;

procedure register_ipm_data(
    io_ipm_data     in out nocopy   xmltype
  , i_oper_id       in              com_api_type_pkg.t_long_id
) is
    l_mcw_rec       mcw_api_type_pkg.t_fin_rec;
begin
    trc_log_pkg.debug(
        i_text          => 'opr_prc_import_pkg.register_ipm_data; i_oper_id [#1] start'
      , i_env_param1    => i_oper_id
    );

    select is_incoming
         , is_reversal
         , is_rejected
         , impact
         , mti
         , de024
         , de002
         , de003_1
         , de003_2
         , de003_3
         , de004
         , de005
         , de006
         , de009
         , de010
         , de012
         , de014
         , de022_1
         , de022_2
         , de022_3
         , de022_4
         , de022_5
         , de022_6
         , de022_7
         , de022_8
         , de022_9
         , de022_10
         , de022_11
         , de022_12
         , de023
         , de025
         , de026
         , de030_1
         , de030_2
         , de031
         , de032
         , de033
         , de037
         , de038
         , de040
         , de041
         , de042
         , de043_1
         , de043_2
         , de043_3
         , de043_4
         , de043_5
         , de043_6
         , de049
         , de050
         , de051
         , de054
         , utl_raw.cast_to_raw(com_api_hash_pkg.base64_decode(de055))
         , de063
         , de071
         , de072
         , de073
         , de093
         , de094
         , de095
         , de100
         , de111
         , p0002
         , p0023
         , p0025_1
         , p0025_2
         , p0043
         , p0052
         , p0137
         , p0148
         , p0146
         , p0146_net
         , p0147
         , p0149_1
         , p0149_2
         , p0158_1
         , p0158_2
         , p0158_3
         , p0158_4
         , p0158_5
         , p0158_6
         , p0158_7
         , p0158_8
         , p0158_9
         , p0158_10
         , p0159_1
         , p0159_2
         , p0159_3
         , p0159_4
         , p0159_5
         , p0159_6
         , p0159_7
         , p0159_8
         , p0159_9
         , p0165
         , p0176
         , p0208_1
         , p0208_2
         , p0209
         , p0228
         , p0230
         , p0241
         , p0243
         , p0244
         , p0260
         , p0261
         , p0262
         , p0264
         , p0265
         , p0266
         , p0267
         , p0268_1
         , p0268_2
         , p0375
         , emv_9f26
         , emv_9f02
         , emv_9f27
         , emv_9f10
         , emv_9f36
         , emv_95
         , emv_82
         , emv_9a
         , emv_9c
         , emv_9f37
         , emv_5f2a
         , emv_9f33
         , emv_9f34
         , emv_9f1a
         , emv_9f35
         , emv_9f53
         , emv_84
         , emv_9f09
         , emv_9f03
         , emv_9f1e
         , emv_9f41
         , p0042
         , p0158_11
         , p0158_12
         , p0158_13
         , p0158_14
         , p0198
         , p0200_1
         , p0200_2
         , p0210_1
         , p0210_2
     into  l_mcw_rec.is_incoming
         , l_mcw_rec.is_reversal
         , l_mcw_rec.is_rejected
         , l_mcw_rec.impact
         , l_mcw_rec.mti
         , l_mcw_rec.de024
         , l_mcw_rec.de002
         , l_mcw_rec.de003_1
         , l_mcw_rec.de003_2
         , l_mcw_rec.de003_3
         , l_mcw_rec.de004
         , l_mcw_rec.de005
         , l_mcw_rec.de006
         , l_mcw_rec.de009
         , l_mcw_rec.de010
         , l_mcw_rec.de012
         , l_mcw_rec.de014
         , l_mcw_rec.de022_1
         , l_mcw_rec.de022_2
         , l_mcw_rec.de022_3
         , l_mcw_rec.de022_4
         , l_mcw_rec.de022_5
         , l_mcw_rec.de022_6
         , l_mcw_rec.de022_7
         , l_mcw_rec.de022_8
         , l_mcw_rec.de022_9
         , l_mcw_rec.de022_10
         , l_mcw_rec.de022_11
         , l_mcw_rec.de022_12
         , l_mcw_rec.de023
         , l_mcw_rec.de025
         , l_mcw_rec.de026
         , l_mcw_rec.de030_1
         , l_mcw_rec.de030_2
         , l_mcw_rec.de031
         , l_mcw_rec.de032
         , l_mcw_rec.de033
         , l_mcw_rec.de037
         , l_mcw_rec.de038
         , l_mcw_rec.de040
         , l_mcw_rec.de041
         , l_mcw_rec.de042
         , l_mcw_rec.de043_1
         , l_mcw_rec.de043_2
         , l_mcw_rec.de043_3
         , l_mcw_rec.de043_4
         , l_mcw_rec.de043_5
         , l_mcw_rec.de043_6
         , l_mcw_rec.de049
         , l_mcw_rec.de050
         , l_mcw_rec.de051
         , l_mcw_rec.de054
         , l_mcw_rec.de055--raw
         , l_mcw_rec.de063
         , l_mcw_rec.de071
         , l_mcw_rec.de072
         , l_mcw_rec.de073
         , l_mcw_rec.de093
         , l_mcw_rec.de094
         , l_mcw_rec.de095
         , l_mcw_rec.de100
         , l_mcw_rec.de111
         , l_mcw_rec.p0002
         , l_mcw_rec.p0023
         , l_mcw_rec.p0025_1
         , l_mcw_rec.p0025_2
         , l_mcw_rec.p0043
         , l_mcw_rec.p0052
         , l_mcw_rec.p0137
         , l_mcw_rec.p0148
         , l_mcw_rec.p0146
         , l_mcw_rec.p0146_net
         , l_mcw_rec.p0147
         , l_mcw_rec.p0149_1
         , l_mcw_rec.p0149_2
         , l_mcw_rec.p0158_1
         , l_mcw_rec.p0158_2
         , l_mcw_rec.p0158_3
         , l_mcw_rec.p0158_4
         , l_mcw_rec.p0158_5
         , l_mcw_rec.p0158_6
         , l_mcw_rec.p0158_7
         , l_mcw_rec.p0158_8
         , l_mcw_rec.p0158_9
         , l_mcw_rec.p0158_10
         , l_mcw_rec.p0159_1
         , l_mcw_rec.p0159_2
         , l_mcw_rec.p0159_3
         , l_mcw_rec.p0159_4
         , l_mcw_rec.p0159_5
         , l_mcw_rec.p0159_6
         , l_mcw_rec.p0159_7
         , l_mcw_rec.p0159_8
         , l_mcw_rec.p0159_9
         , l_mcw_rec.p0165
         , l_mcw_rec.p0176
         , l_mcw_rec.p0208_1
         , l_mcw_rec.p0208_2
         , l_mcw_rec.p0209
         , l_mcw_rec.p0228
         , l_mcw_rec.p0230
         , l_mcw_rec.p0241
         , l_mcw_rec.p0243
         , l_mcw_rec.p0244
         , l_mcw_rec.p0260
         , l_mcw_rec.p0261
         , l_mcw_rec.p0262
         , l_mcw_rec.p0264
         , l_mcw_rec.p0265
         , l_mcw_rec.p0266
         , l_mcw_rec.p0267
         , l_mcw_rec.p0268_1
         , l_mcw_rec.p0268_2
         , l_mcw_rec.p0375
         , l_mcw_rec.emv_9f26
         , l_mcw_rec.emv_9f02
         , l_mcw_rec.emv_9f27
         , l_mcw_rec.emv_9f10
         , l_mcw_rec.emv_9f36
         , l_mcw_rec.emv_95
         , l_mcw_rec.emv_82
         , l_mcw_rec.emv_9a
         , l_mcw_rec.emv_9c
         , l_mcw_rec.emv_9f37
         , l_mcw_rec.emv_5f2a
         , l_mcw_rec.emv_9f33
         , l_mcw_rec.emv_9f34
         , l_mcw_rec.emv_9f1a
         , l_mcw_rec.emv_9f35
         , l_mcw_rec.emv_9f53
         , l_mcw_rec.emv_84
         , l_mcw_rec.emv_9f09
         , l_mcw_rec.emv_9f03
         , l_mcw_rec.emv_9f1e
         , l_mcw_rec.emv_9f41
         , l_mcw_rec.p0042
         , l_mcw_rec.p0158_11
         , l_mcw_rec.p0158_12
         , l_mcw_rec.p0158_13
         , l_mcw_rec.p0158_14
         , l_mcw_rec.p0198
         , l_mcw_rec.p0200_1
         , l_mcw_rec.p0200_2
         , l_mcw_rec.p0210_1
         , l_mcw_rec.p0210_2
      from xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing'),
               '/ipm_data'
               passing io_ipm_data
               columns is_incoming       number(1)       path 'is_incoming'
                     , is_reversal       number(1)       path 'is_reversal'
                     , is_rejected       number(1)       path 'is_rejected'
                     , impact            number(1)       path 'impact'
                     , mti               varchar2(4)     path 'mti'
                     , de024             varchar2(3)     path 'de024'
                     , de002             varchar2(19)    path 'de002'
                     , de003_1           varchar2(2)     path 'de003_1'
                     , de003_2           varchar2(2)     path 'de003_2'
                     , de003_3           varchar2(2)     path 'de003_3'
                     , de004             number(12)      path 'de004'
                     , de005             number(12)      path 'de005'
                     , de006             number(12)      path 'de006'
                     , de009             varchar2(8)     path 'de009'
                     , de010             varchar2(8)     path 'de010'
                     , de012             date            path 'de012'
                     , de014             date            path 'de014'
                     , de022_1           varchar2(1)     path 'de022_1'
                     , de022_2           varchar2(1)     path 'de022_2'
                     , de022_3           varchar2(1)     path 'de022_3'
                     , de022_4           varchar2(1)     path 'de022_4'
                     , de022_5           varchar2(1)     path 'de022_5'
                     , de022_6           varchar2(1)     path 'de022_6'
                     , de022_7           varchar2(1)     path 'de022_7'
                     , de022_8           varchar2(1)     path 'de022_8'
                     , de022_9           varchar2(1)     path 'de022_9'
                     , de022_10          varchar2(1)     path 'de022_10'
                     , de022_11          varchar2(1)     path 'de022_11'
                     , de022_12          varchar2(1)     path 'de022_12'
                     , de023             number(3)       path 'de023'
                     , de025             varchar2(4)     path 'de025'
                     , de026             varchar2(4)     path 'de026'
                     , de030_1           number(12)      path 'de030_1'
                     , de030_2           number(12)      path 'de030_2'
                     , de031             varchar2(23)    path 'de031'
                     , de032             varchar2(11)    path 'de032'
                     , de033             varchar2(11)    path 'de033'
                     , de037             varchar2(12)    path 'de037'
                     , de038             varchar2(6)     path 'de038'
                     , de040             varchar2(3)     path 'de040'
                     , de041             varchar2(8)     path 'de041'
                     , de042             varchar2(15)    path 'de042'
                     , de043_1           varchar2(99)    path 'de043_1'
                     , de043_2           varchar2(99)    path 'de043_2'
                     , de043_3           varchar2(99)    path 'de043_3'
                     , de043_4           varchar2(99)    path 'de043_4'
                     , de043_5           varchar2(3)     path 'de043_5'
                     , de043_6           varchar2(3)     path 'de043_6'
                     , de049             varchar2(3)     path 'de049'
                     , de050             varchar2(3)     path 'de050'
                     , de051             varchar2(3)     path 'de051'
                     , de054             varchar2(20)    path 'de054'
                     , de055             varchar2(350)   path 'de055'
                     , de063             varchar2(16)    path 'de063'
                     , de071             number(7)       path 'de071'
                     , de072             varchar2(999)   path 'de072'
                     , de073             date            path 'de073'
                     , de093             varchar2(11)    path 'de093'
                     , de094             varchar2(11)    path 'de094'
                     , de095             varchar2(10)    path 'de095'
                     , de100             varchar2(11)    path 'de100'
                     , de111             number(12)      path 'de111'
                     , p0002             varchar2(3)     path 'p0002'
                     , p0023             varchar2(3)     path 'p0023'
                     , p0025_1           varchar2(1)     path 'p0025_1'
                     , p0025_2           date            path 'p0025_2'
                     , p0043             varchar2(3)     path 'p0043'
                     , p0052             varchar2(3)     path 'p0052'
                     , p0137             varchar2(20)    path 'p0137'
                     , p0148             varchar2(60)    path 'p0148'
                     , p0146             varchar2(432)   path 'p0146'
                     , p0146_net         number(12)      path 'p0146_net'
                     , p0147             varchar2(576)   path 'p0147'
                     , p0149_1           varchar2(3)     path 'p0149_1'
                     , p0149_2           varchar2(3)     path 'p0149_2'
                     , p0158_1           varchar2(3)     path 'p0158_1'
                     , p0158_2           varchar2(1)     path 'p0158_2'
                     , p0158_3           varchar2(6)     path 'p0158_3'
                     , p0158_4           varchar2(2)     path 'p0158_4'
                     , p0158_5           date            path 'p0158_5'
                     , p0158_6           number(2)       path 'p0158_6'
                     , p0158_7           varchar2(1)     path 'p0158_7'
                     , p0158_8           varchar2(3)     path 'p0158_8'
                     , p0158_9           varchar2(1)     path 'p0158_9'
                     , p0158_10          varchar2(1)     path 'p0158_10'
                     , p0159_1           varchar2(11)    path 'p0159_1'
                     , p0159_2           varchar2(28)    path 'p0159_2'
                     , p0159_3           number(1)       path 'p0159_3'
                     , p0159_4           varchar2(10)    path 'p0159_4'
                     , p0159_5           varchar2(1)     path 'p0159_5'
                     , p0159_6           date            path 'p0159_6'
                     , p0159_7           number(2)       path 'p0159_7'
                     , p0159_8           date            path 'p0159_8'
                     , p0159_9           number(2)       path 'p0159_9'
                     , p0165             varchar2(30)    path 'p0165'
                     , p0176             varchar2(6)     path 'p0176'
                     , p0208_1           varchar2(11)    path 'p0208_1'
                     , p0208_2           varchar2(15)    path 'p0208_2'
                     , p0209             varchar2(11)    path 'p0209'
                     , p0228             number(1)       path 'p0228'
                     , p0230             number(1)       path 'p0230'
                     , p0241             varchar2(7)     path 'p0241'
                     , p0243             varchar2(38)    path 'p0243'
                     , p0244             varchar2(12)    path 'p0244'
                     , p0260             varchar2(4)     path 'p0260'
                     , p0261             number(11)      path 'p0261'
                     , p0262             number(1)       path 'p0262'
                     , p0264             number(4)       path 'p0264'
                     , p0265             varchar2(110)   path 'p0265'
                     , p0266             varchar2(127)   path 'p0266'
                     , p0267             varchar2(127)   path 'p0267'
                     , p0268_1           number(12)      path 'p0268_1'
                     , p0268_2           varchar2(3)     path 'p0268_2'
                     , p0375             varchar2(50)    path 'p0375'
                     , emv_9f26          varchar2(16)    path 'emv_9f26'
                     , emv_9f02          number(12)      path 'emv_9f02'
                     , emv_9f27          varchar2(2)     path 'emv_9f27'
                     , emv_9f10          varchar2(64)    path 'emv_9f10'
                     , emv_9f36          varchar2(4)     path 'emv_9f36'
                     , emv_95            varchar2(10)    path 'emv_95'
                     , emv_82            varchar2(4)     path 'emv_82'
                     , emv_9a            date            path 'emv_9a'
                     , emv_9c            number(2)       path 'emv_9c'
                     , emv_9f37          varchar2(8)     path 'emv_9f37'
                     , emv_5f2a          number(3)       path 'emv_5f2a'
                     , emv_9f33          varchar2(6)     path 'emv_9f33'
                     , emv_9f34          varchar2(6)     path 'emv_9f34'
                     , emv_9f1a          number(3)       path 'emv_9f1a'
                     , emv_9f35          number(2)       path 'emv_9f35'
                     , emv_9f53          varchar2(2)     path 'emv_9f53'
                     , emv_84            varchar2(32)    path 'emv_84'
                     , emv_9f09          varchar2(4)     path 'emv_9f09'
                     , emv_9f03          number(4)       path 'emv_9f03'
                     , emv_9f1e          varchar2(16)    path 'emv_9f1e'
                     , emv_9f41          number(8)       path 'emv_9f41'
                     , p0042             varchar2(1)     path 'p0042'
                     , p0158_11          varchar2(1)     path 'p0158_11'
                     , p0158_12          varchar2(1)     path 'p0158_12'
                     , p0158_13          varchar2(1)     path 'p0158_13'
                     , p0158_14          varchar2(1)     path 'p0158_14'
                     , p0198             varchar2(2)     path 'p0198'
                     , p0200_1           date            path 'p0200_1'
                     , p0200_2           number(22)      path 'p0200_2'
                     , p0210_1           varchar2(2)     path 'p0210_1'
                     , p0210_2           varchar2(2)     path 'p0210_2'
           );

    l_mcw_rec.id := i_oper_id;

    mcw_api_fin_pkg.put_message(
        i_fin_rec           => l_mcw_rec
    );

    trc_log_pkg.debug(
        i_text          => 'opr_prc_import_pkg.register_ipm_data; i_oper_id [#1] end'
      , i_env_param1    => i_oper_id
    );

exception
    when others then
        trc_log_pkg.error(
            i_text          => 'IPM_DATA_NOT_FOUND: ' || sqlerrm
        );

        com_api_error_pkg.raise_error(
            i_error         => 'IPM_DATA_NOT_FOUND'
          , i_env_param1    => i_oper_id
        );
end;

procedure register_baseII_data(
    io_baseII_data  in out nocopy   xmltype
  , i_oper_id       in              com_api_type_pkg.t_long_id
) is
    l_baseII_rec        vis_api_type_pkg.t_visa_fin_mes_rec;
begin
    trc_log_pkg.debug(
        i_text          => 'opr_prc_import_pkg.register_baseII_data; i_oper_id [#1] start'
      , i_env_param1    => i_oper_id
    );

    select is_reversal
         , is_incoming
         , is_returned
         , is_invalid
         , rrn
         , trans_code
         , trans_code_qualifier
         , card_mask
         , oper_amount
         , oper_currency
         , oper_date
         , sttl_amount
         , sttl_currency
         , network_amount
         , network_currency
         , floor_limit_ind
         , exept_file_ind
         , pcas_ind
         , arn
         , acquirer_bin
         , acq_business_id
         , merchant_name
         , merchant_city
         , merchant_country
         , merchant_postal_code
         , merchant_region
         , merchant_street
         , mcc
         , req_pay_service
         , usage_code
         , reason_code
         , settlement_flag
         , auth_char_ind
         , auth_code
         , pos_terminal_cap
         , inter_fee_ind
         , crdh_id_method
         , collect_only_flag
         , pos_entry_mode
         , central_proc_date
         , reimburst_attr
         , iss_workst_bin
         , acq_workst_bin
         , chargeback_ref_num
         , docum_ind
         , member_msg_text
         , spec_cond_ind
         , fee_program_ind
         , issuer_charge
         , merchant_number
         , terminal_number
         , national_reimb_fee
         , electr_comm_ind
         , spec_chargeback_ind
         , interface_trace_num
         , unatt_accept_term_ind
         , prepaid_card_ind
         , service_development
         , avs_resp_code
         , auth_source_code
         , purch_id_format
         , account_selection
         , installment_pay_count
         , purch_id
         , cashback
         , chip_cond_code
         , pos_environment
         , transaction_type
         , card_seq_number
         , terminal_profile
         , unpredict_number
         , appl_trans_counter
         , appl_interch_profile
         , cryptogram
         , term_verif_result
         , cryptogram_amount
         , card_verif_result
         , issuer_appl_data
         , issuer_script_result
         , card_expir_date
         , cryptogram_version
         , cvv2_result_code
         , auth_resp_code
         , cryptogram_info_data
         , transaction_id
         , merchant_verif_value
         , proc_bin
         , chargeback_reason_code
         , destination_channel
         , source_channel
         , acq_inst_bin
         , spend_qualified_ind
         , service_code
     into  l_baseII_rec.is_reversal
         , l_baseII_rec.is_incoming
         , l_baseII_rec.is_returned
         , l_baseII_rec.is_invalid
         , l_baseII_rec.rrn
         , l_baseII_rec.trans_code
         , l_baseII_rec.trans_code_qualifier
         , l_baseII_rec.card_mask
         , l_baseII_rec.oper_amount
         , l_baseII_rec.oper_currency
         , l_baseII_rec.oper_date
         , l_baseII_rec.sttl_amount
         , l_baseII_rec.sttl_currency
         , l_baseII_rec.network_amount
         , l_baseII_rec.network_currency
         , l_baseII_rec.floor_limit_ind
         , l_baseII_rec.exept_file_ind
         , l_baseII_rec.pcas_ind
         , l_baseII_rec.arn
         , l_baseII_rec.acquirer_bin
         , l_baseII_rec.acq_business_id
         , l_baseII_rec.merchant_name
         , l_baseII_rec.merchant_city
         , l_baseII_rec.merchant_country
         , l_baseII_rec.merchant_postal_code
         , l_baseII_rec.merchant_region
         , l_baseII_rec.merchant_street
         , l_baseII_rec.mcc
         , l_baseII_rec.req_pay_service
         , l_baseII_rec.usage_code
         , l_baseII_rec.reason_code
         , l_baseII_rec.settlement_flag
         , l_baseII_rec.auth_char_ind
         , l_baseII_rec.auth_code
         , l_baseII_rec.pos_terminal_cap
         , l_baseII_rec.inter_fee_ind
         , l_baseII_rec.crdh_id_method
         , l_baseII_rec.collect_only_flag
         , l_baseII_rec.pos_entry_mode
         , l_baseII_rec.central_proc_date
         , l_baseII_rec.reimburst_attr
         , l_baseII_rec.iss_workst_bin
         , l_baseII_rec.acq_workst_bin
         , l_baseII_rec.chargeback_ref_num
         , l_baseII_rec.docum_ind
         , l_baseII_rec.member_msg_text
         , l_baseII_rec.spec_cond_ind
         , l_baseII_rec.fee_program_ind
         , l_baseII_rec.issuer_charge
         , l_baseII_rec.merchant_number
         , l_baseII_rec.terminal_number
         , l_baseII_rec.national_reimb_fee
         , l_baseII_rec.electr_comm_ind
         , l_baseII_rec.spec_chargeback_ind
         , l_baseII_rec.interface_trace_num
         , l_baseII_rec.unatt_accept_term_ind
         , l_baseII_rec.prepaid_card_ind
         , l_baseII_rec.service_development
         , l_baseII_rec.avs_resp_code
         , l_baseII_rec.auth_source_code
         , l_baseII_rec.purch_id_format
         , l_baseII_rec.account_selection
         , l_baseII_rec.installment_pay_count
         , l_baseII_rec.purch_id
         , l_baseII_rec.cashback
         , l_baseII_rec.chip_cond_code
         , l_baseII_rec.pos_environment
         , l_baseII_rec.transaction_type
         , l_baseII_rec.card_seq_number
         , l_baseII_rec.terminal_profile
         , l_baseII_rec.unpredict_number
         , l_baseII_rec.appl_trans_counter
         , l_baseII_rec.appl_interch_profile
         , l_baseII_rec.cryptogram
         , l_baseII_rec.term_verif_result
         , l_baseII_rec.cryptogram_amount
         , l_baseII_rec.card_verif_result
         , l_baseII_rec.issuer_appl_data
         , l_baseII_rec.issuer_script_result
         , l_baseII_rec.card_expir_date
         , l_baseII_rec.cryptogram_version
         , l_baseII_rec.cvv2_result_code
         , l_baseII_rec.auth_resp_code
         , l_baseII_rec.cryptogram_info_data
         , l_baseII_rec.transaction_id
         , l_baseII_rec.merchant_verif_value
         , l_baseII_rec.proc_bin
         , l_baseII_rec.chargeback_reason_code
         , l_baseII_rec.destination_channel
         , l_baseII_rec.source_channel
         , l_baseII_rec.acq_inst_bin
         , l_baseII_rec.spend_qualified_ind
         , l_baseII_rec.service_code
      from xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing'),
               '/baseII_data'
               passing io_baseII_data
               columns is_reversal               number(1)       path 'is_reversal'
                     , is_incoming               number(1)       path 'is_incoming'
                     , is_returned               number(1)       path 'is_returned'
                     , is_invalid                number(1)       path 'is_invalid'
                     , rrn                       varchar2(12)    path 'rrn'
                     , trans_code                varchar2(2)     path 'trans_code'
                     , trans_code_qualifier      varchar2(1)     path 'trans_code_qualifier'
                     , card_mask                 varchar2(24)    path 'card_mask'
                     , oper_amount               number(22)      path 'oper_amount'
                     , oper_currency             varchar2(3)     path 'oper_currency'
                     , oper_date                 date            path 'oper_date'
                     , sttl_amount               number(22)      path 'sttl_amount'
                     , sttl_currency             varchar2(3)     path 'sttl_currency'
                     , network_amount            number(22)      path 'network_amount'
                     , network_currency          varchar2(3)     path 'network_currency'
                     , floor_limit_ind           varchar2(1)     path 'floor_limit_ind'
                     , exept_file_ind            varchar2(1)     path 'exept_file_ind'
                     , pcas_ind                  varchar2(1)     path 'pcas_ind'
                     , arn                       varchar2(23)    path 'arn'
                     , acquirer_bin              varchar2(12)    path 'acquirer_bin'
                     , acq_business_id           varchar2(8)     path 'acq_business_id'
                     , merchant_name             varchar2(25)    path 'merchant_name'
                     , merchant_city             varchar2(13)    path 'merchant_city'
                     , merchant_country          varchar2(3)     path 'merchant_country'
                     , merchant_postal_code      varchar2(10)    path 'merchant_postal_code'
                     , merchant_region           varchar2(3)     path 'merchant_region'
                     , merchant_street           varchar2(200)   path 'merchant_street'
                     , mcc                       varchar2(4)     path 'mcc'
                     , req_pay_service           varchar2(8)     path 'req_pay_service'
                     , usage_code                varchar2(1)     path 'usage_code'
                     , reason_code               varchar2(2)     path 'reason_code'
                     , settlement_flag           varchar2(1)     path 'settlement_flag'
                     , auth_char_ind             varchar2(8)     path 'auth_char_ind'
                     , auth_code                 varchar2(6)     path 'auth_code'
                     , pos_terminal_cap          varchar2(8)     path 'pos_terminal_cap'
                     , inter_fee_ind             varchar2(1)     path 'inter_fee_ind'
                     , crdh_id_method            varchar2(1)     path 'crdh_id_method'
                     , collect_only_flag         varchar2(1)     path 'collect_only_flag'
                     , pos_entry_mode            varchar2(2)     path 'pos_entry_mode'
                     , central_proc_date         varchar2(4)     path 'central_proc_date'
                     , reimburst_attr            varchar2(1)     path 'reimburst_attr'
                     , iss_workst_bin            varchar2(6)     path 'iss_workst_bin'
                     , acq_workst_bin            varchar2(6)     path 'acq_workst_bin'
                     , chargeback_ref_num        varchar2(6)     path 'chargeback_ref_num'
                     , docum_ind                 varchar2(1)     path 'docum_ind'
                     , member_msg_text           varchar2(50)    path 'member_msg_text'
                     , spec_cond_ind             varchar2(2)     path 'spec_cond_ind'
                     , fee_program_ind           varchar2(3)     path 'fee_program_ind'
                     , issuer_charge             varchar2(1)     path 'issuer_charge'
                     , merchant_number           varchar2(15)    path 'merchant_number'
                     , terminal_number           varchar2(8)     path 'terminal_number'
                     , national_reimb_fee        varchar2(12)    path 'national_reimb_fee'
                     , electr_comm_ind           varchar2(1)     path 'electr_comm_ind'
                     , spec_chargeback_ind       varchar2(1)     path 'spec_chargeback_ind'
                     , interface_trace_num       varchar2(6)     path 'interface_trace_num'
                     , unatt_accept_term_ind     varchar2(1)     path 'unatt_accept_term_ind'
                     , prepaid_card_ind          varchar2(1)     path 'prepaid_card_ind'
                     , service_development       varchar2(1)     path 'service_development'
                     , avs_resp_code             varchar2(1)     path 'avs_resp_code'
                     , auth_source_code          varchar2(1)     path 'auth_source_code'
                     , purch_id_format           varchar2(1)     path 'purch_id_format'
                     , account_selection         varchar2(1)     path 'account_selection'
                     , installment_pay_count     varchar2(2)     path 'installment_pay_count'
                     , purch_id                  varchar2(25)    path 'purch_id'
                     , cashback                  varchar2(9)     path 'cashback'
                     , chip_cond_code            varchar2(1)     path 'chip_cond_code'
                     , pos_environment           varchar2(1)     path 'pos_environment'
                     , transaction_type          varchar2(2)     path 'transaction_type'
                     , card_seq_number           varchar2(3)     path 'card_seq_number'
                     , terminal_profile          varchar2(6)     path 'terminal_profile'
                     , unpredict_number          varchar2(8)     path 'unpredict_number'
                     , appl_trans_counter        varchar2(4)     path 'appl_trans_counter'
                     , appl_interch_profile      varchar2(4)     path 'appl_interch_profile'
                     , cryptogram                varchar2(16)    path 'cryptogram'
                     , term_verif_result         varchar2(10)    path 'term_verif_result'
                     , cryptogram_amount         varchar2(12)    path 'cryptogram_amount'
                     , card_verif_result         varchar2(8)     path 'card_verif_result'
                     , issuer_appl_data          varchar2(64)    path 'issuer_appl_data'
                     , issuer_script_result      varchar2(10)    path 'issuer_script_result'
                     , card_expir_date           varchar2(4)     path 'card_expir_date'
                     , cryptogram_version        varchar2(2)     path 'cryptogram_version'
                     , cvv2_result_code          varchar2(1)     path 'cvv2_result_code'
                     , auth_resp_code            varchar2(2)     path 'auth_resp_code'
                     , cryptogram_info_data      varchar2(2)     path 'cryptogram_info_data'
                     , transaction_id            varchar2(15)    path 'transaction_id'
                     , merchant_verif_value      varchar2(10)    path 'merchant_verif_value'
                     , proc_bin                  varchar2(6)     path 'proc_bin'
                     , chargeback_reason_code    varchar2(4)     path 'chargeback_reason_code'
                     , destination_channel       varchar2(1)     path 'destination_channel'
                     , source_channel            varchar2(1)     path 'source_channel'
                     , acq_inst_bin              varchar2(12)    path 'acq_inst_bin'
                     , spend_qualified_ind       varchar2(1)     path 'spend_qualified_ind'
                     , service_code              varchar2(3)     path 'service_code'
           );

    l_baseII_rec.id := i_oper_id;

    l_baseII_rec.id :=
        vis_api_fin_message_pkg.put_message(
            i_fin_rec       => l_baseII_rec
        );

    trc_log_pkg.debug(
        i_text          => 'opr_prc_import_pkg.register_baseII_data; i_oper_id [#1] end'
      , i_env_param1    => i_oper_id
    );

exception
    when others then
        trc_log_pkg.error(
            i_text          => 'BASEII_DATA_NOT_FOUND: ' || sqlerrm
        );

        com_api_error_pkg.raise_error(
            i_error         => 'BASEII_DATA_NOT_FOUND'
          , i_env_param1    => i_oper_id
        );
end register_baseII_data;

procedure register_notes(
    io_notes        in out nocopy xmltype
  , i_oper_id       in            com_api_type_pkg.t_long_id
) is
    l_id    com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text          => 'opr_prc_import_pkg.register_notes'
    );

    for note in (
        select x.note_type
             , c.lang
             , c.note_header
             , c.note_text
          from xmltable(
                   xmlnamespaces('http://bpc.ru/sv/SVXP/clearing' as "svxp")
                 , '/svxp:note'
                   passing io_notes
                   columns note_type       varchar2(8)     path 'svxp:note_type'
                         , note_content    xmltype         path 'svxp:note_content'
               ) x
             , xmltable(
                   xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing')
                 , '/note_content'
                   passing x.note_content
                   columns lang            varchar2(8)     path '@language'
                         , note_header     varchar2(4000)  path 'note_header'
                         , note_text       varchar2(4000)  path 'note_text'
               ) c
    ) loop
        ntb_ui_note_pkg.add (
            o_id            => l_id
          , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id     => i_oper_id
          , i_note_type     => note.note_type
          , i_lang          => note.lang
          , i_header        => note.note_header
          , i_text          => note.note_text
        );
    end loop;
end;

procedure register_additional_amount(
    io_addl_amounts in out nocopy xmltype
  , i_oper_id       in            com_api_type_pkg.t_long_id
) is
    l_amount_type_tab             com_api_type_pkg.t_dict_tab;
    l_amount_value_tab            com_api_type_pkg.t_money_tab;
    l_currency_tab                com_api_type_pkg.t_curr_code_tab;
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.register_additional_amount'
    );

    for addl_amount in (
        select x.amount_value
             , x.currency
             , x.amount_type
          from xmltable(
                   xmlnamespaces('http://bpc.ru/sv/SVXP/clearing' as "svxp")
                 , '/svxp:additional_amount'
                   passing io_addl_amounts
                   columns amount_value  number       path 'svxp:amount_value'
                         , currency      varchar2(3)  path 'svxp:currency'
                         , amount_type   varchar2(8)  path 'svxp:amount_type'
               ) x
    ) loop
        l_amount_type_tab (l_amount_type_tab.count  + 1) := addl_amount.amount_type;
        l_amount_value_tab(l_amount_value_tab.count + 1) := addl_amount.amount_value;
        l_currency_tab    (l_currency_tab.count     + 1) := addl_amount.currency;
    end loop;

    opr_api_additional_amount_pkg.insert_amount(
        i_oper_id          => i_oper_id
      , i_amount_type_tab  => l_amount_type_tab
      , i_amount_value_tab => l_amount_value_tab
      , i_currency_tab     => l_currency_tab
    );
end;

procedure register_flexible_data(
    io_flexible_data in out nocopy xmltype
  , i_oper_id        in            com_api_type_pkg.t_long_id
) is
    l_flexible_data_rec            com_api_type_pkg.t_flexible_field;
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.register_flexible_data'
    );

    for flexible_data_node in (
        select x.field_name
             , x.field_value
          from xmltable(
                   xmlnamespaces('http://bpc.ru/sv/SVXP/clearing' as "svxp")
                 , '/svxp:flexible_data'
                   passing io_flexible_data
                   columns field_name     varchar2(200)    path 'svxp:field_name'
                         , field_value    varchar2(200)    path 'svxp:field_value'
               ) x
    ) loop
        l_flexible_data_rec :=
            com_api_flexible_data_pkg.get_flexible_field(
                i_field_name  => flexible_data_node.field_name
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            );

        if l_flexible_data_rec.data_type = com_api_const_pkg.DATA_TYPE_CHAR then
            com_api_flexible_data_pkg.set_flexible_value(
                i_field_name  => flexible_data_node.field_name
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => i_oper_id
              , i_field_value => flexible_data_node.field_value
            );
        elsif l_flexible_data_rec.data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
            com_api_flexible_data_pkg.set_flexible_value(
                i_field_name  => flexible_data_node.field_name
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => i_oper_id
              , i_field_value => to_number(flexible_data_node.field_value)
            );
        elsif l_flexible_data_rec.data_type = com_api_const_pkg.DATA_TYPE_DATE then
            com_api_flexible_data_pkg.set_flexible_value(
                i_field_name  => flexible_data_node.field_name
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => i_oper_id
              , i_field_value => to_date(flexible_data_node.field_value, com_api_const_pkg.XML_DATETIME_FORMAT)
            );
        end if;
    end loop;
end register_flexible_data;

procedure register_participant(
    io_participant      in out nocopy   opr_api_type_pkg.t_oper_part_rec
  , io_oper             in out nocopy   t_oper_clearing_rec
  , io_resp_code        in out          com_api_type_pkg.t_dict_value
  , i_without_checks    in              com_api_type_pkg.t_boolean          default null
  , io_split_hash_tab   in out nocopy   com_api_type_pkg.t_tiny_tab
  , io_inst_id_tab      in out nocopy   com_api_type_pkg.t_inst_id_tab
) is
    l_host_id                           com_api_type_pkg.t_tiny_id;
    l_payment_host_id                   com_api_type_pkg.t_tiny_id;
begin

    opr_api_create_pkg.add_participant(
        i_oper_id               => io_oper.oper_id
      , i_msg_type              => io_oper.msg_type
      , i_oper_type             => io_oper.oper_type
      , i_oper_reason           => io_oper.oper_reason
      , i_participant_type      => io_participant.participant_type
      , i_host_date             => io_oper.host_date
      , i_client_id_type        => io_participant.client_id_type
      , i_client_id_value       => io_participant.client_id_value
      , io_inst_id              => io_participant.inst_id
      , io_network_id           => io_participant.network_id
      , o_host_id               => l_host_id
      , io_card_inst_id         => io_participant.card_inst_id
      , io_card_network_id      => io_participant.card_network_id
      , io_card_id              => io_participant.card_id
      , o_card_instance_id      => io_participant.card_instance_id
      , io_card_type_id         => io_participant.card_type_id
      , i_card_number           => io_participant.card_number
      , io_card_mask            => io_participant.card_mask
      , io_card_hash            => io_participant.card_hash
      , io_card_seq_number      => io_participant.card_seq_number
      , io_card_expir_date      => io_participant.card_expir_date
      , io_card_service_code    => io_participant.card_service_code
      , io_card_country         => io_participant.card_country
      , io_customer_id          => io_participant.customer_id
      , io_account_id           => io_participant.account_id
      , i_account_type          => io_participant.account_type
      , i_account_number        => io_participant.account_number
      , i_account_amount        => io_participant.account_amount
      , i_account_currency      => io_participant.account_currency
      , i_auth_code             => io_participant.auth_code
      , i_merchant_number       => io_oper.merchant_number
      , io_merchant_id          => io_participant.merchant_id
      , i_terminal_number       => io_oper.terminal_number
      , io_terminal_id          => io_participant.terminal_id
      , o_split_hash            => io_participant.split_hash
      , i_without_checks        => i_without_checks
      , io_payment_host_id      => l_payment_host_id
      , i_payment_order_id      => io_oper.payment_order_id
      , i_acq_inst_id           => io_participant.acq_inst_id
      , i_acq_network_id        => io_participant.acq_network_id
      , i_oper_currency         => io_oper.oper_amount_currency
      , i_external_auth_id      => io_oper.external_auth_id
      , i_external_orig_id      => io_oper.external_orig_id
      , i_trace_number          => io_oper.trace_number
      , i_is_reversal           => io_oper.is_reversal
      , i_acq_inst_bin          => io_oper.acq_inst_bin
      , i_iss_inst_id           => io_participant.iss_inst_id
      , i_iss_network_id        => io_participant.iss_network_id
      , i_sttl_type             => io_oper.sttl_type
      , i_fast_oper_stage       => com_api_const_pkg.TRUE
    );

    if io_resp_code is null then
        io_resp_code      := aup_api_const_pkg.RESP_CODE_OK;
    end if;

    add_event_to_cache(
        io_split_hash_tab => io_split_hash_tab
      , io_inst_id_tab    => io_inst_id_tab
      , i_new_split_hash  => io_participant.split_hash
      , i_new_inst_id     => io_participant.inst_id
    );

exception
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error = 'DUPLICATE_OPERATION' then
            io_resp_code      := aup_api_const_pkg.RESP_CODE_OPERATION_DUPLICATED;
        else
            io_resp_code      := aup_api_const_pkg.RESP_CODE_ERROR;
        end if;

        add_event_to_cache(
            io_split_hash_tab => io_split_hash_tab
          , io_inst_id_tab    => io_inst_id_tab
          , i_new_split_hash  => io_participant.split_hash
          , i_new_inst_id     => io_participant.inst_id
        );

end register_participant;

procedure register_custom_participants(
    io_oper             in out nocopy t_oper_clearing_rec
  , io_resp_code        in out        com_api_type_pkg.t_dict_value
  , i_import_clear_pan  in            com_api_type_pkg.t_boolean
  , io_split_hash_tab   in out nocopy com_api_type_pkg.t_tiny_tab
  , io_inst_id_tab      in out nocopy com_api_type_pkg.t_inst_id_tab
) is
    l_participant       opr_api_type_pkg.t_oper_part_rec;
begin
    trc_log_pkg.debug(
        i_text          => 'opr_prc_import_pkg.register_custom_participants'
    );

    for participant in (
        select x.participant_type
             , x.client_id_type
             , x.client_id_value
             , case nvl(i_import_clear_pan, com_api_const_pkg.TRUE)
                   when com_api_const_pkg.TRUE
                   then x.card_number
                   else iss_api_token_pkg.decode_card_number(i_card_number => x.card_number)
               end as card_number
             , x.card_seq_number
             , to_date(x.card_expir_date, com_api_const_pkg.XML_DATETIME_FORMAT) as card_expir_date
             , x.inst_id
             , x.network_id
             , x.auth_code
             , x.account_amount
             , x.account_currency
             , x.account_number
          from xmltable(
                   xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing')
                 , '/participant'
                   passing io_oper.participant
                   columns participant_type           varchar(8)    path 'participant_type'
                         , client_id_type             varchar2(8)   path 'client_id_type'
                         , client_id_value            varchar2(200) path 'client_id_value'
                         , card_number                varchar2(24)  path 'card_number'
                         , card_seq_number            number        path 'card_seq_number'
                         , card_expir_date            varchar2(20)  path 'card_expir_date'
                         , inst_id                    number        path 'inst_id'
                         , network_id                 number        path 'network_id'
                         , auth_code                  varchar2(6)   path 'auth_code'
                         , account_amount             number        path 'account_amount'
                         , account_currency           varchar2(3)   path 'account_currency'
                         , account_number             varchar2(32)  path 'account_number'
               ) x
    ) loop
        l_participant.participant_type := participant.participant_type;
        l_participant.client_id_type   := participant.client_id_type;
        l_participant.client_id_value  := participant.client_id_value;
        l_participant.inst_id          := nvl(participant.inst_id, io_oper.default_inst_id);
        l_participant.network_id       := participant.network_id;
        l_participant.auth_code        := participant.auth_code;
        l_participant.card_number      := participant.card_number;
        l_participant.card_seq_number  := participant.card_seq_number;
        l_participant.card_expir_date  := participant.card_expir_date;
        l_participant.account_amount   := participant.account_amount;
        l_participant.account_currency := participant.account_currency;
        l_participant.account_number   := participant.account_number;

        register_participant(
            io_participant    => l_participant
          , io_oper           => io_oper
          , io_resp_code      => io_resp_code
          , io_split_hash_tab => io_split_hash_tab
          , io_inst_id_tab    => io_inst_id_tab
        );
    end loop;
end;

/*
 * Merge processing stages of the operation that being processed.
 */
procedure register_processing_stage(
    i_processing_stage  in            xmltype
  , i_oper              in            t_oper_clearing_rec
  , io_is_error         in out        com_api_type_pkg.t_boolean
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.register_processing_stage';

    l_split_method      com_api_type_pkg.t_dict_value;
    l_exec_order        com_api_type_pkg.t_tiny_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_count             pls_integer := 0;

begin
    trc_log_pkg.debug(LOG_PREFIX || ' <<');

    for rec in (
        select x.proc_stage
             , x.status
          from xmltable(
                   xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing')
                 , '/processing_stage'
                   passing i_processing_stage
                   columns proc_stage   varchar2(8)   path 'proc_stage'
                         , status       varchar2(8)   path 'status'
               ) x
    ) loop

        begin
            select *
              into l_exec_order
                 , l_split_method
              from (
                  select r.exec_order
                       , r.split_method
                    from opr_proc_stage r
                   where nvl(rec.proc_stage,   '%') like r.proc_stage
                     and nvl(i_oper.msg_type,  '%') like r.msg_type
                     and nvl(i_oper.sttl_type, '%') like r.sttl_type
                     and nvl(i_oper.oper_type, '%') like r.oper_type
                     and nvl(rec.status,       '%') like r.status
                   order by r.exec_order desc
              ) where rownum = 1;

        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text        => 'OPR_STAGE_NOT_FOUND'
                  , i_env_param1  => rec.proc_stage
                );

                io_is_error := com_api_const_pkg.TRUE;
                continue;
        end;

        trc_log_pkg.debug('l_split_method = ' || l_split_method || ', l_exec_order = ' || l_exec_order);

        l_split_hash := g_participants(nvl(l_split_method, com_api_const_pkg.PARTICIPANT_ISSUER)).split_hash;

        trc_log_pkg.debug('l_split_hash = ' || l_split_hash);

        merge into
            opr_oper_stage dst
        using (
            select i_oper.oper_id      as oper_id
                 , rec.proc_stage      as proc_stage
                 , rec.status          as status
                 , l_exec_order        as exec_order
                 , l_split_hash        as split_hash
              from dual
        ) src
        on (
                src.oper_id    = dst.oper_id
            and src.proc_stage = dst.proc_stage
            and src.exec_order = dst.exec_order
            and src.split_hash = dst.split_hash
        )
        when matched then
            update
            set dst.status = src.status
        when not matched then
            insert (
                dst.oper_id
              , dst.proc_stage
              , dst.status
              , dst.exec_order
              , dst.split_hash
            ) values (
                src.oper_id
              , src.proc_stage
              , src.status
              , src.exec_order
              , src.split_hash
            );

        l_count := l_count + 1;

        trc_log_pkg.debug('l_count = ' || l_count);

    end loop;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> count of processing stages for the operations: #1'
      , i_env_param1 => l_count --l_proc_stage_tab.count()
    );
end register_processing_stage;

procedure get_original_id(
    io_oper             in out nocopy t_oper_clearing_rec
  , io_resp_code        in out        com_api_type_pkg.t_dict_value
  , o_original_id       out           com_api_type_pkg.t_long_id
  , io_status           in out        com_api_type_pkg.t_dict_value
) is
    l_orig_oper_status            com_api_type_pkg.t_dict_value;
    l_original_id                 com_api_type_pkg.t_long_id;
    l_client_id_value             com_api_type_pkg.t_name;
begin
    -- Searching by external_auth_id is first priority
    if io_oper.external_auth_id is not null then

        trc_log_pkg.debug(
            i_text       => 'io_oper.external_orig_id = [#1], io_oper.external_auth_id [#2]'
          , i_env_param1 => io_oper.external_orig_id
          , i_env_param2 => io_oper.external_auth_id
        );

        select a.id
             , o.status
          into l_original_id
             , l_orig_oper_status
          from aut_auth a
             , opr_operation o
         where a.external_auth_id = io_oper.external_auth_id
           and o.id = a.id
           and nvl(o.is_reversal, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
           and o.id != io_oper.oper_id
           and o.status != opr_api_const_pkg.OPERATION_STATUS_DUPLICATE;

    else
        -- Searching by l_client_id_value and originator_refnum is second priority
        l_client_id_value :=
            case io_oper.issuer_client_id_type
                when opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                    then nvl(io_oper.issuer_client_id_value, io_oper.issuer_card_number)
                    else io_oper.issuer_client_id_value
            end;

        trc_log_pkg.debug(
            i_text       => 'io_oper.is_reversal = 1, search original operation: '
                         || 'originator_refnum [#1], oper_date [#2], '
                         || 'issuer_card_number [#3], issuer_client_id_type [#4], issuer_client_id_value [#5]'
          , i_env_param1 => io_oper.originator_refnum
          , i_env_param2 => io_oper.oper_date
          , i_env_param3 => iss_api_card_pkg.get_card_mask(i_card_number => io_oper.issuer_card_number)
          , i_env_param4 => io_oper.issuer_client_id_type
          , i_env_param5 => case when io_oper.issuer_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                                 then iss_api_card_pkg.get_card_mask(i_card_number => io_oper.issuer_client_id_value)
                                 else io_oper.issuer_client_id_value
                            end
        );

        if  io_oper.issuer_client_id_type is null
            or
            l_client_id_value is null
        then
            trc_log_pkg.debug('original operation can''t be found because of insufficient issuer data');

        else
            -- We consider that <io_oper.issuer_client_id_type> can't be NULL, and card number may be passed
            -- either via <io_oper.issuer_card_number> or via <io_oper.issuer_client_id_value> but only with
            -- client type <opr_api_const_pkg.CLIENT_ID_TYPE_CARD>
            select o.id
                 , o.status
              into l_original_id
                 , l_orig_oper_status
              from opr_operation o
                 , opr_participant op
                 , opr_card oc
             where op.oper_id = o.id
               and nvl(o.is_reversal, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
               and o.originator_refnum = io_oper.originator_refnum
               and o.oper_type         = io_oper.oper_type
               and o.msg_type          = io_oper.msg_type
               and io_oper.oper_date - o.oper_date <= REVERSAL_SEARCH_TIME_WINDOW
               and not exists ( -- operation may be already linked with another reversal
                   select r.id
                     from opr_operation r
                    where nvl(r.is_reversal, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
                      and r.original_id = o.id
               )
               and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and oc.oper_id(+) = op.oper_id
               and oc.participant_type(+) = op.participant_type
               and op.client_id_type = io_oper.issuer_client_id_type
               and case io_oper.issuer_client_id_type
                       when opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                           then coalesce(
                                    op.client_id_value
                                  , iss_api_token_pkg.decode_card_number(i_card_number => oc.card_number)
                                )
                           else op.client_id_value
                   end
                   = l_client_id_value;
        end if;
    end if;

    trc_log_pkg.debug('searching result: l_original_id [' || l_original_id || '], l_orig_oper_status [' || l_orig_oper_status || ']');

    -- Check original operation status and set reversal's status to "Frozen for manual processing" if it is needed
    if  l_original_id is not null
        and l_orig_oper_status not in (opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                                     , opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                     , opr_api_const_pkg.OPERATION_STATUS_NO_ENTRIES
                                     , opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD)
    then
        io_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;

        trc_log_pkg.warn(
            i_text       => 'ORIGINAL_OPERATION_IS_NOT_SUCCESSFUL'
          , i_env_param1 => io_oper.oper_id
          , i_env_param2 => io_status
          , i_env_param3 => l_original_id
          , i_env_param4 => l_orig_oper_status
        );
    end if;

    o_original_id := l_original_id;

exception
    when no_data_found then
        trc_log_pkg.error(
            i_text       => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
          , i_env_param1 => io_oper.oper_id
          , i_env_param2 => io_oper.originator_refnum
          , i_env_param3 => io_oper.oper_date
          , i_env_param4 => io_oper.issuer_client_id_type
          , i_env_param5 => case when io_oper.issuer_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                                 then iss_api_card_pkg.get_card_mask(i_card_number => l_client_id_value)
                                 else l_client_id_value
                            end
          , i_env_param6 => io_oper.external_auth_id
        );

        io_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;

    when too_many_rows then
        trc_log_pkg.error(
            i_text       => 'DUPLICATE_ORIGINAL_OPERATION'
          , i_env_param1 => io_oper.oper_id
          , i_env_param2 => io_oper.originator_refnum
          , i_env_param3 => io_oper.oper_date
          , i_env_param4 => io_oper.issuer_client_id_type
          , i_env_param5 => case when io_oper.issuer_client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                                 then iss_api_card_pkg.get_card_mask(i_card_number => l_client_id_value)
                                 else l_client_id_value
                            end
          , i_env_param6 => io_oper.external_auth_id
        );

        io_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;
end;

procedure update_total_amount
is
    l_base_operation_id         com_api_type_pkg.t_long_id;
    l_total_amount              com_api_type_pkg.t_money;
    l_oper_amount               com_api_type_pkg.t_money;
begin
    for i in 1 .. g_operations.count loop
        begin
            -- Value "Total_amount" is filled in base operation only which has "aut_auth.is_incremental is null".
            -- Value "Total_amount" is empty in its incremental operations which has "aut_auth.is_incremental is not null".
            select a.id
                 , (
                       select coalesce(op.total_amount, op.oper_amount)
                         from opr_operation op
                        where op.id = a.id
                   )
                 , (
                       select decode(op.is_reversal, 0, op.oper_amount, 1, op.oper_amount * -1)
                         from opr_operation op
                        where op.id = o.id
                   )
              into l_base_operation_id
                 , l_total_amount
                 , l_oper_amount
              from aut_auth a
                 , aut_auth o
             where a.external_auth_id = o.trace_number
               and o.id = g_operations(i);

            l_total_amount     := nvl(l_total_amount, 0) + nvl(l_oper_amount, 0);

            update opr_operation
               set total_amount = l_total_amount
             where id = l_base_operation_id;

            update opr_operation
               set match_status = opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH
             where id = g_operations(i);

            trc_log_pkg.debug(
                i_text          => 'Update total_amount; i_oper_id [#1], l_base_oper_id[#2], l_total_amount[#3], l_oper_amount[#4]'
              , i_env_param1    => g_operations(i)
              , i_env_param2    => l_base_operation_id
              , i_env_param3    => l_total_amount
              , i_env_param4    => l_oper_amount
            );
        exception
            when no_data_found then
                -- Error
                trc_log_pkg.error(
                    i_text        => 'opr_prc_import_pkg.update_total_amount: No found base operation. oper_id [#1]'
                  , i_env_param1  => g_operations(i)
                );
           when too_many_rows then
                -- Error
                trc_log_pkg.error(
                    i_text        => 'opr_prc_import_pkg.update_total_amount: Too many rows for base operation. oper_id [#1]'
                  , i_env_param1  => g_operations(i)
                );
        end;
    end loop;
end update_total_amount;

function register_operation(
    io_oper                 in out nocopy t_oper_clearing_rec
  , io_auth_data_rec        in out nocopy aut_api_type_pkg.t_auth_rec
  , io_auth_tag_tab         in out nocopy aut_api_type_pkg.t_auth_tag_tab
  , i_import_clear_pan      in            com_api_type_pkg.t_boolean
  , i_oper_status           in            com_api_type_pkg.t_dict_value default opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
  , i_sttl_date             in            date
  , i_without_checks        in            com_api_type_pkg.t_boolean    default null
  , i_fraud_control         in            com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , io_split_hash_tab       in out nocopy com_api_type_pkg.t_tiny_tab
  , io_inst_id_tab          in out nocopy com_api_type_pkg.t_inst_id_tab
  , i_use_auth_data_rec     in            com_api_type_pkg.t_boolean
  , io_event_params         in out nocopy com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_dict_value
is
    l_customer_id                 com_api_type_pkg.t_medium_id;
    l_order_inst_id               com_api_type_pkg.t_inst_id;
    l_split_hash                  com_api_type_pkg.t_tiny_id;
    l_inst_id                     com_api_type_pkg.t_inst_id;

    l_acquirer                    opr_api_type_pkg.t_oper_part_rec;
    l_issuer                      opr_api_type_pkg.t_oper_part_rec;
    l_original_issuer             opr_api_type_pkg.t_oper_part_rec;
    l_dest                        opr_api_type_pkg.t_oper_part_rec;
    l_srvp                        opr_api_type_pkg.t_oper_part_rec;
    l_agg                         opr_api_type_pkg.t_oper_part_rec;

    l_iss_network_id              com_api_type_pkg.t_network_id;
    l_original_id                 com_api_type_pkg.t_long_id;
    l_dispute_id                  com_api_type_pkg.t_long_id;
    l_disputed_operation_id       com_api_type_pkg.t_long_id;

    l_match_status                com_api_type_pkg.t_dict_value;
    l_status                      com_api_type_pkg.t_dict_value := nvl(io_oper.status, i_oper_status);
    l_resp_code                   com_api_type_pkg.t_dict_value;
    l_emv_data                    com_api_type_pkg.t_text;
    l_msg_type                    com_api_type_pkg.t_dict_value;
    l_network_refnum              com_api_type_pkg.t_rrn;

    l_auth_resp_code              com_api_type_pkg.t_dict_value;
    l_auth_acq_resp_code          com_api_type_pkg.t_dict_value;

    l_auth_purpose_id             com_api_type_pkg.t_long_id;  -- Tag "aut_auth.auth_purpose_id" is equivalent for tag "payment_order/purpose_number"
    l_is_error                    com_api_type_pkg.t_boolean  := com_api_const_pkg.FALSE;

    type t_customer_rec is record(
         customer_id        com_api_type_pkg.t_medium_id
       , split_hash         com_api_type_pkg.t_tiny_id
       , inst_id            com_api_type_pkg.t_inst_id
       , iss_network_id     com_api_type_pkg.t_network_id
    );

    type t_customer_rec_tab is table of t_customer_rec      index by com_api_type_pkg.t_name;
    type t_customer_tab_tab is table of t_customer_rec_tab  index by com_api_type_pkg.t_dict_value;

    l_customer_cache    t_customer_tab_tab;
    l_customer_rec      t_customer_rec;
    --l_customer_cache(id_type)(id_value).customer_id

    procedure find_customer(
        io_participant  in out nocopy opr_api_type_pkg.t_oper_part_rec
    ) is
    begin
        begin
            l_customer_rec  := l_customer_cache(io_participant.client_id_type)(io_participant.client_id_value);

            if io_participant.inst_id is not null and l_customer_rec.inst_id != io_participant.inst_id then
                l_customer_rec.customer_id := null;

            else
                trc_log_pkg.debug(
                    i_text          => 'customer found in cache: [#1] [#2], customer_id [#3]'
                  , i_env_param1    => io_participant.client_id_type
                  , i_env_param2    => io_participant.client_id_value
                  , i_env_param3    => l_customer_rec.customer_id
                );
            end if;

        exception
            when no_data_found then
                l_customer_rec.customer_id := null;
        end;

        if l_customer_rec.customer_id is null then
            prd_api_customer_pkg.find_customer(
                i_client_id_type    => io_participant.client_id_type
              , i_client_id_value   => io_participant.client_id_value
              , i_inst_id           => io_participant.inst_id
              , i_raise_error       => com_api_const_pkg.FALSE
              , i_error_value       => null
              , o_customer_id       => l_customer_rec.customer_id
              , o_split_hash        => l_customer_rec.split_hash
              , o_inst_id           => l_customer_rec.inst_id
              , o_iss_network_id    => l_customer_rec.iss_network_id
            );

            l_customer_cache(io_participant.client_id_type)(io_participant.client_id_value) := l_customer_rec;
        end if;

        io_participant.customer_id  := l_customer_rec.customer_id;
        io_participant.split_hash   := l_customer_rec.split_hash;
        io_participant.inst_id      := l_customer_rec.inst_id;
        l_iss_network_id            := l_customer_rec.iss_network_id;

        if io_participant.customer_id is null then
            trc_log_pkg.error(
                i_text          => 'OPR_CUSTOMER_NOT_FOUND'
              , i_env_param1    => io_participant.client_id_type
              , i_env_param2    => io_participant.client_id_value
            );
        end if;
    end find_customer;

    function get_oper_id (
        io_oper             in out nocopy t_oper_clearing_rec
      , i_fraud_control     in            com_api_type_pkg.t_boolean
    ) return com_api_type_pkg.t_long_id is

        l_result  com_api_type_pkg.t_long_id;
    begin
        if i_fraud_control = com_api_const_pkg.TRUE then

            select oper_id
              into l_result
              from opr_oper_stage
             where is_reversal      = io_oper.is_reversal
               and external_auth_id = io_oper.external_auth_id;

            trc_log_pkg.debug(
                i_text          => 'Found oper_id [#1], i_fraud_control [#2]'
              , i_env_param1    => l_result
              , i_env_param2    => i_fraud_control
            );

        else
            l_result := opr_api_create_pkg.get_id(i_host_date => io_oper.host_date);
        end if;

        return l_result;

    exception
        when no_data_found then

            l_result := opr_api_create_pkg.get_id(i_host_date => io_oper.host_date);

            return l_result;
    end get_oper_id;
begin
    begin
        com_api_sttl_day_pkg.set_sysdate(
            i_sysdate       => io_oper.host_date
        );

        trc_log_pkg.debug(
            i_text          => 'io_oper.oper_id [#1], i_fraud_control [#2]'
          , i_env_param1    => io_oper.oper_id
          , i_env_param2    => i_fraud_control
        );

        --io_oper.oper_id := coalesce(io_oper.oper_id, opr_api_create_pkg.get_id(i_host_date => io_oper.host_date));
        if io_oper.oper_id is null then
            io_oper.oper_id := get_oper_id (
                                   io_oper          => io_oper
                                 , i_fraud_control  => i_fraud_control
                               );
        end if;

        trc_log_pkg.debug(
            i_text          => 'oper_id [#1]'
          , i_env_param1    => io_oper.oper_id
        );

        trc_log_pkg.set_object(
            i_object_id     => io_oper.oper_id
          , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        );

        l_issuer.participant_type   := com_api_const_pkg.PARTICIPANT_ISSUER;
        l_acquirer.participant_type := com_api_const_pkg.PARTICIPANT_ACQUIRER;
        l_dest.participant_type     := com_api_const_pkg.PARTICIPANT_DEST;
        l_srvp.participant_type     := com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER;
        l_agg.participant_type      := com_api_const_pkg.PARTICIPANT_AGGREGATOR;

        if i_use_auth_data_rec = com_api_const_pkg.TRUE then
            l_auth_purpose_id          := io_auth_data_rec.auth_purpose_id;
            l_emv_data                 := io_auth_data_rec.emv_data;
            l_issuer.card_service_code := io_auth_data_rec.service_code;

        else
            if io_oper.auth_data is not null then
                begin
                    select auth_purpose_id
                         , emv_data
                         , service_code
                      into l_auth_purpose_id
                         , l_emv_data
                         , l_issuer.card_service_code
                      from xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing'),
                               '/auth_data'
                               passing io_oper.auth_data
                               columns auth_purpose_id         number(16)          path 'auth_purpose_id'
                                     , emv_data                varchar2(2000)      path 'emv_data'
                                     , service_code            varchar(3)          path 'service_code'
                           );

                exception
                    when no_data_found then
                        trc_log_pkg.error(
                            i_text          => 'AUTH_NOT_FOUND'
                          , i_env_param1    => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_env_param2    => io_oper.oper_id
                          , i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id     => io_oper.oper_id
                        );

                        l_is_error := com_api_const_pkg.TRUE;

                    when others then
                        trc_log_pkg.error(
                            i_text          => 'UNHANDLED_EXCEPTION'
                          , i_env_param1    => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_env_param2    => io_oper.oper_id
                          , i_env_param3    => sqlerrm
                        );

                        l_is_error := com_api_const_pkg.TRUE;
                end;
            end if;
        end if;

        if io_oper.payment_order_exists  = com_api_const_pkg.TRUE
           and io_oper.payment_order_id is null
        then

            if io_oper.purpose_number  is null then
                io_oper.purpose_number := l_auth_purpose_id;
            end if;

            if io_oper.purpose_id is null and io_oper.purpose_number is not null then
                begin
                    select id
                      into io_oper.purpose_id
                      from pmo_purpose
                     where purpose_number = io_oper.purpose_number;

                exception
                    when no_data_found then
                        trc_log_pkg.error(
                            i_text          => 'PAYMENT_PURPOSE_NOT_EXISTS'
                          , i_env_param1    => io_oper.purpose_number
                        );

                        l_is_error := com_api_const_pkg.TRUE;
                end;
            end if;

            if io_oper.purpose_id is not null then
                if io_oper.payment_order_prty_type is null then
                  io_oper.payment_order_prty_type  := com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER;
                end if;

                --register new payment order
                case io_oper.payment_order_prty_type
                when com_api_const_pkg.PARTICIPANT_ACQUIRER then
                    l_acquirer.client_id_type  := io_oper.acquirer_client_id_type;
                    l_acquirer.client_id_value := io_oper.acquirer_client_id_value;
                    l_acquirer.inst_id         := nvl(io_oper.acquirer_inst_id, io_oper.default_inst_id);
                    find_customer(
                        io_participant  => l_acquirer
                    );
                    l_customer_id              := l_acquirer.customer_id;
                    l_order_inst_id            := l_acquirer.inst_id;
                    l_split_hash               := l_acquirer.split_hash;

                when com_api_const_pkg.PARTICIPANT_ISSUER then
                    l_issuer.client_id_type    := io_oper.issuer_client_id_type;
                    l_issuer.client_id_value   := io_oper.issuer_client_id_value;
                    l_issuer.inst_id           := nvl(io_oper.issuer_inst_id, io_oper.default_inst_id);
                    find_customer(
                        io_participant  => l_issuer
                    );
                    l_customer_id              := l_issuer.customer_id;
                    l_order_inst_id            := l_issuer.inst_id;
                    l_split_hash               := l_issuer.split_hash;

                when com_api_const_pkg.PARTICIPANT_DEST then
                    l_dest.client_id_type      := io_oper.destination_client_id_type;
                    l_dest.client_id_value     := io_oper.destination_client_id_value;
                    l_dest.inst_id             := nvl(io_oper.destination_inst_id, io_oper.default_inst_id);
                    find_customer(
                        io_participant  => l_dest
                    );
                    l_customer_id              := l_dest.customer_id;
                    l_order_inst_id            := l_dest.inst_id;
                    l_split_hash               := l_dest.split_hash;

                when com_api_const_pkg.PARTICIPANT_AGGREGATOR then
                    l_agg.client_id_type       := io_oper.aggregator_client_id_type;
                    l_agg.client_id_value      := io_oper.aggregator_client_id_value;
                    l_agg.inst_id              := nvl(io_oper.aggregator_inst_id, io_oper.default_inst_id);
                    find_customer(
                        io_participant  => l_agg
                    );
                    l_customer_id              := l_agg.customer_id;
                    l_order_inst_id            := l_agg.inst_id;
                    l_split_hash               := l_agg.split_hash;

                when com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER then

                    if io_oper.service_provider_exists = com_api_const_pkg.TRUE then
                        l_srvp.client_id_type  := io_oper.srvp_client_id_type;
                        l_srvp.client_id_value := io_oper.srvp_client_id_value;
                        l_srvp.inst_id         := nvl(io_oper.srvp_inst_id, io_oper.default_inst_id);

                    elsif l_auth_purpose_id is not null then
                        l_srvp.client_id_type := pmo_api_const_pkg.CLIENT_ID_TYPE_SRVP_NUMBER;

                        begin
                            select p.provider_number
                              into l_srvp.client_id_value
                              from pmo_purpose  s
                                 , pmo_provider p
                             where s.purpose_number = to_char(l_auth_purpose_id)
                               and s.provider_id    = p.id;

                            l_srvp.inst_id := io_oper.default_inst_id;
                        exception
                            when others then
                                l_srvp.client_id_type := null;
                        end;
                    end if;

                    find_customer(
                        io_participant  => l_srvp
                    );
                    l_customer_id              := l_srvp.customer_id;
                    l_order_inst_id            := l_srvp.inst_id;
                    l_split_hash               := l_srvp.split_hash;

                else
                    trc_log_pkg.error(
                        i_text        => 'WRONG_PARTICIPANT_TYPE'
                      , i_env_param1  => io_oper.payment_order_prty_type
                    );

                    l_is_error := com_api_const_pkg.TRUE;
                end case;

                if l_customer_id is null then
                    trc_log_pkg.error(
                        i_text        => 'CUSTOMER_NOT_FOUND'
                    );

                    l_is_error := com_api_const_pkg.TRUE;

                else
                    pmo_api_order_pkg.add_order(
                        o_id                    => io_oper.payment_order_id
                      , i_customer_id           => l_customer_id
                      , i_entity_type           => null
                      , i_object_id             => null
                      , i_purpose_id            => io_oper.purpose_id
                      , i_template_id           => null
                      , i_amount                => io_oper.payment_order_amount
                      , i_currency              => io_oper.payment_order_currency
                      , i_event_date            => coalesce(io_oper.payment_date, io_oper.host_date)
                      , i_status                => io_oper.payment_order_status
                      , i_inst_id               => l_order_inst_id
                      , i_attempt_count         => null
                      , i_is_prepared_order     => com_api_const_pkg.FALSE
                      , i_split_hash            => l_split_hash
                      , i_payment_order_number  => io_oper.payment_order_number
                    );

                    for param in(
                        select name
                             , value
                          from xmltable('/payment_parameter'
                                    passing io_oper.payment_parameters
                                    columns     name    varchar2(200)   path 'payment_parameter_name'
                                              , value   varchar2(2000)  path 'payment_parameter_value'
                               )
                    ) loop
                        pmo_api_order_pkg.add_order_data(
                            i_order_id      => io_oper.payment_order_id
                          , i_param_name    => param.name
                          , i_param_value   => param.value
                        );
                    end loop;

                    trc_log_pkg.debug(
                        i_text          => 'payment order has been added [#1]'
                      , i_env_param1    => io_oper.payment_order_id
                    );
                end if;
            end if;
        end if;

        trc_log_pkg.debug(
            i_text          => 'io_oper.oper_id [#1], io_oper.default_inst_id [#2]'
          , i_env_param1    => io_oper.oper_id
          , i_env_param2    => io_oper.default_inst_id
        );

        -- Try to find original operation for a reversal
        if io_oper.is_reversal = com_api_const_pkg.TRUE
           and
           (io_oper.originator_refnum is not null or io_oper.external_auth_id is not null)
        then
            get_original_id (
                io_oper             => io_oper
              , io_resp_code        => l_resp_code
              , o_original_id       => l_original_id
              , io_status           => l_status
            );
            trc_log_pkg.debug('l_status = ' || l_status || ', l_original_id = ' || l_original_id);
        end if;

        -- Check external_orig_id
        if  io_oper.msg_type in (opr_api_const_pkg.MESSAGE_TYPE_CANCELETION
                               , opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
                               , opr_api_const_pkg.MESSAGE_TYPE_CHRGBK_PERIOD_EXT)
            and l_original_id is null
        then
            if nvl(io_oper.external_orig_id, 0) != nvl(io_oper.external_auth_id, 0) then
                -- It is necessary to use max() here because if an original operation
                -- is duplicated then TOO_MANY_ROWS exception will be raised on searching
                -- an original operation by associated canceletion/completion operation.
                -- Usage of max() instead of min() allows to get for a duplicate of
                -- canceletion/completion operation an associated duplicate of an original
                -- operation, but not source original one.
                if io_oper.is_reversal  = com_api_const_pkg.FALSE
                   and io_oper.msg_type = opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
                then
                    select max(a.id)
                      into l_original_id
                      from aut_auth a
                     where a.external_auth_id = io_oper.external_orig_id
                       and a.resp_code        = aup_api_const_pkg.RESP_CODE_OK;

                elsif io_oper.is_reversal = com_api_const_pkg.FALSE then
                    select max(a.id)
                      into l_original_id
                      from aut_auth a
                     where a.external_auth_id = io_oper.external_orig_id;

                else
                    select max(a.id)
                      into l_original_id
                      from aut_auth a
                         , opr_operation o
                     where a.external_auth_id = io_oper.external_auth_id
                       and a.external_orig_id = io_oper.external_orig_id
                       and o.id = a.id
                       and nvl(o.is_reversal, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
                       and o.id != io_oper.oper_id;

                end if;

                if l_original_id is null then
                    trc_log_pkg.error(
                        i_text       => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
                      , i_env_param1 => io_oper.oper_id
                      , i_env_param2 => io_oper.originator_refnum
                      , i_env_param3 => io_oper.oper_date
                      , i_env_param4 => io_oper.external_orig_id
                      , i_env_param5 => io_oper.external_auth_id
                    );

                    l_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;
                end if;
            end if;
        end if;

        if  io_oper.msg_type = opr_api_const_pkg.MESSAGE_TYPE_POS_BATCH
            and l_original_id is null
        then
            if nvl(io_oper.external_orig_id, 0) != nvl(io_oper.external_auth_id, 0) then
                if io_oper.is_reversal = com_api_const_pkg.FALSE then
                    select min(a.id)
                      into l_original_id
                      from aut_auth a
                     where a.external_auth_id = io_oper.external_orig_id;
                else
                    select min(a.id)
                      into l_original_id
                      from aut_auth a
                         , opr_operation o
                     where a.external_orig_id = io_oper.external_orig_id
                       and o.id = a.id
                       and nvl(o.is_reversal, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
                       and o.id != io_oper.oper_id;
                end if;
            end if;
        end if;

        -- Check reference to online dispute (Visa SMS)
        if io_oper.trace_number is not null
           and io_oper.msg_type in (opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
                                  , opr_api_const_pkg.MESSAGE_TYPE_REPRESENTMENT)
        then
            select min(o.id) as id
                 , min(o.dispute_id) keep (dense_rank first order by o.id) as dispute_id
              into l_disputed_operation_id
                 , l_dispute_id
              from aut_auth a
                 , opr_operation o
             where a.external_auth_id = io_oper.trace_number
               and o.id               = a.id
               and o.id              != io_oper.oper_id;

            if l_dispute_id is not null then
                io_oper.dispute_id := l_dispute_id;
                l_original_id      := nvl(l_original_id, l_disputed_operation_id);

            elsif l_disputed_operation_id is not null then
                io_oper.dispute_id := dsp_api_shared_data_pkg.get_id;
                l_original_id      := nvl(l_original_id, l_disputed_operation_id);

                update opr_operation
                   set dispute_id   = io_oper.dispute_id
                 where id           = l_disputed_operation_id;
            end if;
        end if;
        trc_log_pkg.debug('After check reference to online dispute l_original_id = ' || l_original_id);

        if io_oper.recon_type is not null and io_oper.recon_type = mcw_api_const_pkg.RECONCILIATION_MODE_FULL then
            if l_status in (opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY) then
                l_status := opr_api_const_pkg.OPERATION_STATUS_WAIT_SETTL;
            end if;
        end if;

        if l_status = opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL then
            l_match_status := opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH;
        else
            l_match_status := io_oper.match_status;
        end if;
        if l_match_status is null and io_oper.recon_type is not null and io_oper.recon_type = mcw_api_const_pkg.RECONCILIATION_MODE_FULL then
            l_match_status := opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH;
        end if;

        if l_original_id is not null
           and (io_oper.msg_type = opr_api_const_pkg.OPERATION_TYPE_UNKNOWN
                or
                io_oper.msg_type = aut_api_const_pkg.MESSAGE_TYPE_COMPLETION)
        then
            -- Common query for original operation
            select msg_type
                 , network_refnum
              into l_msg_type
                 , l_network_refnum
              from opr_operation
             where id = l_original_id;

            if io_oper.msg_type = opr_api_const_pkg.OPERATION_TYPE_UNKNOWN then
                io_oper.msg_type := l_msg_type;
            end if;

            if io_oper.msg_type = aut_api_const_pkg.MESSAGE_TYPE_COMPLETION then
                io_oper.network_refnum := l_network_refnum;
            end if;
        end if;

        g_participants.delete;

        if io_oper.issuer_exists = com_api_const_pkg.TRUE then
            l_issuer.client_id_type   := io_oper.issuer_client_id_type;
            l_issuer.client_id_value  := io_oper.issuer_client_id_value;
            l_issuer.inst_id          := nvl(io_oper.issuer_inst_id, io_oper.default_inst_id);
            l_issuer.network_id       := io_oper.issuer_network_id;

            if io_oper.sttl_type is null
               or io_oper.sttl_type not in (opr_api_const_pkg.SETTLEMENT_USONUS
                                          , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST
                                          , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST)
            then
                mup_utl_pkg.redefine_iss_networkd_id(
                    io_network_id     => l_issuer.network_id
                  , i_emv_data        => l_emv_data
                );
            end if;

            l_issuer.auth_code        := io_oper.issuer_auth_code;
            l_issuer.card_number      := io_oper.issuer_card_number;
            l_issuer.card_id          := io_oper.issuer_card_id;
            l_issuer.card_seq_number  := io_oper.issuer_card_seq_number;
            l_issuer.card_expir_date  := io_oper.issuer_card_expir_date;
            l_issuer.account_amount   := io_oper.issuer_account_amount;
            l_issuer.account_currency := io_oper.issuer_account_currency;
            l_issuer.account_number   := io_oper.issuer_account_number;
            l_issuer.acq_inst_id      := nvl(io_oper.acquirer_inst_id, io_oper.default_inst_id);
            l_issuer.acq_network_id   := coalesce(
                                             io_oper.acquirer_network_id
                                           , ost_api_institution_pkg.get_inst_network(i_inst_id => nvl(io_oper.acquirer_inst_id, io_oper.default_inst_id))
                                         );

            if l_original_id is not null
                and io_oper.msg_type = aut_api_const_pkg.MESSAGE_TYPE_COMPLETION
            then
                opr_api_operation_pkg.get_participant(
                    i_oper_id           => l_original_id
                  , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
                  , o_participant       => l_original_issuer
                );
                l_issuer.auth_code       := nvl(l_original_issuer.auth_code,       io_oper.issuer_auth_code);
                l_issuer.card_expir_date := nvl(l_original_issuer.card_expir_date, io_oper.issuer_card_expir_date);
            end if;

            register_participant(
                io_participant    => l_issuer
              , io_oper           => io_oper
              , io_resp_code      => l_resp_code
              , i_without_checks  => i_without_checks
              , io_split_hash_tab => io_split_hash_tab
              , io_inst_id_tab    => io_inst_id_tab
            );

            g_participants(com_api_const_pkg.PARTICIPANT_ISSUER) := l_issuer;
        end if;

        if io_oper.acquirer_exists = com_api_const_pkg.TRUE then
            l_acquirer.client_id_type   := io_oper.acquirer_client_id_type;
            l_acquirer.client_id_value  := io_oper.acquirer_client_id_value;
            l_acquirer.inst_id          := nvl(io_oper.acquirer_inst_id, io_oper.default_inst_id);
            l_acquirer.network_id       := io_oper.acquirer_network_id;
            l_acquirer.auth_code        := io_oper.acquirer_auth_code;
            l_acquirer.card_number      := io_oper.acquirer_card_number;
            l_acquirer.card_seq_number  := io_oper.acquirer_card_seq_number;
            l_acquirer.card_expir_date  := io_oper.acquirer_card_expir_date;
            l_acquirer.account_amount   := io_oper.acquirer_account_amount;
            l_acquirer.account_currency := io_oper.acquirer_account_currency;
            l_acquirer.account_number   := io_oper.acquirer_account_number;
            l_acquirer.iss_inst_id      := nvl(io_oper.issuer_inst_id, io_oper.default_inst_id);
            l_acquirer.iss_network_id   := coalesce(
                                               io_oper.issuer_network_id
                                             , ost_api_institution_pkg.get_inst_network(i_inst_id => nvl(io_oper.issuer_inst_id, io_oper.default_inst_id))
                                           );

            register_participant(
                io_participant    => l_acquirer
              , io_oper           => io_oper
              , io_resp_code      => l_resp_code
              , io_split_hash_tab => io_split_hash_tab
              , io_inst_id_tab    => io_inst_id_tab
            );

            g_participants(com_api_const_pkg.PARTICIPANT_ACQUIRER) := l_acquirer;
        end if;

        if io_oper.destination_exists = com_api_const_pkg.TRUE then
            l_dest.client_id_type   := io_oper.destination_client_id_type;
            l_dest.client_id_value  := io_oper.destination_client_id_value;
            l_dest.inst_id          := nvl(io_oper.destination_inst_id, io_oper.default_inst_id);
            l_dest.network_id       := io_oper.destination_network_id;
            l_dest.auth_code        := io_oper.destination_auth_code;
            l_dest.card_number      := io_oper.destination_card_number;
            l_dest.card_id          := io_oper.destination_card_id;
            l_dest.card_seq_number  := io_oper.destination_card_seq_number;
            l_dest.card_expir_date  := io_oper.destination_card_expir_date;
            l_dest.account_amount   := io_oper.destination_account_amount;
            l_dest.account_currency := io_oper.destination_account_currency;
            l_dest.account_number   := io_oper.destination_account_number;

            register_participant(
                io_participant    => l_dest
              , io_oper           => io_oper
              , io_resp_code      => l_resp_code
              , io_split_hash_tab => io_split_hash_tab
              , io_inst_id_tab    => io_inst_id_tab
            );

            g_participants(com_api_const_pkg.PARTICIPANT_DEST) := l_dest;
        end if;

        if io_oper.aggregator_exists = com_api_const_pkg.TRUE then
            l_agg.client_id_type   := io_oper.aggregator_client_id_type;
            l_agg.client_id_value  := io_oper.aggregator_client_id_value;
            l_agg.inst_id          := nvl(io_oper.aggregator_inst_id, io_oper.default_inst_id);
            l_agg.network_id       := io_oper.aggregator_network_id;
            l_agg.auth_code        := io_oper.aggregator_auth_code;
            l_agg.card_number      := io_oper.aggregator_card_number;
            l_agg.card_seq_number  := io_oper.aggregator_card_seq_number;
            l_agg.card_expir_date  := io_oper.aggregator_card_expir_date;
            l_agg.account_amount   := io_oper.aggregator_account_amount;
            l_agg.account_currency := io_oper.aggregator_account_currency;
            l_agg.account_number   := io_oper.aggregator_account_number;

            register_participant(
                io_participant    => l_agg
              , io_oper           => io_oper
              , io_resp_code      => l_resp_code
              , io_split_hash_tab => io_split_hash_tab
              , io_inst_id_tab    => io_inst_id_tab
            );

            g_participants(com_api_const_pkg.PARTICIPANT_AGGREGATOR) := l_agg;
        end if;

        if  io_oper.service_provider_exists = com_api_const_pkg.TRUE
         or l_auth_purpose_id is not null
        then
            if io_oper.service_provider_exists = com_api_const_pkg.TRUE then
                l_srvp.client_id_type   := io_oper.srvp_client_id_type;
                l_srvp.client_id_value  := io_oper.srvp_client_id_value;
                l_srvp.inst_id          := nvl(io_oper.srvp_inst_id, io_oper.default_inst_id);
                l_srvp.network_id       := io_oper.srvp_network_id;
                l_srvp.auth_code        := io_oper.srvp_auth_code;
                l_srvp.card_number      := io_oper.srvp_card_number;
                l_srvp.card_seq_number  := io_oper.srvp_card_seq_number;
                l_srvp.card_expir_date  := io_oper.srvp_card_expir_date;
                l_srvp.account_amount   := io_oper.srvp_account_amount;
                l_srvp.account_currency := io_oper.srvp_account_currency;
            end if;

            if io_oper.srvp_account_number is not null then
                l_srvp.account_number   := io_oper.srvp_account_number;

            elsif l_srvp.client_id_type  is not null
              and l_srvp.client_id_value is not null
            then
                begin
                    if l_srvp.customer_id is null then
                        prd_api_customer_pkg.find_customer(
                            i_client_id_type    => l_srvp.client_id_type
                          , i_client_id_value   => l_srvp.client_id_value
                          , i_inst_id           => l_srvp.inst_id
                          , i_raise_error       => com_api_const_pkg.FALSE
                          , i_error_value       => null
                          , o_customer_id       => l_srvp.customer_id
                          , o_split_hash        => l_srvp.split_hash
                          , o_inst_id           => l_inst_id
                          , o_iss_network_id    => l_iss_network_id
                        );
                    end if;

                    if l_srvp.customer_id is not null then
                        select a.account_number
                             , a.currency
                             , a.id
                             , a.account_type
                          into l_srvp.account_number
                             , l_srvp.account_currency
                             , l_srvp.account_id
                             , l_srvp.account_type
                          from acc_account a
                         where a.customer_id  = l_srvp.customer_id
                           and a.status      != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
                           and rownum         = 1;
                    end if;
                exception
                    when no_data_found then
                        trc_log_pkg.error(
                            i_text        => 'CUSTOMER_ACCOUNT_NOT_FOUND'
                          , i_env_param1  => l_srvp.customer_id
                        );

                        l_is_error := com_api_const_pkg.TRUE;
                end;
            end if;

            if l_srvp.client_id_type       is not null
                and l_srvp.client_id_value is not null
                and l_srvp.inst_id         is not null
            then
                trc_log_pkg.debug(
                    i_text          => 'participant_service_provider service_provider_exists [#1], l_auth_purpose_id [#2], l_srvp.customer_id [#3], l_srvp.inst_id [#4], l_srvp.account_id [#5], client_id_value [#6]'
                  , i_env_param1    => io_oper.service_provider_exists
                  , i_env_param2    => l_auth_purpose_id
                  , i_env_param3    => l_srvp.customer_id
                  , i_env_param4    => l_srvp.inst_id
                  , i_env_param5    => l_srvp.account_id
                  , i_env_param6    => l_srvp.client_id_type || '/' || l_srvp.client_id_value
                );

                register_participant(
                    io_participant    => l_srvp
                  , io_oper           => io_oper
                  , io_resp_code      => l_resp_code
                  , io_split_hash_tab => io_split_hash_tab
                  , io_inst_id_tab    => io_inst_id_tab
                );

                g_participants(com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER) := l_srvp;
            elsif l_srvp.client_id_type    is null
                or l_srvp.client_id_value  is null
                or l_srvp.inst_id          is null
            then
                if opr_api_create_pkg.participant_needed(
                       i_participant_type  => l_srvp.participant_type
                     , i_oper_type         => io_oper.oper_type
                     , i_oper_reason       => io_oper.oper_reason
                   ) = com_api_const_pkg.TRUE
                then
                    trc_log_pkg.warn(
                        i_text       => 'NOT_ENOUGH_PARAMETERS_FOR_PARTICIPANT'
                      , i_env_param1 => com_api_dictionary_pkg.get_article_text(i_article => com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER)
                      , i_env_param2 => l_srvp.client_id_type
                      , i_env_param3 => l_srvp.client_id_value
                      , i_env_param4 => l_srvp.inst_id
                      , i_env_param5 => l_auth_purpose_id
                    );
                end if;
            end if;
        end if;

        if io_oper.sttl_type is null then
            begin
                select iss.inst_id
                     , iss.card_inst_id
                     , iss.network_id
                     , iss.card_network_id
                     , acq.inst_id
                     , acq.network_id
                  into l_issuer.inst_id
                     , l_issuer.card_inst_id
                     , l_issuer.network_id
                     , l_issuer.card_network_id
                     , l_acquirer.inst_id
                     , l_acquirer.network_id
                  from opr_participant iss
                     , opr_participant acq
                 where iss.oper_id = io_oper.oper_id
                   and acq.oper_id = io_oper.oper_id
                   and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                   and acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER;

                net_api_sttl_pkg.get_sttl_type(
                    i_iss_inst_id         => l_issuer.inst_id
                  , i_acq_inst_id         => l_acquirer.inst_id
                  , i_card_inst_id        => l_issuer.card_inst_id
                  , i_iss_network_id      => l_issuer.network_id
                  , i_acq_network_id      => l_acquirer.network_id
                  , i_card_network_id     => l_issuer.card_network_id
                  , i_acq_inst_bin        => io_oper.acq_inst_bin
                  , o_sttl_type           => io_oper.sttl_type
                  , o_match_status        => l_match_status
                  , i_oper_type           => io_oper.oper_type
                );

                if l_status = opr_api_const_pkg.OPERATION_STATUS_DUPLICATE then
                    l_match_status := opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH;
                end if;

            exception
                when no_data_found then
                    null;
                when com_api_error_pkg.e_application_error then
                    l_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;
            end;
        end if;

        if  l_status = opr_api_const_pkg.OPERATION_STATUS_DUPLICATE
            and (
                l_match_status is null
                or
                l_match_status != opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH
            )
        then
            l_match_status := opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH;
        end if;

        if io_oper.participant is not null then
            register_custom_participants(
                io_oper            => io_oper
              , io_resp_code       => l_resp_code
              , i_import_clear_pan => nvl(i_import_clear_pan, com_api_const_pkg.TRUE)
              , io_split_hash_tab  => io_split_hash_tab
              , io_inst_id_tab     => io_inst_id_tab
            );
        end if;

        if io_oper.note is not null then
            register_notes(
                io_notes        => io_oper.note
              , i_oper_id       => io_oper.oper_id
            );
        end if;

        if io_oper.auth_data is not null
           or io_auth_data_rec.external_auth_id is not null
        then
            register_auth_data(
                io_auth_data_rec        => io_auth_data_rec
              , io_auth_tag_tab         => io_auth_tag_tab
              , io_auth_data            => io_oper.auth_data
              , i_oper_id               => io_oper.oper_id
              , i_import_clear_pan      => nvl(i_import_clear_pan, com_api_const_pkg.TRUE)
              , o_auth_resp_code        => l_auth_resp_code
              , o_auth_acq_resp_code    => l_auth_acq_resp_code
              , io_is_error             => l_is_error
              , i_use_auth_data_rec     => i_use_auth_data_rec
              , i_original_id           => l_original_id
              , i_msg_type              => io_oper.msg_type
            );
        end if;

        if io_oper.ipm_data is not null then
            register_ipm_data(
                io_ipm_data     => io_oper.ipm_data
              , i_oper_id       => io_oper.oper_id
            );
        end if;

        if io_oper.baseii_data is not null then
            register_baseii_data(
                io_baseii_data  => io_oper.baseii_data
              , i_oper_id       => io_oper.oper_id
            );
        end if;

        if io_oper.additional_amount is not null then
            register_additional_amount(
                io_addl_amounts => io_oper.additional_amount
              , i_oper_id       => io_oper.oper_id
            );
        end if;

        if io_oper.processing_stage is not null then
            register_processing_stage(
                i_processing_stage => io_oper.processing_stage
              , i_oper             => io_oper
              , io_is_error        => l_is_error
            );
        end if;

        if io_oper.flexible_data is not null then
            register_flexible_data(
                io_flexible_data => io_oper.flexible_data
              , i_oper_id        => io_oper.oper_id
            );
        end if;

        if l_is_error = com_api_const_pkg.TRUE then
            l_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;
        end if;

    exception
        when com_api_error_pkg.e_application_error then
            l_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;

    end;

    -- For all errors which is included in common block "begin/end".

    if l_resp_code    = aup_api_const_pkg.RESP_CODE_OPERATION_DUPLICATED then
        l_status     := opr_api_const_pkg.OPERATION_STATUS_DUPLICATE;

    elsif l_resp_code = aup_api_const_pkg.RESP_CODE_ERROR then
        l_status     := opr_api_const_pkg.OPERATION_STATUS_MANUAL;

    end if;

    opr_api_create_pkg.create_operation(
        io_oper_id                  => io_oper.oper_id
      , i_session_id                => get_session_id
      , i_is_reversal               => nvl(io_oper.is_reversal, 0)
      , i_original_id               => l_original_id
      , i_oper_type                 => io_oper.oper_type
      , i_oper_reason               => io_oper.oper_reason
      , i_msg_type                  => io_oper.msg_type
      , i_status                    => l_status
      , i_status_reason             => io_oper.status_reason
      , i_sttl_type                 => io_oper.sttl_type
      , i_terminal_type             => io_oper.terminal_type
      , i_merchant_number           => io_oper.merchant_number
      , i_terminal_number           => io_oper.terminal_number
      , i_merchant_name             => io_oper.merchant_name
      , i_merchant_street           => io_oper.merchant_street
      , i_merchant_city             => io_oper.merchant_city
      , i_merchant_country          => io_oper.merchant_country
      , i_merchant_region           => io_oper.merchant_region
      , i_merchant_postcode         => io_oper.merchant_postcode
      , i_mcc                       => io_oper.mcc
      , i_acq_inst_bin              => io_oper.acq_inst_bin
      , i_forw_inst_bin             => io_oper.forw_inst_bin
      , i_originator_refnum         => io_oper.originator_refnum
      , i_network_refnum            => io_oper.network_refnum
      , i_oper_count                => io_oper.oper_count
      , i_oper_request_amount       => io_oper.oper_request_amount_value
      , i_oper_amount               => io_oper.oper_amount_value
      , i_oper_surcharge_amount     => io_oper.oper_surcharge_amount_value
      , i_oper_cashback_amount      => io_oper.oper_cashback_amount_value
      , i_oper_currency             => nvl(io_oper.oper_amount_currency, io_oper.oper_request_amount_currency)
      , i_sttl_amount               => io_oper.sttl_amount_value
      , i_sttl_currency             => io_oper.sttl_amount_currency
      , i_oper_date                 => io_oper.oper_date
      , i_host_date                 => io_oper.host_date
      , i_match_status              => l_match_status
      , i_payment_order_id          => io_oper.payment_order_id
      , i_incom_sess_file_id        => io_oper.incom_sess_file_id
      , i_fee_amount                => io_oper.interchange_fee_value
      , i_fee_currency              => io_oper.interchange_fee_currency
      , i_dispute_id                => io_oper.dispute_id
      , i_sttl_date                 => nvl(io_oper.sttl_date, i_sttl_date)
      , i_acq_sttl_date             => io_oper.acq_sttl_date
    );

    rul_api_shared_data_pkg.save_oper_params(
        io_params              => io_event_params
      , i_msg_type             => io_oper.msg_type
      , i_oper_type            => io_oper.oper_type
      , i_sttl_type            => io_oper.sttl_type
      , i_status               => io_oper.status
      , i_status_reason        => io_oper.status_reason
      , i_terminal_type        => io_oper.terminal_type
      , i_mcc                  => io_oper.mcc
      , i_oper_currency        => io_oper.oper_amount_currency
      , i_is_reversal          => io_oper.is_reversal
      , i_iss_card_network_id  => l_issuer.card_network_id
      , i_match_status         => io_oper.match_status
      , i_merchant_number      => io_oper.merchant_number
      , i_auth_resp_code       => l_auth_resp_code
      , i_acq_resp_code        => l_auth_acq_resp_code
      , i_payment_order_id     => io_oper.payment_order_id
    );

    return l_resp_code;

exception
    when com_api_error_pkg.e_application_error then

        -- Only when error in last methods "opr_api_create_pkg.create_operation" or "rul_api_shared_data_pkg.save_oper_params"
        -- which is not included in common block "begin/end".
        if l_resp_code    = aup_api_const_pkg.RESP_CODE_OPERATION_DUPLICATED then
            l_status     := opr_api_const_pkg.OPERATION_STATUS_DUPLICATE;
        else
            l_status     := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
        end if;

        update opr_operation
           set status = l_status
          where id = io_oper.oper_id
            and status not in (
                    opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL
                  , opr_api_const_pkg.OPERATION_STATUS_DONT_PROCESS
                );

        if sql%rowcount > 0 then
            trc_log_pkg.error(
                i_text          => 'OPERATION_FREEZED'
              , i_env_param1    => io_oper.originator_refnum
            );
        end if;

        return aup_api_const_pkg.RESP_CODE_ERROR;

end register_operation;

procedure before_register_batch(
    i_session_id            in      com_api_type_pkg.t_long_id
  , i_thread_number         in      com_api_type_pkg.t_tiny_id
  , i_container_id          in      com_api_type_pkg.t_short_id
  , i_process_id            in      com_api_type_pkg.t_short_id
  , i_oracle_trace_level    in      com_api_type_pkg.t_tiny_id
  , i_trace_thread_number   in      com_api_type_pkg.t_tiny_id
) is
begin
    trc_log_pkg.debug(
        i_text       => 'before_register_batch: i_session_id [#1], i_thread_number [#2], i_container_id [#3], i_process_id [#4], i_oracle_trace_level [#5], i_trace_thread_number [#6]'
      , i_env_param1 => i_session_id
      , i_env_param2 => i_thread_number
      , i_env_param3 => i_container_id
      , i_env_param4 => i_process_id
      , i_env_param5 => i_oracle_trace_level
      , i_env_param6 => i_trace_thread_number
    );

    prc_api_session_pkg.set_thread_number(
        i_thread_number => i_thread_number
    );

    prc_api_session_pkg.set_container_id(
        i_container_id  => i_container_id
    );

    prc_api_session_pkg.set_process_id(
        i_process_id    => i_process_id
    );

    trc_ora_trace_pkg.check_tracing_on_start(
        i_oracle_trace_level  => i_oracle_trace_level
      , i_thread_number       => i_thread_number
      , i_trace_thread_number => i_trace_thread_number
    );

    prc_api_session_pkg.set_client_info(
        i_session_id    => i_session_id
      , i_thread_number => i_thread_number
      , i_container_id  => i_container_id
      , i_process_id    => i_process_id
    );

end before_register_batch;

procedure after_register_batch(
    i_session_id            in      com_api_type_pkg.t_long_id
  , i_thread_number         in      com_api_type_pkg.t_tiny_id
) is
begin
    trc_log_pkg.debug(
        i_text       => 'after_register_batch: i_session_id [#1], i_thread_number [#2]'
      , i_env_param1 => i_session_id
      , i_env_param2 => i_thread_number
    );

    trc_ora_trace_pkg.disable_trace(
        i_trace_current_session => com_api_const_pkg.TRUE
    );

    prc_api_session_pkg.reset_client_info;

end after_register_batch;

-- Obsolete and do not used. SVFE processes are moved into itf_prc_import_pkg.
procedure register_operation_batch(
    i_oper_tab              in          oper_clearing_tpt
  , i_auth_data_tab         in          auth_data_tpt
  , i_auth_tag_tab          in          auth_tag_tpt
  , i_import_clear_pan      in          com_api_type_pkg.t_boolean
  , i_oper_status           in          com_api_type_pkg.t_dict_value       default opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
  , i_sttl_date             in          date
  , i_without_checks        in          com_api_type_pkg.t_boolean          default null
) is
    l_estimated_count       com_api_type_pkg.t_long_id    := 0;
    l_processed_count       com_api_type_pkg.t_long_id    := 0;
    l_excepted_count        com_api_type_pkg.t_long_id    := 0;
    l_rejected_count        com_api_type_pkg.t_long_id    := 0;

    l_event_params          com_api_type_pkg.t_param_tab;

    l_oper_status           com_api_type_pkg.t_dict_value;
    l_oper_rec              opr_prc_import_pkg.t_oper_clearing_rec;
    l_auth_data_rec         aut_api_type_pkg.t_auth_rec;
    l_auth_tag_tab          aut_api_type_pkg.t_auth_tag_tab;
    l_auth_data_index       com_api_type_pkg.t_long_id    := 1;
    l_auth_tag_index        com_api_type_pkg.t_long_id    := 1;

    l_resp_code             com_api_type_pkg.t_dict_value;
    l_multi_institution     com_api_type_pkg.t_boolean;
    l_sttl_date             date;
    l_result_code           com_api_type_pkg.t_dict_value;
    l_split_hash_tab        com_api_type_pkg.t_tiny_tab;
    l_inst_id_tab           com_api_type_pkg.t_inst_id_tab;

    l_session_id            com_api_type_pkg.t_long_id;
    l_thread_number         com_api_type_pkg.t_tiny_id;
    l_session_file_id       com_api_type_pkg.t_long_id;
begin
    savepoint register_operation_batch_start;

    trc_log_pkg.debug(
        i_text          => 'Register operation batch started'
    );

    trc_log_pkg.debug(
        i_text          => 'Size: i_oper_tab.count [#1], i_auth_data_tab.count [#2], i_auth_tag_tab.count [#3]'
      , i_env_param1    => i_oper_tab.count
      , i_env_param2    => i_auth_data_tab.count
      , i_env_param3    => i_auth_tag_tab.count
    );

    l_session_id       := prc_api_session_pkg.get_session_id;
    l_thread_number    := prc_api_session_pkg.get_thread_number;
    l_session_file_id  := prc_api_file_pkg.get_session_file_id;

    g_operations.delete;

    begin
        select nvl(estimated_count, 0)
             , nvl(processed_total, 0)
             , nvl(excepted_total,  0)
             , nvl(rejected_total,  0)
          into l_estimated_count
             , l_processed_count
             , l_excepted_count
             , l_rejected_count
          from prc_stat
         where session_id    = l_session_id
           and thread_number = l_thread_number;

    exception when no_data_found then
        prc_api_stat_pkg.log_start;

    end;

    trc_log_pkg.debug(
        i_text          => 'Previous values: l_estimated_count [#1] l_processed_count [#2] l_excepted_count [#3] l_rejected_count [#4]'
      , i_env_param1    => l_estimated_count
      , i_env_param2    => l_processed_count
      , i_env_param3    => l_excepted_count
      , i_env_param4    => l_rejected_count
    );

    l_estimated_count := i_oper_tab.count + l_estimated_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
      , i_measure         => opr_api_const_pkg.ENTITY_TYPE_OPERATION
    );

    trc_log_pkg.debug(
        i_text          => 'l_estimated_count [#1]'
      , i_env_param1    => l_estimated_count
    );

    if l_estimated_count > 0 then

        l_oper_status := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;

        -- get sttl_date for operations
        l_multi_institution := set_ui_value_pkg.get_system_param_n('MULTI_INSTITUTION');

        if l_multi_institution = com_api_const_pkg.FALSE then
            l_sttl_date := com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => ost_api_const_pkg.DEFAULT_INST);
        else
            l_sttl_date := null;
        end if;

        trc_log_pkg.debug(
            i_text      => 'l_sttl_date = ' || l_sttl_date
        );

        for i in 1 .. i_oper_tab.count loop

            l_processed_count := l_processed_count + 1;

            l_oper_rec.oper_id                          := i_oper_tab(i).oper_id;
            l_oper_rec.default_inst_id                  := i_oper_tab(i).default_inst_id;
            l_oper_rec.oper_type                        := i_oper_tab(i).oper_type;
            l_oper_rec.msg_type                         := i_oper_tab(i).msg_type;
            l_oper_rec.sttl_type                        := i_oper_tab(i).sttl_type;
            l_oper_rec.recon_type                       := i_oper_tab(i).recon_type;
            l_oper_rec.oper_date                        := i_oper_tab(i).oper_date;
            l_oper_rec.host_date                        := i_oper_tab(i).host_date;
            l_oper_rec.oper_count                       := i_oper_tab(i).oper_count;
            l_oper_rec.oper_amount_value                := i_oper_tab(i).oper_amount_value;
            l_oper_rec.oper_amount_currency             := i_oper_tab(i).oper_amount_currency;
            l_oper_rec.oper_request_amount_value        := i_oper_tab(i).oper_request_amount_value;
            l_oper_rec.oper_request_amount_currency     := i_oper_tab(i).oper_request_amount_currency;
            l_oper_rec.oper_surcharge_amount_value      := i_oper_tab(i).oper_surcharge_amount_value;
            l_oper_rec.oper_surcharge_amount_currency   := i_oper_tab(i).oper_surcharge_amount_currency;
            l_oper_rec.oper_cashback_amount_value       := i_oper_tab(i).oper_cashback_amount_value;
            l_oper_rec.oper_cashback_amount_currency    := i_oper_tab(i).oper_cashback_amount_currency;
            l_oper_rec.sttl_amount_value                := i_oper_tab(i).sttl_amount_value;
            l_oper_rec.sttl_amount_currency             := i_oper_tab(i).sttl_amount_currency;
            l_oper_rec.interchange_fee_value            := i_oper_tab(i).interchange_fee_value;
            l_oper_rec.interchange_fee_currency         := i_oper_tab(i).interchange_fee_currency;
            l_oper_rec.oper_reason                      := i_oper_tab(i).oper_reason;
            l_oper_rec.status                           := i_oper_tab(i).status;
            l_oper_rec.status_reason                    := i_oper_tab(i).status_reason;
            l_oper_rec.is_reversal                      := i_oper_tab(i).is_reversal;
            l_oper_rec.originator_refnum                := i_oper_tab(i).originator_refnum;
            l_oper_rec.network_refnum                   := i_oper_tab(i).network_refnum;
            l_oper_rec.acq_inst_bin                     := i_oper_tab(i).acq_inst_bin;
            l_oper_rec.forw_inst_bin                    := i_oper_tab(i).forw_inst_bin;
            l_oper_rec.merchant_number                  := i_oper_tab(i).merchant_number;
            l_oper_rec.mcc                              := i_oper_tab(i).mcc;
            l_oper_rec.merchant_name                    := i_oper_tab(i).merchant_name;
            l_oper_rec.merchant_street                  := i_oper_tab(i).merchant_street;
            l_oper_rec.merchant_city                    := i_oper_tab(i).merchant_city;
            l_oper_rec.merchant_region                  := i_oper_tab(i).merchant_region;
            l_oper_rec.merchant_country                 := i_oper_tab(i).merchant_country;
            l_oper_rec.merchant_postcode                := i_oper_tab(i).merchant_postcode;
            l_oper_rec.terminal_type                    := i_oper_tab(i).terminal_type;
            l_oper_rec.terminal_number                  := i_oper_tab(i).terminal_number;
            l_oper_rec.sttl_date                        := i_oper_tab(i).sttl_date;
            l_oper_rec.acq_sttl_date                    := i_oper_tab(i).acq_sttl_date;

            l_oper_rec.dispute_id                       := i_oper_tab(i).dispute_id;

            l_oper_rec.payment_order_id                 := i_oper_tab(i).payment_order_id;
            l_oper_rec.payment_order_status             := i_oper_tab(i).payment_order_status;
            l_oper_rec.payment_order_number             := i_oper_tab(i).payment_order_number;
            l_oper_rec.purpose_id                       := i_oper_tab(i).purpose_id;
            l_oper_rec.purpose_number                   := i_oper_tab(i).purpose_number;
            l_oper_rec.payment_order_amount             := i_oper_tab(i).payment_order_amount;
            l_oper_rec.payment_order_currency           := i_oper_tab(i).payment_order_currency;
            l_oper_rec.payment_order_prty_type          := i_oper_tab(i).payment_order_prty_type;

            if i_oper_tab(i).payment_parameters is not null then
                l_oper_rec.payment_parameters           := xmltype(i_oper_tab(i).payment_parameters);
            end if;

            l_oper_rec.issuer_client_id_type            := i_oper_tab(i).issuer_client_id_type;
            l_oper_rec.issuer_client_id_value           := i_oper_tab(i).issuer_client_id_value;
            l_oper_rec.issuer_card_number               := i_oper_tab(i).issuer_card_number;
            l_oper_rec.issuer_card_id                   := i_oper_tab(i).issuer_card_id;
            l_oper_rec.issuer_card_seq_number           := i_oper_tab(i).issuer_card_seq_number;
            l_oper_rec.issuer_card_expir_date           := i_oper_tab(i).issuer_card_expir_date;
            l_oper_rec.issuer_inst_id                   := i_oper_tab(i).issuer_inst_id;
            l_oper_rec.issuer_network_id                := i_oper_tab(i).issuer_network_id;
            l_oper_rec.issuer_auth_code                 := i_oper_tab(i).issuer_auth_code;
            l_oper_rec.issuer_account_amount            := i_oper_tab(i).issuer_account_amount;
            l_oper_rec.issuer_account_currency          := i_oper_tab(i).issuer_account_currency;
            l_oper_rec.issuer_account_number            := i_oper_tab(i).issuer_account_number;

            l_oper_rec.acquirer_client_id_type          := i_oper_tab(i).acquirer_client_id_type;
            l_oper_rec.acquirer_client_id_value         := i_oper_tab(i).acquirer_client_id_value;
            l_oper_rec.acquirer_card_number             := i_oper_tab(i).acquirer_card_number;
            l_oper_rec.acquirer_card_seq_number         := i_oper_tab(i).acquirer_card_seq_number;
            l_oper_rec.acquirer_card_expir_date         := i_oper_tab(i).acquirer_card_expir_date;
            l_oper_rec.acquirer_inst_id                 := i_oper_tab(i).acquirer_inst_id;
            l_oper_rec.acquirer_network_id              := i_oper_tab(i).acquirer_network_id;
            l_oper_rec.acquirer_auth_code               := i_oper_tab(i).acquirer_auth_code;
            l_oper_rec.acquirer_account_amount          := i_oper_tab(i).acquirer_account_amount;
            l_oper_rec.acquirer_account_currency        := i_oper_tab(i).acquirer_account_currency;
            l_oper_rec.acquirer_account_number          := i_oper_tab(i).acquirer_account_number;

            l_oper_rec.destination_client_id_type       := i_oper_tab(i).destination_client_id_type;
            l_oper_rec.destination_client_id_value      := i_oper_tab(i).destination_client_id_value;
            l_oper_rec.destination_card_number          := i_oper_tab(i).destination_card_number;
            l_oper_rec.destination_card_id              := i_oper_tab(i).destination_card_id;
            l_oper_rec.destination_card_seq_number      := i_oper_tab(i).destination_card_seq_number;
            l_oper_rec.destination_card_expir_date      := i_oper_tab(i).destination_card_expir_date;
            l_oper_rec.destination_inst_id              := i_oper_tab(i).destination_inst_id;
            l_oper_rec.destination_network_id           := i_oper_tab(i).destination_network_id;
            l_oper_rec.destination_auth_code            := i_oper_tab(i).destination_auth_code;
            l_oper_rec.destination_account_amount       := i_oper_tab(i).destination_account_amount;
            l_oper_rec.destination_account_currency     := i_oper_tab(i).destination_account_currency;
            l_oper_rec.destination_account_number       := i_oper_tab(i).destination_account_number;

            l_oper_rec.aggregator_client_id_type        := i_oper_tab(i).aggregator_client_id_type;
            l_oper_rec.aggregator_client_id_value       := i_oper_tab(i).aggregator_client_id_value;
            l_oper_rec.aggregator_card_number           := i_oper_tab(i).aggregator_card_number;
            l_oper_rec.aggregator_card_seq_number       := i_oper_tab(i).aggregator_card_seq_number;
            l_oper_rec.aggregator_card_expir_date       := i_oper_tab(i).aggregator_card_expir_date;
            l_oper_rec.aggregator_inst_id               := i_oper_tab(i).aggregator_inst_id;
            l_oper_rec.aggregator_network_id            := i_oper_tab(i).aggregator_network_id;
            l_oper_rec.aggregator_auth_code             := i_oper_tab(i).aggregator_auth_code;
            l_oper_rec.aggregator_account_amount        := i_oper_tab(i).aggregator_account_amount;
            l_oper_rec.aggregator_account_currency      := i_oper_tab(i).aggregator_account_currency;
            l_oper_rec.aggregator_account_number        := i_oper_tab(i).aggregator_account_number;

            l_oper_rec.srvp_client_id_type              := i_oper_tab(i).srvp_client_id_type;
            l_oper_rec.srvp_client_id_value             := i_oper_tab(i).srvp_client_id_value;
            l_oper_rec.srvp_card_number                 := i_oper_tab(i).srvp_card_number;
            l_oper_rec.srvp_card_seq_number             := i_oper_tab(i).srvp_card_seq_number;
            l_oper_rec.srvp_card_expir_date             := i_oper_tab(i).srvp_card_expir_date;
            l_oper_rec.srvp_inst_id                     := i_oper_tab(i).srvp_inst_id;
            l_oper_rec.srvp_network_id                  := i_oper_tab(i).srvp_network_id;
            l_oper_rec.srvp_auth_code                   := i_oper_tab(i).srvp_auth_code;
            l_oper_rec.srvp_account_amount              := i_oper_tab(i).srvp_account_amount;
            l_oper_rec.srvp_account_currency            := i_oper_tab(i).srvp_account_currency;
            l_oper_rec.srvp_account_number              := i_oper_tab(i).srvp_account_number;

            if i_oper_tab(i).participant is not null then
                l_oper_rec.participant                  := xmltype(i_oper_tab(i).participant);
            end if;

            l_oper_rec.payment_order_exists             := i_oper_tab(i).payment_order_exists;
            l_oper_rec.issuer_exists                    := i_oper_tab(i).issuer_exists;
            l_oper_rec.acquirer_exists                  := i_oper_tab(i).acquirer_exists;
            l_oper_rec.destination_exists               := i_oper_tab(i).destination_exists;
            l_oper_rec.aggregator_exists                := i_oper_tab(i).aggregator_exists;
            l_oper_rec.service_provider_exists          := i_oper_tab(i).service_provider_exists;
            l_oper_rec.incom_sess_file_id               := nvl(i_oper_tab(i).incom_sess_file_id, l_session_file_id);

            if i_oper_tab(i).note is not null then
                l_oper_rec.note                         := xmltype(i_oper_tab(i).note);
            end if;

            while i_auth_data_tab(l_auth_data_index).oper_id = i_oper_tab(i).oper_id_batch loop

                l_auth_data_rec.resp_code                 := i_auth_data_tab(l_auth_data_index).resp_code;
                l_auth_data_rec.proc_type                 := i_auth_data_tab(l_auth_data_index).proc_type;
                l_auth_data_rec.proc_mode                 := i_auth_data_tab(l_auth_data_index).proc_mode;
                l_auth_data_rec.is_advice                 := i_auth_data_tab(l_auth_data_index).is_advice;
                l_auth_data_rec.is_repeat                 := i_auth_data_tab(l_auth_data_index).is_repeat;
                l_auth_data_rec.bin_amount                := i_auth_data_tab(l_auth_data_index).bin_amount;
                l_auth_data_rec.bin_currency              := i_auth_data_tab(l_auth_data_index).bin_currency;
                l_auth_data_rec.bin_cnvt_rate             := i_auth_data_tab(l_auth_data_index).bin_cnvt_rate;
                l_auth_data_rec.network_amount            := i_auth_data_tab(l_auth_data_index).network_amount;
                l_auth_data_rec.network_currency          := i_auth_data_tab(l_auth_data_index).network_currency;
                l_auth_data_rec.network_cnvt_date         := to_date(i_auth_data_tab(l_auth_data_index).network_cnvt_date, com_api_const_pkg.XML_DATETIME_FORMAT);
                l_auth_data_rec.network_cnvt_rate         := i_auth_data_tab(l_auth_data_index).network_cnvt_rate;
                l_auth_data_rec.account_cnvt_rate         := i_auth_data_tab(l_auth_data_index).account_cnvt_rate;
                l_auth_data_rec.addr_verif_result         := i_auth_data_tab(l_auth_data_index).addr_verif_result;
                l_auth_data_rec.acq_resp_code             := i_auth_data_tab(l_auth_data_index).acq_resp_code;
                l_auth_data_rec.acq_device_proc_result    := i_auth_data_tab(l_auth_data_index).acq_device_proc_result;
                l_auth_data_rec.cat_level                 := i_auth_data_tab(l_auth_data_index).cat_level;
                l_auth_data_rec.card_data_input_cap       := i_auth_data_tab(l_auth_data_index).card_data_input_cap;
                l_auth_data_rec.crdh_auth_cap             := i_auth_data_tab(l_auth_data_index).crdh_auth_cap;
                l_auth_data_rec.card_capture_cap          := i_auth_data_tab(l_auth_data_index).card_capture_cap;
                l_auth_data_rec.terminal_operating_env    := i_auth_data_tab(l_auth_data_index).terminal_operating_env;
                l_auth_data_rec.crdh_presence             := i_auth_data_tab(l_auth_data_index).crdh_presence;
                l_auth_data_rec.card_presence             := i_auth_data_tab(l_auth_data_index).card_presence;
                l_auth_data_rec.card_data_input_mode      := i_auth_data_tab(l_auth_data_index).card_data_input_mode;
                l_auth_data_rec.crdh_auth_method          := i_auth_data_tab(l_auth_data_index).crdh_auth_method;
                l_auth_data_rec.crdh_auth_entity          := i_auth_data_tab(l_auth_data_index).crdh_auth_entity;
                l_auth_data_rec.card_data_output_cap      := i_auth_data_tab(l_auth_data_index).card_data_output_cap;
                l_auth_data_rec.terminal_output_cap       := i_auth_data_tab(l_auth_data_index).terminal_output_cap;
                l_auth_data_rec.pin_capture_cap           := i_auth_data_tab(l_auth_data_index).pin_capture_cap;
                l_auth_data_rec.pin_presence              := i_auth_data_tab(l_auth_data_index).pin_presence;
                l_auth_data_rec.cvv2_presence             := i_auth_data_tab(l_auth_data_index).cvv2_presence;
                l_auth_data_rec.cvc_indicator             := i_auth_data_tab(l_auth_data_index).cvc_indicator;
                l_auth_data_rec.pos_entry_mode            := i_auth_data_tab(l_auth_data_index).pos_entry_mode;
                l_auth_data_rec.pos_cond_code             := i_auth_data_tab(l_auth_data_index).pos_cond_code;
                l_auth_data_rec.emv_data                  := i_auth_data_tab(l_auth_data_index).emv_data;
                l_auth_data_rec.atc                       := i_auth_data_tab(l_auth_data_index).atc;
                l_auth_data_rec.tvr                       := i_auth_data_tab(l_auth_data_index).tvr;
                l_auth_data_rec.cvr                       := i_auth_data_tab(l_auth_data_index).cvr;
                l_auth_data_rec.addl_data                 := i_auth_data_tab(l_auth_data_index).addl_data;
                l_auth_data_rec.service_code              := i_auth_data_tab(l_auth_data_index).service_code;
                l_auth_data_rec.device_date               := to_date(i_auth_data_tab(l_auth_data_index).device_date, com_api_const_pkg.XML_DATETIME_FORMAT);
                l_auth_data_rec.cvv2_result               := i_auth_data_tab(l_auth_data_index).cvv2_result;
                l_auth_data_rec.certificate_method        := i_auth_data_tab(l_auth_data_index).certificate_method;
                l_auth_data_rec.certificate_type          := i_auth_data_tab(l_auth_data_index).certificate_type;
                l_auth_data_rec.merchant_certif           := i_auth_data_tab(l_auth_data_index).merchant_certif;
                l_auth_data_rec.cardholder_certif         := i_auth_data_tab(l_auth_data_index).cardholder_certif;
                l_auth_data_rec.ucaf_indicator            := i_auth_data_tab(l_auth_data_index).ucaf_indicator;
                l_auth_data_rec.is_early_emv              := i_auth_data_tab(l_auth_data_index).is_early_emv;
                l_auth_data_rec.is_completed              := i_auth_data_tab(l_auth_data_index).is_completed;
                l_auth_data_rec.amounts                   := i_auth_data_tab(l_auth_data_index).amounts;
                l_auth_data_rec.system_trace_audit_number := i_auth_data_tab(l_auth_data_index).system_trace_audit_number;
                l_auth_data_rec.transaction_id            := i_auth_data_tab(l_auth_data_index).transaction_id;
                l_auth_data_rec.external_auth_id          := i_auth_data_tab(l_auth_data_index).external_auth_id;
                l_auth_data_rec.external_orig_id          := i_auth_data_tab(l_auth_data_index).external_orig_id;
                l_auth_data_rec.agent_unique_id           := i_auth_data_tab(l_auth_data_index).agent_unique_id;
                l_auth_data_rec.native_resp_code          := i_auth_data_tab(l_auth_data_index).native_resp_code;
                l_auth_data_rec.trace_number              := i_auth_data_tab(l_auth_data_index).trace_number;
                l_auth_data_rec.auth_purpose_id           := i_auth_data_tab(l_auth_data_index).auth_purpose_id;

                l_auth_data_index := l_auth_data_index + 1;

                exit when l_auth_data_index > i_auth_data_tab.count;
            end loop;

            l_auth_tag_tab.delete;

            while i_auth_tag_tab(l_auth_tag_index).oper_id = i_oper_tab(i).oper_id_batch loop

                l_auth_tag_tab(l_auth_tag_tab.count + 1).tag_id := i_auth_tag_tab(l_auth_tag_index).tag_id;
                l_auth_tag_tab(l_auth_tag_tab.count).tag_value  := i_auth_tag_tab(l_auth_tag_index).tag_value;
                l_auth_tag_tab(l_auth_tag_tab.count).tag_name   := i_auth_tag_tab(l_auth_tag_index).tag_name;

                l_auth_tag_index := l_auth_tag_index + 1;

                exit when l_auth_tag_index > i_auth_tag_tab.count;
            end loop;

            l_oper_rec.external_auth_id         := l_auth_data_rec.external_auth_id;
            l_oper_rec.external_orig_id         := l_auth_data_rec.external_orig_id;
            l_oper_rec.trace_number             := l_auth_data_rec.trace_number;

            if i_oper_tab(i).ipm_data is not null then
                l_oper_rec.ipm_data             := xmltype(i_oper_tab(i).ipm_data);
            end if;

            if i_oper_tab(i).baseii_data is not null then
                l_oper_rec.baseii_data          := xmltype(i_oper_tab(i).baseii_data);
            end if;

            l_oper_rec.match_status             := i_oper_tab(i).match_status;

            if i_oper_tab(i).additional_amount is not null then
                l_oper_rec.additional_amount    := xmltype(i_oper_tab(i).additional_amount);
            end if;

            if i_oper_tab(i).processing_stage is not null then
                l_oper_rec.processing_stage     := xmltype(i_oper_tab(i).processing_stage);
            end if;

            if i_oper_tab(i).flexible_data is not null then
                l_oper_rec.flexible_data        := xmltype(i_oper_tab(i).flexible_data);
            end if;

            l_resp_code := register_operation(
                               io_oper             => l_oper_rec
                             , io_auth_data_rec    => l_auth_data_rec
                             , io_auth_tag_tab     => l_auth_tag_tab
                             , i_import_clear_pan  => nvl(i_import_clear_pan, com_api_const_pkg.TRUE)
                             , i_oper_status       => l_oper_status
                             , i_sttl_date         => l_sttl_date
                             , i_without_checks    => i_without_checks
                             , io_split_hash_tab   => l_split_hash_tab
                             , io_inst_id_tab      => l_inst_id_tab
                             , i_use_auth_data_rec => com_api_const_pkg.TRUE
                             , io_event_params     => l_event_params
                           );

            trc_log_pkg.debug(
                i_text        => 'oper_id [#1] resp_code [#2]'
              , i_env_param1  => l_oper_rec.oper_id
              , i_env_param2  => l_resp_code
            );

            if l_resp_code != aup_api_const_pkg.RESP_CODE_OK then
                if l_resp_code = aup_api_const_pkg.RESP_CODE_OPERATION_DUPLICATED then
                    l_rejected_count := l_rejected_count + 1;
                else
                    l_excepted_count := l_excepted_count + 1;
                end if;
            end if;

            register_events(
                io_oper           => l_oper_rec
              , i_resp_code       => l_resp_code
              , io_split_hash_tab => l_split_hash_tab
              , io_inst_id_tab    => l_inst_id_tab
              , io_event_params   => l_event_params
            );

            l_split_hash_tab.delete;
            l_inst_id_tab.delete;

            trc_log_pkg.clear_object;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current(
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;

        end loop;

    end if;  -- if l_estimated_count > 0

    if g_operations.count > 0 then
        update_total_amount;
    end if;

    if (l_rejected_count > 0 or l_excepted_count > 0) and (l_rejected_count + l_excepted_count) < l_processed_count then
        l_result_code := prc_api_const_pkg.PROCESS_RESULT_REJECTED;
    else
        l_result_code := prc_api_const_pkg.PROCESS_RESULT_SUCCESS;
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => l_result_code
    );

    com_api_sttl_day_pkg.unset_sysdate;

    trc_log_pkg.debug(
        i_text          => 'Last values: l_estimated_count [#1] l_processed_count [#2] l_excepted_count [#3] l_rejected_count [#4]'
      , i_env_param1    => l_estimated_count
      , i_env_param2    => l_processed_count
      , i_env_param3    => l_excepted_count
      , i_env_param4    => l_rejected_count
    );

    trc_log_pkg.debug(
        i_text  => 'Register operation batch finished'
    );

exception
    when others then
        rollback to savepoint register_operation_batch_start;

        com_api_sttl_day_pkg.unset_sysdate;
        trc_log_pkg.clear_object;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        trc_log_pkg.debug(
            i_text          => 'Error: l_estimated_count [#1] l_processed_count [#2] l_excepted_count [#3] l_rejected_count [#4]'
          , i_env_param1    => l_estimated_count
          , i_env_param2    => l_processed_count
          , i_env_param3    => l_excepted_count
          , i_env_param4    => l_rejected_count
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end register_operation_batch;

/*
 * Process for loading operations (posting).
 * @param i_import_clear_pan - if it is FALSE then process expects encoded
 *     PANs (tokens) in incoming file(s) when tokenization is enabled
 *     (this case may take place when Message Bus is capable to handle tokens).
 */
procedure load_operations(
    i_oper_status           in     com_api_type_pkg.t_dict_value default null
  , i_import_clear_pan      in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_splitted_files        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
    l_estimated_count              com_api_type_pkg.t_long_id    := 0;
    l_processed_count              com_api_type_pkg.t_long_id    := 0;
    l_excepted_count               com_api_type_pkg.t_long_id    := 0;
    l_rejected_count               com_api_type_pkg.t_long_id    := 0;

    type t_record_count_tab is table of com_api_type_pkg.t_long_id index by com_api_type_pkg.t_name;
    l_record_count_tab             t_record_count_tab;
    l_current_session_file_id      com_api_type_pkg.t_long_id;

    l_splitted_files               com_api_type_pkg.t_boolean    := com_api_const_pkg.FALSE;
    l_oper_status                  com_api_type_pkg.t_dict_value;
    l_last_originator_refnum       com_api_type_pkg.t_rrn;

    l_event_params                 com_api_type_pkg.t_param_tab;

    l_thread_number                com_api_type_pkg.t_tiny_id;
    l_resp_code                    com_api_type_pkg.t_dict_value;
    l_session_file_id              com_api_type_pkg.t_long_id;
    l_multi_institution            com_api_type_pkg.t_boolean;
    l_sttl_date                    date;
    l_session_id                   com_api_type_pkg.t_long_id;
    l_common_sttl_day              com_api_type_pkg.t_boolean;
    l_fraud_control                com_api_type_pkg.t_boolean;
    l_split_hash_tab               com_api_type_pkg.t_tiny_tab;
    l_inst_id_tab                  com_api_type_pkg.t_inst_id_tab;
    l_auth_data_rec                aut_api_type_pkg.t_auth_rec;
    l_auth_tag_tab                 aut_api_type_pkg.t_auth_tag_tab;
begin
    savepoint read_operations_start;

    trc_log_pkg.debug(
        i_text          => 'Read clearing'
    );

    prc_api_stat_pkg.log_start;

    l_session_id    := get_session_id;
    l_thread_number := get_thread_number;

    if l_thread_number > 0 and i_splitted_files = com_api_const_pkg.TRUE then
        l_splitted_files := com_api_const_pkg.TRUE;
    end if;

    open cur_oper_count(
        i_session_id       => l_session_id
      , i_thread_number    => l_thread_number
      , i_splitted_files   => l_splitted_files
    );

    fetch cur_oper_count into l_estimated_count;
    close cur_oper_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count  => l_estimated_count
      , i_measure          => opr_api_const_pkg.ENTITY_TYPE_OPERATION
    );

    l_oper_status := nvl(i_oper_status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY);

    open cur_operations(
        i_session_id       => l_session_id
      , i_thread_number    => l_thread_number
      , i_import_clear_pan => nvl(i_import_clear_pan, com_api_const_pkg.TRUE)
      , i_splitted_files   => l_splitted_files
    );

    trc_log_pkg.debug(
        i_text          => 'cursor cur_operations opened'
    );

    -- get sttl_date for operations
    l_multi_institution := set_ui_value_pkg.get_system_param_n('MULTI_INSTITUTION');
    l_common_sttl_day   := set_ui_value_pkg.get_system_param_n('COMMON_SETTLEMENT_DAY');
    if l_multi_institution   = com_api_const_pkg.FALSE
       and l_common_sttl_day = com_api_const_pkg.TRUE
    then
        l_sttl_date := com_api_sttl_day_pkg.get_open_sttl_date(ost_api_const_pkg.DEFAULT_INST);
    else
        l_sttl_date := null;
    end if;
    trc_log_pkg.debug(
        i_text          => 'l_sttl_date = ' || l_sttl_date
    );
    -- check if needed fraud control
    select case when count(1) > 0 then 1 else 0 end
      into l_fraud_control
      from opr_proc_stage
     where command is not null;

    trc_log_pkg.debug(
        i_text          => 'l_fraud_control = [' || l_fraud_control || ']'
    );

    loop
        fetch cur_operations bulk collect into l_oper_tab limit 1000;

        for i in 1 .. l_oper_tab.count loop
            savepoint register_operation_start;

            -- Save reference to operation after "savepoint", it's used for fatal error.
            l_last_originator_refnum := l_oper_tab(i).originator_refnum;

            l_processed_count := l_processed_count + 1;
            l_session_file_id := l_oper_tab(i).incom_sess_file_id;

            if not l_record_count_tab.exists(l_session_file_id) then
                l_record_count_tab(l_session_file_id) := 0;
            end if;
            l_record_count_tab(l_session_file_id) := l_record_count_tab(l_session_file_id) + 1;

            if l_oper_tab(i).is_reversal = com_api_const_pkg.TRUE
               and (l_oper_tab(i).issuer_client_id_type is null or
                    l_oper_tab(i).issuer_client_id_value is null)
            then
                l_oper_tab(i).issuer_client_id_value := l_oper_tab(i).issuer_card_number;
                l_oper_tab(i).issuer_client_id_type  := case
                                                            when l_oper_tab(i).issuer_client_id_value is not null
                                                            then opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                                                            else l_oper_tab(i).issuer_client_id_type
                                                        end;
            end if;

            l_resp_code := register_operation(
                               io_oper             => l_oper_tab(i)
                             , io_auth_data_rec    => l_auth_data_rec
                             , io_auth_tag_tab     => l_auth_tag_tab
                             , i_import_clear_pan  => nvl(i_import_clear_pan, com_api_const_pkg.TRUE)
                             , i_oper_status       => l_oper_status
                             , i_sttl_date         => l_sttl_date
                             , i_fraud_control     => l_fraud_control
                             , io_split_hash_tab   => l_split_hash_tab
                             , io_inst_id_tab      => l_inst_id_tab
                             , i_use_auth_data_rec => com_api_const_pkg.FALSE
                             , io_event_params     => l_event_params
                           );

            if l_resp_code != aup_api_const_pkg.RESP_CODE_OK then
                if l_resp_code = aup_api_const_pkg.RESP_CODE_OPERATION_DUPLICATED then
                    l_rejected_count := l_rejected_count + 1;
                else
                    l_excepted_count := l_excepted_count + 1;
                end if;
            end if;

            register_events(
                io_oper           => l_oper_tab(i)
              , i_resp_code       => l_resp_code
              , io_split_hash_tab => l_split_hash_tab
              , io_inst_id_tab    => l_inst_id_tab
              , io_event_params   => l_event_params
            );

            l_split_hash_tab.delete;
            l_inst_id_tab.delete;

            trc_log_pkg.clear_object;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;

        end loop;

        -- Clear reference to operation after cycle of operations, it's used for fatal error.
        l_last_originator_refnum := null;

        exit when cur_operations%notfound;
    end loop;

    close cur_operations;

    if g_operations.count > 0 then
        update_total_amount;
    end if;

    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_rejected_total   => l_rejected_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    -- Only when any XML file is loaded in single thread
    if i_splitted_files = com_api_const_pkg.TRUE then
        l_current_session_file_id := l_record_count_tab.first();
        while l_current_session_file_id is not null loop
            prc_api_file_pkg.change_session_file(
                i_sess_file_id       => l_current_session_file_id
              , i_record_count       => l_record_count_tab(l_current_session_file_id)
              , i_check_record_count => com_api_const_pkg.TRUE
            );

            l_current_session_file_id := l_record_count_tab.next(l_current_session_file_id);
        end loop;
    end if;

    trc_log_pkg.debug(
        i_text  => 'Read clearing finished'
    );

    com_api_sttl_day_pkg.unset_sysdate;

exception
    when others then
        rollback to savepoint read_operations_start;

        com_api_sttl_day_pkg.unset_sysdate;
        trc_log_pkg.clear_object;

        if cur_operations%isopen then
            close cur_operations;
        end if;

        if cur_oper_count%isopen then
            close cur_oper_count;
        end if;

        prc_api_stat_pkg.log_end (
            i_excepted_total     => l_excepted_count
            , i_processed_total  => l_processed_count
            , i_rejected_total   => l_rejected_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
              , i_env_param2    => l_last_originator_refnum
            );

        end if;

        raise;

end load_operations;

/*
 * Obsolete and do not used. SVFE processes are moved into itf_prc_import_pkg.
 *
 * Process for loading operations (posting) with additional incoming parameters.
 * @param i_import_clear_pan  - if it is FALSE then process expects encoded
 *     PANs (tokens) in incoming file(s) when tokenization is enabled
 *     (this case may take place when Message Bus is capable to handle tokens).
 */
procedure load_operations_extend(
    i_start_date            in     date
  , i_inst_id               in     com_api_type_pkg.t_tiny_id
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_oper_status           in     com_api_type_pkg.t_dict_value default null
  , i_import_clear_pan      in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_svfe_network          in     com_api_type_pkg.t_tiny_id    default null
  , i_splitted_files        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
)
is
begin
    load_operations(
        i_oper_status      => i_oper_status
      , i_import_clear_pan => i_import_clear_pan
      , i_splitted_files   => i_splitted_files
    );
end;

procedure load_update
is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_rejected_count        com_api_type_pkg.t_long_id := 0;

    l_update_tab            t_update_tab;
    l_sess_file_id          com_api_type_pkg.t_long_id;
begin
    savepoint read_operations_start;

    trc_log_pkg.debug(
        i_text          => 'Read Update Operation'
    );

    prc_api_stat_pkg.log_start;

    open cur_update_count;
    fetch cur_update_count into l_estimated_count;
    close cur_update_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    open cur_update;

    trc_log_pkg.debug(
        i_text          => 'cursor opened '||l_estimated_count
    );

    loop
        fetch cur_update bulk collect into l_update_tab limit 1000;

        forall i in l_update_tab.first..l_update_tab.last
            update opr_operation
               set status = l_update_tab(i).status
                 , status_reason = l_update_tab(i).status_reason
             where id = l_update_tab(i).oper_id;

        for i in l_update_tab.first..l_update_tab.last
        loop
            if l_sess_file_id is null then
                l_sess_file_id := l_update_tab(i).session_file_id;
            end if;

            if l_sess_file_id != l_update_tab(i).session_file_id then
                prc_api_file_pkg.close_file(i_sess_file_id => l_sess_file_id
                                          , i_status       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS);

                l_sess_file_id := l_update_tab(i).session_file_id;
            end if;
        end loop;

        l_processed_count := l_processed_count + l_update_tab.count;

        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
          , i_excepted_count    => l_excepted_count
        );

        exit when cur_update%notfound;
    end loop;

    close cur_update;

    prc_api_file_pkg.close_file(
        i_sess_file_id       => l_sess_file_id
      , i_status             => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    net_api_bin_pkg.rebuild_bin_index;

    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_rejected_total   => l_rejected_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'Operation update finished'
    );

    com_api_sttl_day_pkg.unset_sysdate;

exception
    when others then
        rollback to savepoint read_operations_start;
        com_api_sttl_day_pkg.unset_sysdate;
        trc_log_pkg.clear_object;

        if cur_update%isopen then
            close   cur_update;
        end if;

        if cur_update_count%isopen then
            close cur_update_count;
        end if;

        prc_api_stat_pkg.log_end (
            i_excepted_total     => l_excepted_count
            , i_processed_total  => l_processed_count
            , i_rejected_total   => l_rejected_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end load_update;

procedure load_sttt
is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_rejected_count        com_api_type_pkg.t_long_id := 0;

    l_id                    com_api_type_pkg.t_number_tab;
    l_amount                com_api_type_pkg.t_number_tab;
    l_curr                  com_api_type_pkg.t_curr_code_tab;
    l_sess_file_id          com_api_type_pkg.t_long_id;
    l_sttt_tab              t_sttt_tab;
begin
    savepoint read_operations_start;

    trc_log_pkg.debug(
        i_text          => 'Read Settlement file'
    );

    prc_api_stat_pkg.log_start;


    open cur_sttt_count;
    fetch cur_sttt_count into l_estimated_count;
    close cur_sttt_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    open cur_sttt;

    trc_log_pkg.debug(
        i_text          => 'cursor opened ('||l_estimated_count||')'
    );

    loop
        fetch cur_sttt bulk collect into l_sttt_tab limit 1000;

        l_id.delete;
        l_amount.delete;
        l_curr.delete;

        for k in 1 .. l_sttt_tab.count loop
            l_id(k)     := l_sttt_tab(k).oper_id;
            l_amount(k) := l_sttt_tab(k).sttt_amount;
            l_curr(k)   := l_sttt_tab(k).sttt_currency;

            if l_sess_file_id is null then
                l_sess_file_id := l_sttt_tab(k).session_file_id;
            end if;

            if l_sess_file_id != l_sttt_tab(k).session_file_id then
                prc_api_file_pkg.close_file(i_sess_file_id => l_sess_file_id
                                          , i_status       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS);

                l_sess_file_id := l_sttt_tab(k).session_file_id;
            end if;
        end loop;

        opr_api_clearing_pkg.mark_settled (
            i_id_tab         => l_id
          , i_sttl_amount    => l_amount
          , i_sttl_currency  => l_curr
        );

        l_processed_count := l_processed_count + l_sttt_tab.count;

        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
          , i_excepted_count    => l_excepted_count
        );

        exit when cur_sttt%notfound;
    end loop;

    close cur_sttt;

    prc_api_file_pkg.close_file(
        i_sess_file_id => l_sess_file_id
      , i_status       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    net_api_bin_pkg.rebuild_bin_index;

    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_rejected_total   => l_rejected_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'Read sttt finished'
    );

    com_api_sttl_day_pkg.unset_sysdate;

exception
    when others then
        rollback to savepoint read_operations_start;
        com_api_sttl_day_pkg.unset_sysdate;
        trc_log_pkg.clear_object;

        if cur_sttt%isopen then
            close   cur_sttt;
        end if;

        if cur_sttt_count%isopen then
            close cur_sttt_count;
        end if;

        prc_api_stat_pkg.log_end (
            i_excepted_total     => l_excepted_count
            , i_processed_total  => l_processed_count
            , i_rejected_total   => l_rejected_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end load_sttt;

procedure load_fraud_control
is
    l_estimated_count       com_api_type_pkg.t_long_id    := 0;
    l_processed_count       com_api_type_pkg.t_long_id    := 0;
    l_excepted_count        com_api_type_pkg.t_long_id    := 0;
    l_rejected_count        com_api_type_pkg.t_long_id    := 0;
begin
    savepoint read_fraud_start;

    trc_log_pkg.debug(
        i_text          => 'Read fraud control'
    );

    prc_api_stat_pkg.log_start;

    open cur_frd_control_count;

    fetch cur_frd_control_count into l_estimated_count;
    close cur_frd_control_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    open cur_fraud_control;

    trc_log_pkg.debug(
        i_text          => 'cursor cur_fraud_control opened'
    );

    loop
        fetch cur_fraud_control bulk collect into l_fraud_tab limit 1000;

        for i in 1 .. l_fraud_tab.count loop

            l_processed_count := l_processed_count + 1;

            opr_api_create_pkg.set_oper_stage(
                i_oper_id            => l_fraud_tab(i).oper_id
              , i_external_auth_id   => l_fraud_tab(i).external_auth_id
              , i_is_reversal        => l_fraud_tab(i).is_reversal
              , i_command            => l_fraud_tab(i).command
            );

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;

        end loop;

        exit when cur_fraud_control%notfound;
    end loop;

    close cur_fraud_control;

    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_rejected_total   => l_rejected_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'Read fraud control finished'
    );

exception
    when others then
        rollback to savepoint read_fraud_start;

        if cur_fraud_control%isopen then
            close cur_fraud_control;
        end if;

        if cur_frd_control_count%isopen then
            close cur_frd_control_count;
        end if;

        prc_api_stat_pkg.log_end (
            i_excepted_total     => l_excepted_count
            , i_processed_total  => l_processed_count
            , i_rejected_total   => l_rejected_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

        raise;
end load_fraud_control;

end opr_prc_import_pkg;
/
