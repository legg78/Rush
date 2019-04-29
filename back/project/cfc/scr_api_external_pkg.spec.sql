create or replace package scr_api_external_pkg as
/*********************************************************
* Scroing API  <br />
* Created by: Chau Huynh (huynh@bpcbt.com) at 2017-11-21   $ <br />
* Last changed by $Author:                                 $ <br />
* $LastChangedDate:                                        $ <br />
* Revision: $LastChangedRevision:                          $ <br />
* Module: SCR_API_EXTERNAL_PKG <br />
* @headcom
**********************************************************/

procedure add_bucket(
    io_id                   in  out nocopy com_api_type_pkg.t_medium_id
  , i_account_id            in  com_api_type_pkg.t_account_id
  , i_customer_id           in  com_api_type_pkg.t_medium_id
  , i_revised_bucket        in  com_api_type_pkg.t_byte_char
  , i_eff_date              in  date
  , i_expir_date            in  date
  , i_valid_period          in  com_api_type_pkg.t_byte_id
  , i_reason                in  com_api_type_pkg.t_name
  , i_user_id               in  com_api_type_pkg.t_name
);

procedure add_buckets(
    io_id_tab               in  out nocopy com_api_type_pkg.t_medium_tab
  , i_account_id_tab        in  com_api_type_pkg.t_medium_tab
  , i_customer_id_tab       in  com_api_type_pkg.t_medium_tab
  , i_revised_bucket_tab    in  com_api_type_pkg.t_byte_char_tab
  , i_eff_date_tab          in  com_api_type_pkg.t_date_tab
  , i_expir_date_tab        in  com_api_type_pkg.t_date_tab
  , i_valid_period_tab      in  com_api_type_pkg.t_number_tab
  , i_reason_tab            in  com_api_type_pkg.t_name_tab
  , i_user_id_tab           in  com_api_type_pkg.t_name_tab
);

procedure add_buckets(
    io_scr_bucket_tab       in  out nocopy scr_api_type_pkg.t_scr_bucket_tab
);

procedure get_scoring_data(
    i_inst_id               in  com_api_type_pkg.t_inst_id           
  , i_agent_id              in  com_api_type_pkg.t_agent_id     default null
  , i_customer_id           in  com_api_type_pkg.t_medium_id    default null
  , i_account_id            in  com_api_type_pkg.t_account_id   default null
  , o_ref_cursor            out sys_refcursor
);

procedure get_scoring_info_rec(
    io_scr_outgoing_rec     in out nocopy cst_cfc_api_type_pkg.t_scr_outgoing_rec
  , o_scr_info_rec             out nocopy cst_cfc_api_type_pkg.t_scr_info_rec
  , i_start_date            in            date
  , i_end_date              in            date
);

end scr_api_external_pkg;
/
