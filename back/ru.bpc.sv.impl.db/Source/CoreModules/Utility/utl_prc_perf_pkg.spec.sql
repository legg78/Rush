create or replace package utl_prc_perf_pkg is
/**********************************************************
 * List of objects for setting up the system performance
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 29.08.2016
 * Last changed by Gogolev I.(i.gogolev@bpcbt.com) at 
 * 30.08.2016 15:20:00
 *
 * Module: UTL_PRC_PERF_PKG
 * @headcom
 **********************************************************/

GATHER_DEF      constant com_api_type_pkg.t_name := 'GATHER';
GATHER_AUTO     constant com_api_type_pkg.t_name := 'GATHER AUTO';



/**********************************************************
 *
 * Run procedure gathers statistics (dbms_stat.gather_schema_stats)
 * for objects which is defined in input parameter.
 * 
 * @param i_is_stat_mode_def:
 *     TRUE  - set Oracle default mode for all schema objects
 *     FALSE - set user mode for changes objects only
 *
 *********************************************************/
procedure run_gather_stats(
    i_is_stat_mode_def  in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

procedure save_top_sql(
    i_start_date             in     date                           default null
  , i_end_date               in     date                           default null
  , i_count                  in     com_api_type_pkg.t_long_id     default null
  , i_top_sql_sorting_type   in     com_api_type_pkg.t_dict_value  default null
  , i_need_aggregate         in     com_api_type_pkg.t_boolean     default null
);

end utl_prc_perf_pkg;
/
