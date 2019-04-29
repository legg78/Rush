create or replace package body opr_api_additional_amount_pkg is

g_oper_id               com_api_type_pkg.t_long_id;
g_addl_amounts          com_api_type_pkg.t_amount_by_name_tab;

procedure save_amount_to_cache(
    i_oper_id          in     com_api_type_pkg.t_long_id
  , i_amount_type      in     com_api_type_pkg.t_dict_value
  , i_amount_value     in     com_api_type_pkg.t_money
  , i_currency         in     com_api_type_pkg.t_curr_code
) as
begin
    if g_oper_id is null or g_oper_id != i_oper_id then
        g_oper_id := i_oper_id;
        g_addl_amounts.delete;
    end if;
    g_addl_amounts(i_amount_type).amount := i_amount_value;
    g_addl_amounts(i_amount_type).currency := i_currency;
end save_amount_to_cache;

procedure save_amount(
    i_oper_id          in     com_api_type_pkg.t_long_id
  , i_amount_type      in     com_api_type_pkg.t_dict_value
  , i_amount_value     in     com_api_type_pkg.t_money
  , i_currency         in     com_api_type_pkg.t_curr_code
) as
begin
    trc_log_pkg.debug (
        i_text       => 'Saving additional amount for operation [#1]: type [#2], value [#3], currency [#4]'
      , i_env_param1 => i_oper_id
      , i_env_param2 => i_amount_type
      , i_env_param3 => i_amount_value
      , i_env_param4 => i_currency
    );
    merge into opr_additional_amount d
    using (
        select
            i_oper_id      as oper_id
          , i_amount_type  as amount_type
          , i_amount_value as amount
          , i_currency     as currency
        from
            dual
    ) s
    on (
        d.oper_id = s.oper_id and
        d.amount_type = s.amount_type
    )
    when matched then
        update set
            d.currency = s.currency
          , d.amount   = s.amount
    when not matched then
        insert (
            d.oper_id
          , d.amount_type
          , d.currency
          , d.amount
        ) values (
            s.oper_id
          , s.amount_type
          , s.currency
          , s.amount
        );

    save_amount_to_cache(
        i_oper_id      => i_oper_id
      , i_amount_type  => i_amount_type
      , i_amount_value => i_amount_value
      , i_currency     => i_currency
    );

    opr_api_shared_data_pkg.set_amount(
        i_name         => i_amount_type
      , i_amount       => i_amount_value
      , i_currency     => i_currency
    );
end save_amount;

procedure get_amount(
    i_oper_id          in     com_api_type_pkg.t_long_id
  , i_amount_type      in     com_api_type_pkg.t_dict_value
  , o_amount              out com_api_type_pkg.t_money
  , o_currency            out com_api_type_pkg.t_curr_code
  , i_mask_error       in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_amount     in     com_api_type_pkg.t_money      default null
  , i_error_currency   in     com_api_type_pkg.t_curr_code  default null
) is
begin
    trc_log_pkg.debug(
        i_text          => 'Returning additional amount for operation ID [#1] and amount type [#2]'
      , i_env_param1    => i_oper_id
      , i_env_param2    => i_amount_type
    );
    if g_oper_id = i_oper_id and g_addl_amounts.exists(i_amount_type) then
        o_amount   := g_addl_amounts(i_amount_type).amount;
        o_currency := g_addl_amounts(i_amount_type).currency;
    else
        select currency
             , amount
          into o_currency
             , o_amount
          from opr_additional_amount
         where oper_id = i_oper_id
           and amount_type = i_amount_type;

        save_amount_to_cache(
            i_oper_id      => i_oper_id
          , i_amount_type  => i_amount_type
          , i_amount_value => o_amount
          , i_currency     => o_currency
        );
    end if;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            trc_log_pkg.debug(
                i_text       => 'Reference to undefined additional amount with type [#1] for operation ID [#2]'
              , i_env_param1 => i_amount_type
              , i_env_param2 => i_oper_id
            );
            o_amount := i_error_amount;
            o_currency := i_error_currency;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'REFERENCE_TO_UNDEFINED_ADDITIONAL_AMOUNT'
              , i_env_param1 => i_amount_type
              , i_env_param2 => i_oper_id
            );
        end if;
end get_amount;

/*
 * Procedure reads all additional amounts for an operation from the table.
 */
procedure get_amounts(
    i_oper_id          in     com_api_type_pkg.t_long_id
  , o_amount_tab          out com_api_type_pkg.t_amount_tab
) is
begin
    select amount
         , currency
         , null -- conversion_rate
         , amount_type
      bulk collect into o_amount_tab
      from opr_additional_amount
     where oper_id = i_oper_id;

    trc_log_pkg.debug(
        i_text => 'Additional amounts were read for operation [' || i_oper_id || ']: ' || o_amount_tab.count()
    );
    
    -- Update cache g_addl_amounts that is used in method get_amount()
    if o_amount_tab.count() > 0 then
        g_oper_id := i_oper_id;
        g_addl_amounts.delete;
        for i in 1 .. o_amount_tab.count() loop
            g_addl_amounts(o_amount_tab(i).amount_type).amount   := o_amount_tab(i).amount; 
            g_addl_amounts(o_amount_tab(i).amount_type).currency := o_amount_tab(i).currency; 
        end loop;
    end if;
end get_amounts;

procedure insert_amount(
    i_oper_id              in     com_api_type_pkg.t_long_id
  , i_amount_type_tab      in     com_api_type_pkg.t_dict_tab
  , i_amount_value_tab     in     com_api_type_pkg.t_money_tab
  , i_currency_tab         in     com_api_type_pkg.t_curr_code_tab
) as
begin
    trc_log_pkg.debug (
        i_text       => 'Inserting additional amount for operation [#1]'
      , i_env_param1 => i_oper_id
    );

    forall i in 1 .. i_amount_type_tab.count
        insert into opr_additional_amount (
              oper_id
            , amount_type
            , currency
            , amount
          )
          values (
              i_oper_id
            , i_amount_type_tab(i)
            , i_currency_tab(i)
            , i_amount_value_tab(i)
          );

    for i in 1 .. i_amount_type_tab.count loop
        save_amount_to_cache(
            i_oper_id      => i_oper_id
          , i_amount_type  => i_amount_type_tab(i)
          , i_amount_value => i_amount_value_tab(i)
          , i_currency     => i_currency_tab(i)
        );

        opr_api_shared_data_pkg.set_amount(
            i_name         => i_amount_type_tab(i)
          , i_amount       => i_amount_value_tab(i)
          , i_currency     => i_currency_tab(i)
        );
    end loop;

end insert_amount;

end opr_api_additional_amount_pkg;
/
