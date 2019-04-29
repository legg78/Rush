create or replace package body pmo_api_external_pkg is

procedure get_payment_order(
    i_payment_order_id      in com_api_type_pkg.t_long_id
  , o_payment_order        out t_payment_order_rec
  , o_payment_order_params out com_api_type_pkg.t_ref_cur
) is

begin

    for cur in 
        (select po.id
              , po.status
              , po.payment_order_number
              , po.purpose_id
              , pr.purpose_number
              , po.amount
              , po.currency
              , po.event_date
              , pt.participant_type
           from pmo_order po
              , opr_participant pt
              , pmo_purpose pr
          where po.id         = pt.oper_id
            and po.id         = i_payment_order_id
            and po.purpose_id = pr.id
        )
    loop
        o_payment_order := cur;
        exit;
    end loop;

    if o_payment_order.payment_order_id is not null then
        open o_payment_order_params for
      select par.param_name, od.param_value
        from pmo_order_data od
           , pmo_parameter par
       where od.param_id = par.id
         and od.order_id = o_payment_order.payment_order_id;
    end if;

end get_payment_order;

end pmo_api_external_pkg;
/
