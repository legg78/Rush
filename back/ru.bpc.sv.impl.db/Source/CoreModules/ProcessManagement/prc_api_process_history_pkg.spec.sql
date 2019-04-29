create or replace package prc_api_process_history_pkg as
/***************************************************************
 * The API for history processes <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 01.09.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_API_PROCESS_HISTORY_PKG <br />
 * @headcom
 ***************************************************************/

procedure add(
    i_session_id  in      com_api_type_pkg.t_long_id
  , i_param_id    in      com_api_type_pkg.t_short_id
  , i_param_value in      com_api_type_pkg.t_param_value
);

end;
/
