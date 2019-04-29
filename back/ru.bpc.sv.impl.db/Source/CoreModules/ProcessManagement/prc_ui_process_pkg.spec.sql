create or replace package prc_ui_process_pkg as
/************************************************************
 * UI for processes <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 02.10.2009 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_UI_PROCESS_PKG <br />
 * @headcom
 ************************************************************/

/*
 * add process
 */ 
procedure add_process (
    o_id                     out com_api_type_pkg.t_short_id
  , i_procedure_name      in     com_api_type_pkg.t_name
  , i_is_parallel         in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_is_external         in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_is_container        in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_proc_short_desc     in     com_api_type_pkg.t_short_desc
  , i_proc_full_desc      in     com_api_type_pkg.t_full_desc
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_interrupt_threads   in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

/*
 * modify process
 */ 
procedure modify_process (
    i_id                  in com_api_type_pkg.t_short_id
  , i_procedure_name      in com_api_type_pkg.t_name
  , i_is_parallel         in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_is_external         in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_is_container        in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_proc_short_desc     in com_api_type_pkg.t_short_desc
  , i_proc_full_desc      in com_api_type_pkg.t_full_desc
  , i_lang                in com_api_type_pkg.t_dict_value
  , i_interrupt_threads   in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

/*
 * remove process
 * @param i_prc_id Process identifier
 */ 
procedure remove_process (
    i_id                  in com_api_type_pkg.t_short_id
);

/*
 * Add process to container
 */  
procedure add_process_to_container(
    io_id                   in out com_api_type_pkg.t_short_id
  , i_container_process_id  in     com_api_type_pkg.t_short_id
  , i_process_id            in     com_api_type_pkg.t_short_id
  , i_exec_order            in     com_api_type_pkg.t_tiny_id
  , i_is_parallel           in     com_api_type_pkg.t_boolean
  , i_error_limit           in     com_api_type_pkg.t_tiny_id
  , i_track_threshold       in     com_api_type_pkg.t_long_id
  , i_force                 in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_parallel_degree       in     com_api_type_pkg.t_tiny_id     default null
  , i_proc_cont_desc        in     com_api_type_pkg.t_full_desc
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_stop_on_fatal         in     com_api_type_pkg.t_boolean     default null
  , i_trace_level           in     com_api_type_pkg.t_short_id    default null
  , i_debug_writing_mode    in     com_api_type_pkg.t_dict_value  default null
  , i_start_trace_size      in     com_api_type_pkg.t_short_id    default null
  , i_error_trace_size      in     com_api_type_pkg.t_short_id    default null
  , i_max_duration          in     com_api_type_pkg.t_short_id    default null
  , i_min_speed             in     com_api_type_pkg.t_long_id     default null
);

procedure add_file_attributes(
    i_container_id          in     com_api_type_pkg.t_short_id
  , i_process_id            in     com_api_type_pkg.t_short_id
);

/*
 * Remove procedure from container
 * @param i_id Record identifier
 */  
procedure remove_process_from_container (
    i_id                    in com_api_type_pkg.t_short_id
);

procedure check_process_using(
    i_id                    in com_api_type_pkg.t_short_id
);

end prc_ui_process_pkg;
/
