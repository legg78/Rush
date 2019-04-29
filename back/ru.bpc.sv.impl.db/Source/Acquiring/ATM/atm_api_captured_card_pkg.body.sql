create or replace package body atm_api_captured_card_pkg as
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
) is
    l_split_hash           com_api_type_pkg.t_tiny_id;
begin
    insert into atm_captured_card(
        auth_id
      , terminal_id
      , coll_id
      ) values (
        i_auth_id
      , i_terminal_id
      , i_coll_id
    );
    
    select split_hash
    into   l_split_hash
    from   acq_terminal
    where  id = i_terminal_id;
    
     evt_api_event_pkg.register_event (
            i_event_type    =>  acq_api_const_pkg.event_terminal_card_captured
          , i_eff_date      =>  com_api_sttl_day_pkg.get_sysdate
          , i_entity_type   =>  acq_api_const_pkg.entity_type_terminal
          , i_object_id     =>  i_terminal_id
          , i_inst_id       =>  ost_api_const_pkg.default_inst
          , i_split_hash    =>  l_split_hash
        );
    
end;

procedure remove_captured_card(
    i_terminal_id   in     com_api_type_pkg.t_short_id
)is
begin
    delete from atm_captured_card
        where terminal_id = i_terminal_id;
    
    trc_log_pkg.info('Captured card in terminal [' || i_terminal_id || '] was cleared');    
    
end;

end;
/
