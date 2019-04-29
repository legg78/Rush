create or replace package body dsp_api_shared_data_pkg is
/************************************************************
 * API for Dispute shared data <br />
 * Created by Maslov I.(maslov@bpcbt.com)  at 27.05.2013 <br />
 * Module: DSP_API_SHARED_DATA_PKG <br />
 * @headcom
 ***********************************************************/

g_params                 com_api_type_pkg.t_param_tab;
g_cursor_statement       clob;

function get_id return com_api_type_pkg.t_long_id
is
begin
    return com_api_id_pkg.get_id(
               i_seq  => dsp_dispute_seq.nextval
             , i_date => com_api_sttl_day_pkg.get_sysdate
           );
end;

function get_global_params return com_api_type_pkg.t_param_tab
is
begin
    return g_params;
end;

procedure clear_params
is
begin
    rul_api_param_pkg.clear_params(
        io_params       => g_params
    );
end;

procedure set_param (
    i_name                 in     com_api_type_pkg.t_name
  , i_value                in     com_api_type_pkg.t_name
) is
begin
    rul_api_param_pkg.set_param (
        i_name            => i_name
      , io_params         => g_params
      , i_value           => i_value
    );

    g_cursor_statement := null;
end;

procedure set_param (
    i_name                 in     com_api_type_pkg.t_name
  , i_value                in     number
) is
begin
    rul_api_param_pkg.set_param (
        i_name            => i_name
      , io_params         => g_params
      , i_value           => i_value
    );

    g_cursor_statement := null;
end;

procedure set_param (
    i_name                 in     com_api_type_pkg.t_name
  , i_value                in     date
) is
begin
    rul_api_param_pkg.set_param (
        i_name            => i_name
      , io_params         => g_params
      , i_value           => i_value
    );

    g_cursor_statement := null;
end;

function select_condition (
    i_mod                  in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean
is
    l_mods                 com_api_type_pkg.t_number_tab;
    l_return               com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    if i_mod is not null then
        l_mods(1) := i_mod;
        l_return  := rul_api_mod_pkg.select_condition(
                         i_mods        => l_mods
                       , i_params      => g_params
                       , i_mask_error  => com_api_const_pkg.TRUE
                     );
    end if;
    return l_return;
end;

procedure set_cur_statement (
    i_cur_stat             in     clob
) is
begin
    g_cursor_statement := i_cur_stat;
end;

function get_cur_statement return clob
is
begin
    return g_cursor_statement;
end;

function get_param_num (
    i_name                 in     com_api_type_pkg.t_name
  , i_mask_error           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value          in     com_api_type_pkg.t_name       default null
) return number
is
begin
    return rul_api_param_pkg.get_param_num (
               i_name            => i_name
             , io_params         => g_params
             , i_mask_error      => i_mask_error
             , i_error_value     => i_error_value
           );
end;

function get_param_date (
    i_name                 in     com_api_type_pkg.t_name
  , i_mask_error           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value          in     com_api_type_pkg.t_name       default null
) return date
is
begin
    return rul_api_param_pkg.get_param_date (
               i_name            => i_name
             , io_params         => g_params
             , i_mask_error      => i_mask_error
             , i_error_value     => i_error_value
           );
end;

function get_param_char(
    i_name                 in     com_api_type_pkg.t_name
  , i_mask_error           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_value          in     com_api_type_pkg.t_name       default null
) return com_api_type_pkg.t_name
is
begin
    return rul_api_param_pkg.get_param_char(
               i_name            => i_name
             , io_params         => g_params
             , i_mask_error      => i_mask_error
             , i_error_value     => i_error_value
           );
end;

function get_masked_param_num(
    i_name                 in     com_api_type_pkg.t_name
) return number
is
begin
    return get_param_num(
               i_name        => i_name
             , i_mask_error  => com_api_type_pkg.TRUE
             , i_error_value => null
           );
end get_masked_param_num;

function get_masked_param_date(
    i_name                 in     com_api_type_pkg.t_name
) return date
is
begin
    return get_param_date(
               i_name        => i_name
             , i_mask_error  => com_api_type_pkg.TRUE
             , i_error_value => null
           );
end get_masked_param_date;

function get_masked_param_char(
    i_name                 in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_name
is
begin
    return get_param_char(
               i_name        => i_name
             , i_mask_error  => com_api_type_pkg.TRUE
             , i_error_value => null
           );
end get_masked_param_char;

end dsp_api_shared_data_pkg;
/
