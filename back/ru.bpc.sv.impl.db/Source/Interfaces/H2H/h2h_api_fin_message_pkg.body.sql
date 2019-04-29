create or replace package body h2h_api_fin_message_pkg as
/*********************************************************
 *  Host-to-host financial messages API <br />
 *  Created by Gerbeev I.(gerbeev@bpcbt.com)  at 22.06.2018 <br />
 *  Module: H2H_API_FIN_MESSAGE_PKG <br />
 *  @headcom
 **********************************************************/

function message_exists(
    i_fin_id                in            com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_fin_id                              com_api_type_pkg.t_long_id;
begin
    select max(id)
      into l_fin_id
      from h2h_fin_message
     where id = i_fin_id;

    return com_api_type_pkg.to_bool(l_fin_id is not null);
end;

function put_file(
    i_file_rec              in      h2h_api_type_pkg.t_h2h_file_rec
) return com_api_type_pkg.t_long_id
is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.put_file';
    l_id                            com_api_type_pkg.t_long_id;
begin
    l_id := coalesce(i_file_rec.id, com_api_id_pkg.get_id(i_seq => h2h_file_seq.nextval));

    insert into h2h_file(
        id
      , file_type
      , file_date
      , session_file_id
      , proc_date
      , is_incoming
      , is_rejected
      , network_id
      , inst_id
      , orig_file_id
      , forw_inst_code
      , receiv_inst_code
    ) values (
        l_id
      , i_file_rec.file_type
      , i_file_rec.file_date
      , i_file_rec.session_file_id
      , i_file_rec.proc_date
      , i_file_rec.is_incoming
      , i_file_rec.is_rejected
      , i_file_rec.network_id
      , i_file_rec.inst_id
      , i_file_rec.orig_file_id
      , i_file_rec.forw_inst_code
      , i_file_rec.receiv_inst_code
    );

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ': H2H-file [#1] has been added'
      , i_env_param1  => l_id
    );
    return l_id;
end put_file;

function put_message(
    i_fin_rec               in             h2h_api_type_pkg.t_h2h_fin_message_rec
) return com_api_type_pkg.t_long_id
is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.put_message';
    l_id                    com_api_type_pkg.t_long_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
begin
    l_id         := coalesce(
                        i_fin_rec.id
                      , opr_api_create_pkg.get_id()
                    );
    l_split_hash := coalesce(
                        i_fin_rec.split_hash
                      , com_api_hash_pkg.get_split_hash(i_value => i_fin_rec.card_number)
                    );
    insert into h2h_fin_message(
        id
      , split_hash
      , status
      , inst_id
      , network_id
      , forw_inst_code
      , receiv_inst_code
      , file_id
      , file_type
      , file_date
      , is_incoming
      , is_reversal
      , is_collection_only
      , is_rejected
      , reject_id
      , dispute_id
      , oper_type
      , msg_type
      , oper_date
      , oper_amount_value
      , oper_amount_currency
      , oper_surcharge_amount_value
      , oper_surcharge_amount_currency
      , oper_cashback_amount_value
      , oper_cashback_amount_currency
      , sttl_amount_value
      , sttl_amount_currency
      , sttl_rate
      , crdh_bill_amount_value
      , crdh_bill_amount_currency
      , crdh_bill_rate
      , acq_inst_bin
      , arn
      , merchant_number
      , mcc
      , merchant_name
      , merchant_street
      , merchant_city
      , merchant_region
      , merchant_country
      , merchant_postcode
      , terminal_type
      , terminal_number
      , card_seq_num
      , card_expiry
      , service_code
      , approval_code
      , rrn
      , trn
      , oper_id
      , original_id
      , emv_5f2a
      , emv_5f34
      , emv_71
      , emv_72
      , emv_82
      , emv_84
      , emv_8a
      , emv_91
      , emv_95
      , emv_9a
      , emv_9c
      , emv_9f02
      , emv_9f03
      , emv_9f06
      , emv_9f09
      , emv_9f10
      , emv_9f18
      , emv_9f1a
      , emv_9f1e
      , emv_9f26
      , emv_9f27
      , emv_9f28
      , emv_9f29
      , emv_9f33
      , emv_9f34
      , emv_9f35
      , emv_9f36
      , emv_9f37
      , emv_9f41
      , emv_9f53
      , pdc_1
      , pdc_2
      , pdc_3
      , pdc_4
      , pdc_5
      , pdc_6
      , pdc_7
      , pdc_8
      , pdc_9
      , pdc_10
      , pdc_11
      , pdc_12
    ) values (
        l_id
      , l_split_hash
      , i_fin_rec.status
      , i_fin_rec.inst_id
      , i_fin_rec.network_id
      , i_fin_rec.forw_inst_code
      , i_fin_rec.receiv_inst_code
      , i_fin_rec.file_id
      , i_fin_rec.file_type
      , i_fin_rec.file_date
      , i_fin_rec.is_incoming
      , i_fin_rec.is_reversal
      , i_fin_rec.is_collection_only
      , i_fin_rec.is_rejected
      , i_fin_rec.reject_id
      , i_fin_rec.dispute_id
      , i_fin_rec.oper_type
      , i_fin_rec.msg_type
      , i_fin_rec.oper_date
      , i_fin_rec.oper_amount_value
      , i_fin_rec.oper_amount_currency
      , i_fin_rec.oper_surcharge_amount_value
      , i_fin_rec.oper_surcharge_amount_currency
      , i_fin_rec.oper_cashback_amount_value
      , i_fin_rec.oper_cashback_amount_currency
      , i_fin_rec.sttl_amount_value
      , i_fin_rec.sttl_amount_currency
      , i_fin_rec.sttl_rate
      , i_fin_rec.crdh_bill_amount_value
      , i_fin_rec.crdh_bill_amount_currency
      , i_fin_rec.crdh_bill_rate
      , i_fin_rec.acq_inst_bin
      , i_fin_rec.arn
      , i_fin_rec.merchant_number
      , i_fin_rec.mcc
      , i_fin_rec.merchant_name
      , i_fin_rec.merchant_street
      , i_fin_rec.merchant_city
      , i_fin_rec.merchant_region
      , i_fin_rec.merchant_country
      , i_fin_rec.merchant_postcode
      , i_fin_rec.terminal_type
      , i_fin_rec.terminal_number
      , i_fin_rec.card_seq_num
      , i_fin_rec.card_expiry
      , i_fin_rec.service_code
      , i_fin_rec.approval_code
      , i_fin_rec.rrn
      , i_fin_rec.trn
      , i_fin_rec.oper_id
      , i_fin_rec.original_id
      , i_fin_rec.emv_5f2a
      , i_fin_rec.emv_5f34
      , i_fin_rec.emv_71
      , i_fin_rec.emv_72
      , i_fin_rec.emv_82
      , i_fin_rec.emv_84
      , i_fin_rec.emv_8a
      , i_fin_rec.emv_91
      , i_fin_rec.emv_95
      , i_fin_rec.emv_9a
      , i_fin_rec.emv_9c
      , i_fin_rec.emv_9f02
      , i_fin_rec.emv_9f03
      , i_fin_rec.emv_9f06
      , i_fin_rec.emv_9f09
      , i_fin_rec.emv_9f10
      , i_fin_rec.emv_9f18
      , i_fin_rec.emv_9f1a
      , i_fin_rec.emv_9f1e
      , i_fin_rec.emv_9f26
      , i_fin_rec.emv_9f27
      , i_fin_rec.emv_9f28
      , i_fin_rec.emv_9f29
      , i_fin_rec.emv_9f33
      , i_fin_rec.emv_9f34
      , i_fin_rec.emv_9f35
      , i_fin_rec.emv_9f36
      , i_fin_rec.emv_9f37
      , i_fin_rec.emv_9f41
      , i_fin_rec.emv_9f53
      , i_fin_rec.pdc_1
      , i_fin_rec.pdc_2
      , i_fin_rec.pdc_3
      , i_fin_rec.pdc_4
      , i_fin_rec.pdc_5
      , i_fin_rec.pdc_6
      , i_fin_rec.pdc_7
      , i_fin_rec.pdc_8
      , i_fin_rec.pdc_9
      , i_fin_rec.pdc_10
      , i_fin_rec.pdc_11
      , i_fin_rec.pdc_12
    );

    insert into h2h_card(
        id
      , card_number
    )
    values (
        l_id
      , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
    );

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ': H2H fin. message with ID [#1] has been registered'
      , i_env_param1  => l_id
    );

    return l_id;
