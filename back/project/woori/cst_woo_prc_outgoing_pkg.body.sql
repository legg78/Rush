create or replace package body cst_woo_prc_outgoing_pkg as
pragma serially_reusable;
/************************************************************
 * Export batch files for Woori bank <br />
 * Created by:
    Chau Huynh (huynh@bpcbt.com)
    Man Do     (m.do@bpcbt.com)  at 2017-03-03     <br />
 * Last changed by $Author: Man Do               $ <br />
 * $LastChangedDate:        2017-11-01 11:00     $ <br />
 * Revision: $LastChangedRevision:  7fdabe40     $ <br />
 * Module: CST_WOO_PRC_OUTGOING_PKG <br />
 * @headcom
 *************************************************************/

procedure batch_file_45(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
)is

    cursor cur_f45_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
        select cst_woo_const_pkg.W_BANK_CODE     as bank_code
             , opp.account_number                as sav_acct_num
             , null                              as acct_num             -- default null
             , null                              as notificate_num       -- default null
             , icn.card_number                   as card_num
             , (select oppa.auth_code
                  from opr_operation opop
                     , opr_participant oppa
                 where opop.id = oppa.oper_id
                   and oppa.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER  -- 'PRTYISS'
                   and opop.id = opo.match_id)   as approval_num
             , opo.oper_date                     as approval_date
             , agt.agent_number                  as branch_code
             , '09'                              as notificate_code      -- default value
             , '9'                               as accident_type        -- default value
             , '99'                              as accident_rea_code    -- default value
             , null                              as channel_code         -- default null
             , (select com_api_currency_pkg.get_currency_name(currency)
                  from opr_additional_amount
                 where amount_type = com_api_const_pkg.AMOUNT_PURPOSE_SETTLEMENT --'AMPR0009'
                   and oper_id = opo.id
               )                                 as currency_code
             , (select ori.amount + fee.amount
                  from (select amount, oper_id
                          from opr_additional_amount
                         where amount_type = com_api_const_pkg.AMOUNT_PURPOSE_SETTLEMENT --'AMPR0009'
                       ) ori,
                       (select amount, oper_id
                          from opr_additional_amount
                         where amount_type = cst_woo_const_pkg.AMOUNT_FEE_ORIGINAL -- 'AMPR0020'
                       ) fee
                 where ori.oper_id = fee.oper_id
                   and ori.oper_id = opo.id
               )                                 as amount
             , '99991231'                        as eff_expire           -- default value '99991231'
             , cus.customer_number               as cif_num
             , null                              as accident_content     -- default null
             , null                              as register_content     -- default null
             , null                              as release_content      -- default null
             , null                              as contact_num          -- default null
             , '2'                               as accident_status      -- default value
             , get_sysdate                       as file_date
             , null                              as dissmiss_reason      -- default null
             , decode(opo.is_reversal, com_api_const_pkg.FALSE, 'N', com_api_const_pkg.TRUE, 'Y')
                                                 as is_canceled          -- default value
             , null                              as cancel_reason        -- default null
             , null                              as all_classified_code  -- default null
             , null                              as cust_separator_code  -- default null
             , null                              as cust_id_num          -- default null
             , null                              as related_ref_num      -- default null
             , 0                                 as accident_register_bal-- default value
             , 'Y'                               as is_fee_collected     -- default value
             , '99999999'                        as respone_for_register -- default value
             , '000000000'                       as register_name        -- default value
          from opr_operation           opo
             , opr_participant         opp
             , vis_fin_message         vfm
             , iss_card_instance       ici
             , iss_card_number         icn
             , prd_customer            cus
             , net_card_type_feature   ctf
             , ost_agent               agt
         where opo.id                  = opp.oper_id
           and vfm.id                  = opo.id
           and ici.card_id             = opp.card_id
           and icn.card_id             = ici.card_id
           and cus.id                  = opp.customer_id
           and ctf.card_type_id        = opp.card_type_id
           and ici.agent_id            = agt.id
           and opo.oper_type           = opr_api_const_pkg.OPERATION_TYPE_PURCHASE     -- 'OPTP0000'
           and opo.msg_type            = aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT    -- 'MSGTPRES'
           and opo.status              = opr_api_const_pkg.OPERATION_STATUS_PROCESSED  -- 'OPST0400'
           and opo.match_status        = opr_api_const_pkg.OPERATION_MATCH_MATCHED     -- 'MTST0500'
           and opo.terminal_type       in (
                                            acq_api_const_pkg.TERMINAL_TYPE_POS        -- 'TRMT0003'
                                          , acq_api_const_pkg.TERMINAL_TYPE_EPOS       -- 'TRMT0004'
                                          )
           and opp.participant_type    = com_api_const_pkg.PARTICIPANT_ISSUER          -- 'PRTYISS'
           and ctf.card_feature        = cst_woo_const_pkg.DEBIT_CARD                  -- 'CFCHDEBT'
           and (
                opo.merchant_country   <> opp.card_country                             -- only get oversea trans
                or vfm.settlement_flag = 0                                             -- 0: oversea, 8: domestic
               )
           and ici.inst_id             = i_inst_id
           and opo.host_date between i_from_date and i_to_date
           and not exists (select 1
                             from opr_operation oor
                            where oor.status      = opr_api_const_pkg.OPERATION_STATUS_PROCESSED  -- 'OPST0400'
                              and oor.original_id = opo.id)
           ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_45;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_45                cst_woo_api_type_pkg.t_mes_tab_45;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text  => 'Export batch file 45 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    -- Get the day Before business day clearing
    -- Example 1: current day: Tuesday
    --   Datetime will be from Monday 00:00:00 to Monday 23:59:59
    -- Example 2: (skip weekend days) current day: Monday
    --   Datetime will be from Friday 00:00:00 to Sunday 23:59:59
    -- Example 3: (skip holidays): current day:  Wednesday, yesterday (Tuesday) is holiday
    --   Datetime will be from Monday 00:00:00 to Tuesday 23:59:59
    if i_end_date is not null then
        l_from_date := trunc(i_end_date);
        l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;
    else
    l_from_date := com_api_sttl_day_pkg.get_next_sttl_date(i_alg_day => 'ALDT0020');
    l_to_date   := trunc(get_sysdate) - com_api_const_pkg.ONE_SECOND;
    end if;

    trc_log_pkg.debug(
        i_text       => 'l_from_date=[#1], l_to_date=[#2]'
      , i_env_param1 => to_char(l_from_date, 'dd.mm.yyyy HH24:MI:SS')
      , i_env_param2 => to_char(l_to_date, 'dd.mm.yyyy HH24:MI:SS')
    );

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_45
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f45_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f45_data bulk collect into l_mes_tab_45 limit BULK_LIMIT;

        for i in 1..l_mes_tab_45.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_45(i).bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).sav_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).notificate_num), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).card_num), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).approval_num), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).approval_date, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).branch_code), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).notificate_code), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).accident_type), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).accident_rea_code), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).channel_code), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).currency_code), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).accident_amount), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).eff_expire), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).cif_num), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).accident_content), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).register_content), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).release_content), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).contact_num), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).accident_status), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).file_date, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).dissmiss_reason), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).is_canceled), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).cancel_reason), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).all_classified_code), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).cust_separator_code), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).cust_id_num), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).related_ref_num), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).accident_register_bal), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).is_fee_collected), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).respone_for_register), '')
            || '|' || nvl(to_char(l_mes_tab_45(i).register_name), '')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_45(i).accident_amount;

            l_record.delete;

        end loop;

        exit when cur_f45_data%notfound;

    end loop;

    close cur_f45_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f45_data%isopen then
        close cur_f45_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_45;
--------------------------------------------------------------------------------
procedure batch_file_45_1(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f451_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
        select get_sysdate                                  as file_date
             , cus.customer_number                          as cif_num
             , agt.agent_number                             as agent_id
             , cst_woo_const_pkg.W_BANK_CODE                as w_bank_code
             , opp.account_number                           as sav_acct_num
             , null                                         as dep_bank_code
             , (select account_number
                  from acc_account
                 where account_type   = cst_woo_const_pkg.ACCT_TYPE_INSTITUTION   -- 'ACTP7002'
                         and inst_id  = cst_woo_const_pkg.W_INST
                         and status   = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE)
                                                            as dep_acct_num
             , (select com_api_currency_pkg.get_currency_name(currency)
                  from opr_additional_amount
                 where amount_type = com_api_const_pkg.AMOUNT_PURPOSE_SETTLEMENT --'AMPR0009'
                   and oper_id = opo.id
               )                                            as dep_currency
             , (select ori.amount + fee.amount
                  from (select amount, oper_id
                          from opr_additional_amount
                         where amount_type = com_api_const_pkg.AMOUNT_PURPOSE_SETTLEMENT --'AMPR0009'
                       ) ori,
                       (select amount, oper_id
                          from opr_additional_amount
                         where amount_type = cst_woo_const_pkg.AMOUNT_FEE_ORIGINAL -- 'AMPR0020'
                       ) fee
                 where ori.oper_id = fee.oper_id
                   and ori.oper_id = opo.id
               )                                            as dep_amount
             , (select oppa.auth_code
                  from opr_operation opop
                     , opr_participant oppa
                 where opop.id = oppa.oper_id
                   and oppa.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER  -- 'PRTYISS'
                   and opop.id = opo.match_id)
               || ':' ||
               opo.merchant_name                            as brief_content
             , '201'                                        as work_type
             , null                                         as err_code  --default null
          from opr_operation           opo
             , opr_participant         opp
             , vis_fin_message         vfm
             , iss_card_instance       ici
             , iss_card_number         icn
             , prd_customer            cus
             , net_card_type_feature   ctf
             , ost_agent               agt
         where opo.id                  = opp.oper_id
           and vfm.id                  = opo.id
           and ici.card_id             = opp.card_id
           and icn.card_id             = ici.card_id
           and cus.id                  = opp.customer_id
           and ctf.card_type_id        = opp.card_type_id
           and ici.agent_id            = agt.id
           and opo.oper_type           = opr_api_const_pkg.OPERATION_TYPE_PURCHASE     -- 'OPTP0000'
           and opo.msg_type            = aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT    -- 'MSGTPRES'
           and opo.status              = opr_api_const_pkg.OPERATION_STATUS_PROCESSED  -- 'OPST0400'
           and opo.match_status        = opr_api_const_pkg.OPERATION_MATCH_MATCHED     -- 'MTST0500'
           and opo.terminal_type       in (
                                            acq_api_const_pkg.TERMINAL_TYPE_POS        -- 'TRMT0003'
                                          , acq_api_const_pkg.TERMINAL_TYPE_EPOS       -- 'TRMT0004'
                                          )
           and opp.participant_type    = com_api_const_pkg.PARTICIPANT_ISSUER          -- 'PRTYISS'
           and ctf.card_feature        = cst_woo_const_pkg.DEBIT_CARD                  -- 'CFCHDEBT'
           and (
                opo.merchant_country   <> opp.card_country                             -- only get oversea trans
                or vfm.settlement_flag = 0                                             -- 0: oversea, 8: domestic
               )
           and ici.inst_id             = i_inst_id
           and opo.host_date between i_from_date and i_to_date
           and not exists (select 1
                             from opr_operation oor
                            where oor.status      = opr_api_const_pkg.OPERATION_STATUS_PROCESSED  -- 'OPST0400'
                              and oor.original_id = opo.id)
           ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_451;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_45_1               cst_woo_api_type_pkg.t_mes_tab_45_1;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text    => 'Export batch file 45_1  -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    -- Get the day Before business day clearing
    -- Example 1: current day: Tuesday
    --   Datetime will be from Monday 00:00:00 to Monday 23:59:59
    -- Example 2: (skip weekend days) current day: Monday
    --   Datetime will be from Friday 00:00:00 to Sunday 23:59:59
    -- Example 3: (skip holidays): current day:  Wednesday, yesterday (Tuesday) is holiday
    --   Datetime will be from Monday 00:00:00 to Tuesday 23:59:59
    if i_end_date is not null then
        l_from_date := trunc(i_end_date);
        l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;
    else
    l_from_date := com_api_sttl_day_pkg.get_next_sttl_date(i_alg_day => 'ALDT0020');
    l_to_date   := trunc(get_sysdate) - com_api_const_pkg.ONE_SECOND;
    end if;

    trc_log_pkg.debug(
        i_text       => 'l_from_date=[#1], l_to_date=[#2]'
      , i_env_param1 => to_char(l_from_date, 'dd.mm.yyyy HH24:MI:SS')
      , i_env_param2 => to_char(l_to_date, 'dd.mm.yyyy HH24:MI:SS')
    );

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_451
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f451_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f451_data bulk collect into l_mes_tab_45_1 limit BULK_LIMIT;

        for i in 1..l_mes_tab_45_1.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_45_1(i).file_date,'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_45_1(i).cif_num), '')
            || '|' || nvl(to_char(l_mes_tab_45_1(i).agent_id), '')
            || '|' || nvl(to_char(l_mes_tab_45_1(i).w_bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_45_1(i).sav_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_45_1(i).dep_bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_45_1(i).dep_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_45_1(i).dep_currency), '')
            || '|' || nvl(to_char(l_mes_tab_45_1(i).dep_amount), '')
            || '|' || nvl(to_char(l_mes_tab_45_1(i).brief_content), '')
            || '|' || nvl(to_char(l_mes_tab_45_1(i).work_type), '')
            || '|' || nvl(to_char(l_mes_tab_45_1(i).err_code), '')
            || '|' || nvl(to_char(l_mes_tab_45_1(i).sav_acct_num), '')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_45_1(i).dep_amount;

            l_record.delete;

        end loop;

        exit when cur_f451_data%notfound;

    end loop;

    close cur_f451_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f451_data%isopen then
        close cur_f451_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_45_1;
--------------------------------------------------------------------------------
procedure batch_file_46(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f46_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
          select cst_woo_const_pkg.W_BANK_CODE     as bank_code
           , (select i_acct.account_number
                from acc_account i_acct
               where i_acct.customer_id = tmp.customer_id
                 and i_acct.account_type = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND
                   and rownum = 1
              )                             as sav_acct_num
           , null                           as acct_num
           , null                           as accident_num
           , (select cn.card_number
                from iss_card crd
                   , iss_card_number cn
               where crd.id = cn.card_id
                 and crd.customer_id = tmp.customer_id
                 and crd.category = iss_api_const_pkg.CARD_CATEGORY_PRIMARY --'CRCG0800'
                  and rownum            = 1
               )                                as card_number
           , null                           as approval_num
           , null                           as date_report
           , agt.agent_number               as trans_agent_id
           , '09'                           as notification_num
           , '8'                            as accident_type
           , '97'                           as accident_rea_code
           , null                           as channel_code
           , com_api_currency_pkg.get_currency_name(tmp.currency)
                                            as currency_code
           , tmp.accident_amount            as accident_amount
           , '99991231'                     as eff_eff_expire_date
           , tmp.customer_number            as cif_num
           , 'Long-term Delinquency more than 3 months'
                                            as accident_content
           , null                           as reg_refer_content
           , null                           as release_ref_content
           , null                           as contact_num
           , case
                 when trunc(tmp.latest_payment_dt) = trunc(get_sysdate)
                  and tmp.accident_amount = 0 then
                     2
                 else
                     1
             end                            as accident_reg_status
           , case
                 when trunc(tmp.latest_payment_dt) = trunc(get_sysdate)
                  and tmp.accident_amount = 0 then
                     trunc(tmp.latest_payment_dt)
                 else
                     null
             end                            as st_report_accident
           , null                           as for_acc_report
           , 'N'                            as is_canceled
           , null                           as cancel_reason
           , null                           as all_classified_code
           , null                           as cust_separator_code
           , null                           as cust_id_num
           , null                           as related_number
           , '000000000000000'              as accident_reg
           , 'N'                            as whether_num
           , '999999999'                    as name_of_emp
           , '000000000'                    as registered_name
        from (  select acct.currency
                     , acct.customer_id
                     , cus.customer_number
                     , acct.agent_id
                     , sum(
                           cst_woo_com_pkg.get_overdue_amt(
                               i_account_id    => acct.id
                             , i_split_hash    => acct.split_hash
                           )
                       ) as accident_amount
                     , max(cst_woo_com_pkg.get_latest_payment_dt(acct.id)) as latest_payment_dt
                  from crd_invoice ci
                     , prd_customer cus
                     , acc_account acct
                 where 1 = 1
                   and ci.account_id = acct.id
                   and acct.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT  --'ACTP0130'
                   and acct.inst_id = i_inst_id
                   and ci.aging_period >= 3
                   and ci.id = crd_invoice_pkg.get_last_invoice_id(
                                   i_account_id    => acct.id
                                 , i_split_hash    => acct.split_hash
                                 , i_mask_error    => com_api_const_pkg.TRUE -- 1
                               )
                   and acct.customer_id = cus.id
              group by acct.currency
                     , acct.customer_id
                     , cus.customer_number
                     , acct.agent_id) tmp
           , ost_agent agt
       where tmp.agent_id = agt.id
         and (case
                  when (trunc(tmp.latest_payment_dt) = trunc(get_sysdate)
                    and tmp.accident_amount = 0)
                    or tmp.accident_amount > 0 
                  then 1
                  else 0
              end) = 1
    order by agt.id, tmp.customer_id
    ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_46;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_46                cst_woo_api_type_pkg.t_mes_tab_46;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text  => 'Export batch file 46 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_end_date, get_sysdate));
    l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_46
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f46_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f46_data bulk collect into l_mes_tab_46 limit BULK_LIMIT;

        for i in 1..l_mes_tab_46.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_46(i).bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).sav_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).accident_num), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).card_num), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).approval_num), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).date_report), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).trans_agent_id), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).notif_num), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).accident_type), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).accident_rea_code), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).channel_code), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).currency_code), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).accident_amount), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).eff_expire), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).cif_no), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).accident_content), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).reg_ref_content), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).release_ref_content), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).contact_num), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).accident_reg_status), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).st_report_accident), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).for_acc_report), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).is_canceled), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).cancel_reason), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).all_classified_code), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).cust_separator_code), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).cust_id_num), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).related_number), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).accident_reg), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).whether_num), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).name_of_emp), '')
            || '|' || nvl(to_char(l_mes_tab_46(i).reg_name), '')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_46(i).accident_amount;

            l_record.delete;

        end loop;

        exit when cur_f46_data%notfound;

    end loop;

    close cur_f46_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f46_data%isopen then
        close cur_f46_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_46;
--------------------------------------------------------------------------------
procedure batch_file_49(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_end_date          in      date    default null
)
is
    cursor cur_f49_data(
        i_inst_id   com_api_type_pkg.t_inst_id
      , i_end_date  date
    ) is
        --Transaction interest information
        select cst_woo_const_pkg.W_BANK_CODE          as bank_code
             , i_end_date                             as file_date
             , 'A'                                    as acct_class_code
             , tmp.account_number                     as crd_acct_num
             , row_number() over (partition by tmp.account_number order by tmp.id)
                                                      as trx_seq_id
             , agt.agent_number                       as agent_number
             , 'AIR'                                  as accrual_code
             , '2'                                    as payment_code
             , 'CH'                                   as business_code
             , '28'                                   as bs_detail_code
             , '301'                                  as amt_code
             , tmp.start_date                         as start_date
             , tmp.end_date                           as end_date
             , '2'                                    as side
             , '16'                                   as cal_method
             , round(tmp.end_date - tmp.start_date)   as num_of_date_1
             , tmp.i_amt                              as i_amt
             , 'NON'                                  as book_id
             , (case tmp.oper_type
                    when opr_api_const_pkg.OPERATION_TYPE_ATM_CASH 
                    then cst_woo_const_pkg.GL_ACCOUNT_SUBJ_CASH_INTEREST
                    else cst_woo_const_pkg.GL_ACCOUNT_SUBJ_POSP_INTEREST
                end)                                  as l_bs_amt_code
             , ''                                     as l_is_amt_code
             , ''                                     as kfrs_bs_acct_code
             , ''                                     as kfrs_is_acct_code
             , cus.customer_number                    as cif_num
             , com_api_currency_pkg.get_currency_name(
                   i_curr_code => tmp.currency)       as curr_code
             , tmp.pri_amt                            as pri_amt
             , tmp.start_date                         as start_date
             , tmp.end_date                           as end_date
             , round(tmp.end_date - tmp.start_date)   as num_of_date_2
             , (select cst_woo_com_pkg.get_fee_rate(min(fee_id) keep (dense_rank first order by balance_date desc))
                  from crd_debt_interest
                 where debt_id = tmp.id
                   and interest_amount > 0
                )                                     as rate
             , tmp.i_amt                              as i_amt_1
             , round(tmp.i_amt/greatest((tmp.end_date - tmp.start_date),1))
                                                      as i_amt_2
             , ''                                     as i_cal_event
             , 'Y'                                    as i_flag
             , '10'                                   as s_code
             , ''                                     as g_id
          from prd_customer  cus
             , ost_agent     agt
             , (select acct.customer_id               as customer_id
                     , acct.agent_id                  as agent_id
                     , acct.currency                  as currency
                     , acct.account_number            as account_number
                     , row_number() over (partition by acct.account_number order by cd.id)
                                                      as trx_seq_id
                     , (cst_woo_com_pkg.get_daily_interest_by_debt(
                            i_debt_id   => cd.id
                          , i_intr_type => 1
                          , i_info_type => 3
                          , i_end_date  => i_end_date
                          )                           
                        )                             as pri_amt
                     , (to_date(cst_woo_com_pkg.get_daily_interest_by_debt(
                            i_debt_id   => cd.id
                          , i_intr_type => 1
                          , i_info_type => 1
                          , i_end_date  => i_end_date
                          ), 'dd/mm/yyyy')    
                       )                              as start_date
                     , (to_date(cst_woo_com_pkg.get_daily_interest_by_debt(
                            i_debt_id   => cd.id
                          , i_intr_type => 1
                          , i_info_type => 2
                          , i_end_date  => i_end_date
                          ), 'dd/mm/yyyy')    
                       )                              as end_date
                     , (cst_woo_com_pkg.get_daily_interest_by_debt(
                            i_debt_id   => cd.id
                          , i_intr_type => 1
                          , i_info_type => 5
                          , i_end_date  => i_end_date
                          )    
                        )                             as i_amt
                     , (cst_woo_com_pkg.get_daily_interest_by_debt(
                            i_debt_id   => cd.id
                          , i_intr_type => 1
                          , i_info_type => 4
                          , i_end_date  => i_end_date
                          )
                        )                             as i_amt_daily
                     , cd.id                          as id
                     , cd.oper_type                   as oper_type
                  from acc_account          acct
                     , crd_debt             cd
                 where 1 = 1
                   and acct.id              = cd.account_id
                   and acct.account_type    = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT  --'ACTP0130'
                   and acct.status in (acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE       --'ACSTACTV'
                                     , acc_api_const_pkg.ACCOUNT_STATUS_CREDITS)     --'ACSTCRED'
                   and cd.status            = crd_api_const_pkg.DEBT_STATUS_ACTIVE   --'DBTSACTV'
                   and acct.inst_id         = i_inst_id
                 ) tmp
        where tmp.customer_id     = cus.id
          and tmp.agent_id        = agt.id
          and tmp.i_amt           > 0
          ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_49;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_49                cst_woo_api_type_pkg.t_mes_tab_49;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text          => 'Export batch file 49 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_end_date, get_sysdate));
    l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_49
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare details data to export
    open cur_f49_data(l_inst_id, nvl(trunc(i_end_date), l_from_date));

    loop
        fetch cur_f49_data bulk collect into l_mes_tab_49 limit BULK_LIMIT;

        for i in 1..l_mes_tab_49.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' ||  nvl(to_char(l_mes_tab_49(i).bank_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).file_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).acct_class_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).crd_acct_num), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).trx_seq_id), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).agent_id), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).accrual_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).payment_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).business_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).bs_detail_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).amt_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).start_date_1, 'YYYYMMDD'), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).end_date_1, 'YYYYMMDD'), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).side), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).cal_method), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).num_of_date_1), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).i_amt_1), '0')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).book_id), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).l_is_amt_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).l_bs_amt_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).kfrs_bs_acct_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).kfrs_is_acct_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).cif_num), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).curr_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).pri_amt), '0')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).start_date_2, 'YYYYMMDD'), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).end_date_2, 'YYYYMMDD'), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).num_of_date_2), '0')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).rate, din_api_const_pkg.AMOUNT_FORMAT), '0')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).i_amt_1), '0')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).i_amt_2), '0')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).i_amt_1), '0')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).i_cal_event), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).i_flag), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).s_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_49(i).g_id), '')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_record.delete;

        end loop;

        exit when cur_f49_data%notfound;

    end loop;

    close cur_f49_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f49_data%isopen then
        close cur_f49_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_49;
--------------------------------------------------------------------------------
procedure batch_file_52(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f52_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
        select get_sysdate                                                  as file_date
             , ltb.cif_num                                                  as cif_num
             , ltb.crd_acct_num                                             as crd_acct_num
             , ltb.agent_id                                                 as agent_id
             , ltb.cust_reg_date                                            as cust_reg_date
             , ltb.acct_update_date                                         as acct_update_date
             , ltb.credit_limit                                             as credit_limit
             , ltb.remain_crd_limit                                         as remain_crd_limit
             , nvl(ltb.lim_update_date, ltb.acct_update_date)               as lim_update_date
             , ltb.sum_limit                                                as cash_limit
             , ltb.sum_limit - ltb.used_lmt_amount                          as remain_cash_limit
             , 'N'                                                          as is_his_limit_up
             , 'N'                                                          as is_his_limit_down
             , 'N'                                                          as is_his_limit_past
             , cus_level_limit                                              as cus_level_limit
          from (select cus.customer_number        as cif_num
                     , acc.account_number         as crd_acct_num
                     , agt.agent_number           as agent_id
                     , cus.reg_date               as cust_reg_date
                     , (select max(change_date)
                          from evt_status_log
                         where entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                           and object_id      = acc.id
                        )                         as acct_update_date
                     , (select balance
                          from acc_balance
                         where balance_type = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED --'BLTP1001'
                           and account_id   = acc.id
                        )                         as credit_limit
                     , acc_api_balance_pkg.get_aval_balance_amount_only(acc.id)
                                                  as remain_crd_limit
                     , (select last_reset_date
                          from fcl_limit_counter
                         where object_id   = acc.id
                           and entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                           and limit_type  = cst_woo_const_pkg.LIMIT_TYPE_ACCT_CREDIT_CASH  -- 'LMTP0408'
                        )                         as lim_update_date
                     , case when lim.limit_base is not null and lim.limit_rate is not null
                            then
                               nvl(fcl_api_limit_pkg.get_limit_border_sum(
                                       i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT -- 'ENTTACCT'
                                     , i_object_id            => acc.id
                                     , i_limit_type           => lim.limit_type
                                     , i_limit_base           => lim.limit_base
                                     , i_limit_rate           => lim.limit_rate
                                     , i_currency             => lim.currency
                                     , i_inst_id              => acc.inst_id
                                     , i_product_id           => prd_api_product_pkg.get_product_id(
                                                                     i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                                                   , i_object_id         => acc.id
                                                                   , i_inst_id           => acc.inst_id
                                                                 )
                                     , i_split_hash           => acc.split_hash
                                     , i_mask_error           => com_api_const_pkg.TRUE -- 1
                                  ), 0
                               )
                            else 0
                            end as sum_limit
                      , cst_woo_com_pkg.get_limit_sum_withdraw(
                            i_object_id       => acc.id
                          , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                          , i_split_hash      => acc.split_hash
                      ) as used_lmt_amount
                      , lim.limit_type
                      , lim.limit_base
                      , lim.limit_rate
                      , case when (select 1
                                     from prd_customer
                                    where entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY --'ENTTCOMP'
                                      and id = cus.id) = 1
                             then nvl(
                                       (select sum_limit
                                           from fcl_limit
                                          where id = (select distinct convert_to_number(first_value(attr_value) over (order by start_date desc)) as attr_value
                                                        from prd_attribute_value
                                                       where 1 = 1
                                                         and attr_id      = (select id from prd_attribute where attr_name = 'CRD_CUSTOMER_CREDIT_LIMIT_VALUE')
                                                         and entity_type  = com_api_const_pkg.ENTITY_TYPE_CUSTOMER -- 'ENTTCUST'
                                                         and object_id    = cus.id
                                                         and get_sysdate between start_date and nvl(end_date, get_sysdate)

                                                      )
                                        ),                                                          
                                        (select sum_limit
                                           from fcl_limit
                                          where id = (select distinct convert_to_number(first_value(attr_value) over (order by start_date desc)) as attr_value
                                                        from prd_attribute_value
                                                       where 1 = 1
                                                         and attr_id      = (select id from prd_attribute where attr_name = 'CRD_CUSTOMER_CREDIT_LIMIT_VALUE')
                                                         and entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT   -- 'ENTTPROD'
                                                         and object_id    = prd_api_product_pkg.get_product_id(
                                                                                     i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                                                                   , i_object_id         => acc.id
                                                                                   , i_inst_id           => acc.inst_id
                                                                            )
                                                         and get_sysdate between start_date and nvl(end_date, get_sysdate)
                                                         )
                                        )
                                       )
                             else null
                        end  as cus_level_limit
                      , acc.id
                  from prd_customer     cus,
                       acc_account      acc,
                       acc_balance      aba,
                       ost_agent        agt,
                       fcl_limit        lim
                 where 1 = 1
                   and cus.id           = acc.customer_id
                   and acc.id           = aba.account_id
                   and acc.agent_id     = agt.id
                   and acc.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT            -- 'ACTP0130'
                   and aba.balance_type = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED   -- 'BLTP1001'
                   and lim.limit_type   = cst_woo_const_pkg.LIMIT_TYPE_ACCT_CREDIT_CASH    -- 'LMTP0408'
                   and lim.limit_base   = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED   -- 'BLTP1001'
                   and acc.inst_id      = i_inst_id
                   and lim.id = (select distinct convert_to_number(first_value(pav.attr_value) over (order by pav.start_date desc)) as attr_value
                                  from prd_attribute_value  pav
                                     , prd_attribute        pat
                                     , prd_contract         pcn
                                     , iss_card             ica
                                     , acc_account_object   aco
                                 where 1 = 1
                                   and pav.attr_id      = pat.id
                                   and pat.attr_name    = 'CRD_ACCOUNT_CASH_LIMIT_VALUE'
                                   and pav.entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT --'ENTTPROD'
                                   and pav.object_id    in (select id
                                                              from prd_product
                                                             start with id = pcn.product_id
                                                           connect by id = prior parent_id)
                                   and ica.contract_id  = pcn.id
                                   and aco.object_id    = ica.id
                                   and aco.account_id   = acc.id
                                   and get_sysdate between pav.start_date and nvl(pav.end_date, get_sysdate)
                                )
             )ltb
             ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_52;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_52                cst_woo_api_type_pkg.t_mes_tab_52;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text          => 'Export batch file 52 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_end_date, get_sysdate));
    l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_52
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f52_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f52_data bulk collect into l_mes_tab_52 limit BULK_LIMIT;

        for i in 1..l_mes_tab_52.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
           || '|' || nvl(to_char(l_mes_tab_52(i).file_date, 'YYYYMM'), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).cif_num), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).crd_acct_num), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).agent_id), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).cust_reg_date, 'YYYYMMDD'), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).acct_update_date, 'YYYYMMDD'), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).crd_limit), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).remain_crd_limit), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).cash_limit_date, 'YYYYMMDD'), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).cash_limit), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).remain_cash_limit), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).is_his_limit_up), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).is_his_limit_down), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).is_his_limit_past), '')
           || '|' || nvl(to_char(l_mes_tab_52(i).cus_level_limit), '')
           ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_record.delete;

        end loop;

        exit when cur_f52_data%notfound;

    end loop;

    close cur_f52_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f52_data%isopen then
        close cur_f52_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_52;
