create or replace package pmo_api_external_pkg is
/**************************************************
 *
 * API for external payments <br />
 * Created by Tkhor A. at 13.09.2018 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_API_EXTERNAL_PKG
 * @headcom
 ****************************************************/

type t_payment_order_rec is record(
     payment_order_id           com_api_type_pkg.t_long_id
   , payment_order_status       com_api_type_pkg.t_dict_value
   , payment_order_number       com_api_type_pkg.t_name
   , purpose_id                 com_api_type_pkg.t_long_id
   , purpose_number             com_api_type_pkg.t_name
   , payment_amount             com_api_type_pkg.t_money
   , payment_currency           com_api_type_pkg.t_curr_code
   , payment_date               date
   , participant_type           com_api_type_pkg.t_dict_value
);

type t_payment_param_rec is record(
     param_name                 com_api_type_pkg.t_name
   , param_value                com_api_type_pkg.t_param_value
);

procedure get_payment_order(
     i_payment_order_id      in com_api_type_pkg.t_long_id
   , o_payment_order        out t_payment_order_rec
   , o_payment_order_params out com_api_type_pkg.t_ref_cur
);

end pmo_api_external_pkg;
/