end put_message;

function put_message(
    i_fin_rec               in             h2h_api_type_pkg.t_h2h_clearing_rec
) return com_api_type_pkg.t_long_id
is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.put_message: ';
    l_id                    com_api_type_pkg.t_long_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
begin
    l_id         := coalesce(
                        i_fin_rec.id
                      , opr_api_create_pkg.get_id()
                    );
    l_split_hash := coalesce(
                        i_fin_rec.split_hash
                      , com_api_hash_pkg.get_split_hash(i_value => i_fin_rec.card_number)
                    );

    insert into h2h_fin_message(
        id
      , split_hash
      , status
      , inst_id
      , network_id
      , forw_inst_code
      , receiv_inst_code
      , file_id
      , file_type
      , file_date
      , is_incoming
      , is_reversal
      , is_collection_only
      , is_rejected
      , reject_id
      , dispute_id
      , oper_type
      , msg_type
      , oper_date
      , oper_amount_value
      , oper_amount_currency
      , oper_surcharge_amount_value
      , oper_surcharge_amount_currency
      , oper_cashback_amount_value
      , oper_cashback_amount_currency
      , sttl_amount_value
      , sttl_amount_currency
      , sttl_rate
      , crdh_bill_amount_value
      , crdh_bill_amount_currency
      , crdh_bill_rate
      , acq_inst_bin
      , arn
      , merchant_number
      , mcc
      , merchant_name
      , merchant_street
      , merchant_city
      , merchant_region
      , merchant_country
      , merchant_postcode
      , terminal_type
      , terminal_number
      , card_seq_num
      , card_expiry
      , service_code
      , approval_code
      , rrn
      , trn
      , oper_id
      , original_id
      , emv_5f2a
      , emv_5f34
      , emv_71
      , emv_72
      , emv_82
      , emv_84
      , emv_8a
      , emv_91
      , emv_95
      , emv_9a
      , emv_9c
      , emv_9f02
      , emv_9f03
      , emv_9f06
      , emv_9f09
      , emv_9f10
      , emv_9f18
      , emv_9f1a
      , emv_9f1e
      , emv_9f26
      , emv_9f27
      , emv_9f28
      , emv_9f29
      , emv_9f33
      , emv_9f34
      , emv_9f35
      , emv_9f36
      , emv_9f37
      , emv_9f41
      , emv_9f53
      , pdc_1
      , pdc_2
      , pdc_3
      , pdc_4
      , pdc_5
      , pdc_6
      , pdc_7
      , pdc_8
      , pdc_9
      , pdc_10
      , pdc_11
      , pdc_12
    ) values (
        l_id
      , l_split_hash
      , i_fin_rec.status
      , i_fin_rec.inst_id
      , i_fin_rec.network_id
      , i_fin_rec.forw_inst_code
      , i_fin_rec.receiv_inst_code
      , i_fin_rec.file_id
      , i_fin_rec.file_type
      , i_fin_rec.file_date
      , i_fin_rec.is_incoming
      , i_fin_rec.is_reversal
      , i_fin_rec.is_collection_only
      , i_fin_rec.is_rejected
      , i_fin_rec.reject_id
      , i_fin_rec.dispute_id
      , i_fin_rec.oper_type
      , i_fin_rec.msg_type
      , i_fin_rec.oper_date
      , i_fin_rec.oper_amount_value
      , i_fin_rec.oper_amount_currency
      , i_fin_rec.oper_surcharge_amount_value
      , i_fin_rec.oper_surcharge_amount_currency
      , i_fin_rec.oper_cashback_amount_value
      , i_fin_rec.oper_cashback_amount_currency
      , i_fin_rec.sttl_amount_value
      , i_fin_rec.sttl_amount_currency
      , i_fin_rec.sttl_rate
      , i_fin_rec.crdh_bill_amount_value
      , i_fin_rec.crdh_bill_amount_currency
      , i_fin_rec.crdh_bill_rate
      , i_fin_rec.acq_inst_bin
      , i_fin_rec.arn
      , i_fin_rec.merchant_number
      , i_fin_rec.mcc
      , i_fin_rec.merchant_name
      , i_fin_rec.merchant_street
      , i_fin_rec.merchant_city
      , i_fin_rec.merchant_region
      , i_fin_rec.merchant_country
      , i_fin_rec.merchant_postcode
      , i_fin_rec.terminal_type
      , i_fin_rec.terminal_number
      , i_fin_rec.card_seq_num
      , i_fin_rec.card_expiry
      , i_fin_rec.service_code
      , i_fin_rec.approval_code
      , i_fin_rec.rrn
      , i_fin_rec.trn
      , i_fin_rec.oper_id
      , i_fin_rec.original_id
      , i_fin_rec.emv_5f2a
      , i_fin_rec.emv_5f34
      , i_fin_rec.emv_71
      , i_fin_rec.emv_72
      , i_fin_rec.emv_82
      , i_fin_rec.emv_84
      , i_fin_rec.emv_8a
      , i_fin_rec.emv_91
      , i_fin_rec.emv_95
      , i_fin_rec.emv_9a
      , i_fin_rec.emv_9c
      , i_fin_rec.emv_9f02
      , i_fin_rec.emv_9f03
      , i_fin_rec.emv_9f06
      , i_fin_rec.emv_9f09
      , i_fin_rec.emv_9f10
      , i_fin_rec.emv_9f18
      , i_fin_rec.emv_9f1a
      , i_fin_rec.emv_9f1e
      , i_fin_rec.emv_9f26
      , i_fin_rec.emv_9f27
      , i_fin_rec.emv_9f28
      , i_fin_rec.emv_9f29
      , i_fin_rec.emv_9f33
      , i_fin_rec.emv_9f34
      , i_fin_rec.emv_9f35
      , i_fin_rec.emv_9f36
      , i_fin_rec.emv_9f37
      , i_fin_rec.emv_9f41
      , i_fin_rec.emv_9f53
      , i_fin_rec.pdc_1
      , i_fin_rec.pdc_2
      , i_fin_rec.pdc_3
      , i_fin_rec.pdc_4
      , i_fin_rec.pdc_5
      , i_fin_rec.pdc_6
      , i_fin_rec.pdc_7
      , i_fin_rec.pdc_8
      , i_fin_rec.pdc_9
      , i_fin_rec.pdc_10
      , i_fin_rec.pdc_11
      , i_fin_rec.pdc_12
    );

    insert into h2h_card(
        id
      , card_number
    )
    values (
        l_id
      , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
    );

    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'H2H fin. message with ID [#1] has been registered'
      , i_env_param1  => l_id
    );

    return l_id;
