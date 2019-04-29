create or replace package crd_api_external_pkg as
/*********************************************************
 *  Credit external statement API  <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 03.04.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: crd_api_external_pkg <br />
 *  @headcom
 **********************************************************/

-- Account's statement
procedure account_statement(
    i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_account_number    in     com_api_type_pkg.t_account_number    default null
  , i_invoice_id        in     com_api_type_pkg.t_medium_id         default null
  , o_ref_cursor           out sys_refcursor
);

function get_tad(
    i_account_id        in     com_api_type_pkg.t_medium_id
  , i_split_hash        in     com_api_type_pkg.t_tiny_id
  , i_last_invoice_date in     date
  , i_total_amount_due  in     com_api_type_pkg.t_money
) return com_api_type_pkg.t_money;

-- Account's statement, filtered by array of account status
procedure account_statement(
    i_inst_id                 in    com_api_type_pkg.t_inst_id
  , i_array_account_status_id in    com_api_type_pkg.t_short_id     default null
  , i_id_type                 in    com_api_type_pkg.t_dict_value   default null
  , i_invoice_date            in    date                            default null
  , o_ref_cursor                out sys_refcursor
);

-- Summary of loyalty points
procedure loyalty_points_sum(
    i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_account_number    in     com_api_type_pkg.t_account_number    default null
  , i_invoice_id        in     com_api_type_pkg.t_medium_id         default null
  , o_ref_cursor           out sys_refcursor
);

-- Summary of limits by credit service
procedure credit_service_limits(
    i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_account_number    in     com_api_type_pkg.t_account_number    default null
  , i_invoice_id        in     com_api_type_pkg.t_medium_id         default null
  , o_ref_cursor           out sys_refcursor
);

-- Account's cards
procedure account_cards(
    i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_account_number    in     com_api_type_pkg.t_account_number    default null
    , i_invoice_id        in     com_api_type_pkg.t_medium_id         default null
    , o_ref_cursor           out sys_refcursor
);

-- Due amounts
procedure due_amounts(
    i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_account_number    in     com_api_type_pkg.t_account_number    default null
    , i_invoice_id        in     com_api_type_pkg.t_medium_id         default null
    , o_ref_cursor           out sys_refcursor
);

-- Transactions
procedure transactions(
    i_inst_id             in     com_api_type_pkg.t_inst_id
    , i_account_number    in     com_api_type_pkg.t_account_number    default null
    , i_invoice_id        in     com_api_type_pkg.t_medium_id         default null
    , i_currency          in     com_api_type_pkg.t_curr_code
    , i_rate_type         in     com_api_type_pkg.t_dict_value
    , o_ref_cursor           out sys_refcursor
);

-- Accounts in collection
procedure accounts_in_collection(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_ids_type          in      com_api_type_pkg.t_dict_value
  , i_account_type      in      com_api_type_pkg.t_dict_value   default acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
  , i_account_status    in      com_api_type_pkg.t_dict_value   default null
  , i_min_aging_period  in      com_api_type_pkg.t_short_id     default null
  , i_eff_date          in      date                            default null
  , o_ref_cursor           out  sys_refcursor
);

end;
/
