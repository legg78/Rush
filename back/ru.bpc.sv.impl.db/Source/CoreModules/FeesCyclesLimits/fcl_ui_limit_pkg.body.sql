create or replace package body fcl_ui_limit_pkg as
/***********************************************************
* User interface prcedures for limits
*
* Created by Filimonov A.(filimonov@bpc.ru)  at 07.08.2009
* Last changed by $Author$
* $LastChangedDate::                           $
* Revision: $LastChangedRevision$
* Module: FCL_UI_LIMIT_PKG
* @headcom
***********************************************************/

-- This parameter is calculated in the initialization section
g_instance_type                 com_api_type_pkg.t_sign;

procedure add_limit_type(
    io_limit_type       in out  com_api_type_pkg.t_dict_value
  , i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_is_internal       in      com_api_type_pkg.t_boolean
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_posting_method    in      com_api_type_pkg.t_dict_value   default null
  , i_counter_algorithm in      com_api_type_pkg.t_dict_value   default null
  , o_limit_type_id        out  com_api_type_pkg.t_tiny_id
  , i_limit_usage       in      com_api_type_pkg.t_dict_value   default null
) is
    l_count                     pls_integer;
begin
    if io_limit_type is null then
        select max(to_number(substr(limit_type, 5, 4))) + 1
          into io_limit_type
          from fcl_limit_type
         where regexp_like(limit_type, 'LMTP' || g_instance_type || '\d{3}');

        io_limit_type := 'LMTP' || lpad(to_char(greatest(nvl(io_limit_type, 0)
                                                       , g_instance_type * 1000 + 1)
                                              , 'TM9')
                                      , 4, '0');
    end if;

    select count(id)
      into l_count
      from fcl_limit_type_vw
     where limit_type = io_limit_type;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'LIMIT_TYPE_ALREADY_EXIST'
          , i_env_param1 => io_limit_type
        );
    end if;

    if i_cycle_type is not null then
        com_api_dictionary_pkg.check_article('CYTP', i_cycle_type);
        
        update fcl_cycle_type 
           set cycle_calc_start_date = nvl(cycle_calc_start_date, fcl_api_const_pkg.START_DATE_CURRENT_DATE)
         where cycle_type = i_cycle_type;              
    end if;

    if i_entity_type is not null then
        com_api_dictionary_pkg.check_article('ENTT', i_entity_type);
    end if;

    select count(id)
      into l_count
      from com_dictionary_vw
     where dict = 'LMTP'
       and code = lpad(substr(io_limit_type, 5), 4, '0');

    if l_count = 0 then
        com_ui_dictionary_pkg.add_article(
            i_dict         => 'LMTP'
          , i_code         => lpad(substr(io_limit_type, 5), 4, '0')
          , i_short_desc   => i_short_desc
          , i_full_desc    => i_full_desc
          , i_is_editable  => com_api_type_pkg.TRUE
          , i_lang         => i_lang
        );
    end if;

    o_limit_type_id := fcl_limit_type_seq.nextval;

    insert into fcl_limit_type_vw(
        id
      , seqnum
      , limit_type
      , cycle_type
      , entity_type
      , is_internal
      , posting_method
      , counter_algorithm
      , limit_usage
    ) values (
        o_limit_type_id
      , 1
      , io_limit_type
      , i_cycle_type
      , i_entity_type
      , i_is_internal
      , i_posting_method
      , i_counter_algorithm
      , i_limit_usage
    );
end;

procedure modify_limit_type(
    i_limit_type_id     in      com_api_type_pkg.t_tiny_id
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_is_internal       in      com_api_type_pkg.t_boolean
  , i_seqnum            in      com_api_type_pkg.t_seqnum
  , i_posting_method    in      com_api_type_pkg.t_dict_value   default null
  , i_counter_algorithm in      com_api_type_pkg.t_dict_value   default null
) is
    l_count             pls_integer;
begin
    if i_limit_type is null then
        com_api_error_pkg.raise_error(
            i_error             => 'LIMIT_TYPE_NOT_DEFINED'
        );
    end if;

    select count(1)
      into l_count
      from fcl_limit_vw
     where limit_type = i_limit_type;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'LIMITS_FOR_LIMIT_TYPE_EXIST'
          , i_env_param1        => i_limit_type
        );
    end if;

    if i_cycle_type is not null then
        com_api_dictionary_pkg.check_article('CYTP', i_cycle_type);
    end if;

    if i_entity_type is not null then
        com_api_dictionary_pkg.check_article('ENTT', i_entity_type);
    end if;

    update fcl_limit_type_vw
       set seqnum            = i_seqnum
         , cycle_type        = i_cycle_type
         , entity_type       = i_entity_type
         , is_internal       = i_is_internal
         , posting_method    = i_posting_method
         , counter_algorithm = i_counter_algorithm
     where id                = i_limit_type_id;
