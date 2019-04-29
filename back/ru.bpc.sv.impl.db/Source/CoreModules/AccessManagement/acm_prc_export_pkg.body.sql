create or replace package body acm_prc_export_pkg as
/*********************************************************
*  Export&Import utility for Access Managment module (ACM) <br />
*  Created by Truschelev O.(truschelev@bpcbt.com) at 30.06.2015 <br />
*  Last changed by $Author: truschelev $ <br />
*  $LastChangedDate:: 2015-08-17 12:15:00 +0300#$ <br />
*  Revision: $LastChangedRevision: 52893 $ <br />
*  Module: ACM_PRC_EXPORT_PKG <br />
*  @headcom
**********************************************************/

C_CRLF                 constant     com_api_type_pkg.t_name        := chr(13) || chr(10);
FILE_TYPE_ROLE         constant     com_api_type_pkg.t_dict_value  := 'FLTPROLE';
BULK_LIMIT             constant     com_api_type_pkg.t_short_id    := 1000;

g_role_list            num_tab_tpt := num_tab_tpt();
g_export_record_count  pls_integer;
g_role_i18n            clob;
g_privilege_i18n       clob;
g_priv_limitation_i18n clob;

-- It's reference table between old limit id and new limit id.
type t_limit_id_tab is table of com_api_type_pkg.t_short_id index by varchar2(8);
g_limit_id_tab         t_limit_id_tab;

-- It's types for acm_priv_limitation record from XML file.
type t_acm_priv_limitation_rec  is record (
    old_id             com_api_type_pkg.t_short_id
  , priv_name          com_api_type_pkg.t_name
  , condition          com_api_type_pkg.t_full_desc
  , seqnum             com_api_type_pkg.t_tiny_id
);

type t_acm_priv_limitation_tab  is varray(1000) of t_acm_priv_limitation_rec;

-- It's types for acm_role_object record from XML file.
type t_acm_role_object_rec  is record (
    role_name          com_api_type_pkg.t_name
  , entity_type        com_api_type_pkg.t_dict_value
  , object_id          com_api_type_pkg.t_long_id
);

type t_acm_role_object_tab  is varray(1000) of t_acm_role_object_rec;


