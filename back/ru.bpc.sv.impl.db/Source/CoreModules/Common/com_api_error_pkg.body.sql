create or replace package body com_api_error_pkg as
/*********************************************************
*  UI for exception handling <br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 12.04.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: com_api_error_pkg <br />
*  @headcom
**********************************************************/

    g_last_error                    com_api_type_pkg.t_name    := null;
    g_last_message                  com_api_type_pkg.t_text    := null;
    g_last_id                       com_api_type_pkg.t_long_id := null;
    g_last_trace_text               com_api_type_pkg.t_text    := null;
    g_mask_error                    com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;

    procedure set_last_error(
        i_error             in      com_api_type_pkg.t_name
    ) is
    begin
        g_last_error := i_error;
    end;

    procedure set_last_message(
        i_message           in      com_api_type_pkg.t_text
    ) is
    begin
        g_last_message := i_message;
    end;

    procedure set_last_id(
        i_id                in      com_api_type_pkg.t_long_id
    ) is
    begin
        g_last_id := i_id;
    end;

    procedure set_last_trace_text(
        i_trace_text        in      com_api_type_pkg.t_text
    ) is
    begin
        g_last_trace_text := i_trace_text;
    end;

    procedure raise_error(
        i_error             in      com_api_type_pkg.t_name
      , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
      , i_env_param2        in      com_api_type_pkg.t_name             default null
      , i_env_param3        in      com_api_type_pkg.t_name             default null
      , i_env_param4        in      com_api_type_pkg.t_name             default null
      , i_env_param5        in      com_api_type_pkg.t_name             default null
      , i_env_param6        in      com_api_type_pkg.t_name             default null
      , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
      , i_object_id         in      com_api_type_pkg.t_long_id          default null
      , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
      , i_mask_error        in      com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
      , i_container_id      in      com_api_type_pkg.t_short_id         default null
    ) is
        l_error_message             com_api_type_pkg.t_text;
        l_error_id                  com_api_type_pkg.t_long_id;
        l_error_trace_text          com_api_type_pkg.t_text;
    begin
        set_last_error(i_error);

        if i_mask_error      = com_api_type_pkg.TRUE
           or get_mask_error = com_api_type_pkg.TRUE
        then
            trc_log_pkg.warn(
                i_text          => i_error
              , i_env_param1    => i_env_param1
              , i_env_param2    => i_env_param2
              , i_env_param3    => i_env_param3
              , i_env_param4    => i_env_param4
              , i_env_param5    => i_env_param5
              , i_env_param6    => i_env_param6
              , i_entity_type   => i_entity_type
              , i_object_id     => i_object_id
              , i_event_id      => i_event_id
              , o_text          => l_error_message
              , o_id            => l_error_id
              , i_container_id  => i_container_id
              , o_param_text    => l_error_trace_text
            );
        else
            trc_log_pkg.error(
                i_text          => i_error
              , i_env_param1    => i_env_param1
              , i_env_param2    => i_env_param2
              , i_env_param3    => i_env_param3
              , i_env_param4    => i_env_param4
              , i_env_param5    => i_env_param5
              , i_env_param6    => i_env_param6
              , i_entity_type   => i_entity_type
              , i_object_id     => i_object_id
              , i_event_id      => i_event_id
              , o_text          => l_error_message
              , o_id            => l_error_id
              , i_container_id  => i_container_id
              , o_param_text    => l_error_trace_text
            );
        end if;

        set_last_message(l_error_message);
        set_last_id(l_error_id);
        set_last_trace_text(l_error_trace_text);

        raise_application_error(APPL_ERROR, l_error_message);
    end;

    procedure raise_fatal_error(
        i_error             in      com_api_type_pkg.t_name
      , i_env_param1        in      com_api_type_pkg.t_full_desc        default null
      , i_env_param2        in      com_api_type_pkg.t_name             default null
      , i_env_param3        in      com_api_type_pkg.t_name             default null
      , i_env_param4        in      com_api_type_pkg.t_name             default null
      , i_env_param5        in      com_api_type_pkg.t_name             default null
      , i_env_param6        in      com_api_type_pkg.t_name             default null
      , i_entity_type       in      com_api_type_pkg.t_dict_value       default null
      , i_object_id         in      com_api_type_pkg.t_long_id          default null
      , i_event_id          in      com_api_type_pkg.t_tiny_id          default null
      , i_container_id      in      com_api_type_pkg.t_short_id         default null
    ) is
        l_error_message             com_api_type_pkg.t_text;
        l_error_id                  com_api_type_pkg.t_long_id;
        l_error_trace_text          com_api_type_pkg.t_text;
    begin
        set_last_error(i_error);

        trc_log_pkg.fatal(
            i_text          => i_error
          , i_env_param1    => i_env_param1
          , i_env_param2    => i_env_param2
          , i_env_param3    => i_env_param3
          , i_env_param4    => i_env_param4
          , i_env_param5    => i_env_param5
          , i_env_param6    => i_env_param6
          , i_entity_type   => i_entity_type
          , i_object_id     => i_object_id
          , i_event_id      => i_event_id
          , o_text          => l_error_message
          , i_container_id  => i_container_id
          , o_param_text    => l_error_trace_text
        );

        set_last_message(l_error_message);
        set_last_id(l_error_id);
        set_last_trace_text(l_error_trace_text);

        raise_application_error(FATAL_ERROR, l_error_message);
    end;

    function is_application_error (
        code            in number
    ) return com_api_type_pkg.t_boolean is
    begin
        if code = APPL_ERROR then return com_api_type_pkg.TRUE;
        else return com_api_type_pkg.FALSE;
        end if;
    end;

    function is_fatal_error (
        code            in number
    ) return com_api_type_pkg.t_boolean is
    begin
        if code = FATAL_ERROR then return com_api_type_pkg.TRUE;
        else return com_api_type_pkg.FALSE;
        end if;
    end;

    function get_last_error return com_api_type_pkg.t_name is
    begin
    
        return get_error_code(g_last_error);
    end;

    function get_last_message return com_api_type_pkg.t_text is
    begin
        return g_last_message;
    end;

    function get_last_error_id return com_api_type_pkg.t_long_id is
    begin
        return g_last_id;
    end;

    function get_last_trace_text return com_api_type_pkg.t_text is
    begin
        return g_last_trace_text;
    end;

    function get_error_code(
        i_error_code        in      com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_name is
    begin
        return
            com_api_array_pkg.conv_array_elem_v(
                i_array_type_id     => com_api_const_pkg.ERROR_CONV_ARRAY
              , i_inst_id           => com_ui_user_env_pkg.get_user_inst
              , i_elem_value        => i_error_code
              , i_error_value       => i_error_code
            );
    end;

    procedure set_mask_error (
        i_mask_error        in      com_api_type_pkg.t_boolean
    ) is
    begin
        g_mask_error := nvl(i_mask_error, com_api_type_pkg.FALSE);
    end;

    function get_mask_error return com_api_type_pkg.t_boolean is
    begin
        return g_mask_error;
    end;

end com_api_error_pkg;
/
