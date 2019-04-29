create or replace package body prc_ui_parameter_pkg as
/************************************************************
 * User interface for process parameters <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 15.11.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_UI_PARAMETER_PKG <br />
 * @headcom
 ************************************************************/

procedure set_parameter_value (
    o_id                       out com_api_type_pkg.t_short_id
  , i_container_id          in     com_api_type_pkg.t_short_id
  , i_param_id              in     com_api_type_pkg.t_short_id
  , i_param_value           in     com_api_type_pkg.t_param_value
) is
begin
    o_id := prc_parameter_value_seq.nextval;

    insert into prc_parameter_value_vw(
        id
      , container_id
      , param_id
      , param_value
    ) values (
        o_id
      , i_container_id
      , i_param_id
      , i_param_value
    );

end set_parameter_value;

procedure modify_parameter_value (
    i_id           in      com_api_type_pkg.t_short_id
  , i_param_id     in      com_api_type_pkg.t_short_id
  , i_param_value  in      com_api_type_pkg.t_param_value
) is
begin
    update prc_parameter_value_vw
       set param_id    = i_param_id
         , param_value = i_param_value
     where id          = i_id;
end modify_parameter_value;

procedure set_parameter_value_num (
    io_id                   in out com_api_type_pkg.t_short_id
  , i_container_id          in     com_api_type_pkg.t_short_id
  , i_param_id              in     com_api_type_pkg.t_short_id
  , i_param_value           in     number
) is
    l_data_type             com_api_type_pkg.t_dict_value;
begin
    if io_id is null then
        begin
            select data_type
              into l_data_type
              from (select id, data_type from prc_parameter_vw
                    union all
                    select id, data_type from rpt_parameter_vw)
             where id = i_param_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'PARAM_NOT_FOUND'
                  , i_env_param1  => i_param_id
                );
        end;

        if l_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
            set_parameter_value(
                o_id            => io_id
              , i_container_id  => i_container_id
              , i_param_id      => i_param_id
              , i_param_value   => to_char(i_param_value, com_api_const_pkg.NUMBER_FORMAT)
            );
        else
            com_api_error_pkg.raise_error (
                i_error       => 'WRONG_PARAMETER_DATA_TYPE'
              , i_env_param1  => i_param_id
              , i_env_param2  => l_data_type
              , i_env_param3  => com_api_const_pkg.DATA_TYPE_NUMBER
            );
        end if;
    else
        modify_parameter_value(
            i_id           => io_id
          , i_param_id     => i_param_id
          , i_param_value  => to_char(i_param_value, com_api_const_pkg.NUMBER_FORMAT)
        );
    end if;
end set_parameter_value_num;

procedure set_parameter_value_date (
    io_id                   in out com_api_type_pkg.t_short_id
  , i_container_id          in     com_api_type_pkg.t_short_id
  , i_param_id              in     com_api_type_pkg.t_short_id
  , i_param_value           in     date
) is
    l_data_type             com_api_type_pkg.t_dict_value;
begin
    if io_id is null then
        begin
            select data_type
              into l_data_type
              from (select id, data_type from prc_parameter_vw
                    union all
                    select id, data_type from rpt_parameter_vw)
             where id = i_param_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error         => 'PARAM_NOT_FOUND'
                  , i_env_param1    => i_param_id
                );
        end;

        if l_data_type = com_api_const_pkg.DATA_TYPE_DATE then
            set_parameter_value(
                o_id            => io_id
              , i_container_id  => i_container_id
              , i_param_id      => i_param_id
              , i_param_value   => to_char(i_param_value, com_api_const_pkg.DATE_FORMAT)
            );
        else
            com_api_error_pkg.raise_error(
                i_error       => 'WRONG_PARAMETER_DATA_TYPE'
              , i_env_param1  => i_param_id
              , i_env_param2  => l_data_type
              , i_env_param3  => com_api_const_pkg.DATA_TYPE_DATE
            );
        end if;
    else
        modify_parameter_value (
            i_id           => io_id
          , i_param_id     => i_param_id
          , i_param_value  => to_char(i_param_value, com_api_const_pkg.DATE_FORMAT)
        );
    end if;