/*
 * Generate XML block for acm_role record.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
function generate_acm_role(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) return xmltype
is
    l_xml_block    xmltype;
    l_count        pls_integer    := 0;    
begin

    select xmlelement("acm_roles"
             , xmlagg(
                   xmlelement("acm_role"
                     , xmlelement("name",              ar.name)
                     , xmlelement("notif_scheme_type", ar.notif_scheme_type)
                     , xmlelement("inst_id",           ar.inst_id)
                   )
               )
           )               xml_block
         , xmlagg(
               (
                   select
                       xmlagg(
                           xmlelement("com_i18n"
                             , xmlelement("lang",         c.lang)
                             , case 
                                   when c.entity_type is not null
                                   then xmlelement("entity_type",  c.entity_type)
                                   else null
                               end
                             , xmlelement("table_name",   c.table_name)
                             , xmlelement("column_name",  c.column_name)
                             , xmlelement("object_name",  ar.name)
                             , xmlelement("text",         c.text)
                           )
                       )
                   from com_i18n c
                  where c.table_name = 'ACM_ROLE'
                    and c.object_id  = ar.id
               )
           ).getclobval()  i18n_block
           , count(1)      cnt
      into l_xml_block
         , g_role_i18n
         , l_count
      from (
          select ar.id
               , ar.name
               , (select ns.scheme_type
                    from ntf_scheme ns
                    where ns.id = ar.notif_scheme_id
                 )  notif_scheme_type
               , (case when ar.inst_id = 1001 then ar.inst_id else 9999 end)  inst_id
            from acm_role ar
           where ar.name != acm_api_const_pkg.ROLE_ROOT
             and (i_role_id is null
                  or exists (
                         select 1
                           from table(cast(g_role_list as num_tab_tpt)) rl2
                          where rl2.column_value = ar.id
                     )
                 )
      ) ar;

    g_export_record_count := g_export_record_count + l_count;

    trc_log_pkg.debug(
        i_text          => 'acm_role count: [#1]'
      , i_env_param1    => l_count
    );

    return l_xml_block;

exception
    when others then
        trc_log_pkg.error('Error when generate acm_role block for i_role_id = ' || i_role_id);
        trc_log_pkg.error(sqlerrm);
        return null;
end generate_acm_role;

/*
 * Generate XML block for acm_privilege record.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
function generate_acm_privilege(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) return xmltype
is
    l_xml_block    xmltype;
    l_count        pls_integer    := 0;    
begin

    select xmlelement("acm_privileges"
             , xmlagg(
                   xmlelement("acm_privilege"
                     , xmlelement("name",        ap.name)
                     , xmlelement("section_id",  ap.section_id)
                     , xmlelement("module_code", ap.module_code)
                     , xmlelement("is_active",   ap.is_active)
                   )
               )
           )               xml_block
         , xmlagg(
               (
                   select
                       xmlagg(
                           xmlelement("com_i18n"
                             , xmlelement("lang",         c.lang)
                             , case 
                                   when c.entity_type is not null
                                   then xmlelement("entity_type",  c.entity_type)
                                   else null
                               end
                             , xmlelement("table_name",   c.table_name)
                             , xmlelement("column_name",  c.column_name)
                             , xmlelement("object_name",  ap.name)
                             , xmlelement("text",         c.text)
                           )
                       )
                   from com_i18n c
                  where c.table_name = 'ACM_PRIVILEGE'
                    and c.object_id  = ap.id
               )
           ).getclobval()  i18n_block
         , count(1)        cnt
      into l_xml_block
         , g_privilege_i18n
         , l_count
      from (
          select ap.id
               , ap.name
               , ap.section_id
               , ap.module_code
               , ap.is_active
            from acm_privilege ap
           where i_role_id is null
              or exists (
                     select 1
                       from table(cast(g_role_list as num_tab_tpt)) rl2
                          , acm_role_privilege arp2
                      where rl2.column_value  = arp2.role_id
                        and arp2.priv_id = ap.id
                 )
      ) ap;

    g_export_record_count := g_export_record_count + l_count;

    trc_log_pkg.debug(
        i_text          => 'acm_privilege count: [#1]'
      , i_env_param1    => l_count
    );

    return l_xml_block;

exception
    when others then
        trc_log_pkg.error('Error when generate acm_privilege block for i_role_id = ' || i_role_id);
        trc_log_pkg.error(sqlerrm);
        return null;
end generate_acm_privilege;

/*
 * Generate XML block for acm_role_role record.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
function generate_acm_role_role(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) return xmltype
is
    l_xml_block    xmltype;
    l_count        pls_integer    := 0;    
begin

    select xmlelement("acm_role_roles"
             , xmlagg(
                   xmlelement("acm_role_role"
                     , xmlelement("parent_role_name", arr.parent_role_name)
                     , xmlelement("child_role_name",  arr.child_role_name)
                   )
               )
           )         xml_block
         , count(1)  cnt
      into l_xml_block
         , l_count
      from (
          select ar1.name parent_role_name
               , ar2.name child_role_name
            from acm_role_role arr
               , acm_role ar1
               , acm_role ar2
           where ar1.id = arr.parent_role_id
             and ar2.id = arr.child_role_id
             and (i_role_id is null
                  or exists (
                         select 1
                           from table(cast(g_role_list as num_tab_tpt)) rl2
                          where rl2.column_value = arr.parent_role_id
                     )
                 )
      ) arr;

    g_export_record_count := g_export_record_count + l_count;

    trc_log_pkg.debug(
        i_text          => 'acm_role_role count: [#1]'
      , i_env_param1    => l_count
    );

    return l_xml_block;

exception
    when others then
        trc_log_pkg.error('Error when generate acm_role_role block for i_role_id = ' || i_role_id);
        trc_log_pkg.error(sqlerrm);
        return null;
end generate_acm_role_role;

/*
 * Generate XML block for acm_priv_limitation record.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
function generate_acm_priv_limitation(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) return xmltype
is
    l_xml_block    xmltype;
    l_count        pls_integer    := 0;    
begin

    select xmlelement("acm_priv_limitations"
             , xmlagg(
                   xmlelement("acm_priv_limitation"
                     , xmlelement("old_id",    apl.old_id)
                     , xmlelement("priv_name", apl.priv_name)
                     , xmlelement("condition", apl.condition)
                     , xmlelement("seqnum",    apl.seqnum)
                   )
               )
           )               xml_block
         , xmlagg(
               (
                   select
                       xmlagg(
                           xmlelement("com_i18n"
                             , xmlelement("lang",         c.lang)
                             , case 
                                   when c.entity_type is not null
                                   then xmlelement("entity_type",  c.entity_type)
                                   else null
                               end
                             , xmlelement("table_name",   c.table_name)
                             , xmlelement("column_name",  c.column_name)
                             , xmlelement("object_id",    c.object_id)
                             , xmlelement("text",         c.text)
                           )
                       )
                   from com_i18n c
                  where c.table_name = 'ACM_PRIV_LIMITATION'
                    and c.object_id  = apl.old_id
               )
           ).getclobval()  i18n_block
         , count(1)        cnt
      into l_xml_block
         , g_priv_limitation_i18n
         , l_count
      from (
          select apl.id   old_id
               , ap.name  priv_name
               , apl.condition
               , apl.seqnum
            from acm_priv_limitation apl
               , acm_privilege ap
           where ap.id = apl.priv_id
             and (i_role_id is null
                  or exists (
                         select 1
                           from table(cast(g_role_list as num_tab_tpt)) rl2
                              , acm_role_privilege arp2
                          where rl2.column_value  = arp2.role_id
                            and arp2.priv_id = ap.id
                     )
                 )
      ) apl;

    g_export_record_count  := g_export_record_count + l_count;

    trc_log_pkg.debug(
        i_text          => 'acm_priv_limitation count: [#1]'
      , i_env_param1    => l_count
    );

    return l_xml_block;

exception
    when others then
        trc_log_pkg.error('Error when generate acm_priv_limitation block for i_role_id = ' || i_role_id);
        trc_log_pkg.error(sqlerrm);
        return null;
end generate_acm_priv_limitation;

/*
 * Generate XML block for acm_role_privilege record.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
function generate_acm_role_privilege(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) return xmltype
is
    l_xml_block    xmltype;
    l_count        pls_integer    := 0;    
begin

    select xmlelement("acm_role_privileges"
             , xmlagg(
                   xmlelement("acm_role_privilege"
                       , xmlelement("role_name", arp.role_name)
                       , xmlelement("priv_name", arp.priv_name)
                       , xmlelement("limit_id",  arp.limit_id)
                   )
               )
           )           xml_block
           , count(1)  cnt
      into l_xml_block
         , l_count
      from (
          select ar.name role_name
               , ap.name priv_name
               , arp.limit_id
            from acm_role_privilege arp
               , acm_role ar
               , acm_privilege ap
           where ar.id = arp.role_id
             and ap.id = arp.priv_id
             and (i_role_id is null
                  or exists (
                         select 1
                           from table(cast(g_role_list as num_tab_tpt)) rl2
                          where rl2.column_value = arp.role_id
                     )
                 )
      ) arp;

    g_export_record_count := g_export_record_count + l_count;

    trc_log_pkg.debug(
        i_text          => 'acm_role_privilege count: [#1]'
      , i_env_param1    => l_count
    );

    return l_xml_block;

exception
    when others then
        trc_log_pkg.error('Error when generate acm_role_privilege block for i_role_id = ' || i_role_id);
        trc_log_pkg.error(sqlerrm);
        return null;
end generate_acm_role_privilege;

/*
 * Generate XML block for acm_role_object record.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
function generate_acm_role_object(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) return xmltype
is
    l_xml_block    xmltype;
    l_count        pls_integer    := 0;    
begin

    select xmlelement("acm_role_objects"
             , xmlagg(
                   xmlelement("acm_role_object"
                     , xmlelement("role_name",   aro.role_name)
                     , xmlelement("entity_type", aro.entity_type)
                     , xmlelement("object_id",   aro.object_id)
                   )
               )
           )           xml_block
           , count(1)  cnt
      into l_xml_block
         , l_count
      from (
          select ar.name role_name
               , aro.entity_type
               , aro.object_id
            from acm_role_object aro
               , acm_role ar
           where ar.id = aro.role_id
             and (i_role_id is null
                  or exists (
                           select 1
                             from table(cast(g_role_list as num_tab_tpt)) rl2
                            where rl2.column_value = aro.role_id
                     )
                 )
             and (
                     -- Export only references to core objects.
                     (aro.entity_type in ('ENTTPRCS', 'ENTTREPT') and aro.object_id between 10000000 and 49999999)
                     or
                     (aro.entity_type in ('ENTT0026', 'ENTT0096') and aro.object_id between 1000 and 4999)
                 )
      ) aro;

    g_export_record_count := g_export_record_count + l_count;

    trc_log_pkg.debug(
        i_text          => 'acm_role_object count: [#1]'
      , i_env_param1    => l_count
    );

    return l_xml_block;

exception
    when others then
        trc_log_pkg.error('Error when generate acm_role_object block for i_role_id = ' || i_role_id);
        trc_log_pkg.error(sqlerrm);
        return null;
end generate_acm_role_object;

/*
 * Export either one or all roles into XML file.
 * Any parent role will exported with his child roles.
 * @param i_role_id  -  This role will be exported.
 *                      If it is NULL then all roles will be exported.
 */
procedure export_roles(
    i_role_id   in  com_api_type_pkg.t_tiny_id
) is
    l_sysdate          date                       := com_api_sttl_day_pkg.get_sysdate;
    l_sess_file_id     com_api_type_pkg.t_long_id;
    l_file             clob;
    l_estimated_count  com_api_type_pkg.t_long_id := 0;
