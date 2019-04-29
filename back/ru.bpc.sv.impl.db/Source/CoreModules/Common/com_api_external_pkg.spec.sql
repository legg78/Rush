create or replace package com_api_external_pkg is
/*********************************************************
*  API for external interaction <br />
*  Created by Gerbeev I. (gerbeev@bpcbt.com) at 18.06.2018 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_API_EXTERNAL_PKG <br />
*  @headcom
**********************************************************/

type t_flexible_fields_rec is record (
    field_name                com_api_type_pkg.t_name
  , field_value               com_api_type_pkg.t_name
);

type t_flexible_fields_tab is table of t_flexible_fields_rec index by binary_integer;

type t_notes_rec           is record (
      note_type                 com_api_type_pkg.t_dict_value
    , lang                      com_api_type_pkg.t_dict_value
    , note_header               com_api_type_pkg.t_text
    , note_text                 com_api_type_pkg.t_text
);

type t_notes_tab is table of t_notes_rec index by binary_integer;

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default 1
  , i_field_value       in      varchar2
);

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default 1
  , i_field_value       in      number
);

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default 1
  , i_field_value       in      date
);

procedure add_person(
    io_person_id        in out  com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_person_title      in      com_api_type_pkg.t_dict_value
  , i_first_name        in      com_api_type_pkg.t_name
  , i_second_name       in      com_api_type_pkg.t_name
  , i_surname           in      com_api_type_pkg.t_name
  , i_suffix            in      com_api_type_pkg.t_dict_value
  , i_gender            in      com_api_type_pkg.t_dict_value
  , i_birthday          in      date
  , i_place_of_birth    in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id
);

procedure get_object_flexible_data(
    i_object_id      in   com_api_type_pkg.t_long_id
  , i_entity_type    in   com_api_type_pkg.t_dict_value
  , i_field_name     in   com_api_type_pkg.t_name default null
  , o_ref_cursor     out  com_api_type_pkg.t_ref_cur
);

procedure get_object_notes(
    i_object_id     in   com_api_type_pkg.t_long_id
  , i_entity_type   in   com_api_type_pkg.t_dict_value
  , i_note_type     in   com_api_type_pkg.t_dict_value default null
  , i_lang          in   com_api_type_pkg.t_dict_value default com_ui_user_env_pkg.get_user_lang
  , o_ref_cursor    out  com_api_type_pkg.t_ref_cur
);

end;
/
