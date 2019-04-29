create or replace package body app_api_error_pkg as
/*********************************************************
*  Application error <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 09.09.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                          $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_api_error_pkg <br />
*  @headcom
**********************************************************/

-- Collection with names of blocks that may contain linked ERROR block
g_block_tab          com_api_type_pkg.t_param_tab;

procedure add_error_element(
    i_appl_data_id   in      com_api_type_pkg.t_long_id
  , i_error_code     in      com_api_type_pkg.t_name
  , i_error_message  in      com_api_type_pkg.t_full_desc
  , i_error_details  in      com_api_type_pkg.t_full_desc
  , i_error_element  in      com_api_type_pkg.t_name
) is
    l_parent_id      com_api_type_pkg.t_long_id;
    l_root_id        com_api_type_pkg.t_long_id;
    l_appl_id        com_api_type_pkg.t_long_id;
begin
    begin
        app_api_application_pkg.add_element(
            i_element_name   => 'ERROR'
          , i_parent_id      => i_appl_data_id
          , i_element_value  => ''
          , o_appl_data_id   => l_parent_id
        );
    exception
        when others then 
            if com_api_error_pkg.get_last_error in ('PARENT_ELEMENT_NOT_FOUND'
                                                  , 'IMPOSSIBLE_ATTACH_ELEMENT')
            then
                -- It necessary to link ERROR block to a root application's element
                -- if there are one of the next reasons:
                -- a) PARENT_ELEMENT_NOT_FOUND —
                --   error is linked to non-existent element (e.g. account was added
                --   in before_account custom procedure and deleted with rollback 
                --   to sp_before_app_process);
                -- b) IMPOSSIBLE_ATTACH_ELEMENT —
                --   error block is linked to element that can't contain block
                --   ERROR in accodring to application's structure (e.g. it is not
                --   actually a block but just an element)
                l_appl_id := app_api_application_pkg.get_appl_id;

                select min(a.id)
                  into l_root_id
                  from app_data a
                 where a.appl_id    = l_appl_id
                   and a.parent_id is null;

                trc_log_pkg.debug('l_root_id='||l_root_id||', appl_data_id='||i_appl_data_id);

                app_api_application_pkg.add_element(
                    i_element_name   => 'ERROR'
                  , i_parent_id      => l_root_id
                  , i_element_value  => ''
                  , o_appl_data_id   => l_parent_id
                );
            else
                raise;
            end if;
    end;

    app_api_application_pkg.add_element(
        i_element_name          => 'ERROR_CODE'
      , i_parent_id             => l_parent_id
      , i_element_value         => i_error_code
    );

    app_api_application_pkg.add_element(
        i_element_name          => 'ERROR_DESC'
      , i_parent_id             => l_parent_id
      , i_element_value         => i_error_message
    );

    app_api_application_pkg.add_element(
        i_element_name          => 'ERROR_ELEMENT'
      , i_parent_id             => l_parent_id
      , i_element_value         => i_error_element
    );

    app_api_application_pkg.add_element(
        i_element_name          => 'ERROR_DETAILS'
      , i_parent_id             => l_parent_id
      , i_element_value         => i_error_details
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT) || '.add_error_element FAILED: '
                   || 'i_appl_data_id [' || i_appl_data_id
                   || '], i_error_element [' || i_error_element
                   || '], i_error_code [' || i_error_code
                   || '], l_parent_id [' || l_parent_id
                   || '], l_root_id [' || l_root_id || ']' 
        );
        raise;
end add_error_element;

procedure add_error_element(
    i_appl_id        in      com_api_type_pkg.t_long_id
  , i_error_code     in      com_api_type_pkg.t_name
  , i_error_message  in      com_api_type_pkg.t_full_desc
  , i_error_details  in      com_api_type_pkg.t_full_desc
  , i_error_element  in      com_api_type_pkg.t_name
) is
    l_parent_id      com_api_type_pkg.t_long_id;
begin
    app_api_application_pkg.get_appl_data (
        i_appl_id    => i_appl_id
    );

    -- application
    app_api_application_pkg.get_appl_data_id (
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_parent_id
    );

    add_error_element(
        i_appl_data_id   => l_parent_id
      , i_error_code     => i_error_code
      , i_error_message  => i_error_message
      , i_error_details  => i_error_details
      , i_error_element  => i_error_element
    );
