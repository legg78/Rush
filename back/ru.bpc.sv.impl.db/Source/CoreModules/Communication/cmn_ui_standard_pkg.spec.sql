create or replace package cmn_ui_standard_pkg as
/********************************************************* 
 *  Communication standard interface <br /> 
 *  Created by Filimonov A (filimonov@bpcbt.com)  at 12.11.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: cmn_ui_standard_pkg <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_standard(
    o_standard_id          out  com_api_type_pkg.t_tiny_id
  , i_appl_plugin       in      com_api_type_pkg.t_dict_value
  , i_resp_code_lov_id  in      com_api_type_pkg.t_tiny_id
  , i_key_type_lov_id   in      com_api_type_pkg.t_tiny_id
  , i_standard_type     in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
);

procedure modify_standard(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_appl_plugin       in      com_api_type_pkg.t_dict_value
  , i_resp_code_lov_id  in      com_api_type_pkg.t_tiny_id
  , i_key_type_lov_id   in      com_api_type_pkg.t_tiny_id
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure remove_standard(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure set_param_value_char(
  i_standard_id         in      com_api_type_pkg.t_tiny_id
  , i_version_id        in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      varchar2
);

procedure set_param_value_date(
  i_standard_id         in      com_api_type_pkg.t_tiny_id
  , i_version_id        in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      date
);

procedure set_param_value_number(
  i_standard_id         in      com_api_type_pkg.t_tiny_id
  , i_version_id        in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      number
);

procedure set_param_value_clob(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_version_id        in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_xml_value         in      clob
);

procedure remove_param_value (
  i_standard_id         in      com_api_type_pkg.t_tiny_id
  , i_version_id        in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_param_name        in      com_api_type_pkg.t_name
);

procedure remove_param_value (
  i_id                  in      com_api_type_pkg.t_short_id
);

procedure remove_param_values(
  i_object_id           in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
);

procedure add_standard_version (
    o_id                out com_api_type_pkg.t_tiny_id
    , o_seqnum          out com_api_type_pkg.t_seqnum
    , i_standard_id     in com_api_type_pkg.t_tiny_id
    , i_version_number  in com_api_type_pkg.t_name
    , i_description     in com_api_type_pkg.t_full_desc
    , i_lang            in com_api_type_pkg.t_dict_value
);

procedure modify_standard_version (
    i_id                in com_api_type_pkg.t_tiny_id  
    , io_seqnum         in out com_api_type_pkg.t_seqnum
    , i_version_number  in com_api_type_pkg.t_name
    , i_description     in com_api_type_pkg.t_full_desc
    , i_lang            in com_api_type_pkg.t_dict_value
);

procedure remove_standard_version (
    i_id                in com_api_type_pkg.t_tiny_id
    , i_seqnum          in com_api_type_pkg.t_seqnum
);

procedure move_version_up(
    i_id                in      com_api_type_pkg.t_tiny_id  
);

procedure move_version_down(
    i_id                in      com_api_type_pkg.t_tiny_id  
);
    

end;
/
