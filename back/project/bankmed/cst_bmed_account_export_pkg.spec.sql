create or replace package cst_bmed_account_export_pkg is

procedure process(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_lang                  in     com_api_type_pkg.t_dict_value     default null
);

end;
/