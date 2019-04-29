create or replace package com_ui_mcc_pkg as
/********************************************************* 
 *  Acquiring application API  <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 12.10.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: com_ui_mcc_pkg <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_mcc(
    o_id                     out  com_api_type_pkg.t_medium_id
  , o_seqnum                 out  com_api_type_pkg.t_tiny_id
  , i_mcc                 in      com_api_type_pkg.t_mcc
  , i_tcc                 in      com_api_type_pkg.t_dict_value
  , i_diners_code         in      com_api_type_pkg.t_dict_value
  , i_mastercard_cab_type in      com_api_type_pkg.t_dict_value
  , i_name                in      com_api_type_pkg.t_name
  , i_lang                in      com_api_type_pkg.t_dict_value   default null
);

procedure modify_mcc(
    i_id                  in     com_api_type_pkg.t_medium_id
  , io_seqnum             in out com_api_type_pkg.t_tiny_id
  , i_mcc                 in     com_api_type_pkg.t_mcc
  , i_tcc                 in     com_api_type_pkg.t_dict_value
  , i_diners_code         in     com_api_type_pkg.t_dict_value
  , i_mastercard_cab_type in     com_api_type_pkg.t_dict_value
  , i_name                in     com_api_type_pkg.t_name
  , i_lang                in     com_api_type_pkg.t_dict_value   default null
);

procedure remove_mcc(
    i_id                  in     com_api_type_pkg.t_short_id
  , i_seqnum              in     com_api_type_pkg.t_tiny_id
);

end;
/
