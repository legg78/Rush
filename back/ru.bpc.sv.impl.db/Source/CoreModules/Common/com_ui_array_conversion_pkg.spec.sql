create or replace package com_ui_array_conversion_pkg is
/*********************************************************
*  UI for array types<br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 01.07.2011 <br />
*  Last changed by $Author: fomichev$ <br />
*  $LastChangedDate:: 2011-07-01 13:31:16 +0400#$ <br />
*  Revision: $LastChangedRevision: 10600 $ <br />
*  Module: com_ui_array_type_pkg <br />
*  @headcom
**********************************************************/

procedure add_array_conversion (
    o_id               out  com_api_type_pkg.t_tiny_id
  , o_seqnum           out  com_api_type_pkg.t_seqnum
  , i_in_array_id   in      com_api_type_pkg.t_tiny_id
  , i_in_lov_id     in      com_api_type_pkg.t_tiny_id
  , i_out_array_id  in      com_api_type_pkg.t_tiny_id
  , i_out_lov_id    in      com_api_type_pkg.t_tiny_id
  , i_conv_type     in      com_api_type_pkg.t_dict_value
  , i_lang          in      com_api_type_pkg.t_dict_value
  , i_label         in      com_api_type_pkg.t_name
  , i_description   in      com_api_type_pkg.t_full_desc
);

procedure modify_array_conversion (
    i_id            in      com_api_type_pkg.t_tiny_id
  , io_seqnum       in out  com_api_type_pkg.t_seqnum
  , i_in_array_id   in      com_api_type_pkg.t_short_id
  , i_in_lov_id     in      com_api_type_pkg.t_tiny_id
  , i_out_array_id  in      com_api_type_pkg.t_short_id
  , i_out_lov_id    in      com_api_type_pkg.t_tiny_id
  , i_conv_type     in      com_api_type_pkg.t_dict_value
  , i_lang          in      com_api_type_pkg.t_dict_value
  , i_label         in      com_api_type_pkg.t_name
  , i_description   in      com_api_type_pkg.t_full_desc
);

procedure remove_array_conversion (
    i_id            in      com_api_type_pkg.t_tiny_id
  , i_seqnum        in      com_api_type_pkg.t_seqnum
);

end;
/
