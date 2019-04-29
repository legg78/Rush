create or replace package ntb_ui_note_pkg is

procedure add(
    o_id                  out com_api_type_pkg.t_long_id
  , i_entity_type         in com_api_type_pkg.t_dict_value
  , i_object_id           in com_api_type_pkg.t_long_id
  , i_note_type           in com_api_type_pkg.t_dict_value
  , i_lang                in com_api_type_pkg.t_dict_value
  , i_header              in com_api_type_pkg.t_text
  , i_text                in com_api_type_pkg.t_text
  , i_start_date          in date default null
  , i_end_date            in date default null
);

procedure move(
    i_entity_type         in com_api_type_pkg.t_dict_value
  , i_object_id_old       in com_api_type_pkg.t_long_id
  , i_object_id_new       in com_api_type_pkg.t_long_id
);

end;
/