--------------------------------------------------------------------------------
procedure batch_file_56 (
    i_inst_id               in      com_api_type_pkg.t_inst_id
) is

    -- Main cursor with data:
    cursor cur_f56_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_lang       com_api_type_pkg.t_dict_value
    ) is
    select ag.agent_number as branch_code
         , cust.customer_number as cif_no
         , case cust.entity_type
               when com_api_const_pkg.ENTITY_TYPE_PERSON -- 'ENTTPERS'
               then com_ui_person_pkg.get_person_name (cust.object_id, i_lang)
               when com_api_const_pkg.ENTITY_TYPE_COMPANY -- 'ENTTCOMP'
               then get_text ('COM_COMPANY',
                              'LABEL',
                              cust.object_id,
                              i_lang)
           end as customer_name
         , (
            select cst_woo_com_pkg.get_mapping_code(i.id_type, cst_woo_const_pkg.WOORI_ID_TYPE, 0, i_lang)
              from com_id_object i
             where i.id = doc.id
           ) as id_type
         , (
            select i.id_series || i.id_number
              from com_id_object i
             where i.id = doc.id
           ) as id_document
         , aa.account_number
         , d.account_subject
         , d.overdraft_amount
         , d.overdue_amount
         , d.overdue_date
      from (
            select customer_id
                 , account_id
                 , account_subject
                 , sum(overdraft_amount) as overdraft_amount
                 , sum(overdue_amount) as overdue_amount
                 , min(overdue_date) as overdue_date
              from (
                    select t.customer_id
                         , t.account_id
                         , t.amount_category
                         , case when t.amount_category like '_F__'
                                then cst_woo_const_pkg.GL_ACCOUNT_SUBJ_FEE -- '47509100000'
                                when t.amount_category like '3P%'
                                then cst_woo_const_pkg.GL_ACCOUNT_SUBJ_POSP_INTEREST -- '47431208020'
                                when t.amount_category like '5P%'
                                then cst_woo_const_pkg.GL_ACCOUNT_SUBJ_POSP_INTEREST -- '47431208020'
                                when t.amount_category like '3C%'
                                then cst_woo_const_pkg.GL_ACCOUNT_SUBJ_CASH_INTEREST -- '47440112190'
                                when t.amount_category like '5C%'
                                then cst_woo_const_pkg.GL_ACCOUNT_SUBJ_CASH_INTEREST -- '47440112190'
                                when t.amount_category like '_PDI'
                                then cst_woo_const_pkg.GL_ACCOUNT_SUBJ_POSP_D_I -- '14411100020'
                                when t.amount_category like '_POI'
                                then cst_woo_const_pkg.GL_ACCOUNT_SUBJ_POSP_O_I -- '14415100020'
                                when t.amount_category like '_PDC'
                                then cst_woo_const_pkg.GL_ACCOUNT_SUBJ_POSP_D_C -- '14411100040'
                                when t.amount_category like '_POC'
                                then cst_woo_const_pkg.GL_ACCOUNT_SUBJ_POSP_O_C -- '14415100040'
                                when t.amount_category like '_CDI'
                                then cst_woo_const_pkg.GL_ACCOUNT_SUBJ_CASH_D_I -- '14431100190'
                                when t.amount_category like '_COI'
                                then cst_woo_const_pkg.GL_ACCOUNT_SUBJ_CASH_O_I -- '14435100190'
                           end as account_subject
                         , case when t.amount_category like '2%'
                                  or t.amount_category like '3%'
                                then t.amount
                                else 0
                           end as overdraft_amount
                         , case when t.amount_category like '4%'
                                  or t.amount_category like '5%'
                                then t.amount
                                else 0
                           end as overdue_amount
                         , case when t.amount_category like '4%'
                                  or t.amount_category like '5%'
                                then (select ci.overdue_date
                                        from crd_invoice ci
                                       where ci.id = (select min(invoice_id)
                                                        from crd_invoice_debt cid
                                                       where cid.debt_id = t.debt_id)
                                     )
                                else null
                           end as overdue_date
                      from (
                            select decode(cdb.balance_type,
                                          cst_woo_const_pkg.BALANCE_TYPE_OVERDRAFT,        '2', -- Overdraft (normal) 'BLTP1002'
                                          cst_woo_const_pkg.BALANCE_TYPE_INTEREST,         '3', -- Interest           'BLTP1003'
                                          cst_woo_const_pkg.BALANCE_TYPE_OVERDUE,          '4', -- Overdue            'BLTP1004'
                                          cst_woo_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST, '5') -- Overdue interest   'BLTP1005'
                                || decode(oo.oper_type,
                                          opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE, -- Issuer fee  'OPTP0119'
                                              'F',
                                          opr_api_const_pkg.OPERATION_TYPE_PURCHASE,   -- POS purchase  'OPTP0000'
                                              case when cd.macros_type_id in (
                                                                               cst_woo_const_pkg.MACROS_TYPE_ID_DEBIT_FEE       -- 1007
                                                                             , cst_woo_const_pkg.MACROS_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                                                             , cst_woo_const_pkg.MACROS_TYPE_ID_VAT             -- 7011
                                                                             , cst_woo_const_pkg.MACROS_TYPE_ID_ORIG_FEE        -- 7126
                                                                             )
                                                   then 'F'
                                                   else 'P'
                                              end,
                                          opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST,-- 'OPTP0402'
                                          'P',
                                          opr_api_const_pkg.OPERATION_TYPE_ATM_CASH,   -- Cash withdrawal  'OPTP0001'
                                              case when cd.macros_type_id in (
                                                                               cst_woo_const_pkg.MACROS_TYPE_ID_DEBIT_FEE       -- 1007
                                                                             , cst_woo_const_pkg.MACROS_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                                                             , cst_woo_const_pkg.MACROS_TYPE_ID_VAT             -- 7011
                                                                             , cst_woo_const_pkg.MACROS_TYPE_ID_ORIG_FEE        -- 7126
                                                                             )
                                                   then 'F'
                                                   else 'C'
                                              end,
                                          opr_api_const_pkg.OPERATION_TYPE_POS_CASH,   -- POS Cash advance  'OPTP0012'
                                              case when cd.macros_type_id in (
                                                                               cst_woo_const_pkg.MACROS_TYPE_ID_DEBIT_FEE       -- 1007
                                                                             , cst_woo_const_pkg.MACROS_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                                                             , cst_woo_const_pkg.MACROS_TYPE_ID_VAT             -- 7011
                                                                             , cst_woo_const_pkg.MACROS_TYPE_ID_ORIG_FEE        -- 7126
                                                                             )
                                                   then 'F'
                                                   else 'C'
                                              end,'C')
                                || case when oo.oper_type = 'OPTP0402'
                                        then 'D'
                                        when op.card_country = oo.merchant_country and nvl(vfm.settlement_flag, 8) <> 0
                                        then 'D' -- Domestic
                                        when (op.card_country = oo.merchant_country and nvl(vfm.settlement_flag, 8) = 0) or (op.card_country <> oo.merchant_country)
                                        then 'O' -- Overseas
                                        else 'O'
                                   end
                                || decode(cust.entity_type,
                                          com_api_const_pkg.ENTITY_TYPE_COMPANY, 'C',  -- Corporate  'ENTTCOMP'
                                          com_api_const_pkg.ENTITY_TYPE_PERSON,  'I')  -- Individual 'ENTTPERS'
                                   as amount_category
                                 , oo.id as oper_id
                                 , cd.account_id
                                 , cdb.amount
                                 , cust.id as customer_id
                                 , cd.id as debt_id
                              from crd_debt cd
                                 , crd_debt_balance cdb
                                 , opr_operation oo
                                 , opr_participant op
                                 , acc_account aa
                                 , prd_customer cust
                                 , vis_fin_message vfm
                             where cd.id = cdb.debt_id
                               and oo.id = cd.oper_id
                               and oo.id = op.oper_id
                               and oo.id = vfm.id(+)
                               and aa.id = cd.account_id
                               and cust.id = op.customer_id
                               and cd.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE -- 'DBTSACTV'
                               and cdb.amount > 0
                               and aa.inst_id = i_inst_id
                               and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER -- 'PRTYISS'
                               and (
                                    oo.oper_type in (
                                                     opr_api_const_pkg.OPERATION_TYPE_PURCHASE   -- 'OPTP0000'
                                                   , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH   -- 'OPTP0001'
                                                   , opr_api_const_pkg.OPERATION_TYPE_POS_CASH   -- 'OPTP0012'
                                                   , opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE -- 'OPTP0119'
                                                   )
                                    or
                                    (oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST   -- 'OPTP0402'
                                     and oo.oper_reason = 'ACAR0009' --Purchase discount adjustment
                                    )
                                   )
                               and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
                               and cdb.balance_type in (
                                                         cst_woo_const_pkg.BALANCE_TYPE_OVERDRAFT        -- 'BLTP1002'
                                                       , cst_woo_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                       , cst_woo_const_pkg.BALANCE_TYPE_OVERDUE          -- 'BLTP1004'
                                                       , cst_woo_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                       )

                            union all

                            --DPP amount that already came to debt
                            select distinct decode(cdb.balance_type,
                                                   cst_woo_const_pkg.BALANCE_TYPE_OVERDRAFT,        '2', -- Overdraft (normal) 'BLTP1002'
                                                   cst_woo_const_pkg.BALANCE_TYPE_INTEREST,         '3', -- Interest           'BLTP1003'
                                                   cst_woo_const_pkg.BALANCE_TYPE_OVERDUE,          '4', -- Overdue            'BLTP1004'
                                                   cst_woo_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST, '5') -- Overdue interest   'BLTP1005'
                                    || case when cde.macros_type_id = 7182 --Interest Charge is categorized as Fee by bank requirement
                                            then 'F'
                                            else 'P'
                                       end
                                    || case when opp.card_country = oop.merchant_country
                                            then 'D' -- Domestic
                                            else 'O' -- Overseas
                                       end
                                    || decode(cust.entity_type,
                                              com_api_const_pkg.ENTITY_TYPE_COMPANY, 'C',  -- Corporate  'ENTTCOMP'
                                              com_api_const_pkg.ENTITY_TYPE_PERSON,  'I')  -- Individual 'ENTTPERS'
                                   as amount_category
                                 , dpp.oper_id as oper_id
                                 , cde.account_id
                                 , cdb.amount
                                 , cust.id as customer_id
                                 , cde.id as debt_id
                              from dpp_instalment din
                                 , dpp_payment_plan dpp
                                 , acc_macros acm
                                 , opr_operation oop
                                 , opr_participant opp
                                 , crd_debt cde
                                 , crd_debt_balance cdb
                                 , prd_customer cust
                                 , acc_account aa
                             where 1 = 1
                               and (acm.id = din.macros_id
                                 or acm.id = din.macros_intr_id)
                               and acm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION  -- 'ENTTOPER'
                               and din.dpp_id = dpp.id
                               and acm.object_id = cde.oper_id
                               and cdb.debt_id = cde.id
                               and oop.id = opp.oper_id
                               and opp.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER -- 'PRTYISS'
                               and cust.id = opp.customer_id
                               and aa.id = cde.account_id
                               and aa.inst_id = i_inst_id
                               and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT  -- 'ACTP0130'
                               and oop.id = dpp.oper_id
                               and cde.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE -- 'DBTSACTV'

                            union all

                            --DPP amount still not come to debt (Original amount)
                            select '2P'
                                   || case when opp.card_country = oop.merchant_country
                                           then 'D' -- Domestic
                                           else 'O' -- Overseas
                                      end
                                   || decode(cust.entity_type,
                                             com_api_const_pkg.ENTITY_TYPE_COMPANY, 'C',  -- Corporate  'ENTTCOMP'
                                             com_api_const_pkg.ENTITY_TYPE_PERSON,  'I')  -- Individual 'ENTTPERS'
                                   as amount_category
                                 , dpp.oper_id
                                 , aa.id as account_id
                                 , sum(din.instalment_amount - din.interest_amount) as amount
                                 , cust.id as customer_id
                                 , null as debt_id
                              from dpp_instalment din
                                 , dpp_payment_plan dpp
                                 , opr_operation oop
                                 , opr_participant opp
                                 , prd_customer cust
                                 , acc_account aa
                             where 1 = 1
                               and din.macros_id is null
                               and din.macros_intr_id is null
                               and din.dpp_id = dpp.id
                               and oop.id = opp.oper_id
                               and dpp.oper_id = oop.id
                               and opp.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER -- 'PRTYISS'
                               and cust.id = opp.customer_id
                               and aa.id = opp.account_id
                               and aa.inst_id = i_inst_id
                               and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT  -- 'ACTP0130'
                          group by dpp.oper_id
                                 , aa.id
                                 , cust.id
                                 , opp.card_country
                                 , oop.merchant_country
                                 , cust.entity_type

                            union all

                            --DPP amount still not come to debt (Interest amount)
                            select '3F'
                                   || case when opp.card_country = oop.merchant_country
                                           then 'D' -- Domestic
                                           else 'O' -- Overseas
                                      end
                                   || decode(cust.entity_type,
                                             com_api_const_pkg.ENTITY_TYPE_COMPANY, 'C',  -- Corporate  'ENTTCOMP'
                                             com_api_const_pkg.ENTITY_TYPE_PERSON,  'I')  -- Individual 'ENTTPERS'
                                   as amount_category
                                 , dpp.oper_id
                                 , aa.id as account_id
                                 , sum(din.interest_amount) as amount
                                 , cust.id as customer_id
                                 , null as debt_id
                              from dpp_instalment din
                                 , dpp_payment_plan dpp
                                 , opr_operation oop
                                 , opr_participant opp
                                 , prd_customer cust
                                 , acc_account aa
                             where 1 = 1
                               and din.macros_id is null
                               and din.macros_intr_id is null
                               and din.dpp_id = dpp.id
                               and oop.id = opp.oper_id
                               and dpp.oper_id = oop.id
                               and opp.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER -- 'PRTYISS'
                               and cust.id = opp.customer_id
                               and aa.id = opp.account_id
                               and aa.inst_id = i_inst_id
                               and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT  -- 'ACTP0130'
                          group by dpp.oper_id
                                 , aa.id
                                 , cust.id
                                 , opp.card_country
                                 , oop.merchant_country
                                 , cust.entity_type
                           ) t
                   )
             group by
                   customer_id
                 , account_id
                 , account_subject
           ) d
         , prd_customer cust
         , ost_agent ag
         , acc_account aa
         , (
            select object_id
                 , entity_type
                 , max(id) as id
              from com_id_object
             group by
                   object_id
                 , entity_type
           ) doc
     where cust.id = d.customer_id
       and aa.id = d.account_id
       and ag.id = aa.agent_id
       and cust.object_id = doc.object_id(+)
       and cust.entity_type = doc.entity_type(+)
       and d.overdue_amount + d.overdraft_amount > 0
       and d.account_subject is not null
     order by
           d.customer_id
         , d.account_id
         , d.account_subject;

    -- Constants and variables:
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_56;
    BULK_LIMIT         constant com_api_type_pkg.t_count       := 1000;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, cst_woo_const_pkg.WOORI_DATE_FORMAT);
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              com_api_type_pkg.t_count       := 0;
    l_current_account           com_api_type_pkg.t_account_number;

    l_mes_tab_56                cst_woo_api_type_pkg.t_mes_tab_56;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_header                    com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id     := nvl(i_inst_id, cst_woo_const_pkg.W_INST);
    l_lang                      com_api_type_pkg.t_dict_value  := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => 'Export batch file 56 -> start'
    );

    -- Prepare header data
    l_seq_file_id :=
        prc_api_file_pkg.get_next_file(
            i_file_type => opr_api_const_pkg.FILE_TYPE_UNLOADING
          , i_inst_id   => i_inst_id
          , i_file_attr => cst_woo_com_pkg.get_file_attribute_id(
                               i_file_id  => cst_woo_const_pkg.FILE_ID_56
                           )
        );

    l_header := HEADER
             || '|' || JOB_ID
             || '|' || l_process_date
             || '|' || lpad(l_seq_file_id, 3, 0);

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    -- Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_header
    );

    -- Prepare data details to export:
    open cur_f56_data(
        i_inst_id    => l_inst_id
      , i_lang       => l_lang
    );

    loop
        fetch cur_f56_data bulk collect into l_mes_tab_56 limit BULK_LIMIT;

        for i in 1..l_mes_tab_56.count loop

            if l_current_account = l_mes_tab_56(i).account_number then
                null; -- no need to put a record with personal information
            else
                l_record_count := l_record_count + 1;
                l_record(1) :=
                    lpad(l_record_count, 9, 0) -- Data sequence
                 || '|' || '1' -- Personal data
                 || '|' || l_mes_tab_56(i).branch_code
                 || '|' || l_mes_tab_56(i).cif_no
                 || '|' || l_mes_tab_56(i).customer_name
                 || '|' || l_mes_tab_56(i).type_of_id
                 || '|' || l_mes_tab_56(i).id_number
                 || '|' || l_mes_tab_56(i).account_number
                ;

                prc_api_file_pkg.put_line(
                    i_raw_data      => l_record(1)
                  , i_sess_file_id  => l_session_file_id
                );
                l_record.delete;

                l_current_account := l_mes_tab_56(i).account_number;
            end if;

            -- Amounts data
            l_record_count := l_record_count + 1;
            l_record(1) :=
                lpad(l_record_count, 9, 0) -- Data sequence
             || '|' || '2' -- Amounts per GL-account
             || '|' || l_mes_tab_56(i).account_subject
             || '|'
            ;
            if l_mes_tab_56(i).account_subject in (
                                                    cst_woo_const_pkg.GL_ACCOUNT_SUBJ_FEE
                                                  , cst_woo_const_pkg.GL_ACCOUNT_SUBJ_POSP_INTEREST
                                                  , cst_woo_const_pkg.GL_ACCOUNT_SUBJ_CASH_INTEREST
                                                  )
            then
                l_record(1) :=
                    l_record(1)
                 || '|' || '0'
                 || '|'
                 || '|' || '0'
                 || '|' || '0'
                 || '|' || to_char(l_mes_tab_56(i).overdue_amount + l_mes_tab_56(i).overdraft_amount)
                 || '|'
                 || '|'
                ;
            else
                l_record(1) :=
                    l_record(1)
                 || '|' || to_char(l_mes_tab_56(i).overdue_amount)
                 || '|' || to_char(l_mes_tab_56(i).overdue_date, cst_woo_const_pkg.WOORI_DATE_FORMAT)
                 || '|' || to_char(nvl(trunc(get_sysdate - l_mes_tab_56(i).overdue_date), 0))
                 || '|' || to_char(l_mes_tab_56(i).overdue_amount + l_mes_tab_56(i).overdraft_amount)
                 || '|' || '0'
                 || '|'
                 || '|'
                ;
            end if;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(1)
              , i_sess_file_id  => l_session_file_id
            );

            -- l_total_amount := l_total_amount + l_mes_tab_56(i).overdue_amount
            --                                  + l_mes_tab_56(i).overdraft_amount;

            l_record.delete;

        end loop;

        exit when cur_f56_data%notfound;

    end loop;

    close cur_f56_data;

    -- Update file header with total amount and record count
    l_header := l_header
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_header
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total ' || l_record_count || ' records are exported successfully -> End!'
    );

exception
when others then
    if cur_f56_data%isopen then
        close cur_f56_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_56;

procedure batch_file_58(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f58_data(
        i_inst_id       in com_api_type_pkg.t_inst_id
      , i_date          in date
    ) is
    select t.file_date
         , t.cif_num
         , t.crd_acct_num
         , t.agent_number
         , t.bank_code
         , t.sav_acct_num
         , t.acct_curr
         , t.tad_amount
         , t.mad_amount
         , t.acct_curr
         , t.unbilled_amount
         , t.card_num
         , t.virt_acct_num
         , t.rea_code01
         , t.rea_code02
         , t.rea_code03
         , t.rea_code04
         , t.rea_code05
         , t.rea_code06
         , t.rea_code07
         , t.rea_code08
         , t.rea_code09
         , t.rea_code10
         , t.brief_content
         , t.work_type
         , case
               when t.tad_amount = 0 and t.mad_amount = 0
               then null
               else add_months(trunc(t.invoice_date, 'month'), -1)
           end as cr_used_start_date
         , case
               when t.tad_amount = 0 and t.mad_amount = 0
               then null
               else add_months(last_day(t.invoice_date), -1)
           end as cr_used_end_date
    from (
            select get_sysdate                      as file_date
                 , pc.customer_number               as cif_num
                 , ac.account_number                as crd_acct_num
                 , agt.agent_number                 as agent_number
                 , cst_woo_const_pkg.W_BANK_CODE    as bank_code
                 , (select i_acct.account_number
                      from acc_account_object       i_acct_obj
                         , acc_account              i_acct
                         , iss_card                 i_ica
                     where i_acct_obj.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD        --'ENTTCARD'
                       and i_acct_obj.account_id    = i_acct.id
                       and i_acct_obj.object_id     = i_ica.id
                       and i_acct.account_type      = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND    --'ACTP0131'
                       and i_ica.id =  (select i_acct_obj.object_id
                                          from acc_account_object       i_acct_obj
                                             , acc_account              i_acct
                                             , iss_card                 i_ica
                                         where i_acct_obj.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD  --'ENTTCARD'
                                           and i_acct_obj.account_id    = i_acct.id
                                           and i_acct_obj.object_id     = i_ica.id
                                           and i_acct.id                = ac.id
                                           and rownum                   = 1)     -- Get one random card as requirement
                   ) as sav_acct_num
                 , com_api_currency_pkg.get_currency_name(ac.currency) as acct_curr
                 , cst_woo_com_pkg.get_tad_by_invoice(iv.invoice_id, i_date) as tad_amount
                 , cst_woo_com_pkg.get_mad_by_invoice(iv.invoice_id, i_date) as mad_amount
                 , 0 as unbilled_amount
                 , (select i_icn.card_number
                          from acc_account_object       i_acct_obj
                             , acc_account              i_acct
                             , iss_card                 i_ica
                             , iss_card_number          i_icn
                         where i_acct_obj.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD  --'ENTTCARD'
                           and i_acct_obj.account_id    = i_acct.id
                           and i_acct_obj.object_id     = i_ica.id
                           and i_ica.id                 = i_icn.card_id
                           and i_acct.id                = ac.id
                           and rownum                   = 1) as card_num   -- Get one random card as requirement
                 , com_api_flexible_data_pkg.get_flexible_value(
                        i_field_name    => cst_woo_const_pkg.FLEX_VIRTUAL_ACCOUNT_NUMBER  --'CST_VIRTUAL_ACCOUNT_NUMBER'
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT  --'ENTTACCT'
                      , i_object_id     => ac.id
                   )                                        as virt_acct_num
                 , null                                     as rea_code01
                 , null                                     as rea_code02
                 , null                                     as rea_code03
                 , null                                     as rea_code04
                 , null                                     as rea_code05
                 , null                                     as rea_code06
                 , null                                     as rea_code07
                 , null                                     as rea_code08
                 , null                                     as rea_code09
                 , null                                     as rea_code10
                 , null                                     as brief_content
                 , '009'                                    as work_type
                 , iv.invoice_date                          as invoice_date
              from prd_customer pc
                 , acc_account  ac
                 , ost_agent    agt
                 , (select i.id as invoice_id
                         , i.account_id
                         , i.total_amount_due
                         , i.min_amount_due
                         , i.invoice_date
                         , i.grace_date
                         , i.split_hash
                         , i.serial_number
                         , row_number() over(partition by i.account_id order by i.serial_number desc) as rng
                      from crd_invoice i
                   ) iv
             where 1 = 1
               and iv.account_id = ac.id
               and ac.customer_id = pc.id
               and ac.agent_id = agt.id
               and ac.inst_id = i_inst_id
               and iv.split_hash = ac.split_hash
               and pc.split_hash = ac.split_hash
               and 1 = iv.rng
               and ac.status in (
                                  acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE   --'ACSTACTV'
                                , acc_api_const_pkg.ACCOUNT_STATUS_CREDITS  --'ACSTCRED'
                                , cst_woo_const_pkg.ACCOUNT_STATUS_OVERDUE  --'ACSTBOVD'
                                )
         ) t;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_58;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_58                cst_woo_api_type_pkg.t_mes_tab_58;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text          => 'Export batch file 58 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_58
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f58_data(
        i_inst_id    => l_inst_id
      , i_date       => nvl(i_end_date, get_sysdate)
    );

    loop
        fetch cur_f58_data bulk collect into l_mes_tab_58 limit BULK_LIMIT;

        for i in 1..l_mes_tab_58.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_58(i).file_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).cif_num), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).crd_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).agent_id), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).sav_acct_num), 0)
            || '|' || nvl(to_char(l_mes_tab_58(i).acct_curr), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).bill_amount),'')
            || '|' || nvl(to_char(l_mes_tab_58(i).mad_amount),'')
            || '|' || nvl(to_char(l_mes_tab_58(i).unbilled_curr),'')
            || '|' || nvl(to_char(l_mes_tab_58(i).unbilled_amount),'')
            || '|' || nvl(to_char(l_mes_tab_58(i).card_num),'')
            || '|' || nvl(to_char(l_mes_tab_58(i).virt_acct_num),'')
            || '|' || nvl(to_char(l_mes_tab_58(i).rea_code01), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).rea_code02), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).rea_code03), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).rea_code04), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).rea_code05), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).rea_code06), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).rea_code07), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).rea_code08), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).rea_code09), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).rea_code10), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).brief_content), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).work_type), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).cr_used_start_dt, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_58(i).cr_used_end_dt, 'YYYYMMDD'), '')
            ;

            l_total_amount := l_total_amount + nvl(l_mes_tab_58(i).bill_amount, 0);

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_record.delete;

        end loop;

        exit when cur_f58_data%notfound;

    end loop;

    close cur_f58_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f58_data%isopen then
        close cur_f58_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_58;
