create or replace package body frp_ui_gen_pkg as

CRLF                constant com_api_type_pkg.t_dict_value := chr(13)||chr(10);

PACKAGE_NAME        constant com_api_type_pkg.t_oracle_name := 'frp_static_pkg';

PACKAGE_TEMPLATE1   constant com_api_type_pkg.t_text :=
'create or replace package body ' || PACKAGE_NAME || ' as

function auth_id(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_long_id is
begin
    return frp_buffer_pkg.auth_id(i_rec_num);
end;

function msg_type(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_dict_value is
begin
    return frp_buffer_pkg.msg_type(i_rec_num);
end;

function oper_type(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_dict_value is
begin
    return frp_buffer_pkg.oper_type(i_rec_num);
end;

function resp_code(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_dict_value is
begin
    return frp_buffer_pkg.resp_code(i_rec_num);
end;

function acq_bin(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_name is
begin
    return frp_buffer_pkg.acq_bin(i_rec_num);
end;

function merchant_number(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_merchant_number is
begin
    return frp_buffer_pkg.merchant_number(i_rec_num);
end;

function merchant_country(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_name is
begin
    return frp_buffer_pkg.merchant_country(i_rec_num);
end;

function merchant_city(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_name is
begin
    return frp_buffer_pkg.merchant_city(i_rec_num);
end;

function merchant_street(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_name is
begin
    return frp_buffer_pkg.merchant_street(i_rec_num);
end;

function merchant_region(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_name is
begin
    return frp_buffer_pkg.merchant_region(i_rec_num);
end;

function mcc(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_mcc is
begin
    return frp_buffer_pkg.mcc(i_rec_num);
end;

function terminal_number(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_name is
begin
    return frp_buffer_pkg.terminal_number(i_rec_num);
end;

function card_data_input_mode(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_dict_value is
begin
    return frp_buffer_pkg.card_data_input_mode(i_rec_num);
end;

function card_data_output_cap(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_dict_value is
begin
    return frp_buffer_pkg.card_data_output_cap(i_rec_num);
end;

function pin_presence(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_dict_value is
begin
    return frp_buffer_pkg.pin_presence(i_rec_num);
end;

function oper_amount(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_money is
begin
    return frp_buffer_pkg.oper_amount(i_rec_num);
end;

function oper_currency(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_curr_code is
begin
    return frp_buffer_pkg.oper_currency(i_rec_num);
end;

function oper_date(i_rec_num in com_api_type_pkg.t_count) return date is
begin
    return frp_buffer_pkg.oper_date(i_rec_num);
end;

function card_number(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_card_number is
begin
    return frp_buffer_pkg.card_number(i_rec_num);
end;

';

PACKAGE_TEMPLATE2   constant com_api_type_pkg.t_text :=
'
function execute_check (
    i_check_id          in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id is
    l_result            com_api_type_pkg.t_tiny_id;
begin
    if i_check_id is null then
        l_result := null;
    else
        case i_check_id
        when -1 then l_result := null;  -- fake condition to validate package if no modifiers
';

PACKAGE_TEMPLATE3   constant com_api_type_pkg.t_text  :=
'       else
            com_api_error_pkg.raise_error(
                i_error         => ''CHECK_NOT_FOUND''
              , i_env_param1    => i_check_id
            );
        end case;
    end if;

    return l_result;
end;

end;
';

MATRIX_TEMPLATE     constant com_api_type_pkg.t_text :=
'function matrix_<matrix_id> return com_api_type_pkg.t_tiny_id is
    l_result      com_api_type_pkg.t_tiny_id := 0;
begin
    select nvl(min(matrix_value), 0)
      into l_result
      from frp_matrix_value
     where matrix_id = <matrix_id>
       and x_value   = <x_scale>
       and y_value   = <y_scale>;

    return l_result;
end;

';

EXPR_TEMPLATE       constant com_api_type_pkg.t_text :=
'function expr_<check_id> return com_api_type_pkg.t_tiny_id is
    l_result      com_api_type_pkg.t_tiny_id := com_api_type_pkg.FALSE;
begin
    if <check_expr> 
    then l_result := <check_risk_score>;
    else l_result := com_api_type_pkg.FALSE;
    end if;
    return l_result;
end;

';

ALERT_TEMPLATE      constant com_api_type_pkg.t_text :=
'function alert_<check_id> (
    i_depth  in     com_api_type_pkg.t_tiny_id
) return boolean is
    l_count      com_api_type_pkg.t_short_id := 0;
    l_num_tab    num_tab_tpt  := num_tab_tpt();
begin
    l_num_tab.delete;
    for i in i_depth .. frp_buffer_pkg.auth_id.count loop
        l_num_tab.extend;
        l_num_tab(l_num_tab.last) := auth_id(i);
    end loop;
    
    select count(*)
      into l_count
      from frp_alert a
         , table(cast(l_num_tab as num_tab_tpt)) x
     where a.check_id = <check_id>
       and a.auth_id  = x.column_value;

    return l_count > 0;
end;

';

function get_package_errors return com_api_type_pkg.t_full_desc
is
    cursor l_cur_errors is    
        select e.text
             , e.line
             , e.position
          from user_errors e
         where e.type = 'PACKAGE BODY'
           and e.name = upper(PACKAGE_NAME)
         order by e.sequence desc;

    type t_cur_rec is table of l_cur_errors%rowtype index by pls_integer;
    
    l_errors_descr     com_api_type_pkg.t_text := CRLF;
    l_rec_tab          t_cur_rec;
    i                  pls_integer;
    MAX_LENGTH         constant pls_integer := 2000; -- sizeof(com_api_type_pkg.t_full_desc)
begin
    begin
        open l_cur_errors;
        fetch l_cur_errors bulk collect into l_rec_tab;
        
        i := l_rec_tab.first;
        while i <= l_rec_tab.last and length(l_errors_descr) < MAX_LENGTH loop
            l_errors_descr := l_errors_descr || '(at line: ' || lpad(l_rec_tab(i).line, 4) || '): ' || l_rec_tab(i).text || CRLF;
            i := l_rec_tab.next(i);
        end loop;
        
        close l_cur_errors;

    exception
        when others then
            if l_cur_errors%isopen then
                close l_cur_errors;
            end if;

            trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_package_errors: ' || sqlerrm);
    end;

    return substr(l_errors_descr, 1, MAX_LENGTH);
end;

procedure generate_package is
    l_package_source   clob;
    l_checks_list      clob;
    l_functions_list   clob;
    l_matrix_list      com_api_type_pkg.t_number_tab;
    l_error_message    com_api_type_pkg.t_text;
    
    procedure add_matrix(
        i_matrix_id   in com_api_type_pkg.t_tiny_id
    ) is 
    begin
        if not l_matrix_list.exists(i_matrix_id) then
            l_matrix_list(i_matrix_id) := i_matrix_id;
            select l_functions_list ||
                replace(
                  replace(
                    replace(
                      MATRIX_TEMPLATE, '<x_scale>', x_scale)
                    , '<y_scale>', y_scale)
                  , '<matrix_id>', i_matrix_id)
              into l_functions_list
              from frp_matrix
             where id = i_matrix_id;  
        end if;
    end;
    
begin
    for alert in (
        select id
        from frp_check
    ) loop
        l_functions_list := l_functions_list || replace(ALERT_TEMPLATE, '<check_id>', alert.id);
    end loop;
    
    for matrix in (
        select id 
             , x_scale
             , y_scale
          from frp_matrix  
         where matrix_type = frp_api_const_pkg.MATRIX_TYPE_BOOL_VALUE
    ) loop
        l_functions_list := l_functions_list || replace(replace(replace(MATRIX_TEMPLATE, '<x_scale>', matrix.x_scale), '<y_scale>', matrix.y_scale), '<matrix_id>', matrix.id);
    end loop;
    
    for checks in (
        select id
             , case_id
             , check_type
             , alert_type
             , expression
             , nvl(risk_score, 0) risk_score
             , risk_matrix_id
          from frp_check
         order by case_id, id
    ) loop
        if checks.check_type = frp_api_const_pkg.CHECK_TYPE_MATRIX then
            l_checks_list := l_checks_list ||
                '        when '||checks.id||' then l_result := matrix_'||checks.risk_matrix_id||';'|| chr(13)||chr(10);
            add_matrix(i_matrix_id  => checks.risk_matrix_id);
        elsif checks.check_type = frp_api_const_pkg.CHECK_TYPE_EXPRESSION then
            l_checks_list := l_checks_list ||
                '        when '||checks.id||' then l_result := expr_'||checks.id||';'|| chr(13)||chr(10);
            l_functions_list := l_functions_list ||
                replace(
                  replace(
                    replace(
                      EXPR_TEMPLATE, '<check_id>', checks.id)
                    , '<check_expr>', checks.expression)
                  , '<check_risk_score>', checks.risk_score);
  
        elsif checks.check_type = frp_api_const_pkg.CHECK_TYPE_EXP_MATRIX then
            l_checks_list := l_checks_list ||
                '        when '||checks.id||' then l_result := expr_'||checks.id||' + ' ||
                'matrix_'||checks.risk_matrix_id||';'|| chr(13)||chr(10);
            add_matrix(i_matrix_id  => checks.risk_matrix_id);
            l_functions_list := l_functions_list ||
                replace(
                  replace(
                    replace(
                      EXPR_TEMPLATE, '<check_id>', checks.id)
                    , '<check_expr>', checks.expression)
                  , '<check_risk_score>', checks.risk_score);
        else null;
        end if;

    end loop;

    l_package_source := PACKAGE_TEMPLATE1
                      ||l_functions_list
                      ||PACKAGE_TEMPLATE2
                      ||l_checks_list
                      ||PACKAGE_TEMPLATE3;

    execute immediate l_package_source;

exception
    when others then
        trc_log_pkg.error(lower($$PLSQL_UNIT) || '.generate_package failed with errors:' || get_package_errors());
        com_api_error_pkg.raise_error(
                i_error         => 'INCORRECT_CHECK'
            );
end;

end;
/