end;

procedure remove_limit_type(
    i_limit_type_id     in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_count             pls_integer;
    l_limit_type        com_api_type_pkg.t_dict_value;
begin
    if i_limit_type_id is null then
        com_api_error_pkg.raise_error(
            i_error             => 'LIMIT_TYPE_NOT_DEFINED'
        );
    end if;

    select count(a.id) cnt
         , min(b.limit_type) limit_type
      into l_count
         , l_limit_type
      from fcl_limit_vw a
         , fcl_limit_type_vw b
     where a.limit_type(+) = b.limit_type
       and b.id            = i_limit_type_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'LIMITS_FOR_LIMIT_TYPE_EXIST'
          , i_env_param1        => l_limit_type
        );
    end if;

    update fcl_limit_type_vw
       set seqnum = i_seqnum
     where id     = i_limit_type_id;

    delete from fcl_limit_type_vw where id = i_limit_type_id;

    com_ui_dictionary_pkg.remove_article(
        i_dict              => 'LMTP'
      , i_code              => lpad(substr(l_limit_type, 5), 4, '0')
      , i_is_leaf           => com_api_const_pkg.TRUE
    );
end;

procedure add_limit_rate(
    i_limit_type     in      com_api_type_pkg.t_dict_value
  , i_rate_type      in      com_api_type_pkg.t_dict_value
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , o_limit_rate_id     out  com_api_type_pkg.t_tiny_id
  , o_seqnum            out  com_api_type_pkg.t_seqnum
) is
    l_count          com_api_type_pkg.t_tiny_id;
begin
    select count(id)
      into l_count
      from fcl_limit_rate_vw
     where inst_id    = i_inst_id
       and limit_type = i_limit_type;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error       =>  'LIMIT_RATE_ALREADY_EXISTS'
          , i_env_param1  =>  i_limit_type
          , i_env_param2  =>  ost_ui_institution_pkg.get_inst_name(i_inst_id)
        );
    end if;

    select fcl_limit_rate_seq.nextval into o_limit_rate_id from dual;

    o_seqnum := 1;

    insert into fcl_limit_rate_vw(
        id
      , seqnum
      , limit_type
      , rate_type
      , inst_id
    ) values (
        o_limit_rate_id
      , o_seqnum
      , i_limit_type
      , i_rate_type
      , i_inst_id
    );
end;

procedure modify_limit_rate(
    i_limit_rate_id     in      com_api_type_pkg.t_tiny_id
  , i_rate_type         in      com_api_type_pkg.t_dict_value
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
) is
begin
    update fcl_limit_rate_vw
       set rate_type = i_rate_type
         , seqnum    = io_seqnum
     where id        = i_limit_rate_id;

    io_seqnum := io_seqnum + 1;
end;

