create or replace package scr_api_type_pkg is
/*********************************************************
 *  API for types of scoring <br />
 *  Created by Chau Huynh (huynh@bpcbt.com) at 2017-11-21 <br />
 *  Module: SCR_API_TYPE_PKG  <br />
 *  @headcom
 **********************************************************/
type t_scr_bucket_rec is record (
    id                com_api_type_pkg.t_medium_id
  , account_id        com_api_type_pkg.t_account_id
  , customer_id       com_api_type_pkg.t_medium_id
  , revised_bucket    com_api_type_pkg.t_byte_char
  , eff_date          date
  , expir_date        date
  , valid_period      com_api_type_pkg.t_byte_id
  , reason            com_api_type_pkg.t_short_desc
  , user_id           com_api_type_pkg.t_name
);

type t_scr_bucket_tab is table of t_scr_bucket_rec index by binary_integer;

end scr_api_type_pkg;
/
