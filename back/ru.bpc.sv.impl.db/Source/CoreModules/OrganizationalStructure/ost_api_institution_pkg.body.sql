create or replace package body ost_api_institution_pkg as
/*********************************************************
 *  API for institution <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com) at 09.09.2009 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate:: 2016-02-02 14:00:00 +0300#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: OST_API_INSTITUTION_PKG <br />
 *  @headcom
 **********************************************************/

g_sandbox_tab               com_api_type_pkg.t_inst_id_tab;
g_multi_institution         com_api_type_pkg.t_boolean      := com_api_type_pkg.FALSE;

function get_network_inst_id(
    i_network_id        in  com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_inst_id is
    l_inst_id               com_api_type_pkg.t_inst_id;
begin
    select i.id
      into l_inst_id
      from ost_institution i
         , net_network n
     where i.network_id = i_network_id
       and n.id         = i.network_id
       and n.inst_id    = i.id;

    return l_inst_id;
exception
    when no_data_found then
        return null;
    when too_many_rows then
        com_api_error_pkg.raise_error(
            i_error         => 'TOO_MANY_INSTITUTIONS'
          , i_env_param1    => i_network_id
        );
end;

function get_inst_network (
    i_inst_id           in com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_tiny_id is
    l_result            com_api_type_pkg.t_tiny_id;
begin
    select network_id into l_result from ost_institution where id = i_inst_id;
    return l_result;
exception
    when no_data_found then
        return null;
    when too_many_rows then
        com_api_error_pkg.raise_error(
            i_error         => 'TOO_MANY_NETWORKS'
          , i_env_param1    => i_inst_id
        );
end;

function get_default_agent(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_agent_id is
    l_agent_id          com_api_type_pkg.t_agent_id;
begin
    select id into l_agent_id from ost_agent_vw where inst_id = i_inst_id and is_default = com_api_type_pkg.TRUE;
    return l_agent_id;
exception
    when no_data_found then
        return null;
end;

function get_parent_inst_id(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_inst_id is
    l_result            com_api_type_pkg.t_inst_id;
begin
    select parent_id into l_result from ost_institution_vw where id = i_inst_id;

    return l_result;
exception
    when no_data_found then
        return null;
end;

--function get_root_inst_id(
--    i_inst_id           in      com_api_type_pkg.t_inst_id
--) return com_api_type_pkg.t_inst_id
--is
--    l_root_inst_id      com_api_type_pkg.t_inst_id;
--begin
--    begin
--            select id
--              into l_root_inst_id
--              from ost_institution
--             where connect_by_isleaf = 1
--        start with id = i_inst_id
--        connect by id = prior parent_id;
--    exception
--        when no_data_found then
--            null;
--    end;
--    return l_root_inst_id;
--end;

function get_object_inst_id(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_mask_errors       in      com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_inst_id is
    l_result        com_api_type_pkg.t_inst_id;
    l_table_name    com_api_type_pkg.t_oracle_name;
begin
    if i_entity_type in (com_api_const_pkg.ENTITY_TYPE_PERSON, com_api_const_pkg.ENTITY_TYPE_COMPANY) then
        begin
            select inst_id
              into l_result
              from prd_customer
             where entity_type = i_entity_type
               and object_id   = i_object_id;
        exception
            when no_data_found then
                if i_mask_errors = com_api_const_pkg.FALSE then
                    com_api_error_pkg.raise_error(
                        i_error         => 'OBJECT_NOT_FOUND'
                      , i_env_param1    => i_entity_type
                      , i_env_param2    => i_object_id
                    );
                else
                    return null;
                end if;
        end;
    else
        l_table_name := utl_deploy_pkg.get_entity_table(i_entity_type => i_entity_type);
        if l_table_name is null then
            if i_mask_errors = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error         => 'ENTITY_TYPE_NOT_FOUND'
                  , i_env_param1    => i_entity_type
                );
            else
                return null;
            end if;
        end if;

        if utl_deploy_pkg.check_column(l_table_name, 'inst_id') = 1 then
            begin
                execute immediate 'select inst_id from '||l_table_name||' where id = :p_id'
                   into l_result
                  using i_object_id;
            exception
                when no_data_found then
                    if i_mask_errors = com_api_const_pkg.FALSE then
                        com_api_error_pkg.raise_error(
                            i_error         => 'OBJECT_NOT_FOUND'
                          , i_env_param1    => i_entity_type
                          , i_env_param2    => i_object_id
                        );
                    else
                        return null;
                    end if;
            end;
        else
            l_result := com_ui_user_env_pkg.get_user_inst;
        end if;
    end if;
    return l_result;
exception
    when others then
        if i_mask_errors = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => substr(sqlerrm, 1, 2000)
            );
        else
            return null;
        end if;

end get_object_inst_id;

function get_sandbox(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_inst_id is
    l_multi_institution         com_api_type_pkg.t_boolean;
    l_list_id                   com_api_type_pkg.t_inst_id;
    LOG_PREFIX                  com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_sandbox: ';

begin

    trc_log_pkg.debug(LOG_PREFIX || 'inst_id = ' || i_inst_id);
    if i_inst_id is null then
        return ost_api_const_pkg.DEFAULT_INST;
    end if;

    l_multi_institution := nvl( set_ui_value_pkg.get_system_param_n( i_param_name => 'MULTI_INSTITUTION' ), com_api_type_pkg.FALSE );
    trc_log_pkg.debug(LOG_PREFIX || 'multi_institution = ' || l_multi_institution);

    if g_multi_institution != l_multi_institution then
        g_sandbox_tab.delete;
        g_multi_institution := l_multi_institution;
    end if;

    begin

        l_list_id := g_sandbox_tab(i_inst_id);
        trc_log_pkg.debug(LOG_PREFIX || 'return list_id = ' || l_list_id);
        return l_list_id;

    exception
        when no_data_found then
            trc_log_pkg.debug(LOG_PREFIX || 'no_data_found, multi_institution = ' || l_multi_institution);
            if l_multi_institution = com_api_type_pkg.TRUE then
                for r in (
                    select i.id as inst_id
                      from ost_institution_vw i
                     where connect_by_isleaf = 1
                     start with id = i_inst_id
                     connect by id = prior parent_id
                ) loop
                    g_sandbox_tab(i_inst_id) := r.inst_id;
                    trc_log_pkg.debug(LOG_PREFIX || 'added ' || r.inst_id || ' and return it');
                    return r.inst_id;
                end loop;
            end if;
            g_sandbox_tab(i_inst_id) := acm_api_user_pkg.get_user_sandbox;
            trc_log_pkg.debug(LOG_PREFIX || 'after loop, added ' || acm_api_user_pkg.get_user_sandbox || ' and return it');
            return g_sandbox_tab(i_inst_id);
    end;
end;

/*
 * Procedure checks if specified institution exists in the system, and raises an error if it is not.
 */
procedure check_institution(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_id                        com_api_type_pkg.t_inst_id;
begin
    select i.id
      into l_id
      from ost_institution i
     where i.id = i_inst_id;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'INSTITUTION_IS_NOT_DEFINED'
          , i_env_param1 => i_inst_id
        );
end check_institution;

procedure check_inst_id(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_inst_id                   com_api_type_pkg.t_inst_id;
begin
    select i.inst_id
      into l_inst_id
      from acm_cu_inst_vw i
     where i.inst_id = i_inst_id;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'INSTITUTION_NOT_ACCESS'
          , i_env_param1 => i_inst_id
        );
end check_inst_id;

-- Get institution number by id
function get_inst_number(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_mcc
result_cache
relies_on (ost_institution)
is
    l_inst_number               com_api_type_pkg.t_mcc;
begin
    if i_inst_id = ost_api_const_pkg.DEFAULT_INST then
        l_inst_number := to_char(ost_api_const_pkg.DEFAULT_INST, com_api_const_pkg.XML_NUMBER_FORMAT);
    else
        select institution_number
          into l_inst_number
          from ost_institution
         where id = i_inst_id;
    end if;

    return l_inst_number;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'INSTITUTION_IS_NOT_DEFINED'
          , i_env_param1 => i_inst_id
        );
end;

procedure check_status(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_data_action       in      com_api_type_pkg.t_dict_value
)
is
begin
    for rec in (
        select a.inst_status
          from ost_institution i
             , ost_forbidden_action a
         where i.status      = a.inst_status
           and a.data_action = i_data_action
    ) loop
        com_api_error_pkg.raise_error(
            i_error        => 'FORBIDDEN_ACTION_IN_INSTITUTION'
          , i_env_param1   => i_data_action
          , i_env_param2   => i_inst_id
          , i_env_param3   => rec.inst_status
        );
    end loop;
end;

function check_status(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_data_action       in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean
result_cache
relies_on (ost_institution, ost_forbidden_action) is
begin
   for rec in (
        select a.inst_status
          from ost_institution i
             , ost_forbidden_action a
         where i.status      = a.inst_status
           and a.data_action = i_data_action
    ) loop
        return com_api_const_pkg.FALSE;
    end loop;

    return com_api_const_pkg.TRUE;
end;

end ost_api_institution_pkg;
/