end put_message;

function get_message(
    i_fin_id                in             com_api_type_pkg.t_long_id
  , i_mask_error            in             com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return h2h_api_type_pkg.t_h2h_fin_message_rec
is
    l_fin_rec                              h2h_api_type_pkg.t_h2h_fin_message_rec;
begin
    begin
        select m.id
             , m.split_hash
             , m.status
             , m.inst_id
             , m.network_id
             , m.forw_inst_code
             , m.receiv_inst_code
             , m.file_id
             , m.file_type
             , m.file_date
             , m.is_incoming
             , m.is_reversal
             , m.is_collection_only
             , m.is_rejected
             , m.reject_id
             , m.dispute_id
             , m.oper_type
             , m.msg_type
             , m.oper_date
             , m.oper_amount_value
             , m.oper_amount_currency
             , m.oper_surcharge_amount_value
             , m.oper_surcharge_amount_currency
             , m.oper_cashback_amount_value
             , m.oper_cashback_amount_currency
             , m.sttl_amount_value
             , m.sttl_amount_currency
             , m.sttl_rate
             , m.crdh_bill_amount_value
             , m.crdh_bill_amount_currency
             , m.crdh_bill_rate
             , m.acq_inst_bin
             , m.arn
             , m.merchant_number
             , m.mcc
             , m.merchant_name
             , m.merchant_street
             , m.merchant_city
             , m.merchant_region
             , m.merchant_country
             , m.merchant_postcode
             , m.terminal_type
             , m.terminal_number
             , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
             , m.card_seq_num
             , m.card_expiry
             , m.service_code
             , m.approval_code
             , m.rrn
             , m.trn
             , m.oper_id
             , m.original_id
             , m.emv_5f2a
             , m.emv_5f34
             , m.emv_71
             , m.emv_72
             , m.emv_82
             , m.emv_84
             , m.emv_8a
             , m.emv_91
             , m.emv_95
             , m.emv_9a
             , m.emv_9c
             , m.emv_9f02
             , m.emv_9f03
             , m.emv_9f06
             , m.emv_9f09
             , m.emv_9f10
             , m.emv_9f18
             , m.emv_9f1a
             , m.emv_9f1e
             , m.emv_9f26
             , m.emv_9f27
             , m.emv_9f28
             , m.emv_9f29
             , m.emv_9f33
             , m.emv_9f34
             , m.emv_9f35
             , m.emv_9f36
             , m.emv_9f37
             , m.emv_9f41
             , m.emv_9f53
             , m.pdc_1
             , m.pdc_2
             , m.pdc_3
             , m.pdc_4
             , m.pdc_5
             , m.pdc_6
             , m.pdc_7
             , m.pdc_8
             , m.pdc_9
             , m.pdc_10
             , m.pdc_11
             , m.pdc_12
          into l_fin_rec
          from      h2h_fin_message m
          left join h2h_card        c    on c.id = m.id
         where m.id = i_fin_id;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error       => 'H2H_FIN_MESSAGE_NOT_FOUND'
                  , i_env_param1  => i_fin_id
                  , i_env_param2  => null
                  , i_mask_error  => i_mask_error
                );
            end if;
    end;

    return l_fin_rec;
