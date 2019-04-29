create or replace package atm_ui_command_log_pkg is
/************************************************************
 * User interface for ATM command log <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.05.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: atm_ui_command_log_pkg <br />
 * @headcom
 ************************************************************/


/*
 * Add ATM command log
 */
    procedure add_command_log (
        i_terminal_id               in com_api_type_pkg.t_short_id
        , i_command                 in com_api_type_pkg.t_dict_value
        , i_command_result          in com_api_type_pkg.t_dict_value
    );

end;
/
