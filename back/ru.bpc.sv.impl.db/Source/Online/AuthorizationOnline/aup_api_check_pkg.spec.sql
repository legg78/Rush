create or replace package aup_api_check_pkg is
/*********************************************************
 *  API for Authorization online checks <br />
 *  Created by Maslov I  at 06.05.2013 <br />
 *  Last changed by $Author: $ <br />
 *  $LastChangedDate:: #$ <br />
 *  Revision: $LastChangedRevision:  $ <br />
 *  Module: aup_api_check_pkg <br />
 *  @headcom
 **********************************************************/

procedure check_issuing_address(
    i_check_algo        in     com_api_type_pkg.t_dict_value  default null
  , i_card_number       in     com_api_type_pkg.t_card_number
  , i_postal_code       in     com_api_type_pkg.t_postal_code default null
  , i_address           in     com_api_type_pkg.t_name        default null
  , o_resp_code            out com_api_type_pkg.t_dict_value
);

/*
 * Procedure raises an exception if <i_start_date> is greater than <i_end_date>.
 */
procedure check_time_period(
    i_start_date        in     date
  , i_end_date          in     date
);

procedure check_cross_border(
    i_iss_card_number       in     com_api_type_pkg.t_card_number
  , i_acq_card_number       in     com_api_type_pkg.t_card_number     default null
  , i_raise_error           in     com_api_type_pkg.t_boolean         default com_api_const_pkg.TRUE
  , i_acq_inst_id           in     com_api_type_pkg.t_inst_id         default null
  , o_is_cross_border       out    com_api_type_pkg.t_boolean
  , o_application_plugin    out    com_api_type_pkg.t_dict_value
);

end;
/
