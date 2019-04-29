create or replace package asc_ui_scenario_pkg is
/**********************************************************
 * UI for scenaries<br/>
 * Created by Rashin G.(rashin@bpcbt.com)  at 03.02.2010<br/>
 * Last changed by $Author$<br/>
 * $LastChangedDate::                           $<br/>
 * Revision: $LastChangedRevision$<br/>
 * Module: ASC_UI_SCENARIO_PKG
 * @headcom
 **********************************************************/
procedure add_scenario (
    o_scenario_id          out com_api_type_pkg.t_tiny_id
    , o_seqnum             out com_api_type_pkg.t_seqnum
    , i_scenario_name      in com_api_type_pkg.t_name
    , i_lang               in com_api_type_pkg.t_dict_value default null
    , i_description        in com_api_type_pkg.t_full_desc default null
);

procedure modify_scenario (
    i_scenario_id          in com_api_type_pkg.t_tiny_id
    , io_seqnum            in out com_api_type_pkg.t_seqnum
    , i_scenario_name      in com_api_type_pkg.t_name
    , i_lang               in com_api_type_pkg.t_dict_value default null
    , i_description        in com_api_type_pkg.t_full_desc default null
);

procedure remove_scenario (
    i_scenario_id          in com_api_type_pkg.t_tiny_id
    , i_seqnum             in com_api_type_pkg.t_seqnum
);

procedure add_state (
    o_state_id             out com_api_type_pkg.t_short_id
    , o_seqnum             out com_api_type_pkg.t_seqnum
    , i_scenario_id        in com_api_type_pkg.t_tiny_id
    , i_state_code         in com_api_type_pkg.t_tiny_id
    , i_state_type         in com_api_type_pkg.t_dict_value
    , i_lang               in com_api_type_pkg.t_dict_value default null
    , i_description        in com_api_type_pkg.t_full_desc default null
);

procedure modify_state (
    i_state_id             in com_api_type_pkg.t_short_id
    , io_seqnum            in out com_api_type_pkg.t_seqnum
    , i_state_code         in com_api_type_pkg.t_tiny_id
    , i_lang               in com_api_type_pkg.t_dict_value default null
    , i_description        in com_api_type_pkg.t_full_desc default null
);

procedure remove_state (
    i_state_id             in com_api_type_pkg.t_short_id
    , i_seqnum             in com_api_type_pkg.t_seqnum
);

procedure add_state_param_value (
    i_state_id             in com_api_type_pkg.t_short_id
    , i_parameter_id       in com_api_type_pkg.t_tiny_id
    , i_value_char         in com_api_type_pkg.t_full_desc
    , i_seqnum             in com_api_type_pkg.t_seqnum
);

procedure add_state_param_value (
    i_state_id             in com_api_type_pkg.t_short_id
    , i_parameter_id       in com_api_type_pkg.t_tiny_id
    , i_value_num          in number
    , i_seqnum             in com_api_type_pkg.t_seqnum
);

procedure add_state_param_value (
    i_state_id             in com_api_type_pkg.t_short_id
    , i_parameter_id       in com_api_type_pkg.t_tiny_id
    , i_value_date         in date
    , i_seqnum             in com_api_type_pkg.t_seqnum
);

procedure add_selection(
    o_id                      out com_api_type_pkg.t_short_id
  , i_scenario_id          in     com_api_type_pkg.t_tiny_id
  , i_mod_id               in     com_api_type_pkg.t_tiny_id
  , i_oper_type            in     com_api_type_pkg.t_dict_value
  , i_is_reversal          in     com_api_type_pkg.t_boolean
  , i_sttl_type            in     com_api_type_pkg.t_dict_value
  , i_priority             in     com_api_type_pkg.t_tiny_id
  , i_msg_type             in     com_api_type_pkg.t_dict_value
  , i_terminal_type        in     com_api_type_pkg.t_dict_value
  , i_oper_reason          in     com_api_type_pkg.t_dict_value
);

procedure remove_selection(
    i_id                   in     com_api_type_pkg.t_short_id
);

end;
/
