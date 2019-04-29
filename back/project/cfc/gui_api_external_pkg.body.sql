create or replace package body gui_api_external_pkg as
/**********************************************************
 * API for external GUI <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 17.02.2017 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: GUI_API_EXTERNAL_PKG
 * @headcom
 **********************************************************/
g_flexible_fields_instant  gui_api_type_pkg.flexible_fields_entity_tbl;

g_current_index            com_api_type_pkg.t_short_id;

procedure get_dict_articles_code(
    i_dict_code          in    com_api_type_pkg.t_dict_value
  , i_where_additional   in    com_api_type_pkg.t_full_desc    default null
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_dict_articles_code: ';

    l_lang             com_api_type_pkg.t_dict_value := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

    l_cursor_count     com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column    com_api_type_pkg.t_name := 'select c.dict||c.code as code'
                                               ||      ', com_api_dictionary_pkg.get_article_text('
                                               ||            'i_article => c.dict||c.code'
                                               ||          ', i_lang    => ''' || l_lang || ''''
                                               ||      ') as code_description '
    ;
    l_cursor_tbl       com_api_type_pkg.t_name := 'from com_dictionary c '
                                               ||'where c.dict = :i_dict_code '
    ;
    l_cursor_order     com_api_type_pkg.t_name := 'order by '
                                               ||       'c.dict'
                                               ||     ', c.code'
    ;
    l_cursor_where     com_api_type_pkg.t_text;
    l_cursor_str       com_api_type_pkg.t_text;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - i_dict_code [' || i_dict_code
               || '], i_where_additional [' || i_where_additional
               || '], l_lang [' || l_lang
               || ']'
    );

    if i_where_additional is not null then

        l_cursor_where := 'and ' || i_where_additional || ' ';

    end if;

    l_cursor_str := l_cursor_count || l_cursor_tbl || l_cursor_where;
    execute immediate l_cursor_str
                 into o_row_count
                using
                   in i_dict_code
    ;

    if o_row_count = 0 then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished - required dictionary articles not found'
        );

    else

        l_cursor_str := l_cursor_column || l_cursor_tbl || l_cursor_where || l_cursor_order;

        open  o_ref_cursor
          for l_cursor_str
        using i_dict_code
        ;

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished success!'
        );

    end if;

end get_dict_articles_code;

procedure get_dict_identity_types(
    i_owner_entity_type  in    com_api_type_pkg.t_dict_value   default com_api_const_pkg.ENTITY_TYPE_PERSON
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_dict_identity_types: ';

    l_where_additional com_api_type_pkg.t_full_desc := 'dict||code in (select it.id_type '
                                                    ||                  'from com_id_type it '
                                                    ||                 'where it.entity_type = ''' || i_owner_entity_type || ''''
                                                    ||               ')'
    ;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - i_owner_entity_type [' || i_owner_entity_type
               || '], l_where_additional [' || l_where_additional
               || ']'
    );

    if i_owner_entity_type is null then

        com_api_error_pkg.raise_error(
            i_error      => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
          , i_env_param1 => 'i_owner_entity_type'
        );

    end if;

    get_dict_articles_code(
        i_dict_code        => com_api_const_pkg.ID_TYPE_DICTIONARY
      , i_where_additional => l_where_additional
      , o_row_count        => o_row_count
      , o_ref_cursor       => o_ref_cursor
    );

    if o_row_count = 0 then

        com_api_error_pkg.raise_error(
            i_error      => 'DICTIONARY_NOT_FOUND_FOR_ENTITY'
          , i_env_param1 => com_api_const_pkg.ID_TYPE_DICTIONARY
          , i_env_param2 => i_owner_entity_type
        );

    end if;

exception
    when others then

        if o_ref_cursor%isopen then
            close o_ref_cursor;
        end if;

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished failed with params - i_owner_entity_type [' || i_owner_entity_type
                   || '], l_where_additional [' || l_where_additional
                   || ']'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_dict_identity_types;

procedure get_customer_list(
    i_customer_number    in    com_api_type_pkg.t_name         default null
  , i_customer_name      in    com_api_type_pkg.t_name         default null
  , i_customer_mobile    in    com_api_type_pkg.t_name         default null
  , i_identity_type      in    com_api_type_pkg.t_dict_value   default null
  , i_identity_series    in    com_api_type_pkg.t_name         default null
  , i_identity_number    in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_customer_list: ';

    l_lang             com_api_type_pkg.t_dict_value := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

    l_cursor_count     com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column    com_api_type_pkg.t_name := 'select c.customer_id'
                                               ||      ', c.customer_number'
                                               ||      ', c.customer_name '
    ;
    l_cursor_tbl       com_api_type_pkg.t_text := 'from ('
                                               ||       'select id as customer_id'
                                               ||            ', customer_number'
                                               ||            ', com_ui_object_pkg.get_object_desc(entity_type, object_id, ''' || l_lang || ''') as customer_name'
                                               ||            ', object_id '
                                               ||         'from prd_customer '
                                               ||      ') c'
                                               ||    ', (select row_number() over(partition by i.object_id order by i.id desc) as rng'
                                               ||            ', i.object_id'
                                               ||            ', i.id_type'
                                               ||            ', i.id_series'
                                               ||            ', i.id_number'
                                               ||            ', com_api_dictionary_pkg.get_article_text(i.id_type, ''' || l_lang || ''') as id_name'
                                               ||            ', i.id_series||i.id_number as id_document '
                                               ||         'from com_id_object i '
                                               ||      ') i'
                                               ||    ', (select c.object_id as customer_id'
                                               ||            ', c.contact_id'
                                               ||            ', d.commun_method'
                                               ||            ', row_number() over(partition by c.object_id order by d.end_date desc nulls first, c.id desc) as rng '
                                               ||         'from com_contact_object c'
                                               ||            ', com_contact_data d '
                                               ||        'where c.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                                               ||          'and d.contact_id = c.contact_id '
                                               ||          'and d.commun_method = ''' || com_api_const_pkg.COMMUNICATION_METHOD_MOBILE || ''''
                                               ||      ') mt '
                                               ||'where c.object_id = i.object_id (+) '
                                               ||  'and 1 = i.rng (+) '
                                               ||  'and c.customer_id = mt.customer_id (+) '
                                               ||  'and 1 = mt.rng (+) '
    ;
    l_cursor_order     com_api_type_pkg.t_name := 'order by c.customer_number'
    ;
    l_cursor_where     com_api_type_pkg.t_text;
    l_cursor_str       com_api_type_pkg.t_text;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - i_customer_number [' || i_customer_number
               || '], i_customer_name [' || i_customer_name
               || '], i_customer_mobile [' || i_customer_mobile
               || '], i_identity_type [' || i_identity_type
               || '], i_identity_series [' || i_identity_series
               || '], i_identity_number [' || i_identity_number
               || '], i_mask_error [' || i_mask_error
               || '], l_lang [' || l_lang
               || ']'
    );

    if i_customer_number is not null then

        l_cursor_where := 'and c.customer_number = ''' || i_customer_number ||''' ';

    end if;

    if i_customer_name is not null then

        l_cursor_where := l_cursor_where || 'and lower(c.customer_name) like ''' || lower(replace(i_customer_name, '*', '%')) || ''' ';

    end if;

    if i_customer_mobile is not null then

        l_cursor_where := l_cursor_where || 'and com_api_contact_pkg.get_contact_string(mt.contact_id, mt.commun_method, get_sysdate) = ''' || i_customer_mobile || ''' ';

    end if;

    if i_identity_type is not null then

        l_cursor_where := l_cursor_where || 'and i.id_type = ''' || i_identity_type || ''' ';

    end if;

    if i_identity_series is not null then

        l_cursor_where := l_cursor_where || 'and i.id_series = ''' || i_identity_series || ''' ';

    end if;

    if i_identity_number is not null then

        l_cursor_where := l_cursor_where || 'and i.id_number = ''' || i_identity_number || ''' ';

    end if;

    if l_cursor_where is null then

        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_CUSTOMER_SEARCH_PARAMS'
          , i_env_param1 => null
          , i_env_param2 => i_customer_number
          , i_env_param3 => i_customer_name
        );

    end if;

    l_cursor_str := l_cursor_count || l_cursor_tbl || l_cursor_where;
    execute immediate l_cursor_str
                 into o_row_count;

    if o_row_count = 0 then

        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_CUSTOMER_SEARCH_PARAMS'
          , i_env_param1 => null
          , i_env_param2 => i_customer_number
          , i_env_param3 => i_customer_name
        );

    end if;

    l_cursor_str := l_cursor_column || l_cursor_tbl || l_cursor_where || l_cursor_order;

    open o_ref_cursor for l_cursor_str;

exception
    when others then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished failed with params - i_customer_number [' || i_customer_number
                   || '], i_customer_name [' || i_customer_name
                   || '], l_cursor_str [' || l_cursor_str
                   || ']'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_customer_list;

function get_first_customer_id(
    i_customer_number    in    com_api_type_pkg.t_name         default null
  , i_customer_name      in    com_api_type_pkg.t_name         default null
  , i_customer_mobile    in    com_api_type_pkg.t_name         default null
  , i_identity_type      in    com_api_type_pkg.t_dict_value   default null
  , i_identity_series    in    com_api_type_pkg.t_name         default null
  , i_identity_number    in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_medium_id
is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_first_customer_id: ';

    l_customer_min_data    gui_api_type_pkg.t_customer_min_data_rec;

    l_ref_cursor           com_api_type_pkg.t_ref_cur;

    l_count_cursor         com_api_type_pkg.t_long_id;



begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started'
    );

    get_customer_list(
        i_customer_number => i_customer_number
      , i_customer_name   => i_customer_name
      , i_customer_mobile => i_customer_mobile
      , i_identity_type   => i_identity_type
      , i_identity_series => i_identity_series
      , i_identity_number => i_identity_number
      , i_mask_error      => i_mask_error
      , o_row_count       => l_count_cursor
      , o_ref_cursor      => l_ref_cursor
    );

    if l_count_cursor > com_api_const_pkg.FALSE then

        if l_ref_cursor%isopen then

            loop
                fetch l_ref_cursor into l_customer_min_data;
                exit;
            end loop;
            close l_ref_cursor;

        end if;

    end if;


    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finished success'
    );

    return l_customer_min_data.customer_id;

exception
    when others then

        if l_ref_cursor%isopen then
            close l_ref_cursor;
        end if;

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_first_customer_id;

procedure get_main_customer_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id    default null
  , i_customer_number    in    com_api_type_pkg.t_name         default null
  , i_customer_name      in    com_api_type_pkg.t_name         default null
  , i_customer_mobile    in    com_api_type_pkg.t_name         default null
  , i_identity_type      in    com_api_type_pkg.t_dict_value   default null
  , i_identity_series    in    com_api_type_pkg.t_name         default null
  , i_identity_number    in    com_api_type_pkg.t_name         default null
  , i_agent_id           in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
)
is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_main_customer_info: ';

    l_lang                 com_api_type_pkg.t_dict_value := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

    l_cursor_count         com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column        com_api_type_pkg.t_text := 'select c.customer_id '
                                                   ||      ', c.customer_number'
                                                   ||      ', c.customer_name'
                                                   ||      ', c.entity_type as customer_type'
                                                   ||      ', c.entity_name as customer_type_name'
                                                   ||      ', case c.entity_type'
                                                   ||      '      when ''' || com_api_const_pkg.ENTITY_TYPE_COMPANY || ''''
                                                   ||      '          then'
                                                   ||      '              com_api_i18n_pkg.get_text(i_table_name    => ''com_company'','
                                                   ||      '                                        i_column_name   => ''label'','
                                                   ||      '                                        i_object_id     => c.object_id,'
                                                   ||      '                                        i_lang          => ''' || l_lang || ''')'
                                                   ||      '      else null'
                                                   ||      '  end as company_short_name'
                                                   ||      ', case c.entity_type'
                                                   ||      '      when ''' || com_api_const_pkg.ENTITY_TYPE_COMPANY || ''''
                                                   ||      '          then'
                                                   ||      '              com_api_i18n_pkg.get_text(i_table_name    => ''com_company'','
                                                   ||      '                                        i_column_name   => ''description'','
                                                   ||      '                                        i_object_id     => c.object_id,'
                                                   ||      '                                        i_lang          => ''' || l_lang || ''')'
                                                   ||      '      else null'
                                                   ||      '  end as company_full_name'
                                                   ||      ', i.id_type || '' - '' || i.id_name as document_type'
                                                   ||      ', i.id_document'
                                                   ||      ', com_api_person_pkg.get_person_age(p.birthday) as person_age'
                                                   ||      ', p.birthday'
                                                   ||      ', p.gender'
                                                   ||      ', com_api_dictionary_pkg.get_article_text(p.gender, ''' || l_lang || ''') as gender_name'
                                                   ||      ', ht.contact_id as home_phone_contact_id'
                                                   ||      ', ht.contact_type as home_phone_contact_type'
                                                   ||      ', ht.commun_method as home_phone_commun_method'
                                                   ||      ', com_api_contact_pkg.get_contact_string(ht.contact_id, ht.commun_method, get_sysdate) as home_phone'
                                                   ||      ', ha.address_id as home_address_id'
                                                   ||      ', ha.address_type as home_address_type'
                                                   ||      ', com_api_address_pkg.get_address_string(ha.address_id, ''' || l_lang || ''', null, ' || com_api_const_pkg.TRUE || ') as home_address'
                                                   ||      ', bt.contact_id as business_phone_contact_id'
                                                   ||      ', bt.contact_type as business_phone_contact_type'
                                                   ||      ', bt.commun_method as business_phone_commun_method'
                                                   ||      ', com_api_contact_pkg.get_contact_string(bt.contact_id, bt.commun_method, get_sysdate) as business_phone'
                                                   ||      ', ba.address_id as business_address_id'
                                                   ||      ', ba.address_type as business_address_type'
                                                   ||      ', com_api_address_pkg.get_address_string(ba.address_id, ''' || l_lang || ''', null, ' || com_api_const_pkg.TRUE || ') as business_address'
                                                   ||      ', mt.contact_id as mob_phone_contact_id'
                                                   ||      ', mt.contact_type as mob_phone_contact_type'
                                                   ||      ', mt.commun_method as mob_phone_commun_method'
                                                   ||      ', com_api_contact_pkg.get_contact_string(mt.contact_id, mt.commun_method, get_sysdate) as mobile_phone'
                                                   ||      ', fxt.contact_id as fax_contact_id'
                                                   ||      ', fxt.contact_type as fax_contact_type'
                                                   ||      ', fxt.commun_method as fax_commun_method'
                                                   ||      ', com_api_contact_pkg.get_contact_string(fxt.contact_id, fxt.commun_method, get_sysdate) as fax'
                                                   ||      ', em.contact_id as email_contact_id'
                                                   ||      ', em.contact_type as email_contact_type'
                                                   ||      ', em.commun_method as email_commun_method'
                                                   ||      ', com_api_contact_pkg.get_contact_string(em.contact_id, em.commun_method, get_sysdate) as email'
                                                   ||      ', pc.start_date'
                                                   ||      ', pc.end_date as termination_date'
                                                   ||      ', pc.inst_id'
                                                   ||      ', pc.agent_id '
                                                   ||      ', c.nationality as nationality_code '
                                                   ||      ', com_api_country_pkg.get_country_full_name(c.nationality) as nationality_name '
    ;
    l_cursor_flx_template  com_api_type_pkg.t_name := ', com_api_flexible_data_pkg.get_flexible_value(''#1'', ''#2'', #3) as #4';
    l_cursor_flx_column    com_api_type_pkg.t_text;
    l_cursor_tbl           com_api_type_pkg.t_text := 'from (select id as customer_id'
                                                   ||            ', customer_number'
                                                   ||            ', entity_type'
                                                   ||            ', com_api_dictionary_pkg.get_article_text(entity_type, ''' || l_lang || ''') as entity_name'
                                                   ||            ', com_ui_object_pkg.get_object_desc(entity_type, object_id, ''' || l_lang || ''') as customer_name'
                                                   ||            ', object_id '
                                                   ||            ', nationality '
                                                   ||         'from prd_customer '
                                                   ||      ') c'
                                                   ||    ', (select row_number() over(partition by i.object_id order by i.id desc) as rng'
                                                   ||            ', i.object_id'
                                                   ||            ', i.id_type'
                                                   ||            ', i.id_series'
                                                   ||            ', i.id_number'
                                                   ||            ', com_api_dictionary_pkg.get_article_text(i.id_type, ''' || l_lang || ''') as id_name'
                                                   ||            ', i.id_series||i.id_number as id_document '
                                                   ||         'from com_id_object i '
                                                   ||      ') i'
                                                   ||    ', com_person p'
                                                   ||    ', (select pc.customer_id'
                                                   ||            ', pc.inst_id'
                                                   ||            ', pc.agent_id'
                                                   ||            ', min(pc.start_date) over(partition by pc.customer_id) as start_date'
                                                   ||            ', max(pc.end_date) over(partition by pc.customer_id)   as end_date'
                                                   ||            ', row_number() over(partition by pc.customer_id, pc.inst_id, pc.agent_id order by pc.end_date desc nulls first, pc.start_date desc) as rnk '
                                                   ||         'from prd_contract pc '
                                                   ||      ') pc'
                                                   ||    ', (select c.object_id as customer_id'
                                                   ||            ', c.contact_id'
                                                   ||            ', c.contact_type'
                                                   ||            ', d.commun_method'
                                                   ||            ', row_number() over(partition by c.object_id order by d.end_date desc nulls first, decode(c.contact_type, ''' || com_api_const_pkg.CONTACT_TYPE_PRIMARY || ''', 1, 2), c.id desc) as rng '
                                                   ||         'from com_contact_object c'
                                                   ||            ', com_contact_data d '
                                                   ||        'where c.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                                                   ||          'and d.contact_id = c.contact_id '
                                                   ||          'and d.commun_method = ''' || com_api_const_pkg.COMMUNICATION_METHOD_PHONE || ''''
                                                   ||      ') ht'
                                                   ||    ', (select c.object_id as customer_id'
                                                   ||            ', c.contact_id'
                                                   ||            ', c.contact_type'
                                                   ||            ', d.commun_method'
                                                   ||            ', row_number() over(partition by c.object_id order by d.end_date desc nulls first, decode(c.contact_type, ''' || com_api_const_pkg.CONTACT_TYPE_PRIMARY || ''', 2, 1), c.id desc) as rng '
                                                   ||         'from com_contact_object c'
                                                   ||            ', com_contact_data d '
                                                   ||        'where c.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                                                   ||          'and d.contact_id = c.contact_id '
                                                   ||          'and d.commun_method = ''' || com_api_const_pkg.COMMUNICATION_METHOD_PHONE || ''''
                                                   ||      ') bt'
                                                   ||    ', (select c.object_id as customer_id'
                                                   ||            ', c.contact_id'
                                                   ||            ', c.contact_type'
                                                   ||            ', d.commun_method'
                                                   ||            ', row_number() over(partition by c.object_id order by d.end_date desc nulls first, c.id desc) as rng '
                                                   ||         'from com_contact_object c'
                                                   ||            ', com_contact_data d '
                                                   ||        'where c.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                                                   ||          'and d.contact_id = c.contact_id '
                                                   ||          'and d.commun_method = ''' || com_api_const_pkg.COMMUNICATION_METHOD_MOBILE || ''''
                                                   ||      ') mt'
                                                   ||    ', (select c.object_id as customer_id'
                                                   ||            ', c.contact_id'
                                                   ||            ', c.contact_type'
                                                   ||            ', d.commun_method'
                                                   ||            ', row_number() over(partition by c.object_id order by d.end_date desc nulls first, c.id desc) as rng '
                                                   ||         'from com_contact_object c'
                                                   ||            ', com_contact_data d '
                                                   ||        'where c.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                                                   ||          'and d.contact_id = c.contact_id '
                                                   ||          'and d.commun_method = ''' || com_api_const_pkg.COMMUNICATION_METHOD_FAX || ''''
                                                   ||      ') fxt'
                                                   ||    ', (select c.object_id as customer_id'
                                                   ||            ', c.contact_id'
                                                   ||            ', c.contact_type'
                                                   ||            ', d.commun_method'
                                                   ||            ', row_number() over(partition by c.object_id order by d.end_date desc nulls first, c.id desc) as rng '
                                                   ||         'from com_contact_object c'
                                                   ||            ', com_contact_data d '
                                                   ||        'where c.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                                                   ||          'and d.contact_id = c.contact_id '
                                                   ||          'and d.commun_method = ''' || com_api_const_pkg.COMMUNICATION_METHOD_EMAIL || ''''
                                                   ||      ') em'
                                                   ||    ', (select cao.address_id'
                                                   ||            ', cao.address_type'
                                                   ||            ', row_number() over(partition by cao.object_id order by cao.id desc) as rng'
                                                   ||            ', cao.object_id as customer_id '
                                                   ||         'from com_address_object cao '
                                                   ||        'where cao.entity_type  = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                                                   ||          'and cao.address_type = ''' || com_api_const_pkg.ADDRESS_TYPE_HOME || ''''
                                                   ||      ') ha'
                                                   ||    ', (select cao.address_id'
                                                   ||            ', cao.address_type'
                                                   ||            ', row_number() over(partition by cao.object_id order by cao.id desc) as rng'
                                                   ||            ', cao.object_id as customer_id '
                                                   ||         'from com_address_object cao '
                                                   ||        'where cao.entity_type  = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                                                   ||          'and cao.address_type = ''' || com_api_const_pkg.ADDRESS_TYPE_BUSINESS || ''''
                                                   ||      ') ba '
                                                   ||'where c.object_id = i.object_id (+) '
                                                   ||  'and 1 = i.rng (+) '
                                                   ||  'and c.object_id = p.id (+) '
                                                   ||  'and c.customer_id = pc.customer_id (+) '
                                                   ||  'and 1 = pc.rnk (+) '
                                                   ||  'and c.customer_id = ha.customer_id (+) '
                                                   ||  'and 1 = ha.rng (+) '
                                                   ||  'and c.customer_id = ba.customer_id (+) '
                                                   ||  'and 1 = ba.rng (+) '
                                                   ||  'and c.customer_id = ht.customer_id (+) '
                                                   ||  'and 1 = ht.rng (+) '
                                                   ||  'and c.customer_id = bt.customer_id (+) '
                                                   ||  'and 1 = bt.rng (+) '
                                                   ||  'and c.customer_id = mt.customer_id (+) '
                                                   ||  'and 1 = mt.rng (+) '
                                                   ||  'and c.customer_id = fxt.customer_id (+) '
                                                   ||  'and 1 = fxt.rng (+) '
                                                   ||  'and c.customer_id = em.customer_id (+) '
                                                   ||  'and 1 = em.rng (+) '
    ;
    l_cursor_order         com_api_type_pkg.t_name := 'order by c.customer_number'
    ;
    l_cursor_where         com_api_type_pkg.t_text;
    l_cursor_str           com_api_type_pkg.t_sql_statement;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - i_customer_number [' || i_customer_number
               || '], i_customer_name [' || i_customer_name
               || '], i_customer_mobile [' || i_customer_mobile
               || '], i_identity_type [' || i_identity_type
               || '], i_identity_series [' || i_identity_series
               || '], i_identity_number [' || i_identity_number
               || '], i_agent_id ['        || i_agent_id
               || '], i_mask_error [' || i_mask_error
               || '], l_lang [' || l_lang
               || ']'
    );

    if i_customer_id is not null then

        l_cursor_where := 'and c.customer_id = ' || i_customer_id || ' ';

    end if;

    if i_customer_number is not null then

        l_cursor_where := 'and c.customer_number = ''' || i_customer_number || ''' ';

    end if;

    if i_customer_name is not null then

       l_cursor_where := l_cursor_where || 'and lower(c.customer_name) like ''' || lower(replace(i_customer_name, '*', '%')) || ''' ';

    end if;

    if i_customer_mobile is not null then

        l_cursor_where := l_cursor_where || 'and com_api_contact_pkg.get_contact_string(mt.contact_id, mt.commun_method, get_sysdate) = ''' || i_customer_mobile || ''' ';

    end if;

    if i_identity_type is not null then

        l_cursor_where := l_cursor_where || 'and i.id_type = ''' || i_identity_type || ''' ';

    end if;

    if i_identity_series is not null then

        l_cursor_where := l_cursor_where || 'and i.id_series = ''' || i_identity_series || ''' ';

    end if;

    if i_identity_number is not null then

        l_cursor_where := l_cursor_where || 'and i.id_number = ''' || i_identity_number || ''' ';

    end if;

    if i_agent_id is not null then

        l_cursor_where := l_cursor_where || 'and pc.agent_id = ' || i_agent_id || ' ';

    end if;

    l_cursor_str := l_cursor_count || l_cursor_tbl || l_cursor_where;
    execute immediate l_cursor_str
                 into o_row_count;

    if o_row_count = 0 then

        com_api_error_pkg.raise_error(
            i_error      => 'NO_CUSTOMER_DATA_REQUESTED'
          , i_env_param1 => upper(LOG_PREFIX)
          , i_env_param2 => i_customer_id
          , i_env_param3 => i_customer_number
          , i_env_param4 => i_customer_name
        );

    end if;

    if g_flexible_fields_instant.count > com_api_const_pkg.FALSE then

        for rec in (select com_api_const_pkg.ENTITY_TYPE_CUSTOMER as entity from dual
                    union all
                    select com_api_const_pkg.ENTITY_TYPE_PERSON as entity from dual
                    union all
                    select com_api_const_pkg.ENTITY_TYPE_COMPANY as entity from dual
        ) loop

            if g_flexible_fields_instant.exists(rec.entity) then

                for i in g_flexible_fields_instant(rec.entity).first .. g_flexible_fields_instant(rec.entity).last
                loop
                    l_cursor_flx_column := l_cursor_flx_column
                                        || replace(
                                               replace(
                                                   replace(
                                                       replace(
                                                           l_cursor_flx_template
                                                         , '#1'
                                                         , g_flexible_fields_instant(rec.entity)(i).field_name
                                                       )
                                                     , '#2'
                                                     , rec.entity
                                                   )
                                                 , '#3'
                                                 , case
                                                       when rec.entity = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                                           then 'c.customer_id'
                                                       when rec.entity in (com_api_const_pkg.ENTITY_TYPE_PERSON, com_api_const_pkg.ENTITY_TYPE_COMPANY)
                                                           then 'c.object_id'
                                                       else 'null'
                                                   end
                                               )
                                             , '#4'
                                             , g_flexible_fields_instant(rec.entity)(i).field_short_name
                                           )
                    ;
                end loop;

            end if;

        end loop;

        l_cursor_flx_column := l_cursor_flx_column || ' ';

    end if;

    l_cursor_str := l_cursor_column || l_cursor_flx_column || l_cursor_tbl || l_cursor_where || l_cursor_order;

    open o_ref_cursor for l_cursor_str;

exception
    when others then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_main_customer_info;

procedure get_contacts_customer_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id    default null
  , i_contact_id         in    com_api_type_pkg.t_medium_id    default null
  , i_contact_type       in    com_api_type_pkg.t_dict_value   default null
  , i_commun_method      in    com_api_type_pkg.t_dict_value   default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
)
is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_contacts_customer_info: ';

    l_lang                 com_api_type_pkg.t_dict_value := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

    l_cursor_count         com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column        com_api_type_pkg.t_text := 'select c.object_id as customer_id '
                                                   ||      ', c.contact_id'
                                                   ||      ', c.contact_type'
                                                   ||      ', com_api_dictionary_pkg.get_article_text(c.contact_type, :lang) as contact_type_name'
                                                   ||      ', d.commun_method as communication_method'
                                                   ||      ', com_api_dictionary_pkg.get_article_text(d.commun_method, :lang) as communication_method_name'
                                                   ||      ', com_api_contact_pkg.get_contact_string(c.contact_id, d.commun_method, get_sysdate) as communication_string'
                                                   ||      ', d.start_date'
                                                   ||      ', d.end_date '
    ;
    l_cursor_flx_template  com_api_type_pkg.t_name := ', com_api_flexible_data_pkg.get_flexible_value(''#1'', ''#2'', #3) as #4';
    l_cursor_flx_column    com_api_type_pkg.t_text;
    l_cursor_tbl           com_api_type_pkg.t_text := 'from com_contact_object c'
                                                   ||    ', com_contact_data d '
                                                   ||'where c.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                                                   ||  'and d.contact_id = c.contact_id '
    ;
    l_cursor_order         com_api_type_pkg.t_name := 'order by d.id'
    ;
    l_cursor_where         com_api_type_pkg.t_text;
    l_cursor_str           com_api_type_pkg.t_sql_statement;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - i_customer_id [' || i_customer_id
               || '], i_contact_id [' || i_contact_id
               || '], i_contact_type [' || i_contact_type
               || '], i_commun_method [' || i_commun_method
               || '], i_mask_error [' || i_mask_error
               || '], l_lang [' || l_lang
               || ']'
    );

    if i_customer_id is null
       and i_contact_id is null
    then

        com_api_error_pkg.raise_error(
            i_error      => 'CUSTOMER_CONTACT_NOT_FOUND'
          , i_env_param1 => i_customer_id
          , i_env_param2 => i_contact_id
          , i_env_param3 => i_contact_type
          , i_env_param4 => i_commun_method
        );

    end if;

    if i_customer_id is not null then

        l_cursor_where := 'and c.object_id = ' || i_customer_id || ' ';

    end if;

    if i_contact_id is not null then

        l_cursor_where := 'and c.contact_id = ' || i_contact_id || ' ';

    end if;

    if i_contact_type is not null then

       l_cursor_where := l_cursor_where || 'and c.contact_type = ''' || i_contact_type || ''' ';

    end if;

    if i_commun_method is not null then

        l_cursor_where := l_cursor_where || 'and d.commun_method = ''' || i_commun_method || ''' ';

    end if;

    l_cursor_str := l_cursor_count || l_cursor_tbl || l_cursor_where;
    execute immediate l_cursor_str
                 into o_row_count;

    if o_row_count = 0 then

        com_api_error_pkg.raise_error(
            i_error      => 'CUSTOMER_CONTACT_NOT_FOUND'
          , i_env_param1 => i_customer_id
          , i_env_param2 => i_contact_id
          , i_env_param3 => i_contact_type
          , i_env_param4 => i_commun_method
        );

    end if;

    if g_flexible_fields_instant.count > com_api_const_pkg.FALSE then

        for rec in (select com_api_const_pkg.ENTITY_TYPE_CONTACT as entity from dual
        ) loop

            if g_flexible_fields_instant.exists(rec.entity) then

                for i in g_flexible_fields_instant(rec.entity).first .. g_flexible_fields_instant(rec.entity).last
                loop
                    l_cursor_flx_column := l_cursor_flx_column
                                        || replace(
                                               replace(
                                                   replace(
                                                       replace(
                                                           l_cursor_flx_template
                                                         , '#1'
                                                         , g_flexible_fields_instant(rec.entity)(i).field_name
                                                       )
                                                     , '#2'
                                                     , rec.entity
                                                   )
                                                 , '#3'
                                                 , 'c.contact_id'
                                               )
                                             , '#4'
                                             , g_flexible_fields_instant(rec.entity)(i).field_short_name
                                           )
                    ;
                end loop;

            end if;

        end loop;

        l_cursor_flx_column := l_cursor_flx_column || ' ';

    end if;

    l_cursor_str := l_cursor_column || l_cursor_flx_column || l_cursor_tbl || l_cursor_where || l_cursor_order;

    open  o_ref_cursor
     for  l_cursor_str
    using l_lang
        , l_lang
    ;

exception
    when others then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_contacts_customer_info;

procedure get_addresses_customer_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id    default null
  , i_address_id         in    com_api_type_pkg.t_medium_id    default null
  , i_address_type       in    com_api_type_pkg.t_dict_value   default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_lang               in    com_api_type_pkg.t_dict_value
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
)
is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_addresses_customer_info: ';

    l_lang                 com_api_type_pkg.t_dict_value := coalesce(i_lang, get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

    l_cursor_count         com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column        com_api_type_pkg.t_text := 'select cao.object_id as customer_id '
                                                   ||      ', cao.address_id'
                                                   ||      ', cao.address_type'
                                                   ||      ', com_api_dictionary_pkg.get_article_text(cao.address_type, :lang) as address_type_name'
                                                   ||      ', com_api_address_pkg.get_address_string(cao.address_id, ''' || l_lang || ''', null, ' || com_api_const_pkg.TRUE || ') as address_string'
                                                   ||      ', cad.country as country_code'
                                                   ||      ', com_api_country_pkg.get_country_name(cad.country, ' || com_api_const_pkg.FALSE || ') as country_code_name'
                                                   ||      ', com_api_country_pkg.get_country_full_name(cad.country, :lang, ' || com_api_const_pkg.FALSE || ') as country_name'
                                                   ||      ', cad.region'
                                                   ||      ', cad.city'
                                                   ||      ', cad.street'
                                                   ||      ', cad.house'
                                                   ||      ', cad.apartment'
                                                   ||      ', cad.postal_code'
                                                   ||      ', cad.region_code'
                                                   ||      ', cad.latitude'
                                                   ||      ', cad.longitude'
                                                   ||      ', cad.inst_id'
                                                   ||      ', ost_ui_institution_pkg.get_inst_name(cad.inst_id, :lang) as inst_name'
                                                   ||      ', cad.place_code '
    ;
    l_cursor_flx_template  com_api_type_pkg.t_name := ', com_api_flexible_data_pkg.get_flexible_value(''#1'', ''#2'', #3) as #4';
    l_cursor_flx_column    com_api_type_pkg.t_text;
    l_cursor_tbl           com_api_type_pkg.t_text := 'from com_address_object cao'
                                                   ||    ', com_address cad '
                                                   ||'where cao.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''' '
                                                   ||  'and cad.id = cao.address_id '
                                                   ||  'and cad.lang = :lang '
    ;
    l_cursor_order         com_api_type_pkg.t_name := 'order by cad.id'
    ;
    l_cursor_where         com_api_type_pkg.t_text;
    l_cursor_str           com_api_type_pkg.t_sql_statement;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - i_customer_id [' || i_customer_id
               || '], i_address_id [' || i_address_id
               || '], i_address_type [' || i_address_type
               || '], i_mask_error [' || i_mask_error
               || '], l_lang [' || l_lang
               || ']'
    );

    if i_customer_id is null
       and i_address_id is null
    then

        com_api_error_pkg.raise_error(
            i_error      => 'CUSTOMER_ADDRESS_NOT_FOUND'
          , i_env_param1 => i_customer_id
          , i_env_param2 => i_address_id
          , i_env_param3 => i_address_type
        );

    end if;

    if i_customer_id is not null then

        l_cursor_where := 'and cao.object_id = ' || i_customer_id || ' ';

    end if;

    if i_address_id is not null then

        l_cursor_where := 'and cao.address_id = ' || i_address_id || ' ';

    end if;

    if i_address_type is not null then

       l_cursor_where := l_cursor_where || 'and cao.address_type = ''' || i_address_type || ''' ';

    end if;

    l_cursor_str := l_cursor_count || l_cursor_tbl || l_cursor_where;
    execute immediate l_cursor_str
                 into o_row_count
                using in l_lang;

    if o_row_count = 0 then

        com_api_error_pkg.raise_error(
            i_error      => 'CUSTOMER_ADDRESS_NOT_FOUND'
          , i_env_param1 => i_customer_id
          , i_env_param2 => i_address_id
          , i_env_param3 => i_address_type
        );

    end if;

    if g_flexible_fields_instant.count > com_api_const_pkg.FALSE then

        for rec in (select com_api_const_pkg.ENTITY_TYPE_ADDRESS as entity from dual
        ) loop

            if g_flexible_fields_instant.exists(rec.entity) then

                for i in g_flexible_fields_instant(rec.entity).first .. g_flexible_fields_instant(rec.entity).last
                loop
                    l_cursor_flx_column := l_cursor_flx_column
                                        || replace(
                                               replace(
                                                   replace(
                                                       replace(
                                                           l_cursor_flx_template
                                                         , '#1'
                                                         , g_flexible_fields_instant(rec.entity)(i).field_name
                                                       )
                                                     , '#2'
                                                     , rec.entity
                                                   )
                                                 , '#3'
                                                 , 'cao.address_id'
                                               )
                                             , '#4'
                                             , g_flexible_fields_instant(rec.entity)(i).field_short_name
                                           )
                    ;
                end loop;

            end if;

        end loop;

        l_cursor_flx_column := l_cursor_flx_column || ' ';

    end if;

    l_cursor_str := l_cursor_column || l_cursor_flx_column || l_cursor_tbl || l_cursor_where || l_cursor_order;

    open  o_ref_cursor
     for  l_cursor_str
    using l_lang
        , l_lang
        , l_lang
        , l_lang
    ;

exception
    when others then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_addresses_customer_info;

procedure get_main_billing_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_agent_id           in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
)
is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_main_billing_info: ';

    l_lang                 com_api_type_pkg.t_dict_value := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

    l_cursor_count         com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column        com_api_type_pkg.t_text := 'select row_number() over(order by a.id) as seq '
                                                   ||      ', a.id as account_id'
                                                   ||      ', a.account_type'
                                                   ||      ', a.account_type || '' - '' || com_api_dictionary_pkg.get_article_text(a.account_type, ''' || l_lang || ''') as account_type_name'
                                                   ||      ', a.status as account_status'
                                                   ||      ', com_api_dictionary_pkg.get_article_text(a.status, ''' || l_lang || ''') as account_status_name'
                                                   ||      ', ci.due_date'
                                                   ||      ', a.account_number'
                                                   ||      ', a.agent_id'
                                                   ||      ', ost_ui_agent_pkg.get_agent_name(a.agent_id, ''' || l_lang || ''') as agent_name'
                                                   ||      ', custa.address_id as customer_address_id'
                                                   ||      ', com_api_address_pkg.get_address_string(custa.address_id, ''' || l_lang || ''', null, ' || com_api_const_pkg.TRUE || ') as customer_address'
                                                   ||      ', (select distinct first_value(attr_value) over (order by start_date desc)'
                                                   ||           'from prd_attribute_value '
                                                   ||          'where attr_id = (select id '
                                                   ||                             'from prd_attribute '
                                                   ||                            'where attr_name = ''CRD_INVOICING_DELIVERY_STATEMENT_METHOD'') '
                                                   ||            'and entity_type = ''' || acc_api_const_pkg.ENTITY_TYPE_ACCOUNT || ''''
                                                   ||            'and object_id = a.id '
                                                   ||            'and start_date < get_sysdate) '
                                                   ||      '|| '' - '''
                                                   ||      '|| com_api_dictionary_pkg.get_article_text('
                                                   ||      '  (select distinct first_value(attr_value) over (order by start_date desc)'
                                                   ||           'from prd_attribute_value '
                                                   ||          'where attr_id = (select id '
                                                   ||                             'from prd_attribute '
                                                   ||                            'where attr_name = ''CRD_INVOICING_DELIVERY_STATEMENT_METHOD'') '
                                                   ||            'and entity_type = ''' || acc_api_const_pkg.ENTITY_TYPE_ACCOUNT || ''''
                                                   ||            'and object_id = a.id '
                                                   ||            'and start_date < get_sysdate) '
                                                   ||      ', ''' || l_lang || ''') as statement_delivery '
                                                   ||      ', nc.message_status || '' - '' || com_api_dictionary_pkg.get_article_text(nc.message_status, ''' || l_lang || ''') as returned_status'
                                                   ||      ', ad.reg_date'
                                                   ||      ', ad.term_date '
    ;
    l_cursor_flx_template  com_api_type_pkg.t_name := ', com_api_flexible_data_pkg.get_flexible_value(''#1'', ''#2'', #3) as #4';
    l_cursor_flx_column    com_api_type_pkg.t_text;
    l_cursor_tbl           com_api_type_pkg.t_text := 'from acc_account a'
                                                   ||    ', (select ci.account_id'
                                                   ||            ', ci.due_date'
                                                   ||            ', row_number() over(partition by ci.account_id order by ci.id desc) as rng '
                                                   ||         'from crd_invoice ci '
                                                   ||         'where ci.due_date is not null'
                                                   ||      ') ci'
                                                   ||    ', (select cao.address_id'
                                                   ||            ', row_number() over(partition by cao.object_id order by decode(cao.address_type, ''' || com_api_const_pkg.ADDRESS_TYPE_STMT_DELIVERY || ''', 0, 1), cao.id desc) as rng'
                                                   ||            ', cao.object_id as customer_id '
                                                   ||         'from com_address_object cao '
                                                   ||        'where cao.entity_type  = ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''''
                                                   ||      ') custa'
                                                   ||    ', (select nm.object_id as account_id'
                                                   ||            ', nm.channel_id'
                                                   ||            ', nm.message_status '
                                                   ||            ', row_number() over(partition by nm.object_id order by nm.id desc) as rng '
                                                   ||         'from ntf_message nm '
                                                   ||        'where nm.entity_type = ''' || acc_api_const_pkg.ENTITY_TYPE_ACCOUNT || ''''
                                                   ||      ') nc'
                                                   ||    ', (select l.object_id as account_id'
                                                   ||            ', min(case when l.event_type = ''' || acc_api_const_pkg.EVENT_ACCOUNT_CREATION || ''' then l.change_date else null end) as reg_date'
                                                   ||            ', max(case when l.event_type = ''' || acc_api_const_pkg.EVENT_ACCOUNT_CLOSING || ''' then l.change_date else null end) as term_date '
                                                   ||         'from evt_status_log l '
                                                   ||        'where l.entity_type = ''' || acc_api_const_pkg.ENTITY_TYPE_ACCOUNT || ''''
                                                   ||        'group by '
                                                   ||              'l.object_id'
                                                   ||      ') ad '
                                                   ||'where a.customer_id = :i_customer_id '
                                                   ||  'and a.id = ci.account_id (+) '
                                                   ||  'and 1 = ci.rng (+) '
                                                   ||  'and a.id = ad.account_id (+) '
                                                   ||  'and a.customer_id = custa.customer_id (+) '
                                                   ||  'and 1 = custa.rng (+) '
                                                   ||  'and a.id = nc.account_id (+) '
                                                   ||  'and 1 = nc.rng (+) '
    ;
    l_cursor_order         com_api_type_pkg.t_name := 'order by a.id'
    ;
    l_cursor_str           com_api_type_pkg.t_sql_statement;
    l_cursor_where         com_api_type_pkg.t_text;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - i_customer_id [' || i_customer_id
               || '], i_agent_id [' || i_agent_id
               || '], l_lang [' || l_lang
               || ']'
    );

    if i_agent_id is not null then

        l_cursor_where := l_cursor_where || 'and a.agent_id = ' || i_agent_id || ' ';

    end if;

    l_cursor_str := l_cursor_count || l_cursor_tbl || l_cursor_where;
    execute immediate l_cursor_str
                 into o_row_count
                using in i_customer_id;

    if o_row_count = 0 then

        com_api_error_pkg.raise_error(
            i_error      => 'NO_CUSTOMER_DATA_REQUESTED'
          , i_env_param1 => upper(LOG_PREFIX)
          , i_env_param2 => i_customer_id
        );

    end if;

    if g_flexible_fields_instant.count > com_api_const_pkg.FALSE then

        if g_flexible_fields_instant.exists(acc_api_const_pkg.ENTITY_TYPE_ACCOUNT) then

            for i in g_flexible_fields_instant(acc_api_const_pkg.ENTITY_TYPE_ACCOUNT).first .. g_flexible_fields_instant(acc_api_const_pkg.ENTITY_TYPE_ACCOUNT).last
            loop
                l_cursor_flx_column := l_cursor_flx_column
                                    || replace(
                                           replace(
                                               replace(
                                                   replace(
                                                       l_cursor_flx_template
                                                     , '#1'
                                                     , g_flexible_fields_instant(acc_api_const_pkg.ENTITY_TYPE_ACCOUNT)(i).field_name
                                                   )
                                                 , '#2'
                                                 , acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                               )
                                             , '#3'
                                             , 'a.id'
                                           )
                                         , '#4'
                                         , g_flexible_fields_instant(acc_api_const_pkg.ENTITY_TYPE_ACCOUNT)(i).field_short_name
                                       )
                ;
            end loop;

        end if;

        l_cursor_flx_column := l_cursor_flx_column || ' ';

    end if;

    l_cursor_str := l_cursor_column || l_cursor_flx_column || l_cursor_tbl || l_cursor_where || l_cursor_order;

    open  o_ref_cursor
      for l_cursor_str
    using i_customer_id
    ;

exception
    when others then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_main_billing_info;

procedure get_main_cards_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_agent_id           in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
)
is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_main_cards_info: ';

    l_lang                 com_api_type_pkg.t_dict_value := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

    l_cursor_count         com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column        com_api_type_pkg.t_text := 'select /*+ ordered  use_nl(cu ic ai nct icn pc pp ci ch ich) */ '
                                                   ||      '  dense_rank() over(order by ci.instance_id) as seq'
                                                   ||      ', com_api_i18n_pkg.get_text(''NET_NETWORK'', ''NAME'', nct.network_id, ''' || l_lang || ''') as card_network'
                                                   ||      ', com_api_i18n_pkg.get_text(''NET_CARD_TYPE'', ''NAME'', ic.card_type_id, ''' || l_lang || ''') as card_type_name'
                                                   ||      ', ic.card_mask'
                                                   ||      ', iss_api_token_pkg.decode_card_number(icn.card_number) as card_number'
                                                   ||      ', ai_credit.account_number as credit_account_number'
                                                   ||      ', ai_debit.account_number as debit_account_number'
                                                   ||      ', ai_loyalty.account_number as loyalty_account_number'
                                                   ||      ', ai_prepaid.account_number as prepaid_account_number'
                                                   ||      ', ai_credit.account_type  || '' - '' || com_api_dictionary_pkg.get_article_text(ai_credit.account_type, '''  || l_lang || ''') as credit_account_type'
                                                   ||      ', ai_debit.account_type   || '' - '' || com_api_dictionary_pkg.get_article_text(ai_debit.account_type,  '''  || l_lang || ''') as debit_account_type'
                                                   ||      ', ai_loyalty.account_type || '' - '' || com_api_dictionary_pkg.get_article_text(ai_loyalty.account_type, ''' || l_lang || ''') as loyalty_account_type'
                                                   ||      ', ai_prepaid.account_type || '' - '' || com_api_dictionary_pkg.get_article_text(ai_prepaid.account_type, ''' || l_lang || ''') as prepaid_account_type'
                                                   ||      ', pp.id as product_id'
                                                   ||      ', pp.contract_type'
                                                   ||      ', pp.contract_type || '' - '' || com_api_dictionary_pkg.get_article_text(pp.contract_type, ''' || l_lang || ''') as contract_type_name'
                                                   ||      ', pp.product_type'
                                                   ||      ', pp.product_type || '' - '' || com_api_dictionary_pkg.get_article_text(pp.product_type, ''' || l_lang || ''') as product_type_name'
                                                   ||      ', pp.product_number'
                                                   ||      ', com_api_i18n_pkg.get_text(''PRD_PRODUCT'', ''LABEL'', pp.id, ''' || l_lang || ''') as product_label'
                                                   ||      ', ci.state || '' - '' || com_api_dictionary_pkg.get_article_text(ci.state, ''' || l_lang || ''') as card_state_name'
                                                   ||      ', ic.category || '' - '' || com_api_dictionary_pkg.get_article_text(ic.category, ''' || l_lang || ''') as card_category_name'
                                                   ||      ', ci.cardholder_name as cardholder_name_instance '
                                                   ||      ', ci.iss_date'
                                                   ||      ', rtrim(ci.reissue_reason || '' - '' || com_api_dictionary_pkg.get_article_text(ci.reissue_reason, ''' || l_lang || '''), '' - '') as reissue_reason'
                                                   ||      ', ci.expir_date'
                                                   ||      ', ci.status as card_status_code'
                                                   ||      ', ci.status || '' - '' || com_api_dictionary_pkg.get_article_text(ci.status, ''' || l_lang || ''') as card_status_descr'
                                                   ||      ', decode(cu.object_id, ich.person_id, null, rtrim(ich.id_type || '' - '' || ich.id_name, '' - '')) as extend_identified_type'
                                                   ||      ', decode(cu.object_id, ich.person_id, null, ich.id_document) as extend_identified_num'
                                                   ||      ', com_api_i18n_pkg.get_text(''PRS_BLANK_TYPE'', ''NAME'', ci.blank_type_id, ''' || l_lang || ''') as blank_type '
                                                   ||      ', ch.cardholder_name as cardholder_name '
                                                   ||      ', coalesce(cp.birthday, cpd.birthday) as birthday '
                                                   ||      ', decode(cio.id_type, null, ciod.id_type || '' - '' || com_api_dictionary_pkg.get_article_text(ciod.id_type, ''' || l_lang || '''), '
                                                   ||             ' cio.id_type || '' - '' || com_api_dictionary_pkg.get_article_text(cio.id_type, ''' || l_lang || ''')) as id_type '
                                                   ||      ', coalesce(cio.id_number, cio.id_number) as id_number '
                                                   ||      ', ci.delivery_channel || '' - '' || com_api_dictionary_pkg.get_article_text(ci.delivery_channel, ''' || l_lang || ''') as delivery_channel '
                                                   ||      ', ci.delivery_status || '' - '' || com_api_dictionary_pkg.get_article_text(ci.delivery_status, ''' || l_lang || ''') as delivery_status '
                                                   ||      ', (select distinct first_value(attr_value) over (order by start_date desc)'
                                                   ||           'from prd_attribute_value '
                                                   ||          'where attr_id = (select id '
                                                   ||                             'from prd_attribute '
                                                   ||                            'where attr_name = ''CRD_INVOICING_DELIVERY_STATEMENT_METHOD'') '
                                                   ||            'and entity_type = ''' || acc_api_const_pkg.ENTITY_TYPE_ACCOUNT || ''''
                                                   ||            'and object_id = ai_credit.account_id '
                                                   ||            'and start_date < get_sysdate) '
                                                   ||      '|| '' - '''
                                                   ||      '|| com_api_dictionary_pkg.get_article_text('
                                                   ||      '  (select distinct first_value(attr_value) over (order by start_date desc)'
                                                   ||           'from prd_attribute_value '
                                                   ||          'where attr_id = (select id '
                                                   ||                             'from prd_attribute '
                                                   ||                            'where attr_name = ''CRD_INVOICING_DELIVERY_STATEMENT_METHOD'') '
                                                   ||            'and entity_type = ''' || acc_api_const_pkg.ENTITY_TYPE_ACCOUNT || ''''
                                                   ||            'and object_id = ai_credit.account_id '
                                                   ||            'and start_date < get_sysdate) '
                                                   ||      ', ''' || l_lang || ''') as statement_delivery '
    ;
    l_cursor_flx_template  com_api_type_pkg.t_name := ', com_api_flexible_data_pkg.get_flexible_value(''#1'', ''#2'', #3) as #4';
    l_cursor_flx_column    com_api_type_pkg.t_text;
    l_cursor_tbl           com_api_type_pkg.t_sql_statement :=
                                                      'from prd_customer cu'
                                                   ||    ', iss_card ic'
                                                   ||    ', (select card_id'
                                                   ||           ' , account_id'
                                                   ||           ' , account_type'
                                                   ||           ' , account_number'
                                                   ||        ' from (select ao.object_id as card_id'
                                                   ||                    ', a.id as account_id'
                                                   ||                    ', a.account_type'
                                                   ||                    ', a.account_number'
                                                   ||                    ', row_number() over(partition by ao.object_id, a.account_type, a.account_number order by decode(a.status, ''ACSTACTV'', 0, 1), a.id) rng'
                                                   ||                ' from acc_account_object ao'
                                                   ||                   ' , acc_account a'
                                                   ||               ' where ao.entity_type = ''ENTTCARD'''
                                                   ||                 ' and a.account_type = ''ACTP0130'''
                                                   ||                 ' and a.id = ao.account_id)'
                                                   ||       ' where rng = 1) ai_credit'
                                                   ||    ', (select card_id'
                                                   ||           ' , account_type'
                                                   ||           ' , account_number'
                                                   ||        ' from (select ao.object_id as card_id'
                                                   ||                    ', a.account_type'
                                                   ||                    ', a.account_number'
                                                   ||                    ', row_number() over(partition by ao.object_id, a.account_type, a.account_number order by decode(a.status, ''ACSTACTV'', 0, 1), a.id) rng'
                                                   ||                ' from acc_account_object ao'
                                                   ||                   ' , acc_account a'
                                                   ||               ' where ao.entity_type = ''ENTTCARD'''
                                                   ||                 ' and a.account_type = ''ACTP0131'''
                                                   ||                 ' and a.id = ao.account_id)'
                                                   ||       ' where rng = 1) ai_debit'
                                                   ||    ', (select card_id'
                                                   ||           ' , account_type'
                                                   ||           ' , account_number'
                                                   ||        ' from (select ao.object_id as card_id'
                                                   ||                    ', a.account_type'
                                                   ||                    ', a.account_number'
                                                   ||                    ', row_number() over(partition by ao.object_id, a.account_type, a.account_number order by decode(a.status, ''ACSTACTV'', 0, 1), a.id) rng'
                                                   ||                ' from acc_account_object ao'
                                                   ||                   ' , acc_account a'
                                                   ||               ' where ao.entity_type = ''ENTTCARD'''
                                                   ||                 ' and a.account_type = ''ACTPLOYT'''
                                                   ||                 ' and a.id = ao.account_id)'
                                                   ||       ' where rng = 1) ai_loyalty'
                                                   ||    ', (select card_id'
                                                   ||           ' , account_type'
                                                   ||           ' , account_number'
                                                   ||        ' from (select ao.object_id as card_id'
                                                   ||                    ', a.account_type'
                                                   ||                    ', a.account_number'
                                                   ||                    ', row_number() over(partition by ao.object_id, a.account_type, a.account_number order by decode(a.status, ''ACSTACTV'', 0, 1), a.id) rng'
                                                   ||                ' from acc_account_object ao'
                                                   ||                   ' , acc_account a'
                                                   ||               ' where ao.entity_type = ''ENTTCARD'''
                                                   ||                 ' and a.account_type = ''ACTP0140'''
                                                   ||                 ' and a.id = ao.account_id)'
                                                   ||       ' where rng = 1) ai_prepaid'
                                                   ||    ', net_card_type nct'
                                                   ||    ', iss_card_number icn'
                                                   ||    ', prd_contract pc'
                                                   ||    ', prd_product pp'
                                                   ||    ', (select ici.id as instance_id'
                                                   ||            ', ici.card_id'
                                                   ||            ', ici.state'
                                                   ||            ', ici.status'
                                                   ||            ', nvl(ici.cardholder_name, ici.company_name) as cardholder_name'
                                                   ||            ', ici.iss_date'
                                                   ||            ', ici.expir_date'
                                                   ||            ', ici.reissue_reason'
                                                   ||            ', ici.blank_type_id'
                                                   ||            ', ici.delivery_channel'
                                                   ||            ', ici.delivery_status'
                                                   ||            ', row_number() over(partition by ici.card_id order by ici.seq_number desc) as rng '
                                                   ||         'from iss_card_instance ici'
                                                   ||      ') ci'
                                                   ||    ', iss_cardholder ch'
                                                   ||    ', (select row_number() over(partition by i.object_id order by i.id desc) as rng'
                                                   ||            ', i.object_id as person_id'
                                                   ||            ', i.id_type'
                                                   ||            ', com_api_dictionary_pkg.get_article_text(i.id_type, ''' || l_lang || ''') as id_name'
                                                   ||            ', i.id_series||i.id_number as id_document '
                                                   ||         'from com_id_object i '
                                                   ||        'where entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_PERSON || ''''
                                                   ||      ') ich '
                                                   ||    ', com_person cp '
                                                   ||    ', com_person cpd '
                                                   ||    ', (select object_id as person_id, id_type, id_number from ( '
                                                   ||          ' select object_id, id_type, id_number, row_number() over (partition by object_id order by seqnum desc) rn '
                                                   ||            ' from com_id_object '
                                                   ||           ' where entity_type = ''ENTTPERS'') '
                                                   ||       ' where rn = 1 '
                                                   ||     ' ) cio '
                                                   ||    ', (select object_id as person_id, id_type, id_number from ( '
                                                   ||          ' select object_id, id_type, id_number, row_number() over (partition by object_id order by seqnum desc) rn '
                                                   ||            ' from com_id_object '
                                                   ||           ' where entity_type = ''ENTTPERS'') '
                                                   ||       ' where rn = 1 '
                                                   ||     ' ) ciod '
                                                   ||'where cu.id = :i_customer_id '
                                                   ||  'and pc.customer_id = cu.id '
                                                   ||  'and ai_credit.card_id (+) = ic.id '
                                                   ||  'and ai_debit.card_id (+) = ic.id '
                                                   ||  'and ai_loyalty.card_id (+) = ic.id '
                                                   ||  'and ai_prepaid.card_id (+) = ic.id '
                                                   ||  'and nct.id = ic.card_type_id '
                                                   ||  'and icn.card_id = ic.id '
                                                   ||  'and pc.id = ic.contract_id '
                                                   ||  'and pp.id = pc.product_id '
                                                   ||  'and ic.id = ci.card_id '
                                                   ||  'and ch.id = ic.cardholder_id '
                                                   ||  'and ch.person_id = ich.person_id (+) '
                                                   ||  'and 1 = ich.rng (+) '
                                                   ||  'and ch.person_id = cp.id (+) '
                                                   ||  'and cu.object_id = cpd.id (+) '
                                                   ||  'and cu.entity_type (+) in ( ''ENTTPERS'', ''ENTTCOMP'')  '
                                                   ||  'and cp.id  = cio.person_id (+) '
                                                   ||  'and cpd.id = ciod.person_id (+) '
    ;
    l_cursor_order         com_api_type_pkg.t_name := 'order by ic.id'
    ;
    l_cursor_str           com_api_type_pkg.t_sql_statement;
    l_cursor_where         com_api_type_pkg.t_text;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - i_customer_id [' || i_customer_id
               || '], i_agent_id [' || i_agent_id
               || '], l_lang [' || l_lang
               || ']'
    );

    if i_agent_id is not null then

        l_cursor_where := l_cursor_where || 'and pc.agent_id = ' || i_agent_id || ' ';

    end if;

    l_cursor_str := l_cursor_count || l_cursor_tbl || l_cursor_where;

    trc_log_pkg.debug(LOG_PREFIX || ' count query[1]: ' || substr(l_cursor_str,    1, 3900));
    trc_log_pkg.debug(LOG_PREFIX || ' count query[2]: ' || substr(l_cursor_str, 3901, 3900));

    execute immediate l_cursor_str
                 into o_row_count
                using in i_customer_id;

    if o_row_count = 0 then

        com_api_error_pkg.raise_error(
            i_error      => 'NO_CUSTOMER_DATA_REQUESTED'
          , i_env_param1 => upper(LOG_PREFIX)
          , i_env_param2 => i_customer_id
        );

    end if;

    if g_flexible_fields_instant.count > com_api_const_pkg.FALSE then

        for rec in (select iss_api_const_pkg.ENTITY_TYPE_CARD as entity from dual
                    union all
                    select iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE as entity from dual
        ) loop

            if g_flexible_fields_instant.exists(rec.entity) then

                for i in g_flexible_fields_instant(rec.entity).first .. g_flexible_fields_instant(rec.entity).last
                loop
                    l_cursor_flx_column := l_cursor_flx_column
                                        || replace(
                                               replace(
                                                   replace(
                                                       replace(
                                                           l_cursor_flx_template
                                                         , '#1'
                                                         , g_flexible_fields_instant(rec.entity)(i).field_name
                                                       )
                                                     , '#2'
                                                     , rec.entity
                                                   )
                                                 , '#3'
                                                 , case
                                                       when rec.entity = iss_api_const_pkg.ENTITY_TYPE_CARD
                                                           then 'ic.id'
                                                       when rec.entity = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                                           then 'ci.instance_id'
                                                       else 'null'
                                                   end
                                               )
                                             , '#4'
                                             , g_flexible_fields_instant(rec.entity)(i).field_short_name
                                           )
                    ;
                end loop;

            end if;

        end loop;

        l_cursor_flx_column := l_cursor_flx_column || ' ';

    end if;

    l_cursor_str := l_cursor_column || l_cursor_flx_column || l_cursor_tbl || l_cursor_where || l_cursor_order;

    trc_log_pkg.debug(LOG_PREFIX || ' FINISH query[1]: ' || substr(l_cursor_str,    1, 3900));
    trc_log_pkg.debug(LOG_PREFIX || ' FINISH query[2]: ' || substr(l_cursor_str, 3901, 3900));
    trc_log_pkg.debug(LOG_PREFIX || ' FINISH query[3]: ' || substr(l_cursor_str, 7801, 3900));

    open  o_ref_cursor
      for l_cursor_str
    using i_customer_id
    ;

exception
    when others then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_main_cards_info;

procedure get_card_type_feature(
    i_card_number        in    com_api_type_pkg.t_card_number
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
)
is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_card_type_feature: ';

    l_lang                 com_api_type_pkg.t_dict_value := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

    l_card_futures         com_api_type_pkg.t_dict_tab;
    l_card_futures_desc    com_api_type_pkg.t_desc_tab;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - i_card_number [' || iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
               || '], l_lang [' || l_lang
               || ']'
    );

    itf_ui_integration_pkg.get_card_features(
        i_card_number => i_card_number
      , i_card_id     => null
      , i_lang        => l_lang
      , o_ref_cursor  => o_ref_cursor
    );

    if o_ref_cursor%isopen then

        fetch o_ref_cursor bulk collect into l_card_futures, l_card_futures_desc;
        o_row_count := l_card_futures.count;

        close_ref_cursor(
            i_ref_cursor => o_ref_cursor
        );

        if o_row_count = 0 then

            trc_log_pkg.debug(
                i_text => LOG_PREFIX || 'Not card type features for card  - i_card_number [' || iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
                       || ']'
            );

        else

            itf_ui_integration_pkg.get_card_features(
                i_card_number => i_card_number
              , i_card_id     => null
              , i_lang        => l_lang
              , o_ref_cursor  => o_ref_cursor
            );

        end if;

    else

        o_row_count := 0;

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Not card type features for card  - i_card_number [' || iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
                   || ']'
        );

    end if;

exception
    when others then

        o_row_count := nvl(o_row_count, 0);

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_card_type_feature;

procedure get_customer_limit_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
)
is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_customer_limit_info: ';

    l_lang                 com_api_type_pkg.t_dict_value := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

    l_cursor_count         com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column        com_api_type_pkg.t_text := 'select lmt.customer_limit_name'
                                                   ||      ', to_char('
                                                   ||            'lmt.limit_sum / power(10, cc.exponent)'
                                                   ||          ', ''' || com_api_const_pkg.XML_NUMBER_FORMAT || ''''
                                                   ||            '|| rpad('
                                                   ||                   '''.'''
                                                   ||                 ', case cc.exponent '
                                                   ||                       'when 0 '
                                                   ||                           'then 0 '
                                                   ||                       'else cc.exponent + 1 '
                                                   ||                   'end'
                                                   ||                 ', ''0'''
                                                   ||               ')'
                                                   ||        ') as limit_sum'
                                                   ||      ', to_char('
                                                   ||            'lmt.sum_reminder / power(10, cc.exponent)'
                                                   ||          ', ''' || com_api_const_pkg.XML_NUMBER_FORMAT || ''''
                                                   ||            '|| rpad('
                                                   ||                   '''.'''
                                                   ||                 ', case cc.exponent '
                                                   ||                       'when 0 '
                                                   ||                           'then 0 '
                                                   ||                       'else cc.exponent + 1 '
                                                   ||                   'end'
                                                   ||                 ', ''0'''
                                                   ||               ')'
                                                   ||        ') as sum_reminder '
    ;
    l_cursor_tbl           com_api_type_pkg.t_text := 'from ('
                                                   ||       'select p.id'
                                                   ||            ', p.attr_name as attr_system_name'
                                                   ||            ', com_api_i18n_pkg.get_text(''PRD_ATTRIBUTE'', ''LABEL'', p.id, ''' || l_lang || ''') as customer_limit_name'
                                                   ||            ', fcl_api_limit_pkg.get_limit_currency('
                                                   ||                  'i_limit_type  => p.object_type'
                                                   ||                ', i_entity_type => ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''''
                                                   ||                ', i_object_id   => :icustomer_id'
                                                   ||                ', i_mask_error  => ' || com_api_const_pkg.TRUE
                                                   ||              ') as limit_currency'
                                                   ||            ', fcl_api_limit_pkg.get_sum_limit('
                                                   ||                  'i_limit_type  => p.object_type'
                                                   ||                ', i_entity_type => ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''''
                                                   ||                ', i_object_id   => :icustomer_id'
                                                   ||                ', i_mask_error  => ' || com_api_const_pkg.TRUE
                                                   ||              ') as limit_sum'
                                                   ||            ', fcl_api_limit_pkg.get_sum_remainder('
                                                   ||                  'i_limit_type  => p.object_type'
                                                   ||                ', i_entity_type => ''' || com_api_const_pkg.ENTITY_TYPE_CUSTOMER || ''''
                                                   ||                ', i_object_id   => :icustomer_id'
                                                   ||                ', i_mask_error  => ' || com_api_const_pkg.TRUE
                                                   ||              ') as sum_reminder '
                                                   ||         'from prd_attribute p '
                                                   ||        'where p.service_type_id = ' || gui_api_const_pkg.CUSTOMER_MAINTENANCE_SERVICE || ' '
                                                   ||          'and p.entity_type = ''' || fcl_api_const_pkg.ENTITY_TYPE_LIMIT || ''' '
                                                   ||        'start with '
                                                   ||              'p.id = ' || prd_api_attribute_pkg.get_attribute(i_attr_name => gui_api_const_pkg.CUSTOMER_CREDIT_LIMITS_GROUP).ID || ' '
                                                   ||       'connect by '
                                                   ||        'prior p.id = p.parent_id'
                                                   ||     ') lmt'
                                                   ||     ', com_currency cc '
                                                   ||'where lmt.limit_currency = cc.code (+) '
    ;
    l_cursor_order         com_api_type_pkg.t_name := 'order by lmt.id'
    ;
    l_cursor_str           com_api_type_pkg.t_sql_statement;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - i_customer_id [' || i_customer_id
               || '], l_lang [' || l_lang
               || ']'
    );

    l_cursor_str := l_cursor_count || l_cursor_tbl;

    execute immediate l_cursor_str
                 into o_row_count
                using in i_customer_id
                    , in i_customer_id
                    , in i_customer_id
    ;

    if o_row_count = 0 then

        com_api_error_pkg.raise_error(
            i_error      => 'NO_CUSTOMER_DATA_REQUESTED'
          , i_env_param1 => upper(LOG_PREFIX)
          , i_env_param2 => i_customer_id
        );

    end if;


    l_cursor_str := l_cursor_column || l_cursor_tbl || l_cursor_order;

    open  o_ref_cursor
      for l_cursor_str
    using i_customer_id
        , i_customer_id
        , i_customer_id
    ;

exception
    when others then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_customer_limit_info;

procedure get_customer_crd_invoice_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_agent_id           in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
)
is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_customer_crd_invoice_info: ';

    l_cursor_count         com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column        com_api_type_pkg.t_text := 'select iv.invoice_id'
                                                   ||      ', a.account_number as credit_account_number'
                                                   ||      ', to_char('
                                                   ||            'iv.total_amount_due / power(10, cc.exponent)'
                                                   ||          ', ''' || com_api_const_pkg.XML_NUMBER_FORMAT || ''''
                                                   ||            '|| rpad('
                                                   ||                   '''.'''
                                                   ||                 ', case cc.exponent '
                                                   ||                       'when 0 '
                                                   ||                           'then 0 '
                                                   ||                       'else cc.exponent + 1 '
                                                   ||                   'end'
                                                   ||                 ', ''0'''
                                                   ||               ')'
                                                   ||        ') as total_amount_due'
                                                   ||      ', to_char('
                                                   ||            'iv.min_amount_due / power(10, cc.exponent)'
                                                   ||          ', ''' || com_api_const_pkg.XML_NUMBER_FORMAT || ''''
                                                   ||            '|| rpad('
                                                   ||                   '''.'''
                                                   ||                 ', case cc.exponent '
                                                   ||                       'when 0 '
                                                   ||                           'then 0 '
                                                   ||                       'else cc.exponent + 1 '
                                                   ||                   'end'
                                                   ||                 ', ''0'''
                                                   ||               ')'
                                                   ||        ') as min_amount_due'
                                                   ||      ', to_char('
                                                   ||            'iv.overdue_balance / power(10, cc.exponent)'
                                                   ||          ', ''' || com_api_const_pkg.XML_NUMBER_FORMAT || ''''
                                                   ||            '|| rpad('
                                                   ||                   '''.'''
                                                   ||                 ', case cc.exponent '
                                                   ||                       'when 0 '
                                                   ||                           'then 0 '
                                                   ||                       'else cc.exponent + 1 '
                                                   ||                   'end'
                                                   ||                 ', ''0'''
                                                   ||               ')'
                                                   ||        ') as overdue_balance'
                                                   ||      ', to_char('
                                                   ||            'iv.payment_amount / power(10, cc.exponent)'
                                                   ||          ', ''' || com_api_const_pkg.XML_NUMBER_FORMAT || ''''
                                                   ||            '|| rpad('
                                                   ||                   '''.'''
                                                   ||                 ', case cc.exponent '
                                                   ||                       'when 0 '
                                                   ||                           'then 0 '
                                                   ||                       'else cc.exponent + 1 '
                                                   ||                   'end'
                                                   ||                 ', ''0'''
                                                   ||               ')'
                                                   ||        ') as payment_amount'
                                                   ||      ', iv.due_date'
                                                   ||      ', to_char('
                                                   ||            'iv.expense_amount / power(10, cc.exponent)'
                                                   ||          ', ''' || com_api_const_pkg.XML_NUMBER_FORMAT || ''''
                                                   ||            '|| rpad('
                                                   ||                   '''.'''
                                                   ||                 ', case cc.exponent '
                                                   ||                       'when 0 '
                                                   ||                           'then 0 '
                                                   ||                       'else cc.exponent + 1 '
                                                   ||                   'end'
                                                   ||                 ', ''0'''
                                                   ||               ')'
                                                   ||        ') as expense_amount '
    ;
    l_cursor_tbl           com_api_type_pkg.t_text := 'from prd_customer cu'
                                                   ||    ', prd_contract pc'
                                                   ||    ', prd_service s'
                                                   ||    ', prd_service_object so'
                                                   ||    ', acc_account a'
                                                   ||    ', (select i.id as invoice_id'
                                                   ||            ', i.account_id'
                                                   ||            ', i.total_amount_due'
                                                   ||            ', i.min_amount_due'
                                                   ||            ', i.overdue_balance'
                                                   ||            ', i.payment_amount'
                                                   ||            ', i.due_date'
                                                   ||            ', i.expense_amount'
                                                   ||            ', row_number() over(partition by i.account_id order by i.serial_number desc) as rng '
                                                   ||         'from crd_invoice i'
                                                   ||      ') iv'
                                                   ||    ', com_currency cc '
                                                   ||'where cu.id = :i_customer_id '
                                                   ||  'and pc.customer_id = cu.id '
                                                   ||  'and s.service_type_id = ' || crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID || ' '
                                                   ||  'and so.service_id = s.id '
                                                   ||  'and so.contract_id = pc.id '
                                                   ||  'and so.entity_type = ''' || acc_api_const_pkg.ENTITY_TYPE_ACCOUNT || ''' '
                                                   ||  'and so.object_id = a.id '
                                                   ||  'and a.id = iv.account_id (+) '
                                                   ||  'and 1 = iv.rng (+) '
                                                   ||  'and a.currency = cc.code '
    ;
    l_cursor_order         com_api_type_pkg.t_name := 'order by a.id'
    ;
    l_cursor_str           com_api_type_pkg.t_sql_statement;
    l_cursor_where         com_api_type_pkg.t_text;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with param - i_customer_id [' || i_customer_id
               || '], i_agent_id [' || i_agent_id
               || ']'
    );

    if i_agent_id is not null then

        l_cursor_where := l_cursor_where || 'and pc.agent_id = ' || i_agent_id || ' ';

    end if;

    l_cursor_str := l_cursor_count || l_cursor_tbl || l_cursor_where;

    execute immediate l_cursor_str
                 into o_row_count
                using
                   in i_customer_id
    ;

    if o_row_count = 0 then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Not credit accounts for customer  - i_customer_id [' || i_customer_id
                   || ']'
        );

    else

        l_cursor_str := l_cursor_column || l_cursor_tbl || l_cursor_where || l_cursor_order;

        open  o_ref_cursor
          for l_cursor_str
        using i_customer_id
        ;

    end if;

exception
    when others then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_customer_crd_invoice_info;

procedure get_crd_invoice_payments_info(
    i_invoice_id         in    com_api_type_pkg.t_medium_id
  , i_agent_id           in    com_api_type_pkg.t_name         default null
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
)
is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_customer_crd_invoice_info: ';

    l_cursor_count         com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column        com_api_type_pkg.t_text := 'select oo.oper_date'
                                                   ||      ', to_char('
                                                   ||            'cp.amount / power(10, cc.exponent)'
                                                   ||          ', ''' || com_api_const_pkg.XML_NUMBER_FORMAT || ''''
                                                   ||            '|| rpad('
                                                   ||                   '''.'''
                                                   ||                 ', case cc.exponent '
                                                   ||                       'when 0 '
                                                   ||                           'then 0 '
                                                   ||                       'else cc.exponent + 1 '
                                                   ||                   'end'
                                                   ||                 ', ''0'''
                                                   ||               ')'
                                                   ||        ') as amount '
    ;
    l_cursor_tbl           com_api_type_pkg.t_text := 'from crd_invoice_payment ip'
                                                   ||    ', crd_payment cp'
                                                   ||    ', opr_operation oo'
                                                   ||    ', com_currency cc '
                                                   ||'where ip.invoice_id = :i_invoice_id '
                                                   ||  'and cp.id = ip.pay_id '
                                                   ||  'and oo.id = cp.oper_id '
                                                   ||  'and cc.code = cp.currency '
    ;
    l_cursor_order         com_api_type_pkg.t_name := 'order by oo.oper_date'
    ;
    l_cursor_str           com_api_type_pkg.t_sql_statement;
    l_cursor_where         com_api_type_pkg.t_text;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with param - i_invoice_id [' || i_invoice_id
               || '], i_agent_id [' || i_agent_id
               || ']'
    );

    if i_agent_id is not null then

        l_cursor_where := l_cursor_where || 'and cp.agent_id = ' || i_agent_id || ' ';

    end if;

    l_cursor_str := l_cursor_count || l_cursor_tbl || l_cursor_where;

    execute immediate l_cursor_str
                 into o_row_count
                using
                   in i_invoice_id
    ;

    if o_row_count = 0 then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Not payments for invoice  - i_invoice_id [' || i_invoice_id
                   || ']'
        );

    else

        l_cursor_str := l_cursor_column || l_cursor_tbl || l_cursor_where || l_cursor_order;

        open  o_ref_cursor
          for l_cursor_str
        using i_invoice_id
        ;

    end if;