end add_error_element;

procedure add_errors_to_app_data is 
    pragma        autonomous_transaction;
begin
    trc_log_pkg.debug (
        i_text          => 'add_errors_to_app_data started [#1]'
        , i_env_param1  => g_app_errors.count
    );
    for i in nvl(g_app_errors.first, 1)..nvl(g_app_errors.last, 0) loop
        -- Block ERROR can't be linked to a simple element, it can be linked
        -- only to a block, so in this case it is necessary to try to link 
        -- a error to a parent block
        add_error_element(
            i_appl_data_id  => case
                                   when g_block_tab.exists(g_app_errors(i).element_name)
                                     or g_app_errors(i).parent_id is null
                                   then g_app_errors(i).appl_data_id
                                   else g_app_errors(i).parent_id
                               end
          , i_error_code    => g_app_errors(i).error_code
          , i_error_message => g_app_errors(i).error_message
          , i_error_details => g_app_errors(i).error_details
          , i_error_element => g_app_errors(i).element_name
        );
    end loop;
    
    g_app_errors.delete;

    commit;
end;

procedure intercept_error(
    i_appl_data_id      in      com_api_type_pkg.t_long_id
  , i_element_name      in      com_api_type_pkg.t_name
  , i_parent_id         in      com_api_type_pkg.t_long_id    default null
) is
    l_count             pls_integer;
begin
    l_count := g_app_errors.count + 1;
    
    g_app_errors(l_count).appl_data_id  := i_appl_data_id;
    g_app_errors(l_count).parent_id     := i_parent_id;
    g_app_errors(l_count).error_code    := com_api_error_pkg.get_last_error;
    g_app_errors(l_count).error_message := com_api_error_pkg.get_last_message;
    g_app_errors(l_count).error_details := trc_log_pkg.get_details(
                                               i_label_id   => com_api_error_pkg.get_last_error_id
                                             , i_trace_text => com_api_error_pkg.get_last_trace_text
                                           );
    g_app_errors(l_count).element_name  := i_element_name;

    trc_log_pkg.debug('intercept_error: '||
        'i_appl_data_id => ' || g_app_errors(l_count).appl_data_id ||
      ', parent_id => '      || g_app_errors(l_count).parent_id ||
      ', i_error_code => '   || g_app_errors(l_count).error_code ||
      ', i_error_message => '|| g_app_errors(l_count).error_message ||
      ', i_error_details => '|| g_app_errors(l_count).error_details ||
      ', i_error_element => '|| g_app_errors(l_count).element_name
    );
    
    raise com_api_error_pkg.e_stop_appl_processing;
end;

procedure raise_error(
    i_appl_data_id      in      com_api_type_pkg.t_long_id
  , i_error             in      com_api_type_pkg.t_name
  , i_env_param1        in      com_api_type_pkg.t_full_desc  default null
  , i_env_param2        in      com_api_type_pkg.t_name       default null
  , i_env_param3        in      com_api_type_pkg.t_name       default null
  , i_env_param4        in      com_api_type_pkg.t_name       default null
  , i_env_param5        in      com_api_type_pkg.t_name       default null
  , i_env_param6        in      com_api_type_pkg.t_name       default null
  , i_element_name      in      com_api_type_pkg.t_name       default null
  , i_appl_id           in      com_api_type_pkg.t_long_id    default null
  , i_parent_id         in      com_api_type_pkg.t_long_id    default null
) is
    --l_error_msg     com_api_type_pkg.t_full_desc;
begin
    com_api_error_pkg.raise_error(
        i_error       => i_error
      , i_env_param1  => i_env_param1
      , i_env_param2  => i_env_param2
      , i_env_param3  => i_env_param3 
      , i_env_param4  => i_env_param4
      , i_env_param5  => i_env_param5
      , i_env_param6  => i_env_param6
      , i_entity_type => app_api_const_pkg.ENTITY_TYPE_APPLICATION
      , i_object_id   => i_appl_id
    );
exception
    when others then
        intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => i_element_name
          , i_parent_id     => i_parent_id
        );    
end raise_error;

