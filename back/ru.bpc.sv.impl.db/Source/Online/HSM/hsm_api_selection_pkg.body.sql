create or replace package body hsm_api_selection_pkg is
/************************************************************
 * API for HSM selection <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.07.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: hsm_api_selection_pkg <br />
 * @headcom
 ************************************************************/

    function select_hsm (
        i_inst_id                   in com_api_type_pkg.t_inst_id
        , i_action                  in com_api_type_pkg.t_dict_value
        , i_params                  in com_api_type_pkg.t_param_tab
    ) return com_api_type_pkg.t_tiny_id is
        l_hsm_id                    com_api_type_pkg.t_number_tab;
    begin
        l_hsm_id := select_all_hsm (
            i_inst_id   => i_inst_id
            , i_action  => i_action
            , i_params  => i_params
        );

        if l_hsm_id.count > 0 then
            return l_hsm_id(1);
        end if;
        
        com_api_error_pkg.raise_error (
            i_error       => 'NO_HSM_DEVICE_FOR_ACTION'
          , i_env_param1  => i_action
        );
    end;

    function select_hsm (
        i_inst_id                   in com_api_type_pkg.t_inst_id
        , i_agent_id                in com_api_type_pkg.t_agent_id
        , i_hsm_id                  in com_api_type_pkg.t_tiny_id
        , i_action                  in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_tiny_id is
        l_ref_cur                   sys_refcursor;
        l_result                    com_api_type_pkg.t_tiny_id;
        l_hsm_id                    com_api_type_pkg.t_number_tab;
        l_params                    com_api_type_pkg.t_param_tab;
        l_sql_source                com_api_type_pkg.t_full_desc;
        l_where_clause              com_api_type_pkg.t_full_desc;
        l_orderby                   com_api_type_pkg.t_full_desc := ' order by id';
    begin
        l_params.delete;
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => i_inst_id
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'AGENT_ID'
            , i_value    => i_agent_id
            , io_params  => l_params
        );
        
        l_hsm_id := select_all_hsm (
            i_inst_id   => i_inst_id
            , i_action  => i_action
            , i_params  => l_params
        );

        l_sql_source := 'select id from hsm_device_vw';
        
        l_where_clause := ' where 1=1 ';
        if l_hsm_id.count > 0 then
            l_where_clause := l_where_clause || 'and id in (';
            for i in 1 .. l_hsm_id.count loop
                l_where_clause := l_where_clause || l_hsm_id(i) || ', ';
            end loop;
            l_where_clause := rtrim(l_where_clause, ', ') || ')';
        else
            l_where_clause := l_where_clause || 'and 1=0';
        end if;
        l_where_clause := l_where_clause || ' and is_enabled = com_api_type_pkg.TRUE';

        l_sql_source :=  l_sql_source || l_where_clause || l_orderby;

        trc_log_pkg.debug (
            i_text          => 'Going to execute query for HSM selection: [#1]'
            , i_env_param1  => l_sql_source
        );

        begin
            open l_ref_cur for l_sql_source;
        exception
            when others then
                com_api_error_pkg.raise_error (
                    i_error         => 'EXEC_HSM_SELECT_QUERY_ERROR'
                    , i_env_param1  => substr(l_sql_source, 1, 2000)
                    , i_env_param2  => substr(sqlerrm, 1, 200)
                );
        end;
        
        loop
            fetch l_ref_cur into l_result;
            exit when l_ref_cur%notfound;
                
            if i_hsm_id is not null then
                if l_result = i_hsm_id then
                    close l_ref_cur;
                    return l_result;
                end if;
            else
                close l_ref_cur;
                return l_result;
            end if;
        end loop;
        close l_ref_cur;

        com_api_error_pkg.raise_error (
            i_error       => 'NO_HSM_DEVICE_FOR_ACTION'
          , i_env_param1  => i_action
        );
    exception
        when others then
            if l_ref_cur%isopen then
                close l_ref_cur;
            end if;
            raise;
    end;

    function select_all_hsm (
        i_inst_id                   in com_api_type_pkg.t_inst_id
        , i_action                  in com_api_type_pkg.t_dict_value
        , i_params                  in com_api_type_pkg.t_param_tab
    ) return com_api_type_pkg.t_number_tab is
        l_hsm_id                    com_api_type_pkg.t_number_tab;
    begin
        for r in (
            select
                l.mod_id
                , l.hsm_device_id hsm_id
            from
                hsm_selection l
                , (
                    select
                        m.id mod_id
                        , m.priority
                    from
                        rul_mod_scale s
                        , rul_mod m
                    where
                        s.scale_type = rul_api_const_pkg.SCALE_TYPE_CHOISE_HSM
                        and s.inst_id = i_inst_id
                        and s.id = m.scale_id
                ) m
            where
                l.action = i_action
                and ( l.inst_id = i_inst_id
                      or l.inst_id = ost_api_const_pkg.default_inst )
                and m.mod_id(+) = l.mod_id
            order by
                decode(l.inst_id, i_inst_id, 0, 1), m.priority
        ) loop
            if r.mod_id is null
               or
               rul_api_mod_pkg.check_condition(
                   i_mod_id     => r.mod_id
                   , i_params   => i_params
               ) = com_api_const_pkg.TRUE
            then
                l_hsm_id(l_hsm_id.count+1) := r.hsm_id;
            end if;
        end loop;
        
        return l_hsm_id;
    end;

end; 
/
