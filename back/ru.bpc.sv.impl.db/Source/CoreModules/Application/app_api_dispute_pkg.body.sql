create or replace package body app_api_dispute_pkg as
/**************************************************
 *  Dispute application API <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 15.11.2016 <br />
 *  Module: APP_API_DISPUTE_PKG <br />
 *  @headcom
 ***************************************************/

procedure determine_user(
    i_flow_id                  in     com_api_type_pkg.t_tiny_id
  , i_appl_status              in     com_api_type_pkg.t_dict_value
  , i_reject_code              in     com_api_type_pkg.t_dict_value
  , o_user_id                     out com_api_type_pkg.t_short_id
) is
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.determine_user ';
    e_role_is_not_defined      exception; 
    l_role_id                  com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_flow_id [' || i_flow_id
                                   || '], i_appl_status [#1], i_reject_code [#2]'
      , i_env_param1 => i_appl_status
      , i_env_param2 => i_reject_code
    );

    begin
        select role_id
          into l_role_id
          from app_flow_stage fs
         where fs.flow_id               = i_flow_id
           and fs.appl_status           = i_appl_status
           and nvl(fs.reject_code, '~') = nvl(i_reject_code, '~');
    exception
        when no_data_found then
            raise e_role_is_not_defined;
    end;

    trc_log_pkg.debug('l_role_id [' || l_role_id || ']');

    -- Check history and find applications with specified status and reject code,
    -- select a user with minimal count of found applications
    select min(user_id) keep (dense_rank first order by cnt)
      into o_user_id
      from (
          select ur.user_id
               , count(distinct h.appl_id) as cnt
            from app_history   h
            join acm_user_role ur
                on ur.user_id = h.change_user
           where h.appl_status           = i_appl_status
             and nvl(h.reject_code, '~') = nvl(i_reject_code, '~')
             and ur.role_id              = l_role_id
             and ur.user_id             != get_user_id()
        group by ur.user_id
      );

    trc_log_pkg.debug('Defined by history o_user_id [' || l_role_id || ']');

    -- If search in history fails, look through all users with found role and select one with
    -- minimal count of applications with specified flow ID, status and reject code
    if o_user_id is null then
        select min(user_id) keep (dense_rank first order by cnt)
          into o_user_id
          from (
              select ur.user_id
                   , count(a.id) as cnt
                from      acm_user_role    ur
                left join app_application  a
                       on a.user_id               = ur.user_id
                      and a.flow_id               = i_flow_id
                      and a.appl_status           = i_appl_status
                      and nvl(a.reject_code, '~') = nvl(i_reject_code, '~')
               where ur.role_id  = l_role_id
                 and ur.user_id != get_user_id()
            group by ur.user_id
          );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> o_user_id [' || o_user_id || ']'
    );
exception
    when e_role_is_not_defined then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> role is not defined, quit'
        );
end determine_user;

/*
 * Find element DUE_DATE in the specified application and update its value with a new one,
 * add new element if it doesn't exist.
 * @i_appl_id    -- application ID of type APTPDSPT, it must exist, no checks are intended(!)
 * @i_due_date   -- new value for DUE_DATE element
 */
procedure set_due_date(
    i_appl_id                  in     com_api_type_pkg.t_long_id
  , i_due_date                 in     date
) is
    l_parent_id                com_api_type_pkg.t_long_id;
    l_appl_data_id             com_api_type_pkg.t_long_id;
begin
    app_api_application_pkg.get_appl_data(i_appl_id => i_appl_id);

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'APPLICATION'
      , i_parent_id     => null
      , o_appl_data_id  => l_parent_id
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'DUE_DATE'
      , i_parent_id     => l_parent_id
      , o_appl_data_id  => l_appl_data_id
    );

    if l_appl_data_id is null then
        app_api_application_pkg.add_element(
            i_element_name      => 'DUE_DATE'
          , i_parent_id         => l_parent_id
          , i_element_value     => i_due_date
        );
    else
        app_api_application_pkg.modify_element(
            i_appl_data_id      => l_appl_data_id
          , i_element_value     => i_due_date
        );
    end if;
end set_due_date;

end;
/
