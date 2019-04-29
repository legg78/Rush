create or replace package body csm_api_process_pkg as
/**************************************************
 *  Case dispute process API <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com) at 19.01.2018 <br />
 *  Module: CSM_API_PROCESS_PKG <br />
 *  @headcom
 ***************************************************/

procedure process_hide_unhide_case
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_hide_unhide_case';
    l_sysdate                   date;
    l_seqnum                    com_api_type_pkg.t_tiny_id;
begin
    l_sysdate := trunc(com_api_sttl_day_pkg.get_sysdate);
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with l_sysdate [' || to_char(l_sysdate, 'DD.MM.YYYY') || ']'
    );

    for v_hide in (
        select c.id as case_id
             , a.seqnum
          from csm_case c
             , app_application a
         where c.id           = a.id
           and a.is_visible   = com_api_const_pkg.TRUE
           and c.hide_date   <= l_sysdate
    ) loop
        l_seqnum := v_hide.seqnum;
        
        csm_ui_case_pkg.change_case_visibility(
            i_case_id     => v_hide.case_id
          , io_seqnum     => l_seqnum
          , i_is_visible  => com_api_const_pkg.FALSE
          , i_start_date  => l_sysdate
        );
    end loop;

    for v_unhide in (
        select c.id as case_id
             , a.seqnum
          from csm_case c
             , app_application a
         where c.id           = a.id
           and a.is_visible   = com_api_const_pkg.FALSE
           and c.unhide_date <= l_sysdate
    ) loop
        l_seqnum := v_unhide.seqnum;
        
        csm_ui_case_pkg.change_case_visibility(
            i_case_id     => v_unhide.case_id
          , io_seqnum     => l_seqnum
          , i_is_visible  => com_api_const_pkg.TRUE
          , i_start_date  => l_sysdate
        );
    end loop;

end process_hide_unhide_case;

end;
/
