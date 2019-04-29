create or replace package body crd_cst_invoice_pkg as

procedure get_aging_period(
    i_last_invoice_id       in      com_api_type_pkg.t_medium_id
  , o_aging_period             out  com_api_type_pkg.t_tiny_id
  , o_serial_number            out  com_api_type_pkg.t_tiny_id
  , i_aging_algorithm       in      com_api_type_pkg.t_dict_value default null
) is
    l_aging_algorithm               com_api_type_pkg.t_dict_value;
begin
    l_aging_algorithm   := nvl(i_aging_algorithm, crd_api_const_pkg.ALGORITHM_AGING_DEFAULT);
    o_aging_period      := 0;
    o_serial_number     := 1;

    if i_last_invoice_id is not null then
        select case when l_aging_algorithm = crd_api_const_pkg.ALGORITHM_AGING_INDEPENDENT then aging_period
                    when is_mad_paid = com_api_const_pkg.TRUE then 0
                    when is_tad_paid = com_api_const_pkg.TRUE then 0
                    else aging_period + 1
               end
             , serial_number + 1
          into o_aging_period
             , o_serial_number
          from crd_invoice
         where id           = i_last_invoice_id;
    end if;

exception
    when no_data_found then
        o_aging_period  := 0;
        o_serial_number := 1;

end;

end;
/
