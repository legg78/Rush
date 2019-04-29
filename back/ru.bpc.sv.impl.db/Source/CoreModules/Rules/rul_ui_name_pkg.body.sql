create or replace package body rul_ui_name_pkg as
/*********************************************************
*  Naming service <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 01.04.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RUL_UI_NAME_PKG <br />
*  @headcom
**********************************************************/

RUL_NAME_FORMAT_TABLE        constant com_api_type_pkg.t_oracle_name := 'RUL_NAME_FORMAT';
RUL_NAME_FORMAT_COLUMN       constant com_api_type_pkg.t_oracle_name := 'LABEL';

procedure sync_range (
    io_id            in out  com_api_type_pkg.t_short_id
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_entity_type    in      com_api_type_pkg.t_dict_value
  , i_algorithm      in      com_api_type_pkg.t_dict_value
  , i_low_value      in      com_api_type_pkg.t_large_id
  , i_high_value     in      com_api_type_pkg.t_large_id
  , i_current_value  in      com_api_type_pkg.t_large_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_name           in      com_api_type_pkg.t_name
) is
begin
    if nvl(i_low_value, 0) > nvl(i_high_value, nvl(i_low_value, 0)) then
        com_api_error_pkg.raise_error (
            i_error      => 'LOW_VALUE_CAN_GREATER_HIGH_VALUE'
          , i_env_param1 => i_low_value
          , i_env_param2 => i_high_value
        );
    end if;

    if i_current_value is not null and
       (nvl(i_low_value, 0) > i_current_value or i_current_value > nvl(i_high_value, 0))
    then
        com_api_error_pkg.raise_error (
            i_error      => 'CURRENT_VALUE_NOT_BETWEEN_RANGE'
          , i_env_param1 => i_current_value
          , i_env_param2 => i_low_value
          , i_env_param3 => i_high_value
        );
    end if;

    if io_id is null then
        io_id := rul_name_index_range_seq.nextval;
        insert into rul_name_index_range_vw (
              id
            , inst_id
            , entity_type
            , algorithm
            , low_value
            , high_value
            , current_value
        ) values (
              io_id
            , i_inst_id
            , i_entity_type
            , i_algorithm
            , i_low_value
            , i_high_value
            , i_current_value
        );

        -- add pool
        if i_entity_type != iss_api_const_pkg.ENTITY_TYPE_CARD then
            if i_algorithm in (
                rul_api_const_pkg.ALGORITHM_TYPE_RNGS
              , rul_api_const_pkg.ALGORITHM_TYPE_RNGR)
            then
                rul_ui_name_pool_pkg.add_pool(
                    i_index_range_id => io_id
                  , i_low_value      => i_low_value
                  , i_high_value     => i_high_value
                );
            end if;
        else
            rul_ui_name_pool_pkg.check_cross(
                i_index_range_id => io_id
              , i_low_value      => i_low_value
              , i_high_value     => i_high_value
            );
        end if;

    else
        update rul_name_index_range_vw a
           set algorithm     = i_algorithm
             , low_value     = i_low_value
             , high_value    = i_high_value
             , current_value = i_current_value
         where id            = io_id;

        if i_algorithm in (
            rul_api_const_pkg.ALGORITHM_TYPE_RNGS
          , rul_api_const_pkg.ALGORITHM_TYPE_RNGR)
        then
            rul_ui_name_pool_pkg.modify_pool(
                i_index_range_id => io_id
              , i_low_value      => i_low_value
              , i_high_value     => i_high_value
            );
        else
            rul_ui_name_pool_pkg.check_cross(
                i_index_range_id     => io_id
              , i_low_value          => i_low_value
              , i_high_value         => i_high_value
            );
            
        end if;
    end if;

    com_api_i18n_pkg.add_text (
        i_table_name    => 'rul_name_index_range'
      , i_column_name   => 'name'
      , i_object_id     => io_id
      , i_lang          => i_lang
      , i_text          => i_name
      , i_check_unique  => com_api_type_pkg.TRUE
    );

end;