end set_parameter_value_date;

procedure set_parameter_value_char(
    io_id                   in out com_api_type_pkg.t_short_id
  , i_container_id          in     com_api_type_pkg.t_short_id
  , i_param_id              in     com_api_type_pkg.t_short_id
  , i_param_value           in     com_api_type_pkg.t_param_value
) is
    l_data_type             com_api_type_pkg.t_dict_value;
begin
    if io_id is null then
        begin
            select data_type
              into l_data_type
              from (select id, data_type from prc_parameter_vw
                    union all
                    select id, data_type from rpt_parameter_vw)
             where id = i_param_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'PARAM_NOT_FOUND'
                  , i_env_param1  => i_param_id
                );
        end;

        if l_data_type = com_api_const_pkg.DATA_TYPE_CHAR then
            set_parameter_value(
                o_id            => io_id
              , i_container_id  => i_container_id
              , i_param_id      => i_param_id
              , i_param_value   => i_param_value
            );
        else
            com_api_error_pkg.raise_error (
                i_error       => 'WRONG_PARAMETER_DATA_TYPE'
              , i_env_param1  => i_param_id
              , i_env_param2  => l_data_type
              , i_env_param3  => com_api_const_pkg.DATA_TYPE_CHAR
            );
        end if;
    else
        modify_parameter_value (
            i_id           => io_id
          , i_param_id     => i_param_id
          , i_param_value  => i_param_value
        );
    end if;
end set_parameter_value_char;

procedure remove_parameter_value (
    i_id    in              com_api_type_pkg.t_short_id
) is
begin
    delete from prc_parameter_value_vw
     where id = i_id;
end remove_parameter_value;

procedure add_parameter (
    o_id                       out com_api_type_pkg.t_short_id
  , i_param_name            in     com_api_type_pkg.t_attr_name
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_lov_id                in     com_api_type_pkg.t_tiny_id
  , i_parent_id             in     com_api_type_pkg.t_short_id
  , i_label                 in     com_api_type_pkg.t_short_desc
  , i_description           in     com_api_type_pkg.t_full_desc
  , i_lang                  in     com_api_type_pkg.t_dict_value
) is
begin
    -- check parameter type
    if upper (i_data_type) not in(
           com_api_const_pkg.DATA_TYPE_NUMBER
         , com_api_const_pkg.DATA_TYPE_CHAR
         , com_api_const_pkg.DATA_TYPE_DATE
       ) then
        com_api_error_pkg.raise_error(
            i_error         => 'UNKNOWN_DATA_TYPE'
          , i_env_param1    => i_data_type
        );
    end if;

    -- check unique
    for rec in (
        select 1
          from prc_ui_parameter_vw a
         where lower(trim(a.param_name)) = lower(trim(i_param_name))
            or lower(trim(a.label))      = lower(trim(i_label))
    ) loop
        com_api_error_pkg.raise_error(
            i_error      => 'PARAMETER_NAME_NOT_UNIQUE'
          , i_env_param1 => i_param_name
          , i_env_param2 => i_label
        );
    end loop;

    o_id := com_parameter_seq.nextval;
    insert into prc_parameter_vw(
        id
      , param_name
      , data_type
      , lov_id
      , parent_id
    ) values (
        o_id
      , upper(i_param_name)
      , upper(i_data_type)
      , i_lov_id
      , i_parent_id
    );

    -- add/modify description
    com_api_i18n_pkg.add_text (
        i_table_name   => 'prc_parameter'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_text         => i_label
      , i_lang         => i_lang
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prc_parameter'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
    );
end add_parameter;

