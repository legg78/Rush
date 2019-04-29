create or replace package body prd_ui_attribute_pkg is
/*********************************************************
*  UI for attributes <br />
*  Created by Kopachev D.(kopachev@bpcbt.com)  at 15.11.2010 <br />
*  Last changed by $Author: fomichev $ <br />
*  $LastChangedDate:: 2011-07-13 16:20:00 +0400#$ <br />
*  Revision: $LastChangedRevision: 10500 $ <br />
*  Module: prd_ui_attribute_pkg <br />
*  @headcom
**********************************************************/

procedure check_group_exists (
    i_id                    in com_api_type_pkg.t_short_id
    , i_error               in com_api_type_pkg.t_name
) is
    l_check_id              com_api_type_pkg.t_short_id;
begin
    select
        id
    into
        l_check_id
    from
        prd_attribute_vw
    where
        id = i_id
    for update;
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error         => i_error
            , i_env_param1  => i_id
        );
end;

procedure check_attribute_text_unique(
    i_service_type_id  in  com_api_type_pkg.t_short_id
  , i_lang             in  com_api_type_pkg.t_dict_value
  , i_text             in  com_api_type_pkg.t_text
  , i_column_name      in  com_api_type_pkg.t_oracle_name
  , i_object_id        in  com_api_type_pkg.t_long_id      default null
) is
    l_cnt com_api_type_pkg.t_count := 0;
begin
    select count(1) as cnt
      into l_cnt
      from prd_attribute_vw a
         , com_i18n_vw i
     where a.id = i.object_id
       and i.table_name = 'PRD_ATTRIBUTE'
       and i.column_name = upper(i_column_name)
       and upper(i.text) = upper(i_text)
       and i.lang = i_lang
       and a.service_type_id = i_service_type_id
       and (i.object_id <> i_object_id or i_object_id is null);

    if l_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'DESCRIPTION_IS_NOT_UNIQUE'
          , i_env_param2  => upper(i_column_name)
          , i_env_param3  => i_text
        );
    end if;
end;

procedure update_service_type_fee (
    i_service_type_id      in     com_api_type_pkg.t_short_id
    , i_is_service_fee     in     com_api_type_pkg.t_boolean
    , i_attribute_id       in     com_api_type_pkg.t_short_id
) is
begin
    update prd_service_type_vw
    set service_fee = decode(i_is_service_fee, com_api_type_pkg.TRUE, i_attribute_id, null)
    where id        = i_service_type_id;
end;