procedure remove_range (
    i_id     in          com_api_type_pkg.t_short_id
) is
begin
    for rec in (
        select a.id
             , a.inst_id
             , get_text(RUL_NAME_FORMAT_TABLE, RUL_NAME_FORMAT_COLUMN, a.id) format_name
          from rul_name_format_vw a
         where a.index_range_id = i_id)
    loop
        com_api_error_pkg.raise_error(
            i_error      => 'INDEX_RANGE_IS_IN_USE'
          , i_env_param1 => rec.format_name
          , i_env_param2 => rec.id
          , i_env_param3 => rec.inst_id
        );
    end loop;

    trc_log_pkg.debug (
        i_text       => 'Delete name range with id = #1'
      , i_env_param1 => i_id
    );

    com_api_i18n_pkg.remove_text (
        i_table_name  => 'rul_name_index_range'
      , i_object_id   => i_id
    );

    for rec in (
        select a.id
             , a.algorithm
          from rul_name_index_range_vw a
         where a.id = i_id
    ) loop
        delete rul_name_index_range_vw
         where id = rec.id;
        -- remove pool
        if rec.algorithm in (
            rul_api_const_pkg.ALGORITHM_TYPE_RNGS
          , rul_api_const_pkg.ALGORITHM_TYPE_RNGR)
        then
            rul_ui_name_pool_pkg.remove_pool(
                i_index_range_id => rec.id
            );
        end if;
    end loop;

end remove_range;

procedure sync_part (
    io_id                  in out com_api_type_pkg.t_short_id
  , i_format_id            in     com_api_type_pkg.t_tiny_id
  , i_part_order           in     com_api_type_pkg.t_tiny_id
  , i_base_value_type      in     com_api_type_pkg.t_dict_value
  , i_base_value           in     com_api_type_pkg.t_name
  , i_transformation_type  in     com_api_type_pkg.t_dict_value
  , i_transformation_mask  in     com_api_type_pkg.t_name
  , i_part_length          in     com_api_type_pkg.t_tiny_id
  , i_pad_type             in     com_api_type_pkg.t_dict_value
  , i_pad_string           in     com_api_type_pkg.t_name
  , i_check_part           in     com_api_type_pkg.t_boolean
) is
    l_length               pls_integer;
begin
    -- check pad method
    if (i_pad_type is null and i_pad_string is not null) or (i_pad_type is not null and i_pad_string is null) then
        com_api_error_pkg.raise_error(
            i_error      => 'RUL_PAD_METHOD_INCOMPLETE'
          , i_env_param1 => i_pad_type
          , i_env_param2 => i_pad_string
        );
    end if;

    for rec in (
        select id
             , entity_type
          from rul_name_format_vw
         where id = i_format_id
    ) loop

        begin
            if io_id is null then
                io_id := rul_name_part_seq.nextval;
                insert into rul_name_part_vw (
                    id
                  , format_id
                  , part_order
                  , base_value_type
                  , base_value
                  , transformation_type
                  , transformation_mask
                  , part_length
                  , pad_type
                  , pad_string
                  , check_part
                ) values (
                    io_id
                  , i_format_id
                  , i_part_order
                  , i_base_value_type
                  , i_base_value
                  , i_transformation_type
                  , i_transformation_mask
                  , i_part_length
                  , i_pad_type
                  , i_pad_string
                  , i_check_part
                );

                trc_log_pkg.debug (
                    i_text        => 'Add name component with id = #1'
                  , i_env_param1  => io_id
                );
            else
                update rul_name_part_vw
                   set format_id           = i_format_id
                     , part_order          = i_part_order
                     , base_value_type     = i_base_value_type
                     , base_value          = i_base_value
                     , transformation_type = i_transformation_type
                     , transformation_mask = case i_transformation_type
                                             when rul_api_const_pkg.TRANSFORMATION_NO
                                             then null
                                             else i_transformation_mask
                                             end
                     , part_length         = i_part_length
                     , pad_type            = i_pad_type
                     , pad_string          = i_pad_string
                     , check_part          = i_check_part
                 where id                  = io_id;

                trc_log_pkg.debug (
                    i_text       => 'Update name component with id = #1'
                  , i_env_param1 => io_id
                );
            end if;
        exception
            when dup_val_on_index then
                com_api_error_pkg.raise_error (
                    i_error       => 'COMPONENT_ORDER_ALREADY_EXISTS'
                  , i_env_param1  => i_part_order
                  , i_env_param2  => i_format_id
                );
        end;

        if rec.entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD) then
            select sum(nvl(part_length, 0))
              into l_length
              from rul_name_part_vw
             where format_id = io_id;

            if nvl(l_length, 0) > iss_api_const_pkg.MAX_CARD_NUMBER_LENGTH then
                com_api_error_pkg.raise_error(
                    i_error      => 'CARD_NUMBER_TOO_LONG'
                  , i_env_param1 => l_length
                  , i_env_param2 => iss_api_const_pkg.MAX_CARD_NUMBER_LENGTH
                  , i_env_param3 => i_format_id
                );
            end if;
        end if;

        return;
    end loop;

    com_api_error_pkg.raise_error (
        i_error       => 'RUL_NAME_FORMAT_NOT_FOUND'
      , i_env_param1  => i_format_id
    );
