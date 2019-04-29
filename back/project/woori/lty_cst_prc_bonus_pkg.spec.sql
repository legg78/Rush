create or replace package lty_cst_prc_bonus_pkg as
/*********************************************************
 *  Process for expired loyalty bonus at Woori bank<br />
 *  Created by Chau Huynh (huynh@bpcbt.com) at 29.08.2017 <br />
 *  Last changed by $Author:$ <br />
 *  $LastChangedDate:: <br />
 *  Revision: $LastChangedRevision: $ <br />
 *  Module: lty_cst_prc_bonus_pkg <br />
 *  @headcom
 **********************************************************/

procedure process_expired_bonus (
    i_inst_id           in  com_api_type_pkg.t_inst_id
  , i_service_id        in  com_api_type_pkg.t_tiny_id
  , i_eff_date          in  date
  , i_rate_type         in  com_api_type_pkg.t_dict_value
  , i_conversion_type   in  com_api_type_pkg.t_dict_value
);

end lty_cst_prc_bonus_pkg;
/