procedure add_attribute (
    o_id                       out com_api_type_pkg.t_short_id
  , i_service_type_id       in     com_api_type_pkg.t_short_id
  , i_parent_id             in     com_api_type_pkg.t_short_id
  , i_attr_name             in     com_api_type_pkg.t_name
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_lov_id                in     com_api_type_pkg.t_tiny_id
  , i_display_order         in     com_api_type_pkg.t_tiny_id
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_short_description     in     com_api_type_pkg.t_name
  , i_description           in     com_api_type_pkg.t_full_desc
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_type           in     com_api_type_pkg.t_dict_value
  , i_definition_level      in     com_api_type_pkg.t_dict_value
  , i_is_cycle              in     com_api_type_pkg.t_boolean
  , i_is_use_limit          in     com_api_type_pkg.t_boolean
  , i_is_limit_cyclic       in     com_api_type_pkg.t_boolean
  , i_is_visible            in     com_api_type_pkg.t_boolean
  , i_is_service_fee        in     com_api_type_pkg.t_boolean
  , i_cycle_calc_start_date in     com_api_type_pkg.t_dict_value
  , i_cycle_calc_date_type  in     com_api_type_pkg.t_dict_value
  , i_posting_method        in     com_api_type_pkg.t_dict_value    default null
  , i_counter_algorithm     in     com_api_type_pkg.t_dict_value    default null
  , i_short_name            in     com_api_type_pkg.t_name          default null
  , i_is_repeating          in     com_api_type_pkg.t_boolean       default null
  , i_need_length_type      in     com_api_type_pkg.t_boolean       default null
  , i_module_code           in     com_api_type_pkg.t_module_code   default null
  , i_limit_usage           in     com_api_type_pkg.t_dict_value    default null
) is
    l_id                 com_api_type_pkg.t_short_id;
    l_cycle_type         com_api_type_pkg.t_dict_value;
    l_limit_type         com_api_type_pkg.t_dict_value;
    l_object_type        com_api_type_pkg.t_dict_value := i_object_type;
    l_seqnum             com_api_type_pkg.t_seqnum;
    l_count              com_api_type_pkg.t_count := 0;
    l_attr_name          com_api_type_pkg.t_name;
    l_entity_type        com_api_type_pkg.t_dict_value;
    l_nextval            com_api_type_pkg.t_long_id;

    function get_acticle (
        i_dict        in     com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_dict_value is
        l_code        com_api_type_pkg.t_dict_value;
    begin
        if i_module_code is not null then
            begin
                select m.dict_code 
                  into l_code
                  from com_module m 
                 where m.module_code = i_module_code;
            exception 
                when no_data_found then
                    null; 
            end;
        end if;
        
        if l_code is null then
            case l_entity_type
            when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                l_code := '04';
            when iss_api_const_pkg.ENTITY_TYPE_CARD then
                l_code := '01';
            when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
               l_code := '02';
            when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
               l_code := '02';
            when ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
               l_code := '03';
            when ost_api_const_pkg.ENTITY_TYPE_AGENT then
               l_code := '03';
            when prd_api_const_pkg.ENTITY_TYPE_CONTRACT then
               l_code := '09';
            when prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
               l_code := '09';
            else
                null;
            end case;
        end if;

        select
            i_dict || lpad(nvl(max(to_number(code)), l_code || '00') + 1, 4, '0')
        into
            l_code
        from
            com_dictionary_vw
        where
            dict = i_dict
            and regexp_like(code, l_code || '\d{2}');

        return l_code;
    end;

begin
    trc_log_pkg.debug (
        i_text        => 'prd_ui_attribute_pkg.add_attribute: i_name/i_short_desc/i_data_type [#1], '
                      || 'i_entity_type[#2], l_cycle_type[#3], i_is_cycle[#4], i_is_use_limit[#5], i_is_limit_cyclic[#6], ' 
                      || 'i_module_code[' || i_module_code ||']'
                      
      , i_env_param1  => i_attr_name || '; ' || i_short_description || '; ' || i_data_type
      , i_env_param2  => i_entity_type
      , i_env_param3  => l_cycle_type
      , i_env_param4  => i_is_cycle
      , i_env_param5  => i_is_use_limit
      , i_env_param6  => i_is_limit_cyclic
    );

    begin
        select t.entity_type
          into l_entity_type
          from prd_service_type_vw t
         where id = i_service_type_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error       => 'SERVICE_TYPE_NOT_FOUND'
              , i_env_param1  => i_service_type_id
            );
    end;

    --check display order
    select count(1)
      into l_count
      from prd_attribute_vw
     where service_type_id = i_service_type_id
       and (parent_id = i_parent_id or nvl(i_parent_id, 0) = nvl(parent_id, 0))
       and display_order   = i_display_order;
    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'SERVICE_TERM_DISPLAY_ORDER_ALREADY_USED'
          , i_env_param1  => i_display_order
          , i_env_param2  => i_service_type_id
        );
    end if;

    l_nextval := com_api_id_pkg.get_sequence_nextval(i_sequence_name => 'com_dictionary_seq');

    case i_entity_type
    when fcl_api_const_pkg.ENTITY_TYPE_FEE then
        if i_is_use_limit = com_api_const_pkg.TRUE then
            if i_is_limit_cyclic = com_api_const_pkg.TRUE then
                l_cycle_type := null;

                if l_nextval < 50000000 then
                    l_cycle_type := get_acticle (
                        i_dict  => 'CYTP'
                    );
                end if;

                fcl_ui_cycle_pkg.add_cycle_type (
                    io_cycle_type           => l_cycle_type
                  , i_short_desc            => com_api_label_pkg.get_label_text('prd.cycle_for') || ' ' || i_short_description
                  , i_full_desc             => null
                  , i_cycle_calc_start_date => i_cycle_calc_start_date
                  , i_cycle_calc_date_type  => i_cycle_calc_date_type
                  , i_is_repeating          => i_is_repeating
                  , i_lang                  => i_lang
                );
            end if;

            if l_nextval < 50000000 then
                l_limit_type := get_acticle (
                    i_dict  => 'LMTP'
                );
            end if;

            fcl_ui_limit_pkg.add_limit_type (
                io_limit_type       => l_limit_type
              , i_cycle_type        => l_cycle_type
              , i_entity_type       => null
              , i_is_internal       => com_api_type_pkg.TRUE
              , i_short_desc        => com_api_label_pkg.get_label_text('prd.limit_for') || ' ' || i_short_description
              , i_full_desc         => null
              , i_lang              => i_lang
              , i_posting_method    => i_posting_method
              , i_counter_algorithm => i_counter_algorithm
              , i_limit_usage       => i_limit_usage
              , o_limit_type_id     => l_id
            );
        end if;

        l_cycle_type := null;

        if i_is_cycle = com_api_const_pkg.TRUE then
            if l_nextval < 50000000 then
                l_cycle_type := get_acticle (
                    i_dict  => 'CYTP'
                );
            end if;

            fcl_ui_cycle_pkg.add_cycle_type (
                io_cycle_type           => l_cycle_type
              , i_short_desc            => com_api_label_pkg.get_label_text('prd.cycle_for') || ' ' || i_short_description
                                        || case
                                               when i_is_use_limit    = com_api_const_pkg.TRUE
                                                and i_is_limit_cyclic = com_api_const_pkg.TRUE
                                               then ' 2'
                                               else ''
                                           end
              , i_full_desc             => null
              , i_cycle_calc_start_date => i_cycle_calc_start_date
              , i_cycle_calc_date_type  => i_cycle_calc_date_type
              , i_is_repeating          => i_is_repeating
              , i_lang                  => i_lang
            );
        end if;

        if l_nextval < 50000000 then
            l_object_type := get_acticle (
                i_dict  => 'FETP'
            );
        end if;

        fcl_ui_fee_pkg.add_fee_type (
            io_fee_type        => l_object_type
          , i_entity_type      => null
          , i_cycle_type       => l_cycle_type
          , i_limit_type       => l_limit_type
          , i_short_desc       => i_short_description
          , i_full_desc        => null
          , i_lang             => i_lang
          , i_need_length_type => i_need_length_type
          , o_seqnum           => l_seqnum
        );

    when fcl_api_const_pkg.ENTITY_TYPE_LIMIT then
        if i_is_cycle = com_api_const_pkg.TRUE then
            l_cycle_type := null;

            if l_nextval < 50000000 then
                l_cycle_type := get_acticle (
                    i_dict  => 'CYTP'
                );
            end if;

            fcl_ui_cycle_pkg.add_cycle_type (
                io_cycle_type           => l_cycle_type
              , i_short_desc            => com_api_label_pkg.get_label_text('prd.cycle_for') || ' ' || i_short_description
              , i_full_desc             => null
              , i_cycle_calc_start_date => i_cycle_calc_start_date
              , i_cycle_calc_date_type  => i_cycle_calc_date_type
              , i_is_repeating          => i_is_repeating
              , i_lang                  => i_lang
            );
        end if;

        if l_nextval < 50000000 then
            l_object_type := get_acticle (
                i_dict  => 'LMTP'
            );
        end if;

        fcl_ui_limit_pkg.add_limit_type (
            io_limit_type       => l_object_type
          , i_cycle_type        => l_cycle_type
          , i_entity_type       => null
          , i_is_internal       => com_api_type_pkg.TRUE
          , i_short_desc        => i_short_description
          , i_full_desc         => null
          , i_lang              => i_lang
          , i_posting_method    => i_posting_method
          , i_counter_algorithm => i_counter_algorithm
          , i_limit_usage       => i_limit_usage
          , o_limit_type_id     => l_id
        );

    when fcl_api_const_pkg.ENTITY_TYPE_CYCLE then
        if l_nextval < 50000000 then
            l_object_type := get_acticle (
                i_dict  => 'CYTP'
            );
        end if;

        fcl_ui_cycle_pkg.add_cycle_type (
            io_cycle_type           => l_object_type
          , i_short_desc            => i_short_description
          , i_full_desc             => null
          , i_cycle_calc_start_date => i_cycle_calc_start_date
          , i_cycle_calc_date_type  => i_cycle_calc_date_type
          , i_is_repeating          => i_is_repeating
          , i_lang                  => i_lang
        );

    else
        null;
    end case;

    o_id := com_parameter_seq.nextval;
    begin
        insert into prd_attribute_vw (
            id
          , service_type_id
          , parent_id
          , attr_name
          , data_type
          , lov_id
          , display_order
          , entity_type
          , object_type
          , definition_level
          , is_visible
        ) values (
            o_id
          , i_service_type_id
          , i_parent_id
          , upper(replace(i_attr_name, ' ', '_'))
          , nvl(i_data_type, com_api_const_pkg.DATA_TYPE_NUMBER)
          , i_lov_id
          , i_display_order
          , i_entity_type
          , l_object_type
          , i_definition_level
          , i_is_visible
        );

        select count(*)
             , min(attr_name)
          into l_count
             , l_attr_name
          from (select connect_by_iscycle iscycle, id, parent_id, attr_name
                  from prd_ui_attribute_vw
               connect by nocycle prior id = parent_id)
         where iscycle = 1;

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'CYCLIC_ATTRIBUTE_TREE_FOUND'
              , i_env_param1 => l_attr_name
            );
        end if;
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error      => 'ATTR_WITH_NAME_ALREADY_EXISTS'
              , i_env_param1 => upper(replace(i_attr_name, ' ', '_'))
            );
    end;
    
    check_attribute_text_unique(
        i_service_type_id  => i_service_type_id
      , i_lang             => i_lang
      , i_text             => i_short_description
      , i_column_name      => 'label'
    );
    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_attribute'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_short_description
    );
    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_attribute'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_description
    );
    com_api_i18n_pkg.add_text(
        i_table_name   => 'prd_attribute'
      , i_column_name  => 'short_name'
      , i_object_id    => o_id
      , i_text         => i_short_name
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    update_service_type_fee (
        i_service_type_id  => i_service_type_id
      , i_is_service_fee   => i_is_service_fee
      , i_attribute_id     => o_id
    );
end add_attribute;

procedure modify_attribute (
    i_id                in     com_api_type_pkg.t_short_id
  , i_service_type_id   in     com_api_type_pkg.t_short_id
  , i_parent_id         in     com_api_type_pkg.t_short_id
  , i_display_order     in     com_api_type_pkg.t_tiny_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_short_description in     com_api_type_pkg.t_name
  , i_description       in     com_api_type_pkg.t_full_desc
  , i_is_visible        in     com_api_type_pkg.t_boolean
  , i_is_service_fee    in     com_api_type_pkg.t_boolean
  , i_is_repeating      in     com_api_type_pkg.t_boolean       default null
  , i_counter_algorithm in     com_api_type_pkg.t_dict_value    default null
) is
    l_object_type           com_api_type_pkg.t_dict_value;
    l_entity_type           com_api_type_pkg.t_dict_value;
    l_count                 com_api_type_pkg.t_count := 0;
    l_attr_name             com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug('prd_ui_attribute_pkg.modify_attribute: id [' || i_id ||
                      '], i_short_description [' || i_short_description || ']');

    --check display order
    select count(1)
      into l_count
      from prd_attribute_vw
     where service_type_id = i_service_type_id
       and display_order   = i_display_order
       and id != i_id
       and (parent_id = i_parent_id or nvl(i_parent_id, 0) = nvl(parent_id, 0));

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'SERVICE_TERM_DISPLAY_ORDER_ALREADY_USED'
          , i_env_param1  => i_display_order
          , i_env_param2  => i_service_type_id
        );
    end if;

    select object_type
         , entity_type
      into l_object_type
         , l_entity_type
      from prd_attribute_vw
     where id = i_id;

    trc_log_pkg.debug(
        i_text => 'prd_ui_attribute_pkg.modify_attribute: l_object_type=' || l_object_type || ' l_entity_type=' || l_entity_type
    );

    if l_object_type is not null then
        com_ui_dictionary_pkg.modify_article(
            i_dict       => substr(l_object_type, 1, 4)
          , i_code       => substr(l_object_type, 5, 4)
          , i_short_desc => i_short_description
          , i_full_desc  => i_description
          , i_lang       => i_lang
        );
    end if;

    case l_entity_type
    when fcl_api_const_pkg.ENTITY_TYPE_FEE then
        for rec in(
            select b.cycle_type
                 , b.limit_type
                 , c.cycle_type    as cycle_type_from_limit
                 , c.id            as limit_type_id
                 , c.entity_type   as limit_entity_type
                 , c.is_internal
                 , c.seqnum        as limit_seqnum
                 , c.posting_method
             from  fcl_ui_fee_type_vw b
                 , fcl_ui_limit_type_vw c
             where b.fee_type    = l_object_type
               and b.limit_type  = c.limit_type(+)
        ) loop
            if rec.cycle_type is not null then
                fcl_ui_cycle_pkg.modify_cycle_type(
                    i_cycle_type            => rec.cycle_type
                  , i_is_repeating          => i_is_repeating
                  , i_is_standard           => null
                  , i_cycle_calc_start_date => null
                  , i_cycle_calc_date_type  => null
                );
                com_ui_dictionary_pkg.modify_article(
                    i_dict         => substr(rec.cycle_type, 1, 4)
                  , i_code         => substr(rec.cycle_type, 5, 4)
                  , i_short_desc   => com_api_label_pkg.get_label_text('prd.cycle_for') || ' ' || i_short_description
                                   || case
                                          when rec.limit_type is not null
                                          and rec.cycle_type_from_limit is not null
                                          then ' 2'
                                          else ''
                                      end
                  , i_full_desc    => null
                  , i_lang         => i_lang
                );
            end if;

            if rec.limit_type is not null then
                fcl_ui_limit_pkg.modify_limit_type(
                    i_limit_type_id     => rec.limit_type_id
                  , i_limit_type        => rec.limit_type
                  , i_cycle_type        => rec.cycle_type_from_limit
                  , i_entity_type       => rec.limit_entity_type
                  , i_is_internal       => rec.is_internal
                  , i_seqnum            => rec.limit_seqnum
                  , i_posting_method    => rec.posting_method
                  , i_counter_algorithm => i_counter_algorithm
                );
                com_ui_dictionary_pkg.modify_article(
                    i_dict       => substr(rec.limit_type, 1, 4)
                  , i_code       => substr(rec.limit_type, 5, 4)
                  , i_short_desc => com_api_label_pkg.get_label_text('prd.limit_for') || ' ' || i_short_description
                  , i_full_desc  => null
                  , i_lang       => i_lang
                );
            end if;

            if rec.cycle_type_from_limit is not null then
                fcl_ui_cycle_pkg.modify_cycle_type(
                    i_cycle_type            => rec.cycle_type_from_limit
                  , i_is_repeating          => i_is_repeating
                  , i_is_standard           => null
                  , i_cycle_calc_start_date => null
                  , i_cycle_calc_date_type  => null
                );
                com_ui_dictionary_pkg.modify_article(
                    i_dict       => substr(rec.cycle_type_from_limit, 1, 4)
                  , i_code       => substr(rec.cycle_type_from_limit, 5, 4)
                  , i_short_desc => com_api_label_pkg.get_label_text('prd.cycle_for') || ' ' || i_short_description
                  , i_full_desc  => null
                  , i_lang       => i_lang
                );
            end if;
        end loop;

    when fcl_api_const_pkg.ENTITY_TYPE_LIMIT then
        for rec in (
            select cycle_type
                 , id            as limit_type_id
                 , entity_type   as limit_entity_type
                 , is_internal
                 , seqnum        as limit_seqnum
                 , posting_method
              from fcl_limit_type_vw
             where limit_type = l_object_type
        ) loop
            if rec.cycle_type is not null then
                fcl_ui_cycle_pkg.modify_cycle_type(
                    i_cycle_type            => rec.cycle_type
                  , i_is_repeating          => i_is_repeating
                  , i_is_standard           => null
                  , i_cycle_calc_start_date => null
                  , i_cycle_calc_date_type  => null
                );
                com_ui_dictionary_pkg.modify_article(
                    i_dict         => substr(rec.cycle_type, 1, 4)
                  , i_code         => substr(rec.cycle_type, 5, 4)
                  , i_short_desc   => com_api_label_pkg.get_label_text('prd.cycle_for') || ' ' || i_short_description
                  , i_full_desc    => null
                  , i_lang         => i_lang
                );
            else
                com_ui_dictionary_pkg.modify_article(
                    i_dict       => substr(l_object_type, 1, 4)
                  , i_code       => substr(l_object_type, 5, 4)
                  , i_short_desc => com_api_label_pkg.get_label_text('prd.limit_for') || ' ' || i_short_description
                  , i_full_desc  => null
                  , i_lang       => i_lang
                );
            end if;
            fcl_ui_limit_pkg.modify_limit_type(
                i_limit_type_id     => rec.limit_type_id
              , i_limit_type        => l_object_type
              , i_cycle_type        => rec.cycle_type
              , i_entity_type       => rec.limit_entity_type
              , i_is_internal       => rec.is_internal
              , i_seqnum            => rec.limit_seqnum
              , i_posting_method    => rec.posting_method
              , i_counter_algorithm => i_counter_algorithm
            );
        end loop;

    when fcl_api_const_pkg.ENTITY_TYPE_CYCLE then
        for rec in (
            select cycle_type
              from fcl_ui_cycle_type_vw
             where cycle_type = l_object_type
        ) loop
            if rec.cycle_type is not null then
                fcl_ui_cycle_pkg.modify_cycle_type(
                    i_cycle_type            => rec.cycle_type
                  , i_is_repeating          => i_is_repeating
                  , i_is_standard           => null
                  , i_cycle_calc_start_date => null
                  , i_cycle_calc_date_type  => null
                );
                com_ui_dictionary_pkg.modify_article(
                    i_dict         => substr(rec.cycle_type, 1, 4)
                  , i_code         => substr(rec.cycle_type, 5, 4)
                  , i_short_desc   => com_api_label_pkg.get_label_text('prd.cycle_for') || ' ' || i_short_description
                  , i_full_desc    => null
                  , i_lang         => i_lang
                );
            end if;
        end loop;

    else
        null;
    end case;

    update prd_attribute_vw
    set display_order   = i_display_order
      , service_type_id = i_service_type_id
      , parent_id       = i_parent_id
      , is_visible      = i_is_visible
    where id            = i_id;

    select count(*)
         , min(attr_name)
      into l_count
         , l_attr_name
      from (select connect_by_iscycle iscycle, id, parent_id, attr_name
              from prd_ui_attribute_vw
           connect by nocycle prior id = parent_id)
             where iscycle = 1;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'CYCLIC_ATTRIBUTE_TREE_FOUND'
          , i_env_param1 => l_attr_name
          );
    end if;

    check_attribute_text_unique(
        i_service_type_id  => i_service_type_id
      , i_lang             => i_lang
      , i_text             => i_short_description
      , i_column_name      => 'label'
      , i_object_id        => i_id
    );
    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_attribute'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_short_description
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_attribute'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_description
    );

    update_service_type_fee (
        i_service_type_id  => i_service_type_id
      , i_is_service_fee   => i_is_service_fee
      , i_attribute_id     => i_id
    );
    trc_log_pkg.debug('prd_ui_attribute_pkg.modify_attribute: END');
