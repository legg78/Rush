create or replace package body frp_ui_suite_pkg as

procedure add_suite(
    o_id              out  com_api_type_pkg.t_tiny_id
  , o_seqnum          out  com_api_type_pkg.t_seqnum
  , i_entity_type  in      com_api_type_pkg.t_dict_value
  , i_inst_id      in      com_api_type_pkg.t_inst_id
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
) is
begin

    o_id := frp_suite_seq.nextval;
    o_seqnum := 1;

    insert into frp_suite_vw(
        id
      , seqnum
      , entity_type
      , inst_id
    ) values (
        o_id
      , o_seqnum
      , i_entity_type
      , i_inst_id
    );

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_suite'
          , i_column_name   => 'label'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_suite'
          , i_column_name   => 'description'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;

end;

procedure modify_suite(
    i_id           in      com_api_type_pkg.t_tiny_id
  , io_seqnum      in out  com_api_type_pkg.t_seqnum
  , i_entity_type  in      com_api_type_pkg.t_dict_value
  , i_inst_id      in      com_api_type_pkg.t_inst_id
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
) is
    l_event_type        com_api_type_pkg.t_dict_value;
begin
    update frp_suite_vw
       set seqnum      = io_seqnum
         , entity_type = i_entity_type
         , inst_id     = i_inst_id
     where id          = i_id;

    io_seqnum := io_seqnum + 1;

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_suite'
          , i_column_name   => 'label'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_suite'
          , i_column_name   => 'description'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;


end;

procedure remove_suite(
    i_id           in      com_api_type_pkg.t_tiny_id
  , i_seqnum       in      com_api_type_pkg.t_seqnum
) is
begin
    update frp_suite_vw
       set seqnum  = i_seqnum
     where id      = i_id;

    delete frp_suite_vw
     where id      = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name        => 'frp_suite'
      , i_object_id         => i_id
    );

    update frp_suite_object_vw
       set seqnum   = seqnum + 1
     where suite_id = i_id;

    delete frp_suite_object_vw
     where suite_id = i_id;
end;

procedure add_suite_object(
    o_suite_object_id      out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_suite_id          in      com_api_type_pkg.t_tiny_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_start_date        in      date
  , i_end_date          in      date
) is
begin
    o_suite_object_id := frp_suite_object_seq.nextval;
    o_seqnum := 1;

    insert into frp_suite_object_vw(
        id
      , seqnum
      , suite_id
      , entity_type
      , object_id
      , start_date
      , end_date
    ) values (
        o_suite_object_id
      , o_seqnum
      , i_suite_id
      , i_entity_type
      , i_object_id
      , nvl(i_start_date, get_sysdate)
      , i_end_date
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'SUITE_IS_NOT_UNIQUE'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
          , i_env_param3 => i_start_date
        );
end;

procedure modify_suite_object(
    i_suite_object_id   in      com_api_type_pkg.t_long_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_end_date          in      date
) is
begin
    update frp_suite_object_vw
       set seqnum   = io_seqnum
         , end_date = i_end_date
     where id       = i_suite_object_id;

    io_seqnum := io_seqnum + 1;
end;

procedure remove_suite_object(
    i_suite_object_id   in      com_api_type_pkg.t_long_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update frp_suite_object_vw
       set seqnum   = i_seqnum
     where id       = i_suite_object_id;

    delete frp_suite_object_vw
     where id       = i_suite_object_id;
end;

end;
/
