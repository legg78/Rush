create or replace package body pmo_ui_order_search_pkg is

procedure get_ref_cur_base(
    o_ref_cur               out   com_api_type_pkg.t_ref_cur
  , io_row_count         in out   com_api_type_pkg.t_long_id
  , i_first_row          in       com_api_type_pkg.t_long_id
  , i_last_row           in       com_api_type_pkg.t_long_id
  , i_tab_name           in       com_api_type_pkg.t_name
  , i_param_tab          in       com_param_map_tpt
  , i_sorting_tab        in       com_param_map_tpt
  , i_is_first_call      in       com_api_type_pkg.t_boolean
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name     := lower($$PLSQL_UNIT) || '.get_ref_cur_base';

    l_param_tab                   com_param_map_tpt           := i_param_tab;
    l_inst_id                     com_api_type_pkg.t_inst_id;
    l_order_date_from             date;
    l_order_date_to               date;
    l_customer_id                 com_api_type_pkg.t_medium_id;
    l_entity_type                 com_api_type_pkg.t_dict_value;
    l_object_id                   com_api_type_pkg.t_long_id;
    l_status                      com_api_type_pkg.t_dict_value;
    l_purpose_id                  com_api_type_pkg.t_long_id;
    l_param_id                    com_api_type_pkg.t_long_id;
    l_param_value                 com_api_type_pkg.t_full_desc;
    l_order_id                    com_api_type_pkg.t_long_id;

    l_order_by                    com_api_type_pkg.t_name;
    l_user_id                     com_api_type_pkg.t_short_id;

    l_lang                        com_api_type_pkg.t_dict_value;

    COLUMN_LIST          constant com_api_type_pkg.t_text :=
        q'!select o.id                      as order_id
                , o.event_date              as order_date
                , o.entity_type
                , o.object_id
                , com_api_object_pkg.get_object_number(i_entity_type => o.entity_type
                                                     , i_object_id   => o.object_id
                                                     , i_mask_error  => 1)
                                            as object_number
                , com_api_object_pkg.get_object_number(i_entity_type => 'ENTTCUST'
                                                     , i_object_id   => o.customer_id
                                                     , i_mask_error  => 1)
                                            as customer_number
                , o.status
                , o.purpose_id
                , o.amount
                , o.currency
                , o.payment_order_number
                , o.inst_id
                , ost_ui_institution_pkg.get_inst_name(o.inst_id)
                                            as inst
                , o.resp_code
                , o.resp_amount
                , o.expiration_date
                , o.attempt_count
                , o.template_id
                , get_text ('pmo_service', 'label', p.service_id, x.p_lang)
                      || ' - '
                      || get_text ('pmo_provider', 'label', p.provider_id, x.p_lang)
                                            as purpose_label
                , x.p_lang                  as lang!'
    ;

    l_query                       com_api_type_pkg.t_text :=
         q'!, (select :p_inst_id            p_inst_id
                    , :p_lang               p_lang
                    , :p_order_date_from    p_order_date_from
                    , :p_order_date_to      p_order_date_to
                    , :p_customer_id        p_customer_id
                    , :p_entity_type        p_entity_type
                    , :p_object_id          p_object_id
                    , :p_status             p_status
                    , :p_purpose            p_purpose_id
                    , :p_param_id           p_param_id
                    , :p_param_value        p_param_value
                    , :p_user_id            p_user_id
                    , :p_order_id           p_order_id
                    , get_sysdate           p_sysdate
                 from dual
               ) x
               , pmo_purpose      p
          !';
    l_where                        com_api_type_pkg.t_text :=
          q'! where o.inst_id in
                        (select ui.inst_id from acm_user_inst_mvw ui where ui.user_id = x.p_user_id)
                and o.purpose_id         = p.id (+)
            !';

    l_subquery                    com_api_type_pkg.t_text := ' from pmo_order o';

begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ': START with i_tab_name [' || i_tab_name || '], i_is_first_call [' || i_is_first_call || ']'
    );

    utl_data_pkg.print_table(
        i_param_tab => i_param_tab   -- dumping collection, DEBUG logging level is required
    );

    if i_tab_name != 'PMO_ORDER' then
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_TAB_NAME'
          , i_env_param1 => i_tab_name
        );
    end if;

    l_lang := nvl(com_ui_object_search_pkg.get_char_value(l_param_tab, 'LANG'), com_api_const_pkg.DEFAULT_LANGUAGE);
    trc_log_pkg.debug(
        'l_lang=' || l_lang
    );

    -- Use table's column instead of calculated column in "Order by" clause
    if i_sorting_tab is not null then
        if com_ui_object_search_pkg.is_used_sorting(
               i_is_first_call => i_is_first_call
             , i_sorting_count => i_sorting_tab.count
             , i_row_count     => io_row_count
             , i_mask_error    => com_api_type_pkg.FALSE
           ) = com_api_type_pkg.TRUE
        then
            trc_log_pkg.debug(LOG_PREFIX || 'Sorting by:');
            utl_data_pkg.print_table(i_param_tab => i_sorting_tab);

            if i_sorting_tab.count > 0 then
                for i in 1 .. i_sorting_tab.count loop
                    l_order_by := l_order_by
                                  || case
                                         when l_order_by is not null
                                         then ','
                                         else 'order by '
                                     end
                                  || upper(i_sorting_tab(i).name)
                                  || ' '
                                  || i_sorting_tab(i).char_value;
                end loop;
            end if;

            trc_log_pkg.debug(LOG_PREFIX || 'l_order_by: ' || l_order_by);
        end if;
    end if;

    l_user_id                      := com_ui_user_env_pkg.get_user_id;
    l_inst_id                      := com_ui_object_search_pkg.get_number_value(l_param_tab, 'INST_ID');

    l_where                        := l_where || ' and (o.inst_id = x.p_inst_id or x.p_inst_id = 9999)';

    l_order_date_from          := com_ui_object_search_pkg.get_date_value(l_param_tab,    'ORDER_DATE_FROM');
    l_order_date_to            := com_ui_object_search_pkg.get_date_value(l_param_tab,    'ORDER_DATE_TO');
    l_customer_id              := com_ui_object_search_pkg.get_number_value(l_param_tab,  'CUSTOMER_ID');
    l_entity_type              := com_ui_object_search_pkg.get_char_value(l_param_tab,    'ENTITY_TYPE');
    l_object_id                := com_ui_object_search_pkg.get_number_value(l_param_tab,  'OBJECT_ID');
    l_status                   := com_ui_object_search_pkg.get_char_value(l_param_tab,    'STATUS');
    l_purpose_id               := com_ui_object_search_pkg.get_number_value(l_param_tab,  'PURPOSE_ID');
    l_param_id                 := com_ui_object_search_pkg.get_number_value(l_param_tab,  'PARAM_ID');
    l_param_value              := com_ui_object_search_pkg.get_char_value(l_param_tab,    'PARAM_VALUE');
    l_order_id                 := com_ui_object_search_pkg.get_number_value(l_param_tab,  'ORDER_ID');

    trc_log_pkg.debug(
        i_text        => 'entity_type [#1], object_id [#2], inst_id [#3], param_id [#4], param_value [#5], status [#6]'
      , i_env_param1  => l_entity_type
      , i_env_param2  => l_object_id
      , i_env_param3  => l_inst_id
      , i_env_param4  => l_param_id
      , i_env_param5  => l_param_value
      , i_env_param6  => l_status
    );

    if l_order_date_from is not null
        and l_order_date_to is not null
        and l_order_date_from > l_order_date_to
    then
        com_api_error_pkg.raise_error(
            i_error      => 'INCONSISTENT_DATE'
          , i_env_param1 => to_char(l_order_date_from, 'dd.mm.yyyy hh24:mi:ss')
          , i_env_param2 => to_char(l_order_date_to,   'dd.mm.yyyy hh24:mi:ss')
        );
    end if;

    if l_order_id is not null then
        l_where := l_where ||
            q'! and o.id = p_order_id
              !';
    end if;

    if l_order_date_from is not null then
        l_where := l_where || 
            q'! and o.event_date >= p_order_date_from
              !';
    end if;

    if l_order_date_to is not null then
        l_where := l_where ||
            q'! and (o.event_date <= p_order_date_to or p_order_date_to is null)
              !';
    end if;

    if l_customer_id is not null then
        l_where := l_where ||
            q'! and o.customer_id = p_customer_id
              !';
    end if;

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        if l_object_id is not null then
            l_subquery :=
                q'! from (select d.*, d.object_id account_id from pmo_order d where d.entity_type = 'ENTTACCT'
                   union all
                  select r.*, e.account_id from pmo_order r, acc_entry e where r.entity_type = 'ENTTENTR' and r.object_id = e.id) o
                  !';

    end if;

    l_where := l_where ||
        q'! and o.account_id = p_object_id
          !';

    else
        if l_entity_type is not null then
        l_where := l_where ||
            q'! and o.entity_type = p_entity_type
              !';
    end if;
        if l_object_id is not null then
            l_where := l_where ||
                q'! and o.object_id   = p_object_id
                  !';
        end if;
    end if;

    l_query     := l_subquery || l_query;

    if l_status is not null then
        l_where := l_where || ' and o.status = p_status ';
    end if;

    if l_purpose_id is not null then
        l_where := l_where || ' and o.purpose_id = p_purpose_id ';
    end if;

    if l_param_id is not null then
        l_query := l_query ||
        q'!, pmo_order_data   pd
          !';

        l_where := l_where ||
        q'! and o.id                 = pd.order_id
            and pd.param_id          = p_param_id
          !';

        if l_param_value is not null then
            l_where := l_where ||
            q'! and upper(pd.param_value) like p_param_value
              !';
        else
            l_where := l_where ||
            q'! and pd.param_value        is null
              !';
        end if;
    end if;

    -- attach where clause
    l_query := l_query || l_where;

    com_ui_object_search_pkg.start_search(
        i_is_first_call => i_is_first_call
    );

    if i_is_first_call = com_api_const_pkg.TRUE then
        l_query := 'select count(*) '|| l_query;

        execute immediate l_query
        into io_row_count
        using
            l_inst_id
          , l_lang
          , l_order_date_from
          , l_order_date_to
          , l_customer_id
          , l_entity_type
          , l_object_id
          , l_status
          , l_purpose_id
          , l_param_id
          , l_param_value
          , l_user_id
          , l_order_id;

    else
        l_query := 'select t.*'
                    || ' from (select a.*, rownum rn from (select * from ('
                    || COLUMN_LIST || l_query || ') ' || l_order_by
                    || ') a) t where rn between :p_first_row and :p_last_row';

        open o_ref_cur for l_query
        using
            l_inst_id
          , l_lang
          , l_order_date_from
          , l_order_date_to
          , l_customer_id
          , l_entity_type
          , l_object_id
          , l_status
          , l_purpose_id
          , l_param_id
          , l_param_value
          , l_user_id
          , l_order_id
          , i_first_row
          , i_last_row;
    end if;

    com_ui_object_search_pkg.finish_search(
        i_is_first_call => i_is_first_call
      , i_row_count     => io_row_count
      , i_sql_statement => l_query
    );