end modify_attribute;

procedure delete_attribute (
    i_id                    in com_api_type_pkg.t_short_id
) is
    l_check_depend          com_api_type_pkg.t_tiny_id;
    l_entity_type           com_api_type_pkg.t_dict_value;
    l_object_type           com_api_type_pkg.t_dict_value;
    l_id                    com_api_type_pkg.t_long_id;
    l_seq                   com_api_type_pkg.t_short_id;
begin
    select count(*)
      into l_check_depend
      from (select attr_id from prd_attribute_value_vw where attr_id = i_id and rownum = 1
            union all
            select parent_id from prd_attribute_vw where parent_id = i_id and rownum = 1
          );

    if l_check_depend > 0 then
        com_api_error_pkg.raise_error (
            i_error         => 'ATTR_HAS_DEPENDANT'
          , i_env_param1  => i_id
        );
    end if;

    delete from
        prd_attribute_scale_vw
    where
        attr_id = i_id;

    com_api_i18n_pkg.remove_text (
        i_table_name => 'prd_attribute'
      , i_object_id  => i_id
    );

    select object_type
         , entity_type
      into l_object_type
         , l_entity_type
      from prd_attribute_vw
     where id = i_id;

    case l_entity_type
    when fcl_api_const_pkg.ENTITY_TYPE_FEE then
        for rec in (
            select b.fee_type
                 , b.cycle_type
                 , b.limit_type
                 , c.cycle_type cycle_type_from_limit
             from  fcl_ui_fee_type_vw b
                 , fcl_ui_limit_type_vw c
             where b.fee_type    = l_object_type
               and b.limit_type  = c.limit_type(+)
        ) loop
            if rec.cycle_type is not null then
                fcl_ui_cycle_pkg.remove_cycle_type (
                    i_cycle_type  => rec.cycle_type
                );
            end if;

            if rec.limit_type is not null then
                select id
                     , seqnum
                  into l_id
                     , l_seq
                  from fcl_limit_type_vw
                 where limit_type = rec.limit_type;

                fcl_ui_limit_pkg.remove_limit_type (
                    i_limit_type_id  => l_id
                  , i_seqnum         => l_seq + 1
                );
            end if;

            if rec.cycle_type_from_limit is not null then
                fcl_ui_cycle_pkg.remove_cycle_type (
                    i_cycle_type  => rec.cycle_type_from_limit
                );
            end if;

            if rec.fee_type is not null then
                select id
                     , seqnum
                  into l_id
                     , l_seq
                  from fcl_fee_type_vw
                 where fee_type = rec.fee_type;

                fcl_ui_fee_pkg.remove_fee_type (
                    i_fee_type  => rec.fee_type
                  , i_seqnum    => l_seq + 1
                );
            end if;

        end loop;

    when fcl_api_const_pkg.ENTITY_TYPE_LIMIT then
        for rec in (
            select limit_type
                 , cycle_type
              from fcl_limit_type_vw
             where limit_type = l_object_type
        ) loop
            if rec.cycle_type is not null then
                fcl_ui_cycle_pkg.remove_cycle_type (
                    i_cycle_type  => rec.cycle_type
                );
            end if;

            if rec.limit_type is not null then
                begin
                    select id
                         , seqnum
                      into l_id
                         , l_seq
                      from fcl_limit_type_vw
                     where limit_type = rec.limit_type;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error (
                            i_error         => 'LIMIT_TYPE_NOT_EXIST'
                          , i_env_param1  => rec.limit_type
                        );
                end;

                fcl_ui_limit_pkg.remove_limit_type (
                    i_limit_type_id  => l_id
                  , i_seqnum         => l_seq + 1
                );
            end if;
        end loop;

    when fcl_api_const_pkg.ENTITY_TYPE_CYCLE then
        if l_object_type is not null then
            fcl_ui_cycle_pkg.remove_cycle_type (
                i_cycle_type  => l_object_type
            );
        end if;
    else
        null;
    end case;
