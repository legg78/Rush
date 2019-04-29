create or replace package body cst_ap_api_process_pkg is
/************************************************************
 * API for various processing AP <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com)  at 10.03.2019 <br />
 * Last changed by $Author: Gogolev I. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_ap_api_process_pkg <br />
 * @headcom
 ***********************************************************/
procedure insert_into_ap_synt_tab(
    i_ap_synt_tab         in  cst_ap_api_type_pkg.t_synt_file_tab
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.insert_into_ap_synt_tab: ';
    l_total               com_api_type_pkg.t_long_id := 0;
begin
    if i_ap_synt_tab.count > 0 then
        forall i in i_ap_synt_tab.first .. i_ap_synt_tab.last
            insert into cst_ap_synt(
                id
              , session_file_id
              , file_type
              , session_day
              , opr_type
              , bank_id
              , oper_cnt
              , oper_amount
              , balance_impact
            )
            values(
                com_api_id_pkg.get_id(
                    i_seq => cst_ap_synt_seq.nextval
                )
              , i_ap_synt_tab(i).session_file_id
              , i_ap_synt_tab(i).file_type
              , i_ap_synt_tab(i).session_day
              , i_ap_synt_tab(i).opr_type
              , i_ap_synt_tab(i).bank_id
              , i_ap_synt_tab(i).oper_cnt
              , i_ap_synt_tab(i).oper_amount
              , i_ap_synt_tab(i).balance_impact
            );
        l_total := sql%rowcount;
    end if;
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' results - total count [#1]' 
      , i_env_param1 => l_total
    );
end insert_into_ap_synt_tab;

procedure insert_into_ap_session_tab(
    i_date_text         in  com_api_type_pkg.t_attr_name
  , i_format_date       in  com_api_type_pkg.t_attr_name    default FORMAT_DATE_DTGEN
  , i_add_time_text     in  com_api_type_pkg.t_attr_name    default VALUE_ADD_TIME_DEF
  , i_format_time       in  com_api_type_pkg.t_attr_name    default FORMAT_ADD_TIME_DEF
  , i_session_file_id   in  com_api_type_pkg.t_long_id
) is
    LOG_PREFIX                      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.insert_into_ap_session_tab: ';
    RIGHT_CNT_REAL_SESS_RECORDS     constant com_api_type_pkg.t_sign := 2;
    
    l_count               com_api_type_pkg.t_long_id := 0;
    l_session_date        date;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' start with params date [#1] date format [#2] added time [#3] time format [#4] session file [#5]' 
      , i_env_param1 => i_date_text
      , i_env_param2 => i_format_date
      , i_env_param3 => i_add_time_text
      , i_env_param4 => i_format_time
      , i_env_param5 => i_session_file_id
    );
    
    l_session_date :=
        to_date(
            i_date_text || i_add_time_text
          , i_format_date || i_format_time
        );
        
    select count(*)
      into l_count
      from cst_ap_session c
     where c.end_date  = l_session_date;
     
    if l_count = com_api_const_pkg.FALSE then
        update cst_ap_session
           set end_date        = decode(status, cst_ap_api_const_pkg.SESSION_FUTURE, l_session_date, end_date)
             , status          = decode(
                                     status
                                   , cst_ap_api_const_pkg.SESSION_ACTIVE
                                   , cst_ap_api_const_pkg.SESSION_CLOSE
                                   , cst_ap_api_const_pkg.SESSION_FUTURE
                                   , cst_ap_api_const_pkg.SESSION_ACTIVE
                                   , status
                                 )
             , session_file_id = decode(status, cst_ap_api_const_pkg.SESSION_FUTURE, i_session_file_id, session_file_id)
         where status in (
                   cst_ap_api_const_pkg.SESSION_ACTIVE
                 , cst_ap_api_const_pkg.SESSION_FUTURE
               );
               
        insert into cst_ap_session(
            id
          , start_date
          , end_date
          , status
          , session_file_id
        )
        values(
            cst_ap_session_seq.nextval
          , l_session_date
          , null
          , cst_ap_api_const_pkg.SESSION_FUTURE
          , null
        );
        
        select count(*)
          into l_count
          from cst_ap_session
         where status in (
                   cst_ap_api_const_pkg.SESSION_ACTIVE
                 , cst_ap_api_const_pkg.SESSION_FUTURE
               )
          and  (end_date = l_session_date or end_date is null);
               
        if l_count = RIGHT_CNT_REAL_SESS_RECORDS then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ' session records was be success synchronized for session file [#1]' 
              , i_env_param1 => i_session_file_id
            );
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'WRONG_COUNT_REAL_SESSIONS'
              , i_env_param1 => RIGHT_CNT_REAL_SESS_RECORDS
              , i_env_param2 => l_count
              , i_env_param3 => l_session_date
            );
        end if;
    else
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'WRONG_COUNT_REAL_SESSIONS'
          , i_env_param1 => com_api_const_pkg.FALSE
          , i_env_param2 => l_count
          , i_env_param3 => l_session_date
        );
    end if;
    