procedure modify_parameter (
    i_id           in     com_api_type_pkg.t_short_id
  , i_param_name   in     com_api_type_pkg.t_attr_name
  , i_data_type    in     com_api_type_pkg.t_dict_value
  , i_lov_id       in     com_api_type_pkg.t_tiny_id
  , i_parent_id    in     com_api_type_pkg.t_short_id
  , i_label        in     com_api_type_pkg.t_short_desc
  , i_description  in     com_api_type_pkg.t_full_desc
  , i_lang         in     com_api_type_pkg.t_dict_value
) is
begin
    -- check parameter type
    if upper (i_data_type) not in (
              com_api_const_pkg.DATA_TYPE_NUMBER
            , com_api_const_pkg.DATA_TYPE_CHAR
            , com_api_const_pkg.DATA_TYPE_DATE
            )
    then
        com_api_error_pkg.raise_error (
            i_error       => 'UNKNOWN_DATA_TYPE'
          , i_env_param1  => i_data_type
        );
    end if;

    -- check unique
    for rec in (
        select 1
          from prc_ui_parameter_vw a
         where (a.param_name = i_param_name or a.label      = i_label )
           and a.lang        = i_lang
           and a.id         <> i_id
    ) loop
        com_api_error_pkg.raise_error(
            i_error      => 'PARAMETER_NAME_NOT_UNIQUE'
          , i_env_param1 => i_param_name
          , i_env_param2 => i_label
        );
    end loop;

    -- check if used
    for rec in (
        select a.param_name
             , a.data_type
             , a.lov_id
             , a.parent_id
          from prc_ui_process_parameter_vw a
         where a.param_id = i_id
    ) loop
        -- only name and description
        if rec.param_name    != i_param_name
           or rec.data_type  != i_data_type
           or rec.lov_id     != i_lov_id
           or rec.parent_id  != i_parent_id
        then
            com_api_error_pkg.raise_error(
                i_error      => 'PARAMETER_ALREADY_USED'
              , i_env_param1 => rec.param_name
            );
        end if;
    end loop;

    update prc_parameter_vw
       set param_name = nvl(upper(i_param_name), param_name)
         , data_type  = nvl(upper(i_data_type),  data_type)
         , lov_id     = nvl(i_lov_id,            lov_id)
         , parent_id  = nvl(i_parent_id,         parent_id)
     where id         = i_id;

    -- add/modify description
    com_api_i18n_pkg.add_text(
        i_table_name   => 'prc_parameter'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_text         => i_label
      , i_lang         => i_lang
    );

    if i_description is null then
        com_api_i18n_pkg.remove_text(
            i_table_name   => 'prc_parameter'
          , i_column_name  => 'description'
          , i_object_id    => i_id
          , i_lang         => i_lang
        );
    else
        com_api_i18n_pkg.add_text(
            i_table_name   => 'prc_parameter'
          , i_column_name  => 'description'
          , i_object_id    => i_id
          , i_text         => i_description
          , i_lang         => i_lang
        );
    end if;
end modify_parameter;

procedure remove_parameter (
    i_id                    in com_api_type_pkg.t_short_id
) is
begin
    -- check if used
    for rec in (
        select a.param_name
             , a.process_id
          from prc_ui_process_parameter_vw a
         where a.param_id = i_id
    ) loop
        com_api_error_pkg.raise_error(
            i_error      => 'PARAMETER_ALREADY_USED'
          , i_env_param1 => rec.param_name
        );
    end loop;

    com_api_i18n_pkg.remove_text (
        i_table_name => 'prc_parameter'
      , i_object_id  => i_id
    );

    delete from prc_parameter_vw a
     where a.id = i_id;
end;

