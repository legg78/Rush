create or replace package body opr_cst_process_pkg is

    procedure get_statement(
        i_oper_filter             in     com_api_type_pkg.t_dict_value
      , o_statement              out     com_api_type_pkg.t_text
    ) is
    begin
        o_statement := null;
    end;

    procedure before_process
    is
    begin
        trc_log_pkg.debug(
            i_text       => 'opr_cst_process_pkg.before_process was started'
        );
    end before_process;

    procedure before_commit(
        i_oper_tbl  in  com_api_type_pkg.t_number_tab
    ) is
    begin
        trc_log_pkg.debug(
            i_text       => 'opr_cst_process_pkg.before_commit: i_oper_tbl.count [#1]'
          , i_env_param1 => i_oper_tbl.count
        );
    end before_commit;

end;
/
