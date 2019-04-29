create or replace package body rul_ui_mod_pkg is
/*********************************************************
*  UI rules <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 11.03.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: rul_ui_mod_pkg <br />
*  @headcom
**********************************************************/

procedure check_dup_scale(
    i_id                     in     com_api_type_pkg.t_tiny_id
  , i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_name                   in     com_api_type_pkg.t_name
) is
    l_count    com_api_type_pkg.t_count := 0;
begin
    select count(1)
      into l_count
      from rul_ui_mod_scale_vw
     where id     != i_id
       and inst_id = i_inst_id
       and name    = i_name;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'DESCRIPTION_IS_NOT_UNIQUE'
          , i_env_param1  => upper('rul_mod_scale')
          , i_env_param2  => upper('name')
          , i_env_param3  => i_name
        );
    end if;
end;

procedure add_scale (
    o_id                     out    com_api_type_pkg.t_tiny_id
  , o_seqnum                 out    com_api_type_pkg.t_seqnum
  , i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_type                   in     com_api_type_pkg.t_dict_value
  , i_lang                   in     com_api_type_pkg.t_dict_value
  , i_name                   in     com_api_type_pkg.t_name
  , i_description            in     com_api_type_pkg.t_full_desc
) is
    l_check_cnt    com_api_type_pkg.t_count := 0;
begin
    if i_type in (
        rul_api_const_pkg.SCALE_TYPE_SCENARIO
      , rul_api_const_pkg.SCALE_TYPE_CHOISE_HSM
      , rul_api_const_pkg.SCALE_TYPE_SETTLEMENT
      , rul_api_const_pkg.SCALE_TYPE_RULES
      , rul_api_const_pkg.SCALE_TYPE_APP_FLOW
    ) then
        if i_type in (
            rul_api_const_pkg.SCALE_TYPE_SCENARIO
          , rul_api_const_pkg.SCALE_TYPE_SETTLEMENT
          , rul_api_const_pkg.SCALE_TYPE_RULES
        ) and i_inst_id <> ost_api_const_pkg.DEFAULT_INST then
            com_api_error_pkg.raise_error (
                i_error      => 'SCALE_TYPE_SCENARIO_ONLY_SYSTEM_INST'
              , i_env_param1 => i_inst_id
            );
        end if;

        select count(*)
          into l_check_cnt
          from (
            select 1
              from rul_mod_scale_vw
             where inst_id    = i_inst_id
               and scale_type = i_type
               and rownum = 1
        );
    end if;

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error      => 'SCALE_ALREADY_EXIST'
          , i_env_param1 => i_inst_id
          , i_env_param2 => i_type
        );
    end if;
   
    o_id := rul_mod_scale_seq.nextval;
    o_seqnum := 1;

    check_dup_scale(
        i_id         => o_id
      , i_inst_id    => i_inst_id
      , i_name       => i_name
    );
    
    insert into rul_mod_scale_vw (
        id
      , inst_id
      , scale_type
      , seqnum
    ) values (
        o_id
      , i_inst_id
      , i_type
      , o_seqnum
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'rul_mod_scale'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_name
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'rul_mod_scale'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_description
    );
end;

procedure modify_scale (
    i_id                     in     com_api_type_pkg.t_tiny_id
  , io_seqnum                in out com_api_type_pkg.t_seqnum
  , i_type                   in     com_api_type_pkg.t_dict_value
  , i_lang                   in     com_api_type_pkg.t_dict_value
  , i_name                   in     com_api_type_pkg.t_name
  , i_description            in     com_api_type_pkg.t_full_desc
) is
    l_check_cnt              com_api_type_pkg.t_count := 0;
    l_inst_id                com_api_type_pkg.t_inst_id;
