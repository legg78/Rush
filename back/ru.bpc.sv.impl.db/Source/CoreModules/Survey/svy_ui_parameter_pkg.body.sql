create or replace package body svy_ui_parameter_pkg is

procedure add(
    o_id                 out com_api_type_pkg.t_medium_id
  , o_seqnum             out com_api_type_pkg.t_tiny_id
  , i_param_name      in     com_api_type_pkg.t_oracle_name
  , i_data_type       in     com_api_type_pkg.t_dict_value
  , i_display_order   in     com_api_type_pkg.t_tiny_id
  , i_lov_id          in     com_api_type_pkg.t_tiny_id
  , i_is_multi_select in     com_api_type_pkg.t_boolean
  , i_name            in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_name
  , i_lang            in     com_api_type_pkg.t_dict_value
) is
begin
    o_id     := svy_parameter_seq.nextval;
    o_seqnum := 1;

    insert into svy_parameter_vw (
        id
      , seqnum
      , param_name
      , data_type
      , display_order
      , lov_id
      , is_multi_select
      , is_system_param
      , table_name
    ) values (
        o_id
      , o_seqnum
      , i_param_name
      , i_data_type
      , i_display_order
      , i_lov_id
      , nvl(i_is_multi_select, com_api_const_pkg.FALSE)
      , com_api_const_pkg.FALSE
      , null
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'svy_parameter'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_text         => i_name
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'svy_parameter'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
end add;

procedure modify(
    i_id              in     com_api_type_pkg.t_medium_id
  , io_seqnum         in out com_api_type_pkg.t_tiny_id
  , i_param_name      in     com_api_type_pkg.t_oracle_name
  , i_data_type       in     com_api_type_pkg.t_dict_value
  , i_display_order   in     com_api_type_pkg.t_tiny_id
  , i_lov_id          in     com_api_type_pkg.t_tiny_id
  , i_is_multi_select in     com_api_type_pkg.t_boolean
  , i_name            in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_name
  , i_lang            in     com_api_type_pkg.t_dict_value
) is
begin
    update svy_parameter_vw
       set seqnum          = io_seqnum
         , param_name      = i_param_name
         , data_type       = i_data_type
         , display_order   = i_display_order
         , lov_id          = i_lov_id
         , is_multi_select = i_is_multi_select
     where id              = i_id;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'svy_parameter'
      , i_column_name  => 'name'
      , i_object_id    => i_id
      , i_text         => i_name
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'svy_parameter'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    io_seqnum := io_seqnum + 1;
end modify;

procedure remove(
    i_id              in     com_api_type_pkg.t_medium_id
) is
begin
    delete svy_parameter_vw
     where id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'svy_parameter'
      , i_object_id  => i_id
    );
end remove;

end svy_ui_parameter_pkg;
/