--------------------------------------------------------------------------------
procedure batch_file_60(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f60_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
       select null                          as recover_branch
            , agt.agent_number              as agent_id
            , opo.originator_refnum         as global_id
            , icn.card_number               as card_num
            , (
                select a.account_number
                  from acc_account_object   o
                     , acc_account          a
                 where a.id                 = o.account_id
                   and o.entity_type        = iss_api_const_pkg.ENTITY_TYPE_CARD     -- 'ENTTCARD'
                   and a.account_type       = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND -- 'ACTP0131'
                   and o.object_id          = ica.id
               )                            as sav_acct_num
            , aac.account_number            as crd_acct_num
            , nvl(cin.due_date, cst_woo_com_pkg.get_contract_due_date(
                                            prd_api_product_pkg.get_product_id(
                                                i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT -- 'ENTTACCT'
                                              , i_object_id   => aac.id
                                            ))
              )                             as due_date
            , cus.customer_number           as cif_no
            , null                          as first_overdue_date
            , null                          as first_req_date
            , cdp.amount - cdp.pay_amount   as total_dep_amount
            , null                          as overdue_amount
            , null                          as overdue_fee
            , null                          as overdue_interest
            , cdp.pay_amount                as extra_amount
            , null                          as bal_after_trans
         from opr_operation                 opo
            , opr_participant               opp
            , prd_customer                  cus
            , ost_agent                     agt
            , crd_invoice                   cin
            , crd_payment                   cdp
            , acc_account                   aac
            , iss_card_instance             ici
            , iss_card_number               icn
            , iss_card                      ica
        where 1                             = 1
          and opo.id                        = opp.oper_id
          and opo.id                        = cdp.oper_id
          and ica.id                        = opp.card_id
          and ica.id                        = icn.card_id
          and ica.id                        = ici.card_id
          and cus.id                        = ica.customer_id
          and aac.id                        = opp.account_id
          and aac.id                        = cin.account_id(+)
          and agt.id                        = ici.agent_id
          and ici.inst_id                   = i_inst_id
          and opo.oper_type                 = cst_woo_const_pkg.OPERATION_PAYMENT_DD       -- 'OPTP7030'
          and opo.status                    = opr_api_const_pkg.OPERATION_STATUS_PROCESSED -- 'OPST0400'
          and opo.is_reversal               = com_api_type_pkg.FALSE -- 0
          and opo.originator_refnum         is not null
          and opp.participant_type          = com_api_const_pkg.PARTICIPANT_ISSUER         -- 'PRTYISS'
          and aac.account_type              = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT        -- 'ACTP0130'
          and aac.status                    in (acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE    -- 'ACSTACTV'
                                              , acc_api_const_pkg.ACCOUNT_STATUS_CREDITS   -- 'ACSTCRED'
                                              )
          and cin.id                        = crd_invoice_pkg.get_last_invoice_id(
                                                  i_account_id    => aac.id
                                                , i_split_hash    => aac.split_hash
                                                , i_mask_error    => com_api_type_pkg.TRUE  -- 1
                                              )
          and exists (select 1
                        from opr_participant opp1
                       where opp1.inst_id = '2001' --'MCI Payment loaded from file 59'
                         and opp1.oper_id = opo.id
                      )
          and not exists (select id
                            from opr_operation
                           where original_id = opo.id
                             and status      = opr_api_const_pkg.OPERATION_STATUS_PROCESSED --'OPST0400'
                          )
          and opo.host_date between i_from_date and i_to_date
          ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_60;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_60                cst_woo_api_type_pkg.t_mes_tab_60;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text          => 'Export batch file 60 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_end_date, get_sysdate));
    l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_60
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f60_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f60_data bulk collect into l_mes_tab_60 limit BULK_LIMIT;

        for i in 1..l_mes_tab_60.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || to_char(get_sysdate, cst_woo_const_pkg.WOORI_DATE_FORMAT)
            || '|' || nvl(to_char(l_mes_tab_60(i).recover_branch), '')
            || '|' || nvl(to_char(l_mes_tab_60(i).agent_id), '')
            || '|' || nvl(to_char(l_mes_tab_60(i).global_id), '')
            || '|' || nvl(to_char(l_mes_tab_60(i).card_num), '')
            || '|' || nvl(to_char(l_mes_tab_60(i).acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_60(i).crd_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_60(i).due_date, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_60(i).cif_no), '')
            || '|' || nvl(to_char(l_mes_tab_60(i).first_overdue_date, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_60(i).first_req_date, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_60(i).total_dep_amount), '0')
            || '|' || nvl(to_char(l_mes_tab_60(i).overdue_amount), '0')
            || '|' || nvl(to_char(l_mes_tab_60(i).overdue_fee), '0')
            || '|' || nvl(to_char(l_mes_tab_60(i).overdue_interest), '0')
            || '|' || nvl(to_char(l_mes_tab_60(i).extra_amount), '0')
            || '|' || nvl(to_char(l_mes_tab_60(i).bal_after_trans), '0');

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_60(i).total_dep_amount;

            l_record.delete;

        end loop;

        exit when cur_f60_data%notfound;

    end loop;

    close cur_f60_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f60_data%isopen then
        close cur_f60_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_60;
--------------------------------------------------------------------------------
procedure batch_file_61(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f61_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
        select get_sysdate                         as file_date
             , cus.customer_number                 as cif_num
             , agt.agent_number                    as branch_code
             , cst_woo_const_pkg.W_BANK_CODE       as wdr_bank_code
             , null                                as wdr_acct_num
             , cst_woo_const_pkg.W_BANK_CODE       as dep_bank_code
             , (select aac.account_number          as sav_acct_num
                  from acc_account          aac
                     , acc_account_object   aob
                 where 1                    = 1
                   and aac.id               = aob.account_id
                   and aac.account_type     = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND    --'ACTP0131'
                   and aob.entity_type      = 'ENTTCARD'
                   and aob.object_id        = (select object_id
                                                 from acc_account_object o, iss_card i
                                                where o.object_id   = i.id
                                                  and o.entity_type = 'ENTTCARD'
                                                  and i.category    = 'CRCG0800' --primary card
                                                  and o.account_id  = acc.id
                                                  and rownum        = 1)
                )                                  as dep_acct_num
             , com_api_currency_pkg.get_currency_name(opo.oper_currency)
                                                   as dep_curr_code
             , opo.oper_amount                     as dep_amount
             , ':' || to_char(opo.id)              as brief_content
             , '102'                               as work_type --default value is 009
             , null                                as err_code
             , acc.account_number                  as sv_crd_acct
          from opr_operation            opo
             , opr_participant          opp
             , prd_customer             cus
             , acc_account              acc
             , ost_agent                agt
        where 1 = 1
          and opo.id                    = opp.oper_id
          and opo.oper_type             = cst_woo_const_pkg.OPERATION_TYPE_CREDIT_REFUND    --'OPTP1003'
          and opo.status                = opr_api_const_pkg.OPERATION_STATUS_PROCESSED      --'OPST0400'
          and opp.participant_type      = com_api_const_pkg.PARTICIPANT_ISSUER              --'PRTYISS'
          and opo.is_reversal           = com_api_type_pkg.FALSE                            --0
          and opp.account_id            = acc.id
          and cus.id                    = acc.customer_id
          and agt.id                    = acc.agent_id
          and acc.account_type          = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT             --'ACTP0130'
          and acc.inst_id               = i_inst_id
          and opo.session_id            = prc_api_session_pkg.get_session_id
        order by cus.customer_number
        ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_61;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_61                cst_woo_api_type_pkg.t_mes_tab_61;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text          => 'Export batch file 61 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_end_date, get_sysdate));
    l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

--Step 1: Register Own fund event, this event will create operations for each account
    for cur in (
        select acc.id as account_id, acc.account_number, acc.split_hash, acc.customer_id, cus.customer_number
         from  prd_customer             cus
             , acc_account              acc
             , acc_balance              aba
             , ost_agent                agt
        where 1                         = 1
          and cus.id                    = acc.customer_id
          and acc.id                    = aba.account_id
          and agt.id                    = acc.agent_id
          and aba.balance_type          = acc_api_const_pkg.BALANCE_TYPE_LEDGER     --'BLTP0001'
          and aba.status                = acc_api_const_pkg.BALANCE_STATUS_ACTIVE   --'BLSTACTV'
          and aba.balance               > 0
          and acc.account_type          = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT     --'ACTP0130'
          and acc.inst_id               = i_inst_id
          order by cus.customer_number
    )
    loop
        rul_api_param_pkg.set_param (
            i_name     => 'ACCOUNT_ID'
          , i_value    => cur.account_id
          , io_params  => l_param_tab
        );

        rul_api_param_pkg.set_param (
            i_name     => 'ACCOUNT_NUMBER'
          , i_value    => cur.account_number  --Credit account number
          , io_params  => l_param_tab
        );

        evt_api_event_pkg.register_event(
            i_event_type            => 'EVNT5010'  --  Own funds unloaded to CBS
          , i_eff_date              => get_sysdate
          , i_entity_type           => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id             => cur.account_id
          , i_inst_id               => l_inst_id
          , i_split_hash            => cur.split_hash
          , i_param_tab             => l_param_tab
        );

    end loop;

--Step 2: Process operations created by the event
    for oper_cur in (
        select id
          from opr_operation
         where session_id = prc_api_session_pkg.get_session_id
    )
    loop
        opr_api_process_pkg.process_operation(
            i_operation_id => oper_cur.id
        );
    end loop;

--Step 3: Export operation data to outgoing file

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_61
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f61_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f61_data bulk collect into l_mes_tab_61 limit BULK_LIMIT;

        for i in 1..l_mes_tab_61.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' ||  nvl(to_char(l_mes_tab_61(i).file_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' ||  nvl(to_char(l_mes_tab_61(i).cif_num), '')
            || '|' ||  nvl(to_char(l_mes_tab_61(i).branch_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_61(i).wdr_bank_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_61(i).wdr_acct_num), '')
            || '|' ||  nvl(to_char(l_mes_tab_61(i).dep_bank_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_61(i).dep_acct_num), '')
            || '|' ||  nvl(to_char(l_mes_tab_61(i).dep_curr_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_61(i).dep_amount), '')
            || '|' ||  nvl(to_char(l_mes_tab_61(i).brief_content), '')
            || '|' ||  nvl(to_char(l_mes_tab_61(i).work_type), '')
            || '|' ||  nvl(to_char(l_mes_tab_61(i).err_code), '')
            || '|' ||  nvl(to_char(l_mes_tab_61(i).sv_crd_acct), '')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_61(i).dep_amount;
            
            l_record.delete;

        end loop;

        exit when cur_f61_data%notfound;

    end loop;

    close cur_f61_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f61_data%isopen then
        close cur_f61_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_61;
--------------------------------------------------------------------------------
procedure batch_file_62(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f62_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
       select get_sysdate                   as recover_date
            , '0'                           as serial_num
            , null                          as r_branch_code    --agent_id of terminal
            , agt.agent_number              as branch_code
            , opo.id                        as global_id        --SV internal transaction id
            , icn.card_number               as card_num         --credit card_number
            , (
                select a.account_number
                  from acc_account_object   o
                     , acc_account          a
                 where a.id                 = o.account_id
                   and o.entity_type        = iss_api_const_pkg.ENTITY_TYPE_CARD     --'ENTTCARD'
                   and a.account_type       = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND --'ACTP0131'
                   and o.object_id          = ica.id
               )                            as sav_acct_num
            , aac.account_number            as crd_acct_num
            , cst_woo_com_pkg.get_contract_due_date(cdp.product_id)
                                            as billing_date
            , cus.customer_number           as cif_no
            , null                          as first_overdue_date
            , null                          as first_claim_date
            , cdp.amount - cdp.pay_amount   as payment_amount
            , null                          as deli_principal
            , null                          as overdue_fee
            , null                          as overdue_interest
            , cdp.pay_amount                as excess_amount
            , null                          as balance_after
         from opr_operation                 opo
            , opr_participant               opp
            , aut_auth                      aut
            , crd_payment                   cdp
            , crd_invoice                   cin
            , iss_card_instance             ici
            , iss_card_number               icn
            , iss_card                      ica
            , acc_account                   aac
            , prd_customer                  cus
            , ost_agent                     agt
        where 1 = 1
          and opo.id                        = opp.oper_id
          and opo.id                        = aut.id
          and opo.id                        = cdp.oper_id
          and ica.id                        = icn.card_id
          and ica.id                        = ici.card_id
          and ica.id                        = opp.card_id
          and aac.id                        = opp.account_id
          and aac.id                        = cin.account_id(+)
          and cus.id                        = ica.customer_id
          and agt.id                        = ici.agent_id
          and ici.inst_id                   = i_inst_id
          and aac.account_type              = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT        -- 'ACTP0130'
          and opo.oper_type                 = opr_api_const_pkg.OPERATION_TYPE_PAYMENT     -- 'OPTP0028'
          and opo.status                    = opr_api_const_pkg.OPERATION_STATUS_PROCESSED -- 'OPST0400'
          and opo.status_reason             = pmo_api_const_pkg.SUCCESSFUL_AUTHORIZATION   -- 'RESP0001'
          and opo.sttl_type                 = opr_api_const_pkg.SETTLEMENT_USONUS          -- 'STTT0010'
          and opo.is_reversal               = com_api_type_pkg.FALSE  -- 0
          and cin.id                        = crd_invoice_pkg.get_last_invoice_id(
                                                  i_account_id    => aac.id
                                                , i_split_hash    => aac.split_hash
                                                , i_mask_error    => com_api_type_pkg.TRUE --1
                                                )
          and opo.oper_date between i_from_date and i_to_date
          and exists (select 1
                        from opr_participant opp1
                       where opp1.inst_id = '2002'  --'CBS Payment'
                         and opp1.oper_id = opo.id
                      )
          and not exists (select id
                            from opr_operation
                           where original_id = opo.id
                             and status      = opr_api_const_pkg.OPERATION_STATUS_PROCESSED --'OPST0400'
                          )
          ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_62;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_62                cst_woo_api_type_pkg.t_mes_tab_62;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text          => 'Export batch file 62 -> start'
    );

    l_inst_id   := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_end_date, get_sysdate));
    l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_62
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f62_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f62_data bulk collect into l_mes_tab_62 limit BULK_LIMIT;

        for i in 1..l_mes_tab_62.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_62(i).recover_date, 'YYYYMMDD'), '')
            --|| '|' || nvl(to_char(l_mes_tab_62(i).serial_num), '') --Removed at 15.06.2017 by new requirement
            || '|' || nvl(to_char(l_mes_tab_62(i).r_branch_code), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).branch_code), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).global_id), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).card_num), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).sav_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).crd_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).billing_date, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).cif_no), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).first_overdue_date, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).first_claim_date, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).payment_amount), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).deli_principal), '')
            || '|' || trim(nvl(to_char(l_mes_tab_62(i).overdue_fee, '999999999990.999'), ''))
            || '|' || nvl(to_char(l_mes_tab_62(i).overdue_interest, '999999999990.999'), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).excess_amount), '')
            || '|' || nvl(to_char(l_mes_tab_62(i).balance_after), '0')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_62(i).payment_amount;

            l_record.delete;

        end loop;

        exit when cur_f62_data%notfound;

    end loop;

    close cur_f62_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f62_data%isopen then
        close cur_f62_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_62;
--------------------------------------------------------------------------------
procedure batch_file_64(
    i_inst_id           in com_api_type_pkg.t_inst_id
) is

    BULK_LIMIT          constant pls_integer := 10000;

    cursor cur_f64_data is
        select get_sysdate                         as file_date
             , cus.customer_number                 as cif_no
             , agt.agent_number                    as agent_id
             , cst_woo_const_pkg.W_BANK_CODE       as w_bank_code
             , null                                as w_sav_acct_num
             , cst_woo_const_pkg.W_BANK_CODE       as d_bank_code
             , sav_acct.account_number             as d_sav_acct_num
             , com_api_currency_pkg.get_currency_name(sav_acct.currency)
                                                   as d_acct_curr
             , (pay.amount - ci.total_amount_due)  as d_amt
             , null                                as brief_content
             , '103'                               as work_type
             , null                                as err_code
        from crd_invoice    ci
             , prd_customer cus
             , acc_account  acct
             , ost_agent    agt
             , (select i_cip.invoice_id
                     , i_pay.card_id
                     , i_cip.pay_id
                     , i_pay.is_reversal
                     , i_pay.currency
                     , i_pay.amount
                     , i_pay.oper_id
                  from crd_invoice_payment  i_cip
                     , crd_payment          i_pay
                 where i_cip.pay_id         = i_pay.id
                   and i_pay.is_reversal    = 0
              ) pay
             , (select i_acct.account_number
                     , i_acct.currency
                     , i_acct.agent_id
                     , i_acct.customer_id
                  from acc_account         i_acct
                 where 1                   = 1
                   and i_acct.account_type = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND
              ) sav_acct
             where 1                 = 1
               and ci.account_id     = acct.id
               and acct.customer_id  = cus.id
               and acct.agent_id     = agt.id
               and ci.id             = pay.invoice_id
               and cus.id            = sav_acct.customer_id(+)
               and acct.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
               and pay.amount        > ci.total_amount_due
               and acct.inst_id      = i_inst_id
               ;

    cursor cur_f64_count is
    select count(1)
       from crd_invoice  ci
          , prd_customer cus
          , acc_account  acct
          , ost_agent    agt
          , (select i_cip.invoice_id
              , i_pay.card_id
              , i_cip.pay_id
              , i_pay.is_reversal
              , i_pay.currency
              , i_pay.amount
              , i_pay.oper_id
               from crd_invoice_payment i_cip
              , crd_payment i_pay
              where i_cip.pay_id      = i_pay.id
                and i_pay.is_reversal = 0
           ) pay
          , (select i_acct.account_number
              , i_acct.currency
              , i_acct.agent_id
              , i_acct.customer_id
               from acc_account i_acct
              where 1                   = 1
                and i_acct.account_type = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND
           ) sav_acct
          where 1                 = 1
            and ci.account_id     = acct.id
            and acct.customer_id  = cus.id
            and acct.agent_id     = agt.id
            and ci.id             = pay.invoice_id
            and cus.id            = sav_acct.customer_id(+)
            and acct.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
            and pay.amount        > ci.total_amount_due
            and acct.inst_id      = i_inst_id
            ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_64;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--Details info
    l_file_date                 com_api_type_pkg.t_date_tab;
    l_cif_num                   com_api_type_pkg.t_cmid_tab;
    l_agent_id                  com_api_type_pkg.t_dict_tab;
    l_wdr_bank_code             com_api_type_pkg.t_dict_tab;
    l_wdr_acct_num              com_api_type_pkg.t_account_number_tab;
    l_dep_bank_code             com_api_type_pkg.t_dict_tab;
    l_dep_acct_num              com_api_type_pkg.t_account_number_tab;
    l_dep_curr_code             com_api_type_pkg.t_curr_code_tab;
    l_dep_amount                com_api_type_pkg.t_money_tab;
    l_brief_content             com_api_type_pkg.t_desc_tab;
    l_work_type                 com_api_type_pkg.t_dict_tab;
    l_err_code                  com_api_type_pkg.t_dict_tab;
--For file processing
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => 'Export batch file 64 -> start'
   );

    open cur_f64_count;
      fetch cur_f64_count into l_record_count;
    close cur_f64_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_record_count
   );

    if l_record_count > 0 then

    --Prepare header data to export
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type    => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id      => i_inst_id
                       , i_file_attr    => cst_woo_com_pkg.get_file_attribute_id(
                                               i_file_id    => cst_woo_const_pkg.FILE_ID_64
                                           )
                     );

    l_line := null;
    l_line := l_line || HEADER                    || '|';
    l_line := l_line || JOB_ID                    || '|';
    l_line := l_line || l_process_date            || '|';
    l_line := l_line || lpad(l_seq_file_id, 3 ,0) || '|';
    l_line := l_line || l_total_amount            || '|';
    l_line := l_line || l_record_count;

    prc_api_file_pkg.open_file(
        o_sess_file_id => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
      i_sess_file_id  => l_session_file_id
    , i_raw_data      => l_line
    );

    --Prepare details data to export
    open cur_f64_data;

    loop
        fetch cur_f64_data bulk collect into
              l_file_date
            , l_cif_num
            , l_agent_id
            , l_wdr_bank_code
            , l_wdr_acct_num
            , l_dep_bank_code
            , l_dep_acct_num
            , l_dep_curr_code
            , l_dep_amount
            , l_brief_content
            , l_work_type
            , l_err_code
        limit BULK_LIMIT;

    l_record.delete;

        for i in 1..l_record_count loop
            l_record(i) :=
            lpad(i, 9, 0)                                                || '|'
            || nvl(to_char(l_file_date(i)
               , cst_woo_const_pkg.WOORI_DATE_FORMAT), '')               || '|'
            || nvl(to_char(l_cif_num(i)), '')                            || '|'
            || nvl(to_char(l_agent_id(i)), '')                           || '|'
            || nvl(to_char(l_wdr_bank_code(i)), '')                      || '|'
            || nvl(to_char(l_wdr_acct_num(i)), '')                       || '|'
            || nvl(to_char(l_dep_bank_code(i)), '')                      || '|'
            || nvl(to_char(l_dep_acct_num(i)), '')                       || '|'
            || nvl(to_char(l_dep_curr_code(i)), '')                      || '|'
            || nvl(to_char(l_dep_amount(i)), '')                         || '|'
            || nvl(to_char(l_brief_content(i)), '')                      || '|'
            || nvl(to_char(l_work_type(i)), '')                          || '|'
            || nvl(to_char(l_err_code(i)), '');

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

        end loop;

        exit when cur_f64_data%notfound;

    end loop;

    close cur_f64_data;

    prc_api_file_pkg.close_file(
      i_sess_file_id  => l_session_file_id
    , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    end if;

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f64_data%isopen then
        close cur_f64_data;
    end if;

    if cur_f64_count%isopen then
        close cur_f64_count;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
   );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file (
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
       );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
       );
    end if;

end batch_file_64;
--------------------------------------------------------------------------------
procedure batch_file_66 (
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date    default null
) is

    -- Main cursor with data:
    cursor cur_f66_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
    select ag.agent_number
         , oo.id as oper_id
         , oo.oper_date
         , cust.customer_number
         , op.account_number
         , nvl((select sum(oaa.amount)
              from opr_additional_amount oaa
             where oaa.oper_id = oo.id
               and oaa.amount_type = com_api_const_pkg.AMOUNT_PURPOSE_MACROS -- 'AMPR0010'
               and oaa.currency = cst_woo_const_pkg.VNDONG
           ), 0) as amount
      from opr_operation oo
         , opr_participant op
         , acc_account aa
         , ost_agent ag
         , prd_customer cust
         , prd_contract pc
     where oo.id = op.oper_id
       and aa.id = op.account_id
       and ag.id = aa.agent_id
       and cust.id = op.customer_id
       and pc.id = aa.contract_id
       and oo.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and oo.oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND,
                            opr_api_const_pkg.OPERATION_TYPE_CREDIT_ADJUST) --('OPTP0020', 'OPTP0422')
       and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER  -- 'PRTYISS'
       and pc.contract_type in (cst_woo_const_pkg.CONTRACT_DEBIT_CORPORATE, cst_woo_const_pkg.CONTRACT_DEBIT_INDIVIDUAL) -- ('CNTPDCOR', 'CNTPDIND')
       and aa.inst_id = i_inst_id
       and (
            (oo.oper_date between i_from_date and i_to_date)
            or
            (    oo.id in (select oper_id from cst_woo_import_f68)
             and oo.oper_date > trunc(get_sysdate) - 30)
           );

    -- Constants and variables:
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_66;
    BULK_LIMIT         constant pls_integer                    := 1000;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, cst_woo_const_pkg.WOORI_DATE_FORMAT);
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              com_api_type_pkg.t_count       := 0;

    l_mes_tab_66                cst_woo_api_type_pkg.t_mes_tab_66;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_header                    com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => 'Export batch file 66 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_start_date, get_sysdate));
    l_to_date := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    -- Prepare header data
    l_seq_file_id :=
        prc_api_file_pkg.get_next_file(
            i_file_type => opr_api_const_pkg.FILE_TYPE_UNLOADING
          , i_inst_id   => l_inst_id
          , i_file_attr => cst_woo_com_pkg.get_file_attribute_id(
                               i_file_id  => cst_woo_const_pkg.FILE_ID_66
                           )
        );

    l_header := HEADER
             || '|' || JOB_ID
             || '|' || l_process_date
             || '|' || lpad(l_seq_file_id, 3, 0);

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    -- Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_header
    );

    -- Prepare data details to export:
    open cur_f66_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f66_data bulk collect into l_mes_tab_66 limit BULK_LIMIT;

        for i in 1..l_mes_tab_66.count loop
            l_record_count := l_record_count + 1;

            l_record(1) :=
                lpad(l_record_count, 9, 0) -- Data sequence
             || '|' || l_process_date
             || '|' || l_mes_tab_66(i).cif_no
             || '|' || l_mes_tab_66(i).branch_code
             || '|'
             || '|'
             || '|' || cst_woo_const_pkg.W_BANK_CODE
             || '|' || l_mes_tab_66(i).account_number
             || '|' || cst_woo_const_pkg.VALUE_VND
             || '|' || to_char(l_mes_tab_66(i).amount)
             || '|' || ':' || to_char(l_mes_tab_66(i).oper_id)
             || '|' || '110'
             || '|'
             || '|' || l_mes_tab_66(i).account_number
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(1)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_66(i).amount;
            l_record.delete;

        end loop;

        exit when cur_f66_data%notfound;

    end loop;

    close cur_f66_data;

    --Update file header with total amount and record count
    l_header := l_header
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_header
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total ' || l_record_count || ' records are exported successfully -> End!'
    );

exception
when others then
    if cur_f66_data%isopen then
        close cur_f66_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_66;
--------------------------------------------------------------------------------
procedure batch_file_72(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f72_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
      select get_sysdate                    as file_date
           , cif_no                         as cif_no
           , agent_id                       as agent_id
           , null                           as wdr_bank_code
           , wdr_acct_num                   as wdr_acct_num
           , cst_woo_const_pkg.w_bank_code  as dep_bank_code
           , dep_acct_num                   as dep_acct_num
           , dep_curr_code                  as dep_curr_code
           , sum(dep_amount)                as dep_amount
           , null                           as brief_content
           , '106'                          as work_type
           , null                           as err_code
           , account_number                 as sv_acct_num
        from (with loyt_cust
                   as (select cus.id
                            , cus.customer_number
                            , agt.agent_number
                            , acc.account_number
                         from prd_customer      cus
                            , acc_account       acc
                            , ost_agent         agt
                        where cus.id            = acc.customer_id
                          and acc.agent_id      = agt.id
                          and acc.account_type  = cst_woo_const_pkg.ACCT_TYPE_LOYALTY       -- 'ACTPLOYT'
                        )
              select lct.customer_number    as cif_no
                   , lct.agent_number       as agent_id
                   , (select account_number
                        from acc_account
                       where account_type   = cst_woo_const_pkg.ACCT_TYPE_INSTITUTION       -- 'ACTP7002'
                         and inst_id        = cst_woo_const_pkg.W_INST
                         and status         = acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE)      -- 'ACSTACTV'
                                            as wdr_acct_num
                   , (select account_number
                        from opr_participant
                       where account_type = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND          -- 'ACTP0131'
                         and oper_id      = oop.id) as dep_acct_num
                   , com_api_currency_pkg.get_currency_name(ama.currency) as dep_curr_code
                   , ama.amount             as dep_amount
                   , lct.account_number     as account_number
                from opr_operation      oop
                   , opr_participant    opa
                   , acc_macros         ama
                   , loyt_cust          lct
               where oop.id             = opa.oper_id
                 and oop.id             = ama.object_id
                 and lct.id             = opa.customer_id
                 and lct.account_number = opa.account_number
                 and ama.currency       = cst_woo_const_pkg.VNDONG                          -- '704'
                 and ama.macros_type_id = cst_woo_const_pkg.MACROS_TYPE_ID_POINT_TO_CASH    -- 7133
                 and oop.status         = opr_api_const_pkg.OPERATION_STATUS_PROCESSED      -- 'OPST0400'
                 and oop.oper_type in (opr_api_const_pkg.OPERATION_TYPE_FUNDS_TRANSFER      -- 'OPTP0040'
                                     , lty_api_const_pkg.LOYALTY_MANUAL_REDEMPTION          -- 'OPTP1102'
                                     , cst_woo_const_pkg.LOYALTY_POINT_REDEMPTION           -- 'OPTP5001'
                                                                                 )
                 and oop.oper_date between i_from_date and i_to_date) a
    group by cif_no
           , agent_id
           , wdr_acct_num
           , dep_acct_num
           , dep_curr_code
           , account_number
           ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_72;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_72                cst_woo_api_type_pkg.t_mes_tab_72;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;
begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text          => 'Export batch file 72 -> start'
    );

    l_inst_id   := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_end_date, get_sysdate));
    l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_72
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f72_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f72_data bulk collect into l_mes_tab_72 limit BULK_LIMIT;

        for i in 1..l_mes_tab_72.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_72(i).file_date,'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_72(i).cif_num), '')
            || '|' || nvl(to_char(l_mes_tab_72(i).branch_code), '')
            || '|' || nvl(to_char(l_mes_tab_72(i).wdr_bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_72(i).wdr_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_72(i).dep_bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_72(i).dep_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_72(i).dep_curr_code), '')
            || '|' || nvl(to_char(l_mes_tab_72(i).dep_amount), '')
            || '|' || ':' || nvl(to_char(l_mes_tab_72(i).brief_content), '')
            || '|' || nvl(to_char(l_mes_tab_72(i).work_type), '')
            || '|' || nvl(to_char(l_mes_tab_72(i).err_code), '')
            || '|' || nvl(to_char(l_mes_tab_72(i).sv_account), '')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_72(i).dep_amount;

            l_record.delete;

        end loop;

        exit when cur_f72_data%notfound;

    end loop;

    close cur_f72_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f72_data%isopen then
        close cur_f72_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_72;
