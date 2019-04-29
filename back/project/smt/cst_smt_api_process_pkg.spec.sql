create or replace package cst_smt_api_process_pkg is
/************************************************************
 * API for various processing SMT <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com)  at 25.12.2018 <br />
 * Last changed by $Author: Gogolev I. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_smt_api_process_pkg <br />
 * @headcom
 ***********************************************************/
 
procedure insert_into_msstrxn_map(
    i_input_file_name     in  com_api_type_pkg.t_name
  , i_original_file_name  in  com_api_type_pkg.t_name
  , i_load_date           in  date
  , i_msstrxn_map_tab     in  cst_smt_api_type_pkg.t_msstrxn_map_field_tab
);

procedure delete_msstrxn_map(
    i_input_file_name     in  com_api_type_pkg.t_name
  , i_load_date           in  date
  , i_id_tab              in  com_api_type_pkg.t_number_tab
);

end;
/
