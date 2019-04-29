create or replace package aup_api_scheme_pkg as
/********************************************************* 
 *  API for Authorization online schemes <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 30.05.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: aup_api_scheme_pkg <br /> 
 *  @headcom 
 **********************************************************/

procedure check_issuing_scheme(
    i_card_id           in      com_api_type_pkg.t_medium_id
  , i_oper_date         in      date
  , i_auth_param        in      com_api_type_pkg.t_param_tab
  , o_resp_code            out  com_api_type_pkg.t_dict_value
);

procedure check_acquiring_scheme(
    i_terminal_id       in      com_api_type_pkg.t_short_id
  , i_merchant_id       in      com_api_type_pkg.t_short_id
  , i_acq_inst_id       in      com_api_type_pkg.t_inst_id
  , i_oper_date         in      date
  , i_auth_param        in      com_api_type_pkg.t_param_tab
  , o_resp_code            out  com_api_type_pkg.t_dict_value
);

procedure add_scheme_card(
    i_card_uid          in      com_api_type_pkg.t_name
  , i_card_number       in      com_api_type_pkg.t_card_number
  , i_system_name       in      com_api_type_pkg.t_name
  , i_start_date        in      date                              default null    
  , i_end_date          in      date                              default null    
);

end;
/