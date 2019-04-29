create or replace package body rul_api_mod_pkg is

function check_condition (
    i_mod_id                in com_api_type_pkg.t_tiny_id
    , i_params              in com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_boolean is
begin
    return rul_mod_static_pkg.check_condition(
               i_mod_id  => i_mod_id
             , i_params  => i_params
           );
end;

function select_condition (
    i_mods                  in com_api_type_pkg.t_number_tab
    , i_params              in com_api_type_pkg.t_param_tab
    , i_mask_error          in com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
    , i_error_value         in binary_integer                   default null
) return binary_integer is
begin
    for i in 1 .. i_mods.count loop
        if i_mods(i) is null then
            return i;
        elsif rul_mod_static_pkg.check_condition (
                  i_mod_id   => i_mods(i)
                , i_params   => i_params
              ) = com_api_const_pkg.TRUE
        then
            return i;
        end if;
    end loop;

    if i_mask_error = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_error(
            i_error             => 'NO_APPLICABLE_CONDITION'
            , i_env_param1      => rul_api_param_pkg.serialize_params(i_params)
        );
    else
        trc_log_pkg.debug(
            i_text              => 'NO_APPLICABLE_CONDITION'
            , i_env_param1      => rul_api_param_pkg.serialize_params(i_params)
        );

        return i_error_value;
    end if;
end;

function select_value (
    i_mods                  in com_api_type_pkg.t_number_tab
    , i_values              in com_api_type_pkg.t_varchar2_tab
    , i_params              in com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_param_value is
    l_condition             binary_integer;
begin
    l_condition := select_condition(
                       i_mods    => i_mods
                     , i_params  => i_params
                   );
    return i_values(l_condition);
exception
    when com_api_error_pkg.e_value_error then
        com_api_error_pkg.raise_error(
            i_error             => 'NO_VALUE_FOR_CONDITION'
            , i_env_param1      => l_condition
        );
end;

function get_mod_id (
    i_scale_type            in com_api_type_pkg.t_dict_value
    , i_params              in com_api_type_pkg.t_param_tab
    , i_inst_id             in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_tiny_id
is
    l_mod_id_tab            com_api_type_pkg.t_number_tab;
    l_scale_count_tab       com_api_type_pkg.t_number_tab;
begin
    select m.id
         , count(distinct s.id) over (partition by 1)
      bulk collect into
           l_mod_id_tab
         , l_scale_count_tab
      from rul_mod_scale s
         , rul_mod m
     where s.scale_type = i_scale_type
       and s.inst_id = i_inst_id
       and s.id = m.scale_id
     order by
           m.priority;

    if l_scale_count_tab.count > 0 then
        if l_scale_count_tab(1) > 1 then
            com_api_error_pkg.raise_error (
                i_error         => 'TOO_MANY_SCALES_OF_TYPE'
                , i_env_param1  => i_scale_type
            );
        end if;
    end if;

    trc_log_pkg.debug (
        i_text          => 'Going to check [#1] mods of scale [#2]'
        , i_env_param1  => l_mod_id_tab.count
        , i_env_param2  => i_scale_type
    );

    return l_mod_id_tab(select_condition(l_mod_id_tab, i_params));
end;

procedure select_mods(
    i_scale_type        in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default null
  , i_params            in      com_api_type_pkg.t_param_tab
  , o_mods                 out  num_tab_tpt
) is
    l_mods              com_api_type_pkg.t_number_tab;
    l_scale_count_tab   com_api_type_pkg.t_number_tab;
begin
    o_mods := num_tab_tpt();

    select m.id
         , count(distinct s.id) over (partition by 1)
      bulk collect into
           l_mods
         , l_scale_count_tab
      from rul_mod_scale s
         , rul_mod m
     where s.scale_type = i_scale_type
       and s.inst_id = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
       and s.id = m.scale_id;

    if l_scale_count_tab.count > 0 then
        if l_scale_count_tab(1) > 1 then
            com_api_error_pkg.raise_error (
                i_error         => 'TOO_MANY_SCALES_OF_TYPE'
                , i_env_param1  => i_scale_type
            );
        end if;
    end if;

    for i in 1 .. l_mods.count loop
        if  rul_mod_static_pkg.check_condition (
                i_mod_id      => l_mods(i)
              , i_params      => i_params
            ) = com_api_const_pkg.TRUE
        then
            o_mods.extend(1);
            o_mods(o_mods.count) := l_mods(i);
        end if;
    end loop;
end;

procedure check_mod (
    i_mod_id       in     com_api_type_pkg.t_tiny_id
  , i_scale_id     in     com_api_type_pkg.t_tiny_id
  , i_priority     in     com_api_type_pkg.t_tiny_id
  , i_name         in     com_api_type_pkg.t_name
  , i_description  in     com_api_type_pkg.t_full_desc
) is
    l_label_cnt     com_api_type_pkg.t_tiny_id;
    --l_desc_cnt      com_api_type_pkg.t_tiny_id;
    l_inst_id       com_api_type_pkg.t_inst_id;
begin
    check_process_uses_modifier;

    if i_priority is not null then
        for rec in (
            select a.id
              from rul_mod a
             where a.scale_id = i_scale_id
               and a.priority = i_priority
               and (a.id     != i_mod_id or i_mod_id is null)
        ) loop
            com_api_error_pkg.raise_error(
                i_error      => 'MOD_ALREADY_EXISTS'
              , i_env_param1 => rec.id
              , i_env_param2 => i_scale_id
              , i_env_param3 => i_priority
            );
        end loop;
    end if;

    select inst_id
      into l_inst_id
      from rul_mod_scale s
     where id = i_scale_id;

    trc_log_pkg.debug(
        i_text => 'check_mod: inst_id [' || l_inst_id
               || '], i_name [' || i_name
               || '], i_desc [' || i_description || ']'
    );

    select sum(case i.column_name when 'NAME'        then 1 else 0 end) as label_cnt
         --, sum(case i.column_name when 'DESCRIPTION' then 1 else 0 end) as desc_cnt
      into l_label_cnt
         --, l_desc_cnt
      from com_i18n i
         , rul_mod m
         , rul_mod_scale s
     where m.id           = i.object_id
       and m.scale_id     = s.id
       and i.table_name   = 'RUL_MOD'
       and (i.column_name, i.text) in (('NAME', i_name), ('DESCRIPTION', i_description))
       and s.inst_id      = l_inst_id
       and (m.id         != i_mod_id or i_mod_id is null)
--           and lang        = nvl(i_lang, com_ui_user_env_pkg.get_user_lang)
    ;
    if l_label_cnt > 0 then --or l_desc_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'DESCRIPTION_IS_NOT_UNIQUE'
          , i_env_param1  => 'RUL_MOD'
          , i_env_param2  => case when l_label_cnt > 0  then 'NAME' else 'DESCRIPTION' end
          , i_env_param3  => case when l_label_cnt > 0  then i_name else i_description end
        );
    end if;
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
    pragma autonomous_transaction;
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

    insert into rul_mod (
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

            delete from rul_mod where id = o_id;

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
end add_mod;

procedure check_process_uses_modifier is
    l_process_id    com_api_type_pkg.t_short_id;
begin
    select max(ci.process_id)
      into l_process_id
      from prc_api_client_info_vw ci
      where ci.process_id in (
                select to_char(numeric_value)
                  from com_array_element e
                 where e.array_id = prc_api_const_pkg.ARRAY_PROCESS_USES_MODIFIER
            )
        and rownum = 1;

    if l_process_id is not null then
        com_api_error_pkg.raise_error(
            i_error       => 'RUNNING_PROCESS_USES_MODIFIER'
          , i_env_param1  => l_process_id
        );
    end if;
end check_process_uses_modifier;

end;
/