begin
    savepoint sp_export_roles;

    trc_log_pkg.debug(
        i_text          => 'Start roles export: i_role_id=[#1], l_sysdate=[#2]'
      , i_env_param1    => nvl(to_char(i_role_id), 'NULL')
      , i_env_param2    => to_char(l_sysdate, 'dd.mm.yyyy hh24:mi:ss')
    );

    prc_api_stat_pkg.log_start;

    -- Reset global variables.
    g_role_list.delete;
    g_export_record_count  := 0;
    g_role_i18n            := null;
    g_privilege_i18n       := null;
    g_priv_limitation_i18n := null;

    -- Create role list using parameter value i_role_id.
    for rec in (
        select i_role_id role_id
           from dual
        union
        select arr.child_role_id role_id
          from acm_role_role arr
          where i_role_id is not null
          connect by prior arr.child_role_id = arr.parent_role_id
          start with arr.parent_role_id = i_role_id
    )
    loop
        g_role_list.extend;
        g_role_list(g_role_list.count) := rec.role_id;
    end loop;

    -- Generate XML file.

    select '<?xml version="1.0" encoding="utf-8"?>'
        || C_CRLF
        || '<export_roles>'
        || xmlconcat(
               xmlelement("file_type", FILE_TYPE_ROLE)
             , xmlelement("role_id",   i_role_id)
             , generate_acm_role(i_role_id)
             , generate_acm_privilege(i_role_id)
             , generate_acm_role_role(i_role_id)
             , generate_acm_priv_limitation(i_role_id)
             , generate_acm_role_privilege(i_role_id)
             , generate_acm_role_object(i_role_id)
           ).getclobval()  xml_file
      into l_file
      from dual;

    l_file := l_file || '<com_i18ns>' || g_role_i18n || g_privilege_i18n || g_priv_limitation_i18n || '</com_i18ns></export_roles>';


    -- Update statistics.

    l_estimated_count := g_export_record_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count  => l_estimated_count
    );

    trc_log_pkg.debug(
        i_text          => 'export records [#1]'
      , i_env_param1    => l_estimated_count
    );

    prc_api_stat_pkg.log_current(
        i_current_count   => l_estimated_count
      , i_excepted_count  => 0
    );


    -- Save XML file if it exists.

    if l_estimated_count = 0 then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
        
    else
        trc_log_pkg.debug(
            i_text          => 'before open file'
        );

        prc_api_file_pkg.open_file(
            o_sess_file_id => l_sess_file_id
          , i_file_type    => FILE_TYPE_ROLE
        );

        trc_log_pkg.debug(
            i_text          => 'l_sess_file_id [#1]'
          , i_env_param1    => l_sess_file_id  
        );

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_sess_file_id
          , i_clob_content  => l_file
        );
        trc_log_pkg.debug(
            i_text          => 'file length [#1], records exported [#2]'
          , i_env_param1    => length(l_file)
          , i_env_param2    => l_estimated_count 
        );
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_sess_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count  => l_estimated_count
        );
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

    end if;

    trc_log_pkg.debug(
        i_text          => 'Roles exporting finished'
    );

exception
    when others then
        rollback to sp_export_roles;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        
        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;    

end export_roles;

/*
 * Register new acm_priv_limitation record from XML file.
 * @param io_acm_priv_limitation_rec  -  It's current record for merging.
 */
procedure register_acm_priv_limitation(
    io_acm_priv_limitation_rec  in out nocopy  t_acm_priv_limitation_rec
) is
    l_new_id     com_api_type_pkg.t_short_id;
    l_priv_id    com_api_type_pkg.t_short_id;
begin

    trc_log_pkg.debug(
        i_text          => 'priv_limitation: [#1] [#2] [#3]'
      , i_env_param1    => io_acm_priv_limitation_rec.priv_name
      , i_env_param2    => io_acm_priv_limitation_rec.condition
      , i_env_param3    => io_acm_priv_limitation_rec.seqnum
    );

    begin
        select ap.id
          into l_priv_id
          from acm_privilege ap
         where ap.name = io_acm_priv_limitation_rec.priv_name;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'OBJECT_NOT_FOUND'
              , i_env_param1 => com_api_dictionary_pkg.get_article_desc(
                                    i_article => 'ENTT0012'
                                )
              , i_env_param2 => io_acm_priv_limitation_rec.priv_name
            );
    end;

    trc_log_pkg.debug(
        i_text          => 'priv_limitation: l_priv_id [#1]'
      , i_env_param1    => l_priv_id
    );


    merge into acm_priv_limitation dst
    using (
        select l_priv_id                             priv_id
             , io_acm_priv_limitation_rec.condition  condition
             , io_acm_priv_limitation_rec.seqnum     seqnum
          from dual
    ) src
    on (
            src.priv_id          = dst.priv_id
        and upper(src.condition) = upper(dst.condition)
    )
    when matched then
        update set dst.seqnum =  src.seqnum
    when not matched then
        insert (
              dst.id
            , dst.priv_id
            , dst.condition
            , dst.seqnum
        ) values (
              acm_priv_limitation_seq.nextval
            , src.priv_id
            , src.condition
            , src.seqnum
        );

    -- Fill reference table between old limit id and new limit id.
    if not g_limit_id_tab.exists(io_acm_priv_limitation_rec.old_id) then

      select apl.id
        into l_new_id
        from acm_priv_limitation apl, acm_privilege ap
        where ap.name              = io_acm_priv_limitation_rec.priv_name
          and apl.priv_id          = ap.id
          and upper(apl.condition) = upper(io_acm_priv_limitation_rec.condition);

      g_limit_id_tab(io_acm_priv_limitation_rec.old_id) := l_new_id;

    end if;

end register_acm_priv_limitation;

/*
 * Register new acm_role_object record from XML file.
 * @param io_acm_role_object_rec  -  It's current record for merging.
 */
procedure register_acm_role_object(
    io_acm_role_object_rec  in out nocopy  t_acm_role_object_rec
) is
    l_process_id             com_api_type_pkg.t_short_id;
    l_report_id              com_api_type_pkg.t_short_id;
    l_app_flow_id            com_api_type_pkg.t_tiny_id;
    l_entity_oper_type_id    com_api_type_pkg.t_tiny_id;
    l_role_id                com_api_type_pkg.t_tiny_id;
