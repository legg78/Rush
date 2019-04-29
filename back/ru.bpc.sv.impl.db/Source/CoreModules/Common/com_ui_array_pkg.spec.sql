create or replace package com_ui_array_pkg is
/*********************************************************
*  UI for array <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 01.07.2011 <br />
*  Last changed by $Author: fomichev$ <br />
*  $LastChangedDate:: 2011-07-01 13:31:16 +0400#$ <br />
*  Revision: $LastChangedRevision: 10600 $ <br />
*  Module: com_ui_array_pkg <br />
*  @headcom
**********************************************************/
procedure add_array (
    o_id                out  com_api_type_pkg.t_short_id
  , o_seqnum            out  com_api_type_pkg.t_seqnum
  , i_array_type_id  in      com_api_type_pkg.t_tiny_id
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_label          in      com_api_type_pkg.t_name
  , i_description    in      com_api_type_pkg.t_full_desc
  , i_mod_id         in      com_api_type_pkg.t_tiny_id
  , i_agent_id       in      com_api_type_pkg.t_agent_id
  , i_is_private     in      com_api_type_pkg.t_boolean
);

procedure modify_array (
    i_id             in      com_api_type_pkg.t_short_id
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_array_type_id  in      com_api_type_pkg.t_tiny_id
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_label          in      com_api_type_pkg.t_name
  , i_description    in      com_api_type_pkg.t_full_desc
  , i_mod_id         in      com_api_type_pkg.t_tiny_id
  , i_agent_id       in      com_api_type_pkg.t_agent_id
  , i_is_private     in      com_api_type_pkg.t_boolean
);

procedure remove_array (
    i_id             in com_api_type_pkg.t_short_id
  , i_seqnum         in com_api_type_pkg.t_seqnum
);

procedure get_array_elements(
    o_ref_cur          out  sys_refcursor
  , i_array_id      in      com_api_type_pkg.t_short_id
);

procedure get_elements_where(
    i_array_id_list     in     num_tab_tpt
  , o_sql_where         out    com_api_type_pkg.t_full_desc  
);

end;
/
