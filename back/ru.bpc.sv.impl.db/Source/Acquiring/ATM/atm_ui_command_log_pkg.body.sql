create or replace package body atm_ui_command_log_pkg is
/************************************************************
 * User interface for ATM command log <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.05.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: atm_ui_command_log_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_command_log (
        i_terminal_id               in com_api_type_pkg.t_short_id
        , i_command                 in com_api_type_pkg.t_dict_value
        , i_command_result          in com_api_type_pkg.t_dict_value
    ) is
    begin
        insert into atm_command_log_vw (
            terminal_id
            , user_id
            , command_date
            , command
            , command_result
        ) values (
            i_terminal_id
            , acm_api_user_pkg.get_user_id
            , com_api_sttl_day_pkg.get_sysdate
            , i_command
            , i_command_result
        );
    end;

end;
/
