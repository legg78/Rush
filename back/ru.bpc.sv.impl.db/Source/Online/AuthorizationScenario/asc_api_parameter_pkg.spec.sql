create or replace package asc_api_parameter_pkg is

/*********************************************************
*  API for authorization scenario parameters<br />
*  Created by Rashin G.(rashin@bpcsv.com)  at 04.02.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ASC_API_PARAMETER_PKG <br />
*  @headcom
**********************************************************/

--
-- Add/modify parameter
-- @param  io_param_id        Id parameter
-- @param  i_param_name       Name of parameter
-- @param  i_param_short_desc Short descriptions
-- @param  i_param_full_desc  Full descriptions
-- @param  i_param_lang       Description Language
-- @param  i_data_type        Datatype
-- @param  i_data_format      Mask format
-- @param  i_lov_id           Id of list of values for parameter selection
procedure add_parameter(
    io_param_id             in out com_api_type_pkg.t_short_id 
  , i_param_name            in     com_api_type_pkg.t_oracle_name
  , i_description           in     com_api_type_pkg.t_full_desc
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_data_type             in     com_api_type_pkg.t_dict_value
  , i_lov_id                in     com_api_type_pkg.t_tiny_id
);

--
-- Remove parameter
-- @param i_param_id Id parameter
procedure remove_parameter( 
    i_param_id              in      com_api_type_pkg.t_short_id 
);

--
-- Link parameter to state type
-- @param i_param_id Id of parameter
-- @param i_state_type Type of state from dictionary
-- @param i_default_value default value for parameter
-- @param i_display_order place of parameter in user interface
procedure add_state_parameter (
    o_state_parameter_id       out  com_api_type_pkg.t_short_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_param_id              in      com_api_type_pkg.t_short_id
  , i_state_type            in      com_api_type_pkg.t_dict_value
  , i_default_value         in      com_api_type_pkg.t_full_desc
  , i_display_order         in      com_api_type_pkg.t_tiny_id
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_lang                  in      com_api_type_pkg.t_dict_value
);

procedure modify_state_parameter (
    i_state_parameter_id    in      com_api_type_pkg.t_short_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_default_value         in      com_api_type_pkg.t_full_desc
  , i_display_order         in      com_api_type_pkg.t_tiny_id
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_lang                  in      com_api_type_pkg.t_dict_value
);

--
-- Unlink parameter from state type
-- @param i_param_id Id of parameter
-- @param i_state_type Type of state from dictionary
procedure remove_state_parameter ( 
    i_state_parameter_id    in      com_api_type_pkg.t_short_id
  , i_seqnum                in      com_api_type_pkg.t_seqnum
);

end;
/