end;

procedure remove_part (
    i_id                  in com_api_type_pkg.t_short_id
) is
begin
    trc_log_pkg.debug (
        i_text        => 'Delete name component with id = #1'
      , i_env_param1  => i_id
    );

    delete from rul_name_part_prpt_value_vw
     where part_id = i_id;

    delete from rul_name_part_vw
     where id = i_id;
end;

procedure sync_name_format(
    io_id                 in out  com_api_type_pkg.t_tiny_id
  , i_inst                in      com_api_type_pkg.t_inst_id
  , io_seqnum             in out  com_api_type_pkg.t_tiny_id
  , i_entity_type         in      com_api_type_pkg.t_dict_value
  , i_name_length         in      com_api_type_pkg.t_tiny_id
  , i_pad_type            in      com_api_type_pkg.t_dict_value
  , i_pad_string          in      com_api_type_pkg.t_name
  , i_check_algorithm     in      com_api_type_pkg.t_dict_value
  , i_check_base_position in      com_api_type_pkg.t_tiny_id
  , i_check_base_length   in      com_api_type_pkg.t_tiny_id
  , i_check_position      in      com_api_type_pkg.t_tiny_id
  , i_index_range_id      in      com_api_type_pkg.t_short_id
  , i_lang                in      com_api_type_pkg.t_dict_value
  , i_label               in      com_api_type_pkg.t_text
  , i_check_name          in      com_api_type_pkg.t_boolean
) is
    l_length              pls_integer;