--------------------------------------------------------------------------------
procedure batch_file_75(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f75_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
        select get_sysdate                                                      as file_date
             , ci.reg_date                                                      as req_date
             , ci.start_date                                                    as issused_date
             , decode(ci.seq_number, 1, 'R', 'C')                               as reg_type
             , agt.agent_number                                                 as issused_branch
             , (select distinct d3.element_value
                  from app_data         d1
                     , app_data         d2
                     , app_data         d3
                     , app_element      e1
                     , app_element      e2
                     , app_element      e3
                     , app_history      h1
                 where 1                = 1
                   and d1.appl_id       = d2.appl_id
                   and d1.appl_id       = d3.appl_id
                   and e1.id            = d1.element_id
                   and e2.id            = d2.element_id
                   and e3.id            = d3.element_id
                   and h1.appl_id       = d1.appl_id
                   and h1.appl_status   = 'APST0007'
                   and e1.name          = 'APPLICATION_FLOW_ID'
                   and d1.element_value in ('000000000000001001.0000'   -- flow 1001 - Create new customer or contract for Credit
                                            , '000000000000001003.0000' -- flow 1003 - Open additional card
                                           )
                   and e2.name          = 'CARD_NUMBER'
                   and d2.element_value = acct.card_number
                   and e3.name          = 'OPERATOR_ID'
                   and rownum           = 1
               )                                                                as staff_num
             , convert_to_number(
                com_api_flexible_data_pkg.get_flexible_value(
                    i_field_name  => 'CST_RECRUITER_ID'
                  , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                  , i_object_id   => decode(ctf.card_feature
                                            , cst_woo_const_pkg.DEBIT_CARD, acct.saving_acct_id
                                            , cst_woo_const_pkg.CREDIT_CARD, acct.credit_acct_id
                                            , cst_woo_const_pkg.PREPAID_CARD, acct.prepaid_acct_id)
                )
               )                                                                as inviter_num
             , agt.agent_number                                                 as manage_agent_id
             , cus.customer_number                                              as cif_num
             , acct.card_number                                                 as card_num
             , ci.expir_date                                                    as card_expire_date
             , decode(cus.entity_type
                   , com_api_const_pkg.ENTITY_TYPE_PERSON
                   , '1'
                   , '2')                                                       as division
             , (select product_number
                  from prd_product
                 where id = ctr.product_id)                                     as prod_code
             , decode(ctf.card_feature
                    , cst_woo_const_pkg.PREPAID_CARD
                    , '02'
                    , '01')                                                     as card_type_class
             , decode(ctf.card_feature
                    , cst_woo_const_pkg.DEBIT_CARD, '01'
                    , cst_woo_const_pkg.CREDIT_CARD, '03'
                    , cst_woo_const_pkg.PREPAID_CARD, '04')                     as card_class
             , decode(ctf.card_feature
                    , cst_woo_const_pkg.PREPAID_CARD, '421'
                    , cst_woo_const_pkg.CREDIT_CARD, '521'
                    , cst_woo_const_pkg.DEBIT_CARD, '321'
                    , null)                                                     as card_type
             , 3                                                                as brand_code
             , (case
                    when lower(com_api_i18n_pkg.get_text(
                                    i_table_name => 'NET_CARD_TYPE'
                                  , i_column_name => 'NAME'
                                  , i_object_id => crd.card_type_id
                                 )
                               ) like '%classic%'
                    then 'C'
                    when lower(com_api_i18n_pkg.get_text(
                                    i_table_name => 'NET_CARD_TYPE'
                                  , i_column_name => 'NAME'
                                  , i_object_id => crd.card_type_id
                                 )
                               ) like '%gold%'
                    then 'G'
                    when lower(com_api_i18n_pkg.get_text(
                                    i_table_name => 'NET_CARD_TYPE'
                                  , i_column_name => 'NAME'
                                  , i_object_id => crd.card_type_id
                                 )
                               ) like '%platinum%'
                    then 'P'
                    else ''
                end)                                                            as card_grade
             , (select i_cn.card_number
                  from iss_card_instance i_ci
                     , iss_card_number   i_cn
                 where i_ci.card_id = i_cn.card_id
                   and i_ci.id      = ci.preceding_card_instance_id
                   and rownum       = 1
                )                                                               as old_card_num
             , decode(ci.reissue_reason
                       , null, '0'
                       , iss_api_const_pkg.REISS_COMMAND_RENEWAL, '1'
                       , '1'
                     )                                                          as card_issue_class
             , (case
                    when cst_woo_com_pkg.get_latest_change_status_dt(
                            i_event_type_tab => com_dict_tpt(
                                                              'EVNT0160' -- Change card status
                                                            , 'EVNT0192' -- Change card status due to lost
                                                            , 'EVNT5009' -- Change card status due to lost without card
                                                            )
                          , i_object_id      => ci.id
                         ) between i_from_date and i_to_date
                         and ci.status = iss_api_const_pkg.CARD_STATUS_LOST_CARD
                        then '01'
                    when cst_woo_com_pkg.get_latest_change_status_dt(
                            i_event_type_tab => com_dict_tpt(
                                                              'EVNT0160' -- Change card status
                                                            , 'EVNT0193' -- Change card status due to stolen
                                                            )
                          , i_object_id      => ci.id
                          ) between i_from_date and i_to_date
                         and ci.status = iss_api_const_pkg.CARD_STATUS_STOLEN_CARD
                        then '03'
                    when cst_woo_com_pkg.get_latest_change_status_dt(
                            i_event_type_tab => com_dict_tpt(
                                                              'EVNT0201' -- Change card status due to damage
                                                            )
                          , i_object_id      => ci.id
                          ) between i_from_date and i_to_date
                        then '06'
                    when cst_woo_com_pkg.get_latest_crd_limit_dt(
                             i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                           , i_obj_entity  => acct.credit_acct_id
                         ) between i_from_date and i_to_date
                        then '05'
                    when ci.reg_date between i_from_date and i_to_date
                         and ci.status in (
                                            iss_api_const_pkg.CARD_STATUS_VALID_CARD
                                       , iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED
                                       , iss_api_const_pkg.CARD_STATUS_PIN_ACTIVATION
                                       , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE
                                       )
                         then '05'
                    else
                        null
                 end)                                                           as card_status
             , (case
                    when ci.reg_date between i_from_date and i_to_date
                        then ci.reg_date
                    when cst_woo_com_pkg.get_latest_change_status_dt(
                            i_event_type_tab => com_dict_tpt(
                                                              'EVNT0160' -- Change card status
                                                            , 'EVNT0201' -- Change card status due to damage
                                                            , 'EVNT0192' -- Change card status due to lost
                                                            , 'EVNT5009' -- Change card status due to lost without card
                                                            , 'EVNT0193' -- Change card status due to stolen
                                                           )
                          , i_object_id => ci.id
                         ) between i_from_date and i_to_date
                        then cst_woo_com_pkg.get_latest_change_status_dt(
                                i_event_type_tab => com_dict_tpt(
                                                                  'EVNT0160' -- Change card status
                                                                , 'EVNT0201' -- Change card status due to damage
                                                                , 'EVNT0192' -- Change card status due to lost
                                                                , 'EVNT5009' -- Change card status due to lost without card
                                                                , 'EVNT0193' -- Change card status due to stolen
                                                               )
                              , i_object_id => ci.id
                            )
                    when cst_woo_com_pkg.get_latest_crd_limit_dt(
                             i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                           , i_obj_entity  => acct.credit_acct_id
                         ) between i_from_date and i_to_date
                        then cst_woo_com_pkg.get_latest_crd_limit_dt(
                             i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                           , i_obj_entity  => acct.credit_acct_id
                         )
                    when ci.reg_date between i_from_date and i_to_date
                        then ci.reg_date
                    else
                        null
                end)                                                            as card_status_date
             , ci.start_date                                                    as card_issue_date
             , substr(
                cst_woo_com_pkg.get_loyalty_external_num(
                    acct.loyalty_acct_id
                  , acct.split_hash
                ), 1, 6)                                                        as card_aff_code
             , decode(ctf.card_feature
                    , net_api_const_pkg.CARD_FEATURE_STATUS_PREPAID, 'N'
                    , 'Y')                                                      as is_atm_withdraw
             , 'Y'                                                              as is_use_pos
             , cst_woo_com_pkg.get_contract_due_date(ctr.product_id)            as sttl_due_date
             , decode(cus.entity_type
                    , com_api_const_pkg.ENTITY_TYPE_PERSON, 'I3'
                    , 'C2')                                                     as billing_place
             , decode(ctf.card_feature
                    , cst_woo_const_pkg.DEBIT_CARD, acct.saving_acct_num
                    , cst_woo_const_pkg.CREDIT_CARD, acct.credit_acct_num
                    , cst_woo_const_pkg.PREPAID_CARD, acct.prepaid_acct_num)    as account_no
             , (case
                    when ci.delivery_channel = cst_woo_const_pkg.DELIVERY_CHANNEL_PARTY --'CRDC5001' Mail to Home
                        then '01:'||
                                   (select com_api_address_pkg.get_address_string(address_id)
                                      from com_address_object
                                     where entity_type  = com_api_const_pkg.ENTITY_TYPE_CUSTOMER    --'ENTTCUST'
                                       and address_type = com_api_const_pkg.ADDRESS_TYPE_HOME       --'ADTPHOME'
                                       and object_id    = cus.id
                                       and rownum = 1)
                    when ci.delivery_channel = cst_woo_const_pkg.DELIVERY_CHANNEL_STAFF --'CRDC5002' Mail to Office
                        then '02:'||
                                   (select com_api_address_pkg.get_address_string(address_id)
                                      from com_address_object
                                     where entity_type  = com_api_const_pkg.ENTITY_TYPE_CUSTOMER    --'ENTTCUST'
                                       and address_type = com_api_const_pkg.ADDRESS_TYPE_BUSINESS   --'ADTPBSNA'
                                       and object_id    = cus.id
                                       and rownum = 1)
                    when ci.delivery_channel = cst_woo_const_pkg.DELIVERY_CHANNEL_BRANCH --'CRDC5003' Branch pickup
                        then '03:'||
                                    com_api_flexible_data_pkg.get_flexible_value(
                                        i_field_name  => 'CST_CARD_DELIVERY_AGENT'
                                      , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                                      , i_object_id   => crd.id)                       
                    when ci.delivery_channel = cst_woo_const_pkg.DELIVERY_CHANNEL_CUSTOMER --'CRDC5004' Customer pickup
                        then '04:'
                    else null
                end)                                                            as delivery_info
             , acct.saving_acct_num                                             as sav_acct_num
             , com_api_flexible_data_pkg.get_flexible_value(
                    'CST_VIRTUAL_ACCOUNT_NUMBER'
                  , acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , nvl(acct.credit_acct_id, acct.prepaid_acct_id)
               )                                                                as vir_acct_num
             , decode(cus.entity_type
                    , com_api_const_pkg.ENTITY_TYPE_COMPANY
                    , get_text('com_company', 'label', cus.object_id, 'LANGENG')
                    , com_ui_person_pkg.get_person_name(cus.object_id, 'LANGENG')
                    )                                                           as cust_name
             , decode(cus.entity_type
                    , com_api_const_pkg.ENTITY_TYPE_COMPANY
                    , get_text('com_company', 'label', cus.object_id, 'LANGENG')
                    , com_ui_person_pkg.get_person_name(cus.object_id, 'LANGENG')
                    )                                                           as cust_name_eng
             , decode(cus.entity_type
                    , com_api_const_pkg.ENTITY_TYPE_PERSON, '01', '05')         as card_relations
             , (select
                    cst_woo_com_pkg.get_mapping_code(
                        i_code          => id_type
                      , i_array_id      => cst_woo_const_pkg.WOORI_ID_TYPE
                      , i_in_out        => 0 -- 1: in -- 0 out
                      , i_language      => 'LANGENG')
                  from com_id_object
                 where object_id        = cus.object_id
                   and entity_type      = com_api_const_pkg.ENTITY_TYPE_PERSON
                   and rownum           = 1
               )                                                                as card_holder_type_id
             , (select substr(id_number, 0, 12)
                  from com_id_object
                 where object_id       = cus.object_id
                   and entity_type     = com_api_const_pkg.ENTITY_TYPE_PERSON
                   and rownum          = 1
               )                                                                as card_holder_id
             , decode(com_api_flexible_data_pkg.get_flexible_value(
                         i_field_name  => 'CST_COLLATERAL_ACCOUNT'
                       , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       , i_object_id   => acct.credit_acct_id), null
                       , null, 'R')                                             as col_property_info
             , null                                                             as col_property_id
             , com_api_flexible_data_pkg.get_flexible_value(
                    i_field_name       => 'CST_COLLATERAL_ACCOUNT'
                  , i_entity_type      =>  acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id        =>  acct.credit_acct_id
                )                                                               as col_acct_no
          from iss_card crd
             , iss_card_instance ci
             , ost_agent agt
             , prd_customer cus
             , prd_contract ctr
             , net_card_type_feature ctf
             , (select icn.card_id, icn.card_number, act.split_hash
                       , max(decode(act.account_type, cst_woo_const_pkg.ACCT_TYPE_SAVING_VND, act.id))               as saving_acct_id   --'ACTP0131'
                       , max(decode(act.account_type, acc_api_const_pkg.ACCOUNT_TYPE_CREDIT, act.id))                as credit_acct_id   --'ACTP0130'
                       , max(decode(act.account_type, cst_woo_const_pkg.ACCT_TYPE_SAVING_VND, act.account_number))   as saving_acct_num  --'ACTP0131'
                       , max(decode(act.account_type, acc_api_const_pkg.ACCOUNT_TYPE_CREDIT, act.account_number))    as credit_acct_num  --'ACTP0130'
                       , max(decode(act.account_type, cst_woo_const_pkg.ACCT_TYPE_PREPAID_VND, act.account_number))  as prepaid_acct_num --'ACTP0140'
                       , max(decode(act.account_type, cst_woo_const_pkg.ACCT_TYPE_PREPAID_VND, act.id))              as prepaid_acct_id  --'ACTP0140'
                       , max(decode(act.account_type, cst_woo_const_pkg.ACCT_TYPE_LOYALTY, act.id))                  as loyalty_acct_id  --'ACTPLOYT'
                    from acc_account_object aao
                       , iss_card_number    icn
                       , acc_account        act
                 where aao.object_id        = icn.card_id
                     and aao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                     and aao.account_id     = act.id
                     and act.inst_id        = cst_woo_const_pkg.W_INST
                   group by icn.card_id, icn.card_number, act.split_hash
                ) acct
          where crd.id                      = acct.card_id
            and crd.id                      = ci.card_id
            and ci.agent_id                 = agt.id
            and crd.contract_id             = ctr.id
            and crd.customer_id             = cus.id
            and ctf.card_type_id            = crd.card_type_id
            and (
                ci.reg_date between i_from_date and i_to_date
                or
                cst_woo_com_pkg.get_latest_change_status_dt(
                    i_event_type_tab => com_dict_tpt(
                                                      'EVNT0160' -- Change card status
                                                    , 'EVNT0201' -- Change card status due to damage
                                                    , 'EVNT0192' -- Change card status due to lost
                                                    , 'EVNT5009' -- Change card status due to lost without card
                                                    , 'EVNT0193' -- Change card status due to stolen
                                                    )
                  , i_object_id      => ci.id
                ) between i_from_date and i_to_date
                or
                cst_woo_com_pkg.get_latest_crd_limit_dt(
                    i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                  , i_obj_entity  => acct.credit_acct_id
                ) between i_from_date and i_to_date
                )
       order by ci.reg_date;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_75;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_75               cst_woo_api_type_pkg.t_mes_tab_75;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text  => 'Export batch file 75 -> start'
    );

    l_inst_id   := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_end_date, get_sysdate));
    l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_75
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f75_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f75_data bulk collect into l_mes_tab_75 limit BULK_LIMIT;

        for i in 1..l_mes_tab_75.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_75(i).file_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).req_date, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).issused_date, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).reg_type), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).issused_branch), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).staff_num), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).inviter_num), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).manage_agent_id), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).cif_num), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_num), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_expire_date, 'MMYY'), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).division), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).prod_code), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_type_class), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_class), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_type), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).brand_code), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_grade), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).old_card_num), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_issue_class), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_status), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_status_date, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_issue_date, 'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_aff_code), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).is_atm_withdraw), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).is_use_pos), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).sttl_due_date, 'DD'), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).billing_place), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).account_no), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).cert_code), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).sav_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).vir_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).cust_name), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).cust_name_eng), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_relations), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_holder_type_id), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).card_holder_id), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).col_property_info), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).col_property_id), '')
            || '|' || nvl(to_char(l_mes_tab_75(i).col_acct_no), '')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_record.delete;

        end loop;

        exit when cur_f75_data%notfound;

      end loop;

    close cur_f75_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id        => l_session_file_id
      , i_status              => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f75_data%isopen then
        close cur_f75_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_75;
--------------------------------------------------------------------------------
procedure batch_file_83(
    i_inst_id           in com_api_type_pkg.t_inst_id
) is

    cursor cur_f83_data(
        i_inst_id    com_api_type_pkg.t_inst_id
    ) is
    select get_sysdate                              as base_date
         , agt.agent_number                         as agent_number
         , cus.customer_number                      as cif_code
         , (select ich.cardholder_name
              from iss_card             ica
                 , iss_cardholder       ich
             where ich.id               = ica.cardholder_id
               and ica.category         = iss_api_const_pkg.CARD_CATEGORY_PRIMARY --'CRCG0800'
               and ica.customer_id      = cus.id
               and rownum               = 1
            )                                       as cardholder_name
         , cst_woo_com_pkg.get_customer_address(
               i_customer_id => cus.id
             , i_language    => com_api_const_pkg.LANGUAGE_ENGLISH --'LANGENG'
           )                                        as address
         , cst_woo_com_pkg.get_customer_city_code(
               i_customer_id => cus.id
             , i_lang        => com_api_const_pkg.LANGUAGE_ENGLISH --'LANGENG'
           )                                        as province_code
         , nvl(
               com_api_contact_pkg.get_contact_string(
                    i_contact_id    => mt.contact_id
                  , i_commun_method => mt.commun_method
                  , i_start_date    => get_sysdate
               )
             , com_api_contact_pkg.get_contact_string(
                    i_contact_id    => bt.contact_id
                  , i_commun_method => bt.commun_method
                  , i_start_date    => get_sysdate
               )
           )                                        as phone_num
         , cus.nationality                          as nationality
         , decode(psn.gender, 'GNDRFEML', 0, 'GNDRMALE', 1, null)     as gender
         , psn.birthday                             as birth_date
         , ido.id_document                          as id_num
         , ido.id_issue_date                        as id_issued_date
         , null                                     as doc_num
         , null                                     as doc_issued_date
         , null                                     as tax_code
         , null                                     as wh_name
         , null                                     as id_num_of_wh
         , null                                     as sup_cardholder_name
         , null                                     as sup_cardholder_id
      from prd_customer          cus
         , prd_contract          con
         , ost_agent             agt
         , com_person            psn
         , net_card_type_feature nct
         , iss_card              ica
         , acc_account           acc
         , acc_account_object    aco
         , crd_invoice           cri
         , (select c.object_id  as customer_id
                 , c.contact_id
                 , d.commun_method
                 , row_number() over (partition by c.object_id
                                          order by d.end_date desc nulls first
                                                 , c.id desc
                                      ) rng
              from com_contact_object   c
                 , com_contact_data     d
             where c.entity_type    = com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
               and d.contact_id     = c.contact_id
               and d.commun_method  = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE --'CMNM0001'
            ) mt
         , (select c.object_id as customer_id
                 , c.contact_id
                 , d.commun_method
                 , row_number() over (partition by c.object_id
                                          order by d.end_date desc nulls first
                                                 , c.id desc
                                      ) rng
              from com_contact_object   c
                 , com_contact_data     d
             where c.entity_type    = com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
               and d.contact_id     = c.contact_id
               and d.commun_method  = com_api_const_pkg.COMMUNICATION_METHOD_PHONE --'CMNM0012'
            ) bt
         , (select row_number() over (partition by i.object_id
                                          order by i.id desc
                                      ) as rng
                 , i.object_id
                 , i.id_type
                 , com_api_dictionary_pkg.get_article_text(
                       i_article => i.id_type
                     , i_lang    => com_api_const_pkg.LANGUAGE_ENGLISH --'LANGENG'
                   ) id_name
                 , substr(i.id_number, 0, 20)   as id_document
                 , i.id_issue_date
                 , i.id_expire_date
              from com_id_object i
            ) ido
     where 1                    = 1
       and acc.id               = aco.account_id
       and acc.customer_id      = cus.id
       and acc.account_type     = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT   --'ACTP0130'
       and acc.status          != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED --'ACSTCLSD'
       and acc.split_hash       = cri.split_hash(+)
       and acc.id               = cri.account_id(+)
       and cri.id(+) = crd_invoice_pkg.get_last_invoice_id(
                           i_account_id    => acc.id
                         , i_split_hash    => acc.split_hash
                         , i_mask_error    => com_api_const_pkg.TRUE --1
                       )
       and aco.entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
       and aco.object_id        = ica.id
       and ica.contract_id      = con.id
       and cus.id               = ica.customer_id
       and agt.id               = con.agent_id
       and nct.card_feature     = cst_woo_const_pkg.CREDIT_CARD  --'CFCHCRDT'   --only get the customer has credit card
       and nct.card_type_id     = ica.card_type_id
       and cus.object_id        = psn.id(+)
       and psn.lang(+)          = com_api_const_pkg.LANGUAGE_ENGLISH --'LANGENG'
       and cus.id               = mt.customer_id(+)
       and 1                    = mt.rng(+)
       and cus.id               = bt.customer_id(+)
       and 1                    = bt.rng(+)
       and cus.object_id        = ido.object_id(+)
       and 1                    = ido.rng(+)
       group by cus.customer_number, cus.id, cus.nationality
              , psn.gender, psn.birthday, psn.lang
              , ido.id_document, ido.id_issue_date, agt.agent_number
              , mt.contact_id, mt.commun_method, bt.contact_id, bt.commun_method
       order by cus.customer_number
       ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_83;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_83                cst_woo_api_type_pkg.t_mes_tab_83;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text  => 'Export batch file 83 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_83
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f83_data(
        i_inst_id    => l_inst_id
    );

    loop
        fetch cur_f83_data bulk collect into l_mes_tab_83 limit BULK_LIMIT;

        for i in 1..l_mes_tab_83.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_83(i).base_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).branch_code), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).cif_code), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).cardholder_name), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).address), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).province_code), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).phone_num), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).nationality), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).gender), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).birth_date, 'DDMMYYYY'), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).id_num), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).id_issued_date, 'DDMMYYYY'), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).doc_num), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).doc_issued_date, 'DDMMYYYY'), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).tax_code), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).wh_name), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).id_num_of_wh), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).sup_cardholder_name), '')
            || '|' || nvl(to_char(l_mes_tab_83(i).sup_cardholder_id), '')
            ;

             prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_record.delete;

        end loop;

        exit when cur_f83_data%notfound;

    end loop;

    close cur_f83_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f83_data%isopen then
        close cur_f83_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_83;
--------------------------------------------------------------------------------
procedure batch_file_83_1(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_end_date          in      date    default null
) is

    cursor cur_f83_1_data(
        i_inst_id       com_api_type_pkg.t_inst_id
      , i_end_date      in      date
    )
    is
     select
           i_end_date                                 as base_date
         , agt.agent_number                           as branch_code
         , cus.customer_number                        as cif_code
         , ici.cardholder_name                        as cardholder_name
         --, ctr.contract_number                        as contract_num
         , cus.customer_number                        as customer_number  --Change requirement, replace contract_num with customer_number
         , case
            when  lower(com_api_i18n_pkg.get_text(
                       i_table_name  => 'NET_CARD_TYPE'
                     , i_column_name => 'NAME'
                     , i_object_id   => ic.card_type_id
                   )) like '%visa%' then
                    'VISA'
            else
                substr(com_api_i18n_pkg.get_text(
                       i_table_name  => 'NET_CARD_TYPE'
                     , i_column_name => 'NAME'
                     , i_object_id   => ic.card_type_id
                   ),1,10)
            end                                       as card_type_name
         , ici.start_date                             as card_open_date
         , ici.expir_date                             as expired_date
         , null                                       as card_closed_date
         , ci.exceed_limit                            as crd_limit
         , ci.invoice_date                            as statement_date
         , ci.total_amount_due                        as payment_amt
         , ci.min_amount_due                          as min_payment_amt
         , cst_woo_com_pkg.get_total_payment(
                                i_account_id  => ci.account_id
                              , i_bill_date   => ci.invoice_date
                              , i_spent       => 1
                              )                       as paid_amt
         , cst_woo_com_pkg.get_overdue_amt(
                  i_account_id   => acct.id
                , i_split_hash   => acct.split_hash
               )
                                                      as overdue_amt
         , trunc(i_end_date - cst_woo_com_pkg.get_first_overdue_date(
                                    i_account_id => acct.id
                                  , i_split_hash => acct.split_hash
                                ))                    as overdue_day_count
         , ci.aging_period                            as overdue_count
      from prd_customer cus
         , prd_contract ctr
         , ost_agent agt
         , iss_card ic
         , iss_card_instance ici
         , acc_account acct
         , acc_account_object acct_obj
         , crd_invoice ci
     where 1 = 1
       and cus.id               = ctr.customer_id
       and ctr.agent_id         = agt.id
       and ic.contract_id       = ctr.id
       and ic.category          = iss_api_const_pkg.CARD_CATEGORY_PRIMARY   --'CRCG0800'
       and ic.id                = ici.card_id
       and acct.id              = acct_obj.account_id
       and acct_obj.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
       and acct_obj.object_id   = ic.id
       and acct.customer_id     = cus.id
       and acct.account_type    = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT --'ACTP0130'
       and acct.status          in (
                                     acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE    -- 'ACSTACTV'
                                   , acc_api_const_pkg.ACCOUNT_STATUS_CREDITS   -- 'ACSTCRED'
                                   , cst_woo_const_pkg.ACCOUNT_STATUS_OVERDUE   -- 'ACSTBOVD'
                                   )
       and acct.status         != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
       and acct.split_hash      = ci.split_hash(+)
       and acct.id              = ci.account_id(+)
       and ci.id(+) = crd_invoice_pkg.get_last_invoice_id(
                          i_account_id    => acct.id
                        , i_split_hash    => acct.split_hash
                        , i_mask_error    => com_api_const_pkg.TRUE --1
                      )
       ;


--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_83_1;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_83_1               cst_woo_api_type_pkg.t_mes_tab_83_1;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text          => 'Export batch file 83_1 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_83_1
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f83_1_data(
        i_inst_id    => l_inst_id
      , i_end_date   => nvl(i_end_date, get_sysdate)
    );

    loop
        fetch cur_f83_1_data bulk collect into l_mes_tab_83_1 limit BULK_LIMIT;

        for i in 1..l_mes_tab_83_1.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_83_1(i).base_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).branch_code), '')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).cif_code), '')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).cardholder_name), '')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).contract_num), '')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).card_type_name), '')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).card_open_date, 'DDMMYYYY'), '')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).expired_date, 'DDMMYYYY'), '')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).card_closed_date, 'DDMMYYYY'), '')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).crd_limit), '0')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).statement_date, 'DDMMYYYY'), '')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).payment_amt), '0')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).min_payment_amt), '0')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).paid_amt), '0')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).overdue_amt), '0')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).overdue_day_count), '0')
            || '|' || nvl(to_char(l_mes_tab_83_1(i).overdue_count), '0')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_record.delete;

        end loop;

        exit when cur_f83_1_data%notfound;

    end loop;

    close cur_f83_1_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f83_1_data%isopen then
        close cur_f83_1_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;