end get_message;

function get_message(
    i_oper_id               in             com_api_type_pkg.t_long_id
  , i_mask_error            in             com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return h2h_api_type_pkg.t_h2h_fin_message_rec
is
    l_fin_rec                              h2h_api_type_pkg.t_h2h_fin_message_rec;
begin
    begin
        select m.id
             , m.split_hash
             , m.status
             , m.inst_id
             , m.network_id
             , m.forw_inst_code
             , m.receiv_inst_code
             , m.file_id
             , m.file_type
             , m.file_date
             , m.is_incoming
             , m.is_reversal
             , m.is_collection_only
             , m.is_rejected
             , m.reject_id
             , m.dispute_id
             , m.oper_type
             , m.msg_type
             , m.oper_date
             , m.oper_amount_value
             , m.oper_amount_currency
             , m.oper_surcharge_amount_value
             , m.oper_surcharge_amount_currency
             , m.oper_cashback_amount_value
             , m.oper_cashback_amount_currency
             , m.sttl_amount_value
             , m.sttl_amount_currency
             , m.sttl_rate
             , m.crdh_bill_amount_value
             , m.crdh_bill_amount_currency
             , m.crdh_bill_rate
             , m.acq_inst_bin
             , m.arn
             , m.merchant_number
             , m.mcc
             , m.merchant_name
             , m.merchant_street
             , m.merchant_city
             , m.merchant_region
             , m.merchant_country
             , m.merchant_postcode
             , m.terminal_type
             , m.terminal_number
             , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
             , m.card_seq_num
             , m.card_expiry
             , m.service_code
             , m.approval_code
             , m.rrn
             , m.trn
             , m.oper_id
             , m.original_id
             , m.emv_5f2a
             , m.emv_5f34
             , m.emv_71
             , m.emv_72
             , m.emv_82
             , m.emv_84
             , m.emv_8a
             , m.emv_91
             , m.emv_95
             , m.emv_9a
             , m.emv_9c
             , m.emv_9f02
             , m.emv_9f03
             , m.emv_9f06
             , m.emv_9f09
             , m.emv_9f10
             , m.emv_9f18
             , m.emv_9f1a
             , m.emv_9f1e
             , m.emv_9f26
             , m.emv_9f27
             , m.emv_9f28
             , m.emv_9f29
             , m.emv_9f33
             , m.emv_9f34
             , m.emv_9f35
             , m.emv_9f36
             , m.emv_9f37
             , m.emv_9f41
             , m.emv_9f53
             , m.pdc_1
             , m.pdc_2
             , m.pdc_3
             , m.pdc_4
             , m.pdc_5
             , m.pdc_6
             , m.pdc_7
             , m.pdc_8
             , m.pdc_9
             , m.pdc_10
             , m.pdc_11
             , m.pdc_12
          into l_fin_rec
          from      h2h_fin_message m
          left join h2h_card        c    on c.id = m.id
         where m.oper_id = i_oper_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'H2H_FIN_MESSAGE_NOT_FOUND'
              , i_env_param1  => null
              , i_env_param2  => i_oper_id
              , i_mask_error  => i_mask_error
            );
        when too_many_rows then
            com_api_error_pkg.raise_error(
                i_error       => 'H2H_FIN_MESSAGE_IS_DUPLICATED'
              , i_env_param1  => i_oper_id
              , i_mask_error  => i_mask_error
            );
    end;

    return l_fin_rec;

exception
    when com_api_error_pkg.e_application_error then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            raise;
        else
            return l_fin_rec;
        end if;
end get_message;

procedure update_status(
    i_fin_id                in             com_api_type_pkg.t_long_id
  , i_status                in             com_api_type_pkg.t_dict_value
) is
begin
    update h2h_fin_message
       set status = i_status
     where id     = i_fin_id;
end;

