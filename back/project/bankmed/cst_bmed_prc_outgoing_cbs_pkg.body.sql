create or replace package body cst_bmed_prc_outgoing_cbs_pkg is
/**********************************************************
 * Custom handlers for uploading operations in to CBS
 *
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 30.01.2017<br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_BMED_PRC_OUTGOING_CBS_PKG
 * @headcom
 **********************************************************/
procedure create_cbs_file(
    io_file_body_tab       in out nocopy cst_bmed_type_pkg.t_cbs_outg_file_body
) is
    PROC_NAME              constant com_api_type_pkg.t_name := 'create_cbs_file: ';

    l_session_file_id      com_api_type_pkg.t_long_id;
    l_file_content         clob;
begin

    trc_log_pkg.debug(
        i_text         => PROC_NAME || 'Start'
    );

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    trc_log_pkg.debug(
        i_text          => PROC_NAME || 'open file success, file_id: [#1]'
      , i_env_param1    => l_session_file_id
    );

    cst_bmed_cbs_files_format_pkg.generate_cbs_out_file(
        io_body_tab     => io_file_body_tab
      , o_file_content  => l_file_content
    );

    trc_log_pkg.debug(
        i_text          => PROC_NAME || 'created content of the outgoing file'
    );

    prc_api_file_pkg.put_file(
        i_sess_file_id  => l_session_file_id
      , i_clob_content  => l_file_content
    );

    trc_log_pkg.debug(
        i_text          => PROC_NAME || 'content put into file success'
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text          => PROC_NAME || 'file close success'
    );

exception
    when others then
       trc_log_pkg.debug(
            i_text        => PROC_NAME || 'Finished with errors: [#1] [#2]'
          , i_env_param1  => sqlcode
          , i_env_param2  => sqlerrm
        );

        raise;
end;

procedure unloading_cbs_file(
    i_file_type                 in     com_api_type_pkg.t_dict_value
  , i_inst_id                   in     com_api_type_pkg.t_inst_id
  , i_date_type                 in     com_api_type_pkg.t_dict_value
  , i_start_date                in     date                            default null
  , i_end_date                  in     date                            default null
  , i_shift_from                in     com_api_type_pkg.t_tiny_id      default 0
  , i_shift_to                  in     com_api_type_pkg.t_tiny_id      default 0
  , i_sttl_day                  in     com_api_type_pkg.t_medium_id    default null
  , i_array_settl_type_id       in     com_api_type_pkg.t_medium_id    default null
  , i_array_operations_type_id  in     com_api_type_pkg.t_medium_id    default null
  , i_array_trans_type_id       in     com_api_type_pkg.t_medium_id    default null
  , i_full_export               in     com_api_type_pkg.t_boolean      default null
) is
    PROC_NAME     constant com_api_type_pkg.t_name      := lower($$PLSQL_UNIT) || '.unloading_cbs_file: ';

    l_full_export          com_api_type_pkg.t_boolean   := nvl(i_full_export, com_api_type_pkg.FALSE);

    l_aggregated_count     com_api_type_pkg.t_long_id   := 0;
    l_non_aggregated_count com_api_type_pkg.t_long_id   := 0;

    l_estimated_count      com_api_type_pkg.t_long_id   := 0;
    l_processed_count      com_api_type_pkg.t_long_id   := 0;
    l_excepted_count       com_api_type_pkg.t_long_id   := 0;
    l_rejected_count       com_api_type_pkg.t_long_id   := 0;
    i                      com_api_type_pkg.t_count     := 1;

    l_sttl_day             com_api_type_pkg.t_medium_id := i_sttl_day;
    l_sttl_date            date;
    l_file_body            cst_bmed_type_pkg.t_cbs_outg_file_body;
    l_file_additional      cst_bmed_type_pkg.t_cbs_outg_file_body;

    l_evt_objects_tab      num_tab_tpt := num_tab_tpt();
    l_entry_ids_tab        num_tab_tpt := num_tab_tpt();
    l_entry_tab            num_tab_tpt := num_tab_tpt();
    l_sysdate              date;
    l_start_date           date;
    l_end_date             date;
    l_container_id         com_api_type_pkg.t_long_id;
