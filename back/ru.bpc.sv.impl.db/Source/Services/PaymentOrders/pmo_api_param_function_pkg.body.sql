create or replace package body pmo_api_param_function_pkg as
/************************************************************
 * Functions are used for calculation real values of <br />
 * payment order parameters. Like rules, they use <br />
 * shared caches to get incoming parameters. All <br />
 * necessary cache data should be loaded before usage <br />
 * of these functions. Functions always return value <br />
 * of type com_api_type_pkg.t_param_value.<br />
 * Created by Gerbeev I.(gerbeev@bpc.ru) at 11.04.2018  <br />
 * Last changed by $Author: gerbeev $ <br />
 * $LastChangedDate:: 2018-04-11 11:00:00 +0400#$ <br />
 * Revision: $LastChangedRevision: $ <br />
 * Module: pmo_api_param_function_pkg <br />
 * @headcom
 ************************************************************/

procedure set_param(
    i_name              in      com_api_type_pkg.t_name
  , i_value             in      com_api_type_pkg.t_param_value
) is
begin
    g_order_params(i_name)  := i_value;
end set_param;

procedure clear_params
is
begin
    g_invoice := null;
    g_order_params.delete;
end clear_params;

procedure set_invoice(
    i_account_id        in     com_api_type_pkg.t_medium_id
) is
    l_split_hash               com_api_type_pkg.t_tiny_id;
begin
    l_split_hash :=
        com_api_hash_pkg.get_split_hash(
            i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id   => i_account_id
          , i_mask_error  => com_api_const_pkg.FALSE
        );
    g_invoice := crd_invoice_pkg.get_last_invoice(
        i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
      , i_split_hash        => l_split_hash
      , i_mask_error        => com_api_const_pkg.FALSE
    );

end set_invoice;

procedure load_order_params(
    i_order_id          in      com_api_type_pkg.t_short_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.load_order_params';
    l_payment_order_rec         pmo_api_type_pkg.t_payment_order_rec;
begin
    trc_log_pkg.debug(
        'load_order_params start for ' || i_order_id
    );
    clear_params;
    g_order_params := i_param_tab;

    l_payment_order_rec :=
        pmo_api_order_pkg.get_order(i_order_id => i_order_id);
    set_param(
        i_name  => 'PAYMENT_ORDER_ID'
      , i_value => l_payment_order_rec.id
    );
    set_param(
        i_name  => 'ENTITY_TYPE'
      , i_value => l_payment_order_rec.entity_type
    );
    set_param(
        i_name  => 'OBJECT_ID'
      , i_value => l_payment_order_rec.object_id
    );
    set_param(
        i_name  => 'PURPOSE_ID'
      , i_value => l_payment_order_rec.purpose_id
    );
    set_param(
        i_name  => 'TEMPLATE_ID'
      , i_value => l_payment_order_rec.template_id
    );
    set_param(
        i_name  => 'ORDER_DATE'
      , i_value => l_payment_order_rec.event_date
    );
    trc_log_pkg.debug(
        'load_order_params END'
    );
end load_order_params;

function get_due_date
return com_api_type_pkg.t_short_desc
is
    LOG_PREFIX         constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.get_due_date';
begin
    if g_order_params('ENTITY_TYPE') = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        if g_invoice.id is null then
            set_invoice(
                i_account_id => g_order_params('OBJECT_ID')
            );
        end if;
    return to_char(g_invoice.due_date, com_api_const_pkg.DATE_FORMAT);
    else
        trc_log_pkg.error(
            i_text          => 'PMO_WRONG_PARAM_FUNCTION_CONFIGURATION'
          , i_env_param1    => LOG_PREFIX
          , i_env_param2    => g_order_params('ENTITY_TYPE')
        );
        return null;
    end if;
end get_due_date;

function get_mad
return com_api_type_pkg.t_short_desc
is
    LOG_PREFIX         constant com_api_type_pkg.t_name             := lower($$PLSQL_UNIT) || '.get_mad';
begin
    if g_order_params('ENTITY_TYPE') = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        if g_invoice.id is null then
            set_invoice(
                i_account_id => g_order_params('OBJECT_ID')
            );
        end if;
        return to_char(g_invoice.min_amount_due, com_api_const_pkg.NUMBER_FORMAT);
    else
        trc_log_pkg.error(
            i_text          => 'PMO_WRONG_PARAM_FUNCTION_CONFIGURATION'
          , i_env_param1    => LOG_PREFIX
          , i_env_param2    => g_order_params('ENTITY_TYPE')
        );
        return null;
    end if;
end get_mad;

function get_account_number
return com_api_type_pkg.t_short_desc
is
    LOG_PREFIX         constant com_api_type_pkg.t_name             := lower($$PLSQL_UNIT) || '.get_due_date';
begin
    if g_order_params('ENTITY_TYPE') = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        if g_invoice.id is null then
            set_invoice(
                i_account_id => g_order_params('OBJECT_ID')
            );
        end if;
        return acc_api_account_pkg.get_account_number(
                   i_account_id    =>  g_order_params('OBJECT_ID')
               );
    else
        trc_log_pkg.error(
            i_text          => 'PMO_WRONG_PARAM_FUNCTION_CONFIGURATION'
          , i_env_param1    => LOG_PREFIX
          , i_env_param2    => g_order_params('ENTITY_TYPE')
        );
        return null;
    end if;
end get_account_number;

function get_card_number
return com_api_type_pkg.t_short_desc
is
    LOG_PREFIX         constant com_api_type_pkg.t_name             := lower($$PLSQL_UNIT) || '.get_card_number';
    l_card_rec                  iss_api_type_pkg.t_card_rec;
begin
    if g_order_params('ENTITY_TYPE') = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        if g_invoice.id is null then
            set_invoice(
                i_account_id => g_order_params('OBJECT_ID')
            );
        end if;

        l_card_rec := iss_api_card_pkg.get_card(
            i_account_id => g_order_params('OBJECT_ID')
        )(1);

        return to_char(l_card_rec.id, com_api_const_pkg.NUMBER_FORMAT);
    else
        trc_log_pkg.error(
            i_text          => 'PMO_WRONG_PARAM_FUNCTION_CONFIGURATION'
          , i_env_param1    => LOG_PREFIX
          , i_env_param2    => g_order_params('ENTITY_TYPE')
        );
        return null;
    end if;
end get_card_number;

function get_purpose_text
return com_api_type_pkg.t_short_desc
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_purpose_text: ';
    l_template_id      com_api_type_pkg.t_long_id;
    l_result           com_api_type_pkg.t_short_desc; 
begin
    l_template_id := g_order_params('TEMPLATE_ID');
    
    l_result := get_text('PMO_ORDER', 'LABEL', l_template_id) || ', ' 
       || get_object_desc(g_order_params('ENTITY_TYPE'), g_order_params('OBJECT_ID')) || ', ' 
       || g_order_params('ORDER_DATE');

    trc_log_pkg.debug(
        i_text  => LOG_PREFIX || l_result
    );
    return l_result;                
end get_purpose_text;

end pmo_api_param_function_pkg;
/
