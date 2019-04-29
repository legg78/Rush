create or replace package body cmn_ui_standard_pkg as
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
) is
begin
    if i_standard_type = cmn_api_const_pkg.STANDART_TYPE_NETW_BASIC then
        begin
            select id
              into o_standard_id
              from cmn_standard
             where standard_type = cmn_api_const_pkg.STANDART_TYPE_NETW_BASIC;
             
             com_api_error_pkg.raise_error(
                i_error         => 'CMN_DUPLICATE_STANDARD'
              , i_env_param2    => cmn_api_const_pkg.STANDART_TYPE_NETW_BASIC  
             );
             
        exception
            when no_data_found then
                null;     
        end; 
         
    end if;
             
    if i_appl_plugin is null and i_standard_type in (
        cmn_api_const_pkg.STANDART_TYPE_NETW_COMM
      , cmn_api_const_pkg.STANDART_TYPE_TERM_COMM
    ) then
        com_api_error_pkg.raise_error(
            i_error         => 'COMMUNICATION_STANDARD_APPL_PLUGIN_NOT_DEFINED'
        );
    end if;

    o_standard_id := cmn_standard_seq.nextval;

    insert into cmn_standard_vw(
        id
      , application_plugin
      , resp_code_lov_id
      , key_type_lov_id
      , standard_type
      , seqnum
    ) values (
        o_standard_id
      , i_appl_plugin
      , i_resp_code_lov_id
      , i_key_type_lov_id
      , i_standard_type
      , 1
    );

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'CMN_STANDARD'
          , i_column_name  => 'LABEL'
          , i_object_id    => o_standard_id
          , i_lang         => i_lang
          , i_text         => i_label
          , i_check_unique => com_api_const_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'CMN_STANDARD'
          , i_column_name  => 'DESCRIPTION'
          , i_object_id    => o_standard_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end if;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error       => 'CMN_DUPLICATE_STANDARD'
          , i_env_param1  => i_appl_plugin
          , i_env_param2  => i_standard_type
        );
end;

procedure modify_standard(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_appl_plugin       in      com_api_type_pkg.t_dict_value
  , i_resp_code_lov_id  in      com_api_type_pkg.t_tiny_id
  , i_key_type_lov_id   in      com_api_type_pkg.t_tiny_id
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_standard_type     com_api_type_pkg.t_dict_value;
begin
    select standard_type
      into l_standard_type
      from cmn_standard
     where id = i_standard_id;

    if i_appl_plugin is null and l_standard_type in (
        cmn_api_const_pkg.STANDART_TYPE_NETW_COMM
      , cmn_api_const_pkg.STANDART_TYPE_TERM_COMM
    ) then
        com_api_error_pkg.raise_error(
            i_error         => 'COMMUNICATION_STANDARD_APPL_PLUGIN_NOT_DEFINED'
        );
    end if;

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'CMN_STANDARD'
          , i_column_name   => 'LABEL'
          , i_object_id     => i_standard_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_const_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'CMN_STANDARD'
          , i_column_name   => 'DESCRIPTION'
          , i_object_id     => i_standard_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;

    update cmn_standard_vw
       set application_plugin = i_appl_plugin
         , resp_code_lov_id   = i_resp_code_lov_id
         , key_type_lov_id    = i_key_type_lov_id
         , seqnum             = i_seqnum
     where id                 = i_standard_id;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error       => 'CMN_DUPLICATE_STANDARD'
          , i_env_param1  => i_appl_plugin
          , i_env_param2  => null
        );
end;

procedure remove_standard(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_count             pls_integer;
    l_entities          com_api_type_pkg.t_text;
begin
    update cmn_standard_vw
       set seqnum = i_seqnum
     where id     = i_standard_id;

    select count(id)
         , min(entity_type)
      into l_count
         , l_entities
      from cmn_standard_object
     where standard_id = i_standard_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'STANDARD_BEING_USED_FOR_ENTITIES'
          , i_env_param1  => l_entities
          , i_env_param2  => i_standard_id
        );
    end if;

    for r in (
        select id
          from cmn_parameter_vw
         where standard_id = i_standard_id
    ) loop
        cmn_ui_parameter_pkg.remove_parameter (
            i_param_id  => r.id
        );
    end loop;

    for r in (
        select id
             , seqnum
          from cmn_resp_code_vw
         where standard_id = i_standard_id
    ) loop
        cmn_ui_resp_code_pkg.remove_resp_code (
            i_resp_code_id  => r.id
          , i_seqnum        => r.seqnum
        );
    end loop;

    delete from cmn_standard_version_vw
          where standard_id = i_standard_id;

    delete from cmn_standard_vw
          where id = i_standard_id;

    com_api_i18n_pkg.remove_text (
        i_table_name => 'CMN_STANDARD'
      , i_object_id  => i_standard_id
    );
