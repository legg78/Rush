create or replace package body qpr_prc_aggregate_pkg is

procedure set_date_interval(
    io_start_date      in out date
  , io_end_date        in out date
) is
begin
    io_start_date := nvl(trunc(io_start_date), trunc(sysdate - 90, 'Q'));
    io_end_date   := nvl(trunc(io_end_date),   trunc(sysdate, 'Q') - com_api_const_pkg.ONE_SECOND);
end set_date_interval;

procedure refresh_aggregate_cards(
    i_start_date           in date
  , i_end_date             in date
) is
    l_start_date              date                       := i_start_date;
    l_end_date                date                       := i_end_date;
    l_estimated_count         com_api_type_pkg.t_long_id := 0;
begin
    savepoint sp_refresh_process;

    prc_api_stat_pkg.log_start;

    set_date_interval(
        io_start_date  => l_start_date
      , io_end_date    => l_end_date
    );

    trc_log_pkg.debug (
        i_text          => 'Starting refresh qpr aggregate cards data: between [#1] and [#2]'
      , i_env_param1    => to_char(l_start_date, 'dd-mm-yyyy hh24:mi:ss')
      , i_env_param2    => to_char(l_end_date,   'dd-mm-yyyy hh24:mi:ss')
    );

    delete from qpr_card_aggr
     where report_date between l_start_date and l_end_date;

    trc_log_pkg.debug (
        i_text          => 'Removed [#1] old data'
      , i_env_param1    => sql%rowcount
    );

    insert into qpr_card_aggr (
        card_id
      , card_type_id
      , report_date
    )
     select card_id
          , card_type_id
          , oper_date
       from qpr_detail
      where oper_date between l_start_date and l_end_date;

    l_estimated_count := sql%rowcount;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );

    prc_api_stat_pkg.log_end (
        i_excepted_total      => 0
      , i_processed_total     => l_estimated_count
      , i_result_code         => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        rollback to sp_refresh_process;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end refresh_aggregate_cards;

procedure refresh_detail_not_incoming (
    i_start_date              in date
  , i_end_date                in date
  , i_load_reversals          in com_api_type_pkg.t_boolean  :=  com_api_type_pkg.FALSE
  , i_participant_dest        in com_api_type_pkg.t_dict_value
  , i_use_token_pan           in com_api_type_pkg.t_boolean
  , o_estimated_count        out com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.info (
        i_text          => 'refresh_detail_not_incoming: Start'
    );

    insert into qpr_detail(
          oper_id
        , amount
        , currency
        , oper_date
        , oper_type
        , sttl_type
        , msg_type
        , status
        , oper_reason
        , is_reversal
        , mcc
        , merchant_country
        , acq_inst_bin
        , card_type_id
        , card_inst_id
        , card_network_id
        , card_country
        , card_product_id
        , card_perso_method_id
        , card_bin
        , card_number
        , acq_inst_id
        , card_data_input_mode
        , terminal_number
        , is_iss
        , is_acq
        , account_funding_source
        , crdh_presence
        , match_id
        , visa_bin
        , card_id
        , original_id
        , business_application_id
    )
    -- Us-on-Us and Outgoing operations only: Visa, MasterCard and others
    select o.id                                                  as oper_id
         , nvl2(o.sttl_amount, o.sttl_amount, o.oper_amount)     as amount
         , nvl2(o.sttl_amount, o.sttl_currency, o.oper_currency) as currency
         , trunc(o.oper_date)                                    as oper_date
         , o.oper_type
         , /*case when o.acq_inst_bin = '001300' and op2.inst_id = 9947 then 'STTT0010'  -- [***]
                else*/ o.sttl_type
           --    end sttl_type
         , o.msg_type
         , o.status
         , o.oper_reason
         , o.is_reversal
         , o.mcc
         , o.merchant_country
         , o.acq_inst_bin
         , ct.id                                                 as card_type_id
         , case
                when iss_sttl.element_value is not null then op.card_inst_id
                when o.sttl_type is not null then op2.inst_id
                else op.card_inst_id
           end                                                   as card_inst_id
         , ct.network_id
         , op.card_country
         , (select ic.product_id
              from prd_contract ic
             where ic.id = card.contract_id
           )                                                     as product_id
         , card.perso_method_id
         , nvl2(iss_sttl.element_value, substr(oc.card_number, 1, 6), null) as card_bin
         , oc.card_number
         , op2.inst_id                                           as acq_inst_id
         , aa.card_data_input_mode
         , o.terminal_number
         , nvl2(iss_sttl.element_value, 1, 0)                    as is_iss
         , 1                                                     as is_acq
         , to_char(null)                                         as account_funding_source
         , nvl((select '1'
                  from vis_fin_message f
                 where f.id               = aa.id
                   and f.crdh_id_method  in (' ','4')
                   and f.electr_comm_ind in ('1','4')), '0')     as crdh_presence
         , o.match_id
         , case
               when i_use_token_pan = com_api_type_pkg.TRUE
               then substr(iss_api_token_pkg.decode_card_number(
                        i_card_number => oc.card_number
                      , i_mask_error  => com_api_type_pkg.TRUE
                    ), 1, 9)
               else substr(oc.card_number, 1, 9)
           end                                                   as visa_bin
         , op.card_id
         , o.original_id
         , case
               when o.oper_type in (select element_value from com_array_element where array_id = 10000122)
               then (select v.tag_value
                       from aup_tag_value v
                      where v.auth_id = o.id
                        and v.tag_id = 55)
               else null
           end                                                   as business_application_id
      from opr_operation      o
         , aut_auth           aa
         , opr_participant    op
         , opr_participant    op2
         , opr_card           oc
         , (
               select cc.id
                    , cc.contract_id
                    , cc.card_type_id
                    , (select max (perso_method_id) keep (dense_rank first order by seq_number desc) from iss_card_instance ci where ci.card_id = cc.id) as perso_method_id
                 from iss_card cc
           )                  card
         , net_card_type      ct
         , (select element_value from com_array_element where array_id = 10000012) iss_sttl
     where trunc(o.oper_date)   between i_start_date and i_end_date
       and o.sttl_type         in (select element_value from com_array_element where array_id = 10000013)
       and o.msg_type          in (opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION, opr_api_const_pkg.MESSAGE_TYPE_COMPLETION, 'MSGTFPST')
       and (i_load_reversals    = com_api_type_pkg.TRUE or o.is_reversal = com_api_type_pkg.FALSE)
       and o.oper_type         in (select element_value from com_array_element where array_id = 10000014)
       and o.sttl_type          = iss_sttl.element_value(+)
       and o.status            in (select element_value from com_array_element where array_id = 10000020)
       and aa.id(+)             = o.id
       and op.oper_id           = o.id
       and op.participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER, i_participant_dest)
       and op2.oper_id          = o.id
       and op2.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and oc.oper_id           = op.oper_id
       and oc.participant_type  = op.participant_type
       and card.id(+)           = op.card_id
       and ct.id                = coalesce(card.card_type_id, op.card_type_id);

    o_estimated_count := sql%rowcount;

    trc_log_pkg.info (
        i_text          => 'refresh_detail_not_incoming: Finish. count [#1]'
      , i_env_param1    => o_estimated_count
    );

end refresh_detail_not_incoming;

procedure refresh_detail_visa_incoming (
    i_start_date              in date
  , i_end_date                in date
  , i_load_reversals          in com_api_type_pkg.t_boolean  :=  com_api_type_pkg.FALSE
  , i_participant_dest        in com_api_type_pkg.t_dict_value
  , i_use_token_pan           in com_api_type_pkg.t_boolean
  , o_estimated_count        out com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.info (
        i_text          => 'refresh_detail_visa_incoming: Start'
    );

    insert into qpr_detail(
          oper_id
        , amount
        , currency
        , oper_date
        , oper_type
        , sttl_type
        , msg_type
        , status
        , oper_reason
        , is_reversal
        , mcc
        , merchant_country
        , acq_inst_bin
        , card_type_id
        , card_inst_id
        , card_network_id
        , card_country
        , card_product_id
        , card_perso_method_id
        , card_bin
        , card_number
        , acq_inst_id
        , card_data_input_mode
        , terminal_number
        , is_iss
        , is_acq
        , account_funding_source
        , crdh_presence
        , match_id
        , visa_bin
        , card_id
        , original_id
        , trans_code_qualifier
        , pos_environment
        , business_application_id
    )
    -- Incoming Visa operations only
    select o.id                                                   as oper_id
         , nvl2(o.sttl_amount, o.sttl_amount, o.oper_amount)      as amount
         , nvl2(o.sttl_amount, o.sttl_currency, o.oper_currency)  as currency
         , trunc(vf.sttl_date)                                    as oper_date
         , o.oper_type
         , /*case when o.acq_inst_bin = '001300' and op2.inst_id = 9947 then 'STTT0010'  -- [***]
                else*/ o.sttl_type
           --end sttl_type
         , o.msg_type
         , o.status
         , o.oper_reason
         , o.is_reversal
         , o.mcc
         , o.merchant_country
         , nvl2(acq_sttl.element_value, o.acq_inst_bin, null)    as acq_inst_bin
         , ct.id                                                 as card_type_id
         , case
                when iss_sttl.element_value is not null then op.card_inst_id
                when acq_sttl.element_value is not null then op2.inst_id
                else op.card_inst_id
           end                                                   as card_inst_id
         , ct.network_id
         , op.card_country
         , (select ic.product_id
              from prd_contract ic
             where ic.id = card.contract_id
           )                                                     as product_id
         , card.perso_method_id
         , nvl2(iss_sttl.element_value, substr(oc.card_number, 1, 6), null) as card_bin
         , oc.card_number
         , op2.inst_id                                           as acq_inst_id
         , nvl2(vfm.cryptogram, 'F227000C', null)                as card_data_input_mode
         , nvl2(acq_sttl.element_value, o.terminal_number, null) as terminal_number
         , nvl2(iss_sttl.element_value, 1, 0)                    as is_iss
         , case when acq_sttl.element_value is not null then 1
                --when o.acq_inst_bin = '001300' and op2.inst_id = 9947 then 1  -- [***]
                else 0
           end                                                   as is_acq
         , to_char(null)                                         as account_funding_source
         , to_char(null)                                         as crdh_presence
         , o.match_id
         , case
               when i_use_token_pan = com_api_type_pkg.TRUE
               then substr(iss_api_token_pkg.decode_card_number(
                        i_card_number => oc.card_number
                      , i_mask_error  => com_api_type_pkg.TRUE
                    ), 1, 9)
               else substr(oc.card_number, 1, 9)
           end                                                   as visa_bin
         , op.card_id
         , o.original_id
         , vfm.trans_code_qualifier
         , decode(trim(vfm.pos_environment), 'R', 'R', null)     as pos_environment
         , vfm.business_application_id
      from vis_file vf
         , opr_operation o
         , vis_fin_message vfm
         , opr_participant op
         , opr_participant op2
         , opr_card oc
         , (
               select cc.id
                    , cc.contract_id
                    , cc.card_type_id
                    , (select max (perso_method_id) keep (dense_rank first order by seq_number desc) from iss_card_instance ci where ci.card_id = cc.id) as perso_method_id
                 from iss_card cc
           ) card
         , net_card_type ct
         , (select element_value from com_array_element where array_id = 10000012) iss_sttl
         , (select element_value from com_array_element where array_id = 10000013) acq_sttl
     where trunc(vf.sttl_date)  between i_start_date and i_end_date
       and vf.is_incoming       = com_api_type_pkg.TRUE
       and o.incom_sess_file_id = vf.session_file_id
       and o.msg_type          in (opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT, opr_api_const_pkg.MESSAGE_TYPE_PARTIAL_AMOUNT, opr_api_const_pkg.MESSAGE_TYPE_PART_AMOUNT_COMPL)
       and (i_load_reversals    = com_api_type_pkg.TRUE or o.is_reversal = com_api_type_pkg.FALSE)
       and o.oper_type         in (select element_value from com_array_element where array_id = 10000014)
       and o.sttl_type          = iss_sttl.element_value(+)
       and o.sttl_type          = acq_sttl.element_value(+)
       and o.status            in (select element_value from com_array_element where array_id = 10000020)
       and vfm.id               = o.id
       and op.oper_id           = o.id
       and op.participant_type  in (com_api_const_pkg.PARTICIPANT_ISSUER, i_participant_dest)
       and op2.oper_id          = o.id
       and op2.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and oc.oper_id           = op.oper_id
       and oc.participant_type  = op.participant_type
       and card.id(+)           = op.card_id
       and ct.id                = coalesce(card.card_type_id, op.card_type_id);

    o_estimated_count := sql%rowcount;

    trc_log_pkg.info (
        i_text          => 'refresh_detail_visa_incoming: Finish. count [#1]'
      , i_env_param1    => o_estimated_count
    );

end refresh_detail_visa_incoming;

procedure refresh_detail_mc_incoming (
    i_start_date              in date
  , i_end_date                in date
  , i_load_reversals          in com_api_type_pkg.t_boolean  :=  com_api_type_pkg.FALSE
  , i_participant_dest        in com_api_type_pkg.t_dict_value
  , i_use_token_pan           in com_api_type_pkg.t_boolean
  , o_estimated_count        out com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.info (
        i_text          => 'refresh_detail_mc_incoming: Start'
    );

    insert into qpr_detail(
          oper_id
        , amount
        , currency
        , oper_date
        , oper_type
        , sttl_type
        , msg_type
        , status
        , oper_reason
        , is_reversal
        , mcc
        , merchant_country
        , acq_inst_bin
        , card_type_id
        , card_inst_id
        , card_network_id
        , card_country
        , card_product_id
        , card_perso_method_id
        , card_bin
        , card_number
        , acq_inst_id
        , card_data_input_mode
        , terminal_number
        , is_iss
        , is_acq
        , account_funding_source
        , crdh_presence
        , match_id
        , visa_bin
        , card_id
        , original_id
    )
    -- Incoming MasterCard operations only
    select o.id                                                  as oper_id
         , nvl2(o.sttl_amount, o.sttl_amount,   o.oper_amount)   as amount
         , nvl2(o.sttl_amount, o.sttl_currency, o.oper_currency) as currency
         , trunc(mf.p0159_8)                                     as oper_date
         , o.oper_type
         , /*case
               when o.acq_inst_bin = '001300' and op2.inst_id = 9947 then 'STTT0010'  -- [***]
               else*/ o.sttl_type
           --end sttl_type
         , o.msg_type
         , o.status
         , o.oper_reason
         , o.is_reversal
         , o.mcc
         , o.merchant_country
         , nvl2(acq_sttl.element_value, o.acq_inst_bin, null)    as acq_inst_bin
         , ct.id                                                 as card_type_id
         , case
                when iss_sttl.element_value is not null then op.card_inst_id
                when acq_sttl.element_value is not null then op2.inst_id
                else op.card_inst_id
           end                                                   as card_inst_id
         , ct.network_id
         , op.card_country
         , (select ic.product_id
              from prd_contract ic
             where ic.id = card.contract_id
           )                                                     as product_id
         , card.perso_method_id
         , nvl2(iss_sttl.element_value, substr(oc.card_number, 1, 6), null) as card_bin
         , oc.card_number
         , op2.inst_id                                           as acq_inst_id
         , mf.de022_7                                            as card_data_input_mode
         , nvl2(acq_sttl.element_value, o.terminal_number, null) as terminal_number
         , nvl2(iss_sttl.element_value, 1, 0)                    as is_iss
         , case when acq_sttl.element_value is not null then 1
                --when o.acq_inst_bin = '001300' and op2.inst_id = 9947 then 1  -- [***]
                else 0
           end                                                   as is_acq
         , to_char(null)                                         as account_funding_source
         , to_char(null)                                         as crdh_presence
         , o.match_id
         , case
               when i_use_token_pan = com_api_type_pkg.TRUE
               then substr(iss_api_token_pkg.decode_card_number(
                        i_card_number => oc.card_number
                      , i_mask_error  => com_api_type_pkg.TRUE
                    ), 1, 9)
               else substr(oc.card_number, 1, 9)
           end                                                   as visa_bin
         , op.card_id
         , o.original_id
      from mcw_fin mf
         , opr_operation       o
         , opr_participant     op
         , opr_participant     op2
         , opr_card            oc
         , (
               select cc.id
                    , cc.contract_id
                    , cc.card_type_id
                    , (select max (perso_method_id) keep (dense_rank first order by seq_number desc) from iss_card_instance ci where ci.card_id = cc.id) as perso_method_id
                 from iss_card cc
           )                   card
         , net_card_type       ct
         , (select element_value from com_array_element where array_id = 10000012) iss_sttl
         , (select element_value from com_array_element where array_id = 10000013) acq_sttl
     where mf.p0159_8           between i_start_date and i_end_date  -- Use index for the "mf.p0159_8" column.
       and mf.is_incoming       = com_api_type_pkg.TRUE
       and o.id                 = mf.id
       and o.msg_type          in (opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                                 , opr_api_const_pkg.MESSAGE_TYPE_PARTIAL_AMOUNT
                                 , opr_api_const_pkg.MESSAGE_TYPE_PART_AMOUNT_COMPL)
       and (i_load_reversals    = com_api_type_pkg.TRUE or o.is_reversal = com_api_type_pkg.FALSE)
       and o.oper_type         in (select element_value from com_array_element where array_id = 10000014)
       and o.sttl_type          = iss_sttl.element_value(+)
       and o.sttl_type          = acq_sttl.element_value(+)
       and o.status            in (select element_value from com_array_element where array_id = 10000020)
       and op.oper_id           = o.id
       and op.participant_type  in (com_api_const_pkg.PARTICIPANT_ISSUER, i_participant_dest)
       and op2.oper_id          = o.id
       and op2.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and oc.oper_id           = op.oper_id
       and oc.participant_type  = op.participant_type
       and card.id(+)           = op.card_id
       and ct.id                = coalesce(card.card_type_id, op.card_type_id);

    o_estimated_count := sql%rowcount;

    trc_log_pkg.info (
        i_text          => 'refresh_detail_mc_incoming: Finish. count [#1]'
      , i_env_param1    => o_estimated_count
    );

end refresh_detail_mc_incoming;

procedure update_detail(
    i_start_date              in date
  , i_end_date                in date
) is
    l_start_date                 date                       := i_start_date;
    l_end_date                   date                       := i_end_date;
    l_count                      com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.info (
        i_text          => 'update_detail: Start'
    );

    set_date_interval(
        io_start_date  => l_start_date
      , io_end_date    => l_end_date
    );

    trc_log_pkg.info (
        i_text                => 'update_detail. l_start_date [#1], l_end_date [#2]'
      , i_env_param1          => to_char(l_start_date, 'dd-mm-yyyy hh24:mi:ss')
      , i_env_param2          => to_char(l_end_date,   'dd-mm-yyyy hh24:mi:ss')
    );

    insert into qpr_detail_visa_bin (visa_bin)
      select distinct d.visa_bin
        from qpr_detail d
       where d.card_network_id = 1003;

    insert into qpr_detail_visa_bin (visa_bin)
    select distinct substr(cn.card_number, 1, 9) as card_bin
      from iss_card oc
         , iss_card_instance ci
         , net_card_type ct
         , iss_card_number cn
     where ci.card_id = oc.id
       and ci.seq_number = (select max(i.seq_number)
                              from iss_card_instance i
                             where i.card_id = ci.id)
       and ci.expir_date > i_end_date
       and nvl(ci.iss_date, trunc(i_end_date,'Q')) < i_end_date
       and ci.status in (iss_api_const_pkg.CARD_STATUS_VALID_CARD, iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED)
       and ct.network_id = 1003
       and ct.id = oc.card_type_id
       and cn.card_id = oc.id
     minus
    select visa_bin from qpr_detail_visa_bin;

    trc_log_pkg.debug (
        i_text          => 'update_detail: After inserting for qpr_detail_visa_bin'
    );

     update qpr_detail_visa_bin dvb
        set (account_funding_source, product_id) = (
                select case max(vbr.account_funding_source)
                          when 'C'
                          then 'CREDIT'
                          when 'D'
                          then 'DEBIT'
                          when 'R'
                          then 'DEBIT' --'DEFFERED DEBIT'
                          when 'P'
                          then 'PREPAID'
                          else null
                       end as account_funding_source
                     , max(trim(vbr.product_id))
                  from vis_bin_range vbr
                 where dvb.visa_bin between vbr.pan_low and vbr.pan_high
            );

    trc_log_pkg.debug (
        i_text          => 'update_detail: After updating for qpr_detail_visa_bin'
    );

    update qpr_detail d
       set (card_type_id, account_funding_source, product_id) = (
               select ct.id
                    , dvb.account_funding_source
                    , product_id
                 from qpr_detail_visa_bin dvb
                    , net_card_type ct
                where dvb.visa_bin = d.visa_bin
                  and case
                          when dvb.product_id = 'L'
                          then vis_api_const_pkg.QR_ELECTRON_CARD_TYPE
                          when dvb.product_id = 'V'
                          then vis_api_const_pkg.QR_V_PAY_CARD_TYPE
                          else d.card_type_id
                      end = ct.id
           )
         , d.trans_code_qualifier =
               coalesce(
                   d.trans_code_qualifier
                 , (select fi.trans_code_qualifier
                     from vis_fin_message fi
                    where fi.id = d.oper_id
                   )
               )
       where d.card_network_id = 1003
         and d.visa_bin is not null  -- Visa
         and d.oper_date between l_start_date and l_end_date;

    l_count := sql%rowcount;

    trc_log_pkg.info (
        i_text          => 'update_detail: Finish. count [#1]'
      , i_env_param1    => l_count
    );

    insert into qpr_detail_mc_bin (bin)
      select distinct d.visa_bin
        from qpr_detail d
       where d.card_network_id = 1002;

    trc_log_pkg.debug (
        i_text          => 'update_detail: After inserting for qpr_detail_mc_bin'
    );

     update qpr_detail_mc_bin dmb
        set (product_category) = (
          select
              max(case
                  when prod.product_category_code = 'C' then 'CREDIT' --Credit
                  when prod.product_category_code in ('D', 'P', 'O') then 'DEBIT' --Debit
                  when prod.product_category_code = 'N' then --Not applicable
                      case prod.product_category
                      when 'C' then 'CREDIT' --Credit
                      else 'DEBIT' --Debit
                      end
                  else 'DEBIT' --Debit
                  end
                  ) keep (dense_rank first order by decode(prod.licensed_product_id, bin.product_id, 0), bin.priority) as product_category
           from net_bin_range_index ind
              , mcw_bin_range bin
              , mcw_brand_product prod
          where ind.pan_prefix = substr(dmb.bin, 1, 5)
            and dmb.bin between substr(ind.pan_low,1,length(dmb.bin)) and substr(ind.pan_high,1,length(dmb.bin))
            and ind.pan_low = bin.pan_low
            and ind.pan_high = bin.pan_high
            and bin.product_id = prod.gcms_product_id
            and bin.brand = prod.card_program_id
        );

    update qpr_detail_mc_bin dmb
       set (product_category) = nvl((
               select case max(vbr.account_funding_source)
                         when 'C'
                         then 'CREDIT'
                         when 'D'
                         then 'DEBIT'
                         when 'R'
                         then 'DEBIT' --'DEFFERED DEBIT'
                         when 'P'
                         then 'PREPAID'
                         else null
                      end as account_funding_source
                 from vis_bin_range vbr
                where dmb.bin between vbr.pan_low and vbr.pan_high ),'CREDIT')
     where product_category is null;

    trc_log_pkg.debug (
        i_text          => 'update_detail: After updating for qpr_detail_mc_bin'
    );

    update qpr_detail d
       set (d.account_funding_source) = (
               select dmb.product_category
                 from qpr_detail_mc_bin dmb
                where dmb.bin = d.visa_bin
           )
       where d.card_network_id = 1002
         and d.visa_bin is not null  -- MC
         and d.oper_date between l_start_date and l_end_date;

    l_count := sql%rowcount;

    trc_log_pkg.info (
        i_text          => 'update_detail: Finish. count [#1]'
      , i_env_param1    => l_count
    );

end update_detail;

procedure refresh_detail(
    i_start_date           in date
  , i_end_date             in date
  , i_load_reversals       in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_start_date              date                       := i_start_date;
    l_end_date                date                       := i_end_date;
    l_load_reversals          com_api_type_pkg.t_boolean;
    l_estimated_count         com_api_type_pkg.t_long_id := 0;
    l_acquiring_count         com_api_type_pkg.t_long_id := 0;
    l_visa_issuing_count      com_api_type_pkg.t_long_id := 0;
    l_mc_issuing_count        com_api_type_pkg.t_long_id := 0;
    l_is_issuing              com_api_type_pkg.t_boolean;
    l_is_acquiring            com_api_type_pkg.t_boolean;
    l_participant_dest        com_api_type_pkg.t_dict_value;
    l_use_token_pan           com_api_type_pkg.t_boolean;
begin
    savepoint sp_refresh_process;

    trc_log_pkg.info (
        i_text                => 'qpr_prc_aggregate_pkg.refresh_detail. Start'
    );

    prc_api_stat_pkg.log_start;

    -- l_participant_dest := com_api_const_pkg.PARTICIPANT_DEST;  -- [***]

    set_date_interval(
        io_start_date  => l_start_date
      , io_end_date    => l_end_date
    );

    l_load_reversals := nvl(i_load_reversals,    com_api_type_pkg.FALSE);

    -- If tokenization isn't used then there is no sense to call decoding function
    -- in then select section to reduce count of SQL-PLSQL context switches
    l_use_token_pan :=
        case
            when iss_api_token_pkg.is_token_enabled() = com_api_type_pkg.TRUE
            then com_api_type_pkg.TRUE
            else com_api_type_pkg.FALSE
        end;

    execute immediate 'truncate table qpr_detail_visa_bin';
    execute immediate 'truncate table qpr_detail_mc_bin';

    select count(*)
      into l_is_issuing
      from com_array_element
     where array_id = 10000012
       and rownum = 1;

    select count(*)
      into l_is_acquiring
      from com_array_element
     where array_id = 10000013
       and rownum = 1;

    trc_log_pkg.info (
        i_text                => 'Start refresh_detail. l_start_date [#1], l_end_date [#2], l_load_reversals [#3], l_is_issuing [#4], l_is_acquiring [#5]'
      , i_env_param1          => to_char(l_start_date, 'dd-mm-yyyy hh24:mi:ss')
      , i_env_param2          => to_char(l_end_date,   'dd-mm-yyyy hh24:mi:ss')
      , i_env_param3          => l_load_reversals
      , i_env_param4          => l_is_issuing
      , i_env_param5          => l_is_acquiring
    );

    delete from qpr_detail
     where oper_date between l_start_date and l_end_date;

    trc_log_pkg.debug (
        i_text                => 'Removed [#1] old data'
      , i_env_param1          => sql%rowcount
    );

    if l_is_acquiring = com_api_type_pkg.TRUE then

        refresh_detail_not_incoming (
            i_start_date       => l_start_date
          , i_end_date         => l_end_date
          , i_load_reversals   => l_load_reversals
          , i_participant_dest => l_participant_dest
          , i_use_token_pan    => l_use_token_pan
          , o_estimated_count  => l_acquiring_count
        );

    end if;

    if l_is_issuing = com_api_type_pkg.TRUE then

        refresh_detail_visa_incoming (
            i_start_date      => l_start_date
          , i_end_date        => l_end_date
          , i_load_reversals  => l_load_reversals
          , i_participant_dest => l_participant_dest
          , i_use_token_pan    => l_use_token_pan
          , o_estimated_count => l_visa_issuing_count
        );

        refresh_detail_mc_incoming (
            i_start_date      => l_start_date
          , i_end_date        => l_end_date
          , i_load_reversals  => l_load_reversals
          , i_participant_dest => l_participant_dest
          , i_use_token_pan    => l_use_token_pan
          , o_estimated_count => l_mc_issuing_count
        );

    end if;

    update_detail(
        i_start_date => l_start_date
      , i_end_date   => l_end_date
    );

    l_estimated_count := l_acquiring_count + l_visa_issuing_count + l_mc_issuing_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_estimated_count
    );


    prc_api_stat_pkg.log_end (
        i_excepted_total      => 0
        , i_processed_total   => l_estimated_count
        , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.info (
        i_text                => 'Finish refresh_detail. l_start_date [#1], l_end_date [#2], l_load_reversals [#3], l_is_issuing [#4], l_is_acquiring [#5]'
      , i_env_param1          => to_char(l_start_date, 'dd-mm-yyyy hh24:mi:ss')
      , i_env_param2          => to_char(l_end_date,   'dd-mm-yyyy hh24:mi:ss')
      , i_env_param3          => l_load_reversals
      , i_env_param4          => l_is_issuing
      , i_env_param5          => l_is_acquiring
    );

exception
    when others then
        rollback to sp_refresh_process;

        prc_api_stat_pkg.log_end (
            i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end refresh_detail;

procedure refresh_aggregate(
    i_start_date           in date
  , i_end_date             in date
  , i_load_reversals       in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_start_date              date                       := i_start_date;
    l_end_date                date                       := i_end_date;
    l_load_reversals          com_api_type_pkg.t_boolean;
    l_estimated_count         com_api_type_pkg.t_long_id := 0;
begin
    savepoint sp_refresh_process;

    trc_log_pkg.info (
        i_text                => 'qpr_prc_aggregate_pkg.refresh_aggregate. Start'
    );

    prc_api_stat_pkg.log_start;

    set_date_interval(
        io_start_date  => l_start_date
      , io_end_date    => l_end_date
    );

    l_load_reversals :=  nvl(i_load_reversals, com_api_type_pkg.FALSE);

    trc_log_pkg.info (
        i_text                => 'refresh_aggregate. l_start_date [#1], l_end_date [#2], l_load_reversals [#3]'
      , i_env_param1          => to_char(l_start_date, 'dd-mm-yyyy hh24:mi:ss')
      , i_env_param2          => to_char(l_end_date,   'dd-mm-yyyy hh24:mi:ss')
      , i_env_param3          => l_load_reversals
    );

   delete from qpr_aggr
    where oper_date between l_start_date and l_end_date;

    insert into qpr_aggr (
        cnt
      , amount
      , currency
      , oper_date
      , oper_type
      , sttl_type
      , msg_type
      , status
      , oper_reason
      , is_reversal
      , mcc
      , merchant_country
      , acq_inst_bin
      , card_type_id
      , card_inst_id
      , card_network_id
      , card_country
      , card_product_id
      , card_perso_method_id
      , card_bin
      , acq_inst_id
      , card_data_input_mode
      , terminal_number
      , is_iss
      , is_acq
      , account_funding_source
      , crdh_presence
      , trans_code_qualifier
      , pos_environment
      , product_id
      , business_application_id
    )
    select count(o.oper_id)  as cnt
         , sum(o.amount)     as amount
         , o.currency
         , o.oper_date
         , o.oper_type
         , o.sttl_type
         , o.msg_type
         , o.status
         , o.oper_reason
         , o.is_reversal
         , o.mcc
         , o.merchant_country
         , o.acq_inst_bin
         , o.card_type_id
         , o.card_inst_id
         , o.card_network_id
         , o.card_country
         , o.card_product_id
         , o.card_perso_method_id
         , o.card_bin
         , o.acq_inst_id
         , o.card_data_input_mode
         , o.terminal_number
         , o.is_iss
         , o.is_acq
         , o.account_funding_source
         , o.crdh_presence
         , o.trans_code_qualifier
         , o.pos_environment
         , o.product_id
         , o.business_application_id
      from qpr_detail o
     where o.oper_date between l_start_date and l_end_date
       and (l_load_reversals = com_api_type_pkg.TRUE
            or o.is_reversal = com_api_type_pkg.FALSE)
     group by o.currency
            , o.oper_date
            , o.oper_type
            , o.sttl_type
            , o.msg_type
            , o.status
            , o.oper_reason
            , o.is_reversal
            , o.mcc
            , o.merchant_country
            , o.acq_inst_bin
            , o.card_type_id
            , o.card_inst_id
            , o.card_network_id
            , o.card_country
            , o.card_product_id
            , o.card_perso_method_id
            , o.card_bin
            , o.acq_inst_id
            , o.card_data_input_mode
            , o.terminal_number
            , case
                  when o.is_iss = com_api_type_pkg.TRUE
                  then o.sttl_type
                  else null
              end
            , case
                  when o.is_acq = com_api_type_pkg.TRUE
                  then o.sttl_type
                  else null
              end
            , o.is_iss
            , o.is_acq
            , o.account_funding_source
            , o.crdh_presence
            , o.trans_code_qualifier
            , o.pos_environment
            , o.product_id
            , o.business_application_id;

    l_estimated_count := sql%rowcount;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
    );

    prc_api_stat_pkg.log_end (
        i_excepted_total      => 0
        , i_processed_total   => l_estimated_count
        , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.info (
        i_text                => 'qpr_prc_aggregate_pkg.refresh_aggregate. Finish'
    );
exception
    when others then
        rollback to sp_refresh_process;

        prc_api_stat_pkg.log_end (
            i_result_code    => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end refresh_aggregate;

end qpr_prc_aggregate_pkg;
/
