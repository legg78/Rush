create or replace package dsp_cst_process_pkg as 

function check_other_networks(
    i_id                      in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_dict_value;

end;
/