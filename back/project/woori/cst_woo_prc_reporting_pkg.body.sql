create or replace package body      cst_woo_prc_reporting_pkg is

    g_sysdate           date default get_sysdate;

function get_account_balance(
    i_account_id        in      com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_money
is
    l_balance           com_api_type_pkg.t_money default 0;
    l_currency          com_api_type_pkg.t_curr_code;
begin
    acc_api_balance_pkg.get_account_balance(
        i_account_id       => i_account_id
      , o_account_balance  => l_balance
      , o_account_currency => l_currency
    );
    return l_balance;
exception
when others then
    trc_log_pkg.error(
        i_text       => 'Cannot get account balance: [#1]'
      , i_env_param1 => sqlerrm
    );
    return null;
end get_account_balance;

function get_account_number(
    i_account_id        in      com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_account_number
is
    l_result            com_api_type_pkg.t_account_number;
begin
    select account_number
      into l_result
      from acc_account
     where id = i_account_id;
    return l_result;
exception
when others then
    return null;
end get_account_number;

function get_bunch_name(
    i_bunch_id          in com_api_type_pkg.t_long_id
) return  com_api_type_pkg.t_text
is
    l_result            com_api_type_pkg.t_text;
begin
    select text
      into l_result
      from com_i18n
     where table_name = 'ACC_BUNCH_TYPE'
       and lang = com_api_const_pkg.LANGUAGE_ENGLISH
       and column_name = 'NAME'
       and object_id = (select distinct bunch_type_id from acc_bunch where id = i_bunch_id);
    return l_result;
exception
when others then
    return null;
end get_bunch_name;

function get_file_count(
    i_process_id in     prc_session.process_id%type
  , i_start_date in     date                        default null
  , i_end_date   in     date                        default null
) return com_api_type_pkg.t_short_id is
    l_file_count com_api_type_pkg.t_short_id;
begin
    select count(sf.file_name)
      into l_file_count
      from prc_session_file sf
      join prc_session ss on ss.id = sf.session_id
     where ss.process_id = i_process_id
       and (sf.file_date >= i_start_date or i_start_date is null)
       and (sf.file_date <  i_end_date   or i_end_date is null)
       and sf.status = prc_api_const_pkg.FILE_STATUS_ACCEPTED;

    return l_file_count;
exception
when others then
    return null;
end get_file_count;

procedure export_file_51(
    i_inst_id           in      com_api_type_pkg.t_inst_id
)
is
    l_session_file_id   prc_session_file.id%type;
    l_process_id        prc_session.process_id%type;
    l_file_name         prc_session_file.file_name%type;

    l_row_header        com_api_type_pkg.t_text;
    l_row_detail        com_api_type_pkg.t_text;

    l_balance_total     com_api_type_pkg.t_money      default 0;
    l_record_number     com_api_type_pkg.t_medium_id  default 1;

    l_file_count        com_api_type_pkg.t_short_id   default 1;
    l_estimated_count   com_api_type_pkg.t_medium_id  default 0;
    l_processed_count   com_api_type_pkg.t_medium_id  default 0;
    l_rejected_count    com_api_type_pkg.t_medium_id  default 0;
    l_excepted_count    com_api_type_pkg.t_medium_id  default 0;

begin --main

    savepoint export_start;

    g_sysdate := trunc(get_sysdate);

    --here is the estimated number of real exported data
    select count(gl.id)
         , sum(get_account_balance(gl.id))
      into l_estimated_count
         , l_balance_total
      from acc_gl_account_mvw gl
      join ost_agent ag on ag.id = gl.agent_id      
     where 1 = 1
       --and ag.agent_number in ('001', '100', '200') -- for testing purpose
       and (gl.inst_id = i_inst_id or i_inst_id is null)
       ;

    prc_api_stat_pkg.log_estimation(l_estimated_count);

    l_process_id := prc_api_session_pkg.get_process_id;

    l_file_count := get_file_count(
                        i_process_id => l_process_id
                      , i_start_date => g_sysdate
                      , i_end_date   => g_sysdate + 1
                    );
    l_file_count := l_file_count + 1;

    --J28309V_YYYYMMDD_CH051_001.dat
    l_file_name := 'J28309V_'
                || to_char(g_sysdate, 'YYYYMMDD')
                || '_CH051_'
                || lpad(l_file_count, 3, '0')
                || '.dat';

    prc_api_file_pkg.open_file(
        o_sess_file_id => l_session_file_id
      , i_file_name    => l_file_name
    );

    trc_log_pkg.debug(
        i_text       => 'File [#1] with id [#2] is opened'
      , i_env_param1 => l_file_name
      , i_env_param2 => l_session_file_id
    );

    l_row_header := 'HEADER'                             -- constant
                || '|' || 'J28309V'                      -- constant, changed at 21.06.2017, old value '0000510'
                || '|' || to_char(g_sysdate, 'yyyymmdd') -- file generated date
                || '|' || lpad(l_file_count, 3 ,0)       -- the unique file count
                || '|' || l_balance_total                -- summary of amount
                || '|' || l_estimated_count              -- number of details
                ;

    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data      => l_row_header
    );

    for cur in (
        select gl.id
             , gl.account_number
             , gl.currency
             , gl.inst_id
             , ag.agent_number
             , get_account_balance(gl.id) as balance
          from acc_gl_account_mvw gl
          join ost_agent ag on ag.id = gl.agent_id
         where 1 = 1
           --and ag.agent_number in ('001', '100', '200') -- for testing purpose
           and (gl.inst_id = i_inst_id or i_inst_id is null)
    ) loop
    begin
        l_row_detail := l_row_detail
               || lpad(l_record_number, 9, '0')        -- data seq
        || '|' || cst_woo_const_pkg.W_BANK_CODE        -- bank code 'W5970'
        || '|' || to_char(g_sysdate, 'yyyymmdd')       -- file generation date
        || '|' || cur.account_number
               || cur.currency                         -- branch code + GL account code + currency code
        || '|' || '1'                                  -- Transaction processing serial number
        || '|' || cur.agent_number                     -- branch code FROM API
        || '|' || 'L'                                  -- accounting code L:local GAAP
        || '|' || substr(cur.account_number, 4, length(cur.account_number)-3)    -- GL account code FROM API
        || '|' || ''
        || '|' || 'VND'                                -- constant
        || '|' || 'NON'                                -- constant
        || '|' || abs(cur.balance)                     -- account balance
        || '|' || '0'
        || '|' || '0'
        || '|' || '0'
        || '|' || '0'
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || '0'
        || '|' || '0'
        || '|' || ''
        || '|' || '0'
        || '|' || '0'
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || '0'
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || '0'
        || '|' || '0'
        || '|' || '0'
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || '0'
        || '|' || '0'
        || '|' || '0'
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || '0'
        || '|' || ''
        || '|' || ''
        || '|' || '0'
        || '|' || '0'
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        || '|' || ''
        ;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data  => l_row_detail
        );

        l_record_number := l_record_number + 1;

        l_processed_count := l_processed_count + 1;

        prc_api_stat_pkg.increase_current(l_processed_count, l_excepted_count);

        l_row_detail := null;

    exception
        when others then
            l_excepted_count := l_excepted_count + 1;

            prc_api_stat_pkg.increase_current(l_processed_count, l_excepted_count);

            trc_log_pkg.error(
                i_text          => 'Record [#1] was not exported for reason of '
              , i_env_param1    => l_record_number
            );
    end;
    end loop;

    prc_api_file_pkg.close_file(
        i_sess_file_id      => l_session_file_id
      , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
      , i_record_count      => l_processed_count
    );

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_rejected_total    => l_rejected_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to savepoint export_start;

        prc_api_stat_pkg.log_end(
            i_excepted_total    => l_estimated_count
          , i_processed_total   => l_processed_count
          , i_rejected_total    => l_rejected_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end export_file_51;

/*
 * This file is exported except these bunch ID:
      7080, 7084, 7105, 7106, 7118
    , 7119, 7140, 7143, 7144, 7152
    , 7156, 7171, 7172, 7179, 7180
 *  If date input parameter exist, the date/time period must be parameter date
 *  If date input paremeter not exist, the date/time period must be sysdate
 */
procedure export_file_53(
    i_inst_id           in com_api_type_pkg.t_inst_id
  , i_end_date          in      date    default null
)
is
    l_file_params       com_api_type_pkg.t_param_tab;

    l_session_file_id   prc_session_file.id%type;
    l_process_id        prc_session.process_id%type;
    l_file_name         prc_session_file.file_name%type;
    l_acc_ref_date      date;

    l_row_header        com_api_type_pkg.t_text;
    l_row_detail        com_api_type_pkg.t_text;

    l_record_number     com_api_type_pkg.t_short_id  default 1;

    l_file_count        com_api_type_pkg.t_short_id  default 1;
    l_estimated_count   com_api_type_pkg.t_short_id  default 0;
    l_processed_count   com_api_type_pkg.t_short_id  default 0;
    l_rejected_count    com_api_type_pkg.t_short_id  default 0;
    l_excepted_count    com_api_type_pkg.t_short_id  default 0;

    l_estimated_sum     com_api_type_pkg.t_long_id   default 0;
    l_start_date        date;
    l_end_date          date;

begin --main

    savepoint export_start;

    g_sysdate := trunc(get_sysdate);

    l_end_date := nvl(i_end_date, get_sysdate);
    l_end_date := to_date(to_char(l_end_date, 'dd/mm/yyyy')|| ' 23:59:59', 'dd/mm/yyyy HH24:MI:SS');
        l_start_date := trunc(l_end_date);

    trc_log_pkg.debug(
        i_text       => 'l_start_date=[#1], l_end_date=[#2]'
      , i_env_param1 => to_char(l_start_date, 'dd.mm.yyyy HH24:MI:SS')
      , i_env_param2 => to_char(l_end_date, 'dd.mm.yyyy HH24:MI:SS')
    );

    select count(operation_id) as total_operation_id
         , sum(operation_amount) as total_operation_amount
      into l_estimated_count
         , l_estimated_sum
      from (select opr.id as operation_id
                 , ent.amount as operation_amount
              from opr_participant par
              join opr_operation opr on opr.id = par.oper_id
              join acc_macros mac on mac.object_id = opr.id
               and mac.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
              join acc_entry ent on ent.macros_id = mac.id
               and ent.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER  --'BLTP0001'
              join acc_gl_account_mvw gl on gl.id = ent.account_id
              join ost_agent ag on ag.id = gl.agent_id
               --and ag.agent_number in ('001', '100', '200') -- for testing purpose
             where par.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER  -- 'PRTYISS'
               and ent.posting_date between l_start_date and l_end_date
               and not exists (select 1
                                 from acc_bunch
                                where bunch_type_id in (
                                                          7080, 7084, 7105, 7106, 7118
                                                        , 7119, 7140, 7143, 7144, 7152
                                                        , 7156, 7171, 7172, 7179, 7180
                                                        )
                                  and id = ent.bunch_id)
               and opr.oper_type not in (
                                           'OPTP7033' --GL Debit adjustment
                                         , 'OPTP7032' --GL credit adjustment
                                         )
          group by ag.agent_number
                 , par.customer_id
                 , par.card_id
                 , par.account_id
                 , opr.id
                 , ent.amount
                 , ent.currency
                 , ent.bunch_id
           );

    prc_api_stat_pkg.log_estimation(l_estimated_count);

    l_process_id := prc_api_session_pkg.get_process_id;

    l_file_count := get_file_count(
        i_process_id => l_process_id
      , i_start_date => g_sysdate
      , i_end_date   => g_sysdate + 1
    );

    l_file_count := l_file_count + 1;

    --O28308V_YYYYMMDD_AC153_***.dat
    l_file_name := 'O28308V_'
                || to_char(g_sysdate, 'YYYYMMDD')
                || '_AC153_'
                || lpad(l_file_count, 3, '0')
                || '.dat';

    prc_api_file_pkg.open_file(
        o_sess_file_id => l_session_file_id
      , i_file_name    => l_file_name
    );

    trc_log_pkg.debug(
        i_text       => 'File [#1] with id [#2] is opened'
      , i_env_param1 => l_file_name
      , i_env_param2 => l_session_file_id
    );

    l_row_header := 'HEADER'
                || '|' || 'O28308V'
                || '|' || to_char(l_end_date, 'yyyymmdd')
                || '|' || lpad(l_file_count, 3, '0')
                || '|' || l_estimated_sum
                || '|' || l_estimated_count
    ;

    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data  => l_row_header
    );

    for cur in (
        select agent_number, customer_number, card_number, account_number
             , operation_id, operation_amount, bunch_id
             , com_api_currency_pkg.get_currency_name(operation_currency) as operation_currency
             , case when credit_account  < 0 then null
                    else cst_woo_prc_reporting_pkg.get_account_number(abs(credit_account))
                end as credit_account
             , case when debit_account   > 0 then null
                    else cst_woo_prc_reporting_pkg.get_account_number(abs(debit_account))
                end as debit_account
             , case when credit_amount   < 0 then null
                    else abs(credit_amount)
                end as credit_amount
             , case when debit_amount    > 0 then null
                    else abs(debit_amount)
                end as debit_amount
             , case when credit_currency < 0 then null
                    else com_api_currency_pkg.get_currency_name(abs(credit_currency))
               end as credit_currency
             , case when debit_currency  > 0 then null
                    else com_api_currency_pkg.get_currency_name(abs(debit_currency))
               end as debit_currency

        from (select ag.agent_number
                   , prd_api_customer_pkg.get_customer_number(par.customer_id) as customer_number
                   , iss_api_card_pkg.get_card_number(par.card_id) as card_number
                   , cst_woo_prc_reporting_pkg.get_account_number(par.account_id) as account_number
                   , opr.id            as operation_id
                   , ent.amount        as operation_amount
                   , ent.currency      as operation_currency
                   , ent.bunch_id      as bunch_id
                   , max(ent.account_id * ent.balance_impact) as credit_account
                   , min(ent.account_id * ent.balance_impact) as debit_account
                   , max(ent.amount * ent.balance_impact) as credit_amount
                   , min(ent.amount * ent.balance_impact) as debit_amount
                   , max(ent.currency * ent.balance_impact) as credit_currency
                   , min(ent.currency * ent.balance_impact) as debit_currency
                from opr_participant par
                join opr_operation opr on opr.id = par.oper_id
                join acc_macros mac on mac.object_id = opr.id
                 and mac.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
                join acc_entry ent on ent.macros_id = mac.id
                 and ent.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER  --'BLTP0001'
                join acc_gl_account_mvw gl on gl.id = ent.account_id
                join ost_agent ag on ag.id = gl.agent_id
                 --and ag.agent_number in ('001', '100', '200') -- for testing purpose
               where par.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER  -- 'PRTYISS'
                 and ent.posting_date between l_start_date and l_end_date
                 and not exists (select 1
                                   from acc_bunch
                                  where bunch_type_id in (
                                                            7080, 7084, 7105, 7106, 7118
                                                          , 7119, 7140, 7143, 7144, 7152
                                                          , 7156, 7171, 7172, 7179, 7180
                                                          )
                                    and id = ent.bunch_id)
                 and opr.oper_type not in (
                                             'OPTP7033' --GL Debit adjustment
                                           , 'OPTP7032' --GL credit adjustment
                                           )
               group by ag.agent_number
                      , par.customer_id
                      , par.card_id
                      , par.account_id
                      , opr.id
                      , ent.amount
                      , ent.currency
                      , ent.bunch_id
             )
    ) loop
    begin

        select oper_date
          into l_acc_ref_date
          from opr_operation
         where id = cur.operation_id;

        if l_acc_ref_date >= trunc(l_end_date) + 1/24*18 then
            l_acc_ref_date := trunc(l_end_date) + 1;
        end if;

        l_row_detail := l_row_detail
                   || lpad(l_record_number, 9, '0')        -- data seq
            || '|' || 'Type1'                              -- Daily account common usage area
            || '|' || cst_woo_const_pkg.W_BANK_CODE        -- Bank code 'W5970'
            || '|' || ''                                   -- Journal Global ID
            || '|' || cur.agent_number                     -- sv agency ID
            || '|' || to_char(g_sysdate, 'yyyymmdd')       -- file generated date YYYYMMDD
            || '|' || ''                                   -- document number
            || '|' || 'CH'                                 -- Business classification code
            || '|' || cur.account_number                   -- business reference number
            || '|' || ''                                   -- transaction code
            || '|' || 'B'                                  -- constant
            || '|' || to_char(l_acc_ref_date, 'yyyymmdd')  -- Accounting Reflection Day
            || '|' || ''
            || '|' || ''
            || '|' || ''
            || '|' || ''
            || '|' || ''
            || '|' || '0'
            || '|' || cur.operation_id                     -- Original Transaction Global ID
            || '|' || ''
            || '|' || nvl(cur.card_number, cur.account_number) -- Related reference number
            || '|' || 'Y'
            || '|' || cur.customer_number                  -- CIF no
            || '|' || ''
            || '|' || 'N'                                  -- Whether the general ledger is reflected
            || '|' || '2'                                  -- Number of Entries
            || '|' || cur.operation_currency               -- transaction currency code
            || '|' || cur.operation_amount                 -- transaction amount
            || '|' || '10'
            || '|' || ''                                   -- error code
            || '|' || ''
            ;

        l_row_detail := l_row_detail
            || '|' || 'Type2'                              -- One-to-one division
            || '|' || cst_woo_const_pkg.W_BANK_CODE        -- Bank code 'W5970'
            || '|' || ''                                   -- blank
            || '|' || '1'                                  -- Transaction processing serial number
            || '|' || to_char(l_acc_ref_date, 'yyyymmdd')  -- Accounting Reflection Day
            || '|' || 'CH'                                 -- Business classification code
            || '|' || '28'                                 -- Business Detail Separator Code
            || '|' || cur.agent_number
                   || cur.account_number
                   || cur.operation_currency               -- business reference number
            || '|' || nvl(cur.card_number, cur.account_number) -- old business reference number
            || '|' || substr(cur.credit_account, 1, 3)     -- accounting branch code
            || '|' || 'NON'
            || '|' || substr(cur.credit_account, 4, length(cur.credit_account)-3) -- gl account code
            || '|' || cur.credit_currency
            || '|' || 'CR'                                 -- Debit and credit classification code
            || '|' || cur.credit_amount                    -- accounting entry amount
            || '|' || '1'
            || '|' || ''
            || '|' || '1'
            || '|' || ''
            || '|' || '0'
            || '|' || ''
            || '|' || ''
            || '|' || get_bunch_name(cur.bunch_id)         -- Journal entry description
            || '|' || 'Y'                                  -- Whether automatic signing
            || '|' || '0'
            || '|' || ''
            || '|' || '10'
            || '|' || ''
            ;

        l_row_detail := l_row_detail
            || '|' || 'Type2'                              -- One-to-one division
            || '|' || cst_woo_const_pkg.W_BANK_CODE        -- Bank code 'W5970'
            || '|' || ''                                   -- blank
            || '|' || '2'                                  -- Transaction processing serial number
            || '|' || to_char(l_acc_ref_date, 'yyyymmdd')  -- Accounting Reflection Day
            || '|' || 'CH'                                 -- Business classification code
            || '|' || '28'                                 -- Business Detail Separator Code
            || '|' || cur.agent_number
                   || cur.account_number
                   || cur.operation_currency               -- business reference number
            || '|' || nvl(cur.card_number, cur.account_number) -- old business reference number
            || '|' || substr(cur.debit_account, 1, 3)      -- accounting branch code FROM API
            || '|' || 'NON'
            || '|' || substr(cur.debit_account, 4, length(cur.debit_account)-3) -- gl account code FROM API
            || '|' || cur.debit_currency
            || '|' || 'DR'                                 -- Debit and credit classification code
            || '|' || cur.debit_amount                     -- accounting entry amount
            || '|' || '1'                                  -- Exchange rate
            || '|' || ''
            || '|' || '1'                                  -- Base currency conversion rate
            || '|' || ''
            || '|' || '0'                                  -- Selling rate of Headquarters pojisyeonbon
            || '|' || ''
            || '|' || ''
            || '|' || get_bunch_name(cur.bunch_id)         -- Journal entry description
            || '|' || 'Y'                                  -- Whether automatic signing
            || '|' || '0'                                  -- peristalsis Number of processing
            || '|' || ''
            || '|' || '10'                                 -- Status Separator Code
            || '|' || ''                                   -- Global ID
            ;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => l_row_detail
        );

        l_row_detail := null;

        l_record_number := l_record_number + 1;

        l_processed_count := l_processed_count + 1;

        prc_api_stat_pkg.increase_current(l_processed_count, l_excepted_count);

    exception
        when others then
            l_excepted_count := l_excepted_count + 1;

            prc_api_stat_pkg.increase_current(l_processed_count, l_excepted_count);

            trc_log_pkg.error(
                i_text          => 'Record [#1] was not exported for reason of '
              , i_env_param1    => l_record_number
            );
    end;
    end loop;

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_rejected_total    => l_rejected_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to savepoint export_start;

        prc_api_stat_pkg.log_end(
            i_processed_total   => l_processed_count
          , i_excepted_total    => l_excepted_count
          , i_rejected_total    => l_rejected_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

        raise;
end export_file_53;

/*
 * This file is exported for only these bunch ID:
      7080, 7084, 7105, 7106, 7118
    , 7119, 7140, 7143, 7144, 7152
    , 7156, 7171, 7172, 7179, 7180
 *  If date input parameter exist, the date/time period must be
 *  from 6:00PM of parameter date's 1 previous date to 6:00PM of parameter date.
 *  If date input paremeter not exist, the date/time period must be
 *   from 6:00 PM of 1 previous date of sysdate to 6:00PM of sysdate.
 */
procedure export_file_53_1(
    i_inst_id           in com_api_type_pkg.t_inst_id
  , i_end_date          in      date    default null
)
is
    l_file_params       com_api_type_pkg.t_param_tab;

    l_session_file_id   prc_session_file.id%type;
    l_process_id        prc_session.process_id%type;
    l_file_name         prc_session_file.file_name%type;
    l_sysdate           date;

    l_row_header        com_api_type_pkg.t_text;
    l_row_detail        com_api_type_pkg.t_text;

    l_record_number     com_api_type_pkg.t_short_id  default 1;

    l_file_count        com_api_type_pkg.t_short_id  default 1;
    l_estimated_count   com_api_type_pkg.t_short_id  default 0;
    l_processed_count   com_api_type_pkg.t_short_id  default 0;
    l_rejected_count    com_api_type_pkg.t_short_id  default 0;
    l_excepted_count    com_api_type_pkg.t_short_id  default 0;

    l_estimated_sum     com_api_type_pkg.t_long_id   default 0;
    l_start_date        date;
    l_end_date          date;

begin --main

    savepoint export_start;

    g_sysdate := trunc(get_sysdate);

    l_end_date := nvl(i_end_date, get_sysdate);
    l_end_date := to_date(to_char(l_end_date, 'dd/mm/yyyy')|| ' 17:59:59', 'dd/mm/yyyy HH24:MI:SS');
        l_start_date := to_date(to_char(l_end_date - 1, 'dd/mm/yyyy')|| ' 18:00:00', 'dd/mm/yyyy HH24:MI:SS');

    trc_log_pkg.debug(
        i_text       => 'l_start_date=[#1], l_end_date=[#2]'
      , i_env_param1 => to_char(l_start_date, 'dd.mm.yyyy HH24:MI:SS')
      , i_env_param2 => to_char(l_end_date, 'dd.mm.yyyy HH24:MI:SS')
    );

    select count(operation_id) as total_operation_id
         , sum(operation_amount) as total_operation_amount
      into l_estimated_count
         , l_estimated_sum
      from (select opr.id as operation_id
                 , ent.amount as operation_amount
              from opr_participant par
              join opr_operation opr on opr.id = par.oper_id
              join acc_macros mac on mac.object_id = opr.id
               and mac.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
              join acc_entry ent on ent.macros_id = mac.id
               and ent.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER  --'BLTP0001'
              join acc_gl_account_mvw gl on gl.id = ent.account_id
              join ost_agent ag on ag.id = gl.agent_id
               --and ag.agent_number in ('001', '100', '200') -- for testing purpose
             where par.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER  -- 'PRTYISS'
               and opr.host_date between l_start_date and l_end_date
               and (exists (
                            select 1
                              from acc_bunch
                             where bunch_type_id in (
                                                      7080, 7084, 7105, 7106, 7118
                                                    , 7119, 7140, 7143, 7144, 7152
                                                    , 7156, 7171, 7172, 7179, 7180
                                                    )
                              and id = ent.bunch_id
                            )
                            or
                            opr.oper_type in (
                                                'OPTP7033' --GL Debit adjustment
                                              , 'OPTP7032' --GL credit adjustment
                                              )
                   )
          group by ag.agent_number
                 , par.customer_id
                 , par.card_id
                 , par.account_id
                 , opr.id
                 , ent.amount
                 , ent.currency
                 , ent.bunch_id
           );

    prc_api_stat_pkg.log_estimation(l_estimated_count);

    l_process_id := prc_api_session_pkg.get_process_id;

    l_file_count := get_file_count(
        i_process_id => l_process_id
      , i_start_date => g_sysdate
      , i_end_date   => g_sysdate + 1
    );

    l_file_count := l_file_count + 1;

    --O28308V_YYYYMMDD_AC053_***.dat
    l_file_name := 'O28308V_'
                || to_char(g_sysdate, 'YYYYMMDD')
                || '_AC053_'
                || lpad(l_file_count, 3, '0')
                || '.dat';

    prc_api_file_pkg.open_file(
        o_sess_file_id => l_session_file_id
      , i_file_name    => l_file_name
    );

    trc_log_pkg.debug(
        i_text       => 'File [#1] with id [#2] is opened'
      , i_env_param1 => l_file_name
      , i_env_param2 => l_session_file_id
    );

    l_row_header := 'HEADER'
                || '|' || 'O28308V'
                || '|' || to_char(l_end_date, 'yyyymmdd')
                || '|' || lpad(l_file_count, 3, '0')
                || '|' || l_estimated_sum
                || '|' || l_estimated_count
    ;

    prc_api_file_pkg.put_line(
        i_sess_file_id  => l_session_file_id
      , i_raw_data  => l_row_header
    );

    for cur in (
        select agent_number, customer_number, card_number, account_number
             , operation_id, operation_amount, bunch_id
             , com_api_currency_pkg.get_currency_name(operation_currency) as operation_currency
             , case when credit_account  < 0 then null
                    else cst_woo_prc_reporting_pkg.get_account_number(abs(credit_account))
                end as credit_account
             , case when debit_account   > 0 then null
                    else cst_woo_prc_reporting_pkg.get_account_number(abs(debit_account))
                end as debit_account
             , case when credit_amount   < 0 then null
                    else abs(credit_amount)
                end as credit_amount
             , case when debit_amount    > 0 then null
                    else abs(debit_amount)
                end as debit_amount
             , case when credit_currency < 0 then null
                    else com_api_currency_pkg.get_currency_name(abs(credit_currency))
               end as credit_currency
             , case when debit_currency  > 0 then null
                    else com_api_currency_pkg.get_currency_name(abs(debit_currency))
               end as debit_currency

        from (select ag.agent_number
                   , prd_api_customer_pkg.get_customer_number(par.customer_id) as customer_number
                   , iss_api_card_pkg.get_card_number(par.card_id) as card_number
                   , cst_woo_prc_reporting_pkg.get_account_number(par.account_id) as account_number
                   , opr.id            as operation_id
                   , ent.amount        as operation_amount
                   , ent.currency      as operation_currency
                   , ent.bunch_id      as bunch_id
                   , max(ent.account_id * ent.balance_impact) as credit_account
                   , min(ent.account_id * ent.balance_impact) as debit_account
                   , max(ent.amount * ent.balance_impact) as credit_amount
                   , min(ent.amount * ent.balance_impact) as debit_amount
                   , max(ent.currency * ent.balance_impact) as credit_currency
                   , min(ent.currency * ent.balance_impact) as debit_currency
                from opr_participant par
                join opr_operation opr on opr.id = par.oper_id
                join acc_macros mac on mac.object_id = opr.id
                 and mac.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
                join acc_entry ent on ent.macros_id = mac.id
                 and ent.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER  --'BLTP0001'
                join acc_gl_account_mvw gl on gl.id = ent.account_id
                join ost_agent ag on ag.id = gl.agent_id
                 --and ag.agent_number in ('001', '100', '200') -- for testing purpose
               where par.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER  -- 'PRTYISS'
                 and opr.host_date between l_start_date and l_end_date
                 and (exists (
                              select 1
                                from acc_bunch
                               where bunch_type_id in (
                                                        7080, 7084, 7105, 7106, 7118
                                                      , 7119, 7140, 7143, 7144, 7152
                                                      , 7156, 7171, 7172, 7179, 7180
                                                      )
                                and id = ent.bunch_id
                              )
                              or
                              opr.oper_type in (
                                                  'OPTP7033' --GL Debit adjustment
                                                , 'OPTP7032' --GL credit adjustment
                                                )
                      )
               group by ag.agent_number
                      , par.customer_id
                      , par.card_id
                      , par.account_id
                      , opr.id
                      , ent.amount
                      , ent.currency
                      , ent.bunch_id
             )
    ) loop
    begin

        l_row_detail := l_row_detail
                   || lpad(l_record_number, 9, '0')        -- data seq
            || '|' || 'Type1'                              -- Daily account common usage area
            || '|' || cst_woo_const_pkg.W_BANK_CODE        -- Bank code 'W5970'
            || '|' || ''                                   -- Journal Global ID
            || '|' || cur.agent_number                     -- sv agency ID
            || '|' || to_char(g_sysdate, 'yyyymmdd')       -- file generated date YYYYMMDD
            || '|' || ''                                   -- document number
            || '|' || 'CH'                                 -- Business classification code
            || '|' || cur.account_number                   -- business reference number
            || '|' || ''                                   -- transaction code
            || '|' || 'B'                                  -- constant
            || '|' || to_char(l_end_date, 'yyyymmdd')      -- Accounting Reflection Day
            || '|' || ''
            || '|' || ''
            || '|' || ''
            || '|' || ''
            || '|' || ''
            || '|' || '0'
            || '|' || cur.operation_id                     -- Original Transaction Global ID
            || '|' || ''
            || '|' || nvl(cur.card_number, cur.account_number) -- Related reference number
            || '|' || 'Y'
            || '|' || cur.customer_number                  -- CIF no
            || '|' || ''
            || '|' || 'N'                                  -- Whether the general ledger is reflected
            || '|' || '2'                                  -- Number of Entries
            || '|' || cur.operation_currency               -- transaction currency code
            || '|' || cur.operation_amount                 -- transaction amount
            || '|' || '10'
            || '|' || ''                                   -- error code
            || '|' || ''
            ;

        l_row_detail := l_row_detail
            || '|' || 'Type2'                              -- One-to-one division
            || '|' || cst_woo_const_pkg.W_BANK_CODE        -- Bank code 'W5970'
            || '|' || ''                                   -- blank
            || '|' || '1'                                  -- Transaction processing serial number
            || '|' || to_char(l_end_date, 'yyyymmdd')      -- Accounting Reflection Day
            || '|' || 'CH'                                 -- Business classification code
            || '|' || '28'                                 -- Business Detail Separator Code
            || '|' || cur.agent_number
                   || cur.account_number
                   || cur.operation_currency               -- business reference number
            || '|' || nvl(cur.card_number, cur.account_number) -- old business reference number
            || '|' || substr(cur.credit_account, 1, 3)     -- accounting branch code
            || '|' || 'NON'
            || '|' || substr(cur.credit_account, 4, length(cur.credit_account)-3) -- gl account code
            || '|' || cur.credit_currency
            || '|' || 'CR'                                 -- Debit and credit classification code
            || '|' || cur.credit_amount                    -- accounting entry amount
            || '|' || '1'
            || '|' || ''
            || '|' || '1'
            || '|' || ''
            || '|' || '0'
            || '|' || ''
            || '|' || ''
            || '|' || get_bunch_name(cur.bunch_id)         -- Journal entry description
            || '|' || 'Y'                                  -- Whether automatic signing
            || '|' || '0'
            || '|' || ''
            || '|' || '10'
            || '|' || ''
            ;

        l_row_detail := l_row_detail
            || '|' || 'Type2'                              -- One-to-one division
            || '|' || cst_woo_const_pkg.W_BANK_CODE        -- Bank code 'W5970'
            || '|' || ''                                   -- blank
            || '|' || '2'                                  -- Transaction processing serial number
            || '|' || to_char(l_end_date, 'yyyymmdd')      -- Accounting Reflection Day
            || '|' || 'CH'                                 -- Business classification code
            || '|' || '28'                                 -- Business Detail Separator Code
            || '|' || cur.agent_number
                   || cur.account_number
                   || cur.operation_currency               -- business reference number
            || '|' || nvl(cur.card_number, cur.account_number) -- old business reference number
            || '|' || substr(cur.debit_account, 1, 3)      -- accounting branch code FROM API
            || '|' || 'NON'
            || '|' || substr(cur.debit_account, 4, length(cur.debit_account)-3) -- gl account code FROM API
            || '|' || cur.debit_currency
            || '|' || 'DR'                                 -- Debit and credit classification code
            || '|' || cur.debit_amount                     -- accounting entry amount
            || '|' || '1'                                  -- Exchange rate
            || '|' || ''
            || '|' || '1'                                  -- Base currency conversion rate
            || '|' || ''
            || '|' || '0'                                  -- Selling rate of Headquarters pojisyeonbon
            || '|' || ''
            || '|' || ''
            || '|' || get_bunch_name(cur.bunch_id)         -- Journal entry description
            || '|' || 'Y'                                  -- Whether automatic signing
            || '|' || '0'                                  -- peristalsis Number of processing
            || '|' || ''
            || '|' || '10'                                 -- Status Separator Code
            || '|' || ''                                   -- Global ID
            ;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => l_row_detail
        );

        l_row_detail := null;

        l_record_number := l_record_number + 1;

        l_processed_count := l_processed_count + 1;

        prc_api_stat_pkg.increase_current(l_processed_count, l_excepted_count);

    exception
        when others then
            l_excepted_count := l_excepted_count + 1;

            prc_api_stat_pkg.increase_current(l_processed_count, l_excepted_count);

            trc_log_pkg.error(
                i_text          => 'Record [#1] was not exported for reason of '
              , i_env_param1    => l_record_number
            );
    end;
    end loop;

    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_session_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_rejected_total    => l_rejected_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to savepoint export_start;

        prc_api_stat_pkg.log_end(
            i_processed_total   => l_processed_count
          , i_excepted_total    => l_excepted_count
          , i_rejected_total    => l_rejected_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

        raise;
end export_file_53_1;

end cst_woo_prc_reporting_pkg;
/
