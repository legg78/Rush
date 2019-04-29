create or replace package fcl_cst_cycle_ver2_pkg as
/*********************************************************
 *  The package with user-exits for shift's cycles processing <br />
 *
 *  Created by A. Alalykin (alalykin@bpcbt.com) at 24.03.2014 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate: 2014-03-24 12:28:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: fcl_cst_cycle_ver2_pkg <br />
 *  @headcom
 **********************************************************/

/**********************************************************
 * Custom processing for a user cycle's shift.
 * It returns NULL if no appropriate cycle's shift is found  
 **********************************************************/
function shift_date(
    i_date              in date
  , i_shift_type        in com_api_type_pkg.t_dict_value
  , i_shift_sign        in com_api_type_pkg.t_sign
  , i_length_type       in com_api_type_pkg.t_dict_value
  , i_shift_length      in com_api_type_pkg.t_tiny_id
  , i_forward           in com_api_type_pkg.t_boolean
  , i_start_date        in date default null
  , i_object_params     in com_api_type_pkg.t_param_tab          default cast(null as com_api_type_pkg.t_param_tab)
) return date;

/**********************************************************
 * Custom processing when e_application_error raised
 * possibillty to modify next_date of processed cycle
 **********************************************************/
procedure on_application_error(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , io_next_date        in out  date
);

end;
/
