create or replace package body rul_api_name_pkg as
/***************************************************************
 *  Naming service <br />
 *  Created by Kryukov E.(krukov@bpc.ru)  at 01.04.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: RUL_API_NAME_PKG <br />
 *  @headcom
 ***************************************************************/

function pad_str(
    i_pad_type     in     com_api_type_pkg.t_dict_value
  , i_src          in     com_api_type_pkg.t_param_value
  , i_pad_string   in     com_api_type_pkg.t_dict_value
  , i_length       in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_lob_data is
    l_str                 com_api_type_pkg.t_lob_data;
begin
    if i_pad_type = rul_api_const_pkg.PAD_TYPE_RIGHT then
        l_str := rpad (
            str1    => i_src
            , len   => i_length
            , pad   => i_pad_string
        );

    else-- rul_api_const_pkg.PAD_TYPE_LEFT
        l_str := lpad (
            str1    => i_src
            , len   => i_length
            , pad   => i_pad_string
        );
    end if;

    return l_str;
end;

function pad_byte_len (
    i_src          in     com_api_type_pkg.t_param_value
  , i_pad_type     in     com_api_type_pkg.t_dict_value
  , i_pad_string   in     com_api_type_pkg.t_dict_value
  , i_length       in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_lob_data is
begin
    return pad_str (
        i_pad_type   => i_pad_type
      , i_src        => i_src
      , i_pad_string => nvl(i_pad_string, '0')
      , i_length     => nvl(i_length * 2, length(i_src) + mod(length(i_src), 2))
    );
end;

function pad_str(
    i_pad_type     in     com_api_type_pkg.t_dict_value
  , i_src          in     com_api_type_pkg.t_param_value
  , i_pad_string   in     com_api_type_pkg.t_dict_value
  , i_length       in     com_api_type_pkg.t_tiny_id
  , i_format_id    in     com_api_type_pkg.t_tiny_id
  , i_component    in     com_api_type_pkg.t_param_value
  , i_entity_type  in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_param_value is
    l_str                 com_api_type_pkg.t_param_value;
begin
    if i_pad_type is null or i_pad_string is null then
        com_api_error_pkg.raise_error (
            i_error      => 'RUL_NAME_UNKNOWN_PAD'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_format_id
          , i_env_param3 => get_article_text(i_pad_type)||' "'||i_pad_string||'"'
          , i_env_param4 => i_component
          , i_env_param5 => i_src
          , i_env_param6 => i_length
        );

    elsif i_pad_type in (rul_api_const_pkg.PAD_TYPE_RIGHT, rul_api_const_pkg.PAD_TYPE_LEFT) then
        l_str := pad_str (
            i_pad_type   => i_pad_type
          , i_src        => nvl(i_src, i_pad_string)
          , i_pad_string => i_pad_string
          , i_length     => i_length
        );

    else
        com_api_error_pkg.raise_error (
            i_error      => 'RUL_NAME_UNKNOWN_PAD'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_format_id
          , i_env_param3 => get_article_text(i_pad_type)||' "'||i_pad_string||'"'
          , i_env_param4 => i_component
          , i_env_param5 => i_src
          , i_env_param6 => i_length
        );
    end if;

    return l_str;

end pad_str;

function trunc_str (
    i_trunc_type  in     com_api_type_pkg.t_dict_value
  , i_src         in     com_api_type_pkg.t_param_value
  , i_length      in     com_api_type_pkg.t_tiny_id
  , i_format_id   in     com_api_type_pkg.t_tiny_id
  , i_component   in     com_api_type_pkg.t_param_value
  , i_entity_type in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_param_value is
begin
    if i_trunc_type is null or i_trunc_type not in (
            rul_api_const_pkg.PAD_TYPE_LEFT
          , rul_api_const_pkg.PAD_TYPE_RIGHT) then

        com_api_error_pkg.raise_error (
            i_error      => 'RUL_NAME_UNKNOWN_PAD'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_format_id
          , i_env_param3 => get_article_text(i_trunc_type)
          , i_env_param4 => i_component
          , i_env_param5 => i_src
          , i_env_param6 => i_length
        );

    end if;

    return substr(
        str1  => i_src
        , pos => case
                    when i_trunc_type = rul_api_const_pkg.PAD_TYPE_LEFT then -i_length
                    else 1
                 end
        , len => i_length
    );
end trunc_str;

function get_part (
    i_format_id    in     com_api_type_pkg.t_tiny_id
  , i_part_rec     in     rul_api_type_pkg.t_name_part_rec
  , i_component    in     com_api_type_pkg.t_param_value := null
  , i_entity_type  in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_param_value is

    l_str                     com_api_type_pkg.t_param_value;
    l_stmt                    com_api_type_pkg.t_text;

begin
    l_stmt := 'select ' || i_component || ' from dual';

    begin
        execute immediate l_stmt into l_str;
    exception
        when com_api_error_pkg.e_application_error then
            raise;
        when others then
            com_api_error_pkg.raise_error (
                i_error       => 'ERROR_TRANSFORMATION'
              , i_env_param1  => i_part_rec.transformation_type
              , i_env_param2  => i_part_rec.transformation_mask
              , i_env_param3  => l_stmt
              , i_env_param4  => sqlerrm
              , i_env_param5  => i_format_id
            );
    end;

    if i_part_rec.part_length is not null then
        if nvl(length(l_str), 0) < i_part_rec.part_length then
            if i_part_rec.pad_type is null or i_part_rec.pad_string is null then
                -- small string, param: component_id, format_id
                com_api_error_pkg.raise_error(
                    i_error      => 'RUL_NAME_UNKNOWN_PAD'
                  , i_env_param1 => i_entity_type
                  , i_env_param2 => i_part_rec.format_id
                  , i_env_param3 => get_article_text(i_part_rec.pad_type)||' "'||i_part_rec.pad_string||'"'
                  , i_env_param4 => i_component
--                  , i_env_param5 => i_src
--                  , i_env_param6 => i_length
                );
            else
            -- pad
              l_str := pad_str(
                  i_pad_type    => i_part_rec.pad_type
                , i_src         => l_str
                , i_pad_string  => i_part_rec.pad_string
                , i_length      => i_part_rec.part_length
                , i_format_id   => i_format_id
                , i_component   => i_component
                , i_entity_type => i_entity_type
              );

            end if;

        elsif nvl(length(l_str), 0) > i_part_rec.part_length then
            l_str := trunc_str(
                i_trunc_type  => i_part_rec.pad_type
              , i_src         => l_str
              , i_length      => i_part_rec.part_length
              , i_format_id   => i_format_id
              , i_component   => i_component
              , i_entity_type => i_entity_type
            );

        end if;
    end if;

    return l_str;
end;

function get_part (
    i_format_id    in     com_api_type_pkg.t_tiny_id
  , i_part_rec     in     rul_api_type_pkg.t_name_part_rec
  , i_param_value  in     com_api_type_pkg.t_param_value
  , i_component    in     com_api_type_pkg.t_param_value := null
  , i_entity_type  in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_param_value is
    l_str                     com_api_type_pkg.t_param_value;
    l_stmt                    com_api_type_pkg.t_text;
begin
    case nvl(i_part_rec.transformation_type, rul_api_const_pkg.TRANSFORMATION_NO)
        when rul_api_const_pkg.TRANSFORMATION_NO then
            l_str := i_param_value;

        when rul_api_const_pkg.TRANSFORMATION_ORACLE_SQL then
            l_stmt := 'select '
                   || replace(
                          i_part_rec.transformation_mask
                        , ':' || i_part_rec.base_value
                        -- Escaping apostrophe character in parameter's value
                        , '''' || replace(i_param_value, '''', '''''') || ''''
                      )
                   || ' from dual';
            begin
                execute immediate l_stmt into l_str;
            exception
                when com_api_error_pkg.e_application_error then
                    raise;
                when others then
                    com_api_error_pkg.raise_error (
                        i_error       => 'ERROR_TRANSFORMATION'
                      , i_env_param1  => i_part_rec.transformation_type
                      , i_env_param2  => i_part_rec.transformation_mask
                      , i_env_param3  => l_stmt
                      , i_env_param4  => sqlerrm
                      , i_env_param5  => i_format_id
                    );
            end;
        else
            com_api_error_pkg.raise_error (
                i_error      => 'UNKNOWN_TRANSFORMATION'
              , i_env_param1 => i_part_rec.transformation_type
              , i_env_param2 => i_format_id
            );
    end case;

    if i_part_rec.part_length is not null then
        if nvl(length(l_str), 0) < i_part_rec.part_length then
            if i_part_rec.pad_type is null or i_part_rec.pad_string is null then
                -- small string, param: component_id, format_id
                /*com_api_error_pkg.raise_error(
                    i_error      => 'RUL_NAME_UNKNOWN_PAD'
                  , i_env_param1 => i_entity_type
                  , i_env_param2 => i_part_rec.format_id
                  , i_env_param3 => get_article_text(i_part_rec.pad_type)||' "'||i_part_rec.pad_string||'"'
                  , i_env_param4 => i_component
--                  , i_env_param5 => i_src
--                  , i_env_param6 => i_length
               );*/
               null;
            else
            -- pad
              l_str := pad_str(
                  i_pad_type    => i_part_rec.pad_type
                , i_src         => l_str
                , i_pad_string  => i_part_rec.pad_string
                , i_length      => i_part_rec.part_length
                , i_format_id   => i_format_id
                , i_component   => i_component
                , i_entity_type => i_entity_type
              );

            end if;

        elsif nvl(length(l_str), 0) > i_part_rec.part_length then
            l_str := trunc_str(
                i_trunc_type   => i_part_rec.pad_type
              , i_src          => l_str
              , i_length       => i_part_rec.part_length
              , i_format_id    => i_format_id
              , i_component    => i_component
              , i_entity_type  => i_entity_type
              );

        end if;
    end if;

    return l_str;
end get_part;

function range_nextval (
    i_id          in com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_large_id is pragma autonomous_transaction;
    l_current        com_api_type_pkg.t_large_id := 0;
begin
    for rec in (
        select a.id
             , a.current_value
             , a.low_value
             , a.high_value
             , a.algorithm
          from rul_name_index_range_vw a
         where a.id = i_id
    ) loop

        if rec.algorithm = rul_api_const_pkg.ALGORITHM_TYPE_SQNC then -- value in series
            update rul_name_index_range_vw a
               set a.current_value = nvl(nvl(a.current_value + 1, a.low_value), 1)
             where a.id            = rec.id
         returning a.current_value
              into l_current;

            if l_current not between rec.low_value and rec.high_value then
                rollback;
                com_api_error_pkg.raise_error (
                    i_error      => 'RUL_NAME_INDEX_RANGE_OUT'
                  , i_env_param1 => rec.id
                );
            else
                commit;
            end if;

        elsif rec.algorithm = rul_api_const_pkg.ALGORITHM_TYPE_RNDM then  -- random value
            l_current := trunc(dbms_random.value(rec.low_value, rec.high_value));

        elsif rec.algorithm = rul_api_const_pkg.ALGORITHM_TYPE_RNGS then
            l_current := rul_ui_name_pool_pkg.get_next_value(
                i_index_range_id => rec.id);

        elsif rec.algorithm = rul_api_const_pkg.ALGORITHM_TYPE_RNGR then
            l_current := rul_ui_name_pool_pkg.get_random_value(
                i_index_range_id => rec.id);

        else -- something else
            rollback;
            com_api_error_pkg.raise_error (
                i_error       => 'RUL_NAME_INDEX_FETCH_ALGORITH_UNKNOWN'
              , i_env_param1  => rec.id
              , i_env_param2  => rec.algorithm
            );
        end if;
        commit;
        return l_current;
    end loop;

    rollback;
    com_api_error_pkg.raise_error (
        i_error           => 'RUL_NAME_INDEX_RANGE_NOT_FOUND'
      , i_env_param1      => i_id
    );
end range_nextval;

function get_format_id (
      i_inst_id         in com_api_type_pkg.t_inst_id
    , i_entity_type     in com_api_type_pkg.t_dict_value
    , i_raise_error     in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
) return com_api_type_pkg.t_tiny_id
is
begin
    for r in(
        select id
          from (
              select id
                   , dense_rank() over(order by decode(inst_id, ost_api_const_pkg.DEFAULT_INST, 2, 1)) rn
                from rul_name_format
               where inst_id      in (i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                 and entity_type  = i_entity_type)
         where rn = 1
    ) loop
        return r.id;
        
    end loop;

    if i_raise_error = com_api_const_pkg.TRUE then
        com_api_error_pkg.raise_error (
            i_error         => 'NO_NAME_FORMAT'
            , i_env_param1  => ost_ui_institution_pkg.get_inst_name(i_inst_id)
            , i_env_param2  => i_entity_type
        );
    else
        return null;
    end if;
    
end;

function get_part_property (
    i_part_id           in com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_param_tab is
    l_property             com_api_type_pkg.t_param_tab;
begin
    for rec in (
        select
            a.property_name
            , b.property_value
        from
            rul_name_part_prpt a
            , rul_name_part_prpt_value_vw b
        where
            a.id = b.property_id
            and b.part_id = i_part_id
    ) loop
        l_property(upper(rec.property_name)) := rec.property_value;
    end loop;

    return l_property;
end;

function get_name (
    i_inst_id             in      com_api_type_pkg.t_inst_id
  , i_entity_type         in      com_api_type_pkg.t_dict_value
  , i_param_tab           in      com_api_type_pkg.t_param_tab
  , i_double_check_value  in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_name is
begin
    return get_name (
        i_format_id           => get_format_id(i_inst_id, i_entity_type, com_api_const_pkg.TRUE)
      , i_param_tab           => i_param_tab
      , i_double_check_value  => i_double_check_value
    );
end get_name;

function get_params_name (
    i_format_id       in     com_api_type_pkg.t_tiny_id
  , i_param_tab       in     com_api_type_pkg.t_param_tab
) return rul_api_type_pkg.t_param_tab is
begin
    for r1 in (
        select a.id
             , a.index_range_id
             , a.entity_type
          from rul_name_format_vw a
         where a.id = i_format_id
    ) loop
        return get_params_name (
            i_format_id       => r1.id
          , i_param_tab       => i_param_tab
          , i_index_range_id  => r1.index_range_id
          , i_entity_type     => r1.entity_type
        );
    end loop;

    com_api_error_pkg.raise_error (
        i_error      => 'RUL_NAME_FORMAT_NOT_FOUND'
      , i_env_param1 => i_format_id
    );
end;

function get_params_name (
    i_format_id      in      com_api_type_pkg.t_tiny_id
  , i_param_tab      in      com_api_type_pkg.t_param_tab
  , i_index_range_id in      com_api_type_pkg.t_short_id
  , i_entity_type    in      com_api_type_pkg.t_dict_value
) return rul_api_type_pkg.t_param_tab is

    l_index_format        com_api_type_pkg.t_short_id;
    l_param_rec           rul_api_type_pkg.t_param_rec;
    l_param_tab           com_api_type_pkg.t_param_tab := i_param_tab;
    l_result_params_tab   rul_api_type_pkg.t_param_tab;
begin

    for rec in (
        select
            a.id
            , a.format_id
            , a.part_order
            , a.base_value_type
            , decode(a.base_value_type, rul_api_const_pkg.BASE_VALUE_INDEX, 'INDEX', a.base_value) as base_value
            , a.transformation_type
            , a.transformation_mask
            , a.part_length
            , a.pad_type
            , a.pad_string
            , a.check_part
        from
            rul_name_part_vw a
        where
            a.format_id = i_format_id
        order by
            a.part_order asc)
    loop

        l_param_rec := null;

        -- Bonding components
        if rec.base_value_type = rul_api_const_pkg.BASE_VALUE_CONSTANT then

            l_param_rec.param_value := get_part (
                i_format_id    => i_format_id
              , i_part_rec     => rec
              , i_param_value  => rec.base_value
              , i_component    => rec.base_value_type || rec.part_order
              , i_entity_type  => i_entity_type
            );

            l_param_rec.param_name := rec.base_value_type || rec.part_order;

        elsif rec.base_value_type = rul_api_const_pkg.BASE_VALUE_INDEX then
            if l_param_tab.exists(rec.base_value) and l_param_tab(rec.base_value) is not null then
                begin
                    l_index_format := to_number(l_param_tab(rec.base_value), com_api_const_pkg.NUMBER_FORMAT);
                exception
                    when others then
                        com_api_error_pkg.raise_error (
                            i_error      => 'RUL_NAME_INDEX_PARAM_WRONG'
                          , i_env_param1 => rec.base_value
                          , i_env_param2 => l_param_tab(rec.base_value)
                          , i_env_param3 => sqlerrm
                          , i_env_param4 => i_format_id
                        );
                end;

            elsif i_index_range_id is not null then
                l_index_format := i_index_range_id;

            else
                com_api_error_pkg.raise_error (
                    i_error       => 'RUL_NAME_INDEX_PARAM_NOT_FOUND'
                  , i_env_param1  => i_format_id
                );
            end if;

            l_param_rec.param_value := get_part (
                i_format_id    => i_format_id
              , i_part_rec     => rec
              , i_param_value  => range_nextval(i_id => l_index_format)
              , i_component    => rec.base_value
              , i_entity_type  => i_entity_type
            );

            l_param_rec.param_name := rec.base_value;

        elsif rec.base_value_type = rul_api_const_pkg.BASE_VALUE_ARRAY then
            rul_api_param_pkg.set_param (
                io_params     => l_param_tab
              , i_name        => 'PART_LENGTH'
              , i_value       => rec.part_length
            );
            rul_api_name_transform_pkg.set_param(l_param_tab);

            l_param_rec.param_value := get_part (
                i_format_id    => i_format_id
              , i_part_rec     => rec
              , i_component    => rec.base_value
              , i_entity_type  => i_entity_type
            );

            l_param_rec.param_name := rec.base_value;

        elsif rec.base_value_type = rul_api_const_pkg.BASE_VALUE_PARAMETER then

            begin
                l_param_rec.param_value := get_part (
                    i_format_id    => i_format_id
                  , i_part_rec     => rec
                  , i_param_value  => l_param_tab(rec.base_value)
                  , i_component    => rec.base_value
                  , i_entity_type  => i_entity_type
                );

                l_param_rec.param_name := rec.base_value;

            exception
                when no_data_found then
                    com_api_error_pkg.raise_error (
                        i_error         => 'RUL_NAME_PARAM_NOT_FOUND'
                        , i_env_param1  => rec.base_value
                        , i_env_param2  => i_format_id
                    );
            end;

        else

            com_api_error_pkg.raise_error (
                i_error       => 'UNKNOWN_BASE_VALUE_TYPE'
              , i_env_param1  => rec.base_value_type
              , i_env_param2  => i_format_id
            );

        end if;

        l_param_rec.property := get_part_property (
            i_part_id  => rec.id
        );

        l_result_params_tab(l_result_params_tab.count+1) := l_param_rec;
    end loop;

    return l_result_params_tab;
end;

function get_name (
    i_format_id             in com_api_type_pkg.t_tiny_id
  , i_param_tab           in com_api_type_pkg.t_param_tab
  , i_double_check_value  in com_api_type_pkg.t_name
  , i_enable_empty        in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_name is
    l_str                 com_api_type_pkg.t_param_value;
    l_checksum            com_api_type_pkg.t_param_value;
    l_number              com_api_type_pkg.t_param_value;
    l_params_tab          rul_api_type_pkg.t_param_tab;
    l_inst                com_api_type_pkg.t_inst_id;
    l_bik                 com_api_type_pkg.t_name;
    l_index_range_id      com_api_type_pkg.t_short_id;
begin
    for r1 in (
        select id, inst_id, seqnum, entity_type, name_length, pad_type, pad_string, check_algorithm
             , check_base_position, check_base_length, check_position, index_range_id, check_name
          from rul_name_format_vw a
         where a.id = i_format_id
    ) loop
        l_index_range_id := r1.index_range_id;
        if i_param_tab.exists('INDEX') and r1.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
            l_index_range_id := rul_api_param_pkg.get_param_num('INDEX', i_param_tab);
        end if;

        l_params_tab := get_params_name (
            i_format_id       => r1.id
          , i_param_tab       => i_param_tab
          , i_index_range_id  => nvl(l_index_range_id, r1.index_range_id)
          , i_entity_type     => r1.entity_type
        );
        
        if l_params_tab.count = 0 then
            com_api_error_pkg.raise_error (
                i_error      => 'RUL_FORMAT_COMPONENT_NOT_FOUND'
              , i_env_param1 => r1.id
              , i_env_param2 => i_format_id
              , i_env_param3 => r1.entity_type
              , i_env_param4 => r1.inst_id
            );
        end if;

        -- set inst id for checksum sbrf
        if i_param_tab.exists('INST_ID') then
            l_inst := rul_api_param_pkg.get_param_num('INST_ID', i_param_tab);
        end if;

        for i in 1 .. l_params_tab.count loop
            l_str := l_str || l_params_tab(i).param_value;
        end loop;

        -- checksum if need
        if nvl(r1.check_algorithm, com_api_const_pkg.CHECK_ALGORITHM_NO_CHECK) != com_api_const_pkg.CHECK_ALGORITHM_NO_CHECK then
            l_number := substr(l_str, nvl(r1.check_base_position, 1), nvl(r1.check_base_length, r1.name_length - nvl(r1.check_base_position, 1)));

            trc_log_pkg.debug (
                i_text         => 'format id [#4] format_value[#1] check_base_position[#2] check_base_length[#3]'
                , i_env_param1 => l_str
                , i_env_param2 => nvl(r1.check_base_position, 1)
                , i_env_param3 => nvl(r1.check_base_length, r1.name_length - nvl(r1.check_base_position, 1))
                , i_env_param4 => i_format_id
            );

            begin
                l_number := to_char(to_number(l_number));
            exception
                when value_error then
                    -- Format value must contain only digits
                    com_api_error_pkg.raise_error (
                        i_error      => 'RUL_NAME_VALUE_WRONG'
                      , i_env_param1 => i_format_id
                      , i_env_param2 => l_number
                      , i_env_param3 => i_format_id
                    );
            end;

            case r1.check_algorithm

                when com_api_const_pkg.CHECK_ALGORITHM_LUHN then
                    l_checksum :=
                        com_api_checksum_pkg.get_luhn_checksum (
                            i_number => l_number
                        );
                when com_api_const_pkg.CHECK_ALGORITHM_MOD11 then
                    l_checksum :=
                        com_api_checksum_pkg.get_mod11_checksum (
                            i_number => l_number
                        );
                when com_api_const_pkg.CHECK_ALGORITM_CBRF then
                    l_bik := com_api_flexible_data_pkg.get_flexible_value (
                                 i_field_name   => 'FLX_BANK_ID_CODE'
                               , i_entity_type  => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                               , i_object_id    => nvl(l_inst, get_def_inst)
                             );
                    if l_bik is null then
                        com_api_error_pkg.raise_error(
                            i_error      => 'BIK_NOT_FOUND'
                          , i_env_param1 => l_inst
                        );
                    else
                        l_checksum :=
                            com_api_checksum_pkg.get_cbrf_checksum (
                                i_bik    => l_bik
                              , i_number => l_number
                            );
                    end if;

                else
                    -- Algorithm for check digit generation not supported
                    com_api_error_pkg.raise_error (
                        i_error      => 'UNKNOWN_ALGORITHM_CHECK_DIGIT_GENERATION'
                      , i_env_param1 => r1.check_algorithm
                      , i_env_param2 => r1.id
                      , i_env_param3 => i_format_id
                    );
            end case;

            l_str := substr(l_str, 1, nvl(r1.check_position, r1.name_length) - 1)
                     || l_checksum
                     || substr(l_str, nvl(r1.check_position, r1.name_length) + 1, r1.name_length - nvl(r1.check_position, r1.name_length));
        end if;

        -- control length
        if r1.name_length > length(l_str) then
            -- Padding str
            l_str := pad_str (
                i_pad_type     => r1.pad_type
              , i_src          => l_str
              , i_pad_string   => r1.pad_string
              , i_length       => r1.name_length
              , i_format_id    => i_format_id
              , i_component    => 'NAME'
              , i_entity_type  => r1.entity_type
            );

        elsif r1.name_length < length(l_str) then
            -- Truncate str
            l_str := trunc_str (
                i_trunc_type => r1.pad_type
              , i_src        => l_str
              , i_length     => r1.name_length
              , i_format_id  => i_format_id
              , i_component  => 'NAME'
              , i_entity_type  => r1.entity_type
            );

        end if;

        if l_str is null and i_enable_empty = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error (
                i_error      => 'RUL_NAME_NOT_GENERATED'
              , i_env_param1 => r1.id
              , i_env_param2 => i_format_id
              , i_env_param3 => r1.entity_type
              , i_env_param4 => r1.inst_id
            );

        elsif l_str = i_double_check_value then
            com_api_error_pkg.raise_error(
                i_error      => 'RUL_DOUBLE_NAME_GENERATED'
              , i_env_param1 => r1.id
              , i_env_param2 => l_str
              , i_env_param3 => i_format_id
            );
        end if;

        if r1.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
            trc_log_pkg.debug('name generated, length='||length(l_str)||', name='||iss_api_card_pkg.get_card_mask(i_card_number => l_str));
        else
            trc_log_pkg.debug('name generated, length='||length(l_str)||', name='||l_str);
        end if;
        return l_str;
    end loop;

    com_api_error_pkg.raise_fatal_error (
        i_error      => 'RUL_NAME_FORMAT_NOT_FOUND'
      , i_env_param1 => i_format_id
    );
end get_name;

procedure check_part(
    io_name       in out nocopy com_api_type_pkg.t_name
  , i_part        in            com_api_type_pkg.t_name
  , i_length      in            pls_integer
) is
    l_ok          boolean default true;
begin
    if i_length is not null then
        if substr(io_name, 1, i_length) != i_part then
            l_ok := false;
        end if;
    else
        if instr(io_name, i_part) != 1 then
            l_ok := false;
        end if;
    end if;
    if not l_ok then
        com_api_error_pkg.raise_error(
            i_error      => 'RUL_NAME_CHECK_FAIL'
          , i_env_param1 => io_name
          , i_env_param2 => i_part
        );
    else
        io_name := substr(io_name, - (length(io_name) - length(i_part)));
    end if;
end;

function check_name (
    i_format_id    in     com_api_type_pkg.t_tiny_id
  , i_name         in     com_api_type_pkg.t_name
  , i_param_tab    in     com_api_type_pkg.t_param_tab
  , i_entity_type  in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean is
    l_check_base          com_api_type_pkg.t_param_value := '';
    l_sum                 com_api_type_pkg.t_param_value := '';
    l_bik                 com_api_type_pkg.t_name;
    l_inst                com_api_type_pkg.t_inst_id;
    l_name                com_api_type_pkg.t_name := i_name;
    l_part                com_api_type_pkg.t_name;

begin
    for r1 in (
        select
            a.name_length
            , a.id
            , a.check_algorithm
            , nvl(a.check_base_position, 1) check_base_position
            , nvl(a.check_base_length, a.name_length - nvl(a.check_base_position, 1)) check_base_length
            , nvl(a.check_position, a.name_length) check_position
            , nvl(a.check_name, com_api_type_pkg.FALSE) as check_name
        from
            rul_name_format_vw a
        where
            a.id = i_format_id
    ) loop

        if r1.check_name = com_api_type_pkg.FALSE then
            return com_api_type_pkg.TRUE;
        end if;

        -- set inst id for checksum sbrf
        if i_param_tab.exists('INST_ID') then
            l_inst := rul_api_param_pkg.get_param_num('INST_ID', i_param_tab);
        end if;

        -- check length
        if length(i_name) <>  r1.name_length then
            com_api_error_pkg.raise_error(
                i_error      => 'RUL_NAME_LENGTH_ERROR'
              , i_env_param1 => i_format_id
              , i_env_param2 => i_name
            );
        end if;

        -- check sum
        if nvl(r1.check_algorithm, com_api_const_pkg.CHECK_ALGORITHM_NO_CHECK) != com_api_const_pkg.CHECK_ALGORITHM_NO_CHECK then
            trc_log_pkg.info(
                i_text       => 'Check format[#1] name[#2] check_base_position[#3] check_base_length[#4] check_position[#5]'
              , i_env_param1 => i_format_id
              , i_env_param2 => i_name
              , i_env_param3 => r1.check_base_position
              , i_env_param4 => r1.check_base_length
              , i_env_param5 => r1.check_position
            );

            l_check_base := substr(i_name, r1.check_base_position, r1.check_base_length);
            l_sum := substr(i_name, r1.check_position, 1);

            if r1.check_algorithm = com_api_const_pkg.CHECK_ALGORITHM_LUHN then
                if l_sum != to_char(com_api_checksum_pkg.get_luhn_checksum(i_number => to_number(l_check_base))) then
                    com_api_error_pkg.raise_error(
                        i_error => 'RUL_NAME_CHECKSUM_ERROR'
                      , i_env_param1 => i_format_id
                      , i_env_param2 => i_name
                    );
                end if;

            elsif r1.check_algorithm = com_api_const_pkg.CHECK_ALGORITHM_MOD11 then
                if l_sum != to_char(com_api_checksum_pkg.get_mod11_checksum(i_number => to_number(l_check_base))) then
                    com_api_error_pkg.raise_error(
                        i_error => 'RUL_NAME_CHECKSUM_ERROR'
                      , i_env_param1 => i_format_id
                      , i_env_param2 => i_name
                    );
                end if;

            elsif r1.check_algorithm = com_api_const_pkg.check_algoritm_cbrf then
                -- get BIK
                l_bik := com_api_flexible_data_pkg.get_flexible_value (
                             i_field_name   => 'FLX_BANK_ID_CODE'
                           , i_entity_type  => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                           , i_object_id    => nvl(l_inst, get_def_inst)
                         );

                if l_bik is null then
                    com_api_error_pkg.raise_error(
                        i_error      => 'BIK_NOT_FOUND'
                      , i_env_param1 => l_inst
                    );
                end if;

                if l_sum != to_char(com_api_checksum_pkg.get_cbrf_checksum(
                                        i_number => to_number(l_check_base)
                                      , i_bik    => l_bik))
                then
                    com_api_error_pkg.raise_error(
                        i_error => 'RUL_NAME_CHECKSUM_ERROR'
                      , i_env_param1 => i_format_id
                      , i_env_param2 => i_name
                    );
                end if;

            else
                com_api_error_pkg.raise_error (
                    i_error      => 'UNKNOWN_ALGORITHM_CHECK_DIGIT_GENERATION'
                  , i_env_param1 => r1.check_algorithm
                  , i_env_param2 => r1.id
                  , i_env_param3 => i_format_id
                );
            end if;
        end if;

        for r2 in (
            select
                a.id
                , a.format_id
                , a.part_order
                , a.base_value_type
                , a.base_value
                , a.transformation_type
                , a.transformation_mask
                , a.part_length
                , a.pad_type
                , a.pad_string
                , nvl(a.check_part, com_api_type_pkg.FALSE) as check_part
            from
                rul_name_part a
            where
                a.format_id = i_format_id
            order by
                a.part_order)
        loop
            if r2.check_part = com_api_type_pkg.TRUE then
                case r2.base_value_type
                    -- check constant
                    when rul_api_const_pkg.BASE_VALUE_CONSTANT then
                    -- if constant for checksum then only check length
                        if r1.name_length-length(l_name) + 1 = r1.check_position then
                            l_name := substr(l_name, r2.part_length+1);
                        else

                            l_part :=
                                get_part(
                                    i_format_id    => i_format_id
                                  , i_part_rec     => r2
                                  , i_param_value  => r2.base_value
                                  , i_component    => r2.base_value_type || r2.part_order
                                  , i_entity_type  => i_entity_type
                                );

                            check_part(l_name,l_part, r2.part_length);
                        end if;

                    when rul_api_const_pkg.BASE_VALUE_PARAMETER then
                        l_part :=
                            get_part(
                                i_format_id    => i_format_id
                              , i_part_rec     => r2
                              , i_param_value  => i_param_tab(r2.base_value)
                              , i_component    => r2.base_value
                              , i_entity_type  => i_entity_type
                            );

                        check_part(l_name, l_part, r2.part_length);
                    when rul_api_const_pkg.BASE_VALUE_INDEX then
                        l_name := substr(l_name, r2.part_length + 1);

                    when rul_api_const_pkg.BASE_VALUE_ARRAY then
                        l_name := substr(l_name, r2.part_length + 1);
                    else
                        null;
                end case;
            else

                l_name := substr(l_name, r2.part_length + 1);
            end if;
        end loop;

        return com_api_type_pkg.TRUE;
    end loop;

    com_api_error_pkg.raise_error (
        i_error        => 'RUL_NAME_FORMAT_NOT_FOUND'
      , i_env_param1   => i_format_id
      , i_env_param2   => i_name
    );
end check_name;

function check_name (
    i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_name                 in     com_api_type_pkg.t_name
  , i_param_tab            in     com_api_type_pkg.t_param_tab
  , i_null_format_allowed  in     com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_boolean is
    l_format_id         com_api_type_pkg.t_tiny_id;
begin
    l_format_id := get_format_id (
                       i_inst_id         => i_inst_id
                     , i_entity_type     => i_entity_type
                     , i_raise_error     => com_api_type_pkg.FALSE
                   );

    if l_format_id is not null then
        return check_name (
                   i_format_id   => l_format_id
                 , i_name        => i_name
                 , i_param_tab   => i_param_tab
                 , i_entity_type => i_entity_type
               );

    elsif i_null_format_allowed = com_api_type_pkg.TRUE then
        return com_api_type_pkg.TRUE;

    else
        com_api_error_pkg.raise_error (
            i_error      => 'NAME_FORMAT_NOT_SPECIFIED'
          , i_env_param1 => i_inst_id
          , i_env_param2 => i_entity_type
        );
    end if;
end;

end rul_api_name_pkg;
/
