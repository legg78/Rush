create or replace package BODY pos_api_report_pkg is
/*********************************************************
 *  POS reports API <br />
 *  Created by Nick (shalnov@bpcbt.com) at 11.09.2018 <br />
 *  Last changed by $Author: Nick $ <br />
 *  $LastChangedDate:: 2018-09-11 09:46:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 25841 $ <br />
 *  Module: pos_api_report_pkg <br />
 *  @headcom
 **********************************************************/

procedure pos_batch_unmatched(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id        default null
  , i_start_date        in     date                              default null
  , i_end_date          in     date                              default null
  , i_mode              in     com_api_type_pkg.t_dict_value
  , i_lang              in     com_api_type_pkg.t_dict_value     default null
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.pos_batch_unmatched: ';
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_start_date           date;
    l_end_date             date;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_header               xmltype;
    l_detail               xmltype;
    l_result               xmltype;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'inst [#1], start_date [#2], end_date [#3], mode [#4], lang [#5]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_start_date
      , i_env_param3 => i_end_date
      , i_env_param4 => i_mode
      , i_env_param5 => i_lang
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);

    select
        xmlelement(
            "header"
          , xmlelement("inst_id", l_inst_id)
          , xmlelement("inst", ost_ui_institution_pkg.get_inst_name(l_inst_id, l_lang))
          , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
          , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
          , xmlelement("mode", i_mode)
        ) r
    into
        l_header
    from
        dual;

    -- report body
    with msch as (
        -- determine matched/not matched
        select ba_op.id                 as ba_id
             , ba_op.msg_type           as ba_msg_type
             , ba_op.original_id        as ba_original_id
             , au_op.id                 as op_id
             , au_op.msg_type           as op_msg_type
             , case
                   when ba_op.id is null and au_op.id is not null
                       then 0
                   when ba_op.id is not null and au_op.id is null
                       then 0
                   when ba_op.id is not null and au_op.id is not null
                       then 1
               end                      as matched_status      -- 0 - not matched, 1 matched
          from (
                select ba.id
                     , ba.msg_type
                     , ba.original_id
                  from opr_operation ba
                  join opr_participant baop on baop.oper_id = ba.id
                                           and baop.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                 where ba.msg_type = opr_api_const_pkg.MESSAGE_TYPE_POS_BATCH
                   and ba.oper_date between l_start_date and l_end_date
                   and ba.status in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED)
               ) ba_op
          full join (
                select o.id
                     , o.msg_type
                  from opr_operation o
                  join opr_participant op on op.oper_id = o.id
                                         and op.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                 where o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                   and o.oper_date between l_start_date and l_end_date
                   and o.status in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED)
                   and exists (
                           select 1
                             from acq_terminal a
                            where a.id = op.terminal_id
                              and a.pos_batch_support = com_api_const_pkg.TRUE
                       )
               ) au_op on ba_op.original_id = au_op.id),
      rawdata as (
        select t.id          as oper_id
             , t.msg_type    as message_type
             , t.matched_status
             , o.oper_date
             , com_api_currency_pkg.get_amount_str(
                   i_amount     => o.oper_amount
                 , i_curr_code  => o.oper_currency
                 , i_mask_error => com_api_const_pkg.TRUE
               )              as oper_amount
             , o.terminal_number
             , o.merchant_number
             , o.merchant_name
             , iss_api_card_pkg.get_card_mask(
                   i_card_number => oc.card_number
               )              as card_mask
             , o.original_id
             , o.is_reversal
             , o.mcc
             , a.external_orig_id
             , a.external_auth_id
             , get_label_text(
                  i_name => o.status
                , i_lang => l_lang
               )              as status
          from (
            select case when matched_status = 1 then
                            ba_id
                        else nvl(ba_id, op_id)
                   end as id
                 , case when matched_status = 1 then
                            ba_msg_type
                        else nvl(ba_msg_type, op_msg_type)
                   end as msg_type
                 , matched_status
              from msch) t
           join opr_operation o  on o.id = t.id
           left join aut_auth a  on a.id = t.id
           left join opr_card oc on oc.oper_id = t.id
                                and oc.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
    )
    select
        xmlelement(
            "operations"
          , xmlagg(
                xmlelement(
                    "operation"
                   , xmlelement("oper_id"           , oper_id)
                   , xmlelement("message_type"      , message_type)
                   , xmlelement("oper_date"         , oper_date)
                   , xmlelement("oper_amount"       , oper_amount)  -- amount + currency
                   , xmlelement("terminal_number"   , terminal_number)
                   , xmlelement("merchant_number"   , merchant_number)
                   , xmlelement("merchant_name"     , merchant_name)
                   , xmlelement("card_mask"         , card_mask)
                   , xmlelement("external_orig_id"  , external_orig_id)
                   , xmlelement("external_auth_id"  , external_auth_id)
                   , xmlelement("original_id"       , original_id)
                   , xmlelement("is_reversal"       , is_reversal)
                   , xmlelement("mcc"               , mcc)
                   , xmlelement("status"            , status)
                )
           )
        ) r
    into
        l_detail
    from rawdata
   where matched_status = case i_mode
                              when 'NBCRRMCH' then 1
                              when 'NBCRRMSM' then 0
                              else null
                          end;

   if l_detail.getclobval = '<operations></operations>' then
       select
        xmlelement(
            "operations"
          , xmlagg(
                xmlelement(
                    "operation"
                   , xmlelement("oper_id"           , null)
                   , xmlelement("message_type"      , null)
                   , xmlelement("oper_date"         , null)
                   , xmlelement("oper_amount"       , null)
                   , xmlelement("terminal_number"   , null)
                   , xmlelement("merchant_number"   , null)
                   , xmlelement("merchant_name"     , null)
                   , xmlelement("card_mask"         , null)
                   , xmlelement("external_orig_id"  , null)
                   , xmlelement("external_auth_id"  , null)
                   , xmlelement("original_id"       , null)
                   , xmlelement("is_reversal"       , null)
                   , xmlelement("mcc"               , null)
                   , xmlelement("status"            , null)
                )
           )
        ) r
       into
           l_detail
       from dual;
   end if;

    select
        xmlelement(
            "report"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'end'
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || sqlerrm
        );
        raise;
end;

end pos_api_report_pkg;
/