procedure remove_limit_rate(
    i_limit_rate_id     in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update fcl_limit_rate_vw
       set seqnum    = i_seqnum
     where id        = i_limit_rate_id;

    delete fcl_limit_rate_vw
     where id        = i_limit_rate_id;
end;

procedure add_limit(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_count_limit       in      com_api_type_pkg.t_long_id
  , i_sum_limit         in      com_api_type_pkg.t_money
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_posting_method    in      com_api_type_pkg.t_dict_value   default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_is_custom         in      com_api_type_pkg.t_boolean      default null
  , i_limit_base        in      com_api_type_pkg.t_dict_value
  , i_limit_rate        in      com_api_type_pkg.t_money
  , i_check_type        in      com_api_type_pkg.t_dict_value   default null
  , i_counter_algorithm in      com_api_type_pkg.t_dict_value   default null
  , o_limit_id             out  com_api_type_pkg.t_long_id
  , i_count_max_bound   in      com_api_type_pkg.t_long_id      default null
  , i_sum_max_bound     in      com_api_type_pkg.t_money        default null
) is
    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_cycle_type2       com_api_type_pkg.t_dict_value;
    l_posting_method    com_api_type_pkg.t_dict_value := nvl(i_posting_method, acc_api_const_pkg.POSTING_METHOD_BULK);
    l_limit_usage       com_api_type_pkg.t_dict_value;
begin
    if i_limit_type is null then
        com_api_error_pkg.raise_error(
            i_error             => 'LIMIT_TYPE_NOT_DEFINED'
        );
    end if;

    begin
        select cycle_type, limit_usage
          into l_cycle_type, l_limit_usage
          from fcl_limit_type_vw
         where limit_type = i_limit_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error             => 'LIMIT_TYPE_NOT_EXIST'
              , i_env_param1        => i_limit_type
            );
    end;

    if l_limit_usage = fcl_api_const_pkg.LIMIT_USAGE_COUNT_ONLY and i_sum_limit > 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'LIMIT_USAGE_COUNT_ONLY_SUM_NONZERO'
          , i_env_param1        => l_limit_usage
          , i_env_param2        => i_sum_limit
        );
    elsif l_limit_usage = fcl_api_const_pkg.LIMIT_USAGE_SUM_ONLY and i_count_limit > 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'LIMIT_USAGE_SUM_ONLY_COUNT_NONZERO'
          , i_env_param1        => l_limit_usage
          , i_env_param2        => i_count_limit
        );
    end if;

    if i_posting_method is null then
        begin
            select case when s.entity_type in (ost_api_const_pkg.ENTITY_TYPE_AGENT, ost_api_const_pkg.ENTITY_TYPE_INSTITUTION)
                        then acc_api_const_pkg.POSTING_METHOD_BUFFERED 
                        else acc_api_const_pkg.POSTING_METHOD_IMMEDIATE
                   end
              into l_posting_method
              from prd_service_type s
                 , prd_attribute a
             where a.service_type_id = s.id
               and a.object_type in 
                       (
                        select i_limit_type object_type from dual
                        union all
                        select fee_type object_type from fcl_fee_type where limit_type = i_limit_type
                       );
        exception
            when no_data_found then
                null;
        end; 
    end if;

    if i_cycle_id is not null then
        begin
            select cycle_type
              into l_cycle_type2
              from fcl_cycle_vw
             where id = i_cycle_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error             => 'CYCLE_NOT_FOUND'
                  , i_env_param1        => i_cycle_id
                );
        end;

        if l_cycle_type != l_cycle_type2 then
            com_api_error_pkg.raise_error(
                i_error             => 'CYCLE_HAS_WRONG_TYPE_FOR_LIMIT'
              , i_env_param1        => i_cycle_id
              , i_env_param2        => l_cycle_type2
              , i_env_param3        => l_cycle_type
            );
        end if;
    end if;

    if i_inst_id is null then
        com_api_error_pkg.raise_error(
            i_error             => 'INSTITUTION_NOT_DEFINED'
        );
    end if;

    select fcl_limit_seq.nextval into o_limit_id from dual;

    insert into fcl_limit_vw(
        id
      , seqnum
      , limit_type
      , cycle_id
      , count_limit
      , sum_limit
      , currency
      , posting_method
      , is_custom
      , inst_id
      , limit_base
      , limit_rate
      , check_type
      , counter_algorithm
      , count_max_bound
      , sum_max_bound
    ) values (
        o_limit_id
      , 1
      , i_limit_type
      , i_cycle_id
      , nvl(i_count_limit, -1)
      , nvl(i_sum_limit, -1)
      , i_currency
      , l_posting_method
      , nvl(i_is_custom, com_api_const_pkg.FALSE)
      , i_inst_id
      , i_limit_base
      , i_limit_rate
      , i_check_type
      , i_counter_algorithm
      , i_count_max_bound
      , i_sum_max_bound
    );

end;

procedure modify_limit(
    i_limit_id          in      com_api_type_pkg.t_long_id
  , i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_count_limit       in      com_api_type_pkg.t_long_id
  , i_sum_limit         in      com_api_type_pkg.t_money
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_posting_method    in      com_api_type_pkg.t_dict_value
  , i_seqnum            in      com_api_type_pkg.t_seqnum
  , i_limit_base        in      com_api_type_pkg.t_dict_value
  , i_limit_rate        in      com_api_type_pkg.t_money
  , i_check_type        in      com_api_type_pkg.t_dict_value       default null
  , i_counter_algorithm in      com_api_type_pkg.t_dict_value       default null
  , i_count_max_bound   in      com_api_type_pkg.t_long_id          default null
  , i_sum_max_bound     in      com_api_type_pkg.t_money            default null
) is
    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_cycle_type2       com_api_type_pkg.t_dict_value;
    l_limit_type        com_api_type_pkg.t_dict_value;
