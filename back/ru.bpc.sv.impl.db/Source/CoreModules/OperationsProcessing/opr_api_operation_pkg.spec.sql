create or replace package opr_api_operation_pkg is
/************************************************************
 * Provides an API for operate with operation. <br />
 * Last changed by $Author: maslov $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: opr_api_operation_pkg <br />
 * @headcom
 *************************************************************/

procedure get_operation(
    i_oper_id             in  com_api_type_pkg.t_long_id
  , o_operation           out opr_api_type_pkg.t_oper_rec
);

function get_operation(
    i_external_auth_id        in     com_api_type_pkg.t_attr_name
) return opr_api_type_pkg.t_oper_rec;

procedure get_participant(
    i_oper_id             in  com_api_type_pkg.t_long_id
  , i_participaint_type   in  com_api_type_pkg.t_dict_value
  , o_participant         out opr_api_type_pkg.t_oper_part_rec
);

-- This function is used in the matching process only as the "deterministic" function.
function is_credit_operation(
    i_oper_type         in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean deterministic;

-- This function is used in the matching process only as the "deterministic" function.
function is_oper_type_same_group(
    i_a_oper_type         in  com_api_type_pkg.t_dict_value
  , i_b_oper_type         in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean deterministic;                

procedure remove_operation(
    i_oper_id             in  com_api_type_pkg.t_long_id
);

procedure update_oper_amount(
    i_id                in      com_api_type_pkg.t_long_id
  , i_oper_amount       in      com_api_type_pkg.t_money
  , i_oper_currency     in      com_api_type_pkg.t_curr_code
  , i_raise_error       in      com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
);

function check_operations_exist(
    i_card_id    in     com_api_type_pkg.t_medium_id
  , i_start_date in     date
  , i_end_date   in     date
  , i_oper_type  in     com_api_type_pkg.t_dict_value default null
  , i_split_hash in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean;

function check_operations_exist(
    i_object_id    in     com_api_type_pkg.t_long_id
  , i_entity_type  in     com_api_type_pkg.t_dict_value
  , i_split_hash   in     com_api_type_pkg.t_tiny_id
  , i_start_date   in     date
  , i_end_date     in     date
  , i_oper_type    in     com_dict_tpt default null
) return com_api_type_pkg.t_boolean;

procedure link_payment_order(
    i_oper_id_tab       in      com_api_type_pkg.t_long_tab
  , i_payment_order_id  in      com_api_type_pkg.t_long_id
  , i_mask_error        in      com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

end opr_api_operation_pkg;
/
