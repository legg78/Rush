create or replace package body prc_ui_file_pkg as
/************************************************************
 * The UI for file processes <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 02.10.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: prc_ui_file_pkg <br />
 * @headcom
 ************************************************************/

procedure add_file(
    o_id                     out  com_api_type_pkg.t_tiny_id
  , i_process_id          in      com_api_type_pkg.t_short_id
  , i_file_purpose        in      com_api_type_pkg.t_dict_value
  , i_saver_id            in      com_api_type_pkg.t_tiny_id
  , i_file_nature         in      com_api_type_pkg.t_dict_value := prc_api_const_pkg.FILE_NATURE_PLAINTEXT
  , i_xsd_source          in      clob default null
  , i_file_type           in      com_api_type_pkg.t_dict_value := null
  , i_name                in      com_api_type_pkg.t_name
  , i_description         in      com_api_type_pkg.t_full_desc
  , i_lang                in      com_api_type_pkg.t_dict_value
) is
begin
    prc_ui_process_pkg.check_process_using (
        i_id  => i_process_id
    );

    if i_file_purpose in (prc_api_file_pkg.get_file_purpose_in, prc_api_file_pkg.get_file_purpose_out) then
        null;
    else
        com_api_error_pkg.raise_error (
            i_error         => 'FILE_PURPOSE_NOT_FOUND'
            , i_env_param1  => i_file_purpose
        );
    end if;

    o_id := prc_file_seq.nextval;
    insert into prc_file_vw (
        id
      , process_id
      , file_purpose
      , saver_id
      , file_nature
      , xsd_source
      , file_type
    ) values (
        o_id
      , i_process_id
      , i_file_purpose
      , i_saver_id
      , i_file_nature
      , i_xsd_source
      , i_file_type
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prc_file'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_text         => i_name
      , i_lang         => i_lang
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prc_file'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
    );
end;

procedure modify_file(
    i_id                  in      com_api_type_pkg.t_tiny_id
  , i_file_purpose        in      com_api_type_pkg.t_dict_value
  , i_saver_id            in      com_api_type_pkg.t_tiny_id
  , i_file_nature         in      com_api_type_pkg.t_dict_value := prc_api_const_pkg.FILE_NATURE_PLAINTEXT
  , i_xsd_source          in      clob default null
  , i_file_type           in      com_api_type_pkg.t_dict_value := null
  , i_name                in      com_api_type_pkg.t_name
  , i_description         in      com_api_type_pkg.t_full_desc
  , i_lang                in      com_api_type_pkg.t_dict_value
) is
    l_process_id                  com_api_type_pkg.t_short_id;
begin
    -- If associated process is used in at least one process container, forbid to modify 
    -- all file's parameters (they are listed in the query below) except for XSD_SOURCE 
    begin 
        select process_id
          into l_process_id
          from prc_file
         where id = i_id
           and (nvl(i_file_purpose, '~'), nvl(i_file_nature, '~'), nvl(i_file_type, '~'), nvl(i_saver_id, 0))
               not in
               ( (nvl(file_purpose, '~'), nvl(file_nature, '~'), nvl(file_type, '~'), nvl(saver_id, 0)) );

        prc_ui_process_pkg.check_process_using(
            i_id => l_process_id
        );
    exception
        when no_data_found then
            null; -- Allow to change parameters without any check if they are NOT listed in the query above
    end; 

    if i_file_purpose not in (prc_api_file_pkg.get_file_purpose_in
                            , prc_api_file_pkg.get_file_purpose_out)
    then
        com_api_error_pkg.raise_error(
            i_error       => 'FILE_PURPOSE_NOT_FOUND'
          , i_env_param1  => i_file_purpose
        );
    end if;

    update prc_file_vw
       set file_purpose = i_file_purpose
         , saver_id     = i_saver_id
         , file_nature  = i_file_nature
         , xsd_source   = i_xsd_source
         , file_type    = i_file_type
     where id           = i_id;

    com_api_i18n_pkg.add_text (
        i_table_name     => 'prc_file'
        , i_column_name  => 'name'
        , i_object_id    => i_id
        , i_text         => i_name
        , i_lang         => i_lang
    );

    if i_description is null then
        com_api_i18n_pkg.remove_text(
            i_table_name   => 'prc_file'
          , i_column_name  => 'description'
          , i_object_id    => i_id
          , i_lang         => i_lang
        );
    else
        com_api_i18n_pkg.add_text(
            i_table_name   => 'prc_file'
          , i_column_name  => 'description'
          , i_object_id    => i_id
          , i_text         => i_description
          , i_lang         => i_lang
        );
    end if;