begin

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text        => PROC_NAME || 'Start'
    );

    l_sysdate    := com_api_sttl_day_pkg.get_sysdate;
    l_start_date := trunc(coalesce(i_start_date, l_sysdate), 'DD');
    l_end_date   := nvl(trunc(i_end_date, 'DD'), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    l_start_date := l_start_date + nvl(i_shift_from, 0);
    l_end_date   := l_end_date   + nvl(i_shift_to,   0);
    
    l_container_id  :=  prc_api_session_pkg.get_container_id;

    trc_log_pkg.debug(
        i_text        => PROC_NAME || ' l_full_export [#1]'
      , i_env_param1  => l_full_export
    );

    if l_full_export = com_api_type_pkg.TRUE then

        if i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK then

            if l_sttl_day is null then
                select max(sttl_day - 1)
                  into l_sttl_day
                  from com_settlement_day
                 where inst_id  in (i_inst_id, ost_api_const_pkg.DEFAULT_INST);
            end if;

            select trunc(max(sttl_date))
              into l_sttl_date
              from com_settlement_day
             where inst_id  in (i_inst_id, ost_api_const_pkg.DEFAULT_INST)
               and sttl_day  = l_sttl_day;

            trc_log_pkg.debug(
                i_text        => PROC_NAME || ' l_sttl_date [#1], l_sttl_day [#2]'
              , i_env_param1  => to_char(l_sttl_date, com_api_const_pkg.LOG_DATE_FORMAT)
              , i_env_param2  => to_char(l_sttl_day)
            );

        elsif i_date_type in (com_api_const_pkg.DATE_PURPOSE_PROCESSING
                            , com_api_const_pkg.DATE_PURPOSE_HOST)
        then

            trc_log_pkg.debug(
                i_text        => PROC_NAME || ' l_start_date [#1], l_end_date [#2], i_shift_from [#3], i_shift_to [#4]'
              , i_env_param1  => to_char(l_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
              , i_env_param2  => to_char(l_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
              , i_env_param3  => to_char(nvl(i_shift_from, 0))
              , i_env_param4  => to_char(nvl(i_shift_to,   0))
            );

        else
            trc_log_pkg.debug(
                i_text        => PROC_NAME || ' i_date_type [#1]'
              , i_env_param1  => i_date_type
            );

        end if;

        select e.id
          bulk collect into l_entry_tab
          from acc_entry     e
             , acc_account   a
             , acc_macros    m
             , opr_operation o
         where (
                   (
                       i_date_type = com_api_const_pkg.DATE_PURPOSE_BANK
                       and e.sttl_date = l_sttl_date
                   )
                   or
                   (
                       i_date_type = com_api_const_pkg.DATE_PURPOSE_PROCESSING
                       and e.posting_date between l_start_date and l_end_date
                   )
                   or
                   (
                       i_date_type = com_api_const_pkg.DATE_PURPOSE_HOST
                       and o.host_date between l_start_date and l_end_date
                   )
               )
           and a.id                = e.account_id
           and a.inst_id           = i_inst_id
           and m.id                = e.macros_id
           and m.entity_type       = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and o.id                = m.object_id
           and e.amount           != 0
           and (i_array_settl_type_id      is null or o.sttl_type        in (select element_value from com_array_element where array_id = i_array_settl_type_id     ))
           and (i_array_operations_type_id is null or o.oper_type        in (select element_value from com_array_element where array_id = i_array_operations_type_id))
           and (i_array_trans_type_id      is null or e.transaction_type in (select element_value from com_array_element where array_id = i_array_trans_type_id     ));

    else
        select e.id
             , eo.id
          bulk collect into 
               l_entry_tab
             , l_evt_objects_tab
          from evt_event_object eo
             , acc_entry        e
             , acc_macros       m
             , opr_operation    o
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_BMED_PRC_OUTGOING_CBS_PKG.UNLOADING_CBS_FILE'
           and eo.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and eo.eff_date        <= l_sysdate
           and eo.inst_id          = i_inst_id
           and (eo.container_id    = l_container_id  or eo.container_id is null)
           and o.id                = eo.object_id
           and m.id                = e.macros_id
           and m.entity_type       = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and o.id                = m.object_id
           and e.amount           != 0
           and (i_array_settl_type_id      is null or o.sttl_type        in (select element_value from com_array_element where array_id = i_array_settl_type_id     ))
           and (i_array_operations_type_id is null or o.oper_type        in (select element_value from com_array_element where array_id = i_array_operations_type_id))
           and (i_array_trans_type_id      is null or e.transaction_type in (select element_value from com_array_element where array_id = i_array_trans_type_id     ));

    end if;

    trc_log_pkg.debug(
        i_text        => PROC_NAME || ' l_entry_tab.count [#1]'
      , i_env_param1  => l_entry_tab.count
    );

    if l_entry_tab.count > 0 then

        -- Aggregated part
        i := 1;
        for aggr in (
            select x.account_number
                 , case
                       when x.balance_impact > 0 or sum(x.amount) = 0
                       then '+'
                       else '-'
                   end as dir_transaction_amount
                 , case
                       when x.currency = cst_bmed_api_const_pkg.LBPOUND
                       then trunc(sum(x.amount) / 100)
                       else sum(x.amount)
                   end as transaction_amount
                 , row_number() over(order by 1) as record_number
                 , count(distinct x.oper_id) oper_count
                 , x.narrative_text_1
                 , x.narrative_text_2
                 , x.narrative_text_3
                 , x.reference_value
                 , sum(x.amount_per_month_acct_curr) as amount_per_month_acct_curr
                 , sum(x.amount_per_month_usd_curr) as amount_per_month_usd_curr
                 , sum(x.amount_per_month_oper_curr) as amount_per_month_oper_curr
                 , sum(x.amount_per_month_lbp_curr) as amount_per_month_lbp_curr
                 , max(x.file_name) as file_name
              from (
                  select a.account_number
                       , e.sttl_date
                       , o.sttl_type
                       , o.oper_type
                       , e.transaction_type
                       , o.fee_type
                       , e.balance_impact
                       , e.amount
                       , e.currency
                       , cst_bmed_cbs_files_format_pkg.replace_tags_in_label(
                             i_label_id         => n.narrative_label_1
                           , i_is_aggregated    => com_api_type_pkg.TRUE
                           , i_sttl_date        => l_sysdate
                           , i_fee_type         => o.fee_type
                           , i_count            => null
                         ) as narrative_text_1
                       , cst_bmed_cbs_files_format_pkg.replace_tags_in_label(
                             i_label_id         => n.narrative_label_2
                           , i_is_aggregated    => com_api_type_pkg.TRUE
                           , i_sttl_date        => l_sysdate
                           , i_fee_type         => o.fee_type
                           , i_count            => null
                         ) as narrative_text_2
                       , cst_bmed_cbs_files_format_pkg.replace_tags_in_label(
                             i_label_id         => n.narrative_label_3
                           , i_is_aggregated    => com_api_type_pkg.TRUE
                           , i_sttl_date        => l_sysdate
                           , i_fee_type         => o.fee_type
                           , i_count            => null
                         ) as narrative_text_3
                       , n.reference_value
                       , o.id as oper_id
                       , case
                             when a.currency = o.sttl_currency
                             then o.sttl_amount
                             else com_api_rate_pkg.convert_amount(
                                      i_src_amount      => o.sttl_amount
                                    , i_src_currency    => o.sttl_currency
                                    , i_dst_currency    => a.currency
                                    , i_rate_type       => 'RTTPISS'
                                    , i_inst_id         => a.inst_id
                                    , i_eff_date        => e.posting_date
                                    , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_BUYING
                                  )
                         end as amount_per_month_acct_curr
                       , case
                             when o.sttl_currency = com_api_currency_pkg.USDOLLAR
                             then o.sttl_amount
                             else com_api_rate_pkg.convert_amount(
                                      i_src_amount      => o.sttl_amount
                                    , i_src_currency    => o.sttl_currency
                                    , i_dst_currency    => com_api_currency_pkg.USDOLLAR
                                    , i_rate_type       => 'RTTPISS'
                                    , i_inst_id         => a.inst_id
                                    , i_eff_date        => e.posting_date
                                    , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_BUYING
                                  )
                         end as amount_per_month_usd_curr
                       , o.oper_amount as amount_per_month_oper_curr
                       , case
                             when e.currency = cst_bmed_api_const_pkg.LBPOUND
                             then 0
                             else trunc(
                                      com_api_rate_pkg.convert_amount(
                                          i_src_amount      => e.amount
                                        , i_src_currency    => e.currency
                                        , i_dst_currency    => cst_bmed_api_const_pkg.LBPOUND
                                        , i_rate_type       => 'RTTPISS'
                                        , i_inst_id         => a.inst_id
                                        , i_eff_date        => e.posting_date
                                        , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_BUYING
                                      ) / 100
                                  )
                         end as amount_per_month_lbp_curr
                       , fn.file_name
                    from acc_entry   e
                       , acc_account a
                       , acc_macros  m
                       , (
                             select oo.id
                                  , oo.sttl_type
                                  , oo.oper_type
                                  , decode(substr(oo.oper_reason, 1, 4), fcl_api_const_pkg.FEE_TYPE_STATUS_KEY, oo.oper_reason, null) as fee_type
                                  , coalesce(oo.sttl_amount, oo.oper_amount) sttl_amount
                                  , case when oo.sttl_amount is null
                                         then oo.oper_currency
                                         else oo.sttl_currency
                                    end as sttl_currency
                                  , oo.oper_amount
                                  , oo.oper_currency
                                  , oo.oper_date
                               from opr_operation oo
                         ) o
                       , opr_card c
                       , cst_bmed_cbs_narrative n
                       , (select first_value(sf.file_name) over (order by sf.file_date desc) as file_name
                               , row_number() over (order by sf.file_date desc) as rn 
                            from prc_session_file sf
                           where sf.id in (select o.incom_sess_file_id 
                                             from acc_entry e
                                                , acc_macros m
                                                , opr_operation o
                                            where m.id          = e.macros_id 
                                              and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                              and o.id          = m.object_id 
                                              and e.id          in (select column_value from table(cast(l_entry_tab as num_tab_tpt)))
                                          )
                         ) fn
                   where e.id                 in (select column_value from table(cast(l_entry_tab as num_tab_tpt)))
                     and a.id                  = e.account_id
                     and m.id                  = e.macros_id
                     and m.entity_type         = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                     and o.id                  = m.object_id
                     and c.oper_id             = o.id
                     and c.participant_type    = com_api_const_pkg.PARTICIPANT_ISSUER
                     and n.file_type           = i_file_type
                     and n.need_aggregate      = com_api_type_pkg.TRUE
                     and (n.oper_type          = o.oper_type        or n.oper_type        is null)
                     and (n.sttl_type          = o.sttl_type        or n.sttl_type        is null)
                     and (n.transaction_type   = e.transaction_type or n.transaction_type is null)
                     and (n.fee_type           = o.fee_type         or n.fee_type         is null or o.fee_type is null)
                     and fn.rn                 = 1
                  ) x
             group by x.account_number
                    , x.balance_impact
                    , x.narrative_text_1
                    , x.narrative_text_2
                    , x.narrative_text_3
                    , x.reference_value
                    , x.currency
            )
        loop
            -- Fill file body
            l_file_body(i) := cst_bmed_cbs_files_format_pkg.generate_cbs_out_row(
                                  i_file_type                    => i_file_type
                                , i_sttl_date                    => l_sysdate
                                , i_account_number               => aggr.account_number
                                , i_dir_transaction_amount       => aggr.dir_transaction_amount
                                , i_transaction_amount           => aggr.transaction_amount
                                , i_is_aggregated                => com_api_type_pkg.TRUE
                                , i_record_number                => aggr.record_number
                                , i_count                        => aggr.oper_count
                                , i_narrative_text_1             => aggr.narrative_text_1
                                , i_narrative_text_2             => aggr.narrative_text_2
                                , i_narrative_text_3             => aggr.narrative_text_3
                                , i_reference_value              => aggr.reference_value
                                , i_amount_per_month_acct_curr   => aggr.amount_per_month_acct_curr
                                , i_amount_per_month_usd_curr    => aggr.amount_per_month_usd_curr
                                , i_amount_per_month_oper_curr   => aggr.amount_per_month_oper_curr
                                , i_amount_per_month_lbp_curr    => aggr.amount_per_month_lbp_curr
                                , i_file_name                    => aggr.file_name
                              );
            trc_log_pkg.debug(
                i_text        => ' Filled [#1] row: [#2]'
              , i_env_param1  => i
              , i_env_param2  => l_file_body(i)
            );
            i := i + 1;
        end loop;

        l_aggregated_count := l_file_body.count;

        trc_log_pkg.debug(
            i_text       => 'l_aggregated_count [#1]'
          , i_env_param1 => l_aggregated_count
        );

        -- Non-aggregated part
        select cst_bmed_cbs_files_format_pkg.generate_cbs_out_row(
                   i_file_type               => i_file_type
                 , i_sttl_date               => e.sttl_date
                 , i_account_number          => a.account_number
                 , i_dir_transaction_amount  => case
                                                    when e.balance_impact > 0
                                                         or e.amount      = 0
                                                    then '+'
                                                    else '-'
                                                end
                 , i_transaction_amount      => case
                                                    when e.currency = cst_bmed_api_const_pkg.LBPOUND
                                                    then trunc(e.amount / 100)
                                                    else e.amount
                                                end
                 , i_is_aggregated           => com_api_type_pkg.FALSE
                 , i_record_number           => l_aggregated_count + row_number() over(order by 1)
                 , i_count                   => 1
                 , i_oper_type               => o.oper_type
                 , i_sttl_type               => o.sttl_type
                 , i_transaction_type        => e.transaction_type
                 , i_fee_type                => o.fee_type
                 , i_oper_id                 => o.id
                 , i_posting_date            => e.posting_date
                 , i_amount_per_month_lbp_curr =>
                   case
                       when e.currency = cst_bmed_api_const_pkg.LBPOUND
                       then 0
                       else trunc(
                                com_api_rate_pkg.convert_amount(
                                    i_src_amount      => e.amount
                                  , i_src_currency    => e.currency
                                  , i_dst_currency    => cst_bmed_api_const_pkg.LBPOUND
                                  , i_rate_type       => 'RTTPISS'
                                  , i_inst_id         => a.inst_id
                                  , i_eff_date        => e.posting_date
                                  , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_BUYING
                                ) / 100
                            )
                   end
                 , i_file_name               => nvl(fn.file_name,'')
               )
          bulk collect into l_file_additional
          from acc_entry     e
             , acc_account   a
             , acc_macros    m
             , (
                   select oo.id
                        , oo.sttl_type
                        , oo.oper_type
                        , decode(substr(oo.oper_reason, 1, 4), fcl_api_const_pkg.FEE_TYPE_STATUS_KEY, oo.oper_reason, null) as fee_type
                        , oo.incom_sess_file_id
                     from opr_operation oo
               ) o
             , (select sf.file_name
                     , sf.id as incom_sess_file_id
                  from prc_session_file sf
                 where sf.id in (select o.incom_sess_file_id 
                                   from acc_entry e
                                      , acc_macros m
                                      , opr_operation o
                                  where m.id          = e.macros_id 
                                    and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                    and o.id          = m.object_id 
                                    and e.id          in (select column_value from table(cast(l_entry_tab as num_tab_tpt)))
                                )
               ) fn
         where e.id                in (select column_value from table(cast(l_entry_tab as num_tab_tpt)))
           and a.id                 = e.account_id
           and m.id                 = e.macros_id
           and m.entity_type        = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and o.id                 = m.object_id
           and o.incom_sess_file_id = fn.incom_sess_file_id(+)
           and not exists (
                   select 1
                     from cst_bmed_cbs_narrative n
                    where n.file_type         = i_file_type
                      and n.need_aggregate    = com_api_type_pkg.TRUE
                      and (n.oper_type        = o.oper_type        or n.oper_type        is null)
                      and (n.sttl_type        = o.sttl_type        or n.sttl_type        is null)
                      and (n.transaction_type = e.transaction_type or n.transaction_type is null)
                      and (n.fee_type         = o.fee_type         or n.fee_type         is null or o.fee_type is null)
               );

        l_non_aggregated_count   := l_file_additional.count;

        trc_log_pkg.debug(
            i_text               => 'l_non_aggregated_count [#1]'
          , i_env_param1         => l_non_aggregated_count
        );

    end if;  -- if l_entry_tab.count > 0

    l_estimated_count        := l_aggregated_count + l_non_aggregated_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count    => l_estimated_count
    );

    if l_estimated_count > 0 then

        for i in 1 .. l_file_additional.count loop
            l_file_body(l_aggregated_count + i) := l_file_additional(i);
        end loop;

        create_cbs_file(
            io_file_body_tab => l_file_body
        );
    end if;

    l_processed_count        := l_estimated_count;

    trc_log_pkg.debug(
        i_text        => PROC_NAME || ' l_evt_objects_tab.count [#1]'
      , i_env_param1  => l_evt_objects_tab.count
    );

    -- Mark processed event object
    evt_api_event_pkg.process_event_object (
        i_event_object_id_tab  => l_evt_objects_tab
    );

    trc_log_pkg.debug(
        i_text               => PROC_NAME || 'Finish'
    );

    prc_api_stat_pkg.log_end(
        i_excepted_total     => l_excepted_count
      , i_processed_total    => l_processed_count
      , i_rejected_total     => l_rejected_count
      , i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text           => PROC_NAME || 'Finished with errors: [#1] [#2]'
          , i_env_param1     => sqlcode
          , i_env_param2     => sqlerrm
        );

        l_excepted_count := l_aggregated_count + l_non_aggregated_count;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE
           and com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
        then

            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );

        end if;

        raise;

end unloading_cbs_file;

end cst_bmed_prc_outgoing_cbs_pkg;
/