end batch_file_83_1;
--------------------------------------------------------------------------------
procedure batch_file_87(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date    default null
  , i_end_date              in      date    default null
) is

    cursor cur_f87_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
        select t.invoice_date
             , t.customer_number
             , t.account_number
             , t.due_date
             , sum(t.fee_amount)                as fee_amount
             , sum(t.pos_domes_invi_amount)     as pos_domes_invi_amount
             , sum(t.pos_interest)              as pos_interest
             , sum(t.pos_oversea_invi_amount)   as pos_oversea_invi_amount
             , sum(t.pos_domes_corp_amount)     as pos_domes_corp_amount
             , sum(t.pos_oversea_corp_amount)   as pos_oversea_corp_amount
             , sum(t.cash_domes_invi_amount)    as cash_domes_invi_amount
             , sum(t.cash_interest)             as cash_interest
             , sum(t.cash_oversea_invi_amount)  as cash_oversea_invi_amount
             , cst_woo_com_pkg.get_invoice_project_interest(t.invoice_id) as pro_interest
          from (
                select cri.invoice_date
                     , cus.customer_number
                     , aac.account_number
                     , cri.due_date
                     , opo.id as operation_id
                     , crm.invoice_id
                    -- Field 1 - Fee(Include VAT)
                     , (case when lower(crm.macros_type_name) like '%fee%'
                             then crm.amount
                        else 0
                         end
                        ) as fee_amount
                    -- Field 2 - Domestic Individual POS purchase
                     , (case when (opp.card_country     = opo.merchant_country and vfm.settlement_flag <> 0)         -- domestic
                              and cus.entity_type       = com_api_const_pkg.ENTITY_TYPE_PERSON                      --'ENTTPERS'
                              and crm.oper_type         = opr_api_const_pkg.OPERATION_TYPE_PURCHASE              -- 'OPTP0000'
                              and crm.balance_type      not in (
                                                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                               )
                              and lower(crm.macros_type_name) not like '%fee%'
                             then crm.amount
                             -- Account debit adjustment:
                             when cus.entity_type       = com_api_const_pkg.ENTITY_TYPE_PERSON                      --'ENTTPERS'
                              and crm.oper_type         = opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST             --'OPTP0402'
                              and crm.balance_type      not in (
                                                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST            --'BLTP1003'
                                                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST    --'BLTP1005'
                                                               )
                              and lower(crm.macros_type_name) not like '%fee%'
                             then crm.amount
                             --For DPP tranactions:
                             when cus.entity_type       = com_api_const_pkg.ENTITY_TYPE_PERSON                      --'ENTTPERS'
                              and crm.oper_type         = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER          -- 'OPTP1501'
                              and crm.balance_type      not in (
                                                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                               )
                              and lower(crm.macros_type_name) not like '%fee%'
                              and crm.macros_type_id != 7182 -- DPP interest
                              and exists (select 1
                                            from opr_operation o, opr_participant p, crd_debt c
                                           where o.id = p.oper_id
                                             and o.id = c.original_id
                                             and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER      -- 'PRTYISS'
                                             and o.oper_type        = opr_api_const_pkg.OPERATION_TYPE_PURCHASE -- 'OPTP0000'
                                             and p.card_country     = o.merchant_country                        -- domestic
                                             and c.oper_id          = opo.id
                                             and c.id               = crm.debt_id
                                          )
                             then crm.amount
                             else 0
                         end
                        ) as pos_domes_invi_amount
                    -- Field 3 - Interest - POS purchase
                     , (case when crm.oper_type         = opr_api_const_pkg.OPERATION_TYPE_PURCHASE          -- 'OPTP0000'
                              and crm.balance_type      in (
                                                             crd_api_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                           , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                           )
                              and lower(crm.macros_type_name) not like '%fee%'
                             then crm.amount
                             when crm.oper_type         = opr_api_const_pkg.OPERATION_TYPE_PURCHASE                 --'OPTP1501'
                              and crm.balance_type      in (
                                                             crd_api_const_pkg.BALANCE_TYPE_INTEREST                --'BLTP1003'
                                                           , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST        --'BLTP1005'
                                                           )
                              and crm.macros_type_id = 7182 -- DPP interest
                             then crm.amount
                             else 0
                         end
                        ) as pos_interest
                    -- Field 4 - Overseas Individual POS purchase
                     , (case when (opp.card_country    != opo.merchant_country or vfm.settlement_flag = 0)          -- overseaa
                              and cus.entity_type       = com_api_const_pkg.ENTITY_TYPE_PERSON                      --'ENTTPERS'
                              and crm.oper_type         = opr_api_const_pkg.OPERATION_TYPE_PURCHASE              -- 'OPTP0000'
                              and crm.balance_type      not in (
                                                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                               )
                              and lower(crm.macros_type_name) not like '%fee%'
                             then crm.amount
                             --For DPP tranactions:
                             when cus.entity_type       = com_api_const_pkg.ENTITY_TYPE_PERSON                      --'ENTTPERS'
                              and crm.oper_type         = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER          -- 'OPTP1501'
                              and crm.balance_type      not in (
                                                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                               )
                              and lower(crm.macros_type_name) not like '%fee%'
                              and exists (select 1
                                            from opr_operation o, opr_participant p, crd_debt c
                                           where o.id = p.oper_id
                                             and o.id = c.original_id
                                             and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER      -- 'PRTYISS'
                                             and o.oper_type        = opr_api_const_pkg.OPERATION_TYPE_PURCHASE -- 'OPTP0000'
                                             and p.card_country     != o.merchant_country                        -- oversea
                                             and c.oper_id          = opo.id
                                             and c.id               = crm.debt_id
                                          )
                             then crm.amount
                             else 0
                         end
                        ) as pos_oversea_invi_amount
                    -- Field 5 - Domestic Corporate POS purchase
                     , (case when (opp.card_country     = opo.merchant_country and vfm.settlement_flag <> 0)         -- domestic
                              and cus.entity_type       = com_api_const_pkg.ENTITY_TYPE_COMPANY                     --'ENTTCOMP'
                              and crm.oper_type         = opr_api_const_pkg.OPERATION_TYPE_PURCHASE              -- 'OPTP0000'
                              and crm.balance_type      not in (
                                                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                               )
                              and lower(crm.macros_type_name) not like '%fee%'
                             then crm.amount
                             --For DPP tranactions:
                             when cus.entity_type       = com_api_const_pkg.ENTITY_TYPE_COMPANY                     --'ENTTCOMP'
                              and crm.oper_type         = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER          -- 'OPTP1501'
                              and crm.balance_type      not in (
                                                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                               )
                              and lower(crm.macros_type_name) not like '%fee%'
                              and exists (select 1
                                            from opr_operation o, opr_participant p, crd_debt c
                                           where o.id = p.oper_id
                                             and o.id = c.original_id
                                             and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER      -- 'PRTYISS'
                                             and o.oper_type        = opr_api_const_pkg.OPERATION_TYPE_PURCHASE -- 'OPTP0000'
                                             and p.card_country     = o.merchant_country                        -- domestic
                                             and c.oper_id          = opo.id
                                             and c.id               = crm.debt_id
                                          )
                             then crm.amount
                             else 0
                          end
                         ) as pos_domes_corp_amount
                    -- Field 6 - Overseas Corporate POS purchase
                     , (case when (opp.card_country    != opo.merchant_country or vfm.settlement_flag = 0)          -- oversea
                              and cus.entity_type       = com_api_const_pkg.ENTITY_TYPE_COMPANY                     --'ENTTCOMP'
                              and crm.oper_type         = opr_api_const_pkg.OPERATION_TYPE_PURCHASE     -- 'OPTP0000'
                              and crm.balance_type      not in (
                                                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                               )
                              and lower(crm.macros_type_name) not like '%fee%'
                             then crm.amount
                             --For DPP tranactions:
                             when cus.entity_type       = com_api_const_pkg.ENTITY_TYPE_COMPANY                     --'ENTTCOMP'
                              and crm.oper_type         = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER          -- 'OPTP1501'
                              and crm.balance_type      not in (
                                                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                               )
                              and lower(crm.macros_type_name) not like '%fee%'
                              and exists (select 1
                                            from opr_operation o, opr_participant p, crd_debt c
                                           where o.id = p.oper_id
                                             and o.id = c.original_id
                                             and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER      -- 'PRTYISS'
                                             and o.oper_type        = opr_api_const_pkg.OPERATION_TYPE_PURCHASE -- 'OPTP0000'
                                             and p.card_country     != o.merchant_country                        -- oversea
                                             and c.oper_id          = opo.id
                                             and c.id               = crm.debt_id
                                          )
                             then crm.amount
                             else 0
                         end
                        ) as pos_oversea_corp_amount
                    -- Field 7 - Domestic Individual Cash Advance
                     , (case when (opp.card_country     = opo.merchant_country and vfm.settlement_flag <> 0)        -- domestic
                              and cus.entity_type       = com_api_const_pkg.ENTITY_TYPE_PERSON                      --'ENTTPERS'
                              and crm.oper_type         = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH              -- 'OPTP0001'
                              and crm.balance_type      not in (
                                                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                               )
                              and lower(crm.macros_type_name) not like '%fee%'
                             then crm.amount
                             else 0
                         end
                        ) as cash_domes_invi_amount
                    -- Field 8 - Interest - Cash Advance
                     , (case when crm.oper_type         = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH          -- 'OPTP0001'
                              and crm.balance_type      in (
                                                             crd_api_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                           , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                           )
                              and lower(crm.macros_type_name) not like '%fee%'
                             then crm.amount
                             else 0
                         end
                        ) as cash_interest
                    --Field 9 - Overseas Individual Cash Advance
                     , (case when (opp.card_country    != opo.merchant_country or vfm.settlement_flag = 0)          -- oversea
                              and cus.entity_type       = com_api_const_pkg.ENTITY_TYPE_PERSON                      --'ENTTPERS'
                              and crm.oper_type         = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH     -- 'OPTP0001'
                              and crm.balance_type      not in (
                                                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                               )
                              and lower(crm.macros_type_name) not like '%fee%'
                             then crm.amount
                             else 0
                         end
                        ) as cash_oversea_invi_amount
                  from crd_ui_invoice_mad_vw    crm
                     , crd_ui_invoice_vw        cri
                     , opr_operation            opo
                     , opr_participant          opp
                     , acc_account              aac
                     , prd_customer             cus
                     , prd_contract             cnt
                     , vis_fin_message          vfm
                 where 1                        = 1
                   and cri.id                   = crm.invoice_id
                   and opo.id                   = crm.oper_id
                   and opo.id                   = opp.oper_id
                   and aac.id                   = cri.account_id
                   and cnt.id                   = cus.contract_id
                   and cus.id                   = opp.customer_id
                   and opo.id                   = vfm.id(+)
                   and opo.status               = opr_api_const_pkg.OPERATION_STATUS_PROCESSED      -- 'OPST0400'
                   and opo.oper_type            in (
                                                      opr_api_const_pkg.OPERATION_TYPE_PURCHASE     -- 'OPTP0000'
                                                    , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH     -- 'OPTP0001'
                                                    , opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE   -- 'OPTP0119'
                                                    , dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER -- 'OPTP1501'
                                                    , opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST --'OPTP0402'
                                                    )
                   and aac.account_type         = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
                   and opp.participant_type     = com_api_const_pkg.PARTICIPANT_ISSUER  -- 'PRTYISS'
                   and crm.lang                 = com_api_const_pkg.LANGUAGE_ENGLISH    -- 'LANGENG'
                   and cri.id                   = crd_invoice_pkg.get_last_invoice_id(
                                                      i_account_id    => cri.account_id
                                                    , i_split_hash    => aac.split_hash
                                                    , i_mask_error    => com_api_const_pkg.TRUE
                                                  )
                   and cri.invoice_date between nvl(i_from_date, cri.invoice_date) and nvl(i_to_date, cri.invoice_date)
                ) t
         group by t.invoice_date
                , t.customer_number
                , t.account_number
                , t.due_date
                , t.invoice_id
         order by t.invoice_date
                , t.customer_number
         ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_87;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_87                cst_woo_api_type_pkg.t_mes_tab_87;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text    => 'Export batch file 87  -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := i_start_date;
    l_to_date   := i_end_date;

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_87
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
     open cur_f87_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f87_data bulk collect into l_mes_tab_87 limit BULK_LIMIT;

        for i in 1..l_mes_tab_87.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_87(i).invoice_date, cst_woo_const_pkg.WOORI_DATE_YYYYMM), '')
            || '|' || nvl(to_char(l_mes_tab_87(i).cif_no), '')
            || '|' || nvl(to_char(l_mes_tab_87(i).account_number), '')
            || '|' || nvl(to_char(l_mes_tab_87(i).due_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_87(i).fee_amount), '0')
            || '|' || nvl(to_char(l_mes_tab_87(i).pos_domes_invi_amount), '0')
            || '|' || nvl(to_char(l_mes_tab_87(i).pos_interest), '0')
            || '|' || nvl(to_char(l_mes_tab_87(i).pos_oversea_invi_amount), '0')
            || '|' || nvl(to_char(l_mes_tab_87(i).pos_domes_corp_amount), '0')
            || '|' || nvl(to_char(l_mes_tab_87(i).pos_oversea_corp_amount), '0')
            || '|' || nvl(to_char(l_mes_tab_87(i).cash_domes_invi_amount), '0')
            || '|' || nvl(to_char(l_mes_tab_87(i).cash_interest), '0')
            || '|' || nvl(to_char(l_mes_tab_87(i).cash_oversea_invi_amount), '0')
            || '|' || nvl(to_char(l_mes_tab_87(i).pro_interest), '0')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_record.delete;

        end loop;

        exit when cur_f87_data%notfound;

    end loop;

    close cur_f87_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f87_data%isopen then
        close cur_f87_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_87;
--------------------------------------------------------------------------------
procedure batch_file_88 (
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date    default null
) is

    -- Main cursor with data:
    cursor cur_f88_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
    select customer_number
         , account_number
         , payment_posting_date
         , sum(payment_fee_amount)            as payment_fee_amount
         , sum(payment_dom_ind_pos)           as payment_dom_ind_pos
         , sum(payment_interest_ind_pos)      as payment_interest_ind_pos
         , sum(payment_overs_ind_pos)         as payment_overs_ind_pos
         , sum(payment_dom_corp_pos)          as payment_dom_corp_pos
         , sum(payment_overs_corp_pos)        as payment_overs_corp_pos
         , sum(payment_dom_ind_cash)          as payment_dom_ind_cash
         , sum(payment_interest_dom_ind_cash) as payment_interest_dom_ind_cash
         , sum(payment_overs_ind_cash)        as payment_overs_ind_cash
         , sum(overdue_fee_amount)            as overdue_fee_amount
         , sum(overdue_dom_ind_pos)           as overdue_dom_ind_pos
         , sum(overdue_interest_ind_pos)      as overdue_interest_ind_pos
         , sum(overdue_overs_ind_pos)         as overdue_overs_ind_pos
         , sum(overdue_dom_corp_pos)          as overdue_dom_corp_pos
         , sum(overdue_overs_corp_pos)        as overdue_overs_corp_pos
         , sum(overdue_dom_ind_cash)          as overdue_dom_ind_cash
         , sum(overdue_interest_dom_ind_cash) as overdue_interest_dom_ind_cash
         , sum(overdue_overs_ind_cash)        as overdue_overs_ind_cash
      from (
            select t.customer_number
                 , t.account_number
                 , trunc(t.payment_posting_date) as payment_posting_date
                 , case when t.amount_category like 'P_F%'
                        then t.pay_amount
                        else 0
                   end as payment_fee_amount            -- field 5
                 , case when t.amount_category =    'P PDI'
                        then t.pay_amount
                        else 0
                   end as payment_dom_ind_pos           -- field 6
                 , case when t.amount_category like 'PIP_I' --< Updated in 2017.09.26
                        then t.pay_amount
                        else 0
                   end as payment_interest_ind_pos      -- field 7
                 , case when t.amount_category =    'P POI'
                        then t.pay_amount
                        else 0
                   end as payment_overs_ind_pos         -- field 8
                 , case when t.amount_category =    'P PDC'
                        then t.pay_amount
                        else 0
                   end as payment_dom_corp_pos          -- field 9
                 , case when t.amount_category =    'P POC'
                        then t.pay_amount
                        else 0
                   end as payment_overs_corp_pos        -- field 10
                 , case when t.amount_category =    'P CDI'
                        then t.pay_amount
                        else 0
                   end as payment_dom_ind_cash          -- field 11
                 , case when t.amount_category =    'PICDI'
                        then t.pay_amount
                        else 0
                   end as payment_interest_dom_ind_cash -- field 12
                 , case when t.amount_category =    'P COI'
                        then t.pay_amount
                        else 0
                   end as payment_overs_ind_cash        -- field 13
                 , case when t.amount_category like 'O_F%'
                        then t.pay_amount
                        else 0
                   end as overdue_fee_amount            -- field 14
                 , case when t.amount_category =    'O PDI'
                        then t.pay_amount
                        else 0
                   end as overdue_dom_ind_pos           -- field 15
                 , case when t.amount_category like 'OIP_I'  --< Updated in 2017.09.26
                        then t.pay_amount
                        else 0
                   end as overdue_interest_ind_pos      -- field 16
                 , case when t.amount_category =    'O POI'
                        then t.pay_amount
                        else 0
                   end as overdue_overs_ind_pos         -- field 17
                 , case when t.amount_category =    'O PDC'
                        then t.pay_amount
                        else 0
                   end as overdue_dom_corp_pos          -- field 18
                 , case when t.amount_category =    'O POC'
                        then t.pay_amount
                        else 0
                   end as overdue_overs_corp_pos        -- field 19
                 , case when t.amount_category =    'O CDI'
                        then t.pay_amount
                        else 0
                   end as overdue_dom_ind_cash          -- field 20
                 , case when t.amount_category =    'OICDI'
                        then t.pay_amount
                        else 0
                   end as overdue_interest_dom_ind_cash -- field 21
                 , case when t.amount_category =    'O COI'
                        then t.pay_amount
                        else 0
                   end as overdue_overs_ind_cash        -- field 22
              from (select decode(cdp.balance_type,
                                  cst_woo_const_pkg.BALANCE_TYPE_OVERDRAFT,        'P ', -- Payment/prepayment
                                  cst_woo_const_pkg.BALANCE_TYPE_INTEREST,         'PI', -- Payment interest
                                  cst_woo_const_pkg.BALANCE_TYPE_OVERDUE,          'O ', -- Overdue
                                  cst_woo_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST, 'OI') -- Overdue interest
                        || decode(oo.oper_type,
                                  opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE, -- Issuer fee
                                      'F',
                                  opr_api_const_pkg.OPERATION_TYPE_PURCHASE,   -- POS purchase
                                      case when cd.macros_type_id in (
                                                                       cst_woo_const_pkg.MACROS_TYPE_ID_DEBIT_FEE       -- 1007
                                                                     , cst_woo_const_pkg.MACROS_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                                                     , cst_woo_const_pkg.MACROS_TYPE_ID_VAT             -- 7011
                                                                     , cst_woo_const_pkg.MACROS_TYPE_ID_ORIG_FEE        -- 7126
                                                                     )
                                           then 'F'
                                           else 'P'
                                      end,
                                  dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER, --'OPTP1501'
                                                'P',
                                  opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST, --'OPTP0402'
                                                'P',
                                  opr_api_const_pkg.OPERATION_TYPE_ATM_CASH,   -- Cash withdrawal
                                      case when cd.macros_type_id in (
                                                                       cst_woo_const_pkg.MACROS_TYPE_ID_DEBIT_FEE       -- 1007
                                                                     , cst_woo_const_pkg.MACROS_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                                                     , cst_woo_const_pkg.MACROS_TYPE_ID_VAT             -- 7011
                                                                     , cst_woo_const_pkg.MACROS_TYPE_ID_ORIG_FEE        -- 7126
                                                                     )
                                           then 'F'
                                           else 'C'
                                      end,
                                  opr_api_const_pkg.OPERATION_TYPE_POS_CASH,   -- POS Cash advance
                                      case when cd.macros_type_id in (
                                                                       cst_woo_const_pkg.MACROS_TYPE_ID_DEBIT_FEE       -- 1007
                                                                     , cst_woo_const_pkg.MACROS_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                                                     , cst_woo_const_pkg.MACROS_TYPE_ID_VAT             -- 7011
                                                                     , cst_woo_const_pkg.MACROS_TYPE_ID_ORIG_FEE        -- 7126
                                                                     )
                                           then 'F'
                                           else 'C'
                                      end,'C')
                        || case when op.card_country = oo.merchant_country and vfm.settlement_flag <> 0
                                then 'D' -- Domestic
                                when op.card_country <> oo.merchant_country or vfm.settlement_flag = 0
                                then 'O' -- Oversea
                                when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST  --'OPTP0402'
                                then 'D' -- Domestic
                                when oo.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER  --'OPTP1501'
                                then  (
                                        select case
                                                   when merchant_country = card_country and vfm.settlement_flag <> 0
                                                   then 'D'
                                                   when merchant_country <> card_country or vfm.settlement_flag = 0
                                                   then 'O'
                                                   else 'D'
                                               end
                                          from (
                                                select o.merchant_country
                                                     , p.card_country
                                                     , o.id as oper_id
                                                     , v.settlement_flag
                                                  from opr_operation o
                                                     , opr_participant p
                                                     , vis_fin_message v
                                                 where o.id = p.oper_id
                                                   and o.id = v.id
                                                   and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER -- 'PRTYISS'
                                               )
                                         where oper_id = oo.original_id
                                      )
                                else 'D' -- Domestic
                           end
                        || decode(cust.entity_type,
                                  com_api_const_pkg.ENTITY_TYPE_COMPANY, 'C',  -- Corporate  'ENTTCOMP'
                                  com_api_const_pkg.ENTITY_TYPE_PERSON,  'I')  -- Individual 'ENTTPERS'
                           as amount_category
                         , oo.id as original_oper_id
                         , cp.oper_id as payment_oper_id
                         , cdp.eff_date as payment_posting_date
                         , aa.account_number
                         , cdp.pay_amount
                         , cust.customer_number
                      from crd_debt cd
                         , crd_debt_payment cdp
                         , crd_payment cp
                         , opr_operation oo
                         , opr_participant op
                         , acc_account aa
                         , prd_customer cust
                         , opr_operation po -- payment operation
                         , vis_fin_message vfm
                     where cd.id = cdp.debt_id
                       and cp.id = cdp.pay_id
                       and oo.id = cd.oper_id
                       and oo.id = op.oper_id
                       and oo.id = vfm.id(+)
                       and aa.id = cd.account_id
                       and po.id = cp.oper_id
                       and cust.id = op.customer_id
                       and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER -- 'PRTYISS'
                       and oo.oper_type in (
                                             opr_api_const_pkg.OPERATION_TYPE_PURCHASE   -- 'OPTP0000'
                                           , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH   -- 'OPTP0001'
                                           , opr_api_const_pkg.OPERATION_TYPE_POS_CASH   -- 'OPTP0012'
                                           , opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE -- 'OPTP0119'
                                           , dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER  --'OPTP1501'
                                           , opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST --'OPTP0402'
                                           )
                       and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
                       and cdp.pay_amount > 0
                       and cdp.balance_type in (
                                                 cst_woo_const_pkg.BALANCE_TYPE_OVERDRAFT        -- 'BLTP1002'
                                               , cst_woo_const_pkg.BALANCE_TYPE_INTEREST         -- 'BLTP1003'
                                               , cst_woo_const_pkg.BALANCE_TYPE_OVERDUE          -- 'BLTP1004'
                                               , cst_woo_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                               )
                       and po.oper_type in ( -- only payments
                                             cst_woo_const_pkg.OPERATION_PAYMENT_DD              -- 'OPTP7030'
                                           , cst_woo_const_pkg.OPERATION_PAYMENT_ORDER           -- 'OPTP7001'
                                           , cst_woo_const_pkg.OPERATION_PAYMENT_NOTIFICATION    -- 'OPTP0027'
                                           , cst_woo_const_pkg.OPERATION_PAYMENT                 -- 'OPTP0028'
                                           )
                       and not exists (
                           select 1
                             from opr_operation oor
                            where oor.original_id = po.id
                              and oor.is_reversal = com_api_const_pkg.TRUE
                              and oor.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                       )
                       and not exists (
                           select 1
                             from opr_operation oor
                            where oor.original_id = oo.id
                              and oor.is_reversal = com_api_const_pkg.TRUE
                              and oor.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                       )
                       and oo.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                       and aa.inst_id = i_inst_id
                       and cdp.eff_date between i_from_date and i_to_date
                   ) t
           )
     group by customer_number
            , account_number
            , payment_posting_date;

    -- Constants and variables:
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_88;
    BULK_LIMIT         constant pls_integer                    := 1000;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, cst_woo_const_pkg.WOORI_DATE_FORMAT);
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              com_api_type_pkg.t_count       := 0;

    l_mes_tab_88                cst_woo_api_type_pkg.t_mes_tab_88;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_header                    com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => 'Export batch file 88 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

l_from_date := trunc(nvl(i_start_date, get_sysdate));
    l_to_date := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    -- Prepare header data
    l_seq_file_id :=
        prc_api_file_pkg.get_next_file(
            i_file_type => opr_api_const_pkg.FILE_TYPE_UNLOADING
          , i_inst_id   => l_inst_id
          , i_file_attr => cst_woo_com_pkg.get_file_attribute_id(
                               i_file_id  => cst_woo_const_pkg.FILE_ID_88
                           )
        );

    l_header := HEADER
             || '|' || JOB_ID
             || '|' || l_process_date
             || '|' || lpad(l_seq_file_id, 3, 0);

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    -- Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_header
    );

    -- Prepare data details to export:
    open cur_f88_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f88_data bulk collect into l_mes_tab_88 limit BULK_LIMIT;

        for i in 1..l_mes_tab_88.count loop
            l_record_count := l_record_count + 1;
            l_record(1) :=
                lpad(l_record_count, 9, 0) -- Data sequence
             || '|' || l_process_date
             || '|' || l_mes_tab_88(i).cif_no
             || '|' || l_mes_tab_88(i).account_number
             || '|' || l_mes_tab_88(i).amount_1
             || '|' || l_mes_tab_88(i).amount_2
             || '|' || l_mes_tab_88(i).amount_3
             || '|' || l_mes_tab_88(i).amount_4
             || '|' || l_mes_tab_88(i).amount_5
             || '|' || l_mes_tab_88(i).amount_6
             || '|' || l_mes_tab_88(i).amount_7
             || '|' || l_mes_tab_88(i).amount_8
             || '|' || l_mes_tab_88(i).amount_9
             || '|' || l_mes_tab_88(i).amount_10
             || '|' || l_mes_tab_88(i).amount_11
             || '|' || l_mes_tab_88(i).amount_12
             || '|' || l_mes_tab_88(i).amount_13
             || '|' || l_mes_tab_88(i).amount_14
             || '|' || l_mes_tab_88(i).amount_15
             || '|' || l_mes_tab_88(i).amount_16
             || '|' || l_mes_tab_88(i).amount_17
             || '|' || l_mes_tab_88(i).amount_18
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(1)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_88(i).amount_1
                                             + l_mes_tab_88(i).amount_2
                                             + l_mes_tab_88(i).amount_3
                                             + l_mes_tab_88(i).amount_4
                                             + l_mes_tab_88(i).amount_5
                                             + l_mes_tab_88(i).amount_6
                                             + l_mes_tab_88(i).amount_7
                                             + l_mes_tab_88(i).amount_8
                                             + l_mes_tab_88(i).amount_9
                                             + l_mes_tab_88(i).amount_10
                                             + l_mes_tab_88(i).amount_11
                                             + l_mes_tab_88(i).amount_12
                                             + l_mes_tab_88(i).amount_13
                                             + l_mes_tab_88(i).amount_14
                                             + l_mes_tab_88(i).amount_15
                                             + l_mes_tab_88(i).amount_16
                                             + l_mes_tab_88(i).amount_17
                                             + l_mes_tab_88(i).amount_18;

            l_record.delete;

        end loop;

        exit when cur_f88_data%notfound;

    end loop;

    close cur_f88_data;

    --Update file header with total amount and record count
    l_header := l_header
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_header
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total ' || l_record_count || ' records are exported successfully -> End!'
    );

exception
when others then
    if cur_f88_data%isopen then
        close cur_f88_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_88;
--------------------------------------------------------------------------------
procedure batch_file_89(
    i_inst_id               in      com_api_type_pkg.t_inst_id
) is

    cursor cur_f89_data(
        i_inst_id    com_api_type_pkg.t_inst_id
    ) is
        select de.customer_number
             , de.account_number
             , (select ci.overdue_date
                  from crd_invoice ci
                 where ci.id = de.overdue_invoice_id) as overdue_date
             , de.overdue_fee_amount
             , de.overdue_dom_ind_pos
             , de.overdue_interest_pos
             , de.overdue_overs_ind_pos
             , de.overdue_dom_corp_pos
             , de.overdue_overs_corp_pos
             , de.overdue_dom_ind_cash
             , de.overdue_interest_cash
             , de.overdue_overs_ind_cash
          from (
                select d.customer_number
                     , d.account_number
                     , min(d.invoice_id)                    as overdue_invoice_id
                     , sum(d.overdue_fee_amount)            as overdue_fee_amount
                     , sum(d.overdue_dom_ind_pos)           as overdue_dom_ind_pos
                     , sum(d.overdue_interest_pos)          as overdue_interest_pos
                     , sum(d.overdue_overs_ind_pos)         as overdue_overs_ind_pos
                     , sum(d.overdue_dom_corp_pos)          as overdue_dom_corp_pos
                     , sum(d.overdue_overs_corp_pos)        as overdue_overs_corp_pos
                     , sum(d.overdue_dom_ind_cash)          as overdue_dom_ind_cash
                     , sum(d.overdue_interest_cash)         as overdue_interest_cash
                     , sum(d.overdue_overs_ind_cash)        as overdue_overs_ind_cash
                  from (
                        select t.customer_number
                             , t.account_number
                             , t.account_id
                             , t.invoice_id
                             , case when t.amount_category like '_F%'
                                    then t.amount
                                    else 0
                               end as overdue_fee_amount         -- field 6
                             , case when t.amount_category =    '4PDI'
                                    then t.amount
                                    else 0
                               end as overdue_dom_ind_pos        -- field 7
                             , case when t.amount_category like '5P%'
                                    then t.amount
                                    else 0
                               end as overdue_interest_pos       -- field 8
                             , case when t.amount_category =    '4POI'
                                    then t.amount
                                    else 0
                               end as overdue_overs_ind_pos      -- field 9
                             , case when t.amount_category =    '4PDC'
                                    then t.amount
                                    else 0
                               end as overdue_dom_corp_pos       -- field 10
                             , case when t.amount_category =    '4POC'
                                    then t.amount
                                    else 0
                               end as overdue_overs_corp_pos     -- field 11
                             , case when t.amount_category =    '4CDI'
                                    then t.amount
                                    else 0
                               end as overdue_dom_ind_cash       -- field 12
                             , case when t.amount_category like '5C%'
                                    then t.amount
                                    else 0
                               end as overdue_interest_cash      -- field 13
                             , case when t.amount_category =    '4COI'
                                    then t.amount
                                    else 0
                               end as overdue_overs_ind_cash     -- field 22
                          from (
                                select decode(cdb.balance_type,
                                              cst_woo_const_pkg.BALANCE_TYPE_OVERDUE,          '4', -- Overdue
                                              cst_woo_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST, '5') -- Overdue interest
                                    || decode(oo.oper_type,
                                              opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE, -- Issuer fee
                                                  'F',
                                              opr_api_const_pkg.OPERATION_TYPE_PURCHASE,   -- POS purchase
                                                  case when cd.macros_type_id in (
                                                                                   cst_woo_const_pkg.MACROS_TYPE_ID_DEBIT_FEE -- 1007
                                                                                 , cst_woo_const_pkg.MACROS_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                                                                 , cst_woo_const_pkg.MACROS_TYPE_ID_VAT -- 7011
                                                                                 , cst_woo_const_pkg.MACROS_TYPE_ID_ORIG_FEE -- 7126
                                                                                 )
                                                       then 'F'
                                                       else 'P'
                                                  end,
                                              dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER,  --'OPTP1501'
                                                  'P',
                                              opr_api_const_pkg.OPERATION_TYPE_ATM_CASH,   -- Cash withdrawal
                                                  case when cd.macros_type_id in (
                                                                                   cst_woo_const_pkg.MACROS_TYPE_ID_DEBIT_FEE -- 1007
                                                                                 , cst_woo_const_pkg.MACROS_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                                                                 , cst_woo_const_pkg.MACROS_TYPE_ID_VAT -- 7011
                                                                                 , cst_woo_const_pkg.MACROS_TYPE_ID_ORIG_FEE -- 7126
                                                                                 )
                                                       then 'F'
                                                       else 'C'
                                                  end,
                                              opr_api_const_pkg.OPERATION_TYPE_POS_CASH,   -- POS Cash advance
                                                  case when cd.macros_type_id in (
                                                                                   cst_woo_const_pkg.MACROS_TYPE_ID_DEBIT_FEE -- 1007
                                                                                 , cst_woo_const_pkg.MACROS_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                                                                 , cst_woo_const_pkg.MACROS_TYPE_ID_VAT -- 7011
                                                                                 , cst_woo_const_pkg.MACROS_TYPE_ID_ORIG_FEE -- 7126
                                                                                 )
                                                       then 'F'
                                                       else 'C'
                                                  end,'C')
                                    || case when op.card_country = oo.merchant_country and vfm.settlement_flag <> 0
                                            then 'D' -- Domestic
                                            when op.card_country <> oo.merchant_country or vfm.settlement_flag = 0
                                            then 'O' -- Oversea
                                            when oo.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER  --'OPTP1501'
                                            then  (
                                                    select case
                                                               when merchant_country = card_country and vfm.settlement_flag <> 0
                                                               then 'D'
                                                               when merchant_country <> card_country or vfm.settlement_flag = 0
                                                               then 'O'
                                                               else 'D'
                                                           end
                                                      from (
                                                            select o.merchant_country
                                                                 , p.card_country
                                                                 , o.id as oper_id
                                                                 , v.settlement_flag
                                                              from opr_operation o
                                                                 , opr_participant p
                                                                 , vis_fin_message v
                                                             where o.id = p.oper_id
                                                               and o.id = v.id
                                                               and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER -- 'PRTYISS'
                                                           )
                                                     where oper_id = oo.original_id
                                                  )
                                            else 'D' -- Domestic
                                       end
                                    || decode(cust.entity_type,
                                              com_api_const_pkg.ENTITY_TYPE_COMPANY, 'C',  -- Corporate  'ENTTCOMP'
                                              com_api_const_pkg.ENTITY_TYPE_PERSON,  'I')  -- Individual 'ENTTPERS'
                                       as amount_category
                                     , oo.id as oper_id
                                     , cd.account_id
                                     , cdb.amount
                                     , cust.id as customer_id
                                     , cust.customer_number
                                     , aa.account_number
                                     , (select min(invoice_id)
                                          from crd_invoice_debt cid
                                         where cid.debt_id = cd.id) as invoice_id
                                  from crd_debt cd
                                     , crd_debt_balance cdb
                                     , opr_operation oo
                                     , opr_participant op
                                     , acc_account aa
                                     , prd_customer cust
                                     , vis_fin_message  vfm
                                 where cd.id = cdb.debt_id
                                   and oo.id = cd.oper_id
                                   and oo.id = op.oper_id
                                   and oo.id = vfm.id(+)
                                   and aa.id = cd.account_id
                                   and cust.id = op.customer_id
                                   and cdb.amount > 0
                                   and aa.inst_id = i_inst_id
                                   and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER -- 'PRTYISS'
                                   and oo.oper_type in (
                                                         opr_api_const_pkg.OPERATION_TYPE_PURCHASE   -- 'OPTP0000'
                                                       , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH   -- 'OPTP0001'
                                                       , opr_api_const_pkg.OPERATION_TYPE_POS_CASH   -- 'OPTP0012'
                                                       , opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE -- 'OPTP0119'
                                                       , dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER  --'OPTP1501'
                                                       )
                                   and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
                                   and cdb.balance_type in (
                                                             cst_woo_const_pkg.BALANCE_TYPE_OVERDUE          -- 'BLTP1004'
                                                           , cst_woo_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST -- 'BLTP1005'
                                                           )
                                   and not exists (
                                       select 1
                                         from opr_operation oor
                                        where oor.original_id = oo.id
                                          and oor.is_reversal = com_api_const_pkg.TRUE
                                          and oor.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                   )
                               ) t
                       ) d
                 group by d.customer_number
                        , d.account_number
                        , d.account_id
               ) de;


