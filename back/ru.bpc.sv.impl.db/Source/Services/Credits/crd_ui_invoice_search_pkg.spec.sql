create or replace package crd_ui_invoice_search_pkg as
/************************************************************
 * The API for search in invoice forms <br />
 * Created by Gogolev I. (i.gogolev@bpcbt.com)  at 11.01.2017 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CRD_UI_INVOICE_SEARCH_PKG <br />
 * @headcom
 ************************************************************/
 
procedure get_interest_details(
    o_ref_cur           out        com_api_type_pkg.t_ref_cur
  , i_account_id         in        com_api_type_pkg.t_account_id
  , i_invoice_id         in        com_api_type_pkg.t_long_id
  , i_sorting_tab        in        com_param_map_tpt
);

procedure get_interest_details_count(
    o_row_count         out        com_api_type_pkg.t_medium_id
  , i_account_id         in        com_api_type_pkg.t_account_id
  , i_invoice_id         in        com_api_type_pkg.t_long_id
);

end crd_ui_invoice_search_pkg;
/