procedure save_auth(
    i_fin_rec               in             h2h_api_type_pkg.t_h2h_clearing_rec
  , i_resp_code             in             com_api_type_pkg.t_dict_value          default null
  , io_tag_value_tab        in out nocopy  h2h_api_type_pkg.t_h2h_tag_value_tab
) is
    LOG_PREFIX                    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.register_auth';
    l_auth                                 aut_api_type_pkg.t_auth_rec;
    l_emv_tag_tab                          com_api_type_pkg.t_tag_value_tab;
    l_auth_tag_value_tab                   aup_api_type_pkg.t_aup_tag_tab;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ' << i_fin_rec.id [#1]'
      , i_env_param1  => i_fin_rec.id
    );

    l_auth.id                     := i_fin_rec.id;
    l_auth.resp_code              := aup_api_const_pkg.RESP_CODE_OK;
    l_auth.proc_type              := aut_api_const_pkg.AUTH_PROC_TYPE_LOAD;
    l_auth.proc_mode              := aut_api_const_pkg.AUTH_PROC_MODE_NORMAL;
    l_auth.is_advice              := com_api_const_pkg.FALSE;
    l_auth.is_repeat              := com_api_const_pkg.FALSE;
    l_auth.bin_amount             := i_fin_rec.crdh_bill_amount_value;
    l_auth.bin_currency           := i_fin_rec.crdh_bill_amount_currency;
    l_auth.bin_cnvt_rate          := i_fin_rec.crdh_bill_rate;
    l_auth.external_auth_id       := i_fin_rec.oper_id;
    l_auth.external_orig_id       := i_fin_rec.original_id;
    l_auth.resp_code              := i_resp_code;

    l_auth.card_data_input_cap    := acq_api_const_pkg.DICT_CARD_DATA_INPUT_CAP      || lpad(i_fin_rec.pdc_1, 4, '0');
    l_auth.crdh_auth_cap          := acq_api_const_pkg.DICT_CARDHOLDER_AUTH_CAP      || lpad(i_fin_rec.pdc_2, 4, '0');
    l_auth.card_capture_cap       := acq_api_const_pkg.DICT_CARD_CAPTURE_CAP         || lpad(i_fin_rec.pdc_3, 4, '0');
    l_auth.terminal_operating_env := acq_api_const_pkg.DICT_TERMINAL_OPERATING_ENV   || lpad(i_fin_rec.pdc_4, 4, '0');
    l_auth.crdh_presence          := acq_api_const_pkg.DICT_CARDHOLDER_PRESENCE_DATA || lpad(i_fin_rec.pdc_5, 4, '0');
    l_auth.card_presence          := acq_api_const_pkg.DICT_CARD_PRESENCE_DATA       || lpad(i_fin_rec.pdc_6, 4, '0');
    l_auth.card_data_input_mode   := acq_api_const_pkg.DICT_CARD_DATA_INPUT_MODE     || lpad(i_fin_rec.pdc_7, 4, '0');
    l_auth.crdh_auth_method       := acq_api_const_pkg.DICT_CARDHOLDER_AUTH_METHOD   || lpad(i_fin_rec.pdc_8, 4, '0');
    l_auth.crdh_auth_entity       := acq_api_const_pkg.DICT_CARDHOLDER_AUTH_ENTITY   || lpad(i_fin_rec.pdc_9, 4, '0');
    l_auth.card_data_output_cap   := acq_api_const_pkg.DICT_CARD_DATA_OUTPUT_CAP     || lpad(i_fin_rec.pdc_10, 4, '0');
    l_auth.terminal_output_cap    := acq_api_const_pkg.DICT_TERMINAL_DATA_OUTP_CAP   || lpad(i_fin_rec.pdc_11, 4, '0');
    l_auth.pin_capture_cap        := acq_api_const_pkg.DICT_PIN_CAPTURE_CAP          || lpad(i_fin_rec.pdc_12, 4, '0');

    l_emv_tag_tab('5F2A')  := i_fin_rec.emv_5f2a;
    l_emv_tag_tab('5F34')  := i_fin_rec.emv_5f34;
    l_emv_tag_tab('71')    := i_fin_rec.emv_71;
    l_emv_tag_tab('72')    := i_fin_rec.emv_72;
    l_emv_tag_tab('82')    := i_fin_rec.emv_82;
    l_emv_tag_tab('84')    := i_fin_rec.emv_84;
    l_emv_tag_tab('8A')    := i_fin_rec.emv_8a;
    l_emv_tag_tab('91')    := i_fin_rec.emv_91;
    l_emv_tag_tab('95')    := i_fin_rec.emv_95;
    l_emv_tag_tab('9A')    := i_fin_rec.emv_9a;
    l_emv_tag_tab('9C')    := i_fin_rec.emv_9c;
    l_emv_tag_tab('9F02')  := i_fin_rec.emv_9f02;
    l_emv_tag_tab('9F03')  := i_fin_rec.emv_9f03;
    l_emv_tag_tab('9F06')  := i_fin_rec.emv_9f06;
    l_emv_tag_tab('9F09')  := i_fin_rec.emv_9f09;
    l_emv_tag_tab('9F10')  := i_fin_rec.emv_9f10;
    l_emv_tag_tab('9F18')  := i_fin_rec.emv_9f18;
    l_emv_tag_tab('9F1A')  := i_fin_rec.emv_9f1a;
    l_emv_tag_tab('9F1E')  := i_fin_rec.emv_9f1e;
    l_emv_tag_tab('9F26')  := i_fin_rec.emv_9f26;
    l_emv_tag_tab('9F27')  := i_fin_rec.emv_9f27;
    l_emv_tag_tab('9F28')  := i_fin_rec.emv_9f28;
    l_emv_tag_tab('9F29')  := i_fin_rec.emv_9f29;
    l_emv_tag_tab('9F33')  := i_fin_rec.emv_9f33;
    l_emv_tag_tab('9F34')  := i_fin_rec.emv_9f34;
    l_emv_tag_tab('9F35')  := i_fin_rec.emv_9f35;
    l_emv_tag_tab('9F36')  := i_fin_rec.emv_9f36;
    l_emv_tag_tab('9F37')  := i_fin_rec.emv_9f37;
    l_emv_tag_tab('9F41')  := i_fin_rec.emv_9f41;
    l_emv_tag_tab('9F53')  := i_fin_rec.emv_9f53;

    l_auth.emv_data :=
        hextoraw(
            emv_api_tag_pkg.format_emv_data(
                io_emv_tag_tab  => l_emv_tag_tab
              , i_tag_type_tab  => h2h_api_const_pkg.EMV_TAGS_LIST_FOR_H2H
            )
        );

    aut_api_auth_pkg.save_auth(i_auth => l_auth);

    h2h_api_tag_pkg.get_auth_tag_value(
        io_tag_value_tab     => io_tag_value_tab
      , o_auth_tag_value_tab => l_auth_tag_value_tab
    );

    aup_api_tag_pkg.save_tag(
        i_auth_id            => l_auth.id
      , i_tags               => l_auth_tag_value_tab
    );

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ' >> [#1] auth tags saved'
      , i_env_param1  => l_auth_tag_value_tab.count()
    );
