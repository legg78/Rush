create or replace package fcl_api_type_pkg as

/********************************************************* 
 *  API for types of FCL module <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 03.08.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: fcl_api_type_pkg   <br /> 
 *  @headcom 
 **********************************************************/ 

type t_limit_buffer is record(
    entity_type         com_api_type_pkg.t_dict_value
  , object_id           com_api_type_pkg.t_long_id
  , limit_type          com_api_type_pkg.t_dict_value
  , count_value         com_api_type_pkg.t_long_id
  , sum_value           com_api_type_pkg.t_money
  , split_hash          com_api_type_pkg.t_tiny_id
);

type t_limit_buffer_tab is table of t_limit_buffer index by binary_integer;

type t_limit_history is record(
    entity_type         com_api_type_pkg.t_dict_value
  , object_id           com_api_type_pkg.t_long_id
  , limit_type          com_api_type_pkg.t_dict_value
  , count_value         com_api_type_pkg.t_long_id
  , sum_value           com_api_type_pkg.t_money
  , source_entity_type  com_api_type_pkg.t_dict_value
  , source_object_id    com_api_type_pkg.t_long_id
  , split_hash          com_api_type_pkg.t_tiny_id
);

type t_limit_history_tab is table of t_limit_history index by binary_integer;

type t_limit is record(
    id                  com_api_type_pkg.t_long_id
  , limit_type          com_api_type_pkg.t_dict_value
  , cycle_id            com_api_type_pkg.t_short_id
  , count_limit         com_api_type_pkg.t_long_id
  , sum_limit           com_api_type_pkg.t_money
  , currency            com_api_type_pkg.t_curr_code
  , posting_method      com_api_type_pkg.t_dict_value
  , is_custom           com_api_type_pkg.t_boolean
  , inst_id             com_api_type_pkg.t_inst_id
  , limit_base          com_api_type_pkg.t_dict_value
  , limit_rate          com_api_type_pkg.t_money
  , count_max_bound     com_api_type_pkg.t_long_id
  , sum_max_bound       com_api_type_pkg.t_money
);

type t_fee_tier is record(
    id              com_api_type_pkg.t_short_id
  , fee_id          com_api_type_pkg.t_short_id
  , fixed_rate      com_api_type_pkg.t_money
  , percent_rate    com_api_type_pkg.t_money
  , min_value       com_api_type_pkg.t_money
  , max_value       com_api_type_pkg.t_money
  , length_type     com_api_type_pkg.t_dict_value
  , sum_threshold   com_api_type_pkg.t_money
  , count_threshold com_api_type_pkg.t_money
);

type t_fee_tier_tab is table of t_fee_tier index by binary_integer;

type t_fee is record(
    id              com_api_type_pkg.t_short_id
  , fee_type        com_api_type_pkg.t_dict_value
  , fee_rate_calc   com_api_type_pkg.t_dict_value
  , fee_base_calc   com_api_type_pkg.t_dict_value
  , currency        com_api_type_pkg.t_curr_code
  , inst_id         com_api_type_pkg.t_inst_id
  , cycle_id        com_api_type_pkg.t_short_id
  , limit_id        com_api_type_pkg.t_long_id 
);

type t_fee_tab is table of t_fee index by binary_integer;

end;
/
