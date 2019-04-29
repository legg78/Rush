create or replace package body itf_cst_integration_pkg as

procedure get_remote_banking_activity(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , o_banking_activity     out      com_api_type_pkg.t_boolean
) is
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_count                 com_api_type_pkg.t_tiny_id;
    l_sysdate               date;
begin
    o_banking_activity := com_api_const_pkg.TRUE;
    
    if i_customer_number is not null then
        l_customer_id := prd_api_customer_pkg.get_customer_id(
                             i_customer_number => i_customer_number
                           , i_inst_id         => i_inst_id
                           , i_mask_error      => com_api_type_pkg.FALSE
                         );

        l_sysdate := get_sysdate;

        select count(1)
          into l_count
          from acc_account a
             , acc_balance b
             , crd_invoice i
         where a.customer_id    = l_customer_id
           and b.account_id     = a.id
           and b.balance_type   = acc_api_const_pkg.BALANCE_TYPE_OVERDUE
           and b.balance       != 0
           and i.id             = crd_invoice_pkg.get_last_invoice_id(
                                      i_account_id        => a.id
                                    , i_split_hash        => null
                                    , i_mask_error        => com_api_const_pkg.TRUE
                                  )
           and (i.aging_period >= 3
                or i.aging_period >= 2
               and l_sysdate >= i.overdue_date
               );

        if l_count != 0 then
            o_banking_activity := com_api_const_pkg.FALSE;
        end if;
    end if;
end get_remote_banking_activity;

end;
/