exception
    when others then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_crd_invoice_payments_info;

procedure get_customer_marketing_info(
    i_customer_id        in    com_api_type_pkg.t_medium_id
  , i_months_ago         in    com_api_type_pkg.t_byte_id
  , i_mask_error         in    com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_row_count         out    com_api_type_pkg.t_long_id
  , o_ref_cursor        out    com_api_type_pkg.t_ref_cur
)
is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_customer_marketing_info: ';

    l_lang                 com_api_type_pkg.t_dict_value := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

    l_cursor_count         com_api_type_pkg.t_name := 'select count(1) '
    ;
    l_cursor_column        com_api_type_pkg.t_text := 'select iss.card_type_id'
                                                   ||      ', iss.card_type_name'
                                                   ||      ', iss.card_number'
                                                   ||      ', iss.card_account_number'
                                                   ||      ', iss.card_account_type'
                                                   ||      ', iss.card_account_type_name'
                                                   ||      ', iss.is_credit_flag'
                                                   ||      ', op.oper_type'
                                                   ||      ', op.oper_type || '' - '' || com_api_dictionary_pkg.get_article_text(op.oper_type, ''' || l_lang || ''') as oper_type_name'
                                                   ||      ', cc.name as currency_name'
                                                   ||      ', to_char('
                                                   ||            'sum(op.oper_amount / power(10, cc.exponent))'
                                                   ||          ', ''' || com_api_const_pkg.XML_NUMBER_FORMAT || ''''
                                                   ||            '|| rpad('
                                                   ||                   '''.'''
                                                   ||                 ', case cc.exponent '
                                                   ||                       'when 0 '
                                                   ||                           'then 0 '
                                                   ||                       'else cc.exponent + 1 '
                                                   ||                   'end'
                                                   ||                 ', ''0'''
                                                   ||               ')'
                                                   ||      ') as oper_amount '
    ;
    l_cursor_tbl           com_api_type_pkg.t_text := 'from opr_operation op'
                                                   ||    ', opr_participant pr'
                                                   ||    ', (select /*+ ordered use_nl(co ic cn ao a) */'
                                                   ||            '  ic.id as card_id'
                                                   ||            ', ic.card_type_id'
                                                   ||            ', ic.card_type_id || '' - '' || com_api_i18n_pkg.get_text(''NET_CARD_TYPE'', ''NAME'', ic.card_type_id, ''' || l_lang || ''')  as card_type_name'
                                                   ||            ', iss_api_token_pkg.decode_card_number(cn.card_number) as card_number'
                                                   ||            ', a.id as account_id'
                                                   ||            ', a.account_number as card_account_number'
                                                   ||            ', a.account_type as card_account_type'
                                                   ||            ', a.account_type || '' - '' || com_api_dictionary_pkg.get_article_text(a.account_type, ''' || l_lang || ''') as card_account_type_name'
                                                   ||            ', nvl('
                                                   ||                  '(select 1 '
                                                   ||                     'from prd_service s'
                                                   ||                        ', prd_service_object so '
                                                   ||                    'where s.service_type_id = ' || crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID || ' '
                                                   ||                      'and so.contract_id = co.id '
                                                   ||                      'and so.service_id = s.id '
                                                   ||                      'and so.entity_type = ''' || acc_api_const_pkg.ENTITY_TYPE_ACCOUNT || ''' '
                                                   ||                      'and so.object_id = a.id '
                                                   ||                      'and rownum < 2'
                                                   ||                  ')'
                                                   ||                ', 0'
                                                   ||              ') as is_credit_flag'
                                                   ||            ', ao.usage_order '
                                                   ||         'from prd_contract co'
                                                   ||            ', iss_card ic'
                                                   ||            ', iss_card_number cn'
                                                   ||            ', acc_account_object ao'
                                                   ||            ', acc_account a '
                                                   ||        'where co.customer_id = :i_customer_id '
                                                   ||           'and ic.contract_id = co.id '
                                                   ||           'and cn.card_id = ic.id '
                                                   ||           'and ao.object_id = ic.id '
                                                   ||           'and ao.entity_type = ''' || iss_api_const_pkg.ENTITY_TYPE_CARD || ''' '
                                                   ||           'and a.id = ao.account_id'
                                                   ||      ') iss'
                                                   ||    ', com_currency cc '
                                                   ||'where op.oper_date between :date_start and :date_end  '
                                                   ||  'and pr.oper_id = op.id '
                                                   ||  'and pr.participant_type = ''' || com_api_const_pkg.PARTICIPANT_ISSUER || ''' '
                                                   ||  'and pr.card_id = iss.card_id '
                                                   ||  'and (pr.account_id = iss.account_id or (pr.account_id is null and iss.usage_order = 1)) '
                                                   ||  'and cc.code = op.oper_currency '
    ;
    l_cursor_group_by      com_api_type_pkg.t_full_desc := 'group by '
                                                        ||       'iss.card_type_id'
                                                        ||       ', iss.card_type_name'
                                                        ||       ', iss.card_id'
                                                        ||       ', iss.card_number'
                                                        ||       ', iss.account_id'
                                                        ||       ', iss.card_account_number'
                                                        ||       ', iss.card_account_type'
                                                        ||       ', iss.card_account_type_name'
                                                        ||       ', iss.is_credit_flag'
                                                        ||       ', op.oper_type'
                                                        ||       ', cc.name'
                                                        ||       ', cc.exponent '
    ;
    l_cursor_order         com_api_type_pkg.t_name := 'order by '
                                                   ||       'iss.is_credit_flag desc'
                                                   ||       ', iss.card_id'
                                                   ||       ', iss.account_id'
    ;
    l_cursor_str           com_api_type_pkg.t_sql_statement;

    l_date_end             date := get_sysdate();
    l_date_start           date := case
                                       when i_months_ago is null
                                           then trunc(l_date_end, 'mm')
                                       else
                                           add_months(l_date_end, (-1)*i_months_ago)
                                   end;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with param - i_customer_id [' || i_customer_id
               || '], i_months_ago [' || i_months_ago
               || '], l_lang [' || l_lang
               || ']'
    );

    l_cursor_str := l_cursor_count || 'from (' || l_cursor_column || l_cursor_tbl || l_cursor_group_by || ')';

    execute immediate l_cursor_str
                 into o_row_count
                using
                   in i_customer_id
                 , in l_date_start
                 , in l_date_end
    ;

    if o_row_count = 0 then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Not operation fount for customer  - i_customer_id [' || i_customer_id
                   || '], for period: date_start [' || to_char(l_date_start, com_api_const_pkg.XML_DATETIME_FORMAT)
                   || '], date_end [' || to_char(l_date_end, com_api_const_pkg.XML_DATETIME_FORMAT)
                   || ']'
        );

    else

        l_cursor_str := l_cursor_column || l_cursor_tbl || l_cursor_group_by || l_cursor_order;

        open  o_ref_cursor
          for l_cursor_str
        using i_customer_id
            , l_date_start
            , l_date_end
        ;

    end if;

exception
    when others then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        if com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.TRUE then

            if i_mask_error = com_api_const_pkg.TRUE then

                null;

            else

                raise;

            end if;

        elsif com_api_error_pkg.is_fatal_error(code => sqlcode) = com_api_const_pkg.TRUE then

            raise;

        else

            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

end get_customer_marketing_info;

procedure close_ref_cursor(
    i_ref_cursor         in    com_api_type_pkg.t_ref_cur
)
is

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.close_ref_cursor: ';

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Start'
    );

    if i_ref_cursor%isopen then
        close i_ref_cursor;
    end if;

exception
    when others then

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Finished with error'
        );

        raise;

end close_ref_cursor;

begin
    for rec in (select flx.id
                     , flx.entity_type
                     , flx.name
                     , case
                           when length(flx.name) > 30
                               then 'FLX'||to_char(flx.id)
                           else flx.name
                       end as short_name
                  from com_flexible_field flx
                 order by
                       flx.entity_type
                     , flx.id
    ) loop

        if g_flexible_fields_instant.exists(rec.entity_type) then

            g_current_index := g_flexible_fields_instant(rec.entity_type).last + 1;

            g_flexible_fields_instant(rec.entity_type)(g_current_index).field_id         := rec.id;
            g_flexible_fields_instant(rec.entity_type)(g_current_index).field_name       := rec.name;
            g_flexible_fields_instant(rec.entity_type)(g_current_index).field_short_name := rec.short_name;

        else

            g_flexible_fields_instant(rec.entity_type)(1).field_id         := rec.id;
            g_flexible_fields_instant(rec.entity_type)(1).field_name       := rec.name;
            g_flexible_fields_instant(rec.entity_type)(1).field_short_name := rec.short_name;

        end if;

    end loop;

end gui_api_external_pkg;
/