begin
    -- Check pad method
    if i_pad_type is null     and i_pad_string is not null
       or
       i_pad_type is not null and i_pad_string is null
    then
        com_api_error_pkg.raise_error(
            i_error      => 'RUL_PAD_METHOD_INCOMPLETE'
          , i_env_param1 => i_pad_type
          , i_env_param2 => i_pad_string
        );
    end if;

    if nvl(i_check_algorithm, com_api_const_pkg.CHECK_ALGORITHM_NO_CHECK) != com_api_const_pkg.CHECK_ALGORITHM_NO_CHECK then
        if i_check_base_position < 1 or i_check_base_position > i_name_length then
            -- Incorrect check base position
            com_api_error_pkg.raise_error(
                i_error        => 'RUL_NAME_CHECK_BASE_POSITION_INCORRECT'
            );
        elsif i_check_base_length < 1 or i_check_base_position + i_check_base_length - 1 > i_name_length then
            -- Incorrect check base length
            com_api_error_pkg.raise_error(
                i_error        => 'RUL_NAME_CHECK_BASE_LENGTH_INCORRECT'
            );
        elsif i_check_position < 1
              or i_check_position > i_name_length
              or (i_check_base_position <= i_check_position
                  and i_check_position <= i_check_base_position + i_check_base_length - 1
                  and i_check_algorithm != com_api_const_pkg.CHECK_ALGORITM_CBRF)
        then
            -- Incorrect check position
            com_api_error_pkg.raise_error(
                i_error        => 'RUL_NAME_CHECK_POSITION_INCORRECT'
            );
        end if;
    end if;

    -- For some entity types, we limit count of naming formats by 1 per institute
    if io_id is null and i_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER) then
        trc_log_pkg.debug('Checking for name format uniqueness for institute [' || i_inst || '] and entity type [' || i_entity_type || ']');
        declare
            l_id    com_api_type_pkg.t_tiny_id;
        begin
            select id
              into l_id
              from rul_name_format_vw
             where entity_type = i_entity_type
               and inst_id     = i_inst
               and rownum = 1;

            com_api_error_pkg.raise_error(
                i_error      => 'RUL_FORMAT_ALREADY_EXISTS'
              , i_env_param1 => i_entity_type
              , i_env_param2 => i_inst
            );
        exception
            when no_data_found then
                null;
        end;
    end if;

    -- For some entity types, we limit length of naming format returned value by some constants
    if i_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD) then
        if nvl(i_name_length,0) > iss_api_const_pkg.MAX_CARD_NUMBER_LENGTH then
            com_api_error_pkg.raise_error(
                i_error      => 'CARD_NUMBER_TOO_LONG'
              , i_env_param1 => i_name_length
              , i_env_param2 => iss_api_const_pkg.MAX_CARD_NUMBER_LENGTH
              , i_env_param3 => io_id
            );
        end if;
    end if;

    if io_id is null then
        io_id     := rul_name_format_seq.nextval;
        io_seqnum := 1;

        insert into rul_name_format_vw (
            id
          , inst_id
          , seqnum
          , entity_type
          , name_length
          , pad_type
          , pad_string
          , check_algorithm
          , check_base_position
          , check_base_length
          , check_position
          , index_range_id
          , check_name
        ) values (
            io_id
          , i_inst
          , io_seqnum
          , i_entity_type
          , i_name_length
          , i_pad_type
          , i_pad_string
          , i_check_algorithm
          , i_check_base_position
          , i_check_base_length
          , i_check_position
          , i_index_range_id
          , i_check_name
        );

        trc_log_pkg.debug(
            i_text       => 'Add name format with id = #1'
          , i_env_param1 => io_id
        );
    else
        -- For some entity types, we limit length of naming format returned value by some constants
        if i_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD) then
            select sum(nvl(part_length, 0))
              into l_length
              from rul_name_part_vw
             where format_id = io_id;

            if nvl(l_length, 0) > iss_api_const_pkg.MAX_CARD_NUMBER_LENGTH then
                com_api_error_pkg.raise_error(
                    i_error      => 'CARD_NUMBER_TOO_LONG'
                  , i_env_param1 => l_length
                  , i_env_param2 => iss_api_const_pkg.MAX_CARD_NUMBER_LENGTH
                  , i_env_param3 => io_id
                );
            end if;
        end if;

        update rul_name_format_vw
           set inst_id             = i_inst
             , seqnum              = io_seqnum
             , name_length         = i_name_length
             , pad_type            = i_pad_type
             , pad_string          = i_pad_string
             , check_algorithm     = i_check_algorithm
             , check_base_position = i_check_base_position
             , check_base_length   = i_check_base_length
             , check_position      = i_check_position
             , index_range_id      = i_index_range_id
             , check_name          = i_check_name
        where id                   = io_id;

        io_seqnum := io_seqnum + 1;

        trc_log_pkg.debug(
            i_text       => 'Update name format with id = #1'
          , i_env_param1 => io_id
        );
    end if;

    com_api_i18n_pkg.add_text(
        i_table_name   => RUL_NAME_FORMAT_TABLE
      , i_column_name  => RUL_NAME_FORMAT_COLUMN
      , i_object_id    => io_id
      , i_lang         => i_lang
      , i_text         => i_label
    );

    declare
        l_id    com_api_type_pkg.t_tiny_id;
    begin
        select f.id
          into l_id
          from rul_name_format f join com_i18n i on i.object_id = f.id 
         where i.table_name  = RUL_NAME_FORMAT_TABLE
           and i.column_name = RUL_NAME_FORMAT_COLUMN
           and i.text        = i_label
           and i.lang        = i_lang
           and f.entity_type = i_entity_type
           and f.inst_id     = i_inst;
    exception
        when no_data_found then
            trc_log_pkg.debug('WARNING: label for name format [' || io_id || '] hasn''t been added correctly');
        when too_many_rows then
            com_api_error_pkg.raise_error(
                i_error      => 'DUPLICATE_NAME_FORMAT'
              , i_env_param1 => io_id
              , i_env_param2 => i_inst
              , i_env_param3 => i_entity_type
              , i_env_param4 => i_label
              , i_env_param5 => i_lang
            );
    end;
