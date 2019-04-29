create or replace package prc_ui_task_pkg as
/************************************************************
 * User interface for process tasks <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 04.12.2009 <br />
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2009-12-04 09:58:36 +0300#$ <br />
 * Revision: $LastChangedRevision: 1367 $ <br />
 * Module: PRC_UI_TASK_PKG <br />
 * @headcom
 ************************************************************/

/*
 * Register new task
 */
 
 
procedure add_task (
    o_id                         out com_api_type_pkg.t_short_id
    , i_process_id            in     com_api_type_pkg.t_short_id
    , i_crontab_value         in     com_api_type_pkg.t_name
    , i_is_active             in     com_api_type_pkg.t_boolean       default com_api_type_pkg.TRUE
    , i_repeat_period         in     com_api_type_pkg.t_tiny_id
    , i_repeat_interval       in     com_api_type_pkg.t_tiny_id
    , i_short_desc            in     com_api_type_pkg.t_short_desc
    , i_full_desc             in     com_api_type_pkg.t_full_desc
    , i_lang                  in     com_api_type_pkg.t_dict_value
    , i_is_holiday_skipped    in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
    , i_stop_on_fatal         in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
);

/*
 * Modify new task
 */
procedure modify_task (
    i_id                      in     com_api_type_pkg.t_short_id
    , i_process_id            in     com_api_type_pkg.t_short_id
    , i_crontab_value         in     com_api_type_pkg.t_name
    , i_is_active             in     com_api_type_pkg.t_boolean       default com_api_type_pkg.TRUE
    , i_repeat_period         in     com_api_type_pkg.t_tiny_id
    , i_repeat_interval       in     com_api_type_pkg.t_tiny_id
    , i_short_desc            in     com_api_type_pkg.t_short_desc
    , i_full_desc             in     com_api_type_pkg.t_full_desc
    , i_lang                  in     com_api_type_pkg.t_dict_value
    , i_is_holiday_skipped    in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
    , i_stop_on_fatal         in     com_api_type_pkg.t_boolean       default com_api_type_pkg.FALSE
);

/*
 * Remove task
 * @param i_task_is Task identifier
 */  
procedure remove_task (
    i_id                      in     com_api_type_pkg.t_short_id
);

/*
 * Get schedule info
 * @param i_task_is Task identifier
 */
procedure get_schedule_info (
    o_ref_cur                   out  com_api_type_pkg.t_ref_cur
  , i_date                   in      date                          default null
  , i_first_row              in      com_api_type_pkg.t_long_id
  , i_last_row               in      com_api_type_pkg.t_long_id
  , i_param_tab              in      com_param_map_tpt             default null
  , i_sorting_tab            in      com_param_map_tpt             default null
);

procedure get_schedule_info_count (
    o_row_count                 out  com_api_type_pkg.t_long_id
  , i_date                   in      date                          default null
  , i_param_tab              in      com_param_map_tpt             default null
);

function get_exec_time(
    i_cron                    in     varchar2
  , i_date                    in     date                          default trunc(get_sysdate)
  , i_is_holiday_skipped      in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_inst_id                 in     com_api_type_pkg.t_inst_id    default ost_api_const_pkg.DEFAULT_INST
  , i_mask_error              in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return date_tab_tpt pipelined;

-- generator
function gen_times(
    i_hour                    in     com_api_type_pkg.t_attr_name
  , i_min                     in     com_api_type_pkg.t_attr_name
  , i_date                    in     date
) return date_tab_tpt pipelined;

end;
/