begin
    if i_limit_id is null then
        com_api_error_pkg.raise_error(
            i_error             => 'LIMIT_ID_NOT_DEFINED'
        );
    end if;

    begin
        select cycle_type
             , b.limit_type
          into l_cycle_type
             , l_limit_type
          from fcl_limit_type_vw a
             , fcl_limit_vw      b
         where a.limit_type = b.limit_type
           and b.id         = i_limit_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error             => 'LIMIT_NOT_FOUND'
              , i_env_param1        => i_limit_id
            );
    end;

    if i_cycle_id is not null then
        begin
            select cycle_type
              into l_cycle_type2
              from fcl_cycle_vw
             where id = i_cycle_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error             => 'CYCLE_NOT_FOUND'
                  , i_env_param1        => i_cycle_id
                );
        end;

        if l_cycle_type != l_cycle_type2 then
            com_api_error_pkg.raise_error(
                i_error             => 'CYCLE_HAS_WRONG_TYPE_FOR_LIMIT'
              , i_env_param1        => i_cycle_id
              , i_env_param2        => l_cycle_type2
              , i_env_param3        => l_cycle_type
            );
        end if;
    else
        com_api_error_pkg.raise_error(
            i_error             => 'CYCLE_MANDATORY_FOR_LIMIT'
          , i_env_param1        => l_limit_type
        );
    end if;

    update fcl_limit_vw
       set seqnum         = i_seqnum
         , cycle_id       = i_cycle_id
         , count_limit    = nvl(i_count_limit, 0)
         , sum_limit      = nvl(i_sum_limit, 0)
         , currency       = i_currency
         , posting_method = i_posting_method
         , limit_base     = i_limit_base
         , limit_rate     = i_limit_rate
         , check_type     = i_check_type 
         , counter_algorithm = i_counter_algorithm
         , count_max_bound   = nvl(i_count_max_bound, count_max_bound)
         , sum_max_bound     = nvl(i_sum_max_bound, sum_max_bound)
     where id             = i_limit_id;
end;

procedure remove_limit(
    i_limit_id          in      com_api_type_pkg.t_long_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update fcl_limit_vw
       set seqnum         = i_seqnum
     where id             = i_limit_id;

    delete from fcl_limit_vw where id = i_limit_id;
end;

function get_limit_desc(
    i_limit_id       in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_name is
    l_result                    com_api_type_pkg.t_name;
    l_limit                     fcl_api_type_pkg.t_limit;
    l_format                    com_api_type_pkg.t_name;
    l_nls_numeric_characters    com_api_type_pkg.t_name := com_ui_user_env_pkg.get_nls_numeric_characters;
begin
    select a.count_limit
         , a.sum_limit/power(10, b.exponent)
         , b.name currency
         , com_api_const_pkg.get_number_i_format_with_sep || case when b.exponent > 0 then 'D' || rpad('0', b.exponent, '0') else '' end
         , a.limit_base
         , a.limit_rate
         , a.limit_type
         , a.inst_id
      into l_limit.count_limit
         , l_limit.sum_limit
         , l_limit.currency
         , l_format
         , l_limit.limit_base
         , l_limit.limit_rate
         , l_limit.limit_type
         , l_limit.inst_id
      from fcl_limit_vw a
         , fcl_limit_type_vw t
         , com_ui_currency_vw b
     where a.id         = i_limit_id
       and a.currency   = b.code(+)
       and a.limit_type = t.limit_type
       and rownum       = 1;

     if nvl(l_limit.count_limit, 0) >= 0 then
        l_result := com_api_label_pkg.get_label_text('LIMIT_BY_COUNT')|| ' ' || l_limit.count_limit;
     end if;

     if nvl(l_limit.sum_limit, 0) >= 0 then
         if l_result is not null then
            l_result := l_result || '; ';
         end if;

        l_result := l_result || com_api_label_pkg.get_label_text('LIMIT_BY_SUM') || ' ' 
                 || case when l_limit.limit_base is not null 
                    then l_limit.limit_rate || ' % of '--then to_char(l_limit.limit_rate, get_number_format)||' % of '
                    else ''
                    end
                 || to_char(l_limit.sum_limit, l_format, l_nls_numeric_characters)|| ' ' || l_limit.currency;

     elsif l_limit.limit_base is not null then

         if l_result is not null then
            l_result := l_result || '; ';
         end if;

         l_result := l_result || com_api_label_pkg.get_label_text('BASE_LIMIT') || ' ' 
                              || l_limit.limit_rate ||' % of ' 
                              || l_limit.limit_base || ' - ' 
                              || com_api_dictionary_pkg.get_article_text(
                                      i_article => l_limit.limit_base
                                    , i_lang    => com_ui_user_env_pkg.get_user_lang
                                 );
                         
     end if;

     if l_result is null then
        l_result := com_api_label_pkg.get_label_text('NOT_LIMITED');
     end if;

     return l_result;
exception
    when no_data_found then
        return null;
end;

procedure get_limit_counter(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id         default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_param_map         in      com_param_map_tpt
  , io_currency         in out  com_api_type_pkg.t_curr_code
  , i_eff_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , o_last_reset_date      out  date
  , o_count_curr           out  com_api_type_pkg.t_long_id
  , o_count_limit          out  com_api_type_pkg.t_long_id
  , o_sum_limit            out  com_api_type_pkg.t_money
  , o_sum_curr             out  com_api_type_pkg.t_money
) is
    l_product_id                com_api_type_pkg.t_short_id;
    l_param_tab                 com_api_type_pkg.t_param_tab;
begin
    if i_param_map is not null then
        for i in 1..i_param_map.count loop
            if i_param_map(i).char_value is not null then
                rul_api_param_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).char_value, l_param_tab);
                
            elsif i_param_map(i).number_value is not null then
                rul_api_param_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).number_value, l_param_tab);
                
            elsif i_param_map(i).date_value is not null then
                rul_api_param_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).date_value, l_param_tab);
                
            else
                null;
            end if;          
        end loop;
    end if;
    
    if i_product_id is null then    
        l_product_id := prd_api_product_pkg.get_product_id(
            i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
        );        
    else
        l_product_id := i_product_id;
    end if;
    
    fcl_api_limit_pkg.get_limit_counter(
        i_limit_type       => i_limit_type
      , i_product_id       => l_product_id
      , i_entity_type      => i_entity_type
      , i_object_id        => i_object_id
      , i_params           => l_param_tab
      , io_currency        => io_currency
      , i_eff_date         => i_eff_date
      , i_split_hash       => i_split_hash
      , i_inst_id          => i_inst_id
      , o_last_reset_date  => o_last_reset_date
      , o_count_curr       => o_count_curr
      , o_count_limit      => o_count_limit
      , o_sum_limit        => o_sum_limit
      , o_sum_curr         => o_sum_curr
    );
