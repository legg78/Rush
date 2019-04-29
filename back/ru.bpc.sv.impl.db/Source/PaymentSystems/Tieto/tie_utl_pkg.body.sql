create or replace package body tie_utl_pkg is

procedure calculate_control_sum(
    i_impact              in com_api_type_pkg.t_sign
  , i_pr_amount           in tie_api_type_pkg.t_pr_amount
  , io_tran_sum           in out nocopy tie_api_type_pkg.t_pr_amount
  , io_control_sum        in out nocopy tie_api_type_pkg.t_pr_amount
) is
begin
    
    io_tran_sum:= 
        nvl(io_tran_sum, 0)
      + nvl(i_pr_amount, 0)
      * case i_impact
            when com_api_const_pkg.CREDIT then -1
            when com_api_const_pkg.DEBIT  then  1
            when com_api_const_pkg.NONE   then  0
        end;
    io_control_sum:= nvl(io_control_sum, 0) + i_pr_amount;
    
end calculate_control_sum;

function cut_file_extension(
    i_file_name           in com_api_type_pkg.t_name
) return com_api_type_pkg.t_name is
begin
    return nvl(substr(i_file_name, 1, instr(i_file_name, '.', -1) - 1), i_file_name);
end;

begin
    -- Initialization
    null;
end tie_utl_pkg;
/