--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_89;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, cst_woo_const_pkg.WOORI_DATE_FORMAT);
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_89                cst_woo_api_type_pkg.t_mes_tab_89;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text    => 'Export batch file 89  -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_89
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f89_data(
        i_inst_id    => l_inst_id
    );

    loop
        fetch cur_f89_data bulk collect into l_mes_tab_89 limit BULK_LIMIT;

        for i in 1..l_mes_tab_89.count loop
            l_record_count := l_record_count + 1;

            l_record(1) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(get_sysdate, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_89(i).cif_no), '')
            || '|' || nvl(to_char(l_mes_tab_89(i).account_number), '')
            || '|' || nvl(to_char(l_mes_tab_89(i).delin_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_89(i).ovdue_fee), '0')
            || '|' || nvl(to_char(l_mes_tab_89(i).ovdue_domes_invi_pos), '0')
            || '|' || nvl(to_char(l_mes_tab_89(i).ovdue_domes_invi_pos_inr), '0')
            || '|' || nvl(to_char(l_mes_tab_89(i).ovdue_ovsea_invi_pos), '0')
            || '|' || nvl(to_char(l_mes_tab_89(i).ovdue_domes_corp_pos), '0')
            || '|' || nvl(to_char(l_mes_tab_89(i).ovdue_ovsea_corp_pos), '0')
            || '|' || nvl(to_char(l_mes_tab_89(i).ovdue_domes_invi_cash), '0')
            || '|' || nvl(to_char(l_mes_tab_89(i).ovdue_domes_invi_cash_inr), '0')
            || '|' || nvl(to_char(l_mes_tab_89(i).ovdue_ovsea_invi_cash), '0')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(1)
              , i_sess_file_id  => l_session_file_id
            );

            l_record.delete;

        end loop;

        exit when cur_f89_data%notfound;

    end loop;

    close cur_f89_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );


    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f89_data%isopen then
        close cur_f89_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_89;
--------------------------------------------------------------------------------
procedure batch_file_92(
    i_inst_id               in com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f92_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
      select cus.customer_number                       as cif
           , decode(cus.entity_type, com_api_const_pkg.ENTITY_TYPE_PERSON,  '1', --ENTTPERS
                                     com_api_const_pkg.ENTITY_TYPE_COMPANY, '2') --ENTTCOMP
                                                       as division_code
           , icn.card_number
           , case
                when ctf.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_CREDIT
                    then '1'
                when ctf.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT
                    then '2'
                when ctf.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_PREPAID and con.contract_type = 'CNTPNOAN' --Non-anonymous
                    then '3'
                when ctf.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_PREPAID and con.contract_type = 'CNTPPRPD' --Anonymous
                    then '4'
                else ''
             end                                       as card_type
           , case
                when opo.oper_type   = 'OPTP1003' and opo.is_reversal = com_api_const_pkg.TRUE
                    then '3' -- refund and reversal
                when opo.is_reversal = com_api_const_pkg.TRUE
                    then '2' -- authorization reversal
                else     '1' -- authorization
             end                                       as status_code
           , opo.host_date                             as trans_date
           , opo.host_date                             as trans_time
           , opp.auth_code                             as audit_num
           , (select oper_date
                from opr_operation
               where id = opo.original_id)             as reversal_date
           , (select oper_date
                from opr_operation
               where id = opo.original_id)             as reversal_time
           , (select auth_code
                from opr_participant
               where participant_type = com_api_const_pkg.PARTICIPANT_ISSUER  --'PRTYISS'
                 and oper_id = opo.original_id)        as reversal_audit_num
           , case
                when opo.oper_type = cst_woo_const_pkg.OPERATION_TYPE_CREDIT_REFUND  -- 'OPTP1003'
                     and opo.is_reversal = com_api_const_pkg.TRUE then '22' --Refund Reversal
                when opo.oper_type = cst_woo_const_pkg.OPERATION_TYPE_CREDIT_REFUND  -- 'OPTP1003'
                     and opo.is_reversal = com_api_const_pkg.FALSE then '21' --Refund
                when opo.merchant_country <> opp.card_country
                     and opo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH -- 'OPTP0001'
                     and opo.is_reversal = com_api_const_pkg.TRUE then '20' --Oversea Cash Advance Reversal
                when opo.merchant_country <> opp.card_country
                     and opo.oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE -- 'OPTP0000'
                     and opo.is_reversal = com_api_const_pkg.TRUE then '19' --Oversea Purchase Reverval
                when opo.merchant_country <> opp.card_country
                     and opo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH -- 'OPTP0001'
                     and opo.is_reversal = com_api_const_pkg.FALSE then '18' --Oversea Cash Advance
                when opo.merchant_country <> opp.card_country
                     and opo.oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE -- 'OPTP0000'
                     and opo.is_reversal = com_api_const_pkg.FALSE then '17' --Oversea Purchase
                when opo.merchant_country = opp.card_country
                     and opo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH -- 'OPTP0001'
                     and opo.is_reversal = com_api_const_pkg.TRUE then '16' --Domestic Cash Advance Reversal
                when opo.merchant_country = opp.card_country
                     and opo.oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE -- 'OPTP0000'
                     and opo.is_reversal = com_api_const_pkg.TRUE then '15' --Domestic Purchase Reverval
                when opo.merchant_country = opp.card_country
                     and opo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH -- 'OPTP0001'
                     and opo.is_reversal = com_api_const_pkg.FALSE then '06' --Domestic Cash Advance
                when opo.merchant_country = opp.card_country
                     and opo.oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE -- 'OPTP0000'
                     and opo.is_reversal = com_api_const_pkg.FALSE then '05' --Domestic Purchase
             end                                       as card_sale_code
           , case
                when opo.merchant_country = opp.card_country then '1' -- Domestic
                                                             else '2' -- Overseas
             end                                       as classified_code
           , decode ( opo.sttl_type
                      , opr_api_const_pkg.SETTLEMENT_USONUS
                      , opo.oper_amount
                      , opr_api_const_pkg.SETTLEMENT_USONTHEM
                      , (select ori.amount - fee.amount
                           from (select amount, oper_id 
                                   from opr_additional_amount 
                                  where amount_type = com_api_const_pkg.AMOUNT_PURPOSE_MACROS --'AMPR0010' 
                                 ) ori,
                                (select amount, oper_id 
                                   from opr_additional_amount 
                                  where amount_type = cst_woo_const_pkg.AMOUNT_FEE_ORIGINAL -- 'AMPR0020' 
                                 ) fee
                          where ori.oper_id = fee.oper_id
                            and ori.oper_id = opo.id
                         )            
                    ) as trans_amount
           , opo.merchant_name                         as mrc_name
           , opo.merchant_number                       as mrc_num
           , opo.mcc                                   as mrc_business_num
           , opo.merchant_name                         as mrc_business_name
           , opo.merchant_country                      as mrc_country_code
      from opr_operation            opo
           , opr_participant        opp
           , iss_card               ica
           , iss_card_instance      ici
           , iss_card_number        icn
           , prd_customer           cus
           , prd_contract           con
           , net_card_type_feature  ctf
           , acc_account            aac
     where opo.id                   = opp.oper_id
       and ica.id                   = ici.card_id
       and con.id                   = ica.contract_id
       and ici.id                   = opp.card_instance_id
       and ici.card_id              = icn.card_id
       and cus.id                   = opp.customer_id
       and ctf.card_type_id         = opp.card_type_id
       and aac.id                   = opp.account_id
       and opp.participant_type     = com_api_const_pkg.PARTICIPANT_ISSUER          -- 'PRTYISS'
       and opo.msg_type             = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION  -- 'MSGTAUTH'
         and (opo.oper_type in ( opr_api_const_pkg.OPERATION_TYPE_PURCHASE          -- 'OPTP0000'         
                            , cst_woo_const_pkg.OPERATION_TYPE_CREDIT_REFUND    -- 'OPTP1003'
                            )
              or
              (opo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH            -- 'OPTP0001'
               and aac.account_type != cst_woo_const_pkg.ACCT_TYPE_SAVING_VND)      -- 'ACTP0131' 
             )
       and opo.status in ( opr_api_const_pkg.OPERATION_STATUS_PROCESSED         -- 'OPST0400'
                         , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED          -- 'OPST0402'
                         , opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD     -- 'OPST0800'
                         )
       and ctf.card_feature in ( net_api_const_pkg.CARD_FEATURE_STATUS_CREDIT   -- 'CFCHCRDT'
                               , net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT    -- 'CFCHDEBT'
                               , net_api_const_pkg.CARD_FEATURE_STATUS_PREPAID  -- 'CFCHPRPD'
                               )
       and opo.host_date between i_from_date and i_to_date
       ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_92;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_92                cst_woo_api_type_pkg.t_mes_tab_92;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text          => 'Export batch file 92 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    --Get data from 9PM of from previous day:
    l_from_date := to_date(to_char(nvl(i_end_date, get_sysdate) - 1, 'dd/mm/yyyy')|| ' 21:00:00', 'dd/mm/yyyy HH24:MI:SS');
    l_to_date   := to_date(to_char(nvl(i_end_date, get_sysdate), 'dd/mm/yyyy')|| ' 20:59:59', 'dd/mm/yyyy HH24:MI:SS');

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_92
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f92_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f92_data bulk collect into l_mes_tab_92 limit BULK_LIMIT;

        for i in 1..l_mes_tab_92.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || to_char(get_sysdate,'YYYYMMDD')
            || '|' || nvl(to_char(l_mes_tab_92(i).cif_num), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).division_code), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).card_num), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).card_type), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).status_code), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).trans_date,'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).trans_time,'HH24MISS'), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).audit_num), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).reversal_date ,'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).reversal_time ,'HH24MISS'), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).reversal_audit_num), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).card_sale_code), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).classified_code), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).trans_amount), '0')
            || '|' || nvl(to_char(l_mes_tab_92(i).mrc_name), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).mrc_num), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).mrc_business_num), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).mrc_business_name), '')
            || '|' || nvl(to_char(l_mes_tab_92(i).mrc_country_code), '')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_record.delete;

        end loop;

        exit when cur_f92_data%notfound;

    end loop;

    close cur_f92_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f92_data%isopen then
        close cur_f92_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_92;
--------------------------------------------------------------------------------
procedure batch_file_110(
    i_inst_id           in com_api_type_pkg.t_inst_id
) is
    BULK_LIMIT          constant pls_integer := 10000;

    cursor cur_f110_data (
        i_inst_id       in com_api_type_pkg.t_inst_id
    ) is
        select file_date
             , cif_num
             , employee_num
             , card_num
             , deling_date
             , approve_date
             , approve_time
             , approve_amount
             , limit_rate
             , used_lmt_amount
             , acct_id
         from (select get_sysdate                               as file_date
                     , cus.customer_number                      as cif_num
                     , com_api_flexible_data_pkg.get_flexible_value(
                            i_field_name    => 'CST_EMPLOYEE_NUMBER'
                          , i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
                          , i_object_id     => cus.id
                       )                                        as employee_num
                     , cn.card_number                           as card_num
                     , (select max(penalty_date)
                          from crd_invoice
                         where account_id   = acct.id
                           and aging_period = 1
                        )                                       as deling_date
                     , lmt_cnt.last_reset_date                  as approve_date
                     , lmt_cnt.last_reset_date                  as approve_time
                     , case when lmt.limit_base is not null and lmt.limit_rate is not null
                        then
                           nvl(fcl_api_limit_pkg.get_limit_border_sum(
                                   i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT -- 'ENTTACCT'
                                 , i_object_id            => acct.id
                                 , i_limit_type           => lmt.limit_type
                                 , i_limit_base           => lmt.limit_base
                                 , i_limit_rate           => lmt.limit_rate
                                 , i_currency             => lmt.currency
                                 , i_inst_id              => acct.inst_id
                                 , i_product_id           => prd_api_product_pkg.get_product_id(
                                                                 i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                                                               , i_object_id         => acct.id
                                                               , i_inst_id           => acct.inst_id
                                                             )
                                 , i_split_hash           => acct.split_hash
                                 , i_mask_error           => com_api_const_pkg.TRUE -- 1
                              ), 0
                           )
                        else 0
                        end
                                                                as approve_amount
                     , lmt.limit_rate as limit_rate
                     , cst_woo_com_pkg.get_limit_sum_withdraw(
                            i_object_id       => acct.id
                          , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                          , i_split_hash      => acct.split_hash
                        ) as used_lmt_amount
                        , acct.id                               as acct_id
                 from  prd_customer            cus
                     , acc_account             acct
                     , fcl_limit_counter       lmt_cnt
                     , fcl_limit               lmt
                     , acc_account_object      acct_obj
                     , iss_card_number         cn
                 where 1                       = 1
                   and acct.customer_id        = cus.id
                   and lmt_cnt.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                   and lmt_cnt.object_id       = acct.id
                   and acct.account_type       = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
                   and acct.id                 = acct_obj.account_id
                   and acct_obj.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD -- 'ENTTCARD'
                   and acct_obj.object_id      = cn.card_id
                   and acct.inst_id            = i_inst_id
                   and lmt.limit_type          = cst_woo_const_pkg.LIMIT_TYPE_ACCT_CREDIT_CASH    -- 'LMTP0408'
                   and lmt.id                  = (select distinct convert_to_number(first_value(pav.attr_value)
                                                    over (order by pav.start_date desc)) as attr_value
                                                    from prd_attribute_value  pav
                                                       , prd_attribute        pat
                                                       , prd_contract         pcn
                                                       , iss_card             ica
                                                       , acc_account_object   aco
                                                   where 1 = 1
                                                     and pav.attr_id      = pat.id
                                                     and pat.attr_name    = 'CRD_ACCOUNT_CASH_LIMIT_VALUE'
                                                     and pav.entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT --'ENTTPROD'
                                                     and pav.object_id    in (select id
                                                                                from prd_product
                                                                               start with id = pcn.product_id
                                                                             connect by id = prior parent_id)
                                                     and ica.contract_id  = pcn.id
                                                     and aco.object_id    = ica.id
                                                     and aco.account_id   = acct.id
                                                     and get_sysdate between pav.start_date and nvl(pav.end_date, get_sysdate)
                                                )
               )
        where employee_num is not null;

    cursor cur_f110_count(
        i_inst_id   in  com_api_type_pkg.t_inst_id
    ) is
    select count(1)
      from prd_customer            cus
         , acc_account             acct
         , fcl_limit_counter       lmt_cnt
         , fcl_limit               lmt
         , acc_account_object      acct_obj
         , iss_card_number         cn
     where 1                       = 1
       and acct.customer_id        = cus.id
       and lmt_cnt.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
       and lmt_cnt.object_id       = acct.id
       and acct.account_type       = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
       and acct.id                 = acct_obj.account_id
       and acct_obj.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD -- 'ENTTCARD'
       and acct_obj.object_id      = cn.card_id
       and acct.inst_id            = i_inst_id
       and lmt.limit_type          = cst_woo_const_pkg.LIMIT_TYPE_ACCT_CREDIT_CASH    -- 'LMTP0408'
       and lmt.id                  = (select distinct convert_to_number(first_value(pav.attr_value)
                                        over (order by pav.start_date desc)) as attr_value
                                        from prd_attribute_value  pav
                                           , prd_attribute        pat
                                           , prd_contract         pcn
                                           , iss_card             ica
                                           , acc_account_object   aco
                                       where 1 = 1
                                         and pav.attr_id      = pat.id
                                         and pat.attr_name    = 'CRD_ACCOUNT_CASH_LIMIT_VALUE'
                                         and pav.entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT --'ENTTPROD'
                                         and pav.object_id    in (select id
                                                                    from prd_product
                                                                   start with id = pcn.product_id
                                                                 connect by id = prior parent_id)
                                         and ica.contract_id  = pcn.id
                                         and aco.object_id    = ica.id
                                         and aco.account_id   = acct.id
                                         and get_sysdate between pav.start_date and nvl(pav.end_date, get_sysdate)
                                    )
       and com_api_flexible_data_pkg.get_flexible_value(
                'CST_EMPLOYEE_NUMBER'
               , com_api_const_pkg.ENTITY_TYPE_CUSTOMER
               , cus.id) is not null
       ;

--Header info
    HEADER          constant    com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID          constant    com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_110;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--Details info
    l_file_date                 com_api_type_pkg.t_date_tab;
    l_cif_num                   com_api_type_pkg.t_cmid_tab;
    l_employee_num              com_api_type_pkg.t_cmid_tab;
    l_card_num                  com_api_type_pkg.t_card_number_tab;
    l_deling_date               com_api_type_pkg.t_date_tab;
    l_approve_date              com_api_type_pkg.t_date_tab;
    l_approve_time              com_api_type_pkg.t_date_tab;
    l_approve_amount            com_api_type_pkg.t_money_tab;
    l_cash_advn_bal             com_api_type_pkg.t_money_tab;
    l_used_lmt_amount           com_api_type_pkg.t_money_tab;
    l_limit_rate                com_api_type_pkg.t_number_tab;
    l_acct_id                   com_api_type_pkg.t_account_number_tab;
--For file processing
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_apprv_amt_tmp             com_api_type_pkg.t_money;
begin

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text    => 'Export batch file 110 -> start'
    );

    open cur_f110_count(i_inst_id);
        fetch cur_f110_count into l_record_count;
    close cur_f110_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count
    );

    if l_record_count > 0 then

    --Prepare header data to export
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type    => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id      => i_inst_id
                       , i_file_attr    => cst_woo_com_pkg.get_file_attribute_id(
                                               i_file_id    => cst_woo_const_pkg.FILE_ID_110
                                           )
                     );

    l_line := null;
    l_line := l_line || HEADER                    || '|';
    l_line := l_line || JOB_ID                    || '|';
    l_line := l_line || l_process_date            || '|';
    l_line := l_line || lpad(l_seq_file_id, 3 ,0) || '|';
    l_line := l_line || l_total_amount            || '|';
    l_line := l_line || l_record_count;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare details data to export
    open cur_f110_data(i_inst_id);
        loop
        fetch cur_f110_data bulk collect into
            l_file_date
          , l_cif_num
          , l_employee_num
          , l_card_num
          , l_deling_date
          , l_approve_date
          , l_approve_time
          , l_approve_amount
          , l_limit_rate
          , l_used_lmt_amount
          , l_acct_id
        limit BULK_LIMIT;

        l_record.delete;

        for i in 1..l_record_count loop

            if l_approve_amount(i) is not null then
                l_apprv_amt_tmp := l_approve_amount(i);
            else
                l_apprv_amt_tmp := (l_limit_rate(i) * acc_api_balance_pkg.get_balance_amount(
                                                        i_account_id     => l_acct_id(i)
                                                      , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED --'BLTP1001'
                                                      ).amount)/100;
            end if;

            l_record(i) :=
            lpad(i, 9, 0)                                               || '|'
            || nvl(to_char(l_file_date(i)
               , cst_woo_const_pkg.WOORI_DATE_YYYYMM), '')              || '|'
            || nvl(to_char(l_cif_num(i)), '')                           || '|'
            || nvl(to_char(l_employee_num(i)), '')                      || '|'
            || nvl(to_char(l_card_num(i)), '')                          || '|'
            || nvl(to_char(l_deling_date(i), 'YYYYMMDD'), '')           || '|'
            || nvl(to_char(l_approve_date(i), 'YYYYMMDD'), '')          || '|'
            || nvl(to_char(l_approve_time(i), 'HH24MISS'), '')          || '|'
            || nvl(to_char(l_apprv_amt_tmp), '0')                       || '|'
            || nvl(to_char(l_apprv_amt_tmp - l_used_lmt_amount(i)), '0')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

        end loop;

        exit when cur_f110_data%notfound;

    end loop;

    close cur_f110_data;

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    end if;

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        if cur_f110_data%isopen then
            close cur_f110_data;
        end if;

        if cur_f110_count%isopen then
            close cur_f110_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;

end batch_file_110;
--------------------------------------------------------------------------------
procedure batch_file_65_1(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f65_1_data(
        i_from_date     date
      , i_to_date       date
    ) is
        select file_date
             , cif_num
             , agent_id
             , wdr_bank_code
             , wdr_acct_num
             , dep_bank_code
             , dep_acct_num
             , dep_curr_code
             , dep_amount
             , brief_content
             , work_type
             , err_code
          from cst_woo_mapping_f64f65
         where 1          = 1
           and map_status = 1
           and file_date between i_from_date and i_to_date;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_65_1;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_65_1              cst_woo_api_type_pkg.t_mes_tab_65_1;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text  => 'Export batch file 65_1 -> start'
    );

    l_inst_id   := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_end_date, get_sysdate));
    l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_65_1
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare details data to export
    open cur_f65_1_data(
        i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f65_1_data bulk collect into l_mes_tab_65_1 limit BULK_LIMIT;

        for i in 1..l_mes_tab_65_1.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_65_1(i).file_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_65_1(i).cif_num), '')
            || '|' || nvl(to_char(l_mes_tab_65_1(i).agent_id), '')
            || '|' || nvl(to_char(l_mes_tab_65_1(i).wdr_bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_65_1(i).wdr_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_65_1(i).dep_bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_65_1(i).dep_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_65_1(i).dep_curr_code), '')
            || '|' || nvl(to_char(l_mes_tab_65_1(i).dep_amount), '')
            || '|' || nvl(to_char(l_mes_tab_65_1(i).brief_content), '')
            || '|' || nvl(to_char(l_mes_tab_65_1(i).work_type), '')
            || '|' || nvl(to_char(l_mes_tab_65_1(i).err_code), '')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_65_1(i).dep_amount;

            l_record.delete;

        end loop;

        exit when cur_f65_1_data%notfound;

    end loop;

    close cur_f65_1_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text  => 'Total '|| l_record_count ||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f65_1_data%isopen then
        close cur_f65_1_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_65_1;
--------------------------------------------------------------------------------
procedure batch_file_73_1(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    BULK_LIMIT          constant pls_integer := 10000;

    cursor cur_f73_1_data(
        i_from_date date
      , i_to_date   date
    ) is
        select file_date
             , cif_num
             , agent_id
             , wdr_bank_code
             , wdr_acct_num
             , dep_bank_code
             , dep_acct_num
             , dep_curr_code
             , dep_amount
             , brief_content
             , work_type
             , err_code
          from cst_woo_mapping_f72f73
         where 1          = 1
           and map_status = 1
           and file_date between i_from_date and i_to_date;

    cursor cur_f73_1_count(
        i_from_date date
      , i_to_date   date
    ) is
        select count(1)
          from cst_woo_mapping_f72f73
         where 1          = 1
           and map_status = 1
           and file_date between i_from_date and i_to_date;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_73_1;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--Details info
    l_file_date                 com_api_type_pkg.t_date_tab;
    l_cif_num                   com_api_type_pkg.t_cmid_tab;
    l_agent_id                  com_api_type_pkg.t_dict_tab;
    l_wdr_bank_code             com_api_type_pkg.t_dict_tab;
    l_wdr_acct_num              com_api_type_pkg.t_account_number_tab;
    l_dep_bank_code             com_api_type_pkg.t_dict_tab;
    l_dep_acct_num              com_api_type_pkg.t_account_number_tab;
    l_dep_curr_code             com_api_type_pkg.t_curr_code_tab;
    l_dep_amount                com_api_type_pkg.t_money_tab;
    l_brief_content             com_api_type_pkg.t_desc_tab;
    l_work_type                 com_api_type_pkg.t_dict_tab;
    l_err_code                  com_api_type_pkg.t_dict_tab;
--For file processing
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => 'Export batch file 73_1 -> start'
    );

    l_inst_id   := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_end_date, get_sysdate));
    l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    open cur_f73_1_count(
        i_from_date => l_from_date
      , i_to_date   => l_to_date
    );

    fetch cur_f73_1_count into l_record_count;

    close cur_f73_1_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_record_count
    );

    if l_record_count > 0 then

    --Prepare header data to export
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type    => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id      => l_inst_id
                       , i_file_attr    => cst_woo_com_pkg.get_file_attribute_id(
                                               i_file_id    => cst_woo_const_pkg.FILE_ID_73_1
                                           )
                     );

    l_line := null;
    l_line := l_line || HEADER                    || '|';
    l_line := l_line || JOB_ID                    || '|';
    l_line := l_line || l_process_date            || '|';
    l_line := l_line || lpad(l_seq_file_id, 3 ,0) || '|';
    l_line := l_line || l_total_amount            || '|';
    l_line := l_line || l_record_count;

    prc_api_file_pkg.open_file(
        o_sess_file_id => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
      i_sess_file_id  => l_session_file_id
    , i_raw_data      => l_line
    );

    --Prepare details data to export
    open cur_f73_1_data(
        i_from_date => l_from_date
      , i_to_date   => l_to_date
    );

    loop
        fetch cur_f73_1_data bulk collect into
            l_file_date
          , l_cif_num
          , l_agent_id
          , l_wdr_bank_code
          , l_wdr_acct_num
          , l_dep_bank_code
          , l_dep_acct_num
          , l_dep_curr_code
          , l_dep_amount
          , l_brief_content
          , l_work_type
          , l_err_code
        limit BULK_LIMIT;

        l_record.delete;

        for i in 1..l_record_count loop
            l_record(i) :=
            lpad(i, 9, 0)                                                || '|'
            || nvl(to_char(l_file_date(i)
                            , cst_woo_const_pkg.WOORI_DATE_FORMAT), '')  || '|'
            || nvl(to_char(l_cif_num(i)), '')                            || '|'
            || nvl(to_char(l_agent_id(i)), '')                           || '|'
            || nvl(to_char(l_wdr_bank_code(i)), '')                      || '|'
            || nvl(to_char(l_wdr_acct_num(i)), '')                       || '|'
            || nvl(to_char(l_dep_bank_code(i)), '')                      || '|'
            || nvl(to_char(l_dep_acct_num(i)), '')                       || '|'
            || nvl(to_char(l_dep_curr_code(i)), '')                      || '|'
            || nvl(to_char(l_dep_amount(i)), '')                         || '|'
            || nvl(to_char(l_brief_content(i)), '')                      || '|'
            || nvl(to_char(l_work_type(i)), '')                          || '|'
            || nvl(to_char(l_err_code(i)), '');

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

        end loop;

        exit when cur_f73_1_data%notfound;

    end loop;

    close cur_f73_1_data;

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    end if;

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f73_1_data%isopen then
        close cur_f73_1_data;
    end if;

    if cur_f73_1_count%isopen then
        close cur_f73_1_count;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
    end if;

