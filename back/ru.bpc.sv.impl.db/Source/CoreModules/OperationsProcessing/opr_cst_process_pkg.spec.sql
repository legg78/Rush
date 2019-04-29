create or replace package opr_cst_process_pkg is

    procedure get_statement(
        i_oper_filter             in     com_api_type_pkg.t_dict_value
      , o_statement              out     com_api_type_pkg.t_text
    );

    procedure before_process;

    procedure before_commit(
        i_oper_tbl  in  com_api_type_pkg.t_number_tab
    );

end;
/
