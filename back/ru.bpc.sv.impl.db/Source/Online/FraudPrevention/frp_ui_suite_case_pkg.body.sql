create or replace package body frp_ui_suite_case_pkg as

procedure add_suite_case(
    i_suite_id   in      com_api_type_pkg.t_tiny_id
  , i_case_id    in      com_api_type_pkg.t_tiny_id
  , i_priority   in      com_api_type_pkg.t_tiny_id
) is
begin
    insert into frp_suite_case_vw(
        suite_id
      , case_id
      , priority
    ) values (
        i_suite_id
      , i_case_id
      , i_priority
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
            i_error         => 'DUPLICATE_FRP_SUITE_CASE'
            , i_env_param1  => i_suite_id
            , i_env_param2  => i_case_id
        );
end;

procedure modify_suite_case(
    i_suite_id   in      com_api_type_pkg.t_tiny_id
  , i_case_id    in      com_api_type_pkg.t_tiny_id
  , i_priority   in      com_api_type_pkg.t_tiny_id
) is
begin
    update frp_suite_case
    set priority   = i_priority
    where suite_id = i_suite_id
      and case_id  = i_case_id;
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error (
            i_error         => 'DUPLICATE_FRP_SUITE_CASE'
            , i_env_param1  => i_suite_id
            , i_env_param2  => i_case_id
        );
end;



procedure remove_suite_case(
    i_suite_id   in      com_api_type_pkg.t_tiny_id
  , i_case_id    in      com_api_type_pkg.t_tiny_id
) is
begin
    delete from frp_suite_case_vw
     where suite_id  = i_suite_id
       and case_id   = i_case_id;
end;

end;
/