end;

/*
 * If there is a table with entity objects that are related to removing name format then the error will be raised.
 */
procedure assert_removing_name_format(
    i_id                  in      com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.assert_removing_name_format: ';
    l_entity_type                 com_api_type_pkg.t_dict_value;
    l_entity_object_id            com_api_type_pkg.t_long_id;
begin
    begin
        select t.entity_type
          into l_entity_type
          from rul_name_format_vw t
         where id = i_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'NAME_FORMAT_IS_NOT_DEFINED'
              , i_env_param1 => i_id
            );
    end;

    trc_log_pkg.debug(LOG_PREFIX || 'i_id [' || i_id || '], l_entity_type [' || l_entity_type || ']');

    declare
        SQL_QUERY_TEMPLATE    constant com_api_type_pkg.t_short_desc :=
            'select id from @VIEW@ where @COLUMN@ = :i_id and rownum <= 1';
        l_sql_query                    com_api_type_pkg.t_short_desc;
        l_view                         com_api_type_pkg.t_oracle_name;
        l_column                       com_api_type_pkg.t_oracle_name;
    begin
        case
            when l_entity_type in (acc_api_const_pkg.ENTITY_TYPE_ACCOUNT) then
                l_view   := 'acc_account_type_vw';
                l_column := 'number_format_id';
            when l_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD) then
                l_view   := 'iss_product_card_type_vw';
                l_column := 'number_format_id';
            when l_entity_type in (com_api_const_pkg.ENTITY_TYPE_BALANCE_TYPE) then
                l_view   := 'acc_balance_type_vw';
                l_column := 'number_format_id';
            when l_entity_type in (com_api_const_pkg.ENTITY_TYPE_REPORT) then
                l_view   := 'rpt_report_vw';
                l_column := 'name_format_id';
            when l_entity_type in (prc_api_const_pkg.ENTITY_TYPE_FILE_ATTRIBUTE) then
                l_view   := 'prc_file_attribute_vw';
                l_column := 'name_format_id';
            when l_entity_type is not null then
                <<check_prs_template>> -- If entity type is in LOV #79 then it is necessary to check table <prs_template>
                declare
                    LOV_ID_PRS_TEMPLATE_ENTITIES  constant com_api_type_pkg.t_tiny_id := 79;
                    l_sql_entities                         com_api_type_pkg.t_full_desc;
                    l_result                               com_api_type_pkg.t_dict_value;

                    function get_lov_query(
                        i_lov_id    in      com_api_type_pkg.t_tiny_id
                    ) return com_api_type_pkg.t_full_desc
                    is
                        l_result            com_api_type_pkg.t_full_desc;
                    begin
                        begin
                            select lov_query
                              into l_result
                              from com_lov_vw
                             where id = i_lov_id;
                        exception
                            when no_data_found then
                                l_result := 'select null as code from dual';
                        end;
                        return l_result;
                    end get_lov_query;
                begin
                    l_sql_entities := 'select code from (' || get_lov_query(i_lov_id => LOV_ID_PRS_TEMPLATE_ENTITIES)
                                   || ') where code = :p_entity_type';
                    trc_log_pkg.debug(LOG_PREFIX || 'l_sql_entities [' || l_sql_entities || ']');

                    execute immediate l_sql_entities into l_result using l_entity_type;

                    if l_result is not null then
                        l_view   := 'prs_template_vw';
                        l_column := 'format_id';
                    end if;
                exception
                    when no_data_found then
                        null; -- Entity is not used in prs_template, so check isn't required
                end check_prs_template;
        end case;

        if l_view is null or l_column is null then
            trc_log_pkg.debug(LOG_PREFIX || 'no any table references to the name format, checks aren''t required');
        else
            l_sql_query := replace(replace(SQL_QUERY_TEMPLATE, '@VIEW@', l_view), '@COLUMN@', l_column);
            trc_log_pkg.debug(LOG_PREFIX || 'l_sql_query [' || l_sql_query || ']');

            execute immediate l_sql_query into l_entity_object_id using i_id;
        end if;
    exception
        when no_data_found then
            null;
    end;

    -- If it is used by any entity object then it is necessary to restrict its deleting
    if l_entity_object_id is null then
        trc_log_pkg.debug(LOG_PREFIX || 'removing name format is permitted');
    else
        com_api_error_pkg.raise_error(
            i_error      => 'NAME_FORMAT_IS_USED'
          , i_env_param1 => i_id
          , i_env_param2 => l_entity_type
          , i_env_param3 => l_entity_object_id
        );
    end if;
