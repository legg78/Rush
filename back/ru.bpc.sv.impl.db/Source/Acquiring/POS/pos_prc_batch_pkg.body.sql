create or replace package body pos_prc_batch_pkg as

DUMMY_XML    xmltype;

    cursor cur_operations(
        i_session_id          in     com_api_type_pkg.t_long_id
      , i_import_clear_pan    in     com_api_type_pkg.t_boolean
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
        end as destination_card_number
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
          , x.inst_id def_inst
          , x.oper_type
          , x.msg_type
          , x.sttl_type
          , x.recon_type
          , x.oper_date
          , x.host_date
          , nvl(oper_count, 1) oper_count
          , x.oper_amount_value
          , x.oper_amount_currency
          , x.oper_request_amount_value
          , x.oper_request_amount_currency
          , x.oper_surcharge_amount_value
          , x.oper_surcharge_amount_currency
          , x.oper_cashback_amount_value
          , x.oper_cashback_amount_currency
          , to_number(null) sttl_amount_value
          , to_char(null) sttl_amount_currency
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
          , x.sttl_date sttl_date
          , x.acq_sttl_date

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
          , x.payment_date
          , x.payment_order_prty_type
          , x.payment_parameters

          , x.issuer_client_id_type
          , x.issuer_client_id_value
          , x.issuer_card_number
          , x.issuer_card_id
          , x.issuer_card_seq_number
          , x.issuer_card_expir_date issuer_card_expir_date
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
          , x.acquirer_card_expir_date acquirer_card_expir_date
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
          , x.destination_card_expir_date destination_card_expir_date
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
          , x.aggregator_card_expir_date aggregator_card_expir_date
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
          , x.srvp_card_expir_date srvp_card_expir_date
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
          , x.session_file_id incom_sess_file_id
          , x.note
          , x.auth_data
          , x.ipm_data
          , x.baseii_data
          , x.match_status
          , x.additional_amount
          , x.processing_stage
          , x.flexible_data

          , x.issuer_client_id_type || '/' || x.issuer_client_id_value split_hash
        from (
            select d.id oper_id
                 , nvl(o.oper_type, com_api_array_pkg.conv_array_elem_v(
                                        i_array_type_id     => 1040
                                      , i_array_id          => 10000048
                                      , i_elem_value        => d.trans_type
                                    )
                   ) oper_type
                 , opr_api_const_pkg.MESSAGE_TYPE_POS_BATCH msg_type
                 , nvl(o.sttl_type, nvl2(c.card_id, opr_api_const_pkg.SETTLEMENT_USONUS, opr_api_const_pkg.SETTLEMENT_THEMONUS)) sttl_type
                 , to_char(null) recon_type
                 , case p_iss.inst_id
                   when cup_api_const_pkg.UPI_INST_ID then
                       o.oper_date
                   else
                       to_date(d.trans_date || d.trans_time, 'DDMMYYYYHH24MISS')
                   end oper_date
                 , nvl(o.host_date, to_date(d.trans_date || d.trans_time, 'DDMMYYYYHH24MISS')) host_date
                 , o.oper_count
                 , d.trans_amount           oper_amount_value
                 , d.trans_currency         oper_amount_currency
                 , nvl(o.oper_request_amount, d.trans_amount)    oper_request_amount_value
                 , d.trans_currency         oper_request_amount_currency
                 , o.oper_surcharge_amount  oper_surcharge_amount_value
                 , to_char(null)            oper_surcharge_amount_currency
                 , o.oper_cashback_amount   oper_cashback_amount_value
                 , to_char(null)            oper_cashback_amount_currency
                 , o.fee_amount             interchange_fee_value
                 , o.fee_currency           interchange_fee_currency
                 , o.oper_reason
                 , to_char(null)            status
                 , to_char(null)            status_reason
                 , d.is_reversal
                 , d.retrieval_reference_number originator_refnum
                 , o.network_refnum
                 , to_number(d.acq_inst_id) acq_inst_bin
                 , o.forw_inst_bin
                 , m.merchant_number
                 , b.mcc
                 , nvl(o.merchant_name, m.merchant_name)                        merchant_name
                 , nvl(o.merchant_street, ad.street)                            merchant_street
                 , nvl(o.merchant_city, ad.city)                                merchant_city
                 , nvl(o.merchant_region, com_api_country_pkg.get_country_name(
                                              i_code        => nvl(o.merchant_country, ad.country)
                                            , i_raise_error => com_api_const_pkg.FALSE
                                          )
                   )                                                            merchant_region
                 , nvl(o.merchant_country, ad.country)                          merchant_country
                 , nvl(o.merchant_postcode, ad.postal_code)                     merchant_postcode
                 , nvl(o.terminal_type, acq_api_const_pkg.TERMINAL_TYPE_POS)    terminal_type
                 , t.terminal_number
                 , o.sttl_date
                 , o.acq_sttl_date

                 , d.utrnno                 external_auth_id
                 , d.auth_utrnno            external_orig_id
                 , d.trace_number
                 -- payment_order
                 , to_number(null)          payment_order_id
                 , to_char(null)            payment_order_status
                 , to_char(null)            payment_order_number
                 , to_number(null)          purpose_id
                 , to_char(null)            purpose_number
                 , to_number(null)          payment_order_amount
                 , to_char(null)            payment_order_currency
                 , to_date(null)            payment_date
                 , to_char(null)            payment_order_prty_type
                 , DUMMY_XML                payment_parameters
                 -- issuer
                 , nvl(p_iss.client_id_type, opr_api_const_pkg.CLIENT_ID_TYPE_CARD)     issuer_client_id_type
                 , nvl(p_iss.client_id_value, d.card_number)                            issuer_client_id_value
                 , d.card_number            issuer_card_number
                 , nvl(p_iss.card_id, c.card_id)            issuer_card_id
                 , d.card_member_number     issuer_card_seq_number
                 , nvl(p_iss.card_expir_date, case when d.card_expir_date != '0000'
                                                   then last_day(to_date(d.card_expir_date, 'yymm'))
                                               end
                   ) as issuer_card_expir_date
                 , p_iss.inst_id            issuer_inst_id
                 , p_iss.network_id         issuer_network_id
                 , d.auth_code              issuer_auth_code
                 , p_iss.account_amount     issuer_account_amount
                 , p_iss.account_currency   issuer_account_currency
                 , nvl(p_iss.account_number, (select min(a.account_number)
                                                from acc_account_object o
                                                   , acc_account        a
                                               where o.object_id   = nvl(p_iss.card_id, c.card_id)
                                                 and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                                 and a.id          = o.account_id
                                                 and a.status     != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED)
                   ) as issuer_account_number
                 -- acquirer
                 , nvl(p_acq.client_id_type, opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL)            acquirer_client_id_type
                 , nvl(p_acq.client_id_value, b.header_terminal_id)            acquirer_client_id_value
                 , to_char(null)            acquirer_card_number
                 , to_number(null)          acquirer_card_id
                 , to_number(null)          acquirer_card_seq_number
                 , to_date(null)            acquirer_card_expir_date
                 , p_acq.inst_id            acquirer_inst_id
                 , p_acq.network_id         acquirer_network_id
                 , to_char(null)            acquirer_auth_code
                 , p_acq.account_amount     acquirer_account_amount
                 , p_acq.account_currency   acquirer_account_currency
                 , nvl(p_acq.account_number, (select min(a.account_number)
                                                from acq_terminal       t
                                                   , acc_account_object o
                                                   , acc_account        a
                                               where t.terminal_number = b.header_terminal_id
                                                 and o.object_id       = t.id
                                                 and o.entity_type     = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                                 and a.id              = o.account_id
                                                 and a.status         != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED)
                   ) as acquirer_account_number
                 -- destination
                 , to_char(null)            destination_client_id_type
                 , to_char(null)            destination_client_id_value
                 , to_char(null)            destination_card_number
                 , to_number(null)          destination_card_id
                 , to_number(null)          destination_card_seq_number
                 , to_date(null)            destination_card_expir_date
                 , to_number(null)          destination_inst_id
                 , to_number(null)          destination_network_id
                 , to_char(null)            destination_auth_code
                 , to_number(null)          destination_account_amount
                 , to_char(null)            destination_account_currency
                 , to_char(null)            destination_account_number
                 -- aggregator
                 , to_char(null)            aggregator_client_id_type
                 , to_char(null)            aggregator_client_id_value
                 , to_char(null)            aggregator_card_number
                 , to_number(null)          aggregator_card_seq_number
                 , to_date(null)            aggregator_card_expir_date
                 , to_number(null)          aggregator_inst_id
                 , to_number(null)          aggregator_network_id
                 , to_char(null)            aggregator_auth_code
                 , to_number(null)          aggregator_account_amount
                 , to_char(null)            aggregator_account_currency
                 , to_char(null)            aggregator_account_number
                 -- service Provider
                 , to_char(null)            srvp_client_id_type
                 , to_char(null)            srvp_client_id_value
                 , to_char(null)            srvp_card_number
                 , to_number(null)          srvp_card_seq_number
                 , to_date(null)            srvp_card_expir_date
                 , to_number(null)          srvp_inst_id
                 , to_number(null)          srvp_network_id
                 , to_char(null)            srvp_auth_code
                 , to_number(null)          srvp_account_amount
                 , to_char(null)            srvp_account_currency
                 , to_char(null)            srvp_account_number

                 , DUMMY_XML                participant

                 , com_api_const_pkg.FALSE  payment_order_exists
                 , com_api_const_pkg.TRUE   issuer_exists
                 , com_api_const_pkg.TRUE   acquirer_exists
                 , com_api_const_pkg.FALSE  destination_exists
                 , com_api_const_pkg.FALSE  aggregator_exists
                 , com_api_const_pkg.FALSE  service_provider_exists

                 , DUMMY_XML                note
                 , DUMMY_XML                auth_data
                 , DUMMY_XML                ipm_data
                 , DUMMY_XML                baseii_data
                 , to_char(null)            match_status
                 , DUMMY_XML                additional_amount
                 , DUMMY_XML                processing_stage
                 , DUMMY_XML                flexible_data
                 , f.session_file_id
                 , to_number(f.inst_id)     inst_id
              from pos_batch_file       f
                 , pos_batch_block      b
                 , pos_batch_detail     d
                 , ( select min(id) id, external_auth_id
                      from aut_auth
                     group by external_auth_id
                   ) a
                 , opr_operation        o
                 , opr_participant      p_acq
                 , opr_participant      p_iss
                 , acq_merchant         m
                 , acq_terminal         t
                 , com_address_object   ao
                 , com_address          ad
                 , iss_card_number      c
             where f.session_id              = nvl(i_session_id, f.session_id)
               and f.status                 is null
               and b.batch_file_id           = f.id
               and d.batch_block_id          = b.id
               and a.external_auth_id(+)     = d.auth_utrnno
               and (a.id                    in (select min(aa.id) 
                                                  from aut_auth aa
                                                 where aa.external_auth_id = a.external_auth_id)
                    or a.id is null)
               and o.id(+)                   = a.id
               and nvl(o.msg_type, 'X')     != opr_api_const_pkg.MESSAGE_TYPE_POS_BATCH
               and o.is_reversal(+)          = nvl(d.is_reversal, com_api_type_pkg.FALSE)
               and p_acq.oper_id(+)          = o.id
               and p_acq.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER
               and p_iss.oper_id(+)          = o.id
               and p_iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
               and m.merchant_number(+)      = b.header_merchant_id
               and t.terminal_number(+)      = b.header_terminal_id
               and t.merchant_id(+)          = m.id
               and t.terminal_type(+)        = acq_api_const_pkg.TERMINAL_TYPE_POS
               and ao.object_id(+)           = m.id
               and ao.entity_type(+)         = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               and ad.id(+)                  = ao.address_id
               and ad.lang(+)                = com_api_const_pkg.LANGUAGE_ENGLISH
               and c.card_number(+)          = d.card_number
         ) x
    ) opr
    where com_api_hash_pkg.get_split_hash(i_value => opr.split_hash) in (select split_hash from com_api_split_map_vw)
    order by opr.is_reversal
           , opr.host_date
           , decode(opr.external_orig_id, opr.external_auth_id, 0, 1)
           , opr.external_auth_id;

    cursor cur_oper_count (
        i_session_id          in     com_api_type_pkg.t_long_id
    ) is
    select count(1) oper_count
      from pos_batch_file   f
         , pos_batch_block  b
         , pos_batch_detail d
     where f.session_id     = nvl(i_session_id, f.session_id)
       and f.status        is null
       and b.batch_file_id  = f.id
       and d.batch_block_id = b.id;

