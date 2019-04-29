create or replace package body pmo_ui_template_pkg as
/************************************************************
 * UI for Payment Order Templates<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 18.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_ui_template_pkg <br />
 * @headcom
 ************************************************************/

procedure add(
    o_id                   out com_api_type_pkg.t_long_id
  , i_customer_id       in     com_api_type_pkg.t_medium_id     default null
  , i_purpose_id        in     com_api_type_pkg.t_short_id
  , i_status            in     com_api_type_pkg.t_dict_value
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_is_prepared_order in     com_api_type_pkg.t_boolean
  , i_label             in     com_api_type_pkg.t_short_desc
  , i_description       in     com_api_type_pkg.t_full_desc
  , i_entity_type       in     com_api_type_pkg.t_dict_value    default null
  , i_object_id         in     com_api_type_pkg.t_long_id       default null
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_amount            in     com_api_type_pkg.t_money         default null
  , i_currency          in     com_api_type_pkg.t_curr_code     default null
) is
    l_split_hash               com_api_type_pkg.t_tiny_id;
    l_count                    com_api_type_pkg.t_long_id;
    l_payment_order_number     com_api_type_pkg.t_name;
    l_params                   com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text       => 'pmo_ui_template_pkg.add start i_customer_id [#1], i_purpose_id [#2], i_status [#3], i_entity_type [#4], i_object_id [#5], i_is_prepared_order [#6]'
      , i_env_param1 => i_customer_id
      , i_env_param2 => i_purpose_id
      , i_env_param3 => i_status
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
      , i_env_param6 => i_is_prepared_order
    );

    select count(1)
      into l_count
      from pmo_purpose_vw
     where id = i_purpose_id;
    
    if l_count = 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'PAYMENT_PURPOSE_NOT_EXISTS'
          , i_env_param1 => i_purpose_id
        );
    end if;

    o_id := com_api_id_pkg.get_id(pmo_order_seq.nextval);
    trc_log_pkg.debug(
        i_text       => 'pmo_ui_template_pkg.add order id [#1]'
      , i_env_param1 => o_id
    );

    if i_customer_id is not null then
        l_split_hash := com_api_hash_pkg.get_split_hash(
            i_entity_type  => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id    => i_customer_id
        );
    else
        l_split_hash := com_api_hash_pkg.get_split_hash(
            i_value => o_id
        );
    end if;
    
    rul_api_param_pkg.set_param (
        i_value   => o_id
      , i_name    => 'PAYMENT_ORDER_ID'
      , io_params => l_params
    );

    l_payment_order_number := rul_api_name_pkg.get_name (
            i_inst_id             => i_inst_id
          , i_entity_type         => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
          , i_param_tab           => l_params
          , i_double_check_value  => null
        );
    trc_log_pkg.debug(
        i_text       => 'l_payment_order_number=' || l_payment_order_number);

    insert into pmo_order_vw(
        id
      , customer_id
      , purpose_id
      , templ_status
      , inst_id
      , is_template
      , is_prepared_order
      , split_hash
      , entity_type
      , object_id
      , amount           
      , currency         
      , payment_order_number
    ) values (
        o_id
      , i_customer_id
      , i_purpose_id
      , i_status
      , i_inst_id
      , com_api_const_pkg.TRUE
      , i_is_prepared_order
      , l_split_hash
      , i_entity_type
      , i_object_id
      , i_amount           
      , i_currency         
      , l_payment_order_number
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_order'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_text         => i_label
      , i_lang         => i_lang
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_order'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
    );
    trc_log_pkg.debug(
        i_text       => 'pmo_ui_template_pkg.add END'
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
            i_error         => 'PAYMENT_ORDER_NUMBER_NOT_UNIQUE'
          , i_env_param1    => l_payment_order_number
        );

end;

procedure modify(
    i_id                in     com_api_type_pkg.t_long_id
  , i_customer_id       in     com_api_type_pkg.t_medium_id
  , i_purpose_id        in     com_api_type_pkg.t_short_id
  , i_status            in     com_api_type_pkg.t_dict_value
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_is_prepared_order in     com_api_type_pkg.t_boolean
  , i_label             in     com_api_type_pkg.t_short_desc
  , i_description       in     com_api_type_pkg.t_full_desc
  , i_entity_type       in     com_api_type_pkg.t_dict_value    default null
  , i_object_id         in     com_api_type_pkg.t_long_id       default null
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_amount            in     com_api_type_pkg.t_money         default null
  , i_currency          in     com_api_type_pkg.t_curr_code     default null
) is
begin
    update pmo_order_vw
       set purpose_id        = i_purpose_id
         , templ_status      = i_status
         , is_prepared_order = i_is_prepared_order
         , amount            = i_amount             
         , currency          = i_currency
         , entity_type       = i_entity_type
         , object_id         = i_object_id
     where id                = i_id;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_order'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_text         => i_label
      , i_lang         => i_lang
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_order'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
    );
end;

procedure remove(
    i_id              in     com_api_type_pkg.t_long_id
) is
begin
    for rec in (
        select id
          from pmo_order_data_vw
         where order_id = i_id
    ) loop
        pmo_ui_template_data_pkg.remove(
            i_id => rec.id
        );
    end loop;

    for r in (
        select id schedule_id
             , seqnum
          from pmo_schedule
         where order_id = i_id
    ) loop
        pmo_ui_schedule_pkg.remove(
            i_id       => r.schedule_id
          , i_seqnum   => r.seqnum 
        );
    end loop;
    
    com_api_i18n_pkg.remove_text(
        i_table_name => 'pmo_order'
      , i_object_id  => i_id
    );

    delete pmo_order_vw
     where id = i_id;

end;

end pmo_ui_template_pkg;
/