end;

procedure switch_limit_counter(
    i_limit_type         in      com_api_type_pkg.t_dict_value
  , i_product_id         in      com_api_type_pkg.t_short_id         default null
  , i_entity_type        in      com_api_type_pkg.t_dict_value
  , i_object_id          in      com_api_type_pkg.t_long_id
  , i_param_map          in      com_param_map_tpt
  , i_count_value        in      com_api_type_pkg.t_long_id          default null
  , i_sum_value          in      com_api_type_pkg.t_money
  , i_currency           in      com_api_type_pkg.t_curr_code
  , i_eff_date           in      date                                default null
  , i_split_hash         in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id            in      com_api_type_pkg.t_inst_id          default null
  , i_check_overlimit    in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , i_switch_limit       in      com_api_type_pkg.t_boolean          default com_api_const_pkg.TRUE
  , i_source_entity_type in      com_api_type_pkg.t_dict_value       default null
  , i_source_object_id   in      com_api_type_pkg.t_long_id          default null
  , i_service_id         in      com_api_type_pkg.t_short_id         default null
  , i_test_mode          in      com_api_type_pkg.t_dict_value       default fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
) is
    l_sum_value         com_api_type_pkg.t_money;
    l_currency          com_api_type_pkg.t_curr_code;
    l_product_id                com_api_type_pkg.t_short_id;
    l_param_tab                 com_api_type_pkg.t_param_tab;
begin
    if i_param_map is not null then
        for i in 1..i_param_map.count loop
            if i_param_map(i).char_value is not null then
                rul_api_param_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).char_value, l_param_tab);
                
            elsif i_param_map(i).number_value is not null then
                rul_api_param_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).number_value, l_param_tab);
                
            elsif i_param_map(i).date_value is not null then
                rul_api_param_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).date_value, l_param_tab);
                
            else
                null;
            end if;          
        end loop;
    end if;
    
    if i_product_id is null then    
        l_product_id := prd_api_product_pkg.get_product_id(
            i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
        );        
    else
        l_product_id := i_product_id;
    end if;

    fcl_api_limit_pkg.switch_limit_counter (
        i_limit_type          => i_limit_type
      , i_product_id          => l_product_id
      , i_entity_type         => i_entity_type
      , i_object_id           => i_object_id
      , i_params              => l_param_tab
      , i_count_value         => i_count_value
      , i_sum_value           => i_sum_value
      , i_currency            => i_currency
      , i_eff_date            => i_eff_date
      , i_split_hash          => i_split_hash
      , i_check_overlimit     => i_check_overlimit
      , i_inst_id             => i_inst_id
      , i_switch_limit        => i_switch_limit
      , i_source_entity_type  => i_source_entity_type
      , i_source_object_id    => i_source_object_id
      , o_sum_value           => l_sum_value
      , o_currency            => l_currency
      , i_service_id          => i_service_id
      , i_test_mode           => i_test_mode
    );
end;