type t_oper_tab is varray(1000) of opr_prc_import_pkg.t_oper_clearing_rec;
l_oper_tab                  t_oper_tab;

procedure add_pos_batch_detail(
    i_oper_id        in            com_api_type_pkg.t_long_id
  , io_event_params  in out nocopy com_api_type_pkg.t_param_tab
) is
    l_trans_type            com_api_type_pkg.t_dict_value;
begin
    for r in (
        select id
             , voucher_number
             , debit_credit
             , trans_type
             , pos_data_code
             , trans_status
             , add_data
             , emv_data
             , service_id
             , payment_details
             , service_provider_id
             , unique_number_payment
             , add_amounts
             , svfe_trace_number
          from pos_batch_detail
         where id = i_oper_id
    )
    loop
        insert into opr_pos_batch (
            oper_id
          , voucher_number
          , debit_credit
          , trans_type
          , pos_data_code
          , trans_status
          , add_data
          , emv_data
          , service_id
          , payment_details
          , service_provider_id
          , unique_number_payment
          , add_amounts
          , svfe_trace_number
        )
        values (
               r.id
             , r.voucher_number
             , r.debit_credit
             , r.trans_type
             , r.pos_data_code
             , r.trans_status
             , r.add_data
             , r.emv_data
             , r.service_id
             , r.payment_details
             , r.service_provider_id
             , r.unique_number_payment
             , r.add_amounts
             , r.svfe_trace_number
        );

        l_trans_type := r.trans_type;
    end loop;

    rul_api_param_pkg.set_param(
        i_name    => 'POS_BATCH_TRANS_TYPE'
      , i_value   => l_trans_type
      , io_params => io_event_params
    );
