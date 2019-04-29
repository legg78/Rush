create or replace package body ost_ui_agent_type_tree_pkg as
/********************************************************* 
 *  UI for agent type tree <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 09.10.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: ost_ui_agent_type_tree_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_agent_type_branch(
    o_branch_id            out  com_api_type_pkg.t_tiny_id
  , i_agent_type        in      com_api_type_pkg.t_dict_value
  , i_parent_type       in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_agent_type        com_api_type_pkg.t_dict_value;
begin
    if i_parent_type is not null then
        begin
            select agent_type
              into l_agent_type
              from ost_agent_type_tree_vw
             where agent_type = i_parent_type
               and inst_id    = i_inst_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'AGENT_TYPE_NOT_FOUND'
                  , i_env_param1    => i_parent_type
                );
        end;
    end if; 
    
    if i_agent_type is null then
        com_api_error_pkg.raise_error(
            i_error         => 'AGENT_TYPE_NOT_DEFINED'
        );
    end if;    
    
    if i_inst_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'INSTITUTION_NOT_DEFINED'
        );
    end if;   
    
    select ost_agent_type_tree_seq.nextval into o_branch_id from dual; 
    
    insert into ost_agent_type_tree_vw(
        id
      , agent_type
      , parent_agent_type
      , inst_id
      , seqnum
    ) values (
        o_branch_id
      , i_agent_type
      , i_parent_type
      , i_inst_id
      , 1
    );
 
    begin
        select min(agent_type)
          into l_agent_type
          from ost_agent_type_tree
        connect by prior agent_type = parent_agent_type
            and prior inst_id = inst_id;
    exception
        when com_api_error_pkg.e_connect_by_loop then
            com_api_error_pkg.raise_error(
                i_error      => 'CYCLIC_AGENT_TREE_FOUND'
              , i_env_param1 => i_agent_type
              , i_env_param2 => i_parent_type
            );
    end;
end;

procedure remove_agent_type_branch(
    i_branch_id         in      com_api_type_pkg.t_tiny_id
) is
begin
    delete from ost_agent_type_tree_vw
     where id = i_branch_id;
end;

end;
/