create or replace package utl_data_pkg as
/*********************************************************
*  Unloading data <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 09.10.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: UTL_DATA_PKG <br />
*  @headcom
**********************************************************/ 

procedure data_from_table (
    i_owner             in      com_api_type_pkg.t_oracle_name
  , i_table_name        in      com_api_type_pkg.t_oracle_name
  , i_where_clause      in      com_api_type_pkg.t_full_desc        default null
  , i_order_clause      in      com_api_type_pkg.t_full_desc        default null
  , i_export_clob       in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
);

procedure data_from_table (
    i_owner             in      com_api_type_pkg.t_oracle_name
  , i_table_name        in      com_api_type_pkg.t_oracle_name
  , i_where_clause      in      com_api_type_pkg.t_full_desc        default null
  , i_order_clause      in      com_api_type_pkg.t_full_desc        default null
  , i_export_clob       in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , io_source           in out  nocopy clob
);

procedure print_table (
    i_param_tab         in      com_param_map_tpt
);

end;
/ 
