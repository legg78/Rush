create or replace package atm_api_captured_card_pkg as
/********************************************************* 
 *  Api for captured cards <br> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 11.04.2012  <br> 
 *  Last changed by $Author$ <br>
 *  $LastChangedDate::                           $  <br>
 *  Revision: $LastChangedRevision$ <br>
 *  Module: atm_api_captured_card_pkg  <br>
 *  @headcom
 **********************************************************/ 
  
procedure add_captured_card(
    i_auth_id       in     com_api_type_pkg.t_long_id
  , i_terminal_id   in     com_api_type_pkg.t_short_id
  , i_coll_id       in     com_api_type_pkg.t_long_id
);

procedure remove_captured_card(
    i_terminal_id   in     com_api_type_pkg.t_short_id
);

end;
/