end save_auth;

procedure create_operation(
    i_fin_rec               in             h2h_api_type_pkg.t_h2h_clearing_rec
  , i_host_id                              com_api_type_pkg.t_tiny_id             default null
  , i_standard_id                          com_api_type_pkg.t_tiny_id             default null
  , io_tag_value_tab        in out nocopy  h2h_api_type_pkg.t_h2h_tag_value_tab
  , o_resp_code                out         com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX                    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_operation';
    l_operation                            opr_api_type_pkg.t_oper_rec;
    l_card_mask                            com_api_type_pkg.t_card_number;
    l_issuer                               opr_api_type_pkg.t_oper_part_rec;
    l_acquirer                             opr_api_type_pkg.t_oper_part_rec;
    l_standard_id                          com_api_type_pkg.t_tiny_id;
    l_host_id                              com_api_type_pkg.t_tiny_id;
    l_iss_host_id                          com_api_type_pkg.t_tiny_id;
    l_pan_length                           com_api_type_pkg.t_tiny_id;
    l_is_own_card                          com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_fin_rec.id [#1], i_standard_id [#2], i_host_id [#3]'
      , i_env_param1 => i_fin_rec.id
      , i_env_param2 => i_standard_id
      , i_env_param3 => i_host_id
    );

    iss_api_bin_pkg.get_bin_info(
        i_card_number      => i_fin_rec.card_number
      , o_iss_inst_id      => l_issuer.inst_id
      , o_iss_network_id   => l_issuer.network_id
      , o_iss_host_id      => l_iss_host_id
      , o_card_type_id     => l_issuer.card_type_id
      , o_card_country     => l_issuer.card_country
      , o_card_inst_id     => l_issuer.card_inst_id
      , o_card_network_id  => l_issuer.card_network_id
      , o_pan_length       => l_pan_length
      , i_raise_error      => com_api_const_pkg.FALSE
    );

    l_card_mask := iss_api_card_pkg.get_card_mask(i_card_number => i_fin_rec.card_number);

    trc_log_pkg.debug(
        i_text        => 'Own issuing BIN search result: PAN [#1], network [#2], institution [#3]'
      , i_env_param1  => l_card_mask
      , i_env_param2  => l_issuer.network_id
      , i_env_param3  => l_issuer.inst_id
    );

    l_is_own_card := com_api_type_pkg.to_bool(l_issuer.network_id is not null);

    l_operation.id      := i_fin_rec.id;
    l_operation.status  := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;

    begin
        if i_fin_rec.is_reversal = com_api_type_pkg.TRUE then
            -- In case of reversal, field <original_id> of the current H2H message should contain
            -- an external ID of H2H message imported earlier. That original H2H message can be found by
            -- the following condition: <original H2H message>.oper_id = <current H2H message>.original_id
            begin
                l_operation.id := get_message(
                                       i_oper_id    => i_fin_rec.original_id
                                     , i_mask_error => com_api_const_pkg.FALSE
                                  ).id;
            exception
                when com_api_error_pkg.e_application_error then
                    o_resp_code := aup_api_const_pkg.RESP_CODE_NO_ORIGINAL_OPER;
                    raise;
            end;

            if l_operation.id is not null then
                opr_api_operation_pkg.get_operation(
                    i_oper_id            => l_operation.id
                  , o_operation          => l_operation
                );
                opr_api_operation_pkg.get_participant(
                    i_oper_id            => l_operation.id
                  , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
                  , o_participant        => l_issuer
                );
                opr_api_operation_pkg.get_participant(
                    i_oper_id            => l_operation.id
                  , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
                  , o_participant        => l_acquirer
                );
            end if;
        else
            -- Non-reversal
            if l_is_own_card = com_api_const_pkg.FALSE then
                net_api_bin_pkg.get_bin_info(
                    i_card_number      => i_fin_rec.card_number
                  , io_iss_inst_id     => l_issuer.inst_id
                  , o_iss_network_id   => l_issuer.network_id
                  , o_iss_host_id      => l_iss_host_id
                  , o_card_type_id     => l_issuer.card_type_id
                  , o_card_country     => l_issuer.card_country
                  , o_card_inst_id     => l_issuer.card_inst_id
                  , o_card_network_id  => l_issuer.card_network_id
                  , o_pan_length       => l_pan_length
                  , i_raise_error      => com_api_const_pkg.FALSE
                );
                trc_log_pkg.debug(
                    i_text        => 'Network BIN search result: PAN [#1], network [#2], institution [#3]'
                  , i_env_param1  => l_card_mask
                  , i_env_param2  => l_issuer.network_id
                  , i_env_param3  => l_issuer.inst_id
                );
            end if;

            if l_issuer.card_inst_id is null then
                o_resp_code := aup_api_const_pkg.RESP_CODE_CARD_NOT_FOUND;

                com_api_error_pkg.raise_error(
                    i_error       => 'CARD_NOT_FOUND'
                  , i_env_param1  => l_card_mask
                );
            end if;

            if l_pan_length is null then
                com_api_error_pkg.raise_error(
                    i_error       => 'UNKNOWN_BIN_CARD_NUMBER_NETWORK'
                  , i_env_param1  => substr(i_fin_rec.card_number, 1, 6)
                  , i_env_param2  => l_issuer.network_id
                );
            end if;

            l_host_id :=
                coalesce(
                    i_host_id
                  , net_api_network_pkg.get_default_host(i_network_id => i_fin_rec.network_id)
                );
            l_standard_id :=
                coalesce(
                    i_standard_id
                  , net_api_network_pkg.get_offline_standard(i_host_id => l_host_id)
                );

            l_acquirer.inst_id :=
                cmn_api_standard_pkg.find_value_owner(
                    i_standard_id  => l_standard_id
                  , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_object_id    => l_host_id
                  , i_param_name   => h2h_api_const_pkg.H2H_INST_CODE
                  , i_value_char   => i_fin_rec.forw_inst_code
                  , i_mask_error   => com_api_const_pkg.FALSE
                );

            trc_log_pkg.debug(
                i_text        => 'l_acquirer.inst_id [#1] found by host [#1], standard [#2], forw_inst_code [#3]'
              , i_env_param1  => l_host_id
              , i_env_param2  => l_standard_id
              , i_env_param3  => l_acquirer.inst_id
            );

            l_acquirer.network_id := ost_api_institution_pkg.get_inst_network(i_inst_id => l_acquirer.inst_id);

            begin
                net_api_sttl_pkg.get_sttl_type(
                    i_iss_inst_id      => l_issuer.inst_id
                  , i_acq_inst_id      => l_acquirer.inst_id
                  , i_card_inst_id     => l_issuer.card_inst_id
                  , i_iss_network_id   => l_issuer.network_id
                  , i_acq_network_id   => l_acquirer.network_id
                  , i_card_network_id  => l_issuer.card_network_id
                  , i_acq_inst_bin     => i_fin_rec.acq_inst_bin
                  , i_oper_type        => i_fin_rec.oper_type
                  , i_mask_error       => com_api_const_pkg.FALSE
                  , o_sttl_type        => l_operation.sttl_type
                  , o_match_status     => l_operation.match_status
                );

                trc_log_pkg.debug(
                    i_text        => 'sttl_type [#1], match_status [#2]'
                  , i_env_param1  => l_operation.sttl_type
                  , i_env_param2  => l_operation.match_status
                );
            exception
                when com_api_error_pkg.e_application_error then
                    o_resp_code := aup_api_const_pkg.RESP_CODE_CANT_GET_STTL_TYPE;
                    raise;
            end;
        end if;

        l_operation.terminal_type :=
            coalesce(
                i_fin_rec.terminal_type
              , l_operation.terminal_type
              , case i_fin_rec.mcc
                    when net_api_const_pkg.MCC_ATM then acq_api_const_pkg.TERMINAL_TYPE_ATM
                                                   else acq_api_const_pkg.TERMINAL_TYPE_POS
                end
            );
        com_api_dictionary_pkg.check_article(
            i_dict  => acq_api_const_pkg.TERMINAL_TYPE_DICTIONARY
          , i_code  => l_operation.terminal_type
        );
    exception
        when com_api_error_pkg.e_application_error then
            l_operation.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
            o_resp_code        := nvl(o_resp_code, aup_api_const_pkg.RESP_CODE_ERROR);
    end;

    l_operation.terminal_number := nvl(i_fin_rec.terminal_number, l_operation.terminal_number);
    l_operation.host_date       := com_api_sttl_day_pkg.get_sysdate();
    l_operation.oper_date       := coalesce(i_fin_rec.oper_date, l_operation.host_date);

    opr_api_create_pkg.create_operation(
        io_oper_id           => l_operation.id
      , i_session_id         => prc_api_session_pkg.get_session_id()
      , i_status             => l_operation.status
      , i_status_reason      => null
      , i_sttl_type          => l_operation.sttl_type
      , i_msg_type           => i_fin_rec.msg_type
      , i_oper_type          => i_fin_rec.oper_type
      , i_oper_reason        => null
      , i_is_reversal        => i_fin_rec.is_reversal
      , i_original_id        => l_operation.original_id
      , i_oper_amount        => i_fin_rec.oper_amount_value
      , i_oper_currency      => i_fin_rec.oper_amount_currency
      , i_sttl_amount        => i_fin_rec.sttl_amount_value
      , i_sttl_currency      => i_fin_rec.sttl_amount_currency
      , i_oper_date          => l_operation.oper_date
      , i_host_date          => l_operation.host_date
      , i_terminal_type      => l_operation.terminal_type
      , i_mcc                => i_fin_rec.mcc
      , i_originator_refnum  => i_fin_rec.rrn
      , i_network_refnum     => i_fin_rec.arn
      , i_acq_inst_bin       => i_fin_rec.acq_inst_bin
      , i_merchant_number    => nvl(i_fin_rec.merchant_number, l_operation.merchant_number)
      , i_terminal_number    => l_operation.terminal_number
      , i_merchant_name      => i_fin_rec.merchant_name
      , i_merchant_street    => i_fin_rec.merchant_street
      , i_merchant_city      => i_fin_rec.merchant_city
      , i_merchant_region    => i_fin_rec.merchant_region
      , i_merchant_country   => i_fin_rec.merchant_country
      , i_merchant_postcode  => i_fin_rec.merchant_postcode
      , i_dispute_id         => i_fin_rec.dispute_id
      , i_match_status       => l_operation.match_status
      , i_incom_sess_file_id => null
    );

    opr_api_create_pkg.add_participant(
        i_oper_id            => l_operation.id
      , i_msg_type           => i_fin_rec.msg_type
      , i_oper_type          => i_fin_rec.oper_type
      , i_participant_type   => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_host_date          => l_operation.host_date
      , i_inst_id            => l_issuer.inst_id
      , i_network_id         => l_issuer.network_id
      , i_customer_id        => iss_api_card_pkg.get_customer_id(i_card_number => i_fin_rec.card_number)
      , i_client_id_type     => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
      , i_client_id_value    => i_fin_rec.card_number
      , i_card_id            => iss_api_card_pkg.get_card_id(i_card_number => i_fin_rec.card_number)
      , i_card_type_id       => l_issuer.card_type_id
      , i_card_expir_date    => l_issuer.card_expir_date
      , i_card_seq_number    => l_issuer.card_seq_number
      , i_card_number        => i_fin_rec.card_number
      , i_card_mask          => l_card_mask
      , i_card_hash          => com_api_hash_pkg.get_card_hash(i_card_number => i_fin_rec.card_number)
      , i_card_country       => l_issuer.card_country
      , i_card_inst_id       => l_issuer.card_inst_id
      , i_card_network_id    => l_issuer.card_network_id
      , i_account_id         => null
      , i_account_number     => null
      , i_account_amount     => null
      , i_account_currency   => null
      , i_auth_code          => i_fin_rec.approval_code
      , i_split_hash         => l_issuer.split_hash
      , i_without_checks     => com_api_const_pkg.TRUE
    );

    opr_api_create_pkg.add_participant(
        i_oper_id            => l_operation.id
      , i_msg_type           => i_fin_rec.msg_type
      , i_oper_type          => i_fin_rec.oper_type
      , i_participant_type   => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , i_host_date          => l_operation.host_date
      , i_inst_id            => l_acquirer.inst_id
      , i_network_id         => l_acquirer.network_id
      , i_merchant_id        => l_acquirer.merchant_id
      , i_terminal_id        => l_acquirer.terminal_id
      , i_terminal_number    => l_operation.terminal_number
      , i_split_hash         => l_acquirer.split_hash
      , i_without_checks     => com_api_const_pkg.TRUE
    );

    -- In the case of own card, a H2H mesasge is a presentment for earlier loaded (via posting file)
    -- authorization, so no more authorization should be created for that message
    if l_is_own_card = com_api_const_pkg.FALSE then
        save_auth(
            i_fin_rec         => i_fin_rec
          , i_resp_code       => o_resp_code
          , io_tag_value_tab  => io_tag_value_tab
        );
    end if;

    o_resp_code := nvl(o_resp_code, aup_api_const_pkg.RESP_CODE_OK);

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ' >> o_resp_code [#1]'
      , i_env_param1  => o_resp_code
    );
