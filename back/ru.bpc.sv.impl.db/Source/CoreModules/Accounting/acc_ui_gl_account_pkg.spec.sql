create or replace package acc_ui_gl_account_pkg is
/********************************************************* 
 *  UI for GL Accounts   <br /> 
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 19.03.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module:g  <br /> 
 *  @headcom 
 **********************************************************/ 
procedure create_gl_accounts (
    i_entity_type     in     com_api_type_pkg.t_dict_value
  , i_currency        in     com_api_type_pkg.t_curr_code
  , i_object_id       in     com_api_type_pkg.t_short_id
);
    
procedure create_gl_account (
    o_id                 out com_api_type_pkg.t_medium_id
  , io_account_number in out com_api_type_pkg.t_account_number
  , i_entity_type     in     com_api_type_pkg.t_dict_value
  , i_account_type    in     com_api_type_pkg.t_dict_value
  , i_currency        in     com_api_type_pkg.t_curr_code
  , i_object_id       in     com_api_type_pkg.t_short_id
);
    
procedure remove_gl_account(
    i_account_id      in     com_api_type_pkg.t_medium_id
  , i_split_hash      in     com_api_type_pkg.t_tiny_id      default null
);
    
end; 
/
