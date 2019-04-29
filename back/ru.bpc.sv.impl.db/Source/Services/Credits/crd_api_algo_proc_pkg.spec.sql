create or replace package crd_api_algo_proc_pkg is
/*********************************************************
*  Credit algorithms procedures and related API <br />
*  Created by Alalykin A. (alalykin@bpcbt.com) at 20.12.2018 <br />
*  Module: CRD_API_ALGO_PROC_PKG <br />
*  @headcom
**********************************************************/

procedure clear_shared_data;

function get_param_num(
    i_name                    in            com_api_type_pkg.t_name
  , i_mask_error              in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value             in            com_api_type_pkg.t_name       default null
) return number;

function get_param_date(
    i_name                    in            com_api_type_pkg.t_name
  , i_mask_error              in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value             in            com_api_type_pkg.t_name       default null
) return date;

function get_param_char(
    i_name                    in            com_api_type_pkg.t_name
  , i_mask_error              in            com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value             in            com_api_type_pkg.t_name       default null
) return com_api_type_pkg.t_param_value;

procedure set_param(
    i_name                    in            com_api_type_pkg.t_name
  , i_value                   in            com_api_type_pkg.t_name
);

procedure set_param(
    i_name                    in            com_api_type_pkg.t_name
  , i_value                   in            number
);

procedure set_param(
    i_name                    in            com_api_type_pkg.t_name
  , i_value                   in            date
);

function get_account return acc_api_type_pkg.t_account_rec;

/*
 * Modification of MAD and/or additional actions when creating an invoice due to specific MAD algorithm.
 */
procedure process_mad_when_invoice(
    i_account_id              in            com_api_type_pkg.t_account_id
  , i_product_id              in            com_api_type_pkg.t_short_id
  , i_service_id              in            com_api_type_pkg.t_short_id
  , i_eff_date                in            date
  , i_invoice_id              in            com_api_type_pkg.t_medium_id
  , i_aging_period            in            com_api_type_pkg.t_tiny_id
  , i_mad                     in            com_api_type_pkg.t_money
  , i_tad                     in            com_api_type_pkg.t_money
  , i_overdraft_balance       in            com_api_type_pkg.t_money            default null
  , o_mad                        out        com_api_type_pkg.t_money
);

/*
 * Modification of MAD and/or additional actions on processing (applying) a payment due to specific MAD algorithm.
 */
procedure process_mad_when_payment(
    i_account_id              in            com_api_type_pkg.t_account_id
  , i_split_hash              in            com_api_type_pkg.t_tiny_id
  , i_inst_id                 in            com_api_type_pkg.t_inst_id
  , i_product_id              in            com_api_type_pkg.t_short_id
  , i_service_id              in            com_api_type_pkg.t_short_id
  , i_eff_date                in            date
  , i_payment_amount          in            com_api_type_pkg.t_money
);

/*
 * Checking possibility of resetting aging on executing rule <Reset aging period> due to specific MAD algorithm.
 */
function check_reset_aging(
    io_invoice                in out nocopy crd_api_type_pkg.t_invoice_rec
  , i_eff_date                in            date
  , i_event_type              in            com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean;

/*
 * Modification of MAD and/or additional actions on checking the overdue due to specific MAD algorithm.
 */
procedure process_mad_when_overdue(
    i_account_id              in            com_api_type_pkg.t_account_id
  , i_product_id              in            com_api_type_pkg.t_short_id
  , i_service_id              in            com_api_type_pkg.t_short_id
  , i_eff_date                in            date
  , i_invoice_id              in            com_api_type_pkg.t_medium_id
  , i_total_payment_amount    in            com_api_type_pkg.t_money
  , i_tolerance_amount        in            com_api_type_pkg.t_money
  , io_mad                    in out        com_api_type_pkg.t_money
  , o_make_tad_equal_mad         out        com_api_type_pkg.t_boolean
);

/*
 * Additional information for using on GUI (form Account, tab Credit details) due to specific MAD algorithm.
 */
function get_additional_ui_info(
    i_account_id              in            com_api_type_pkg.t_account_id
  , i_product_id              in            com_api_type_pkg.t_short_id
  , i_service_id              in            com_api_type_pkg.t_short_id
  , i_eff_date                in            date
) return com_api_type_pkg.t_param_value;

-- Algorithms procedures

/* 
 * MAD modification procedure, it is intended to be used as a algorithm procedure
 * with MAD calculation algorithm ALGORITHM_MAD_CALC_THRESHOLD.
 */
procedure mad_algorithm_threshold;

end;
/
