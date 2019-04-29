create or replace package cst_bmed_csc_outgoing_pkg as
/**********************************************************
 * Custom handlers for a process for uploading CSC file
 *
 * Created by Gyumyush D.(gyumyush@bpcbt.com) at 08.09.2016<br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CST_BMED_CSC_OUTGOING_PKG
 * @headcom
 **********************************************************/

procedure export_csc_report(
    i_network_id    in    com_api_type_pkg.t_network_id
  , i_date_type     in    com_api_type_pkg.t_dict_value
  , i_start_date    in    date                             default    null
  , i_end_date      in    date                             default    null
  , i_shift_from    in    com_api_type_pkg.t_tiny_id       default    0
  , i_shift_to      in    com_api_type_pkg.t_tiny_id       default    0
  , i_full_export   in    com_api_type_pkg.t_boolean       default    null
);

end;
/