end;

procedure remove_file (
    i_id                  in      com_api_type_pkg.t_tiny_id
) is
begin
    for r1 in (
        select a.id
             , process_id
          from prc_file_vw a
         where a.id = i_id
    ) loop
        prc_ui_process_pkg.check_process_using (
            i_id  => r1.process_id
        );

        -- delete attribute
        for r2 in (
            select b.id
              from prc_file_attribute_vw b
             where b.file_id = r1.id
        ) loop
            remove_file_attribute (
                i_id  => r2.id
            );
        end loop;

        -- delete file
        delete from prc_file_vw a
         where a.id = r1.id;

        com_api_i18n_pkg.remove_text (
            i_table_name => 'prc_file'
          , i_object_id  => r1.id
        );
    end loop;
end;

procedure add_file_attribute(
    o_id                     out com_api_type_pkg.t_short_id
  , i_file_id             in     com_api_type_pkg.t_tiny_id
  , i_container_id        in     com_api_type_pkg.t_short_id
  , i_characterset        in     com_api_type_pkg.t_attr_name
  , i_file_name_mask      in     com_api_type_pkg.t_name
  , i_name_format_id      in     com_api_type_pkg.t_tiny_id
  , i_upload_empty_file   in     com_api_type_pkg.t_boolean
  , i_xslt_source         in     clob := null
  , i_converter_class     in     com_api_type_pkg.t_name
  , i_is_tar              in     com_api_type_pkg.t_boolean
  , i_is_zip              in     com_api_type_pkg.t_boolean
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_report_id           in     com_api_type_pkg.t_short_id
  , i_report_template_id  in     com_api_type_pkg.t_short_id
  , i_load_priority       in     com_api_type_pkg.t_tiny_id      default null
  , i_sign_transfer_type  in     com_api_type_pkg.t_dict_value   default null
  , i_encrypt_plugin      in     com_api_type_pkg.t_name         default null
  , i_ignore_file_errors  in     com_api_type_pkg.t_boolean      default null
  , i_location_id         in     com_api_type_pkg.t_tiny_id
  , i_parallel_degree     in     com_api_type_pkg.t_tiny_id      default null
  , i_is_file_name_unique in     com_api_type_pkg.t_boolean      default null
  , i_is_file_required    in     com_api_type_pkg.t_boolean      default null
  , i_queue_identifier    in     com_api_type_pkg.t_name         default null
  , i_time_out            in     com_api_type_pkg.t_short_id     default null
  , i_port                in     com_api_type_pkg.t_tag          default null
  , i_line_separator      in     com_api_type_pkg.t_name         default null
  , i_password_protect    in     com_api_type_pkg.t_boolean      default null
  , i_is_cleanup_data     in     com_api_type_pkg.t_boolean      default null
  , i_file_merge_mode     in     com_api_type_pkg.t_dict_value   default null
) is
begin
    o_id := prc_file_attribute_seq.nextval;
    insert into prc_file_attribute_vw (
        id
      , file_id
      , container_id
      , characterset
      , file_name_mask
      , name_format_id
      , upload_empty_file
      , xslt_source
      , converter_class
      , is_tar
      , is_zip
      , inst_id
      , report_id
      , report_template_id
      , load_priority
      , sign_transfer_type
      , encrypt_plugin
      , ignore_file_errors
      , location_id
      , parallel_degree
      , is_file_name_unique
      , is_file_required
      , queue_identifier
      , time_out
      , port
      , line_separator
      , password_protect
      , is_cleanup_data
      , file_merge_mode
    ) values (
        o_id
      , i_file_id
      , i_container_id
      , i_characterset
      , i_file_name_mask
      , i_name_format_id
      , i_upload_empty_file
      , i_xslt_source
      , i_converter_class
      , i_is_tar
      , i_is_zip
      , i_inst_id
      , i_report_id
      , i_report_template_id
      , i_load_priority
      , i_sign_transfer_type
      , i_encrypt_plugin
      , nvl(i_ignore_file_errors, com_api_const_pkg.FALSE)
      , i_location_id
      , i_parallel_degree
      , nvl(i_is_file_name_unique, com_api_const_pkg.TRUE)
      , nvl(i_is_file_required, com_api_const_pkg.TRUE)
      , i_queue_identifier
      , i_time_out
      , i_port
      , i_line_separator
      , i_password_protect
      , i_is_cleanup_data
      , i_file_merge_mode
    );