procedure add_process_parameter (
    o_id                     out com_api_type_pkg.t_short_id
  , i_process_id          in     com_api_type_pkg.t_short_id
  , i_param_id            in     com_api_type_pkg.t_short_id
  , i_default_value_char  in     com_api_type_pkg.t_name
  , i_default_value_num   in     number
  , i_default_value_date  in     date
  , i_display_order       in     com_api_type_pkg.t_tiny_id
  , i_is_format           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_is_mandatory        in     com_api_type_pkg.t_boolean
  , i_lov_id              in     com_api_type_pkg.t_tiny_id    default null
  , i_description         in     com_api_type_pkg.t_full_desc  default null
  , i_lang                in     com_api_type_pkg.t_dict_value default null
) is
    l_data_type           com_api_type_pkg.t_dict_value;
    l_default_value       com_api_type_pkg.t_name;
    l_count               pls_integer;
begin
    select count(id)
      into l_count
      from prc_process_parameter_vw
     where display_order = i_display_order
       and process_id    = i_process_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'PARAMETER_ORDER_NOT_UNIQUE'
          , i_env_param1 => i_process_id
          , i_env_param2 => i_display_order
        );
    end if;

    for rec in (
        select container_process_id
          from prc_container_vw
         where process_id = i_process_id
    ) loop
        com_api_error_pkg.raise_error(
            i_error      => 'UNABLE_CHANGE_PROCESS_PARAMETER'
          , i_env_param1 => i_process_id
          , i_env_param2 => rec.container_process_id
        );
    end loop;

    prc_ui_process_pkg.check_process_using(i_process_id);

    o_id := prc_process_parameter_seq.nextval;

    select data_type
      into l_data_type
      from prc_parameter
     where id = i_param_id;

    if l_data_type = com_api_const_pkg.DATA_TYPE_CHAR then
        l_default_value := i_default_value_char;
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_default_value := to_char(i_default_value_num, com_api_const_pkg.NUMBER_FORMAT);
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_default_value := to_char(i_default_value_date, com_api_const_pkg.DATE_FORMAT);
    end if;

    insert into prc_process_parameter_vw(
        id
      , process_id
      , param_id
      , default_value
      , display_order
      , is_format
      , is_mandatory
      , lov_id
    ) values (
        o_id
      , i_process_id
      , i_param_id
      , l_default_value
      , i_display_order
      , i_is_format
      , i_is_mandatory
      , i_lov_id
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prc_process_parameter'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
    );

exception
    when no_data_found then
        null;
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
            i_error       => 'PARAM_ALREADY_EXISTS'
          , i_env_param1  => i_param_id
          , i_env_param2  => i_process_id
        );
end;

