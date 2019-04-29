create or replace package body svy_ui_tag_pkg is

procedure add(
    o_id               out com_api_type_pkg.t_short_id
  , o_seqnum           out com_api_type_pkg.t_tiny_id
  , i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_condition     in     com_api_type_pkg.t_full_desc
  , i_name          in     com_api_type_pkg.t_name
  , i_description   in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
) is
begin
    o_id     := svy_tag_seq.nextval;
    o_seqnum := 1;

    insert into svy_tag_vw (
        id
      , seqnum
      , inst_id
      , entity_type
      , condition
    ) values (
        o_id
      , o_seqnum
      , i_inst_id
      , i_entity_type
      , i_condition
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'svy_tag'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_text         => i_name
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'svy_tag'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
end add;

procedure modify(
    i_id            in     com_api_type_pkg.t_short_id
  , io_seqnum       in out com_api_type_pkg.t_tiny_id
  , i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_condition     in     com_api_type_pkg.t_full_desc
  , i_name          in     com_api_type_pkg.t_name
  , i_description   in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
) is
begin
    update svy_tag_vw
       set seqnum        = io_seqnum
         , inst_id       = i_inst_id
         , entity_type   = i_entity_type
         , condition     = i_condition
     where id            = i_id;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'svy_tag'
      , i_column_name  => 'name'
      , i_object_id    => i_id
      , i_text         => i_name
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'svy_tag'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    io_seqnum := io_seqnum + 1;
end modify;

procedure remove(
    i_id            in     com_api_type_pkg.t_short_id
) is
begin
    delete svy_tag_vw
     where id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'svy_tag'
      , i_object_id  => i_id
    );
end remove;

end svy_ui_tag_pkg;
/
