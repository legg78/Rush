create or replace package atm_ui_scenario_encoding_pkg as
/*********************************************************
 * User Interface for ATM encodings <br>
 * Created by Necheukhin I.(necheukhin@bpcbt.com)  at 20.12.2012  <br>
 * Last changed by $Author: necheukhin $ <br>
 * $LastChangedDate:: 2012-12-20 15:00:03 +0400#$  <br>
 * Revision: $LastChangedRevision: 6830 $ <br>
 * Module: atm_ui_scenario_encoding_pkg <br>
 * @headcom
 **********************************************************/

procedure add_encoding (
    o_id                     out  com_api_type_pkg.t_tiny_id
  , o_seqnum                 out  com_api_type_pkg.t_seqnum
  , i_atm_scenario_id     in      com_api_type_pkg.t_tiny_id
  , i_lang                in      com_api_type_pkg.t_dict_value
  , i_reciept_encoding    in      com_api_type_pkg.t_name
  , i_screen_encoding     in      com_api_type_pkg.t_name
);

procedure modify_encoding (
    i_id                  in      com_api_type_pkg.t_tiny_id
  , io_seqnum             in out  com_api_type_pkg.t_seqnum
  , i_atm_scenario_id     in      com_api_type_pkg.t_tiny_id
  , i_lang                in      com_api_type_pkg.t_dict_value
  , i_reciept_encoding    in      com_api_type_pkg.t_name      
  , i_screen_encoding     in      com_api_type_pkg.t_name      
);
    
procedure remove_encoding (
    i_id                  in      com_api_type_pkg.t_tiny_id
  , i_seqnum              in      com_api_type_pkg.t_seqnum  
);

end atm_ui_scenario_encoding_pkg;
/