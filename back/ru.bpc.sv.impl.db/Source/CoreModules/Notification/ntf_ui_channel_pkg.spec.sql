create or replace package ntf_ui_channel_pkg is
/********************************************************* 
 *  UI for notification channels <br /> 
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 16.09.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: ntf_ui_channel_pkg <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_channel (
    o_id                  out  com_api_type_pkg.t_tiny_id
  , i_address_pattern  in      com_api_type_pkg.t_name
  , i_mess_max_length  in      com_api_type_pkg.t_tiny_id
  , i_address_source   in      com_api_type_pkg.t_full_desc
  , i_lang             in      com_api_type_pkg.t_dict_value
  , i_name             in      com_api_type_pkg.t_name
  , i_description      in      com_api_type_pkg.t_full_desc
);

procedure modify_channel (
    i_id               in     com_api_type_pkg.t_tiny_id
  , i_address_pattern  in     com_api_type_pkg.t_name
  , i_mess_max_length  in     com_api_type_pkg.t_tiny_id
  , i_address_source   in     com_api_type_pkg.t_full_desc
  , i_lang             in     com_api_type_pkg.t_dict_value
  , i_name             in     com_api_type_pkg.t_name
  , i_description      in     com_api_type_pkg.t_full_desc
);

procedure remove_channel (
    i_id               in        com_api_type_pkg.t_tiny_id
);

end; 
/
