create or replace package pmo_prc_schedule_pkg as
/************************************************************
 * process for Payment Order shedule<br />
 * Created by Fomichev A.(fomichev@bpcbt.com)  at 18.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_prc_schedule_pkg <br />
 * @headcom
 ************************************************************/

/**
*   Payment order scheduler processing
*   @param i_order_status - Status of created order
*   @param i_register_event - True if register event
*   @param i_purpose_id - use only for institution based templates w/o schedule and with subscription
*/
procedure process(
    i_order_status      in com_api_type_pkg.t_dict_value    default pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
  , i_register_event    in com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_purpose_id        in com_api_type_pkg.t_long_id       default null
);

end;
/
