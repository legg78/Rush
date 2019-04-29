CREATE OR REPLACE package body crd_ui_event_bunch_type_pkg is

 /********************************************************* 
 *  Interface for Event bunch types  <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 26.07.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: crd_ui_event_bunch_type_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

procedure add_event_bunch_type (
    o_id                    out  com_api_type_pkg.t_tiny_id
  , o_seqnum                out  com_api_type_pkg.t_seqnum
  , i_event_type         in      com_api_type_pkg.t_dict_value
  , i_balance_type       in      com_api_type_pkg.t_dict_value
  , i_bunch_type_id      in      com_api_type_pkg.t_tiny_id
  , i_inst_id            in      com_api_type_pkg.t_inst_id
  , i_add_bunch_type_id  in      com_api_type_pkg.t_tiny_id
) is
begin
    o_id     := crd_event_bunch_type_seq.nextval;
    o_seqnum := 1;
    
    insert into crd_event_bunch_type_vw (
        id
      , seqnum
      , event_type
      , balance_type
      , bunch_type_id
      , inst_id
      , add_bunch_type_id
    ) values (
        o_id
      , o_seqnum
      , i_event_type
      , i_balance_type
      , i_bunch_type_id
      , i_inst_id
      , i_add_bunch_type_id
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_EVENT_BUNCH_TYPE'
          , i_env_param1 => i_event_type
          , i_env_param2 => i_balance_type
          , i_env_param3 => i_bunch_type_id
          , i_env_param4 => i_inst_id
        );      
end;

procedure modify_event_bunch_type (
    i_id                 in      com_api_type_pkg.t_tiny_id
  , io_seqnum            in out  com_api_type_pkg.t_seqnum
  , i_event_type         in      com_api_type_pkg.t_dict_value
  , i_balance_type       in      com_api_type_pkg.t_dict_value
  , i_bunch_type_id      in      com_api_type_pkg.t_tiny_id
  , i_inst_id            in      com_api_type_pkg.t_inst_id
  , i_add_bunch_type_id  in      com_api_type_pkg.t_tiny_id
) is
begin
    update crd_event_bunch_type_vw
       set seqnum            = io_seqnum
         , event_type        = i_event_type
         , balance_type      = i_balance_type 
         , bunch_type_id     = i_bunch_type_id
         , inst_id           = i_inst_id
         , add_bunch_type_id = i_add_bunch_type_id
     where id                = i_id;
            
    io_seqnum := io_seqnum + 1;
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_EVENT_BUNCH_TYPE'
          , i_env_param1 => i_event_type
          , i_env_param2 => i_balance_type
          , i_env_param3 => i_bunch_type_id
          , i_env_param4 => i_inst_id
        );      
end;

procedure remove_event_bunch_type (
    i_id             in      com_api_type_pkg.t_tiny_id
  , i_seqnum         in      com_api_type_pkg.t_seqnum
) is
begin
    update crd_event_bunch_type_vw
       set seqnum = i_seqnum
     where id     = i_id;
            
    delete from crd_event_bunch_type_vw
    where id      = i_id;
end;

end;
/
