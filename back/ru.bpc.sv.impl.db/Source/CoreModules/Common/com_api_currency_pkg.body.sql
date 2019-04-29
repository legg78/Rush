create or replace package body com_api_currency_pkg is

procedure apply_currency_update (
    i_code_tab           in      com_api_type_pkg.t_curr_code_tab
  , i_name_tab           in      com_api_type_pkg.t_curr_code_tab
  , i_exponent_tab       in      com_api_type_pkg.t_tiny_tab
) is
begin
    forall i in 1 .. i_code_tab.count
        merge into
            com_currency dst
        using (
            select
                i_code_tab(i) code
                , i_name_tab(i) name
                , i_exponent_tab(i) exponent
            from dual
        ) src
        on (
            src.code = dst.code
        )
        when matched then
            update
            set
                dst.name = src.name
                , dst.exponent = src.exponent
                , dst.seqnum = dst.seqnum + 1
        when not matched then
            insert (
                dst.id
                , dst.code
                , dst.name
                , dst.exponent
                , dst.seqnum
            ) values (
                com_currency_seq.nextval
                , src.code
                , src.name
                , src.exponent
                , 1
            );
end;

function get_currency_exponent(
    i_curr_code          in      com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_tiny_id is
    l_result            com_api_type_pkg.t_tiny_id;
begin
    select exponent
      into l_result
      from com_currency
     where code = i_curr_code;

    return l_result;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'CURRENCY_NOT_FOUND'
          , i_env_param1 => i_curr_code
        );
end;

function get_amount_str(
    i_amount             in      com_api_type_pkg.t_money
  , i_curr_code          in      com_api_type_pkg.t_curr_code
  , i_mask_curr_code     in      com_api_type_pkg.t_boolean
  , i_format_mask        in      com_api_type_pkg.t_name
  , i_mask_error         in      com_api_type_pkg.t_boolean
  , i_user_dig_separator in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
) return com_api_type_pkg.t_name
is
    l_result                  com_api_type_pkg.t_name;
    l_format_mask             com_api_type_pkg.t_name;
    l_nls_numeric_characters  com_api_type_pkg.t_name;
begin
    if i_user_dig_separator = com_api_type_pkg.TRUE then
        l_nls_numeric_characters := com_ui_user_env_pkg.get_nls_numeric_characters;
    else
        l_nls_numeric_characters := 'NLS_NUMERIC_CHARACTERS = ''.,''';
    end if;
    if i_format_mask is null then
        l_format_mask        := com_ui_user_env_pkg.get_format_mask;
    else
        case
            when instr(i_format_mask, 'D') > 0
            then l_format_mask    := i_format_mask;
            when instr(i_format_mask, '.') > 0
            then l_format_mask    := substr(i_format_mask, 1, instr(i_format_mask, '.') - 1)||'D0099';
            else l_format_mask    := i_format_mask||'D0099';
        end case;
    end if;
    if i_amount is not null then -- return null if i_amount is null
        select to_char(round(i_amount) / power(10, exponent)
                     , case when exponent > 0 then l_format_mask else substr(l_format_mask, 1, instr(l_format_mask, 'D') - 1) end
                     , l_nls_numeric_characters
               )
               || case when i_mask_curr_code = com_api_type_pkg.FALSE then ' '||name else '' end
          into l_result
          from com_currency
         where code = i_curr_code;
    end if;

    return l_result;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            return to_char(i_amount);
        else
            com_api_error_pkg.raise_error(
                i_error      => 'CURRENCY_NOT_FOUND'
              , i_env_param1 => i_curr_code
            );
        end if;
end;

function get_currency_name(
    i_curr_code          in      com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_curr_name
result_cache relies_on (com_currency)
is
    l_curr_name                 com_api_type_pkg.t_curr_name;
begin
    if i_curr_code is not null then
        select name
          into l_curr_name
          from com_currency
         where code = i_curr_code;
    end if;

    return l_curr_name;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'CURRENCY_NOT_FOUND'
          , i_env_param1 => i_curr_code
        );
end get_currency_name;

function get_currency_code(
    i_curr_name          in      com_api_type_pkg.t_curr_name
) return com_api_type_pkg.t_curr_code
result_cache relies_on (com_currency)
is
    l_curr_code                 com_api_type_pkg.t_curr_code;
begin
    if i_curr_name is not null then
        select c.code
          into l_curr_code
          from com_currency c
         where c.name = i_curr_name;
    end if;

    return l_curr_code;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'CURRENCY_NOT_FOUND'
          , i_env_param1 => i_curr_name
        );
end get_currency_code;

function get_currency_full_name(
    i_curr_code          in      com_api_type_pkg.t_curr_name
  , i_lang               in      com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_name
result_cache relies_on (com_currency)

is

    l_curr_full_name   com_api_type_pkg.t_name;
    
begin
    if i_curr_code is not null then
        
        select com_api_i18n_pkg.get_text(
                  i_table_name  =>  'COM_CURRENCY'
                , i_column_name =>  'NAME'
                , i_object_id   =>  cr.id
                , i_lang        =>  i_lang
               )
          into l_curr_full_name
          from com_currency cr
         where cr.code = i_curr_code;
         
    end if;
     
    return l_curr_full_name;
     
exception
    when no_data_found then
        
        com_api_error_pkg.raise_error(
            i_error      => 'CURRENCY_NOT_FOUND'
          , i_env_param1 => i_curr_code
        );
        
end get_currency_full_name;

function get_multiplier(
    i_curr_code          in      com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_money
result_cache relies_on (com_currency)
is
begin
    return
        case
            when i_curr_code is null
            then 1
            else power(10, com_api_currency_pkg.get_currency_exponent(i_curr_code => i_curr_code))
        end;
end get_multiplier;

end;
/