begin

    begin
        select ar.id
          into l_role_id
          from acm_role ar
         where ar.name = io_acm_role_object_rec.role_name;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'OBJECT_NOT_FOUND'
              , i_env_param1 => com_api_dictionary_pkg.get_article_desc(
                                    i_article => 'ENTTROLE'
                                )
              , i_env_param2 => io_acm_role_object_rec.role_name
            );
    end;

    begin
        if    io_acm_role_object_rec.entity_type = 'ENTTPRCS' then

            select id
              into l_process_id
              from prc_process
             where id = io_acm_role_object_rec.object_id;

        elsif io_acm_role_object_rec.entity_type = 'ENTTREPT' then

            select id
              into l_report_id
              from rpt_report
             where id = io_acm_role_object_rec.object_id;

        elsif io_acm_role_object_rec.entity_type = 'ENTT0026' then

            select id
              into l_app_flow_id
              from app_flow
             where id = io_acm_role_object_rec.object_id;

        elsif io_acm_role_object_rec.entity_type = 'ENTT0096' then

            select id
              into l_entity_oper_type_id
              from opr_entity_oper_type
             where id = io_acm_role_object_rec.object_id;

        end if;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'OBJECT_NOT_FOUND'
              , i_env_param1 => com_api_dictionary_pkg.get_article_desc(
                                    i_article => io_acm_role_object_rec.entity_type
                                )
              , i_env_param2 => io_acm_role_object_rec.object_id
            );
    end;


    merge into acm_role_object dst
    using (
        select l_role_id                            role_id
             , io_acm_role_object_rec.entity_type   entity_type
             , io_acm_role_object_rec.object_id     object_id
          from dual
    ) src
    on (
            src.role_id     = dst.role_id
        and src.entity_type = dst.entity_type
        and src.object_id   = dst.object_id
    )
    when not matched then
        insert (
              dst.id
            , dst.role_id
            , dst.entity_type
            , dst.object_id
        ) values (
              acm_role_object_seq.nextval
            , src.role_id
            , src.entity_type
            , src.object_id
        );

end register_acm_role_object;

/*
 * Import acm_role records from XML file.
 * @param io_xml_file  -  It's imported XML file.
 */
procedure import_acm_role(
    io_xml_file         in out  nocopy  xmltype
  , io_processed_count  in out  com_api_type_pkg.t_long_id
  , io_excepted_count   in out  com_api_type_pkg.t_long_id
) is

    l_inst_id              com_api_type_pkg.t_tiny_id;
    l_role_id              com_api_type_pkg.t_tiny_id;
    l_notif_scheme_id      com_api_type_pkg.t_tiny_id;

    type t_acm_role_rec  is record (
        old_id             com_api_type_pkg.t_tiny_id
      , name               com_api_type_pkg.t_name
      , notif_scheme_type  com_api_type_pkg.t_dict_value
      , inst_id            com_api_type_pkg.t_tiny_id
    );

    type t_acm_role_tab  is varray(1000) of t_acm_role_rec;
    l_acm_role_tab         t_acm_role_tab;

    -- Read XML for acm_role records.
    cursor cur_acm_role is
        select x.old_id
             , x.name
             , x.notif_scheme_type
             , x.inst_id
          from xmltable('/acm_roles/acm_role'
                  passing io_xml_file
                  columns old_id             number(4)           path 'old_id'
                        , name               varchar2(200 char)  path 'name'
                        , notif_scheme_type  varchar2(8 char)    path 'notif_scheme_type'
                        , inst_id            number(4)           path 'inst_id'
               ) x;