end batch_file_73_1;
--------------------------------------------------------------------------------
procedure batch_file_78_1(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    BULK_LIMIT          constant pls_integer := 10000;

    cursor cur_f78_1_data(
        i_from_date date
      , i_to_date   date
    ) is
         select approved_date
              , tele_mess_num
              , trans_num
              , card_num
              , card_revenue_type
              , approved_amt
              , cash_id_code
              , card_approved_code
              , approved_time
              , terminal_id
              , terminal_agent_id
              , response_code
              , sv_amount
              , rcn_status
           from cst_woo_import_f78
          where 1 = 1
            and rcn_status in (1, 2, 3)
            and to_date(approved_date, 'yyyymmdd') between i_from_date and i_to_date;

    cursor cur_f78_1_count(
        i_from_date date
      , i_to_date   date
    ) is
         select count(1)
           from cst_woo_import_f78
          where 1 = 1
            and rcn_status in (1, 2, 3)
            and to_date(approved_date, 'yyyymmdd') between i_from_date and i_to_date;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_78_1;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--Details info
    l_approved_date             com_api_type_pkg.t_dict_tab;
    l_tele_mess_num             com_api_type_pkg.t_dict_tab;
    l_trans_num                 com_api_type_pkg.t_rrn_tab;
    l_card_num                  com_api_type_pkg.t_card_number_tab;
    l_card_revenue_type         com_api_type_pkg.t_dict_tab;
    l_approved_amt              com_api_type_pkg.t_money_tab;
    l_cash_id_code              com_api_type_pkg.t_dict_tab;
    l_card_approved_code        com_api_type_pkg.t_dict_tab;
    l_approved_time             com_api_type_pkg.t_dict_tab;
    l_terminal_id               com_api_type_pkg.t_terminal_number_tab;
    l_terminal_agent_id         com_api_type_pkg.t_dict_tab;
    l_response_code             com_api_type_pkg.t_dict_tab;
    l_sv_amount                 com_api_type_pkg.t_money_tab;
    l_rcn_status                com_api_type_pkg.t_dict_tab;
--For file processing
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                date;
    l_to_date                  date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => 'Export batch file 78_1 -> start'
    );

    l_inst_id   := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_to_date  := nvl(i_end_date, get_sysdate);
    l_to_date  := to_date(to_char(l_to_date, 'dd/mm/yyyy')|| ' 17:59:59', 'dd/mm/yyyy HH24:MI:SS');
    l_from_date := to_date(to_char(l_to_date - 1, 'dd/mm/yyyy')|| ' 18:00:00', 'dd/mm/yyyy HH24:MI:SS');

    open cur_f78_1_count(
        i_from_date => l_from_date
      , i_to_date   => l_to_date
    );

    fetch cur_f78_1_count into l_record_count;

    close cur_f78_1_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_record_count
    );

    if l_record_count > 0 then

    --Prepare header data to export
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type    => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id      => l_inst_id
                       , i_file_attr    => cst_woo_com_pkg.get_file_attribute_id(
                                               i_file_id    => cst_woo_const_pkg.FILE_ID_78_1
                                           )
                     );

    l_line := null;
    l_line := l_line || HEADER                    || '|';
    l_line := l_line || JOB_ID                    || '|';
    l_line := l_line || l_process_date            || '|';
    l_line := l_line || lpad(l_seq_file_id, 3 ,0) || '|';
    l_line := l_line || l_total_amount            || '|';
    l_line := l_line || l_record_count;

    prc_api_file_pkg.open_file(
        o_sess_file_id => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
      i_sess_file_id  => l_session_file_id
    , i_raw_data      => l_line
    );

    --Prepare details data to export
    open cur_f78_1_data(
        i_from_date => l_from_date
      , i_to_date   => l_to_date
    );

    loop
        fetch cur_f78_1_data bulk collect into
          l_approved_date
        , l_tele_mess_num
        , l_trans_num
        , l_card_num
        , l_card_revenue_type
        , l_approved_amt
        , l_cash_id_code
        , l_card_approved_code
        , l_approved_time
        , l_terminal_id
        , l_terminal_agent_id
        , l_response_code
        , l_sv_amount
        , l_rcn_status
        limit BULK_LIMIT;

        l_record.delete;

        for i in 1..l_record_count loop
            l_record(i) :=
            lpad(i, 9, 0)                                           || '|'
            || nvl(to_char(l_approved_date(i)), '')                 || '|'
            || nvl(to_char(l_tele_mess_num(i)), '')                 || '|'
            || nvl(to_char(l_trans_num(i)), '')                     || '|'
            || nvl(to_char(l_card_num(i)), '')                      || '|'
            || nvl(to_char(l_card_revenue_type(i)), '')             || '|'
            || nvl(to_char(l_approved_amt(i)), '')                  || '|'
            || nvl(to_char(l_cash_id_code(i)), '')                  || '|'
            || nvl(to_char(l_card_approved_code(i)), '')            || '|'
            || nvl(to_char(l_approved_time(i)), '')                 || '|'
            || nvl(to_char(l_terminal_id(i)), '')                   || '|'
            || nvl(to_char(l_terminal_agent_id(i)), '')             || '|'
            || nvl(to_char(l_response_code(i)), '')                 || '|'
            || nvl(to_char(l_sv_amount(i)), '')                     || '|'
            || nvl(to_char(l_rcn_status(i)), '');

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

        end loop;

        exit when cur_f78_1_data%notfound;

    end loop;

    close cur_f78_1_data;

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    end if;

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f78_1_data%isopen then
        close cur_f78_1_data;
    end if;

    if cur_f78_1_count%isopen then
        close cur_f78_1_count;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
    end if;

end batch_file_78_1;
--------------------------------------------------------------------------------
procedure batch_file_134(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f134_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
      select get_sysdate                                                        as file_date
           , prd_api_customer_pkg.get_customer_number(o.customer_id)            as customer_number
           , (select agt.agent_number
                from acc_account acc, ost_agent agt
               where acc.agent_id = agt.id
                 and acc.id = o.object_id
                 )                                                              as branch_code
           , null                                                               as wdr_bank_code
           , null                                                               as wdr_acct_num
           , 'W5970'                                                            as dep_bank_code
           , d.param_value                                                      as dep_acct_num
           , com_api_currency_pkg.get_currency_name(o.currency)                 as dep_curr_code
           , o.amount                                                           as dep_amount
           , o.id                                                               as brief_content
           , cst_woo_com_pkg.get_card_expire_period(
                (select account_number from acc_account where id = o.object_id)
             )                                                                  as work_type
           , null                                                               as err_code
           , (select account_number from acc_account where id = o.object_id)    as sv_crd_acct
        from pmo_order      o
           , pmo_order_data d
           , pmo_parameter  p
        where o.id          = d.order_id
         and p.id           = d.param_id
         and p.id           = 10000004    -- Recipient account param
         and o.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT     --'ENTTACCT'
         and o.inst_id      = i_inst_id
         and o.status       = pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC --'POSA0001' Ready to process
         and o.event_date between i_from_date and i_to_date
         ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_134;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_134               cst_woo_api_type_pkg.t_mes_tab_134;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text    => 'Export batch file 134  -> start'
    );

    l_inst_id   := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_end_date, get_sysdate));
    l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_134
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f134_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f134_data bulk collect into l_mes_tab_134 limit BULK_LIMIT;

        for i in 1..l_mes_tab_134.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_134(i).file_date,'YYYYMMDD'), '')
            || '|' || nvl(to_char(l_mes_tab_134(i).cif_num), '')
            || '|' || nvl(to_char(l_mes_tab_134(i).branch_code), '')
            || '|' || nvl(to_char(l_mes_tab_134(i).wdr_bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_134(i).wdr_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_134(i).dep_bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_134(i).dep_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_134(i).dep_curr_code), '')
            || '|' || nvl(to_char(l_mes_tab_134(i).dep_amount), '')
            || '|' || ':' || nvl(to_char(l_mes_tab_134(i).brief_content), '')
            || '|' || nvl(to_char(l_mes_tab_134(i).work_type), '')
            || '|' || nvl(to_char(l_mes_tab_134(i).err_code), '')
            || '|' || nvl(to_char(l_mes_tab_134(i).sv_crd_acct), '')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_134(i).dep_amount;

            --Update payment order status to processed
            update pmo_order
               set status = 'POSA0010' -- processed
             where id = l_mes_tab_134(i).brief_content;

            l_record.delete;

        end loop;

        exit when cur_f134_data%notfound;

    end loop;

    close cur_f134_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f134_data%isopen then
        close cur_f134_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_134;
--------------------------------------------------------------------------------
procedure batch_file_137(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f137_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
        select null                                         as file_date
             , cus.customer_number                          as cif_num
             , (select ag.agent_number
                  from acc_account_object ao
                     , acc_account        aa
                     , ost_agent          ag
                 where ao.account_id    = aa.id
                   and aa.agent_id      = ag.id
                   and ao.entity_type   = iss_api_const_pkg.entity_type_card --'ENTTCARD'
                   and ao.object_id     = opp.card_id
                   and aa.account_type  = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND)
                                                            as branch_code
             , 'W5970'                                      as wdr_bank_code
             , (select aa.account_number
                  from acc_account_object ao
                     , acc_account        aa
                 where ao.account_id    = aa.id
                   and ao.entity_type   = iss_api_const_pkg.entity_type_card --'ENTTCARD'
                   and ao.object_id     = opp.card_id
                   and aa.account_type  = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND)
                                                            as wdr_acct_num
             , null                                         as dep_bank_code
             , null                                         as dep_acct_num
             , case
                    when opo.oper_type not in(opr_api_const_pkg.OPERATION_TYPE_PURCHASE, opr_api_const_pkg.OPERATION_TYPE_REFUND)
                    then com_api_currency_pkg.get_currency_name(opo.oper_currency)
                    else (  select com_api_currency_pkg.get_currency_name(currency)
                              from opr_additional_amount
                             where amount_type = cst_woo_const_pkg.AMOUNT_FEE_ORIGINAL --'AMPR0020'
                               and oper_id = opo.id
                         )
               end as dep_curr_code
             , case
                    when opo.oper_type not in(opr_api_const_pkg.OPERATION_TYPE_PURCHASE, opr_api_const_pkg.OPERATION_TYPE_REFUND)
                    then opo.oper_amount
                    else (  select amount
                              from opr_additional_amount
                             where amount_type = cst_woo_const_pkg.AMOUNT_FEE_ORIGINAL --'AMPR0020'
                               and oper_id = opo.id
                         )
               end as dep_amount
             , ':' || to_char(opo.id)                       as brief_content
             , case
                   when opo.oper_reason = 'FETP0102' and ica.category = 'CRCG0800' then '202'   -- Annual fee (Primary Card)
                   when opo.oper_reason = 'FETP0102' and ica.category <> 'CRCG0800' then '203'  -- Annual fee (Supplementary Card)
                   when opo.oper_reason = 'FETP0109' then '204'                                 -- Card Replacement fee (Lost card)
                   when opo.oper_reason = 'FETP5009' then '205'                                 -- Card Replacement fee (Damaged card)
                   when opo.oper_reason = 'FETP5026' then '206'                                 -- Sales slip reprint (Manual fee charged via Debit adjustment)
                   when opo.oper_reason = 'FETP5004' then '208'                                 -- PIN Reissue (New PIN) via PIN mailer
                   when opo.oper_reason = 'FETP5019' then '209'                                 -- Dispute Investigation (wrong) - (Manual fee charged via Debit adjustment)
                   when opo.oper_reason = 'FETP0118' then '212'                                 -- SMS Notification fee
                   when opo.oper_reason = 'FETP5027' then '213'                                 -- Certification issuance - (Manual fee charged via Debit adjustment)
                   when opo.oper_type   = 'OPTP0000' then '105'                                 -- Refund request for sales cancellation
                   when opo.oper_type   = 'OPTP0020' then '105'                                 -- Refund request for sales cancellation
                   else null
               end                                          as work_type
             , null                                         as err_code
             , null                                         as sv_crd_acct
          from opr_operation           opo
             , opr_participant         opp
             , prd_customer            cus
             , net_card_type_feature   ctf
             , iss_card                ica
         where opo.id                  = opp.oper_id
           and cus.id                  = opp.customer_id
           and cus.id                  = ica.customer_id
           and ica.id                  = opp.card_id
           and ctf.card_type_id        = ica.card_type_id
           and cus.inst_id             = i_inst_id
           and (opo.oper_reason        in( 'FETP0102'    --Card Annual fee
                                         , 'FETP0109'    --Card Replacement fee (Lost card)
                                         , 'FETP5009'    --Card Replacement fee (Damaged card)
                                         , 'FETP5026'    --Sales slip reprint
                                         , 'FETP5004'    --PIN Reissue
                                         , 'FETP5019'    --Dispute Investgation
                                         , 'FETP0118'    --SMS Notification fee
                                         , 'FETP5027'    --Certification insurance
                                        )
                or (opo.oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE and
                    is_reversal = com_api_const_pkg.TRUE and
                    match_status <> opr_api_const_pkg.OPERATION_MATCH_MATCHED)
                or opo.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND
               )
           and opo.msg_type            = aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT           --'MSGTPRES'
           and opo.status              in ( cst_woo_const_pkg.OPER_STATUS_AWAITING_CBS_CONFM  --'OPST5002'
                                          , opr_api_const_pkg.OPERATION_STATUS_PROCESSED      --'OPST0400'
                                          )
           and opp.participant_type    = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
           and ctf.card_feature        = cst_woo_const_pkg.DEBIT_CARD  --'CFCHDEBT'
           and opo.oper_date between i_from_date and i_to_date

       union

       select distinct null --file_date
            , cif_num
            , branch_code
            , wdr_bank_code
            , wdr_acct_num
            , null --dep_bank_code
            , null --dep_acct_num
            , dep_curr_code
            , dep_amount
            , brief_content
            , work_type
            , null --err_code
            , sv_crd_acct
         from cst_woo_import_f138
        where err_code <> '00000000'
          and rcn_status = 0
          and import_date > get_sysdate - 30

        minus

       select distinct null --file_date
            , cif_num
            , branch_code
            , wdr_bank_code
            , wdr_acct_num
            , null --dep_bank_code
            , null --dep_acct_num
            , dep_curr_code
            , dep_amount
            , brief_content
            , work_type
            , null --err_code
            , sv_crd_acct
         from cst_woo_import_f138
        where err_code = '00000000'
          and rcn_status is null
          and import_date > get_sysdate - 30
          ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_137;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_137               cst_woo_api_type_pkg.t_mes_tab_137;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text    => 'Export batch file 137  -> start'
    );

    l_inst_id   := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_end_date, get_sysdate));
    l_to_date   := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_137
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f137_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f137_data bulk collect into l_mes_tab_137 limit BULK_LIMIT;

        for i in 1..l_mes_tab_137.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_137(i).file_date,'YYYYMMDD'), to_char(get_sysdate, 'YYYYMMDD'))
            || '|' || nvl(to_char(l_mes_tab_137(i).cif_num), '')
            || '|' || nvl(to_char(l_mes_tab_137(i).branch_code), '')
            || '|' || nvl(to_char(l_mes_tab_137(i).wdr_bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_137(i).wdr_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_137(i).dep_bank_code), '')
            || '|' || nvl(to_char(l_mes_tab_137(i).dep_acct_num), '')
            || '|' || nvl(to_char(l_mes_tab_137(i).dep_curr_code), '')
            || '|' || nvl(to_char(l_mes_tab_137(i).dep_amount), '')
            || '|' || nvl(to_char(l_mes_tab_137(i).brief_content), '')
            || '|' || nvl(to_char(l_mes_tab_137(i).work_type), '')
            || '|' || nvl(to_char(l_mes_tab_137(i).err_code), '')
            || '|' || nvl(to_char(l_mes_tab_137(i).sv_crd_acct), '')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_137(i).dep_amount;

            l_record.delete;

        end loop;

        exit when cur_f137_data%notfound;

    end loop;

    close cur_f137_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f137_data%isopen then
        close cur_f137_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_137;
--------------------------------------------------------------------------------
procedure batch_file_131 (
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date    default null
) is

    -- Main cursor with data:
    cursor cur_f131_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
    -- 1. non-credit accounts:
    select decode(vf.amount_purpose, cst_woo_const_pkg.VAT_FEE_CARD_LEVEL, icn.card_number, null, nvl(icn.card_number, aa.account_number), aa.account_number) as acct_card_number
         , oo.oper_date as oper_date
         , oo.oper_date as payment_date
         , oo.id as oper_id
         , nvl(oo.original_id, oo.id) as original_oper_id
             , oo.is_reversal as reversal
         , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
                then substr(oo.oper_reason, 5)
                else '9' || substr(oo.oper_type, -3)
           end as fee_code
         , fo.amount as original_fee_amount
         , fo.balance_impact as original_fee_impact
         , 0 as discount_on_fee_amount
         , 1 as discount_on_fee_impact
         , fo.amount as fee_amount_after_discount
         , fo.balance_impact as fee_after_discount_impact
         , nvl(vf.amount, 0) as vat_on_fee_amount
         , nvl(vf.balance_impact, 1) as vat_on_fee_impact
         , nvl(orig.amount, 0) as original_amount
         , nvl(orig.balance_impact, 1) as original_impact
         , null as vat_gl_account
         , case aa.account_type
                when cst_woo_const_pkg.ACCT_TYPE_SAVING_VND 
                then aa.account_number
                else null
           end as sav_account
      from opr_operation oo
         , opr_participant op
         , iss_card_number icn
         , acc_account aa
         , (
            select am.macros_type_id
                 , am.object_id as oper_id
                 , am.amount
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
                 , am.amount_purpose
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
                 , acc_account aa
             where am.id = ae.macros_id
               and ab.id = ae.bunch_id
               and aa.id = ae.account_id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and aa.account_type != acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
               and am.amount_purpose in (cst_woo_const_pkg.VAT_FEE_CARD_LEVEL, cst_woo_const_pkg.VAT_FEE_ACCOUNT_LEVEL)
               and ab.bunch_type_id in (cst_woo_const_pkg.BUNCH_TYPE_ID_VAT, cst_woo_const_pkg.BUNCH_TYPE_ID_VAT_CANCEL)
             union
            -- POS purchase and cash withdrawal
            select am.macros_type_id
                 , am.object_id as oper_id
                 , round(am.amount * 0.090909)
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
                 , cst_woo_const_pkg.VAT_FEE_CARD_LEVEL as amount_purpose
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
                 , opr_operation oo2
                 , acc_account aa
             where am.id = ae.macros_id
               and ab.id = ae.bunch_id
               and aa.id = ae.account_id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and aa.account_type != acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
               and oo2.id = am.object_id
               and oo2.oper_type in (
                                      opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                    , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                    )
               and ab.bunch_type_id in (
                                         cst_woo_const_pkg.BUNCH_TYPE_ID_DEBIT_FEE -- 1007
                                       , cst_woo_const_pkg.BUNCH_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                       )
           ) vf -- VAT on fee
         , (
            select am.macros_type_id
                 , am.object_id as oper_id
                 , am.amount
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
                 , acc_account aa
             where am.id = ae.macros_id
               and ab.id = ae.bunch_id
               and aa.id = ae.account_id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and aa.account_type != acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
               and am.macros_type_id in (cst_woo_const_pkg.MACROS_TYPE_ID_DEBIT_ON_OPER, cst_woo_const_pkg.MACROS_TYPE_ID_CREDIT_ON_OPER)
               and ab.bunch_type_id in (cst_woo_const_pkg.BUNCH_TYPE_ID_DEBIT_ON_OPER, cst_woo_const_pkg.BUNCH_TYPE_ID_CREDIT_ON_OPER)
           ) orig -- original operation
         , (
            select am.macros_type_id
                 , am.object_id as oper_id
                 , am.amount
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
                 , acc_account aa
             where am.id = ae.macros_id
               and ab.id = ae.bunch_id
               and aa.id = ae.account_id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and aa.account_type != acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
               and ab.bunch_type_id in (
                                         cst_woo_const_pkg.BUNCH_TYPE_ID_ORIG_FEE        -- 7132
                                       , cst_woo_const_pkg.BUNCH_TYPE_ID_ORIG_FEE_CANCEL -- 7185
                                       )
             union
            -- POS purchase and cash withdrawal
            select am.macros_type_id
                 , am.object_id as oper_id
                 , round(am.amount * 0.909091)
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
                 , opr_operation oo2
                 , acc_account aa
             where am.id = ae.macros_id
               and ab.id = ae.bunch_id
               and aa.id = ae.account_id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and aa.account_type != acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
               and oo2.id = am.object_id
               and oo2.oper_type in (
                                      opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                    , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                    )
               and ab.bunch_type_id in (
                                         cst_woo_const_pkg.BUNCH_TYPE_ID_DEBIT_FEE -- 1007
                                       , cst_woo_const_pkg.BUNCH_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                       )
           ) fo -- original fee
     where oo.id = op.oper_id
       and oo.id = vf.oper_id(+)
       and oo.id = fo.oper_id
       and oo.id = orig.oper_id(+)
       and op.card_id = icn.card_id(+)
       and fo.account_id = aa.id
       and oo.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and aa.inst_id = i_inst_id
       and oo.oper_type != opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY
       and oo.host_date between i_from_date and i_to_date
    union all
    -- 2. credit accounts
    select decode(vf.amount_purpose, cst_woo_const_pkg.VAT_FEE_CARD_LEVEL, icn.card_number, null, nvl(icn.card_number, aa.account_number), aa.account_number) as acct_card_number
         , oo.oper_date as oper_date
         , paym.payment_complete_date as payment_date
         , oo.id as oper_id
         , nvl(oo.original_id, oo.id) as original_oper_id
         , oo.is_reversal as reversal
         , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
                then substr(oo.oper_reason, 5)
                else '9' || substr(oo.oper_type, -3)
           end as fee_code
         , fo.amount as original_fee_amount
         , fo.balance_impact as original_fee_impact
         , 0 as discount_on_fee_amount
         , 1 as discount_on_fee_impact
         , fo.amount as fee_amount_after_discount
         , fo.balance_impact as fee_after_discount_impact
         , nvl(vf.amount, 0) as vat_on_fee_amount
         , nvl(vf.balance_impact, 0) as vat_on_fee_impact
         , nvl(orig.amount, 0) as original_amount
         , nvl(orig.balance_impact, 1) as original_impact
         , null as vat_gl_account
         , (select a.account_number
              from acc_account_object   o
                 , acc_account          a
                 , iss_card             c
             where o.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD    --'ENTTCARD'
               and o.account_id    = a.id
               and o.object_id     = c.id
               and a.account_type  = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND --'ACTP0131'
               and c.id            = (select i_acct_obj.object_id
                                        from acc_account_object       i_acct_obj
                                           , acc_account              i_acct
                                           , iss_card                 i_ica
                                       where i_acct_obj.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                                         and i_acct_obj.account_id    = i_acct.id
                                         and i_acct_obj.object_id     = i_ica.id
                                         and i_acct.id                = aa.id  -- credit account ID
                                         and rownum                   = 1)     -- Get one random card as requirement if account links to many cards
            ) as sav_account
      from opr_operation oo
         , opr_participant op
         , iss_card_number icn
         , acc_account aa
         , (
            select am.macros_type_id
                 , am.object_id as oper_id
                 , am.amount
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
                 , am.amount_purpose
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
             where am.id = ae.macros_id
               and ab.id = ae.bunch_id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and am.amount_purpose in (cst_woo_const_pkg.VAT_FEE_CARD_LEVEL, cst_woo_const_pkg.VAT_FEE_ACCOUNT_LEVEL)
               and ab.bunch_type_id in (cst_woo_const_pkg.BUNCH_TYPE_ID_VAT, cst_woo_const_pkg.BUNCH_TYPE_ID_VAT_CANCEL)
           ) vf -- VAT on fee
         , (
            select t.payments_sum
                 , t.payment_complete_date
                 , t.oper_id
                 , (
                    select sum(cdo.debt_amount)
                      from crd_debt cdo
                     where cdo.oper_id = t.oper_id
                       and cdo.macros_type_id in (
                                                   cst_woo_const_pkg.MACROS_TYPE_ID_VAT -- 7011
                                                 , cst_woo_const_pkg.MACROS_TYPE_ID_ORIG_FEE -- 7126
                                                 , cst_woo_const_pkg.BUNCH_TYPE_ID_DEBIT_FEE -- 1007
                                                 , cst_woo_const_pkg.BUNCH_TYPE_ID_CREDIT_FEE_CANC -- 1010 
                                                 )
                   ) as debts_sum
              from (
                    select sum(cdp.pay_amount) as payments_sum
                         , max(po.oper_date) as payment_complete_date
                         , cd.oper_id
                      from crd_debt cd
                         , crd_debt_payment cdp
                         , crd_payment cp
                         , opr_operation po
                     where cdp.pay_id = cp.id
                       and cdp.debt_id = cd.id
                       and po.id = cp.oper_id
                       and po.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                       and cd.macros_type_id in (
                                                  cst_woo_const_pkg.MACROS_TYPE_ID_VAT -- 7011
                                                , cst_woo_const_pkg.MACROS_TYPE_ID_ORIG_FEE -- 7126
                                                , cst_woo_const_pkg.BUNCH_TYPE_ID_DEBIT_FEE -- 1007
                                                , cst_woo_const_pkg.BUNCH_TYPE_ID_CREDIT_FEE_CANC -- 1010 
                                                )
                       and not exists (
                           select 1
                             from opr_operation oor
                            where oor.original_id = cp.oper_id
                              and oor.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                       )
                       and cd.oper_id in (
                           select cdi.oper_id
                             from crd_debt cdi
                                , crd_debt_payment cdpi
                                , crd_payment cpi
                                , opr_operation poi
                            where cdpi.pay_id = cpi.id
                              and cdpi.debt_id = cdi.id
                              and poi.id = cpi.oper_id
                              and poi.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                           )
                     group by cd.oper_id
                   ) t
           ) paym -- summary of payments for fee debts (including both parts - original and VAT)
         , (
            select am.macros_type_id
                 , am.object_id as oper_id
                 , am.amount
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
             where am.id = ae.macros_id
               and ab.id = ae.bunch_id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and am.macros_type_id in (cst_woo_const_pkg.MACROS_TYPE_ID_DEBIT_ON_OPER, cst_woo_const_pkg.MACROS_TYPE_ID_CREDIT_ON_OPER)
               and ab.bunch_type_id in (cst_woo_const_pkg.BUNCH_TYPE_ID_DEBIT_ON_OPER, cst_woo_const_pkg.BUNCH_TYPE_ID_CREDIT_ON_OPER)
           ) orig -- original operation
         , (
            select am.macros_type_id
                 , am.object_id as oper_id
                 , am.amount
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
             where am.id = ae.macros_id
               and ab.id = ae.bunch_id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and ab.bunch_type_id in (cst_woo_const_pkg.BUNCH_TYPE_ID_ORIG_FEE, cst_woo_const_pkg.BUNCH_TYPE_ID_ORIG_FEE_CANCEL)
             union
            select am.macros_type_id
                 , am.object_id as oper_id
                 , am.amount -- there's no VAT for credit cards ATM CWD and overseas purchase (domestic purchase doesn't have fees at all) 
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
                 , opr_operation oo2
             where am.id = ae.macros_id
               and ab.id = ae.bunch_id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and oo2.id = am.object_id
               and oo2.oper_type in (
                                      opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                    , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                    )
               and ab.bunch_type_id in (
                                         cst_woo_const_pkg.BUNCH_TYPE_ID_DEBIT_FEE -- 1007
                                       , cst_woo_const_pkg.BUNCH_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                       )
           ) fo -- original fee
     where oo.id = op.oper_id
       and oo.id = vf.oper_id(+)
       and oo.id = paym.oper_id
       and oo.id = fo.oper_id
       and oo.id = orig.oper_id(+)
       and op.card_id = icn.card_id(+)
       and fo.account_id = aa.id
       and oo.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and oo.oper_type != opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY
       and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
       and aa.inst_id = i_inst_id
       and paym.payments_sum >= paym.debts_sum
       and paym.payment_complete_date between i_from_date and i_to_date;

    -- Constants and variables:
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_131;
    BULK_LIMIT         constant pls_integer                    := 1000;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, cst_woo_const_pkg.WOORI_DATE_FORMAT);
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              com_api_type_pkg.t_count       := 0;

    l_mes_tab_131               cst_woo_api_type_pkg.t_mes_tab_131;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_header                    com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => 'Export batch file 131  -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_start_date, get_sysdate));
    l_to_date := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    -- Prepare header data
    l_seq_file_id :=
        prc_api_file_pkg.get_next_file(
            i_file_type => opr_api_const_pkg.FILE_TYPE_UNLOADING
          , i_inst_id   => l_inst_id
          , i_file_attr => cst_woo_com_pkg.get_file_attribute_id(
                               i_file_id  => cst_woo_const_pkg.FILE_ID_131
                           )
        );

    l_header := HEADER
             || '|' || JOB_ID
             || '|' || l_process_date
             || '|' || lpad(l_seq_file_id, 3, 0);

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    -- Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_header
    );

    -- Prepare data details to export
    open cur_f131_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f131_data bulk collect into l_mes_tab_131 limit BULK_LIMIT;

        for i in 1..l_mes_tab_131.count loop
            l_record_count := l_record_count + 1;

            l_record(1) :=
                lpad(l_record_count, 9, 0) -- Data sequence
             || '|' || cst_woo_const_pkg.W_BANK_CODE    --field_10 - BK_CD
             || '|' || l_mes_tab_131(i).acct_card_number    --field_11 - REL_BAS_NO
             || '|' || to_char(l_mes_tab_131(i).oper_date, cst_woo_const_pkg.WOORI_DATE_FORMAT)    --field_12 - FEOCR_DT
             || '|' || to_char(l_mes_tab_131(i).oper_id)    --field_13 - FEOCR_GLB_ID
             || '|' || l_mes_tab_131(i).fee_code    --field_14 - FEE_CD
             || '|' || to_char(l_mes_tab_131(i).payment_date, cst_woo_const_pkg.WOORI_DATE_FORMAT)    --field_15 - FECOL_DT
             || '|' || to_char(l_mes_tab_131(i).original_oper_id)    --field_16 - FECOL_GLB_ID
             || '|'    --field_17 - NCOL_TGT_COL_TRN_YN
             || '|' || cst_woo_const_pkg.VALUE_VND    --field_18 - CUR_CD
             || '|' || to_char(l_mes_tab_131(i).original_fee_amount + l_mes_tab_131(i).vat_on_fee_amount)    --field_19 - FEE_IMPOS_AM
             || '|' || to_char(l_mes_tab_131(i).original_fee_amount + l_mes_tab_131(i).vat_on_fee_amount)    --field_20 - FECOL_AM
             || '|' || '0'    --field_21 - AT_XMP_FEE_AM
             || '|' || to_char(l_mes_tab_131(i).discount_on_fee_amount)    --field_22 - HDW_XMP_FEE_AM
             || '|'    --field_23 - AT_XMP_FEE_RT
             || '|'    --field_24 - HDW_XMP_FEE_RT
             || '|'    --field_25 - AT_RDU_RSN_DSCD
             || '|'    --field_26 - RDU_RSN_DSCD
             || '|'    --field_27 - FEXEM_RSN_TXT
             || '|'    --field_28 - APLY_FEE_RT
             || '|'    --field_29 - RDU_APLY_DSCD
             || '|' || '0'    --field_30 - IMPOS_TAX
             || '|' || to_char(l_mes_tab_131(i).vat_on_fee_amount)    --field_31 - VAT_AM
             || '|' || case 
                           when l_mes_tab_131(i).vat_on_fee_amount > 0 
                           then '0.1'
                           else '0'
                       end    --field_32 - VAT_RT
             || '|' || to_char(l_mes_tab_131(i).original_fee_amount)    --field_33 - VAT_DDU_AF_AM
             || '|' || to_char(l_mes_tab_131(i).payment_date, cst_woo_const_pkg.WOORI_DATE_FORMAT)    --field_34 - FEE_CAL_SDT
             || '|' || to_char(l_mes_tab_131(i).payment_date, cst_woo_const_pkg.WOORI_DATE_FORMAT)    --field_35 - FEE_CAL_EDT
             || '|' || '1'    --field_36 - PRDF_OCP_DSCD
             || '|' || 'N'    --field_37 - NCOL_YN
             || '|'    --field_38 - HDW_COL_YN
             || '|' || case when l_mes_tab_131(i).reversal = 0 then cst_woo_const_pkg.VALUE_CR else cst_woo_const_pkg.VALUE_DR end    --field_39 - RCVPY_DSCD
             || '|' || to_char(l_mes_tab_131(i).sav_account)    --field_40 - REL_ACT_NO
             || '|'    --field_41 - ACC_CD
             || '|' || 'N'    --field_42 - INT_LNM_YN
             || '|' || 'N'    --field_43 - RFND_AVL_YN
             || '|'    --field_44 - OCR_ORGTR_CUR_CD
             || '|' || '0'    --field_45 - OCR_ORGTR_AM
             || '|' || '0'    --field_46 - FEE_APXRT
             || '|'    --field_47 - PRC_FEE_CUR_CD
             || '|' || '0'    --field_48 - PRC_FEE_AM
             || '|'    --field_49 - BR_FEE_SEQ
             || '|' || case when l_mes_tab_131(i).reversal = 0 then '1' else '2' end  --field_50 - RRCV_RFND_DSCD
             || '|' || case when l_mes_tab_131(i).reversal = 0 then l_mes_tab_131(i).original_fee_amount + l_mes_tab_131(i).vat_on_fee_amount else (l_mes_tab_131(i).original_fee_amount + l_mes_tab_131(i).vat_on_fee_amount) * (-1) end   --field_51 - RRCV_RFND_AM
             || '|'    --field_52 - RRCV_RFND_GLB_ID
             || '|'    --field_53 - RRCV_RFND_RSN_DSCD
             || '|' || 'CARD SYSTEM'   --field_54 - RRCV_RFND_RSN_TXT
             || '|'    --field_55 - FEE_CALFM_TXT
             || '|'    --field_56 - APLY_FEE_CALFM_TXT
             || '|'    --field_57 - OCR_RULE_APLY_BAS1_TXT
             || '|' || '1'    --field_69 - CLOC_XC_XRT
             || '|' || to_char(l_mes_tab_131(i).original_fee_amount)    --field_70 - CLOC_XC_FECOL_AM
             || '|' || to_char(l_mes_tab_131(i).vat_on_fee_amount)    --field_71 - CLOC_XC_VAT_AM
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(1)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_131(i).vat_on_fee_amount;
            l_record.delete;

        end loop;

        exit when cur_f131_data%notfound;

    end loop;

    close cur_f131_data;

    --Update file header with total amount and record count
    l_header := l_header
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_header
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