end;

procedure set_param_value(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_version_id        in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_data_type         in      com_api_type_pkg.t_oracle_name
  , i_param_value_v     in      com_api_type_pkg.t_name         default null
  , i_param_value_d     in      date                            default null
  , i_param_value_n     in      number                          default null
) is
    l_param_id          com_api_type_pkg.t_short_id;
    l_data_type         com_api_type_pkg.t_oracle_name;
    l_param_value       com_api_type_pkg.t_name;
begin
    begin
        select id
             , data_type
          into l_param_id
             , l_data_type
          from cmn_parameter_vw
         where name        = upper(i_param_name)
           and standard_id = i_standard_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'STANDARD_PARAM_NOT_EXISTS'
              , i_env_param1    => upper(i_param_name)
              , i_env_param2    => i_standard_id
            );
    end;

    if l_data_type != i_data_type then
        com_api_error_pkg.raise_error(
            i_error         => 'INCORRECT_PARAM_VALUE_DATA_TYPE'
          , i_env_param1    => i_data_type
          , i_env_param2    => l_data_type
        );
    end if;

    l_param_value := com_api_type_pkg.convert_to_char(
                         i_data_type  => l_data_type
                       , i_value_char => i_param_value_v
                       , i_value_num  => i_param_value_n
                       , i_value_date => i_param_value_d
                     );

    merge into cmn_parameter_value_vw dst
    using(select l_param_id    param_id
               , l_param_value param_value
               , i_object_id   object_id
               , i_entity_type entity_type
               , i_standard_id standard_id
               , i_version_id  version_id
               , i_mod_id      mod_id
            from dual
    ) src
    on (    dst.param_id    = src.param_id
        and dst.object_id   = src.object_id
        and dst.entity_type = src.entity_type
        and dst.standard_id = src.standard_id
        and decode(dst.mod_id, src.mod_id, 1, 0) = 1
        and decode(dst.version_id, src.version_id, 1, 0) = 1
    )
    when matched then
        update
        set dst.param_value = src.param_value
    when not matched then
        insert (
            dst.id
          , dst.param_id
          , dst.standard_id
          , dst.version_id
          , dst.entity_type
          , dst.object_id
          , dst.param_value
          , dst.mod_id
        ) values (
            cmn_parameter_value_seq.nextval
          , src.param_id
          , src.standard_id
          , src.version_id
          , src.entity_type
          , src.object_id
          , src.param_value
          , src.mod_id
        );
end;

procedure set_param_value_char(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_version_id        in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      varchar2
) is
    l_data_type         com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATA_TYPE_CHAR;
begin
    set_param_value(
        i_standard_id       => i_standard_id
      , i_version_id        => i_version_id
      , i_object_id         => i_object_id
      , i_entity_type       => i_entity_type
      , i_mod_id            => i_mod_id
      , i_param_name        => i_param_name
      , i_data_type         => l_data_type
      , i_param_value_v     => i_param_value
    );
end;

procedure set_param_value_date(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_version_id        in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      date
) is
begin
    set_param_value(
        i_standard_id       => i_standard_id
      , i_version_id        => i_version_id
      , i_object_id         => i_object_id
      , i_entity_type       => i_entity_type
      , i_mod_id            => i_mod_id
      , i_param_name        => i_param_name
      , i_data_type         => com_api_const_pkg.DATA_TYPE_DATE
      , i_param_value_d     => i_param_value
    );
end;

procedure set_param_value_number(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_version_id        in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      number
) is
begin
    set_param_value(
      i_standard_id       => i_standard_id
      , i_version_id        => i_version_id
      , i_object_id         => i_object_id
      , i_entity_type       => i_entity_type
      , i_mod_id            => i_mod_id
      , i_param_name        => i_param_name
      , i_data_type         => com_api_const_pkg.DATA_TYPE_NUMBER
      , i_param_value_n     => i_param_value
    );
end;

procedure set_param_value_clob(
    i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_version_id        in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_param_name        in      com_api_type_pkg.t_name
  , i_xml_value         in      clob
) is
    l_param_id          com_api_type_pkg.t_short_id;
    l_data_type         com_api_type_pkg.t_oracle_name;
