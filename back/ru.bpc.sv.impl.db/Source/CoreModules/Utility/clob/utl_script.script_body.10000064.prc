declare
    l_count                        com_api_type_pkg.t_count      := 0;
    l_payment_order_number         com_api_type_pkg.t_name;
    l_params                       com_api_type_pkg.t_param_tab;

    cursor cur_pmo_order is
        select *
          from pmo_order
         where payment_order_number is null;
begin
    dbms_output.enable(buffer_size => NULL);

    for o in cur_pmo_order loop
        rul_api_param_pkg.set_param (
            i_value   => o.id
          , i_name    => 'PAYMENT_ORDER_ID'
          , io_params => l_params
        );

        l_payment_order_number := rul_api_name_pkg.get_name (
                i_inst_id             => o.inst_id
              , i_entity_type         => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
              , i_param_tab           => l_params
              , i_double_check_value  => null
            );
        
        update pmo_order set payment_order_number = nvl(l_payment_order_number, to_char(o.id))
         where id = o.id;
         
        l_count := l_count + 1;
    end loop;

    dbms_output.put_line('Script completed. Total payment orders were processed: ' || l_count);
end;