exception
when others then
    if cur_f131_data%isopen then
        close cur_f131_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_131;
--------------------------------------------------------------------------------
procedure batch_file_133 (
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date    default null
) is

    -- Main cursor with data:
    cursor cur_f133_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date  date
      , i_to_date    date
    ) is
    select ag.agent_number as branch_code
         , oo.oper_date as operation_date
         , vf.amount as vat_amount
         , vf.balance_impact as vat_impact
         , cust.customer_number as cif_no
         , oo.id as oper_id
         , nvl(oo.original_id, oo.id) as original_oper_id
         , oo.is_reversal as reversal
         , decode(vf.amount_purpose, cst_woo_const_pkg.VAT_FEE_CARD_LEVEL, icn.card_number, aa.account_number) as acct_card_number
      from opr_operation oo
         , opr_participant op
         , iss_card_number icn
         , acc_account aa
         , ost_agent ag
         , prd_customer cust
         , (
            select am.macros_type_id
                 , am.object_id as oper_id
                 , am.amount
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
                 , am.amount_purpose
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
             where am.id = ae.macros_id
               and ae.bunch_id = ab.id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and am.amount_purpose in (cst_woo_const_pkg.VAT_FEE_CARD_LEVEL, cst_woo_const_pkg.VAT_FEE_ACCOUNT_LEVEL)
               and ab.bunch_type_id in (cst_woo_const_pkg.BUNCH_TYPE_ID_VAT, cst_woo_const_pkg.BUNCH_TYPE_ID_VAT_CANCEL)
             union
            -- POS purchase and cash withdrawal
            select am.macros_type_id
                 , am.object_id as oper_id
                 , round(am.amount * 0.090909)
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
                 , cst_woo_const_pkg.VAT_FEE_CARD_LEVEL as amount_purpose
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
                 , opr_operation oo2
             where am.id = ae.macros_id
               and ab.id = ae.bunch_id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and oo2.id = am.object_id
               and oo2.oper_type in (
                                      opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                    , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                    )
               and ab.bunch_type_id in (
                                         cst_woo_const_pkg.BUNCH_TYPE_ID_DEBIT_FEE -- 1007
                                       , cst_woo_const_pkg.BUNCH_TYPE_ID_CREDIT_FEE_CANC -- 1010
                                       )
           ) vf -- VAT on fee
         , (
            select am.macros_type_id
                 , am.object_id as oper_id
                 , am.amount
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
             where am.id = ae.macros_id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and ae.bunch_id = ab.id
               and am.amount_purpose in (cst_woo_const_pkg.VAT_FEE_CARD_LEVEL, cst_woo_const_pkg.VAT_FEE_ACCOUNT_LEVEL)
               and ab.bunch_type_id in (
                                        select numeric_value
                                          from com_ui_array_element_vw
                                         where array_id = cst_woo_const_pkg.ARRAY_VAT_GL_BUNCH_TYPE
                                           and lang = com_api_const_pkg.LANGUAGE_ENGLISH
                                       )
           ) vfgl -- VAT on fee (GL)
     where oo.id = op.oper_id
       and oo.id = vf.oper_id
       and oo.id = vfgl.oper_id
       and op.card_id = icn.card_id(+)
       and vf.account_id = aa.id
       and vf.balance_impact = vfgl.balance_impact
       and ag.id = aa.agent_id
       and cust.id = op.customer_id
       and oo.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and oo.oper_type != opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY
       and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and aa.account_type != acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
       and aa.inst_id = i_inst_id
       and oo.oper_date between i_from_date and i_to_date
    union all
    -- 2. credit accounts
    select ag.agent_number as branch_code
         , oo.oper_date as operation_date
         , vf.amount as vat_amount
         , vf.balance_impact as vat_impact
         , cust.customer_number as cif_no
         , oo.id as oper_id
         , nvl(oo.original_id, oo.id) as original_oper_id
         , oo.is_reversal as reversal
         , decode(vf.amount_purpose, cst_woo_const_pkg.VAT_FEE_CARD_LEVEL, icn.card_number, aa.account_number) as acct_card_number
      from opr_operation oo
         , opr_participant op
         , iss_card_number icn
         , acc_account aa
         , ost_agent ag
         , prd_customer cust
         , (
            select am.macros_type_id
                 , am.object_id as oper_id
                 , am.amount
                 , am.currency
                 , ae.account_id
                 , ae.balance_impact
                 , am.amount_purpose
              from acc_macros am
                 , acc_bunch ab
                 , acc_entry ae
             where am.id = ae.macros_id
               and ae.bunch_id = ab.id
               and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
               and am.amount_purpose in (cst_woo_const_pkg.VAT_FEE_CARD_LEVEL, cst_woo_const_pkg.VAT_FEE_ACCOUNT_LEVEL)
               and ab.bunch_type_id in (cst_woo_const_pkg.BUNCH_TYPE_ID_VAT, cst_woo_const_pkg.BUNCH_TYPE_ID_VAT_CANCEL)
           ) vf -- VAT on fee
         , (
            select t.payments_sum
                 , t.payment_complete_date
                 , t.oper_id
                 , (
                    select sum(cdo.debt_amount)
                      from crd_debt cdo
                     where cdo.oper_id = t.oper_id
                   ) as debts_sum
              from (
                    select sum(cdp.pay_amount) as payments_sum
                         , max(po.oper_date) as payment_complete_date
                         , cd.oper_id
                      from crd_debt cd
                         , crd_debt_payment cdp
                         , crd_payment cp
                         , opr_operation po
                     where cdp.pay_id = cp.id
                       and cdp.debt_id = cd.id
                       and po.id = cp.oper_id
                       and po.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                       and cd.macros_type_id in (
                                                  cst_woo_const_pkg.MACROS_TYPE_ID_VAT -- 7011
                                                , cst_woo_const_pkg.MACROS_TYPE_ID_ORIG_FEE -- 7126
                                                )
                       and not exists (
                           select 1
                             from opr_operation oor
                            where oor.original_id = cp.oper_id
                              and oor.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                       )
                       and cd.oper_id in (
                           select cdi.oper_id
                             from crd_debt cdi
                                , crd_debt_payment cdpi
                                , crd_payment cpi
                                , opr_operation poi
                            where cdpi.pay_id = cpi.id
                              and cdpi.debt_id = cdi.id
                              and poi.id = cpi.oper_id
                              and poi.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                              and poi.oper_date between i_from_date and i_to_date
                           )
                     group by cd.oper_id
                   ) t
           ) paym -- summary of payments for fee debts (including both parts - original and VAT)
     where oo.id = op.oper_id
       and oo.id = vf.oper_id
       and oo.id = paym.oper_id
       and op.card_id = icn.card_id(+)
       and vf.account_id = aa.id
       and ag.id = aa.agent_id
       and cust.id = op.customer_id
       and oo.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and oo.oper_type != opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY
       and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
       and aa.inst_id = i_inst_id
       and paym.payments_sum >= paym.debts_sum
       and paym.payment_complete_date between i_from_date and i_to_date;

    -- Constants and variables:
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_133;
    BULK_LIMIT         constant pls_integer                    := 1000;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, cst_woo_const_pkg.WOORI_DATE_FORMAT);
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              com_api_type_pkg.t_count       := 0;

    l_mes_tab_133               cst_woo_api_type_pkg.t_mes_tab_133;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_header                    com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => 'Export batch file 133 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_start_date, get_sysdate));
    l_to_date := l_from_date + 1 - com_api_const_pkg.ONE_SECOND;

    -- Prepare header data
    l_seq_file_id :=
        prc_api_file_pkg.get_next_file(
            i_file_type => opr_api_const_pkg.FILE_TYPE_UNLOADING
          , i_inst_id   => l_inst_id
          , i_file_attr => cst_woo_com_pkg.get_file_attribute_id(
                               i_file_id  => cst_woo_const_pkg.FILE_ID_133
                           )
        );

    l_header := HEADER
             || '|' || JOB_ID
             || '|' || l_process_date
             || '|' || lpad(l_seq_file_id, 3, 0);

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    -- Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_header
    );

    -- Prepare data details to export
    open cur_f133_data(
        i_inst_id    => l_inst_id
      , i_from_date  => l_from_date
      , i_to_date    => l_to_date
    );

    loop
        fetch cur_f133_data bulk collect into l_mes_tab_133 limit BULK_LIMIT;

        for i in 1..l_mes_tab_133.count loop
            l_record_count := l_record_count + 1;

            l_record(1) :=
                lpad(l_record_count, 9, 0) -- Data sequence
             || '|' || cst_woo_const_pkg.W_BANK_CODE    --field_10 - BK_CD
             || '|'    --field_11 - REF_NO
             || '|' || l_mes_tab_133(i).branch_code    --field_12 - BR_CD
             || '|' || cst_woo_const_pkg.VALUE_VAT    --field_13 - IMPO_ALTAX_CD
             || '|' || cst_woo_const_pkg.VALUE_VAT    --field_14 - TAX_KD_DSCD
             || '|' || cst_woo_const_pkg.VALUE_NON    --field_15 - BK_ID
             || '|' || to_char(l_mes_tab_133(i).oper_date, cst_woo_const_pkg.WOORI_DATE_FORMAT)    --field_16 - RCV_DT
             || '|' || cst_woo_const_pkg.VALUE_VND    --field_17 - CUR_CD
             || '|' || case when l_mes_tab_133(i).reversal = 0 then l_mes_tab_133(i).vat_amount else l_mes_tab_133(i).vat_amount * (-1) end    --field_18 - TOT_TAX
             || '|' || case when l_mes_tab_133(i).reversal = 0 then l_mes_tab_133(i).vat_amount else l_mes_tab_133(i).vat_amount * (-1) end    --field_19 - ALTAX_AM
             || '|' || '1'    --field_20 - PRN_XCH_XRT
             || '|'    --field_21 - PMNY_CHR_DSCD
             || '|'    --field_22 - INSHR_OFSHR_DSCD
             || '|' || '0'    --field_23 - TAX_RT
             || '|' || cst_woo_const_pkg.VALUE_VND    --field_24 - PAY_CUR_CD
             || '|' || case when l_mes_tab_133(i).reversal = 0 then l_mes_tab_133(i).vat_amount else l_mes_tab_133(i).vat_amount * (-1) end    --field_25 - PAY_AM
             || '|' || '0'    --field_26 - PAY_XRT
             || '|' || case when l_mes_tab_133(i).reversal = 0 then l_mes_tab_133(i).vat_amount else l_mes_tab_133(i).vat_amount * (-1) end    --field_27 - BSCR_XC_TRN_AM
             || '|'    --field_28 - PI_DT
             || '|' || case when l_mes_tab_133(i).reversal = 0 then l_mes_tab_133(i).vat_amount else l_mes_tab_133(i).vat_amount * (-1) end    --field_29 - TAX_BL
             || '|' || cst_woo_const_pkg.VALUE_VND    --field_30 - TRN_CUR_CD
             || '|' || case when l_mes_tab_133(i).reversal = 0 then l_mes_tab_133(i).vat_amount else l_mes_tab_133(i).vat_amount * (-1) end    --field_31 - TRN_AM
             || '|'    --field_32 - CUS_DSCD
             || '|' || l_mes_tab_133(i).cif_no    --field_33 - CUS_NO
             || '|'    --field_34 - RSD_DSCD
             || '|' || to_char(l_mes_tab_133(i).acct_card_number)    --field_35 - ACT_NO
             || '|'    --field_36 - EMP_NO
             || '|' || case when l_mes_tab_133(i).reversal = 0 then null else to_char(l_mes_tab_133(i).original_oper_id) end    --field_37 - ALTAX_RMK
             || '|' || 'CH'    --field_38 - APL_DSCD
             || '|'    --field_39 - APL_REF_NO
             || '|' || '10'    --field_40 - IMPO_ALTAX_STS_DSCD
             || '|'    --field_41 - WCTR_NM
             || '|'    --field_42 - TAX_CHRPE_NM
             || '|'    --field_43 - TRCO_NM
             || '|'    --field_44 - SVC_OFR_SDT
             || '|'    --field_45 - SVC_OFR_EDT
             || '|' || '0'    --field_46 - SVC_OFR_DCN
             || '|' || to_char(l_mes_tab_133(i).oper_id)    --field_47
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(1)
              , i_sess_file_id  => l_session_file_id
            );

            l_total_amount := l_total_amount + l_mes_tab_133(i).vat_amount;
            l_record.delete;

        end loop;

        exit when cur_f133_data%notfound;

    end loop;

    close cur_f133_data;

    --Update file header with total amount and record count
    l_header := l_header
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_header
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total ' || l_record_count || ' records are exported successfully -> End!'
    );

exception
when others then
    if cur_f133_data%isopen then
        close cur_f133_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_133;
--------------------------------------------------------------------------------
procedure batch_file_126(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_end_date              in      date    default null
) is

    cursor cur_f126_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_date       date
    ) is
        select i_date as ref_date
             , aa.account_number
             , pc.customer_number
             , po.service_id
             -- get the earned points until current date or specified date
             , (select sum(b.amount)
                  from lty_bonus b
                 where b.account_id = ao.account_id
                   and trunc(b.oper_date) <= i_date
                ) as earned_points
             -- get the used points until current date or specified date
             , (select sum(b.spent_amount)
                  from lty_bonus b
                 where b.status in (
                                      lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE    --'BNST0100'
                                    , lty_api_const_pkg.BONUS_TRANSACTION_SPENT     --'BNST0200'
                                    )
                   and b.account_id = ao.account_id
                   and trunc(b.oper_date) <= i_date
                ) as used_points
             -- get the total expired points until current date or specified date
             , (select sum(b.amount - b.spent_amount)
                  from lty_bonus b
                 where b.status = lty_api_const_pkg.BONUS_TRANSACTION_OUTDATED  --'BNST0300'
                   and b.expire_date <= i_date
                   and b.account_id = ao.account_id
                ) as expired_points
             , null as remaining_points
          from prd_service_object   po
             , acc_account_object   ao
             , acc_account          aa
             , prd_customer         pc
             , prd_service          ps
         where po.service_id        = ps.id
           and ao.account_id        = aa.id
           and aa.customer_id       = pc.id
           and ao.object_id         = po.object_id
           and po.split_hash        = ao.split_hash
           and ps.service_type_id   = lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID         -- 10000790
           and ao.entity_type       = iss_api_const_pkg.ENTITY_TYPE_CARD                --'ENTTCARD'
           and po.entity_type       = iss_api_const_pkg.ENTITY_TYPE_CARD                --'ENTTCARD'
           and aa.account_type      = cst_woo_const_pkg.ACCT_TYPE_LOYALTY               --'ACTPLOYT'
           and po.status            = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE    --'SROS0020'
           and exists (select 1 from lty_bonus where account_id = ao.account_id and oper_date <= i_date)
      group by customer_number
             , account_number
             , service_id
             , ao.account_id        
           ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_126;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_126               cst_woo_api_type_pkg.t_mes_tab_126;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text          => 'Export batch file 126 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);
    
    l_to_date := trunc(nvl(i_end_date, sysdate));

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_126
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f126_data(
        i_inst_id   => l_inst_id
      , i_date      => l_to_date
    );

    loop
        fetch cur_f126_data bulk collect into l_mes_tab_126 limit BULK_LIMIT;

        for i in 1..l_mes_tab_126.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_126(i).ref_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_126(i).account_number), '')
            || '|' || nvl(to_char(l_mes_tab_126(i).customer_number), '')
            || '|' || nvl(to_char(l_mes_tab_126(i).point_type), '')
            || '|' || nvl(to_char(l_mes_tab_126(i).earned_points), '0')
            || '|' || nvl(to_char(l_mes_tab_126(i).used_points), '0')
            || '|' || '' -- conversion_score
            || '|' || nvl(to_char(l_mes_tab_126(i).expired_points), '0')
            || '|' || to_char(nvl(l_mes_tab_126(i).earned_points, 0) - nvl(l_mes_tab_126(i).used_points, 0) - nvl(l_mes_tab_126(i).expired_points, 0))
            || '|' || '' -- reversion_score
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_record.delete;

        end loop;

        exit when cur_f126_data%notfound;

    end loop;

    close cur_f126_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f126_data%isopen then
        close cur_f126_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_126;

procedure batch_file_93(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date    default null
  , i_end_date              in      date    default null
) is

    cursor cur_f93_data(
        i_inst_id    com_api_type_pkg.t_inst_id
      , i_from_date     date
      , i_to_date       date
    ) is
    select aa.account_number
         , icn.card_number
         , nvl(op.auth_code, auth.auth_code) as auth_number
         , case
                when oo.msg_type = aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                 and oo.is_reversal = com_api_const_pkg.FALSE
                then 1
                when oo.msg_type = aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                 and oo.is_reversal = com_api_const_pkg.TRUE
                then 2
                when oo.msg_type = aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                 and oo.is_reversal = com_api_const_pkg.FALSE
                then 3
                when oo.msg_type = aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                 and oo.is_reversal = com_api_const_pkg.TRUE
                then 4
                else null
           end as data_type
         , case
                when oo.msg_type = aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                 and oo.is_reversal = com_api_const_pkg.FALSE
                then oo.host_date
                else null
           end as auth_date
         , case
                when oo.msg_type = aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                 and oo.is_reversal = com_api_const_pkg.TRUE
                then oo.host_date
                else null
           end as auth_reversal_date
         , case
                when oo.msg_type = aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                 and oo.is_reversal = com_api_const_pkg.FALSE
                then oo.host_date
                else null
           end as clearing_date
         , case
                when oo.msg_type = aut_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                 and oo.is_reversal = com_api_const_pkg.TRUE
                then oo.host_date
                else null
           end as clearing_reversal_date
         , cst_woo_com_pkg.get_cycle_date(
                    i_cycle_type      => crd_api_const_pkg.OVERDUE_DATE_CYCLE_TYPE  --'CYTP1008'
                  , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT      --'ENTTACCT'
                  , i_object_id       => aa.id
                  , i_split_hash      => aa.split_hash
                  , i_from_date       => com_api_const_pkg.FALSE
           ) as payment_due_date
         , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE --'OPTP0119'
                 and oo.oper_reason = mcw_api_const_pkg.ANNUAL_CARD_FEE         --'FETP0102'
                then 300 -- annual fee
                when (oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE and oo.oper_reason like 'FETP%')
                  or fin.amount_type = 'F'
                then 400 -- fee
                when op.card_country = oo.merchant_country and nvl(vfm.settlement_flag, 8) <> 0
                then 100 -- Domestic
                when (op.card_country = oo.merchant_country and nvl(vfm.settlement_flag, 8) = 0)
                  or (op.card_country <> oo.merchant_country)
                then 200 -- Oversea
                else null
           end as payment_prod_code
         , abs(fin.amount) as approved_amount
         , oo.merchant_number
         , null as sav_account
         , oo.merchant_name
      from opr_operation oo
         , opr_participant op
         , acc_account aa
         , prd_customer cust
         , iss_card_number icn
         , opr_operation ooo -- original for reversal
         , vis_fin_message vfm
         , (
            select amount_type
                 , oper_id
                 , sum(amount) as amount
              from (
                    select case when am.macros_type_id in (7012, 7186, 7132, 7185, 1007, 1008, 1009, 1010)
                                then 'F' -- fee
                                else 'O' -- operation
                           end as amount_type
                         , ae.amount * ae.balance_impact as amount
                         , am.object_id as oper_id
                      from acc_entry ae
                         , acc_bunch ab
                         , acc_macros am
                     where am.id = ae.macros_id
                       and ab.id = ae.bunch_id
                       and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
                       and ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER --'BLTP0001'
                       and ab.bunch_type_id in (7012, 7186, 7132, 7185, 1007, 1008, 1009, 1010, -- fees
                                                1003, 1004, 1005, 1006) -- original operation
                   )
             group by oper_id
                    , amount_type
            union all
            select 'O' as amount_type
                 , ao.id
                 , (select amount
                      from opr_additional_amount
                     where amount_type = 'AMPR0010'
                     and oper_id = ao.id
                     ) as amount
              from opr_operation ao
                 , opr_participant ap
             where ao.id = ap.oper_id
               and ap.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER       --'PRTYISS'
               and ao.msg_type = aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION       --'MSGTAUTH'
               and ao.status in ( opr_api_const_pkg.OPERATION_STATUS_PROCESSED      --'OPST0400'
                                , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC   --'OPST0401'
                                , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED       --'OPST0402'
                                , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED     --'OPST0403'
                                )
               and ao.oper_type in  ( opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE   --'OPTP0119'
                                    , opr_api_const_pkg.OPERATION_TYPE_PURCHASE     --'OPTP0000'
                                    , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH     --'OPTP0001'
                                    , opr_api_const_pkg.OPERATION_TYPE_POS_CASH     --'OPTP0012'
                                    )
           ) fin
         , (
            select ao.id
                 , ao.match_id
                 , ap.auth_code
                 , ao.is_reversal
                 , ao.host_date
                 , aor.host_date as reversal_host_date
              from opr_operation ao
                 , opr_participant ap
                 , opr_operation aor
             where ao.id = ap.oper_id
               and ao.id = aor.original_id(+)
               and aor.status(+) in ( opr_api_const_pkg.OPERATION_STATUS_PROCESSED      --'OPST0400'
                                    , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC   --'OPST0401'
                                    , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED       --'OPST0402'
                                    , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED     --'OPST0403'
                                    )
               and ap.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER       --'PRTYISS'
               and ao.msg_type = aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION       --'MSGTAUTH'
               and ao.status in ( opr_api_const_pkg.OPERATION_STATUS_PROCESSED      --'OPST0400'
                                , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC   --'OPST0401'
                                , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED       --'OPST0402'
                                , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED     --'OPST0403'
                                )
               and ao.oper_type in  ( opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE   --'OPTP0119'
                                    , opr_api_const_pkg.OPERATION_TYPE_PURCHASE     --'OPTP0000'
                                    , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH     --'OPTP0001'
                                    , opr_api_const_pkg.OPERATION_TYPE_POS_CASH     --'OPTP0012'
                                    )
           ) auth
     where oo.id = op.oper_id
       and oo.id = fin.oper_id
       and op.customer_id = cust.id
       and op.account_id = aa.id
       and oo.id = vfm.id(+)
       and op.card_id = icn.card_id(+)
       and oo.match_id = auth.id(+)
       and oo.original_id = ooo.id(+)
       and aa.inst_id = i_inst_id
       and ooo.status(+) in ( opr_api_const_pkg.OPERATION_STATUS_PROCESSED      --'OPST0400'
                            , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC   --'OPST0401'
                            , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED       --'OPST0402'
                            , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED     --'OPST0403'
                            )
       and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER       --'PRTYISS'
       and oo.status in ( opr_api_const_pkg.OPERATION_STATUS_PROCESSED      --'OPST0400'
                        , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC   --'OPST0401'
                        , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED       --'OPST0402'
                        , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED     --'OPST0403'
                        )
       and aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT          --'ACTP0130'
       and cust.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY         --'ENTTCOMP'
       and oo.oper_type in  ( opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE   --'OPTP0119'
                            , opr_api_const_pkg.OPERATION_TYPE_PURCHASE     --'OPTP0000'
                            , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH     --'OPTP0001'
                            , opr_api_const_pkg.OPERATION_TYPE_POS_CASH     --'OPTP0012'
                            )
       and oo.oper_date between i_from_date and i_to_date
     order by aa.account_number
            , oo.id
       ;

--Header info
    HEADER             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.F_HEADER;
    JOB_ID             constant com_api_type_pkg.t_dict_value  := cst_woo_const_pkg.FILE_JOB_93;
    l_process_date              com_api_type_pkg.t_date_short  := to_char(get_sysdate, 'yyyymmdd');
    l_seq_file_id               com_api_type_pkg.t_seqnum      := 0;
    l_total_amount              com_api_type_pkg.t_money       := 0;
    l_record_count              pls_integer                    := 0;
--For file processing
    BULK_LIMIT         constant pls_integer := 1000;
    l_mes_tab_93                cst_woo_api_type_pkg.t_mes_tab_93;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record                    com_api_type_pkg.t_raw_tab;
    l_line                      com_api_type_pkg.t_text;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_from_date                 date;
    l_to_date                   date;

begin
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text          => 'Export batch file 93 -> start'
    );

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_from_date := trunc(nvl(i_start_date, get_sysdate));
    l_to_date := nvl(i_end_date, get_sysdate);

    --Prepare header data
    l_seq_file_id := prc_api_file_pkg.get_next_file(
                         i_file_type  => opr_api_const_pkg.FILE_TYPE_UNLOADING
                       , i_inst_id    => l_inst_id
                       , i_file_attr  => cst_woo_com_pkg.get_file_attribute_id(
                                            i_file_id  => cst_woo_const_pkg.FILE_ID_93
                                         )
                     );

    l_line := HEADER
    || '|' || JOB_ID
    || '|' || l_process_date
    || '|' || lpad(l_seq_file_id, 3 ,0)
    ;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    --Put header data into file
    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    --Prepare data details to export
    open cur_f93_data(
        i_inst_id   => l_inst_id
      , i_from_date     => l_from_date
      , i_to_date       => l_to_date
    );

    loop
        fetch cur_f93_data bulk collect into l_mes_tab_93 limit BULK_LIMIT;

        for i in 1..l_mes_tab_93.count loop
            l_record_count := l_record_count + 1;
            l_record(i) := lpad(l_record_count, 9, 0)
            || '|' || nvl(to_char(l_mes_tab_93(i).account_number), '')
            || '|' || nvl(to_char(l_mes_tab_93(i).card_number), '')
            || '|' || nvl(to_char(l_mes_tab_93(i).auth_number), '')
            || '|' || nvl(to_char(l_mes_tab_93(i).data_type), '')
            || '|' || nvl(to_char(l_mes_tab_93(i).auth_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_93(i).auth_reversal_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_93(i).clearing_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_93(i).clearing_reversal_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_93(i).payment_due_date, cst_woo_const_pkg.WOORI_DATE_FORMAT), '')
            || '|' || nvl(to_char(l_mes_tab_93(i).payment_prod_code), '')
            || '|' || ''
            || '|' || nvl(to_char(l_mes_tab_93(i).approved_amount), '0')
            || '|' || nvl(to_char(l_mes_tab_93(i).merchant_number), '')
            || '|' || nvl(to_char(l_mes_tab_93(i).saving_account), '')
            || '|' || nvl(trim(l_mes_tab_93(i).merchant_name), '')
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record(i)
              , i_sess_file_id  => l_session_file_id
            );

            l_record.delete;

        end loop;

        exit when cur_f93_data%notfound;

    end loop;

    close cur_f93_data;

    --Update file header with total amount and record count
    l_line := l_line
    || '|' || l_total_amount
    || '|' || l_record_count
    ;

    cst_woo_com_pkg.update_file_header(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_line
    );

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    trc_log_pkg.debug(
        i_text    => 'Total '||l_record_count||' records are exported successfully -> End!'
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
when others then
    if cur_f93_data%isopen then
        close cur_f93_data;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;

end batch_file_93;

end cst_woo_prc_outgoing_pkg;
/