end add_pos_batch_detail;

procedure load_pos_batch(
    i_import_clear_pan  in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_session_id        in     com_api_type_pkg.t_long_id    default null
) is
    l_estimated_count       com_api_type_pkg.t_long_id    := 0;
    l_processed_count       com_api_type_pkg.t_long_id    := 0;
    l_excepted_count        com_api_type_pkg.t_long_id    := 0;
    l_rejected_count        com_api_type_pkg.t_long_id    := 0;

    l_oper_status           com_api_type_pkg.t_dict_value;
    l_event_params          com_api_type_pkg.t_param_tab;

    l_resp_code             com_api_type_pkg.t_dict_value;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_multi_institution     com_api_type_pkg.t_boolean;
    l_sttl_date             date;
    l_session_id            com_api_type_pkg.t_long_id;
    l_result_code           com_api_type_pkg.t_dict_value;

    l_split_hash_tab        com_api_type_pkg.t_tiny_tab;
    l_inst_id_tab           com_api_type_pkg.t_inst_id_tab;
    l_auth_data_rec         aut_api_type_pkg.t_auth_rec;
    l_auth_tag_tab          aut_api_type_pkg.t_auth_tag_tab;

    l_iss_inst_id           com_api_type_pkg.t_inst_id;
    l_iss_network_id        com_api_type_pkg.t_tiny_id;
    l_iss_host_id           com_api_type_pkg.t_tiny_id;
    l_card_type_id          com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_country_code;
    l_card_inst_id          com_api_type_pkg.t_inst_id;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_pan_length            com_api_type_pkg.t_tiny_id;

    l_original_id           com_api_type_pkg.t_long_id;
    l_operation             opr_api_type_pkg.t_oper_rec;

    procedure copy_auth_data(
        i_source_id     in com_api_type_pkg.t_long_id
      , i_target_id     in com_api_type_pkg.t_long_id
    ) is
        l_auth          aut_api_type_pkg.t_auth_rec;
    begin
        trc_log_pkg.debug(
            i_text => 'copy_auth_data: from ' || i_source_id || ' to ' || i_target_id
        );

        l_auth := aut_api_auth_pkg.get_auth(i_id => i_source_id);

        l_auth.id := i_target_id;

        aut_api_auth_pkg.save_auth(i_auth => l_auth);

        aup_api_tag_pkg.copy_tag_value(
            i_source_auth_id  => i_source_id
          , i_target_auth_id  => i_target_id
        );

        trc_log_pkg.debug(
            i_text => 'copy_auth_data: done'
        );
    end;