end insert_into_ap_session_tab;

function get_ap_session_id(
    i_ap_session_status in  com_api_type_pkg.t_sign
  , i_eff_date          in  date
  , i_mask_error        in  com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_short_id
is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_ap_session_id: ';
    
    l_session_id    com_api_type_pkg.t_short_id;
    l_mask_error    com_api_type_pkg.t_boolean := nvl(i_mask_error, com_api_const_pkg.FALSE);
    
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'search ap session for status [#1], eff date [#2], mask error [#3]' 
      , i_env_param1 => i_ap_session_status
      , i_env_param2 => i_eff_date
      , i_env_param3 => i_mask_error
    );
    select s.id
      into l_session_id
      from cst_ap_session s
     where s.start_date <= i_eff_date
       and s.status      = i_ap_session_status
       and (s.end_date    > i_eff_date
            or
            s.end_date is null
           );
       
    return l_session_id;
exception
    when no_data_found then
        if l_mask_error = com_api_const_pkg.TRUE then
            return l_session_id;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'SESSION_NOT_FOUND'
            );
        end if;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => SQLERRM
        );
end get_ap_session_id;

procedure get_ap_session_date(
    i_ap_session_id     in  com_api_type_pkg.t_long_id
  , o_start_date       out  date
  , o_end_date         out  date
  , i_end_date_def      in  date    default null
)
is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_ap_session_date: ';
begin
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'search ap session dates for session_id [#1], end date default [#2]' 
      , i_env_param1 => i_ap_session_id
      , i_env_param2 => i_end_date_def
    );
    
    select s.start_date
         , nvl(s.end_date, i_end_date_def)
      into o_start_date
         , o_end_date
      from cst_ap_session s
     where s.id = i_ap_session_id;

end get_ap_session_date;

function convert_oper_type_sv_to_tp(
    i_oper_type     in  com_api_type_pkg.t_dict_value
  , i_term_type     in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_byte_id
is
begin
    return case
               when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                   and i_term_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                   then 50
               when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                   and i_term_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                   then 52
               when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                   and i_term_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                   then 2
               when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                   and i_term_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
                   then 40
               when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND
                   and i_term_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                   then 51
               when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND
                   and i_term_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                   then 55
               when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                   and i_term_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                   then 5
               when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                   and i_term_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                   then 53
               when i_oper_type = opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY
                   and i_term_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
                   then 14
               when i_oper_type = cst_ap_api_const_pkg.OPERATION_TYPE_CUSTOMS_PAYMENT
                   and i_term_type = acq_api_const_pkg.TERMINAL_TYPE_POS
                   then 54
               when i_oper_type = cst_ap_api_const_pkg.OPERATION_TYPE_CUSTOMS_PAYMENT
                   and i_term_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS
                   then 56
               else null
           end;
end convert_oper_type_sv_to_tp;

end cst_ap_api_process_pkg;
/
