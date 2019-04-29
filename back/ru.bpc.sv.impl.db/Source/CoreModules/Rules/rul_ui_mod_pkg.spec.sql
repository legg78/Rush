create or replace package rul_ui_mod_pkg is
/*********************************************************
*  UI rules <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 11.03.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: rul_ui_mod_pkg <br />
*  @headcom
**********************************************************/ 

procedure add_scale (
    o_id                    out com_api_type_pkg.t_tiny_id
  , o_seqnum                out com_api_type_pkg.t_seqnum
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_type               in     com_api_type_pkg.t_dict_value
  , i_lang               in     com_api_type_pkg.t_dict_value
  , i_name               in     com_api_type_pkg.t_name
  , i_description        in     com_api_type_pkg.t_full_desc
);

procedure modify_scale (
    i_id                 in     com_api_type_pkg.t_tiny_id
  , io_seqnum            in out com_api_type_pkg.t_seqnum
  , i_type               in     com_api_type_pkg.t_dict_value
  , i_lang               in     com_api_type_pkg.t_dict_value
  , i_name               in     com_api_type_pkg.t_name
  , i_description        in     com_api_type_pkg.t_full_desc
);

procedure remove_scale (
    i_id                 in      com_api_type_pkg.t_tiny_id
  , i_seqnum             in      com_api_type_pkg.t_seqnum
);

procedure add_param (
    o_id                    out com_api_type_pkg.t_short_id
  , i_name               in     com_api_type_pkg.t_name
  , i_data_type          in     com_api_type_pkg.t_dict_value
  , i_lov_id             in     com_api_type_pkg.t_tiny_id
  , i_lang               in     com_api_type_pkg.t_dict_value
  , i_short_description  in     com_api_type_pkg.t_name
  , i_description        in     com_api_type_pkg.t_full_desc
);

procedure modify_param (
    i_id                 in     com_api_type_pkg.t_short_id
  , i_data_type          in     com_api_type_pkg.t_dict_value
  , i_lov_id             in     com_api_type_pkg.t_tiny_id
  , i_lang               in     com_api_type_pkg.t_dict_value
  , i_short_description  in     com_api_type_pkg.t_name
  , i_description        in     com_api_type_pkg.t_full_desc
);

procedure remove_param (
    i_id                 in     com_api_type_pkg.t_short_id
);

procedure include_param_in_scale (
    i_param_id           in     com_api_type_pkg.t_tiny_id
  , i_scale_id           in     com_api_type_pkg.t_tiny_id
  , i_seqnum             in     com_api_type_pkg.t_seqnum
);

procedure remove_param_from_scale (
    i_param_id           in     com_api_type_pkg.t_tiny_id
  , i_scale_id           in     com_api_type_pkg.t_tiny_id
  , i_seqnum             in     com_api_type_pkg.t_seqnum
);

procedure add_mod (
    o_id                    out com_api_type_pkg.t_tiny_id
  , o_seqnum                out com_api_type_pkg.t_seqnum
  , i_scale_id           in     com_api_type_pkg.t_tiny_id
  , i_condition          in     com_api_type_pkg.t_text
  , i_priority           in     com_api_type_pkg.t_tiny_id
  , i_lang               in     com_api_type_pkg.t_dict_value
  , i_name               in     com_api_type_pkg.t_name
  , i_description        in     com_api_type_pkg.t_full_desc
);

procedure modify_mod (
    i_id                 in     com_api_type_pkg.t_tiny_id
  , io_seqnum            in out com_api_type_pkg.t_seqnum
  , i_condition          in     com_api_type_pkg.t_text
  , i_priority           in     com_api_type_pkg.t_tiny_id
  , i_lang               in     com_api_type_pkg.t_dict_value
  , i_name               in     com_api_type_pkg.t_name
  , i_description        in     com_api_type_pkg.t_full_desc
);

procedure remove_mod (
    i_id                 in     com_api_type_pkg.t_tiny_id
  , i_seqnum             in     com_api_type_pkg.t_seqnum
);

procedure check_mod (
    i_mod_id       in     com_api_type_pkg.t_tiny_id
  , i_scale_id     in     com_api_type_pkg.t_tiny_id
  , i_priority     in     com_api_type_pkg.t_tiny_id
  , i_name         in     com_api_type_pkg.t_name
  , i_description  in     com_api_type_pkg.t_full_desc
);

end rul_ui_mod_pkg;
/
