create or replace package body com_api_country_pkg is

INTERNAL_GERMANY_COUNTRY_CODE  constant com_api_type_pkg.t_country_code := '280';
EXTERNAL_GERMANY_COUNTRY_CODE  constant com_api_type_pkg.t_country_code := '276';

procedure apply_country_update(
    i_code_tab          in      com_api_type_pkg.t_curr_code_tab
  , i_name_tab          in      com_api_type_pkg.t_curr_code_tab
  , i_curr_code_tab     in      com_api_type_pkg.t_curr_code_tab
  , i_region_tab        in      com_api_type_pkg.t_dict_tab
  , i_euro_tab          in      com_api_type_pkg.t_curr_code_tab
  , i_desc_tab          in      com_api_type_pkg.t_name_tab
) is
    l_sepa_tab          com_api_type_pkg.t_byte_char_tab;
begin
    for i in 1 .. i_code_tab.count loop
        l_sepa_tab(i) := null;
    end loop;

    apply_country_update (
        i_code_tab          => i_code_tab
      , i_name_tab          => i_name_tab
      , i_curr_code_tab     => i_curr_code_tab
      , i_region_tab        => i_region_tab
      , i_euro_tab          => i_euro_tab
      , i_desc_tab          => i_desc_tab
      , i_sepa_tab          => l_sepa_tab
    );
end apply_country_update;

procedure apply_country_update(
    i_code_tab          in      com_api_type_pkg.t_curr_code_tab
  , i_name_tab          in      com_api_type_pkg.t_curr_code_tab
  , i_curr_code_tab     in      com_api_type_pkg.t_curr_code_tab
  , i_region_tab        in      com_api_type_pkg.t_dict_tab
  , i_euro_tab          in      com_api_type_pkg.t_curr_code_tab
  , i_desc_tab          in      com_api_type_pkg.t_name_tab
  , i_sepa_tab          in      com_api_type_pkg.t_byte_char_tab
) is
    l_country_id        com_api_type_pkg.t_tiny_id;
begin
    for i in 1 .. i_code_tab.count loop
        update
            com_country
        set
            name = i_name_tab(i)
            , curr_code = i_curr_code_tab(i)
            , mastercard_region = i_region_tab(i)
            , mastercard_eurozone = i_euro_tab(i)
            , sepa_indicator = i_sepa_tab(i)
            , seqnum = seqnum + 1
        where
            code = i_code_tab(i)
        returning
            id
        into
            l_country_id;
                
        if sql%rowcount > 0 then
            com_api_i18n_pkg.add_text(
                i_table_name    => 'com_country'
              , i_column_name   => 'name'
              , i_object_id     => l_country_id
              , i_lang          => com_api_const_pkg.LANGUAGE_ENGLISH
              , i_text          => i_desc_tab(i)
            );
        else
            select com_country_seq.nextval into l_country_id from dual;
            
            insert into com_country (
                id
              , seqnum
              , code
              , name
              , curr_code
              , mastercard_region
              , mastercard_eurozone
              , sepa_indicator
            ) values (
                l_country_id
              , 1
              , i_code_tab(i)
              , i_name_tab(i)
              , i_curr_code_tab(i)
              , i_region_tab(i)
              , i_euro_tab(i)
              , i_sepa_tab(i)
            );
            com_api_i18n_pkg.add_text(
                i_table_name    => 'com_country'
              , i_column_name   => 'name'
              , i_object_id     => l_country_id
              , i_lang          => com_api_const_pkg.LANGUAGE_ENGLISH
              , i_text          => i_desc_tab(i)
            );
        end if;
    end loop;
end;

function get_country_name(
    i_code              in      com_api_type_pkg.t_country_code
    , i_raise_error     in      com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
) return com_api_type_pkg.t_country_code is
    l_result            com_api_type_pkg.t_country_code;
begin
      select name
      into l_result
      from com_country
     where code = i_code;

     return l_result;

exception
    when no_data_found then
        if i_raise_error = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_error(
                i_error             => 'VISA_COUNTRY_CODE_NOT_FOUND'
              , i_env_param1        => i_code
            );
        else
            return l_result;
        end if;
end;

function get_country_code(
    i_visa_country_code in      com_api_type_pkg.t_country_code
    , i_raise_error     in      com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
) return com_api_type_pkg.t_country_code is
    l_result            com_api_type_pkg.t_country_code;
begin
    select code
      into l_result
      from com_country
     where upper(visa_country_code) = upper(i_visa_country_code);
     
     return l_result;
     
exception
    when no_data_found then
        if i_raise_error = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_error(
                i_error             => 'VISA_COUNTRY_CODE_NOT_FOUND'
              , i_env_param1        => upper(i_visa_country_code)
            );
        else
            return l_result;
        end if;
end;
    
function get_country_code_by_name(
    i_name              in      com_api_type_pkg.t_name
    , i_raise_error     in      com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
) return com_api_type_pkg.t_country_code is
    l_result            com_api_type_pkg.t_country_code;
begin
    select code
      into l_result
      from com_country
     where upper(name) = upper(i_name);

     return l_result;
