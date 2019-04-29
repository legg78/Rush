create or replace package com_ui_array_conv_elem_pkg is
/*********************************************************
*  UI for array conversion_elements<br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 01.07.2011 <br />
*  Last changed by $Author: fomichev$ <br />
*  $LastChangedDate:: 2011-07-01 13:31:16 +0400#$ <br />
*  Revision: $LastChangedRevision: 10600 $ <br />
*  Module: com_ui_array_conv_elem <br />
*  @headcom
**********************************************************/

procedure add_array_conv_elem (
    o_id                   out  com_api_type_pkg.t_short_id
  , i_conv_id           in      com_api_type_pkg.t_tiny_id
  , i_in_element_value  in      com_api_type_pkg.t_name
  , i_out_element_value in      com_api_type_pkg.t_name
);

procedure modify_array_conv_elem (
    i_id                in      com_api_type_pkg.t_short_id
  , i_conv_id           in      com_api_type_pkg.t_tiny_id
  , i_in_element_value  in      com_api_type_pkg.t_name
  , i_out_element_value in      com_api_type_pkg.t_name
);

procedure remove_array_conv_elem (
    i_id      in      com_api_type_pkg.t_short_id
);

end;
/
