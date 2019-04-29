create or replace package body acc_ui_gl_account_pkg is
/********************************************************* 
 *  UI for GL Accounts   <br /> 
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 19.03.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module:g  <br /> 
 *  @headcom 
 **********************************************************/
procedure create_gl_accounts (
    i_entity_type  in     com_api_type_pkg.t_dict_value
  , i_currency     in     com_api_type_pkg.t_curr_code
  , i_object_id    in     com_api_type_pkg.t_short_id
) is
    l_inst_id      com_api_type_pkg.t_inst_id;
    l_agent_id     com_api_type_pkg.t_agent_id;
begin
    if i_entity_type = 'ENTTINST' then
        l_inst_id := i_object_id;
    elsif i_entity_type = 'ENTTAGNT' then
        select inst_id
          into l_inst_id
          from ost_agent
         where id = i_object_id;
                
        l_agent_id := i_object_id;
    else
        return;
    end if;
        
    acc_api_account_pkg.create_gl_accounts (
        i_entity_type => i_entity_type
      , i_currency    => i_currency
      , i_inst_id     => l_inst_id                    
      , i_agent_id    => l_agent_id
    );
end;
    
procedure create_gl_account (
    o_id                 out com_api_type_pkg.t_medium_id
  , io_account_number in out com_api_type_pkg.t_account_number
  , i_entity_type     in     com_api_type_pkg.t_dict_value
  , i_account_type    in     com_api_type_pkg.t_dict_value
  , i_currency        in     com_api_type_pkg.t_curr_code
  , i_object_id       in     com_api_type_pkg.t_short_id
) is
    l_inst_id                com_api_type_pkg.t_inst_id;
    l_agent_id               com_api_type_pkg.t_agent_id;
begin
    if i_entity_type = 'ENTTINST' then
        l_inst_id := i_object_id;
    elsif i_entity_type = 'ENTTAGNT' then
        select inst_id
          into l_inst_id
          from ost_agent
         where id = i_object_id;

        l_agent_id := i_object_id;
    else
        return;
    end if;
        
    acc_api_account_pkg.create_gl_account (
        o_id               => o_id
      , io_account_number  => io_account_number
      , i_entity_type      => i_entity_type
      , i_account_type     => i_account_type
      , i_currency         => i_currency
      , i_inst_id          => l_inst_id
      , i_agent_id         => l_agent_id
    );
end;

procedure remove_gl_account(
    i_account_id            in      com_api_type_pkg.t_medium_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id      default null
) is
begin
    acc_api_account_pkg.remove_account(
        i_account_id            => i_account_id
      , i_split_hash            => i_split_hash
    );
    
    dbms_mview.refresh('acc_gl_account_mvw');
end;
    
end;
/