exception
    when no_data_found then
        if i_raise_error = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_error(
                i_error             => 'COUNTRY_CODE_BY_NAME_NOT_FOUND'
              , i_env_param1        => upper(i_name)
            );
        else
            return l_result;
        end if;
end;

function get_visa_code(
    i_country_code      in      com_api_type_pkg.t_country_code
    , i_raise_error     in      com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
) return varchar2 result_cache relies_on (com_country)
is
    l_result            com_api_type_pkg.t_country_code;
begin
    select visa_country_code
      into l_result
      from com_country
     where code = i_country_code;

     return l_result;

exception
    when no_data_found then
        if i_raise_error = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_error(
                i_error             => 'COUNTRY_CODE_NOT_FOUND'
              , i_env_param1        => i_country_code
            );
        else
            return l_result;
        end if;
end;
    
function get_visa_region(
    i_country_code      in      com_api_type_pkg.t_country_code
    , i_raise_error     in      com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
) return com_api_type_pkg.t_dict_value result_cache relies_on (com_country)
is
    l_result            com_api_type_pkg.t_dict_value;
begin
    select visa_region
      into l_result
      from com_country
     where code = i_country_code;

     return l_result;
exception
    when no_data_found then
        if i_raise_error = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_error(
                i_error             => 'COUNTRY_CODE_NOT_FOUND'
              , i_env_param1        => i_country_code
            );
        else
            return l_result;
        end if;
end;

function get_country_full_name(
    i_code              in      com_api_type_pkg.t_country_code
  , i_lang              in      com_api_type_pkg.t_dict_value     default null
  , i_raise_error       in      com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_name
is
    l_result            com_api_type_pkg.t_name;
begin
    if i_code is not null then
        select com_api_i18n_pkg.get_text(
                   i_table_name  => 'COM_COUNTRY'
                 , i_column_name => 'NAME'
                 , i_object_id   => cc.id
                 , i_lang        => i_lang
               )
          into l_result
          from com_country cc
         where code = i_code;
    end if;

    return l_result;

exception
    when no_data_found then
        if i_raise_error = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_error(
                i_error             => 'COUNTRY_CODE_NOT_FOUND'
              , i_env_param1        => i_code
            );
        else
            return l_result;
        end if;
end get_country_full_name;

function get_country_code(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_lang              in      com_api_type_pkg.t_dict_value     default null
  , i_address_type      in      com_api_type_pkg.t_dict_value     default null
  , i_mask_errors       in      com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_country_code
is
    l_lang              com_api_type_pkg.t_dict_value;
    l_result            com_api_type_pkg.t_country_code;
begin
    l_lang := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang);

    begin
        select t.country
          into l_result
          from (select rownum as rn, a.*
                  from com_address a
                 where a.id in (select address_id
                                  from (select row_number() over (
                                                   partition by o.entity_type, o.object_id
                                                       order by decode(
                                                                    o.address_type
                                                                  , i_address_type,                          1
                                                                  , com_api_const_pkg.ADDRESS_TYPE_LEGAL,    2
                                                                  , com_api_const_pkg.ADDRESS_TYPE_BUSINESS, 3
                                                                  , com_api_const_pkg.ADDRESS_TYPE_HOME,     4
                                                                  , 5
                                                                )
                                                              , o.id
                                               ) as rn
                                             , o.address_id
                                          from com_address_object o
                                         where o.entity_type = i_entity_type
                                           and o.object_id   = i_object_id) t
                                 where t.rn = 1)
                 order by decode(a.lang, l_lang, 1, com_api_const_pkg.DEFAULT_LANGUAGE, 2, 3)) t
         where t.rn = 1;
    exception
        when no_data_found then
            if nvl(i_mask_errors, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error       => 'ADDRESS_NOT_FOUND'
                  , i_env_param1  => i_address_type
                  , i_entity_type => i_entity_type
                  , i_object_id   => i_object_id
                );
            end if;
        when others then
            if nvl(i_mask_errors, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error       => 'UNHANDLED_EXCEPTION'
                  , i_env_param1  => substr(sqlerrm, 1, 2000)
                );
            end if;
    end;

    return l_result;
end get_country_code;

function get_external_country_code(
    i_internal_country_code  in com_api_type_pkg.t_country_code
) return com_api_type_pkg.t_country_code
is
    l_external_country_code     com_api_type_pkg.t_country_code;
begin
    if i_internal_country_code   = INTERNAL_GERMANY_COUNTRY_CODE then
        l_external_country_code := EXTERNAL_GERMANY_COUNTRY_CODE;
    else
        l_external_country_code := i_internal_country_code;
    end if;

    return l_external_country_code;
end get_external_country_code;

function get_internal_country_code(
    i_external_country_code  in com_api_type_pkg.t_country_code
) return com_api_type_pkg.t_country_code
is
    l_internal_country_code     com_api_type_pkg.t_country_code;
begin
    if i_external_country_code   = EXTERNAL_GERMANY_COUNTRY_CODE then
        l_internal_country_code := INTERNAL_GERMANY_COUNTRY_CODE;
    else
        l_internal_country_code := i_external_country_code;
    end if;

    return l_internal_country_code;
end get_internal_country_code;

end com_api_country_pkg;
/