begin
    for rec in (
        select inst_id
             , scale_type
          from rul_mod_scale_vw
         where id = i_id
    ) loop
        l_inst_id := rec.inst_id;
        if rec.scale_type <> i_type then
            if i_type in (
                rul_api_const_pkg.SCALE_TYPE_SCENARIO
              , rul_api_const_pkg.SCALE_TYPE_CHOISE_HSM
              , rul_api_const_pkg.SCALE_TYPE_SETTLEMENT
              , rul_api_const_pkg.SCALE_TYPE_RULES
              , rul_api_const_pkg.SCALE_TYPE_APP_FLOW
            ) then
                if i_type in (
                    rul_api_const_pkg.SCALE_TYPE_SCENARIO
                  , rul_api_const_pkg.SCALE_TYPE_SETTLEMENT
                  , rul_api_const_pkg.SCALE_TYPE_RULES
                ) and rec.inst_id <> ost_api_const_pkg.DEFAULT_INST then
                    com_api_error_pkg.raise_error (
                        i_error      => 'SCALE_TYPE_SCENARIO_ONLY_SYSTEM_INST'
                      , i_env_param1 => rec.inst_id
                    );
                end if;

                select count(*)
                into l_check_cnt
                from (select 1 from prd_attribute_scale_vw where scale_id = i_id and rownum = 1
                      union all
                      select 1 from evt_event where scale_id = i_id and rownum = 1
                      union all
                      select 1 from net_member where scale_id = i_id and rownum = 1
                      union all
                      select 1 from ntf_scheme_event where scale_id = i_id and rownum = 1
                     );
                if l_check_cnt > 0 then
                    com_api_error_pkg.raise_error(
                        i_error      => 'SCALE_HAS_DEPENDANT'
                      , i_env_param1 => i_id
                    );
                end if;

                select count(*)
                  into l_check_cnt
                  from (
                    select 1
                      from rul_mod_scale_vw
                     where inst_id    = rec.inst_id
                       and scale_type = i_type
                       and rownum = 1
                );
            end if;
        end if;

        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error      => 'SCALE_ALREADY_EXIST'
              , i_env_param1 => rec.inst_id
              , i_env_param2 => i_type
            );
        end if;

        exit;
    end loop;

    check_dup_scale(
        i_id         => i_id
      , i_inst_id    => l_inst_id
      , i_name       => i_name
    );

    update rul_mod_scale_vw
       set scale_type = i_type
         , seqnum     = io_seqnum
     where id         = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text (
        i_table_name    => 'rul_mod_scale'
      , i_column_name   => 'name'
      , i_object_id     => i_id
      , i_lang          => i_lang
      , i_text          => i_name
    );

    com_api_i18n_pkg.add_text (
        i_table_name    => 'rul_mod_scale'
      , i_column_name   => 'description'
      , i_object_id     => i_id
      , i_lang          => i_lang
      , i_text          => i_description
    );
end;

procedure remove_scale (
    i_id                     in      com_api_type_pkg.t_tiny_id
  , i_seqnum                 in      com_api_type_pkg.t_seqnum
) is
    l_check_cnt              com_api_type_pkg.t_count := 0;
begin
    select count(*)
      into l_check_cnt
      from (select 1 from rul_mod_scale_param_vw where scale_id = i_id and rownum = 1
            union all
            select 1 from rul_mod_vw where scale_id = i_id and rownum = 1
            union all
            select 1 from prd_attribute_scale_vw where scale_id = i_id and rownum = 1
            union all
            select 1 from evt_event where scale_id = i_id and rownum = 1
            union all
            select 1 from net_member where scale_id = i_id and rownum = 1
            union all
            select 1 from ntf_scheme_event where scale_id = i_id and rownum = 1
           );

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'SCALE_HAS_DEPENDANT'
          , i_env_param1 => i_id
        );
    else
        update rul_mod_scale_vw
           set seqnum = i_seqnum
         where id     = i_id;

        delete from rul_mod_scale_vw
         where id     = i_id;

        com_api_i18n_pkg.remove_text (
            i_table_name  => 'rul_mod_scale'
          , i_object_id   => i_id
        );
    end if;
end;

procedure add_param (
    o_id                        out com_api_type_pkg.t_short_id
  , i_name                   in     com_api_type_pkg.t_name
  , i_data_type              in     com_api_type_pkg.t_dict_value
  , i_lov_id                 in     com_api_type_pkg.t_tiny_id
  , i_lang                   in     com_api_type_pkg.t_dict_value
  , i_short_description      in     com_api_type_pkg.t_name
  , i_description            in     com_api_type_pkg.t_full_desc
) is
    l_count                  com_api_type_pkg.t_tiny_id;
begin
    select count(1)
      into l_count
      from rul_mod_param_vw
     where upper(trim(name)) = upper(trim(i_name));

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error      => 'PARAM_NAME_EXISTS'
          , i_env_param1 =>  upper(trim(i_name))
          , i_env_param2 => 'RUL'
        );
    end if;

    if length(i_name) > 28 then
        com_api_error_pkg.raise_error(
            i_error      => 'PARAMETER_NAME_TOO_LONG'
          , i_env_param1 => length(i_name)
        );
    end if;

    o_id := com_parameter_seq.nextval;

    insert into rul_mod_param_vw (
        id
      , name
      , data_type
      , lov_id
    ) values (
        o_id
      , i_name
      , i_data_type
      , i_lov_id
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'rul_mod_param'
      , i_column_name  => 'short_description'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_short_description
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'rul_mod_param'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_description
    );