/*                                           it is duplication of calling
    if l_object_type is not null then
        com_ui_dictionary_pkg.remove_article(
            i_dict => substr(l_object_type, 1, 4)
          , i_code => substr(l_object_type, 5, 4)
        );
    end if;
*/
    delete from prd_attribute_vw
    where id = i_id;
end delete_attribute;

procedure add_attribute_scale (
    o_id                    out com_api_type_pkg.t_tiny_id
    , i_attr_id             in com_api_type_pkg.t_short_id
    , i_inst_id             in com_api_type_pkg.t_tiny_id
    , i_scale_id            in com_api_type_pkg.t_tiny_id
    , o_seqnum              out com_api_type_pkg.t_tiny_id
) is
begin
    o_id := prd_attribute_scale_seq.nextval;
    o_seqnum := 1;

    begin
        insert into prd_attribute_scale_vw (
            id
            , attr_id
            , inst_id
            , scale_id
            , seqnum
        ) values (
            o_id
            , i_attr_id
            , i_inst_id
            , i_scale_id
            , o_seqnum
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error       => 'ATTR_SCALE_ALREADY_EXISTS'
              , i_env_param1  => ost_ui_institution_pkg.get_inst_name(i_inst_id)
            );
    end;
end;

procedure modify_attribute_scale (
    i_id                    in com_api_type_pkg.t_tiny_id
    , i_scale_id            in com_api_type_pkg.t_tiny_id
    , io_seqnum             in out com_api_type_pkg.t_seqnum
) is
begin
    update
        prd_attribute_scale_vw
    set
        seqnum = io_seqnum
        , scale_id = i_scale_id
    where
        id = i_id;

    io_seqnum := io_seqnum + 1;
