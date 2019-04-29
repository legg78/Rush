create or replace package body acq_prc_merchant_pkg is
/*********************************************************
 *  Acquiring process <br />
 *  Created by Andrey Fomichev (fomichev@bpcbt.com) at 10.07.2017 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2017-07-10 18:03:00 +0400#$ <br />
 *  Module: acq_prc_merchant_pkg <br />
 *  @headcom
 **********************************************************/

procedure calculate_merchants_statistic(
     i_start_date  in     date
   , i_end_date    in     date
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.calculate_merchants_statistic: ';

    l_start_date          date;
    l_end_date            date;
    l_total_count         com_api_type_pkg.t_long_id;
    l_deleted_count       com_api_type_pkg.t_long_id;
begin

    prc_api_stat_pkg.log_start;

    l_end_date   := trunc(coalesce(i_end_date,   com_api_sttl_day_pkg.get_sysdate - 1));
    l_start_date := trunc(coalesce(i_start_date, l_end_date));

    -- delete data in case of additional running
    delete from acq_merchant_daily_stat
     where trunc(stat_date) between l_start_date and l_end_date
       and split_hash in (select split_hash from com_api_split_map_vw);

    l_deleted_count := sql%rowcount;

    trc_log_pkg.debug(
        i_text         => LOG_PREFIX || 'deleted [#1] rows for period [#2; #3]'
      , i_env_param1   => l_deleted_count
      , i_env_param2   => to_char(l_start_date, com_api_const_pkg.XML_DATE_FORMAT)
      , i_env_param3   => to_char(l_end_date,   com_api_const_pkg.XML_DATE_FORMAT)
    );

    insert into acq_merchant_daily_stat(
           id
         , split_hash
         , customer_id
         , customer_number
         , account_id
         , account_number
         , currency_code
         , currency_name
         , stat_date
         , amount_sum
         , fee_sum
         , trxn_count_total
         , trxn_count_pay
         , trxn_count_trf
         , trxn_count_dep
         , trxn_count_cash
    )
    select com_api_id_pkg.get_id(
               i_seq  => acq_merchant_daily_stat_seq.nextval
             , i_date => l_end_date
           ) as id
         , x.split_hash
         , x.customer_id
         , (select c.customer_number from prd_customer c where c.id = x.customer_id) as customer_number
         , x.account_id
         , x.account_number
         , x.currency_code
         , (select cur.name from com_currency cur where cur.code = x.currency_code) as currency_name
         , x.stat_date
         , x.amount_sum
         , x.fee_sum
         , x.trxn_count_total
         , x.trxn_count_pay
         , x.trxn_count_trf
         , x.trxn_count_dep
         , x.trxn_count_cash
      from (
          select trunc(e.oper_date)        as stat_date
               , a.customer_id
               , e.account_id
               , a.account_number
               , e.currency                as currency_code
               , a.split_hash
               , sum(case
                         when substr(e.amount_purpose, 1, 4) = fcl_api_const_pkg.FEE_TYPE_STATUS_KEY
                         then 0
                         else decode(e.balance_impact, com_api_const_pkg.DEBIT, -1, 1) * nvl(e.amount, 0)
                     end)                  as amount_sum
               , sum(case
                         when substr(e.amount_purpose, 1, 4) = fcl_api_const_pkg.FEE_TYPE_STATUS_KEY
                         then decode(e.balance_impact, com_api_const_pkg.DEBIT, -1, 1) * nvl(e.amount, 0)
                         else 0
                     end)                  as fee_sum
               , count(1)                  as trxn_count_total
               , count(distinct case
                                    when e.oper_type in (opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                                                       , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAY_AGT)
                                    then e.object_id
                                    else null
                                end)       as trxn_count_pay
               , count(distinct case
                                    when e.oper_type in (opr_api_const_pkg.OPERATION_TYPE_FUNDS_TRANSFER
                                                       , opr_api_const_pkg.OPERATION_TYPE_FOREIGN_ACC_FT
                                                       , opr_api_const_pkg.OPER_TYPE_FT_TO_OTHER_BANK
                                                       , opr_api_const_pkg.OPER_TYPE_FT_TO_CASH_BY_CARD
                                                       , opr_api_const_pkg.OPER_TYPE_FT_TO_CASH_BY_CASH)
                                    then e.object_id
                                    else null
                                end)       as trxn_count_trf
               , count(distinct case
                                    when e.oper_type in (opr_api_const_pkg.OPERATION_TYPE_CASHIN
                                                       , opr_api_const_pkg.OPER_TYPE_CASH_DEPO_BY_CASH)
                                    then e.object_id
                                    else null
                                end)       as trxn_count_dep
               , count(distinct case
                                    when e.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                                       , opr_api_const_pkg.OPER_TYPE_CASH_BY_CODE
                                                       , opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
                                    then e.object_id
                                    else null
                                end)       as trxn_count_cash
            from acc_ui_entry_vw e
               , acc_account     a
           where trunc(e.oper_date)  between l_start_date and l_end_date
             and e.balance_type      = acc_api_const_pkg.BALANCE_TYPE_LEDGER
             and e.status           != acc_api_const_pkg.ENTRY_STATUS_CANCELED
             and a.id                = e.account_id
             and a.account_type      = acc_api_const_pkg.ACCOUNT_TYPE_MERCHANT
             and a.split_hash       in (select split_hash from com_api_split_map_vw)
             and exists (
                         select 1
                           from opr_operation   op
                          where e.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                            and op.id         = e.object_id
                            and op.status    in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                               , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC)
                 )
          group by trunc(e.oper_date)
                 , a.customer_id
                 , e.account_id
                 , a.account_number
                 , e.currency
                 , a.split_hash
        ) x;

    l_total_count := sql%rowcount;

    prc_api_stat_pkg.log_end (
        i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total => l_total_count
      , i_excepted_total  => 0
    );

    trc_log_pkg.debug(
        i_text         => LOG_PREFIX || ' Inserted [#1] stat records'
      , i_env_param1   => l_total_count
    );

exception when others then
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || sqlerrm
    );

    prc_api_stat_pkg.log_end (
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
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

end calculate_merchants_statistic;

end acq_prc_merchant_pkg;
/
