create or replace package body frp_ui_case_pkg as

procedure add_case(
    o_id              out  com_api_type_pkg.t_tiny_id
  , o_seqnum          out  com_api_type_pkg.t_seqnum
  , i_inst_id      in      com_api_type_pkg.t_inst_id
  , i_hist_depth   in      com_api_type_pkg.t_tiny_id
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
) is
begin
    select frp_case_seq.nextval into o_id from dual;

    o_seqnum := 1;

    insert into frp_case_vw(
        id
      , seqnum
      , inst_id
      , hist_depth
    ) values (
        o_id
      , o_seqnum
      , i_inst_id
      , i_hist_depth
    );

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_case'
          , i_column_name   => 'label'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_case'
          , i_column_name   => 'description'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
end;

procedure modify_case(
    i_id           in      com_api_type_pkg.t_tiny_id
  , io_seqnum      in out  com_api_type_pkg.t_seqnum
  , i_inst_id      in      com_api_type_pkg.t_inst_id
  , i_hist_depth   in      com_api_type_pkg.t_tiny_id
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
) is
    l_event_type   com_api_type_pkg.t_dict_value;
begin
    update frp_case_vw
       set seqnum      = io_seqnum
         , inst_id     = i_inst_id
         , hist_depth  = i_hist_depth
     where id          = i_id;

    io_seqnum := io_seqnum + 1;

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_case'
          , i_column_name   => 'label'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'frp_case'
          , i_column_name   => 'description'
          , i_object_id     => i_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
end;

procedure remove_case(
    i_id           in      com_api_type_pkg.t_tiny_id
  , i_seqnum       in      com_api_type_pkg.t_seqnum
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.remove_case: ';
    l_id_tab               com_api_type_pkg.t_short_tab;
begin
    --trc_log_pkg.debug(LOG_PREFIX || 'i_id [' || i_id || ']');

    update frp_case_vw
       set seqnum  = i_seqnum
     where id      = i_id;

    delete frp_case_vw
     where id      = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name        => 'frp_case'
      , i_object_id         => i_id
    );

    -- After deleting case it is necessary to delete its checks

    select c.id bulk collect into l_id_tab
      from frp_check_vw c
     where c.case_id = i_id;

    trc_log_pkg.debug('l_id_tab.count=' || l_id_tab.count);

    if l_id_tab.count > 0 then
        for i in l_id_tab.first .. l_id_tab.last loop
            --trc_log_pkg.debug(LOG_PREFIX || 'removing label for check with id [' || l_id_tab(i) || ']');
            com_api_i18n_pkg.remove_text(
                i_table_name        => 'frp_check'
              , i_object_id         => l_id_tab(i)
            );
        end loop;

        forall i in l_id_tab.first .. l_id_tab.last
            delete from frp_check_vw where id = l_id_tab(i);
    end if;
exception
    when others then
        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            trc_log_pkg.debug(
                i_text          => LOG_PREFIX || 'i_id [#2], i_seqnum [#3], sqlerrm [#1]'
              , i_env_param1    => sqlerrm
              , i_env_param2    => i_id
              , i_env_param3    => i_seqnum
            );
            raise;
        end if;
end;

end;
/
