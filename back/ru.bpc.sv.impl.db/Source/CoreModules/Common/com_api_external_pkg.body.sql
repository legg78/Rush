create or replace package body com_api_external_pkg is
/*********************************************************
*  API for external interaction <br />
*  Created by Gerbeev I. (gerbeev@bpcbt.com) at 18.06.2018 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_API_EXTERNAL_PKG <br />
*  @headcom
**********************************************************/

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default 1
  , i_field_value       in      varchar2
) is
begin
    com_api_flexible_data_pkg.set_flexible_value(
        i_field_name        => i_field_name
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_seq_number        => i_seq_number
      , i_field_value       => i_field_value
    );
end set_flexible_value;

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default 1
  , i_field_value       in      number
) is
begin
    com_api_flexible_data_pkg.set_flexible_value(
        i_field_name        => i_field_name
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_seq_number        => i_seq_number
      , i_field_value       => i_field_value
    );
end set_flexible_value;

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default 1
  , i_field_value       in      date
) is
begin
    com_api_flexible_data_pkg.set_flexible_value(
        i_field_name        => i_field_name
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_seq_number        => i_seq_number
      , i_field_value       => i_field_value
    );
end set_flexible_value;

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
) is
begin
    com_api_person_pkg.add_person(
        io_person_id        => io_person_id
      , i_lang              => i_lang
      , i_person_title      => i_person_title
      , i_first_name        => i_first_name
      , i_second_name       => i_second_name
      , i_surname           => i_surname
      , i_suffix            => i_suffix
      , i_gender            => i_gender
      , i_birthday          => i_birthday
      , i_place_of_birth    => i_place_of_birth
      , i_inst_id           => i_inst_id
    );
end add_person;

procedure get_object_flexible_data(
    i_object_id      in   com_api_type_pkg.t_long_id
  , i_entity_type    in   com_api_type_pkg.t_dict_value
  , i_field_name     in   com_api_type_pkg.t_name default null
  , o_ref_cursor     out  com_api_type_pkg.t_ref_cur
) is
begin
    open o_ref_cursor for
  select ff.name
       , fd.field_value
    from com_flexible_field  ff
       , com_flexible_data fd
   where ff.id          = fd.field_id
     and ff.entity_type = i_entity_type
     and fd.object_id   = i_object_id
     and ff.name        = nvl(i_field_name, ff.name);
end get_object_flexible_data;

procedure get_object_notes(
    i_object_id     in   com_api_type_pkg.t_long_id
  , i_entity_type   in   com_api_type_pkg.t_dict_value
  , i_note_type     in   com_api_type_pkg.t_dict_value default null
  , i_lang          in   com_api_type_pkg.t_dict_value default com_ui_user_env_pkg.get_user_lang
  , o_ref_cursor    out  com_api_type_pkg.t_ref_cur
) is
begin
    open o_ref_cursor for
  select n.note_type
       , l.lang
       , com_api_i18n_pkg.get_text('ntb_note', 'HEADER', n.id, l.lang) header
       , com_api_i18n_pkg.get_text('ntb_note', 'TEXT', n.id, l.lang) text
    from ntb_note n
       , com_language_vw l
   where n.object_id   = i_object_id
     and n.entity_type = i_entity_type
     and n.note_type = nvl(i_note_type, n.note_type)
     and l.lang = nvl(i_lang, l.lang);
exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end get_object_notes;

end com_api_external_pkg;
/
