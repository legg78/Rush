create or replace package body acm_ui_component_state_pkg as
/********************************************************* 
 *  Interface for component states <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 21.10.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acm_ui_component_state_pkg <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_state(
    i_user_id      in     com_api_type_pkg.t_short_id
  , i_component_id in     com_api_type_pkg.t_name
  , i_state        in     com_api_type_pkg.t_full_desc
) is
begin
    merge into acm_component_state a
    using (select i_user_id user_id
                , i_component_id as component_Id
             from dual) b
       on (a.user_id       = b.user_id
       and a.component_id  = b.component_id)
    when matched then
        update set a.state = i_state
    when not matched then
        insert(id
             , user_id
             , component_id
             , state
            ) values (
               acm_component_state_seq.nextval
             , i_user_id
             , i_component_id
             , i_state
            );

end;

procedure remove_state(
    i_user_id       in     com_api_type_pkg.t_short_id
  , i_component_id  in     com_api_type_pkg.t_name
) is
begin
    delete from acm_component_state
    where user_id      = i_user_id
      and component_id = i_component_id;

end;

end;
/
