create or replace package cst_institute_pkg is

    function get_mps_inst(i_inst_id in com_api_type_pkg.t_inst_id) return com_api_type_pkg.t_inst_id;

    function get_abs_inst(i_inst_id in com_api_type_pkg.t_inst_id) return com_api_type_pkg.t_inst_id;

    function get_pc_mps_inst(i_inst_id in com_api_type_pkg.t_inst_id) return com_api_type_pkg.t_inst_id;

    function get_pc_abs_inst(i_inst_id in com_api_type_pkg.t_inst_id) return com_api_type_pkg.t_inst_id;
end;
/