procedure switch_limit_counter(
    i_limit_type         in      com_api_type_pkg.t_dict_value
  , i_product_id         in      com_api_type_pkg.t_short_id         default null
  , i_entity_type        in      com_api_type_pkg.t_dict_value
  , i_object_id          in      com_api_type_pkg.t_long_id
  , i_param_map          in      com_param_map_tpt
  , i_count_value        in      com_api_type_pkg.t_long_id          default null
  , i_sum_value          in      com_api_type_pkg.t_money
  , i_currency           in      com_api_type_pkg.t_curr_code
  , i_eff_date           in      date                                default null
  , i_split_hash         in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id            in      com_api_type_pkg.t_inst_id          default null
  , i_check_overlimit    in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , i_switch_limit       in      com_api_type_pkg.t_boolean          default com_api_const_pkg.TRUE
  , i_source_entity_type in      com_api_type_pkg.t_dict_value       default null
  , i_source_object_id   in      com_api_type_pkg.t_long_id          default null
  , i_service_id         in      com_api_type_pkg.t_short_id         default null
  , i_test_mode          in      com_api_type_pkg.t_dict_value       default fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
  , o_overlimit             out  com_api_type_pkg.t_boolean
) is
begin
    switch_limit_counter(
        i_limit_type          => i_limit_type
      , i_product_id          => i_product_id
      , i_entity_type         => i_entity_type
      , i_object_id           => i_object_id
      , i_param_map           => i_param_map
      , i_count_value         => i_count_value
      , i_sum_value           => i_sum_value
      , i_currency            => i_currency
      , i_eff_date            => i_eff_date
      , i_split_hash          => i_split_hash
      , i_inst_id             => i_inst_id
      , i_check_overlimit     => i_check_overlimit
      , i_switch_limit        => i_switch_limit
      , i_source_entity_type  => i_source_entity_type
      , i_source_object_id    => i_source_object_id
      , i_service_id          => i_service_id
      , i_test_mode           => i_test_mode
    );
    o_overlimit := com_api_type_pkg.FALSE;
exception
    when com_api_error_pkg.e_application_error then
        if com_api_error_pkg.get_last_error in ('OVERLIMIT') then
            o_overlimit := com_api_type_pkg.TRUE;
        else
            raise;
        end if;
end;

function get_limit_id(
    i_entity_type        in      com_api_type_pkg.t_dict_value
  , i_object_id          in      com_api_type_pkg.t_long_id
  , i_limit_type         in      com_api_type_pkg.t_dict_value
  , i_inst_id            in      com_api_type_pkg.t_inst_id          default null
  , i_split_hash         in      com_api_type_pkg.t_tiny_id          default null
) return com_api_type_pkg.t_long_id is
    l_limit_id          com_api_type_pkg.t_long_id;
    l_product_id        com_api_type_pkg.t_short_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_split_hash        com_api_type_pkg.t_tiny_id;
begin
    
    rul_api_shared_data_pkg.load_params(
        i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , io_params      => l_param_tab
      , i_full_set     => com_api_const_pkg.TRUE
    );
        
    l_product_id := prd_api_product_pkg.get_product_id(
        i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
    );      

    l_limit_id :=
        prd_api_product_pkg.get_limit_id (
            i_product_id    => l_product_id
          , i_entity_type   => i_entity_type
          , i_object_id     => i_object_id
          , i_limit_type    => i_limit_type
          , i_params        => l_param_tab
          , i_split_hash    => l_split_hash
          , i_service_id    => null
          , i_eff_date      => null
          , i_inst_id       => i_inst_id   
        );
        
    return l_limit_id;    
end;

procedure get_limit_counters(
    i_entity_type        in      com_api_type_pkg.t_dict_value
  , i_object_id          in      com_api_type_pkg.t_long_id
  , i_inst_id            in      com_api_type_pkg.t_inst_id          default null
  , i_split_hash         in      com_api_type_pkg.t_tiny_id          default null
  , o_ref_cursor         out     sys_refcursor  
) is
    l_eff_date           date;
    l_split_hash         com_api_type_pkg.t_tiny_id;
    l_inst_id            com_api_type_pkg.t_inst_id;
    l_product_id         com_api_type_pkg.t_short_id;
    