end;

procedure modify_param (
    i_id                 in     com_api_type_pkg.t_short_id
  , i_data_type          in     com_api_type_pkg.t_dict_value
  , i_lov_id             in     com_api_type_pkg.t_tiny_id
  , i_lang               in     com_api_type_pkg.t_dict_value
  , i_short_description  in     com_api_type_pkg.t_name
  , i_description        in     com_api_type_pkg.t_full_desc
) is
begin
    update rul_mod_param_vw
       set data_type = i_data_type
         , lov_id    = i_lov_id
     where id        = i_id;

    com_api_i18n_pkg.add_text (
        i_table_name   => 'rul_mod_param'
      , i_column_name  => 'short_description'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_short_description
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'rul_mod_param'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_description
    );
end;

procedure remove_param (
    i_id         in     com_api_type_pkg.t_short_id
) is
    l_check_cnt             number;
begin
    select count(*)
      into l_check_cnt
      from rul_mod_scale_param_vw
     where param_id = i_id
       and rownum   = 1;

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error      => 'MOD_PARAM_INCLUDED_IN_SCALE'
          , i_env_param1 => i_id
          , i_env_param2 => com_api_i18n_pkg.get_text('rul_mod_param','short_description', i_id, get_user_lang)
        );
    else
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'rul_mod_param'
          , i_object_id    => i_id
        );

        delete from rul_mod_param
        where id = i_id;
    end if;
end;

procedure include_param_in_scale (
    i_param_id               in     com_api_type_pkg.t_tiny_id
  , i_scale_id               in     com_api_type_pkg.t_tiny_id
  , i_seqnum                 in     com_api_type_pkg.t_seqnum
) is
begin
    update rul_mod_scale_vw
       set seqnum = i_seqnum
     where id     = i_scale_id;

    begin
        insert into rul_mod_scale_param_vw (
            id
          , scale_id
          , param_id
        ) values (
            rul_mod_scale_param_seq.nextval
          , i_scale_id
          , i_param_id
        );
    exception
        when dup_val_on_index then
            null;
    end;
end;

procedure remove_param_from_scale (
    i_param_id               in     com_api_type_pkg.t_tiny_id
  , i_scale_id               in     com_api_type_pkg.t_tiny_id
  , i_seqnum                 in     com_api_type_pkg.t_seqnum
) is
    l_count                 pls_integer;
begin

    select count(1)
      into l_count
      from rul_mod_vw a
         , rul_mod_param_vw b
     where a.scale_id = i_scale_id
       and b.id       = i_param_id
       and upper(a.condition) like '%:'||upper(b.name)||'%';

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error => 'MOD_PARAM_IS_IN_USE'
        );
    end if;

    update rul_mod_scale_vw
       set seqnum = i_seqnum
     where id     = i_scale_id;

    delete from rul_mod_scale_param_vw
     where scale_id = i_scale_id
       and param_id = i_param_id;
end;

procedure add_mod (
    o_id                        out com_api_type_pkg.t_tiny_id
  , o_seqnum                    out com_api_type_pkg.t_seqnum
  , i_scale_id               in     com_api_type_pkg.t_tiny_id
  , i_condition              in     com_api_type_pkg.t_text
  , i_priority               in     com_api_type_pkg.t_tiny_id
  , i_lang                   in     com_api_type_pkg.t_dict_value
  , i_name                   in     com_api_type_pkg.t_name
  , i_description            in     com_api_type_pkg.t_full_desc
) is
begin
    check_mod(
        i_mod_id      => null
      , i_scale_id    => i_scale_id
      , i_priority    => i_priority
      , i_name        => i_name
      , i_description => i_description
    );

    o_id     := rul_mod_seq.nextval;
    o_seqnum := 1;

    insert into rul_mod_vw (
        id
      , scale_id
      , condition
      , priority
      , seqnum
    ) values (
        o_id
      , i_scale_id
      , i_condition
      , nvl(i_priority, o_id)
      , o_seqnum
    );

    commit;

    -- Recompile package
    begin
        rul_mod_gen_pkg.nop;
    exception
        when others then null;
    end;

    begin
        rul_mod_gen_pkg.generate_package(
            i_mod_id => o_id
        );
    exception
        when others then
            trc_log_pkg.debug(sqlerrm);

            delete from rul_mod_vw where id = o_id;

            commit;

            rul_mod_gen_pkg.generate_package(
                i_mod_id => o_id
            );

            com_api_error_pkg.raise_error(
                i_error       => 'NOT_VALID_MOD_CONDITION'
              , i_env_param1  => i_condition
              , i_env_param2  => sqlerrm
            );
    end;
    
    com_api_i18n_pkg.add_text (
        i_table_name   => 'rul_mod'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_name
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'rul_mod'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_description
    );