begin
    begin
        select id
             , data_type
          into l_param_id
             , l_data_type
          from cmn_parameter_vw
         where name        = upper(i_param_name)
           and standard_id = i_standard_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'STANDARD_PARAM_NOT_EXISTS'
              , i_env_param1    => upper(i_param_name)
              , i_env_param2    => i_standard_id
            );
    end;

    if l_data_type != com_api_const_pkg.DATA_TYPE_CLOB then
        com_api_error_pkg.raise_error(
            i_error         => 'INCORRECT_PARAM_VALUE_DATA_TYPE'
          , i_env_param1    => com_api_const_pkg.DATA_TYPE_CLOB
          , i_env_param2    => l_data_type
        );
    end if;

    merge into cmn_parameter_value_vw dst
    using(select l_param_id     param_id
               , i_xml_value    xml_value
               , i_object_id    object_id
               , i_entity_type  entity_type
               , i_standard_id  standard_id
               , i_version_id   version_id
               , i_mod_id       mod_id
            from dual
    ) src
      on (dst.param_id    = src.param_id
      and dst.object_id   = src.object_id
      and dst.entity_type = src.entity_type
      and dst.standard_id = src.standard_id
      and decode(dst.mod_id, src.mod_id, 1, 0) = 1
      and decode(dst.version_id, src.version_id, 1, 0) = 1
    )
    when matched then
        update
        set dst.xml_value = src.xml_value
    when not matched then
        insert (
            dst.id
          , dst.param_id
          , dst.standard_id
          , dst.version_id
          , dst.entity_type
          , dst.object_id
          , dst.xml_value
          , dst.mod_id
        ) values (
            cmn_parameter_value_seq.nextval
          , src.param_id
          , src.standard_id
          , src.version_id
          , src.entity_type
          , src.object_id
          , src.xml_value
          , src.mod_id
        );

end;

procedure remove_param_value (
    i_standard_id         in      com_api_type_pkg.t_tiny_id
  , i_version_id        in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_param_name        in      com_api_type_pkg.t_name
) is
    l_param_id          com_api_type_pkg.t_short_id;
begin
    begin
        select id
          into l_param_id
          from cmn_parameter_vw
         where name        = upper(i_param_name)
           and standard_id = i_standard_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'STANDARD_PARAM_NOT_EXISTS'
              , i_env_param1    => upper(i_param_name)
              , i_env_param2    => i_standard_id
            );
    end;

    delete from cmn_parameter_value
          where object_id   = i_object_id
            and entity_type = i_entity_type
            and param_id    = l_param_id
            and standard_id = i_standard_id
            and decode(version_id, i_version_id, 1, 0) = 1;
end;

procedure remove_param_value (
  i_id                  in      com_api_type_pkg.t_short_id
) is
begin
    delete from cmn_parameter_value
          where id = i_id;
end;

procedure remove_param_values(
    i_object_id         in      com_api_type_pkg.t_long_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
) is
begin
    delete from cmn_parameter_value
          where object_id   = i_object_id
            and entity_type = i_entity_type;
end;

procedure add_standard_version (
    o_id                 out  com_api_type_pkg.t_tiny_id
  , o_seqnum             out  com_api_type_pkg.t_seqnum
  , i_standard_id     in      com_api_type_pkg.t_tiny_id
  , i_version_number  in      com_api_type_pkg.t_name
  , i_description     in      com_api_type_pkg.t_full_desc
  , i_lang            in      com_api_type_pkg.t_dict_value
) is
    l_version_order   com_api_type_pkg.t_tiny_id;
    l_count           com_api_type_pkg.t_long_id;
begin
    select count(1)
      into l_count
      from cmn_standard_version_vw
     where standard_id    = i_standard_id
       and version_number = i_version_number;
     
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'STANDARD_VERSION_ALREADY_EXISTS'
          , i_env_param1  => i_standard_id
          , i_env_param2  => i_version_number
        );
    end if;

    o_id := cmn_standard_version_seq.nextval;
    o_seqnum := 1;
    
    select nvl(max(version_order), 0) 
      into l_version_order
      from cmn_standard_version
     where standard_id = i_standard_id;

    insert into cmn_standard_version_vw (
        id
      , seqnum
      , standard_id
      , version_number
      , version_order
    ) values (
        o_id
      , o_seqnum
      , i_standard_id
      , i_version_number
      , l_version_order + 1
    );

   if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name  => 'CMN_STANDARD_VERSION'
          , i_column_name => 'DESCRIPTION'
          , i_object_id   => o_id
          , i_lang        => i_lang
          , i_text        => i_description
        );
    end if;
end;

procedure modify_standard_version (
    i_id              in     com_api_type_pkg.t_tiny_id
  , io_seqnum         in out com_api_type_pkg.t_seqnum
  , i_version_number  in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_full_desc
  , i_lang            in     com_api_type_pkg.t_dict_value
) is
    l_count           com_api_type_pkg.t_long_id;
    l_standard_id     com_api_type_pkg.t_tiny_id;