function allow_process_parameter_modify(
    i_process_id            in com_api_type_pkg.t_short_id
  , i_mask_error            in com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_boolean is
begin
    for rec in (
        select container_process_id
          from prc_container_vw
         where process_id = i_process_id
    ) loop
          if i_mask_error = com_api_const_pkg.FALSE then
              com_api_error_pkg.raise_error (
                  i_error         => 'UNABLE_CHANGE_PROCESS_PARAMETER'
                , i_env_param1 => i_process_id
                , i_env_param2 => rec.container_process_id
              );
        else
            return com_api_const_pkg.FALSE;
        end if;
    end loop;
    return com_api_const_pkg.TRUE;
end allow_process_parameter_modify;

procedure modify_process_parameter_desc (
    i_object_id           in     com_api_type_pkg.t_short_id
  , i_description         in     com_api_type_pkg.t_full_desc
  , i_lang                in     com_api_type_pkg.t_dict_value
) is
begin
    if i_description is null then
        com_api_i18n_pkg.remove_text(
            i_table_name   => 'prc_process_parameter'
          , i_column_name  => 'description'
          , i_object_id    => i_object_id
          , i_lang         => i_lang
        );

    else
        com_api_i18n_pkg.add_text(
            i_table_name   => 'prc_process_parameter'
          , i_column_name  => 'description'
          , i_object_id    => i_object_id
          , i_text         => i_description
          , i_lang         => i_lang
        );
    end if;
end modify_process_parameter_desc;

procedure modify_process_parameter (
    i_id                  in     com_api_type_pkg.t_short_id
  , i_default_value_char  in     com_api_type_pkg.t_name
  , i_default_value_num   in     number
  , i_default_value_date  in     date
  , i_display_order       in     com_api_type_pkg.t_tiny_id
  , i_is_format           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_is_mandatory        in     com_api_type_pkg.t_boolean
  , i_lov_id              in     com_api_type_pkg.t_tiny_id    default null
  , i_description         in     com_api_type_pkg.t_full_desc  default null
  , i_lang                in     com_api_type_pkg.t_dict_value default null
) is
    l_data_type           com_api_type_pkg.t_dict_value;
    l_default_value       com_api_type_pkg.t_name;
    l_process_id          com_api_type_pkg.t_short_id;
    l_count               pls_integer;
    l_allow_param_modify  com_api_type_pkg.t_boolean;
begin
    select a.data_type
         , b.process_id
      into l_data_type
         , l_process_id
      from prc_parameter a
         , prc_process_parameter b
     where b.id = i_id
       and a.id = b.param_id;

    select count(id)
      into l_count
      from prc_process_parameter_vw
     where display_order = i_display_order
       and process_id    = l_process_id
       and id           != i_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'PARAMETER_ORDER_NOT_UNIQUE'
          , i_env_param1 => l_process_id
          , i_env_param2 => i_display_order
        );
    end if;

    l_allow_param_modify := allow_process_parameter_modify(
                                i_process_id => l_process_id
                              , i_mask_error => com_api_const_pkg.FALSE
                            );

    prc_ui_process_pkg.check_process_using(l_process_id);

    if l_data_type = com_api_const_pkg.DATA_TYPE_CHAR then
        l_default_value := i_default_value_char;
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_default_value := to_char(i_default_value_num, com_api_const_pkg.NUMBER_FORMAT);
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_default_value := to_char(i_default_value_date, com_api_const_pkg.DATE_FORMAT);
    end if;

    update prc_process_parameter_vw
       set default_value = l_default_value
         , display_order = i_display_order
         , is_format     = i_is_format
         , is_mandatory  = i_is_mandatory
         , lov_id        = i_lov_id
     where id            = i_id;

    modify_process_parameter_desc(
        i_object_id => i_id
      , i_description => i_description
      , i_lang => i_lang
    );
end modify_process_parameter;

procedure remove_process_parameter (
    i_id                  in     com_api_type_pkg.t_short_id
) is
    l_process_id                 com_api_type_pkg.t_short_id;
    l_container_process_id       com_api_type_pkg.t_short_id;
begin
    select pp.process_id
         , c.container_process_id
      into l_process_id
         , l_container_process_id
      from prc_process_parameter_vw pp
      left join prc_container_vw c     on pp.process_id = c.process_id
     where pp.id = i_id
       and rownum = 1;

    if l_container_process_id is not null then
        com_api_error_pkg.raise_error(
            i_error      => 'UNABLE_CHANGE_PROCESS_PARAMETER'
          , i_env_param1 => l_process_id
          , i_env_param2 => l_container_process_id
        );
    end if;

    prc_ui_process_pkg.check_process_using(i_id => l_process_id); -- Are there any schedule tasks for the process? 

    delete prc_process_parameter_vw
     where id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name   => 'prc_process_parameter'
      , i_object_id    => i_id
    );
end;

procedure sync_container_parameters (
    i_container_process_id  in com_api_type_pkg.t_short_id
    , i_process_id          in com_api_type_pkg.t_short_id
) is
    l_id                    com_api_type_pkg.t_short_id;
