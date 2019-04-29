create or replace package tie_utl_pkg is

  -- Author  : SHIBAEV
  -- Created : 26.10.2016 17:00:22
  -- Purpose : Tieto utilities
  
procedure calculate_control_sum(
    i_impact              in com_api_type_pkg.t_sign
  , i_pr_amount           in tie_api_type_pkg.t_pr_amount
  , io_tran_sum           in out nocopy tie_api_type_pkg.t_pr_amount
  , io_control_sum        in out nocopy tie_api_type_pkg.t_pr_amount
);

function cut_file_extension(
    i_file_name           in com_api_type_pkg.t_name
) return com_api_type_pkg.t_name;

end tie_utl_pkg;
/