begin
    trc_log_pkg.debug(
        i_text          => 'Start acm_role import'
    );

    l_inst_id := ost_api_institution_pkg.get_sandbox;

    open cur_acm_role;

    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching #1 acm_role records'
          , i_env_param1    => BULK_LIMIT
        );

        fetch cur_acm_role bulk collect into l_acm_role_tab limit BULK_LIMIT;

        trc_log_pkg.debug(
            i_text          => '#1 acm_role fetched'
          , i_env_param1    => l_acm_role_tab.count
        );

        for i in 1 .. l_acm_role_tab.count loop
            savepoint sp_import_acm_role;

            begin
                if l_acm_role_tab(i).notif_scheme_type is not null then
                    select ns.id
                      into l_notif_scheme_id
                      from ntf_scheme ns
                     where ns.scheme_type = l_acm_role_tab(i).notif_scheme_type
                       and ns.inst_id     = l_inst_id;
                end if;

                l_acm_role_tab(i).name := upper(l_acm_role_tab(i).name);

                begin
                    select ar.id
                      into l_role_id
                      from acm_role ar
                     where ar.name = l_acm_role_tab(i).name;
                exception
                    when no_data_found then
                        l_role_id := null;
                end;

                acm_ui_role_pkg.add_role(
                    i_role_name       => l_acm_role_tab(i).name
                  , i_role_short_desc => null
                  , i_role_full_desc  => null
                  , i_role_lang       => null
                  , i_notif_scheme_id => l_notif_scheme_id
                  , io_role_id        => l_role_id
                );

                io_processed_count := io_processed_count + 1;

            exception
                when others then
                    rollback to savepoint sp_import_acm_role;
                    trc_log_pkg.error(
                        i_text          => 'acm_role record with error: #1'
                      , i_env_param1    => i
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        io_excepted_count := io_excepted_count + 1;

                    else
                        close cur_acm_role;
                        raise;

                    end if;
            end;

            if mod(io_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => io_processed_count
                  , i_excepted_count    => io_excepted_count
                );
            end if;
        end loop;

        exit when cur_acm_role%notfound;

    end loop;

    close cur_acm_role;

    trc_log_pkg.debug(
        i_text          => 'acm_role importing finished'
    );

exception
    when others then
        if cur_acm_role%isopen then
            close cur_acm_role;
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;

end import_acm_role;

/*
 * Import acm_privilege records from XML file.
 * @param io_xml_file  -  It's imported XML file.
 */
procedure import_acm_privilege(
    io_xml_file         in out  nocopy  xmltype
  , io_processed_count  in out  com_api_type_pkg.t_long_id
  , io_excepted_count   in out  com_api_type_pkg.t_long_id
) is

    l_privilege_id         com_api_type_pkg.t_short_id;
    l_section_id           com_api_type_pkg.t_tiny_id;

    type t_acm_privilege_rec  is record (
        old_id             com_api_type_pkg.t_short_id
      , name               com_api_type_pkg.t_name
      , section_id         com_api_type_pkg.t_tiny_id
      , module_code        com_api_type_pkg.t_module_code
      , is_active          com_api_type_pkg.t_boolean
    );

    type t_acm_privilege_tab  is varray(1000) of t_acm_privilege_rec;
    l_acm_privilege_tab    t_acm_privilege_tab;

    -- Read XML for acm_privilege records.
    cursor cur_acm_privilege is
        select x.old_id
             , x.name
             , x.section_id
             , x.module_code
             , x.is_active
          from xmltable('/acm_privileges/acm_privilege'
                  passing io_xml_file
                  columns old_id           number(8)           path 'old_id'
                        , name             varchar2(200 char)  path 'name'
                        , section_id       number(4)           path 'section_id'
                        , module_code      varchar2(3 char)    path 'module_code'
                        , is_active        number(1)           path 'is_active'
               ) x;

begin
    trc_log_pkg.debug(
        i_text          => 'Start acm_privilege import'
    );

    open cur_acm_privilege;

    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching #1 acm_privilege records'
          , i_env_param1    => BULK_LIMIT
        );

        fetch cur_acm_privilege bulk collect into l_acm_privilege_tab limit BULK_LIMIT;

        trc_log_pkg.debug(
            i_text          => '#1 acm_privilege fetched'
          , i_env_param1    => l_acm_privilege_tab.count
        );

        for i in 1 .. l_acm_privilege_tab.count loop
            savepoint sp_import_acm_privilege;

            begin
                if l_acm_privilege_tab(i).section_id is not null then
                    begin
                        select id
                          into l_section_id
                          from acm_section
                         where id = l_acm_privilege_tab(i).section_id;
                    exception
                        when no_data_found then
                            com_api_error_pkg.raise_error(
                                i_error      => 'OBJECT_NOT_FOUND'
                              , i_env_param1 => com_api_dictionary_pkg.get_article_desc(
                                                    i_article => 'ENTT0014'
                                                )
                              , i_env_param2 => l_acm_privilege_tab(i).section_id
                            );
                    end;
                end if;

                begin
                    select ap.id
                      into l_privilege_id
                      from acm_privilege ap
                     where ap.name = l_acm_privilege_tab(i).name;
                exception
                    when no_data_found then
                        l_privilege_id := null;
                end;

                acm_ui_privilege_pkg.add_privilege (
                    io_id        => l_privilege_id
                  , i_name       => l_acm_privilege_tab(i).name
                  , i_short_desc => null
                  , i_full_desc  => null
                  , i_lang       => null
                  , i_module     => l_acm_privilege_tab(i).module_code
                  , i_is_active  => l_acm_privilege_tab(i).is_active
                  , i_section_id => l_acm_privilege_tab(i).section_id
                );

                io_processed_count := io_processed_count + 1;

            exception
                when others then
                    rollback to savepoint sp_import_acm_privilege;
                    trc_log_pkg.error(
                        i_text          => 'acm_privilege record with error: #1'
                      , i_env_param1    => i
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        io_excepted_count := io_excepted_count + 1;

                    else
                        close cur_acm_privilege;
                        raise;

                    end if;
            end;

            if mod(io_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => io_processed_count
                  , i_excepted_count    => io_excepted_count
                );
            end if;
        end loop;

        exit when cur_acm_privilege%notfound;

    end loop;

    close cur_acm_privilege;

    trc_log_pkg.debug(
        i_text          => 'acm_privilege importing finished'
    );

exception
    when others then
        if cur_acm_privilege%isopen then
            close cur_acm_privilege;
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;

end import_acm_privilege;

/*
 * Import acm_role_role records from XML file.
 * @param io_xml_file  -  It's imported XML file.
 */
procedure import_acm_role_role(
    io_xml_file         in out  nocopy  xmltype
  , io_processed_count  in out  com_api_type_pkg.t_long_id
  , io_excepted_count   in out  com_api_type_pkg.t_long_id
) is

    l_new_id               com_api_type_pkg.t_short_id;
    l_parent_role_id       com_api_type_pkg.t_tiny_id;
    l_child_role_id        com_api_type_pkg.t_tiny_id;

    type t_acm_role_role_rec  is record (
        parent_role_name   com_api_type_pkg.t_name
      , child_role_name    com_api_type_pkg.t_name
    );

    type t_acm_role_role_tab  is varray(1000) of t_acm_role_role_rec;
    l_acm_role_role_tab    t_acm_role_role_tab;

    -- Read XML for acm_role_role records.
    cursor cur_acm_role_role is
        select x.parent_role_name
             , x.child_role_name
          from xmltable('/acm_role_roles/acm_role_role'
                  passing io_xml_file
                  columns parent_role_name   varchar2(200 char)  path 'parent_role_name'
                        , child_role_name    varchar2(200 char)  path 'child_role_name'
               ) x;

begin
    trc_log_pkg.debug(
        i_text          => 'Start acm_role_role import'
    );

    open cur_acm_role_role;

    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching #1 acm_role_role records'
          , i_env_param1    => BULK_LIMIT
        );

        fetch cur_acm_role_role bulk collect into l_acm_role_role_tab limit BULK_LIMIT;

        trc_log_pkg.debug(
            i_text          => '#1 acm_role_role fetched'
          , i_env_param1    => l_acm_role_role_tab.count
        );

        for i in 1 .. l_acm_role_role_tab.count loop
            savepoint sp_import_acm_role_role;

            begin
                begin
                    select ar1.id
                      into l_parent_role_id
                      from acm_role ar1
                     where ar1.name = l_acm_role_role_tab(i).parent_role_name;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(
                            i_error      => 'OBJECT_NOT_FOUND'
                          , i_env_param1 => com_api_dictionary_pkg.get_article_desc(
                                                i_article => 'ENTTROLE'
                                            )
                          , i_env_param2 => l_acm_role_role_tab(i).parent_role_name
                        );
                end;

                begin
                    select ar2.id
                      into l_child_role_id
                      from acm_role ar2
                     where ar2.name = l_acm_role_role_tab(i).child_role_name;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(
                            i_error      => 'OBJECT_NOT_FOUND'
                          , i_env_param1 => com_api_dictionary_pkg.get_article_desc(
                                                i_article => 'ENTTROLE'
                                            )
                          , i_env_param2 => l_acm_role_role_tab(i).child_role_name
                        );
                end;

                begin
                    select arr.id
                      into l_new_id
                      from acm_role_role arr
                     where arr.child_role_id  = l_child_role_id
                       and arr.parent_role_id = l_parent_role_id;
                exception
                    when no_data_found then
                        acm_ui_role_pkg.add_role_in_role(
                            i_role_child  => l_child_role_id
                          , i_role_parent => l_parent_role_id
                          , o_id          => l_new_id
                        );
                end;

                io_processed_count := io_processed_count + 1;

            exception
                when others then
                    rollback to savepoint sp_import_acm_role_role;
                    trc_log_pkg.error(
                        i_text          => 'acm_role_role record with error: #1'
                      , i_env_param1    => i
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        io_excepted_count := io_excepted_count + 1;

                    else
                        close cur_acm_role_role;
                        raise;

                    end if;
            end;

            if mod(io_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => io_processed_count
                  , i_excepted_count    => io_excepted_count
                );
            end if;
        end loop;

        exit when cur_acm_role_role%notfound;

    end loop;

    close cur_acm_role_role;

    trc_log_pkg.debug(
        i_text          => 'acm_role_role importing finished'
    );

exception
    when others then
        if cur_acm_role_role%isopen then
            close cur_acm_role_role;
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;

end import_acm_role_role;

/*
 * Import acm_priv_limitation records from XML file.
 * @param io_xml_file  -  It's imported XML file.
 */
procedure import_acm_priv_limitation(
    io_xml_file         in out  nocopy  xmltype
  , io_processed_count  in out  com_api_type_pkg.t_long_id
  , io_excepted_count   in out  com_api_type_pkg.t_long_id
) is

    l_acm_priv_limitation_tab  t_acm_priv_limitation_tab;

    -- Read XML for acm_priv_limitation records.
    cursor cur_acm_priv_limitation is
        select x.old_id
             , x.priv_name
             , x.condition
             , x.seqnum
          from xmltable('/acm_priv_limitations/acm_priv_limitation'
                  passing io_xml_file
                  columns old_id      number(8)           path 'old_id'
                        , priv_name   varchar2(200 char)  path 'priv_name'
                        , condition   varchar2(2000 char) path 'condition'
                        , seqnum      number(4)           path 'seqnum'
               ) x;

begin
    trc_log_pkg.debug(
        i_text          => 'Start acm_priv_limitation import'
    );

    open cur_acm_priv_limitation;

    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching #1 acm_priv_limitation records'
          , i_env_param1    => BULK_LIMIT
        );

        fetch cur_acm_priv_limitation bulk collect into l_acm_priv_limitation_tab limit BULK_LIMIT;

        trc_log_pkg.debug(
            i_text          => '#1 acm_priv_limitation fetched'
          , i_env_param1    => l_acm_priv_limitation_tab.count
        );

        for i in 1 .. l_acm_priv_limitation_tab.count loop
            savepoint sp_import_acm_priv_limitation;

            begin
                -- The method acm_ui_limitation_pkg.modify_limitation contains the error PRIVILEGE_LIMITATION_IN_USE.
                -- Therefore we can not use this method for import operation.
                -- Also we can not update condition by id's value for import operation.
                register_acm_priv_limitation(
                    io_acm_priv_limitation_rec  =>  l_acm_priv_limitation_tab(i)
                );

                io_processed_count := io_processed_count + 1;

            exception
                when others then
                    rollback to savepoint sp_import_acm_priv_limitation;
                    trc_log_pkg.error(
                        i_text          => 'acm_priv_limitation record with error: #1'
                      , i_env_param1    => i
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        io_excepted_count := io_excepted_count + 1;

                    else
                        close cur_acm_priv_limitation;
                        raise;

                    end if;
            end;

            if mod(io_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => io_processed_count
                  , i_excepted_count    => io_excepted_count
                );
            end if;
        end loop;

        exit when cur_acm_priv_limitation%notfound;

    end loop;

    close cur_acm_priv_limitation;

    trc_log_pkg.debug(
        i_text          => 'acm_priv_limitation importing finished'
    );

exception
    when others then
        if cur_acm_priv_limitation%isopen then
            close cur_acm_priv_limitation;
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;

end import_acm_priv_limitation;

/*
 * Import acm_role_privilege records from XML file.
 * @param io_xml_file  -  It's imported XML file.
 */
procedure import_acm_role_privilege(
    io_xml_file         in out  nocopy  xmltype
  , io_processed_count  in out  com_api_type_pkg.t_long_id
  , io_excepted_count   in out  com_api_type_pkg.t_long_id
) is

    l_role_privilege_id         com_api_type_pkg.t_short_id;
    l_role_id                   com_api_type_pkg.t_tiny_id;
    l_priv_id                   com_api_type_pkg.t_short_id;
    l_limit_id                  com_api_type_pkg.t_short_id;
    l_new_id                    com_api_type_pkg.t_short_id;

    type t_acm_role_privilege_rec  is record (
        role_name          com_api_type_pkg.t_name
      , priv_name          com_api_type_pkg.t_name
      , limit_id           com_api_type_pkg.t_short_id
    );

    type t_acm_role_privilege_tab  is varray(1000) of t_acm_role_privilege_rec;
    l_acm_role_privilege_tab    t_acm_role_privilege_tab;

    -- Read XML for acm_role_privilege records.
    cursor cur_acm_role_privilege is
        select x.role_name
             , x.priv_name
             , x.limit_id
          from xmltable('/acm_role_privileges/acm_role_privilege'
                  passing io_xml_file
                  columns role_name   varchar2(200 char)  path 'role_name'
                        , priv_name   varchar2(200 char)  path 'priv_name'
                        , limit_id    number(8)           path 'limit_id'
               ) x;

begin
    trc_log_pkg.debug(
        i_text          => 'Start acm_role_privilege import'
    );

    open cur_acm_role_privilege;

    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching #1 acm_role_privilege records'
          , i_env_param1    => BULK_LIMIT
        );

        fetch cur_acm_role_privilege bulk collect into l_acm_role_privilege_tab limit BULK_LIMIT;

        trc_log_pkg.debug(
            i_text          => '#1 acm_role_privilege fetched'
          , i_env_param1    => l_acm_role_privilege_tab.count
        );

        for i in 1 .. l_acm_role_privilege_tab.count loop
            savepoint sp_import_acm_role_privilege;

            begin
                begin
                    select ar.id
                      into l_role_id
                      from acm_role ar
                     where ar.name = l_acm_role_privilege_tab(i).role_name;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(
                            i_error      => 'OBJECT_NOT_FOUND'
                          , i_env_param1 => com_api_dictionary_pkg.get_article_desc(
                                                i_article => 'ENTTROLE'
                                            )
                          , i_env_param2 => l_acm_role_privilege_tab(i).role_name
                        );
                end;

                begin
                    select ap.id
                      into l_priv_id
                      from acm_privilege ap
                     where ap.name = l_acm_role_privilege_tab(i).priv_name;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(
                            i_error      => 'OBJECT_NOT_FOUND'
                          , i_env_param1 => com_api_dictionary_pkg.get_article_desc(
                                                i_article => 'ENTT0012'
                                            )
                          , i_env_param2 => l_acm_role_privilege_tab(i).priv_name
                        );
                end;

                if l_acm_role_privilege_tab(i).limit_id is not null then
                    if not g_limit_id_tab.exists(l_acm_role_privilege_tab(i).limit_id) then
                        com_api_error_pkg.raise_error(
                            i_error      => 'PRIV_LIMITATION_ID_NOT_FOUND'
                          , i_env_param1  => l_acm_role_privilege_tab(i).limit_id
                        );
                    end if;

                    l_limit_id := g_limit_id_tab(l_acm_role_privilege_tab(i).limit_id);
                end if;

                begin
                    select arp.id
                      into l_role_privilege_id
                      from acm_role_privilege arp
                     where arp.role_id = l_role_id
                       and arp.priv_id = l_priv_id;
                exception
                    when no_data_found then
                        l_role_privilege_id := null;
                end;

                if l_role_privilege_id is null then
                    acm_ui_privilege_pkg.add_privilege_role (
                        o_id       => l_new_id
                      , i_role_id  => l_role_id
                      , i_priv_id  => l_priv_id
                      , i_limit_id => l_limit_id
                    );
                else
                    acm_ui_privilege_pkg.set_limitation (
                        i_role_id   => l_role_id
                      , i_priv_id   => l_priv_id
                      , i_limit_id  => l_limit_id
                    );
                end if;

                io_processed_count := io_processed_count + 1;

            exception
                when others then
                    rollback to savepoint sp_import_acm_role_privilege;
                    trc_log_pkg.error(
                        i_text          => 'acm_role_privilege record with error: #1'
                      , i_env_param1    => i
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        io_excepted_count := io_excepted_count + 1;

                    else
                        close cur_acm_role_privilege;
                        raise;

                    end if;
            end;

            if mod(io_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => io_processed_count
                  , i_excepted_count    => io_excepted_count
                );
            end if;
        end loop;

        exit when cur_acm_role_privilege%notfound;

    end loop;

    close cur_acm_role_privilege;

    trc_log_pkg.debug(
        i_text          => 'acm_role_privilege importing finished'
    );

exception
    when others then
        if cur_acm_role_privilege%isopen then
            close cur_acm_role_privilege;
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;

end import_acm_role_privilege;

/*
 * Import acm_role_object records from XML file.
 * @param io_xml_file  -  It's imported XML file.
 */
procedure import_acm_role_object(
    io_xml_file         in out  nocopy  xmltype
  , io_processed_count  in out  com_api_type_pkg.t_long_id
  , io_excepted_count   in out  com_api_type_pkg.t_long_id
) is

    l_acm_role_object_tab  t_acm_role_object_tab;

    -- Read XML for acm_role_object records.
    cursor cur_acm_role_object is
        select x.role_name
             , x.entity_type
             , x.object_id
          from xmltable('/acm_role_objects/acm_role_object'
                  passing io_xml_file
                  columns role_name   varchar2(200 char)  path 'role_name'
                        , entity_type varchar2(8 char)    path 'entity_type'
                        , object_id   number(16)          path 'object_id'
               ) x;

begin
    trc_log_pkg.debug(
        i_text          => 'Start acm_role_object import'
    );

    open cur_acm_role_object;

    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching #1 acm_role_object records'
          , i_env_param1    => BULK_LIMIT
        );

        fetch cur_acm_role_object bulk collect into l_acm_role_object_tab limit BULK_LIMIT;

        trc_log_pkg.debug(
            i_text          => '#1 acm_role_object fetched'
          , i_env_param1    => l_acm_role_object_tab.count
        );

        for i in 1 .. l_acm_role_object_tab.count loop
            savepoint sp_import_acm_role_object;

            begin
                -- In package acm_ui_role_pkg the methods add_role_object, add_role_prc, add_role_rpt hasn't got the error message if object isn't exists.
                -- Therefore we can not use this method for import operation.
                register_acm_role_object(
                    io_acm_role_object_rec  =>  l_acm_role_object_tab(i)
                );

                io_processed_count := io_processed_count + 1;

            exception
                when others then
                    rollback to savepoint sp_import_acm_role_object;
                    trc_log_pkg.error(
                        i_text          => 'acm_role_object record with error: #1'
                      , i_env_param1    => i
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        io_excepted_count := io_excepted_count + 1;

                    else
                        close cur_acm_role_object;
                        raise;

                    end if;
            end;

            if mod(io_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => io_processed_count
                  , i_excepted_count    => io_excepted_count
                );
            end if;
        end loop;

        exit when cur_acm_role_object%notfound;

    end loop;

    close cur_acm_role_object;

    trc_log_pkg.debug(
        i_text          => 'acm_role_object importing finished'
    );

exception
    when others then
        if cur_acm_role_object%isopen then
            close cur_acm_role_object;
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;

end import_acm_role_object;

/*
 * Import com_i18n records from XML file.
 * @param io_xml_file  -  It's imported XML file.
 */
procedure import_com_i18n(
    io_xml_file         in out  nocopy  xmltype
  , io_processed_count  in out  com_api_type_pkg.t_long_id
  , io_excepted_count   in out  com_api_type_pkg.t_long_id
) is

    l_new_id     com_api_type_pkg.t_short_id;

    type t_com_i18n_rec  is record (
        lang               com_api_type_pkg.t_dict_value
      , entity_type        com_api_type_pkg.t_dict_value
      , table_name         com_api_type_pkg.t_name
      , column_name        com_api_type_pkg.t_name
      , object_id          com_api_type_pkg.t_long_id
      , object_name        com_api_type_pkg.t_name
      , text               com_api_type_pkg.t_text
    );

    type t_com_i18n_tab  is varray(1000) of t_com_i18n_rec;
    l_com_i18n_tab  t_com_i18n_tab;

    -- Read XML for com_i18n records.
    cursor cur_com_i18n is
        select x.lang
             , x.entity_type
             , x.table_name
             , x.column_name
             , x.object_id
             , x.object_name
             , x.text
          from xmltable('/com_i18ns/com_i18n'
                  passing io_xml_file
                  columns lang        varchar2(8 char)    path 'lang'
                        , entity_type varchar2(8 char)    path 'entity_type'
                        , table_name  varchar2(30 char)   path 'table_name'
                        , column_name varchar2(30 char)   path 'column_name'
                        , object_id   number(16)          path 'object_id'
                        , object_name varchar2(200 char)  path 'object_name'
                        , text        varchar2(4000 char) path 'text'
               ) x;

begin
    trc_log_pkg.debug(
        i_text          => 'Start com_i18n import'
    );

    open cur_com_i18n;

    loop
        trc_log_pkg.debug(
            i_text          => 'start fetching #1 com_i18n records'
          , i_env_param1    => BULK_LIMIT
        );

        fetch cur_com_i18n bulk collect into l_com_i18n_tab limit BULK_LIMIT;

        trc_log_pkg.debug(
            i_text          => '#1 com_i18n fetched'
          , i_env_param1    => l_com_i18n_tab.count
        );

        for i in 1 .. l_com_i18n_tab.count loop
            savepoint sp_import_com_i18n;

            begin
                if    l_com_i18n_tab(i).table_name = 'ACM_ROLE' then
                    begin
                        select ar.id
                          into l_new_id
                          from acm_role ar
                         where ar.name = l_com_i18n_tab(i).object_name;
                    exception
                        when no_data_found then
                            com_api_error_pkg.raise_error(
                                i_error      => 'OBJECT_NOT_FOUND'
                              , i_env_param1 => com_api_dictionary_pkg.get_article_desc(
                                                    i_article => 'ENTTROLE'
                                                )
                              , i_env_param2 => l_com_i18n_tab(i).object_name
                            );
                    end;

                elsif l_com_i18n_tab(i).table_name = 'ACM_PRIVILEGE' then
                    begin
                        select ap.id
                          into l_new_id
                          from acm_privilege ap
                         where ap.name = l_com_i18n_tab(i).object_name;
                    exception
                        when no_data_found then
                            com_api_error_pkg.raise_error(
                                i_error      => 'OBJECT_NOT_FOUND'
                              , i_env_param1 => com_api_dictionary_pkg.get_article_desc(
                                                    i_article => 'ENTT0012'
                                                )
                              , i_env_param2 => l_com_i18n_tab(i).object_name
                            );
                    end;

                elsif l_com_i18n_tab(i).table_name = 'ACM_PRIV_LIMITATION' then
                    if not g_limit_id_tab.exists(l_com_i18n_tab(i).object_id) then
                        com_api_error_pkg.raise_error(
                            i_error       => 'PRIV_LIMITATION_ID_NOT_FOUND'
                          , i_env_param1  => l_com_i18n_tab(i).object_id
                        );
                    end if;

                    l_new_id := g_limit_id_tab(l_com_i18n_tab(i).object_id);

                else
                    -- Other tables is not supported now.
                    com_api_error_pkg.raise_error(
                        i_error       => 'TABLE_NOT_SUPPORTED'
                      , i_env_param1  => l_com_i18n_tab(i).table_name
                    );
                end if;

                com_api_i18n_pkg.add_text (
                    i_table_name    => l_com_i18n_tab(i).table_name
                  , i_column_name   => l_com_i18n_tab(i).column_name
                  , i_object_id     => l_new_id
                  , i_text          => l_com_i18n_tab(i).text
                  , i_lang          => l_com_i18n_tab(i).lang
                );

                io_processed_count := io_processed_count + 1;

            exception
                when others then
                    rollback to savepoint sp_import_com_i18n;
                    trc_log_pkg.error(
                        i_text          => 'com_i18n record with error: #1'
                      , i_env_param1    => i
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        io_excepted_count := io_excepted_count + 1;

                    else
                        close cur_com_i18n;
                        raise;

                    end if;
            end;

            if mod(io_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => io_processed_count
                  , i_excepted_count    => io_excepted_count
                );
            end if;
        end loop;

        exit when cur_com_i18n%notfound;

    end loop;

    close cur_com_i18n;

    trc_log_pkg.debug(
        i_text          => 'com_i18n importing finished'
    );

exception
    when others then
        if cur_com_i18n%isopen then
            close cur_com_i18n;
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;

end import_com_i18n;

/*
* Calculate the record count from XML file.
* @param io_xml_file  -  It's imported XML file.
*/
function get_estimated_count(
    io_xml_file in out nocopy xmltype
) return pls_integer
is
    l_estimated_count pls_integer;
begin
    trc_log_pkg.debug(
        i_text          => 'get_estimated_count'
    );

    select sum(
               x.record_count
           )
     into l_estimated_count
     from xmltable(
            '/export_roles'
            passing io_xml_file
            columns
                  record_count    number
                      path 'fn:count(acm_roles/acm_role | acm_privileges/acm_privilege | acm_role_roles/acm_role_role | acm_priv_limitations/acm_priv_limitation | acm_role_privileges/acm_role_privilege | acm_role_objects/acm_role_object)'
          ) x;

    trc_log_pkg.debug(
        i_text          => 'get_estimated_count: [#1]'
      , i_env_param1    => l_estimated_count
    );

    return l_estimated_count;
end get_estimated_count;

/*
 * Import roles from XML file.
 */
procedure import_roles is
    l_sysdate               date                       := com_api_sttl_day_pkg.get_sysdate;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_i18n_processed_count  com_api_type_pkg.t_long_id := 0;
    l_i18n_excepted_count   com_api_type_pkg.t_long_id := 0;
    l_estimated_count       com_api_type_pkg.t_long_id;
    l_acm_roles             xmltype;
    l_acm_privileges        xmltype;
    l_acm_role_roles        xmltype;
    l_acm_priv_limitations  xmltype;
    l_acm_role_privileges   xmltype;
    l_acm_role_objects      xmltype;
    l_com_i18ns             xmltype;
begin

    savepoint sp_import_roles;

    trc_log_pkg.debug(
        i_text          => 'Start roles import: l_sysdate=[#1]'
      , i_env_param1    => to_char(l_sysdate, 'dd.mm.yyyy hh24:mi:ss')
    );

    prc_api_stat_pkg.log_start;

    -- get files
    for r in (
        select s.file_name
             , s.file_xml_contents  xml_file
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where s.session_id   = get_session_id
           and s.file_attr_id = a.id
           and f.id           = a.file_id
           and f.file_type    = FILE_TYPE_ROLE
           and f.file_purpose = prc_api_const_pkg.FILE_PURPOSE_IN
           and f.file_nature  = prc_api_const_pkg.FILE_NATURE_XML
    ) loop

        trc_log_pkg.debug (
            i_text          => 'Process file [#1]'
          , i_env_param1    => r.file_name
        );

        g_limit_id_tab.delete;

        -- Calculate the record count from XML file.
        l_estimated_count := get_estimated_count(
                                 io_xml_file => r.xml_file
                             );

        prc_api_stat_pkg.log_estimation(
            i_estimated_count   => l_estimated_count
        );

        -- Import all parts of XML file.

        select x.acm_roles
             , x.acm_privileges
             , x.acm_role_roles
             , x.acm_priv_limitations
             , x.acm_role_privileges
             , x.acm_role_objects
             , x.com_i18ns
          into l_acm_roles
             , l_acm_privileges
             , l_acm_role_roles
             , l_acm_priv_limitations
             , l_acm_role_privileges
             , l_acm_role_objects
             , l_com_i18ns
          from xmltable('/export_roles'
                  passing r.xml_file
                  columns acm_roles               xmltype    path 'acm_roles'
                        , acm_privileges          xmltype    path 'acm_privileges'
                        , acm_role_roles          xmltype    path 'acm_role_roles'
                        , acm_priv_limitations    xmltype    path 'acm_priv_limitations'
                        , acm_role_privileges     xmltype    path 'acm_role_privileges'
                        , acm_role_objects        xmltype    path 'acm_role_objects'
                        , com_i18ns               xmltype    path 'com_i18ns'
               ) x;

        import_acm_role(
            io_xml_file         =>  l_acm_roles
          , io_processed_count  =>  l_processed_count
          , io_excepted_count   =>  l_excepted_count
        );

        import_acm_privilege(
            io_xml_file         =>  l_acm_privileges
          , io_processed_count  =>  l_processed_count
          , io_excepted_count   =>  l_excepted_count
        );

        import_acm_role_role(
            io_xml_file         =>  l_acm_role_roles
          , io_processed_count  =>  l_processed_count
          , io_excepted_count   =>  l_excepted_count
        );

        import_acm_priv_limitation(
            io_xml_file         =>  l_acm_priv_limitations
          , io_processed_count  =>  l_processed_count
          , io_excepted_count   =>  l_excepted_count
        );

        import_acm_role_privilege(
            io_xml_file         =>  l_acm_role_privileges
          , io_processed_count  =>  l_processed_count
          , io_excepted_count   =>  l_excepted_count
        );

        import_acm_role_object(
            io_xml_file         =>  l_acm_role_objects
          , io_processed_count  =>  l_processed_count
          , io_excepted_count   =>  l_excepted_count
        );

        import_com_i18n(
            io_xml_file         =>  l_com_i18ns
          , io_processed_count  =>  l_i18n_processed_count
          , io_excepted_count   =>  l_i18n_excepted_count
        );

        trc_log_pkg.debug (
            i_text              => 'l_processed_count [#1], l_excepted_count [#2]'
          , i_env_param1        => l_processed_count
          , i_env_param2        => l_excepted_count
        );

        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
          , i_excepted_count    => l_excepted_count
        );

        trc_log_pkg.debug (
            i_text              => 'l_i18n_processed_count [#1], l_i18n_excepted_count [#2]'
          , i_env_param1        => l_i18n_processed_count
          , i_env_param2        => l_i18n_excepted_count
        );

    end loop;

    prc_api_stat_pkg.log_end (
        i_processed_total       => l_processed_count
      , i_excepted_total        => l_excepted_count
      , i_result_code           => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text                  => 'Roles importing finished'
    );

exception
    when others then
        rollback to savepoint sp_import_roles;

        prc_api_stat_pkg.log_end (
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;

end import_roles;

end acm_prc_export_pkg;
/
