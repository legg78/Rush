create or replace package set_ui_value_pkg as

--
-- System package
--
-- Created by Filimonov E.(filimonov@bpc.ru)  at 08.07.2009
-- Last changed by $Author$
-- $LastChangedDate::                           $
-- Revision: $LastChangedRevision$
-- Module: SET_VALUE_PKG
-- @headcom
--

SYST_LEVEL              constant com_api_type_pkg.t_dict_value      := 'PLVLSYST';
INST_LEVEL              constant com_api_type_pkg.t_dict_value      := 'PLVLINST';
AGNT_LEVEL              constant com_api_type_pkg.t_dict_value      := 'PLVLAGNT';
USER_LEVEL              constant com_api_type_pkg.t_dict_value      := 'PLVLUSER';


type t_parameter_rec is record (
    param_id            com_api_type_pkg.t_short_id
  , data_type           com_api_type_pkg.t_dict_value
  , default_value       com_api_type_pkg.t_name
  , lower_weight        pls_integer
  , curr_weight         pls_integer
);

type t_value_rec is record (
    param_id            com_api_type_pkg.t_short_id
  , param_value         com_api_type_pkg.t_name
);


function get_parameter_rec(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_level       in      com_api_type_pkg.t_dict_value
) return t_parameter_rec result_cache;

function get_value_rec(
    i_param_id          in      com_api_type_pkg.t_short_id
  , i_param_level       in      com_api_type_pkg.t_dict_value
  , i_level_value       in      com_api_type_pkg.t_name
) return t_value_rec result_cache;

procedure set_system_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      varchar2
);

procedure set_inst_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      varchar2
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
);

procedure set_agent_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      varchar2
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
);

procedure set_user_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      varchar2
  , i_user_id           in      com_api_type_pkg.t_name             default null
);

procedure set_system_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      date
);

procedure set_inst_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
);

procedure set_agent_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      date
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
);

procedure set_user_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      date
  , i_user_id           in      com_api_type_pkg.t_name             default null
);

procedure set_system_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      number
);

procedure set_inst_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      number
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
);

procedure set_agent_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      number
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
);

procedure set_user_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_param_value       in      number
  , i_user_id           in      com_api_type_pkg.t_name             default null
);

function get_system_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return varchar2;

function get_inst_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return varchar2;

function get_agent_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return varchar2;

function get_user_param_v(
    i_param_name        in      com_api_type_pkg.t_name
  , i_user_id           in      com_api_type_pkg.t_name             default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return varchar2;

function get_system_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return date;

function get_inst_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return date;

function get_agent_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return date;

function get_user_param_d(
    i_param_name        in      com_api_type_pkg.t_name
  , i_user_id           in      com_api_type_pkg.t_name             default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return date;

function get_system_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return number;

function get_inst_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return number;

function get_agent_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return number;

function get_user_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , i_user_id           in      com_api_type_pkg.t_name             default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
) return number;

procedure set_system_default_value(
    i_param_name        in      com_api_type_pkg.t_name
);

procedure set_inst_default_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
);

procedure set_agent_default_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_agent_id          in      com_api_type_pkg.t_agent_id         default null
);

procedure set_user_default_value(
    i_param_name        in      com_api_type_pkg.t_name
  , i_user_id           in      com_api_type_pkg.t_name             default null
);

procedure get_param_values(
    i_param_name        in      com_api_type_pkg.t_name
  , io_value_cursor     in out  com_api_type_pkg.t_ref_cur
);

procedure get_inst_by_param_n(
    i_param_name        in      com_api_type_pkg.t_name
  , o_inst_id              out  com_api_type_pkg.t_boolean_tab
);

end;
/