end assert_removing_name_format;

procedure remove_name_format (
    i_id                  in      com_api_type_pkg.t_tiny_id
  , i_seqnum              in      com_api_type_pkg.t_tiny_id
) is
begin
    -- Checking if deleting name format is used by some entity objects,
    -- if they exist then the error NAME_FORMAT_IS_USED will be raised
    assert_removing_name_format(i_id => i_id);

    delete from rul_name_part_prpt_value_vw
     where part_id in (
       select id from rul_name_part_vw
        where format_id = i_id
     );

    delete from rul_name_part_vw
     where format_id = i_id;

    com_api_i18n_pkg.remove_text (
        i_table_name  => RUL_NAME_FORMAT_TABLE
      , i_object_id   => i_id
    );

    -- card type in product
     update iss_product_card_type_vw a
        set a.number_format_id = null
      where a.number_format_id = i_id;

    update rul_name_format_vw
       set seqnum = i_seqnum
     where id = i_id;

    delete from rul_name_format_vw
     where id = i_id;
end;

procedure sync_property_value (
    io_id             in out  com_api_type_pkg.t_short_id
  , i_part_id         in      com_api_type_pkg.t_short_id
  , i_property_id     in      com_api_type_pkg.t_short_id
  , i_property_value  in      com_api_type_pkg.t_name
) is
begin
    for rec in (
        select id
          from rul_name_part_vw
         where id = i_part_id
    ) loop
        if io_id is null then
            io_id := rul_name_part_prpt_value_seq.nextval;
            insert into rul_name_part_prpt_value_vw (
                id
              , part_id
              , property_id
              , property_value
            ) values (
                io_id
              , i_part_id
              , i_property_id
              , i_property_value
            );

            trc_log_pkg.debug (
                i_text       => 'Add name property value with id = #1'
              , i_env_param1 => io_id
            );
        else
            update rul_name_part_prpt_value_vw
               set part_id        = i_part_id
                 , property_id    = i_property_id
                 , property_value = i_property_value
             where id             = io_id;

            trc_log_pkg.debug (
                i_text        => 'Update name property value with id = #1'
              , i_env_param1  => io_id
            );
        end if;

        return;
    end loop;

    com_api_error_pkg.raise_error (
        i_error       => 'RUL_NAME_PART_NOT_FOUND'
      , i_env_param1  => i_part_id
    );
end;

procedure remove_property_value (
    i_id  in           com_api_type_pkg.t_short_id
) is
begin
    trc_log_pkg.debug (
        i_text       => 'Delete name component with id = #1'
      , i_env_param1 => i_id
    );
    delete from  rul_name_part_prpt_value_vw
     where id = i_id;
end;

end rul_ui_name_pkg;
/