end;

procedure modify_file_attribute(
    i_id                  in     com_api_type_pkg.t_short_id
  , i_characterset        in     com_api_type_pkg.t_attr_name
  , i_file_name_mask      in     com_api_type_pkg.t_name
  , i_name_format_id      in     com_api_type_pkg.t_tiny_id
  , i_upload_empty_file   in     com_api_type_pkg.t_boolean
  , i_xslt_source         in     clob := null
  , i_is_tar              in     com_api_type_pkg.t_boolean
  , i_is_zip              in     com_api_type_pkg.t_boolean
  , i_converter_class     in     com_api_type_pkg.t_name
  , i_report_id           in     com_api_type_pkg.t_short_id
  , i_report_template_id  in     com_api_type_pkg.t_short_id
  , i_load_priority       in     com_api_type_pkg.t_tiny_id      default null
  , i_sign_transfer_type  in     com_api_type_pkg.t_dict_value   default null
  , i_encrypt_plugin      in     com_api_type_pkg.t_name         default null
  , i_ignore_file_errors  in     com_api_type_pkg.t_boolean      default null
  , i_location_id         in     com_api_type_pkg.t_tiny_id
  , i_parallel_degree     in     com_api_type_pkg.t_tiny_id      default null
  , i_is_file_name_unique in     com_api_type_pkg.t_boolean      default null
  , i_is_file_required    in     com_api_type_pkg.t_boolean      default null
  , i_queue_identifier    in     com_api_type_pkg.t_name         default null
  , i_time_out            in     com_api_type_pkg.t_short_id     default null
  , i_port                in     com_api_type_pkg.t_tag          default null
  , i_line_separator      in     com_api_type_pkg.t_name         default null
  , i_password_protect    in     com_api_type_pkg.t_boolean      default null
  , i_is_cleanup_data     in     com_api_type_pkg.t_boolean      default null
  , i_file_merge_mode     in     com_api_type_pkg.t_dict_value   default null
) is
begin
    update prc_file_attribute_vw a
       set characterset         = i_characterset
         , file_name_mask       = i_file_name_mask
         , name_format_id       = i_name_format_id
         , upload_empty_file    = i_upload_empty_file
         , location_id          = i_location_id
         , xslt_source          = i_xslt_source
         , converter_class      = i_converter_class
         , is_tar               = i_is_tar
         , is_zip               = i_is_zip
         , report_id            = i_report_id
         , report_template_id   = i_report_template_id
         , load_priority        = i_load_priority
         , sign_transfer_type   = i_sign_transfer_type
         , encrypt_plugin       = i_encrypt_plugin
         , ignore_file_errors   = nvl(i_ignore_file_errors, ignore_file_errors)
         , parallel_degree      = i_parallel_degree
         , is_file_name_unique  = nvl(i_is_file_name_unique, is_file_name_unique)
         , is_file_required     = nvl(i_is_file_required, is_file_required)
         , queue_identifier     = i_queue_identifier
         , time_out             = i_time_out
         , port                 = i_port
         , line_separator       = i_line_separator
         , password_protect     = i_password_protect
         , is_cleanup_data      = i_is_cleanup_data
         , file_merge_mode      = i_file_merge_mode
     where id = i_id;
end;

procedure remove_file_attribute (
    i_id                  in      com_api_type_pkg.t_short_id
) is
begin
    delete
        prc_file_attribute_vw a
    where
        a.id = i_id;
end;

procedure remove_process_file(
    i_process_id          in     com_api_type_pkg.t_short_id
) is
begin
    for rec in (
        select
            a.id
        from
            prc_file_vw a
        where
            a.process_id = i_process_id)
    loop
        remove_file(i_id => rec.id);
    end loop;

end remove_process_file;

procedure set_file_status(
    i_sess_file_id        in      com_api_type_pkg.t_long_id
  , i_status              in      com_api_type_pkg.t_dict_value   default null
) is
begin
    update
        prc_session_file_vw a
    set
        a.status = i_status
    where
        a.id = i_sess_file_id;
end;