procedure raise_fatal_error(
    i_appl_data_id      in      com_api_type_pkg.t_long_id
  , i_error             in      com_api_type_pkg.t_name
  , i_env_param1        in      com_api_type_pkg.t_full_desc  default null
  , i_env_param2        in      com_api_type_pkg.t_name       default null
  , i_env_param3        in      com_api_type_pkg.t_name       default null
  , i_env_param4        in      com_api_type_pkg.t_name       default null
  , i_env_param5        in      com_api_type_pkg.t_name       default null
  , i_env_param6        in      com_api_type_pkg.t_name       default null
  , i_element_name      in      com_api_type_pkg.t_name       default null
  , i_appl_id           in      com_api_type_pkg.t_long_id    default null
  , i_parent_id         in      com_api_type_pkg.t_long_id    default null
) is
    l_error_msg     com_api_type_pkg.t_full_desc;
begin
    begin
        com_api_error_pkg.raise_error(
            i_error       => i_error
          , i_env_param1  => i_env_param1
          , i_env_param2  => i_env_param2
          , i_env_param3  => i_env_param3 
          , i_env_param4  => i_env_param4
          , i_env_param5  => i_env_param5
          , i_env_param6  => i_env_param6
          , i_entity_type => app_api_const_pkg.ENTITY_TYPE_APPLICATION
          , i_object_id   => i_appl_id
        );
    exception
        when others then
            intercept_error(
                i_appl_data_id  => i_appl_data_id
              , i_element_name  => i_element_name
              , i_parent_id     => i_parent_id
            );
    end;
    
    add_errors_to_app_data;
    
    raise_application_error(com_api_error_pkg.FATAL_ERROR, l_error_msg);
    
end raise_fatal_error;

procedure remove_error_elements(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_skip_saver_errors in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
    l_appl_data_id      com_api_type_pkg.t_long_id;
    l_element_value     com_api_type_pkg.t_full_desc;
begin

    for r in (
        select *
          from app_data_vw
         where appl_id = i_appl_id
           and name = 'ERROR'
    ) loop
        app_api_application_pkg.get_element_value(
            i_element_name          => 'ERROR_CODE'
          , i_parent_id             => r.id
          , o_element_value         => l_element_value
        );

        if i_skip_saver_errors = com_api_const_pkg.TRUE
           and l_element_value in ('ERROR_DURING_VALIDATION')
        then
            trc_log_pkg.debug(
                i_text              => 'remove_error_elements: appl_id [#1], ignore error [#2]'
              , i_env_param1        => i_appl_id
              , i_env_param2        => l_element_value
            );

        else
            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'ERROR_CODE'
              , i_parent_id         => r.id
              , o_appl_data_id      => l_appl_data_id
            );

            app_api_application_pkg.remove_element(
                i_appl_data_id      => l_appl_data_id
            );

            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'ERROR_DESC'
              , i_parent_id         => r.id
              , o_appl_data_id      => l_appl_data_id
            );

            app_api_application_pkg.remove_element(
                i_appl_data_id      => l_appl_data_id
            );

            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'ERROR_DETAILS'
              , i_parent_id         => r.id
              , o_appl_data_id      => l_appl_data_id
            );

            app_api_application_pkg.remove_element(
                i_appl_data_id      => l_appl_data_id
            );

            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'ERROR_ELEMENT'
              , i_parent_id         => r.id
              , o_appl_data_id      => l_appl_data_id
            );

            app_api_application_pkg.remove_element(
                i_appl_data_id      => l_appl_data_id
            );

            app_api_application_pkg.remove_element(
                i_appl_data_id      => r.id
            );
        end if;

    end loop;

    app_api_error_pkg.g_app_errors.delete();

end remove_error_elements;

-- Save to associative array g_block_tab all names of blocks
-- that may contain block ERROR in according to application structure
begin
    g_block_tab.delete();
    for r in (
        select ep.name as element_name
          from app_structure s
          join app_element ep on ep.id = s.parent_element_id
          join app_element ec on ec.id = s.element_id
         where ep.element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_COMPLEX
           and ec.name = 'ERROR'
      group by ep.name
    ) loop
        g_block_tab(r.element_name) := null;
    end loop;
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '->init: g_block_tab.count() = ' || g_block_tab.count());    

end app_api_error_pkg;
/