begin
    l_eff_date := com_api_sttl_day_pkg.get_sysdate;          
    
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;
    
    if i_inst_id is null then
        l_inst_id := ost_api_institution_pkg.get_object_inst_id(i_entity_type, i_object_id);
    else
        l_inst_id := i_inst_id;
    end if;
    
    l_product_id := prd_api_product_pkg.get_product_id(
        i_entity_type    => i_entity_type
      , i_object_id      => i_object_id
      , i_eff_date       => l_eff_date
      , i_inst_id        => l_inst_id
    );
    
    open o_ref_cursor for
        select c.id
             , c.entity_type
             , c.object_id
             , c.limit_type
             , fcl_api_limit_pkg.get_limit_count_curr(c.limit_type, c.entity_type, c.object_id, l.id) count_value
             , fcl_api_limit_pkg.get_limit_sum_curr(c.limit_type, c.entity_type, c.object_id, l.id) sum_value
             , case when b.next_date > l_eff_date or b.next_date is null then c.prev_count_value else c.count_value end prev_count_value
             , case when b.next_date > l_eff_date or b.next_date is null then c.prev_sum_value else c.sum_value end prev_sum_value
             , case when b.next_date > l_eff_date or b.next_date is null then c.last_reset_date else b.next_date end last_reset_date
             , c.split_hash
             , c.inst_id
             , case
                   when l.limit_base is not null
                        and l.limit_rate is not null
                   then fcl_api_limit_pkg.get_limit_border_sum(
                            i_entity_type  => c.entity_type
                          , i_object_id    => c.object_id
                          , i_limit_type   => c.limit_type
                          , i_limit_base   => l.limit_base
                          , i_limit_rate   => l.limit_rate
                          , i_currency     => l.currency
                          , i_inst_id      => c.inst_id
                          , i_product_id   => prd_api_product_pkg.get_product_id(
                                                  i_entity_type  => c.entity_type
                                                , i_object_id    => c.object_id
                                                , i_inst_id      => c.inst_id
                                              )
                          , i_split_hash   => c.split_hash
                          , i_mask_error   => com_api_const_pkg.TRUE
                        )
                   else l.sum_limit
               end as sum_limit
             , l.currency limit_currency
             , case
                   when l.limit_base is not null
                        and l.limit_rate is not null
                   then fcl_api_limit_pkg.get_limit_border_count(
                            i_entity_type  => c.entity_type
                          , i_object_id    => c.object_id
                          , i_limit_type   => c.limit_type
                          , i_limit_base   => l.limit_base
                          , i_limit_rate   => l.limit_rate
                          , i_currency     => l.currency
                          , i_inst_id      => c.inst_id
                          , i_product_id   => prd_api_product_pkg.get_product_id(
                                                  i_entity_type  => c.entity_type
                                                , i_object_id    => c.object_id
                                                , i_inst_id      => c.inst_id
                                              )
                          , i_split_hash   => c.split_hash
                          , i_mask_error   => com_api_const_pkg.TRUE
                        )
                   else l.count_limit
               end as count_limit
             , case when b.next_date > l_eff_date or b.next_date is null then b.next_date
                    else fcl_api_cycle_pkg.calc_next_date(b.cycle_type, c.entity_type, c.object_id, c.split_hash, l_eff_date)
               end next_date
             , b.cycle_type
             , com_api_i18n_pkg.get_text('prd_attribute', 'label', t.attr_id) as short_name
             , t.start_date
             , t.end_date
             , t.attr_id
             , service_id
          from (
             select s.*    
                  , row_number() over (partition by limit_type order by decode(level_priority, 0, 0, 1), level_priority , start_date desc , register_timestamp desc) rn
               from (                
                    select limit_id
                         , level_priority
                         , data_type
                         , attr_entity_type
                         , d.start_date
                         , d.end_date
                         , attr_id
                         , limit_type
                         , register_timestamp
                         , d.service_id
                         , d.entity_type
                         , d.object_id
                      from (
                            select v.attr_value limit_id
                                 , 0 level_priority
                                 , a.data_type
                                 , a.entity_type attr_entity_type
                                 , v.register_timestamp
                                 , v.start_date
                                 , v.end_date
                                 , a.id attr_id
                                 , a.object_type limit_type
                                 , v.service_id
                                 , i_entity_type entity_type
                                 , i_object_id object_id
                              from prd_attribute_value v
                                 , prd_attribute a
                             where v.entity_type  = i_entity_type
                               and v.object_id    = i_object_id
                               and v.split_hash   = l_split_hash
                               and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                               and a.id           = v.attr_id
                               and v.mod_id       is null
                               and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
                            union all
                            select to_char(f.limit_id, 'FM000000000000000000.0000') limit_id
                                 , 0 level_priority
                                 , a.data_type
                                 , a.entity_type        attr_entity_type
                                 , v.register_timestamp
                                 , v.start_date
                                 , v.end_date
                                 , a.id attr_id
                                 , t.limit_type
                                 , v.service_id
                                 , i_entity_type        entity_type
                                 , i_object_id          object_id
                              from prd_attribute_value  v
                                 , prd_attribute        a
                                 , fcl_fee_type         t
                                 , fcl_fee              f
                             where v.entity_type    = i_entity_type
                               and v.object_id      = i_object_id
                               and v.split_hash     = l_split_hash
                               and a.entity_type    = fcl_api_const_pkg.ENTITY_TYPE_FEE
                               and a.id             = v.attr_id
                               and a.object_type    = t.fee_type
                               and f.id             = com_api_type_pkg.get_number_value(
                                                          i_data_type => com_api_const_pkg.DATA_TYPE_NUMBER
                                                        , i_value     => v.attr_value
                                                      )
                               and t.limit_type    is not null                               
                               and v.mod_id        is null
                               and l_eff_date between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
                            union all
                            select v.attr_value         limit_id
                                 , p.level_priority
                                 , a.data_type
                                 , a.entity_type        attr_entity_type
                                 , v.register_timestamp
                                 , v.start_date
                                 , v.end_date
                                 , a.id attr_id
                                 , a.object_type        limit_type
                                 , s.id service_id
                                 , i_entity_type        entity_type
                                 , i_object_id          object_id
                              from (
                                    select connect_by_root id product_id
                                         , level level_priority
                                         , id parent_id
                                         , product_type
                                         , case when parent_id is null then 1 else 0 end top_flag
                                      from prd_product
                                     connect by prior parent_id = id
                                       start with id = l_product_id
                                   ) p
                                 , prd_attribute_value v
                                 , prd_attribute a
                                 , prd_service s
                                 , prd_product_service ps
                             where ps.product_id     = p.product_id
                               and ps.service_id     = s.id
                               and v.service_id      = s.id
                               and a.service_type_id = s.service_type_id
                               and v.object_id       = decode(a.definition_level, prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_SERVICE, s.id, p.parent_id)
                               and v.entity_type     = decode(a.definition_level
                                                               , prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_SERVICE, decode(top_flag, 1, prd_api_const_pkg.ENTITY_TYPE_SERVICE, '-')
                                                               , prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                                                       )
                               and v.attr_id         = a.id
                               and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                               and v.mod_id         is null
                               and l_eff_date  between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
                            union all
                            select to_char(f.limit_id, 'FM000000000000000000.0000') limit_id
                                 , p.level_priority
                                 , a.data_type
                                 , a.entity_type        attr_entity_type
                                 , v.register_timestamp
                                 , v.start_date
                                 , v.end_date
                                 , a.id attr_id
                                 , t.limit_type
                                 , s.id service_id
                                 , i_entity_type        entity_type
                                 , i_object_id          object_id
                              from (
                                    select connect_by_root id product_id
                                         , level level_priority
                                         , id parent_id
                                         , product_type
                                         , case when parent_id is null then 1 else 0 end top_flag
                                      from prd_product
                                     connect by prior parent_id = id
                                       start with id = l_product_id
                                   ) p
                                 , prd_attribute_value  v
                                 , prd_attribute        a
                                 , prd_service          s
                                 , prd_product_service  ps
                                 , fcl_fee_type         t
                                 , fcl_fee              f
                             where ps.product_id     = p.product_id
                               and ps.service_id     = s.id
                               and v.service_id      = s.id
                               and a.service_type_id = s.service_type_id
                               and v.object_id       = decode(a.definition_level, prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_SERVICE, s.id, p.parent_id)
                               and v.entity_type     = decode(a.definition_level
                                                               , prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_SERVICE, decode(top_flag, 1, prd_api_const_pkg.ENTITY_TYPE_SERVICE, '-')
                                                               , prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                                                       )
                               and v.attr_id         = a.id
                               and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_FEE
                               and a.object_type     = t.fee_type
                               and f.id              = com_api_type_pkg.get_number_value(
                                                           i_data_type => com_api_const_pkg.DATA_TYPE_NUMBER
                                                         , i_value     => v.attr_value
                                                       )
                               and t.limit_type     is not null
                               and v.mod_id         is null
                               and l_eff_date  between nvl(v.start_date, l_eff_date) and nvl(v.end_date, trunc(l_eff_date)+1)
                           ) d
                           , prd_service_object o
                       where d.entity_type = o.entity_type
                         and d.object_id   = o.object_id  
                         and d.service_id  = o.service_id
                         and l_eff_date between nvl(o.start_date, l_eff_date) and nvl(o.end_date, trunc(l_eff_date)+1)
                    ) s
                ) t
                , fcl_limit_counter c
                , fcl_limit l
                , fcl_limit_type p
                , fcl_cycle_counter b
            where c.limit_type     = t.limit_type
              and c.entity_type    = i_entity_type
              and c.object_id      = i_object_id
              and c.inst_id        = l_inst_id
              and c.split_hash     = l_split_hash
              and l.id             = com_api_type_pkg.get_number_value(
                                         i_data_type => com_api_const_pkg.DATA_TYPE_NUMBER
                                       , i_value     => t.limit_id
                                     )
              and p.limit_type     = t.limit_type
              and p.cycle_type     = b.cycle_type(+)
              and b.entity_type(+) = i_entity_type
              and b.object_id(+)   = i_object_id
              and t.rn = 1;
end;

-- Define instance's type for correct generating numeric dictionary articles
begin
    select substr(to_char(min_value), 1, 1)
      into g_instance_type
      from user_sequences
     where sequence_name = 'FCL_LIMIT_TYPE_SEQ';

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '~initialization: g_instance_type [#1]'
      , i_env_param1 => g_instance_type
    );
exception
    when no_data_found then
        g_instance_type := utl_deploy_pkg.INSTANCE_TYPE_CUSTOM1;
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT)
                         || '~initialization: g_instance_type [#1] BY DEFAULT'
          , i_env_param1 => g_instance_type
        );
end;
/