begin
    savepoint load_pos_batch_start;

    trc_log_pkg.info(
        i_text          => 'Load POS batch file ' || i_session_id
    );

    prc_api_stat_pkg.log_start;

    l_session_id := nvl(i_session_id, get_session_id);

    open cur_oper_count(
        i_session_id       => l_session_id
    );

    fetch cur_oper_count into l_estimated_count;
    close cur_oper_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    trc_log_pkg.debug(
        i_text          => 'l_estimated_count [#1]'
      , i_env_param1    => l_estimated_count
    );

    if l_estimated_count > 0 then

        l_oper_status := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;

        open cur_operations(
            i_session_id       => l_session_id
          , i_import_clear_pan => nvl(i_import_clear_pan, com_api_type_pkg.TRUE)
        );

        trc_log_pkg.debug(
            i_text          => 'cursor cur_operations opened'
        );

        -- get sttl_date for operations
        l_multi_institution := set_ui_value_pkg.get_system_param_n('MULTI_INSTITUTION');
        if l_multi_institution = com_api_type_pkg.FALSE then
            l_sttl_date := com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => ost_api_const_pkg.DEFAULT_INST);
        else
            l_sttl_date := null;
        end if;
        trc_log_pkg.info(
            i_text          => 'l_sttl_date = ' || l_sttl_date
        );

        loop
            fetch cur_operations bulk collect into l_oper_tab limit 1000;

            for i in 1 .. l_oper_tab.count loop

                l_processed_count := l_processed_count + 1;
                l_session_file_id:= l_oper_tab(i).incom_sess_file_id;

                if l_oper_tab(i).is_reversal = com_api_const_pkg.TRUE
                   and (l_oper_tab(i).issuer_client_id_type is null
                        or l_oper_tab(i).issuer_client_id_value is null
                       )
                then
                    l_oper_tab(i).issuer_client_id_value := l_oper_tab(i).issuer_card_number;
                    l_oper_tab(i).issuer_client_id_type  := case
                                                                when l_oper_tab(i).issuer_client_id_value is not null
                                                                then opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                                                                else l_oper_tab(i).issuer_client_id_type
                                                            end;
                end if;

                if l_oper_tab(i).issuer_inst_id is null
                    or l_oper_tab(i).issuer_network_id is null
                then
                    net_api_bin_pkg.get_bin_info(
                        i_card_number           => l_oper_tab(i).issuer_card_number
                      , o_iss_inst_id           => l_iss_inst_id
                      , o_iss_network_id        => l_iss_network_id
                      , o_iss_host_id           => l_iss_host_id
                      , o_card_type_id          => l_card_type_id
                      , o_card_country          => l_card_country
                      , o_card_inst_id          => l_card_inst_id
                      , o_card_network_id       => l_card_network_id
                      , o_pan_length            => l_pan_length
                      , i_raise_error           => com_api_type_pkg.FALSE
                    );

                    if l_oper_tab(i).sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS then
                        l_oper_tab(i).issuer_inst_id    := l_iss_inst_id;
                        l_oper_tab(i).issuer_network_id := l_iss_network_id;
                    else
                        l_oper_tab(i).issuer_inst_id    := l_card_inst_id;
                        l_oper_tab(i).issuer_network_id := l_card_network_id;
                    end if;
                end if;

                if l_oper_tab(i).acquirer_inst_id is null
                    or l_oper_tab(i).acquirer_network_id is null
                then
                    if l_oper_tab(i).sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS then
                        l_oper_tab(i).acquirer_inst_id    := l_iss_inst_id;
                        l_oper_tab(i).acquirer_network_id := l_iss_network_id;
                    end if;
                end if;

                l_resp_code := opr_prc_import_pkg.register_operation(
                                   io_oper             => l_oper_tab(i)
                                 , io_auth_data_rec    => l_auth_data_rec
                                 , io_auth_tag_tab     => l_auth_tag_tab
                                 , i_import_clear_pan  => nvl(i_import_clear_pan, com_api_type_pkg.TRUE)
                                 , i_oper_status       => l_oper_status
                                 , i_sttl_date         => l_sttl_date 
                                 , i_without_checks    => com_api_const_pkg.TRUE
                                 , io_split_hash_tab   => l_split_hash_tab
                                 , io_inst_id_tab      => l_inst_id_tab
                                 , i_use_auth_data_rec => com_api_const_pkg.FALSE
                                 , io_event_params     => l_event_params
                               );

                opr_api_operation_pkg.get_operation(
                    i_oper_id   => l_oper_tab(i).oper_id
                  , o_operation => l_operation
                );
                l_original_id := l_operation.original_id;

                copy_auth_data(
                    i_source_id => l_original_id
                  , i_target_id => l_oper_tab(i).oper_id
                );

                if l_oper_tab(i).merchant_number is null or l_oper_tab(i).terminal_number is null then
                    trc_log_pkg.error(
                        i_text          => 'UNKNOWN_TERMINAL'
                      , i_env_param1    => l_oper_tab(i).acquirer_inst_id
                      , i_env_param2    => l_oper_tab(i).merchant_number
                      , i_env_param3    => null
                      , i_env_param4    => l_oper_tab(i).terminal_number
                    );
                    l_resp_code := aup_api_const_pkg.RESP_CODE_ERROR;
                end if;

                add_pos_batch_detail(
                    i_oper_id        => l_oper_tab(i).oper_id
                  , io_event_params  => l_event_params
                );

                trc_log_pkg.debug(
                    i_text        => 'oper_id [#1] resp_code [#2]'
                  , i_env_param1  => l_oper_tab(i).oper_id
                  , i_env_param2  => l_resp_code
                );

                if l_resp_code != aup_api_const_pkg.RESP_CODE_OK then
                    if l_resp_code = aup_api_const_pkg.RESP_CODE_OPERATION_DUPLICATED then
                        l_rejected_count := l_rejected_count + 1;
                    else
                        l_excepted_count := l_excepted_count + 1;
                    end if;
                end if;

                opr_prc_import_pkg.register_events(
                    io_oper           => l_oper_tab(i)
                  , i_resp_code       => l_resp_code
                  , io_split_hash_tab => l_split_hash_tab
                  , io_inst_id_tab    => l_inst_id_tab
                  , io_event_params   => l_event_params
                );

                trc_log_pkg.clear_object;

                if mod(l_processed_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count     => l_processed_count
                      , i_excepted_count    => l_excepted_count
                    );
                end if;

            end loop;

            exit when cur_operations%notfound;

        end loop;

        close cur_operations;

    end if;  -- if l_estimated_count > 0

    if (l_rejected_count > 0 or l_excepted_count > 0) and (l_rejected_count + l_excepted_count) < l_processed_count then
        l_result_code := prc_api_const_pkg.PROCESS_RESULT_REJECTED;
    else
        l_result_code := prc_api_const_pkg.PROCESS_RESULT_SUCCESS;
    end if;

    update pos_batch_file
       set status = l_result_code
     where session_file_id = l_session_file_id;

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => l_result_code
    );

    trc_log_pkg.info(
        i_text  => 'Load POS batch file finished'
    );

    com_api_sttl_day_pkg.unset_sysdate;

exception
    when others then
        rollback to savepoint load_pos_batch_start;
        com_api_sttl_day_pkg.unset_sysdate;
        trc_log_pkg.clear_object;

        if cur_operations%isopen then
            close cur_operations;
        end if;

        prc_api_stat_pkg.log_end(
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_processed_count
          , i_rejected_total    => l_rejected_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
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
end load_pos_batch;

end pos_prc_batch_pkg;
/

