create or replace package lty_ui_lottery_tickets_pkg as
/*********************************************************
 *  Loyalty - Lottery tickets UI <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 07.04.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: lty_ui_lottery_tickets_pkg <br />
 *  @headcom
 **********************************************************/
 
procedure add_lottery_ticket(
    o_id                   out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_split_hash        in      com_api_type_pkg.t_tiny_id       default null
  , i_customer_id       in      com_api_type_pkg.t_medium_id     default null
  , i_card_id           in      com_api_type_pkg.t_medium_id     default null
  , i_service_id        in      com_api_type_pkg.t_short_id      default null
  , i_ticket_number     in      com_api_type_pkg.t_name          default null
  , i_registration_date in      date                             default null
  , i_status            in      com_api_type_pkg.t_dict_value    default lty_api_const_pkg.LOTTERY_TICKET_ACTIVE
  , i_inst_id           in      com_api_type_pkg.t_inst_id       default null
);

procedure modify_lottery_ticket(
    i_id                in      com_api_type_pkg.t_long_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_status            in      com_api_type_pkg.t_dict_value    default null
);

procedure remove_lottery_ticket(
    i_id                in      com_api_type_pkg.t_long_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

end;
/
