create or replace package rul_ui_name_pool_pkg as
/*********************************************************
*  UI for pool <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 13.02.2012 <br />
*  Last changed by $Author:  $ <br />
*  $LastChangedDate:: #$ <br />
*  Revision: $LastChangedRevision: 36739 $ <br />
*  Module: RUL_UI_NAME_POOL_PKG <br />
*  @headcom
**********************************************************/

function get_partition_key(
    i_index_range_id     in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_short_id;

procedure add_pool_value(
    o_id                    out com_api_type_pkg.t_long_id
  , i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_value              in     com_api_type_pkg.t_large_id
);

procedure modify_pool_value(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_value              in     com_api_type_pkg.t_large_id
  , i_is_used            in     com_api_type_pkg.t_boolean
  , i_rowid              in     rowid default null
);

procedure remove_pool_value(
    i_id                 in     com_api_type_pkg.t_long_id
  , i_rowid              in     rowid                        default null
);

procedure remove_pool_value(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_value              in     com_api_type_pkg.t_large_id
);

procedure create_random_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
);

procedure create_sequential_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
);

procedure create_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
  , i_force              in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

procedure create_pools_if_missing;

procedure check_cross(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
);

procedure check_range_change(
    i_index_range_id          in com_api_type_pkg.t_short_id
  , i_low_value               com_api_type_pkg.t_large_id
  , i_high_value              com_api_type_pkg.t_large_id
);

procedure add_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
);

procedure modify_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
);

procedure remove_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
);

procedure remove_pool_range(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
);

procedure clear_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
);

function get_next_value(
    i_index_range_id     in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_large_id;

function get_random_value(
    i_index_range_id     in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_large_id;

end rul_ui_name_pool_pkg;
/