end;

procedure modify_mod (
    i_id            in     com_api_type_pkg.t_tiny_id
  , io_seqnum       in out com_api_type_pkg.t_seqnum
  , i_condition     in     com_api_type_pkg.t_text
  , i_priority      in     com_api_type_pkg.t_tiny_id
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_name          in     com_api_type_pkg.t_name
  , i_description   in     com_api_type_pkg.t_full_desc
) is
    l_old_condition        com_api_type_pkg.t_text;
    l_old_priority         com_api_type_pkg.t_tiny_id;
    l_old_seqnum           com_api_type_pkg.t_seqnum;
    l_scale_id             com_api_type_pkg.t_tiny_id;
begin
    select scale_id
      into l_scale_id
      from rul_mod_vw
     where id = i_id;

    check_mod(
        i_mod_id      => i_id
      , i_scale_id    => l_scale_id
      , i_priority    => i_priority
      , i_name        => i_name
      , i_description => i_description
    );

    select condition
         , priority
         , seqnum
      into l_old_condition
         , l_old_priority
         , l_old_seqnum
      from rul_mod_vw
     where id = i_id;

    update rul_mod_vw
       set seqnum    = io_seqnum
         , condition = i_condition
         , priority  = i_priority
     where id        = i_id;


    if l_old_condition != i_condition then

        commit;

        begin
            rul_mod_gen_pkg.generate_package(
                i_mod_id           => i_id
              , i_is_modification  => com_api_const_pkg.TRUE
            );
        exception
            when others then
                -- Audit changes via trigger of the 'rul_mod_vw' view.
                update rul_mod_vw
                   set condition = l_old_condition
                     , priority  = l_old_priority
                 where id = i_id;

                -- If update the 'rul_mod_vw' view then its trigger will auto-increase the 'seqnum' value.
                update rul_mod
                   set seqnum = l_old_seqnum
                 where id = i_id;

                commit;

                rul_mod_gen_pkg.generate_package(
                    i_mod_id           => i_id
                  , i_is_modification  => com_api_const_pkg.TRUE
                );

                com_api_error_pkg.raise_error(
                    i_error         => 'NOT_VALID_MOD_CONDITION'
                  , i_env_param1    => i_condition
                );
        end;
    end if;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text (
        i_table_name    => 'rul_mod'
      , i_column_name   => 'name'
      , i_object_id     => i_id
      , i_lang          => i_lang
      , i_text          => i_name
    );

    com_api_i18n_pkg.add_text (
        i_table_name    => 'rul_mod'
      , i_column_name   => 'description'
      , i_object_id     => i_id
      , i_lang          => i_lang
      , i_text          => i_description
    );
end modify_mod;

procedure remove_mod (
    i_id                     in     com_api_type_pkg.t_tiny_id
  , i_seqnum                 in     com_api_type_pkg.t_seqnum
) is
begin
    rul_api_mod_pkg.check_process_uses_modifier;

    update rul_mod_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from rul_mod_vw
     where id     = i_id;

    -- Recompile package
    begin
        rul_mod_gen_pkg.nop;
    exception
        when others then null;
    end;

    rul_mod_gen_pkg.generate_package(
        i_mod_id => i_id
    );

    com_api_i18n_pkg.remove_text (
        i_table_name  => 'rul_mod'
      , i_object_id   => i_id
    );
end remove_mod;

procedure check_mod(
    i_mod_id       in     com_api_type_pkg.t_tiny_id
  , i_scale_id     in     com_api_type_pkg.t_tiny_id
  , i_priority     in     com_api_type_pkg.t_tiny_id
  , i_name         in     com_api_type_pkg.t_name
  , i_description  in     com_api_type_pkg.t_full_desc
) is
begin
    rul_api_mod_pkg.check_mod(
        i_mod_id       => i_mod_id
      , i_scale_id     => i_scale_id
      , i_priority     => i_priority
      , i_name         => i_name
      , i_description  => i_description
    );
end check_mod;

end;
/
