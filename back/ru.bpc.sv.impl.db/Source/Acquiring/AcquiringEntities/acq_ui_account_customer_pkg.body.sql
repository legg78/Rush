create or replace package body acq_ui_account_customer_pkg as

procedure add_account_customer(
    i_customer_id  in   com_api_type_pkg.t_medium_id
  , i_scheme_id    in   com_api_type_pkg.t_tiny_id
) is
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.add_account_customer: i_customer_id [' || i_customer_id
                                                          || '], i_scheme_id [' || i_scheme_id || ']'
    );
    insert into acq_account_customer_vw(
        customer_id
      , scheme_id
    ) values (
        i_customer_id
      , i_scheme_id
    );
end;

procedure modify_account_customer(
    i_customer_id  in   com_api_type_pkg.t_medium_id
  , i_scheme_id    in   com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_account_customer: ';
begin
    trc_log_pkg.debug(LOG_PREFIX || 'i_customer_id [' || i_customer_id || '], i_scheme_id [' || i_scheme_id || ']');

    merge into acq_account_customer_vw dst
    using (select i_customer_id customer_id from dual) src
    on (dst.customer_id = src.customer_id)
    when matched then update
        set dst.scheme_id = nvl(i_scheme_id, dst.scheme_id)
    when not matched then insert (customer_id, scheme_id)
        values (i_customer_id, i_scheme_id);

    trc_log_pkg.debug(LOG_PREFIX || sql%rowcount || ' rows affected');
end;

procedure remove_account_customer(
    i_customer_id  in   com_api_type_pkg.t_medium_id
  , i_scheme_id    in   com_api_type_pkg.t_tiny_id
) is
begin
    delete from acq_account_customer_vw
    where customer_id = i_customer_id;
end;


end;
/