begin
    select count(1) 
      into l_count  
      from cmn_standard_version_obj o  
         , cmn_standard_version v
     where o.version_id = i_id 
       and v.id = o.version_id
       and v.version_number != i_version_number;
             
    if l_count > 0 then
       com_api_error_pkg.raise_error(
            i_error         => 'STANDARD_VERSION_ALREADY_USE'
          , i_env_param1    => i_id
        );
    end if;
        
    update cmn_standard_version_vw
       set version_number = i_version_number
         , seqnum         = io_seqnum
     where id             = i_id;
    
    for s in (
        select
            standard_id
        from
            cmn_standard_version_vw
        where id = i_id
    ) loop
        l_standard_id := s.standard_id;
    end loop;

    select count(1)
      into l_count
      from cmn_standard_version_vw
     where standard_id    = l_standard_id
       and version_number = i_version_number;
     
    if l_count > 1 then
        com_api_error_pkg.raise_error(
            i_error       => 'STANDARD_VERSION_ALREADY_EXISTS'
          , i_env_param1  => l_standard_id
          , i_env_param2  => i_version_number
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name  => 'CMN_STANDARD_VERSION'
          , i_column_name => 'DESCRIPTION'
          , i_object_id   => i_id
          , i_lang        => i_lang
          , i_text        => i_description
        );
    end if;

    io_seqnum := io_seqnum + 1;
end;

procedure remove_standard_version (
    i_id              in      com_api_type_pkg.t_tiny_id
  , i_seqnum          in      com_api_type_pkg.t_seqnum
) is
    l_check_entity    com_api_type_pkg.t_dict_value;
    l_check_object    com_api_type_pkg.t_long_id;
begin
    update cmn_standard_version_vw
       set seqnum = i_seqnum
     where id     = i_id;

    begin
        select entity_type
             , object_id
          into l_check_entity
             , l_check_object
          from cmn_standard_version_obj
         where version_id = i_id
           and rownum     < 2;

        com_api_error_pkg.raise_error(
            i_error         => 'STANDARD_VERSION_IN_USE'
          , i_env_param1    => i_id
          , i_env_param2    => l_check_entity
          , i_env_param3    => l_check_object
        );
    exception
        when no_data_found then
            null;
    end;

    com_api_i18n_pkg.remove_text (
        i_table_name => 'CMN_STANDARD_VERSION'
      , i_object_id  => i_id
    );

    remove_param_values (
        i_object_id   => i_id
      , i_entity_type => cmn_api_const_pkg.ENTITY_TYPE_CMN_STANDARD_VERS
    );

    delete from cmn_standard_version_vw
    where id = i_id;
end;

procedure move_version_up(
    i_id                in      com_api_type_pkg.t_tiny_id  
) is
    l_old_id            com_api_type_pkg.t_tiny_id;
    l_new_version_order com_api_type_pkg.t_tiny_id;
    l_new_id            com_api_type_pkg.t_tiny_id;
    l_old_version_order com_api_type_pkg.t_tiny_id;
begin

    select old_id
         , new_version_order
         , new_id
         , old_version_order
      into l_old_id
         , l_new_version_order
         , l_new_id
         , l_old_version_order
      from (
            select v1.id old_id
                 , v1.version_order new_version_order
                 , v2.id new_id
                 , v2.version_order old_version_order
              from cmn_standard_version v1
                 , cmn_standard_version v2
             where v2.standard_id   = v1.standard_id
               and v2.version_order < v1.version_order
               and v1.id = i_id
             order by v2.version_order desc
           )
     where rownum = 1;       
     
    update cmn_standard_version_vw
       set version_order = decode(id, l_new_id, l_new_version_order, l_old_id, l_old_version_order)
         , seqnum = seqnum
     where id in (l_new_id, l_old_id); 

exception
    when no_data_found then
        null;
end;

procedure move_version_down(
    i_id                in      com_api_type_pkg.t_tiny_id  
) is
    l_old_id            com_api_type_pkg.t_tiny_id;
    l_new_version_order com_api_type_pkg.t_tiny_id;
    l_new_id            com_api_type_pkg.t_tiny_id;
    l_old_version_order com_api_type_pkg.t_tiny_id;
begin

    select old_id
         , new_version_order
         , new_id
         , old_version_order
      into l_old_id
         , l_new_version_order
         , l_new_id
         , l_old_version_order
      from (
            select v1.id old_id
                 , v1.version_order new_version_order
                 , v2.id new_id
                 , v2.version_order old_version_order
              from cmn_standard_version v1
                 , cmn_standard_version v2
             where v2.standard_id   = v1.standard_id
               and v2.version_order > v1.version_order
               and v1.id = i_id
             order by v2.version_order asc
           )
     where rownum = 1;       
     
    update cmn_standard_version_vw
       set version_order = decode(id, l_new_id, l_new_version_order, l_old_id, l_old_version_order)
         , seqnum = seqnum
     where id in (l_new_id, l_old_id); 

exception
    when no_data_found then
        null;
end;
    


end;
/
