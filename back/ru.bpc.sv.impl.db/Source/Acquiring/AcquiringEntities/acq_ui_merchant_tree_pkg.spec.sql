create or replace package acq_ui_merchant_tree_pkg as
/********************************************************* 
 *  UI for acquiring merchant type tree <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 18.09.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acq_ui_merchant_tree_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_merchant_branch(
    io_branch_id        in out  com_api_type_pkg.t_tiny_id
  , i_merchant_type     in      com_api_type_pkg.t_dict_value
  , i_parent_type       in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
);

procedure remove_merchant_branch(
    i_branch_id         in      com_api_type_pkg.t_tiny_id
);

end;
/
