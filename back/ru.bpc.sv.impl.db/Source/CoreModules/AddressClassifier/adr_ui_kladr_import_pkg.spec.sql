create or replace package adr_ui_kladr_import_pkg as
/*********************************************************
*  User interface procedures for loading data from KLADR  into ADR module <br />
*  Created by Fomichev A (fomichev@bpc.ru)  at 28.03.2011 <br />
*  Last changed by $Author: fomichev $ <br />
*  $LastChangedDate:: 2010-04-12 11:09:41 +0400#$ <br />
*  Revision: $LastChangedRevision: 2432 $ <br />
*  Module: adr_ui_kladr_import_pkg <br />
*  @headcom
**********************************************************/


procedure import_kladr_data(
    i_altnames_file_id  in      com_api_type_pkg.t_long_id
  , i_doma_file_id      in      com_api_type_pkg.t_long_id
  , i_flat_file_id      in      com_api_type_pkg.t_long_id
  , i_kladr_file_id     in      com_api_type_pkg.t_long_id
  , i_socrbase_file_id  in      com_api_type_pkg.t_long_id
  , i_street_file_id    in      com_api_type_pkg.t_long_id
  , i_delim             in      com_api_type_pkg.t_name default ';'
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_country_id        in      com_api_type_pkg.t_tiny_id
);

procedure truncate_table (i_table_name in     com_api_type_pkg.t_name);

function get_level_by_code(i_code  in      com_api_type_pkg.t_name) 
return com_api_type_pkg.t_tiny_id;

function get_delim return com_api_type_pkg.t_name;


procedure set_parent;

procedure clear_inactive;

end;
/
