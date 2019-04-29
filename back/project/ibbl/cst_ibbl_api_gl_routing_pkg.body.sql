create or replace package body cst_ibbl_api_gl_routing_pkg as

function get_src_bin return com_api_type_pkg.t_bin is
    l_bin    com_api_type_pkg.t_bin;
begin
    select min(src_bin)
    into l_bin
    from cst_ibbl_gl_routing_formular a
    where a.operation_id = opr_api_shared_data_pkg.get_operation_id(i_selector => opr_api_const_pkg.OPER_SELECTOR_CURRENT );
    
    return l_bin;
end;

function get_dst_bin return com_api_type_pkg.t_bin is
    l_bin    com_api_type_pkg.t_bin;
begin
    select min(dst_bin)
    into l_bin
    from cst_ibbl_gl_routing_formular a
    where a.operation_id = opr_api_shared_data_pkg.get_operation_id(i_selector => opr_api_const_pkg.OPER_SELECTOR_CURRENT );
    
    return l_bin;
end;


end cst_ibbl_api_gl_routing_pkg;
/