end create_operation;

procedure validate_message(
    i_fin_rec               in             h2h_api_type_pkg.t_h2h_clearing_rec
) is
    l_field_name                           com_api_type_pkg.t_oracle_name;
    l_field_value                          com_api_type_pkg.t_name;
begin
    l_field_name := 'msg_type';
    l_field_value := i_fin_rec.msg_type;

    if i_fin_rec.msg_type is not null then
        com_api_dictionary_pkg.check_article(
            i_dict       => opr_api_const_pkg.MESSAGE_TYPE_KEY
          , i_code       => i_fin_rec.msg_type
        );
    else
        raise com_api_error_pkg.e_application_error;
    end if;

    l_field_name := 'oper_type';
    l_field_value := i_fin_rec.oper_type;

    if i_fin_rec.oper_type is not null then
        com_api_dictionary_pkg.check_article(
            i_dict       => opr_api_const_pkg.OPERATION_TYPE_KEY
          , i_code       => i_fin_rec.oper_type
        );
    else
        raise com_api_error_pkg.e_application_error;
    end if;
exception
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error() in ('DICTIONARY_NOT_EXISTS'
                                                , 'CODE_NOT_CORRESPOND_TO_DICT'
                                                , 'CODE_NOT_EXISTS_IN_DICT')
        then
            com_api_error_pkg.raise_error(
                i_error      => 'H2H_INVALID_FIELD_VALUE'
              , i_env_param1 => l_field_name
              , i_env_param2 => l_field_value
              , i_env_param3 => iss_api_card_pkg.get_card_mask(i_card_number => i_fin_rec.card_number)
              , i_env_param4 => i_fin_rec.oper_amount_value
              , i_env_param5 => i_fin_rec.arn
              , i_env_param6 => i_fin_rec.oper_id
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'H2H_MANDATORY_FIELD_IS_MISSING'
              , i_env_param1 => l_field_name
              , i_env_param3 => iss_api_card_pkg.get_card_mask(i_card_number => i_fin_rec.card_number)
              , i_env_param4 => i_fin_rec.oper_amount_value
              , i_env_param5 => i_fin_rec.arn
              , i_env_param6 => i_fin_rec.oper_id
            );
        end if;
end validate_message;

end;
/