exception
    when others then
        com_ui_object_search_pkg.finish_search(
            i_is_first_call => i_is_first_call
          , i_row_count     => io_row_count
          , i_sql_statement => l_query
          , i_is_failed     => com_api_type_pkg.TRUE
          , i_sqlerrm_text  => SQLERRM
        );
        raise;
end get_ref_cur_base;

procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_row_count         in      com_api_type_pkg.t_long_id    default null
  , i_first_row         in      com_api_type_pkg.t_long_id
  , i_last_row          in      com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt             default null
) is
    l_row_count         com_api_type_pkg.t_long_id := i_row_count;
begin
    get_ref_cur_base(
        o_ref_cur           => o_ref_cur
      , io_row_count        => l_row_count
      , i_first_row         => i_first_row
      , i_last_row          => i_last_row
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => i_sorting_tab
      , i_is_first_call     => com_api_const_pkg.FALSE
    );
end get_ref_cur;

procedure get_row_count(
    o_row_count            out  com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
) is
    l_ref_cur           com_api_type_pkg.t_ref_cur;
    l_sorting_tab       com_param_map_tpt;
begin
    get_ref_cur_base(
        o_ref_cur           => l_ref_cur
      , io_row_count        => o_row_count
      , i_first_row         => null
      , i_last_row          => null
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => l_sorting_tab
      , i_is_first_call     => com_api_const_pkg.TRUE
    );
end get_row_count;

end pmo_ui_order_search_pkg;
/
