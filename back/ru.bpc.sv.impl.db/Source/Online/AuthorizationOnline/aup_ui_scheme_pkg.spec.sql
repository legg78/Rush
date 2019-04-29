create or replace package aup_ui_scheme_pkg as
/********************************************************* 
 *  API for schemes in authorization online processing <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 26.04.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: aup_ui_scheme_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_scheme(
    o_scheme_id            out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_scheme_type       in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_resp_code         in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc    default null
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , i_system_name       in      com_api_type_pkg.t_name
);

procedure modify_scheme(
    i_scheme_id         in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_scheme_type       in      com_api_type_pkg.t_dict_value
  , i_resp_code         in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc    default null
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , i_system_name       in      com_api_type_pkg.t_name
);

procedure remove_scheme(
    i_scheme_id         in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure add_template(
    o_templ_id             out  com_api_type_pkg.t_short_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_templ_type        in      com_api_type_pkg.t_dict_value
  , i_resp_code         in      com_api_type_pkg.t_dict_value
  , i_condition         in      com_api_type_pkg.t_text
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_name              in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
);

procedure modify_template(
    i_templ_id          in      com_api_type_pkg.t_short_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_templ_type        in      com_api_type_pkg.t_dict_value
  , i_resp_code         in      com_api_type_pkg.t_dict_value
  , i_condition         in      com_api_type_pkg.t_text
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_name              in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
);

procedure remove_template(
    i_templ_id          in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure add_scheme_template(
    i_templ_id          in      com_api_type_pkg.t_short_id
  , i_scheme_id         in      com_api_type_pkg.t_tiny_id
);

procedure remove_scheme_template(
    i_templ_id          in      com_api_type_pkg.t_short_id
  , i_scheme_id         in      com_api_type_pkg.t_tiny_id
);

procedure add_scheme_object(
    o_scheme_object_id     out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_scheme_id         in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_start_date        in      date
  , i_end_date          in      date
);

procedure modify_scheme_object(
    i_scheme_object_id  in      com_api_type_pkg.t_long_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_end_date          in      date
);

procedure remove_scheme_object(
    i_scheme_object_id  in      com_api_type_pkg.t_long_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

end;
/