end;

procedure remove_attribute_scale (
    i_id                    in com_api_type_pkg.t_tiny_id
    , i_seqnum              in com_api_type_pkg.t_tiny_id
) is
    l_check_depend          com_api_type_pkg.t_count := 0;
begin
    select count(*)
      into l_check_depend
      from prd_attribute_scale_vw s
         , prd_attribute_value_vw v
     where s.attr_id = v.attr_id
       and s.id      = i_id
       and v.mod_id is not null;

    -- Restriction for removing an association between a scale and an attribute,
    -- if at least one modifier from the scale is used for the attribute
    if l_check_depend > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'ATTR_SCALE_ALREADY_USED'
          , i_env_param1 => i_id
        );
    end if;

    update prd_attribute_scale_vw
       set seqnum  = i_seqnum
     where id = i_id;

    delete from prd_attribute_scale_vw
     where id = i_id;
end;

function get_cycle_type(
    i_attr_name  in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_dict_value is
    l_cycle_type com_api_type_pkg.t_dict_value;
begin
    select min(object_type)
      into l_cycle_type
      from prd_attribute_vw
     where attr_name   = i_attr_name
       and entity_type = fcl_api_const_pkg.ENTITY_TYPE_CYCLE;

    return l_cycle_type;
end;

end;
/
