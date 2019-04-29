create or replace package body cst_cab_com_pkg as

function get_main_card_id (
    i_account_id     in     com_api_type_pkg.t_account_id
  , i_split_hash     in     com_api_type_pkg.t_tiny_id default null
) return com_api_type_pkg.t_medium_id
is
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_main_card_id          com_api_type_pkg.t_medium_id;
begin
    l_split_hash := i_split_hash;

    if l_split_hash is null then
        l_split_hash :=
            com_api_hash_pkg.get_split_hash (
                i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id   => i_account_id
            );
    end if;

    select t.id
      into l_main_card_id
      from (
            select c.id
                 , row_number() over (order by
                                      case
                                          when c.category = iss_api_const_pkg.CARD_CATEGORY_PRIMARY   then 1
                                          when c.category = iss_api_const_pkg.CARD_CATEGORY_DOUBLE    then 2
                                          when c.category = iss_api_const_pkg.CARD_CATEGORY_UNDEFINED then 3
                                          when c.category = iss_api_const_pkg.CARD_CATEGORY_VIRTUAL   then 4
                                      end) as seqnum
              from iss_card_vw c
                 , acc_account_object ao
             where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
               and ao.object_id = c.id
               and ao.account_id = i_account_id
               and ao.split_hash = l_split_hash
           ) t
     where t.seqnum = 1;

    return l_main_card_id;
end get_main_card_id;

function format_amount (
    i_amount         in     com_api_type_pkg.t_money
  , i_curr_code      in     com_api_type_pkg.t_curr_code
  , i_add_curr_name  in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_use_separator  in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_mask_error     in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name
is
    l_format_base           com_api_type_pkg.t_name;
    l_result                com_api_type_pkg.t_name;
begin

    if i_use_separator = com_api_type_pkg.TRUE then
        l_format_base := 'FM999,999,999,999,990';
    else
        l_format_base := 'FM999999999999990';
    end if;

    if i_amount is not null then -- return null if i_amount is null
        select to_char(
                        round(i_amount) / power(10, exponent)
                      , l_format_base || case
                                             when exponent > 0
                                             then '.' || rpad('0', exponent, '0')
                                             else null
                                         end
                      )
               || case
                      when i_add_curr_name = com_api_type_pkg.FALSE
                      then ' ' || name
                      else ''
                  end
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
end format_amount;

function get_overdue_days(
    i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id      default null
) return com_api_type_pkg.t_tiny_id
is
    l_last_invoice              crd_api_type_pkg.t_invoice_rec;
    l_last_overdue_date         date;
    l_overdue_amount            com_api_type_pkg.t_money;
    l_available_bal             com_api_type_pkg.t_money;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_day_count                 com_api_type_pkg.t_tiny_id;
    l_is_migrated_acc           com_api_type_pkg.t_tiny_id;
    l_exceed_limit              com_api_type_pkg.t_amount_rec;
begin
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => i_account_id
                        );
    else
        l_split_hash := i_split_hash;
    end if;

    l_exceed_limit :=
        acc_api_balance_pkg.get_balance_amount (
            i_account_id    => i_account_id
          , i_balance_type  => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
          , i_mask_error    => com_api_const_pkg.TRUE
          , i_lock_balance  => com_api_const_pkg.FALSE
        );    

    l_available_bal := 
        acc_api_balance_pkg.get_aval_balance_amount_only(
            i_account_id    => i_account_id
        );
        
    if l_available_bal >= l_exceed_limit.amount then --All debts are fully paid
        l_day_count := 0;
    else
        l_last_invoice := crd_invoice_pkg.get_last_invoice(
                              i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                            , i_object_id       => i_account_id
                            , i_split_hash      => l_split_hash
                            , i_mask_error      => com_api_const_pkg.TRUE
                          );     

        -- Check if account is migration account    
        select count(1)
          into l_is_migrated_acc
          from acc_account a
             , cst_cab_acc_mig m
         where a.account_number = m.sv_acc
           and a.id = i_account_id;
        
        if l_is_migrated_acc > 0 then
            -- For migrated accounts
            case l_last_invoice.aging_period
                when 0 then l_day_count := 0;
                when 1 then l_day_count := 30;
                when 2 then l_day_count := 60;
                when 3 then l_day_count := 90;
                when 4 then l_day_count := 120;
                when 5 then l_day_count := 150;
                when 6 then l_day_count := 180;
                when 7 then l_day_count := 210;
                when 8 then l_day_count := 240;
                when 9 then l_day_count := 270;
                when 10 then l_day_count := 300;
                when 11 then l_day_count := 330;
                when 12 then l_day_count := 360;
                else l_day_count := 390;
            end case;
        else
           --For new accounts in SV
            select nvl(sum(b.amount), 0)
              into l_overdue_amount
              from crd_debt d
                 , crd_debt_balance b
             where d.id = b.debt_id
               and d.is_new = com_api_const_pkg.FALSE
               and decode(d.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, d.account_id, null) = i_account_id
               and b.balance_type in (crd_api_const_pkg.BALANCE_TYPE_OVERDUE            --'BLTP1004'
                                    , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST   --'BLTP1005'
                                    )
               and d.split_hash = l_split_hash
               and b.split_hash = l_split_hash;

            if l_overdue_amount = 0 then
                l_day_count := 0;
            else
                select max(overdue_date)
                  into l_last_overdue_date
                  from crd_invoice
                 where split_hash = l_split_hash
                   and account_id = i_account_id
                   and aging_period = 0;
                l_day_count := greatest(trunc(get_sysdate) - trunc(l_last_overdue_date), 0);
            end if;
        end if;
    end if;
    return l_day_count;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.get_overdue_days, i_account_id = [#1], No_data_found!'
          , i_env_param1 => i_account_id
        );
        return 0;
end get_overdue_days;

function get_card_fee_tier(
    i_card_id           in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_dict_value
as
    l_fee_tier    com_api_type_pkg.t_dict_value;
begin
    l_fee_tier :=
        com_api_flexible_data_pkg.get_flexible_value(
            i_field_name    => cst_cab_api_const_pkg.CARD_FEE_TIER
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => i_card_id
        );

    return l_fee_tier;
end;

end cst_cab_com_pkg;
/