begin
    -- Add parameters
    for rec in (
        select
            d.param_id
            , case when data_type = com_api_const_pkg.DATA_TYPE_CHAR then d.default_value
                   else null
              end default_value_char
            , case when data_type = com_api_const_pkg.DATA_TYPE_NUMBER then to_number(d.default_value, com_api_const_pkg.NUMBER_FORMAT)
                   else null
              end default_value_num
            , case when data_type = com_api_const_pkg.DATA_TYPE_DATE then to_date(d.default_value, com_api_const_pkg.DATE_FORMAT)
                   else null
              end default_value_date
            , d.display_order
            , d.is_format
            , d.is_mandatory
            , a.data_type
        from
            prc_process_parameter_vw d
            , prc_parameter_vw a
        where
            d.process_id = i_process_id
            and a.id = d.param_id
            and d.param_id in (
                select distinct b.param_id
                  from prc_process_parameter_vw b
                 where b.process_id = i_process_id
                minus
                select c.param_id
                  from prc_process_parameter_vw c
                 where c.process_id = i_container_process_id
            )
    ) loop
        add_process_parameter (
            o_id                  => l_id
          , i_process_id          => i_container_process_id
          , i_param_id            => rec.param_id
          , i_default_value_char  => rec.default_value_char
          , i_default_value_num   => rec.default_value_num
          , i_default_value_date  => rec.default_value_date
          , i_display_order       => rec.display_order
          , i_is_format           => rec.is_format
          , i_is_mandatory        => rec.is_mandatory
        );
    end loop;
end sync_container_parameters;

procedure remove_container_parameters (
    i_container_id          in com_api_type_pkg.t_short_id
) is
begin
    -- remove container process value
    for rec in (
        select id
          from prc_parameter_value_vw
         where container_id = i_container_id
    ) loop
        remove_parameter_value(
            i_id  => rec.id
        );
    end loop;
    -- remove container process parameters
    for rec1 in (
        select a.container_process_id
             , a.process_id
          from prc_container_vw a
         where a.id = i_container_id
    ) loop
        for rec2 in (
            select a.id
              from prc_process_parameter_vw a
             where a.process_id = rec1.container_process_id
               and a.param_id not in (
                   select d.param_id
                     from prc_process_parameter d
                    where d.process_id in (select b.process_id
                                             from prc_container b
                                            where b.container_process_id  = rec1.container_process_id
                                              and b.process_id != rec1.process_id
                                           )
            )
        ) loop
            remove_process_parameter(
                i_id  => rec2.id
            );
        end loop;
    end loop;

end;

procedure check_process_param (
    i_process_id            in com_api_type_pkg.t_short_id
) is
    l_flag      com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_count     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_proc_name com_api_type_pkg.t_name;
    l_log       com_api_type_pkg.t_param_value;
begin
    for rec in (
        select a.procedure_name
          from prc_process_vw a
         where a.id = i_process_id
           and a.procedure_name is not null
    ) loop

        l_log := 'Check parameters for procedure ' || rec.procedure_name || chr(10);

        for r1 in (
            select ua.argument_name
                 , ua.data_type
              from user_arguments ua
             where ua.package_name = regexp_substr(rec.procedure_name, '\w+')
               and ua.object_name  = regexp_substr(rec.procedure_name, '\w+', 1, 2)
               and ua.defaulted    = 'N'
        ) loop

            l_log := l_log || 'Check parameter ' || r1.argument_name || chr(10);

            select count(1)
              into l_count
              from prc_process a
                 , prc_process_parameter b
                 , prc_parameter c
             where a.id                = b.process_id
               and c.id                = b.param_id
               and upper(c.param_name) = r1.argument_name
               and b.process_id        = i_process_id;

            if l_count = 0 then
                l_proc_name := rec.procedure_name;
                l_flag := com_api_type_pkg.TRUE;

                l_log := l_log || 'Error! Parameter ' || r1.argument_name || ' not found' || chr(10);

            else
                l_log := l_log || 'Parameter ' || r1.argument_name || ' found' || chr(10);
                l_count := 0;
            end if;
        end loop;

    end loop;

    trc_log_pkg.debug(l_log);

    if l_flag = com_api_type_pkg.TRUE then
        com_api_error_pkg.raise_error(
            i_error       => 'PRC_BIND_PARAM_NOT_FOUND'
          , i_env_param1  => l_proc_name
          , i_env_param2  => i_process_id
        );
    end if;

end check_process_param;

end prc_ui_parameter_pkg;
/
