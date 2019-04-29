create or replace package com_ui_array_type_pkg is
/*********************************************************
*  UI for array types<br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 01.07.2011 <br />
*  Last changed by $Author: fomichev$ <br />
*  $LastChangedDate:: 2011-07-01 13:31:16 +0400#$ <br />
*  Revision: $LastChangedRevision: 10600 $ <br />
*  Module: com_ui_array_type_pkg <br />
*  @headcom
**********************************************************/

procedure add_array_type (
    o_id                out  com_api_type_pkg.t_tiny_id
  , o_seqnum            out  com_api_type_pkg.t_seqnum
  , i_name           in      com_api_type_pkg.t_name
  , i_is_unique      in      com_api_type_pkg.t_boolean
  , i_lov_id         in      com_api_type_pkg.t_tiny_id
  , i_entity_type    in      com_api_type_pkg.t_dict_value
  , i_data_type      in      com_api_type_pkg.t_dict_value
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_label          in      com_api_type_pkg.t_name
  , i_description    in      com_api_type_pkg.t_full_desc
  , i_scale_type     in      com_api_type_pkg.t_dict_value
  , i_class_name     in      com_api_type_pkg.t_name
);

procedure modify_array_type (
    i_id             in      com_api_type_pkg.t_tiny_id
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_name           in      com_api_type_pkg.t_name
  , i_is_unique      in      com_api_type_pkg.t_boolean
  , i_lov_id         in      com_api_type_pkg.t_tiny_id
  , i_entity_type    in      com_api_type_pkg.t_dict_value
  , i_data_type      in      com_api_type_pkg.t_dict_value
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_label          in      com_api_type_pkg.t_name
  , i_description    in      com_api_type_pkg.t_full_desc
  , i_scale_type     in      com_api_type_pkg.t_dict_value
  , i_class_name     in      com_api_type_pkg.t_name
);

procedure remove_array_type (
    i_id      in      com_api_type_pkg.t_tiny_id
  , i_seqnum  in      com_api_type_pkg.t_seqnum
);

end;
/
