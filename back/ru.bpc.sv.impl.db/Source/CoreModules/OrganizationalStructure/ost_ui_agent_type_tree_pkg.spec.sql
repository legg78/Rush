create or replace package ost_ui_agent_type_tree_pkg as

procedure add_agent_type_branch(
    o_branch_id            out  com_api_type_pkg.t_tiny_id
  , i_agent_type        in      com_api_type_pkg.t_dict_value
  , i_parent_type       in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
);

procedure remove_agent_type_branch(
    i_branch_id         in      com_api_type_pkg.t_tiny_id
);

end;
/