create or replace package trc_file_pkg as
/*********************************************************
 *  API for logging into file  <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com)  at 03.03.2015 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate:: 2015-03-03 19:00:00 +0300#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: trc_file_pkg <br />
 *  @headcom
 **********************************************************/

procedure log(
    i_trace_conf        in     trc_config_pkg.trace_conf
  , i_timestamp         in     timestamp
  , i_level             in     com_api_type_pkg.t_dict_value
  , i_user              in     com_api_type_pkg.t_oracle_name
  , i_text              in     com_api_type_pkg.t_text
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_session_id        in     com_api_type_pkg.t_long_id
  , i_thread_number     in     com_api_type_pkg.t_tiny_id
);

end;
/