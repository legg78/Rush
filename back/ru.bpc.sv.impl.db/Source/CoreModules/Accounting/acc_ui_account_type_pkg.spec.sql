create or replace package acc_ui_account_type_pkg is
/*********************************************************
*  Account type UI  <br />
*  Created by Khougaev A.(khougaev@bpcsv.com)  at 06.11.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: acc_ui_account_type_pkg <br />
*  @headcom
**********************************************************/
procedure add (
    o_id                   out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_account_type      in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_number_format_id  in      com_api_type_pkg.t_tiny_id
  , i_number_prefix     in      com_api_type_pkg.t_name
  , i_product_type      in      com_api_type_pkg.t_dict_value
);

procedure modify (
    i_id                in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_number_format_id  in      com_api_type_pkg.t_tiny_id
  , i_number_prefix     in      com_api_type_pkg.t_name
  , i_product_type      in      com_api_type_pkg.t_dict_value
);
    
procedure remove (
    i_id                in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);
    
procedure add_entity_type (
    o_id                   out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_account_type      in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
);

procedure remove_entity_type (
    i_id                in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);
    
procedure add_iso_type (
    o_id                   out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_account_type      in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_iso_type          in      com_api_type_pkg.t_dict_value
  , i_priority          in      com_api_type_pkg.t_tiny_id
);

procedure modify_iso_type (
    i_id                in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_priority          in      com_api_type_pkg.t_tiny_id
);

procedure remove_iso_type (
    i_id                in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

end;
/