function get_default_file_name(
    i_file_type           in      com_api_type_pkg.t_dict_value default null
  , i_file_purpose        in      com_api_type_pkg.t_dict_value default null
  , i_params              in      com_param_map_tpt
) return com_api_type_pkg.t_name is
    l_param_tab     com_api_type_pkg.t_param_tab;
begin

    for r in (
        select name
             , char_value
             , number_value
             , date_value
          from table(cast(i_params as com_param_map_tpt))
    ) loop
        if r.char_value is not null then
            rul_api_param_pkg.set_param(
                i_name      => upper(r.name)
              , i_value     => r.char_value
              , io_params   => l_param_tab
            );
        elsif r.number_value is not null then
            rul_api_param_pkg.set_param(
                i_name      => upper(r.name)
              , i_value     => r.number_value
              , io_params   => l_param_tab
            );
        elsif r.date_value is not null then
            rul_api_param_pkg.set_param(
                i_name      => upper(r.name)
              , i_value     => r.date_value
              , io_params   => l_param_tab
            );
        end if;
    end loop;

    return 
        prc_api_file_pkg.get_default_file_name(
            i_file_type     => i_file_type
          , i_file_purpose  => i_file_purpose
          , io_params       => l_param_tab
        );
end;

procedure add_file_saver (
    o_id                      out com_api_type_pkg.t_tiny_id
  , o_seqnum                  out com_api_type_pkg.t_seqnum
  , i_source               in     com_api_type_pkg.t_name
  , i_is_parallel          in     com_api_type_pkg.t_boolean
  , i_post_source          in     com_api_type_pkg.t_name
  , i_name                 in     com_api_type_pkg.t_name
  , i_lang                 in     com_api_type_pkg.t_dict_value
) is
begin
    o_id := prc_file_saver_seq.nextval;
    o_seqnum := 1;
    
    insert into prc_file_saver_vw (
        id
      , seqnum
      , source
      , is_parallel
      , post_source
    ) values (
        o_id
      , o_seqnum
      , i_source
      , i_is_parallel
      , i_post_source
    );
    
    com_api_i18n_pkg.add_text (
        i_table_name     => 'prc_file_saver'
        , i_column_name  => 'name'
        , i_object_id    => o_id
        , i_lang         => i_lang
        , i_text         => i_name
    );
end;

procedure modify_file_saver (
    i_id                  in      com_api_type_pkg.t_tiny_id
  , io_seqnum             in out  com_api_type_pkg.t_seqnum
  , i_source              in      com_api_type_pkg.t_name
  , i_is_parallel         in      com_api_type_pkg.t_boolean
  , i_post_source         in      com_api_type_pkg.t_name
  , i_name                in      com_api_type_pkg.t_name
  , i_lang                in      com_api_type_pkg.t_dict_value
) is
begin
    update prc_file_saver_vw
       set seqnum      = io_seqnum
         , source      = i_source
         , is_parallel = i_is_parallel
         , post_source = i_post_source
     where id = i_id;
        
    io_seqnum := io_seqnum + 1;
    
    com_api_i18n_pkg.add_text (
        i_table_name     => 'prc_file_saver'
        , i_column_name  => 'name'
        , i_object_id    => i_id
        , i_lang         => i_lang
        , i_text         => i_name
    );
end;

procedure remove_file_saver (
    i_id                        in com_api_type_pkg.t_tiny_id
    , i_seqnum                  in com_api_type_pkg.t_seqnum
) is
    l_check_cnt                 com_api_type_pkg.t_count := 0;
begin
    select count(id)
      into l_check_cnt
      from prc_file_vw
     where saver_id = i_id;
    
    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error      => 'FILE_SAVER_ALREADY_USED'
        );
    end if;
    
    -- remove text
    com_api_i18n_pkg.remove_text (
        i_table_name   => 'prc_file_saver'
        , i_object_id  => i_id
    );
        
    update
        prc_file_saver_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;

    -- delete
    delete from
        prc_file_saver_vw
    where
        id = i_id;

end;

/*
 * Function removes all session files for defined user's session.
 */
procedure remove_session_file(
    i_session_id          in     com_api_type_pkg.t_long_id
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.remove_session_file: ';
begin
    delete from prc_session_file_vw s
     where s.session_id = i_session_id;
    
    trc_log_pkg.debug(LOG_PREFIX || sql%rowcount || ' files were removed for session [' || i_session_id || ']');

exception
    when others then
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED for session [' || i_session_id || ']');
        raise;
end;

end prc_ui_file_pkg;
/
