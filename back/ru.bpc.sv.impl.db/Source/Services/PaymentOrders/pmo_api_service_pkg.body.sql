create or replace package body pmo_api_service_pkg as
/************************************************************
 * API for Payment Service<br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 24.08.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_API_SERVICE_PKG <br />
 * @headcom
 ************************************************************/

procedure get_all_services(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , o_service_id_tab           out  com_api_type_pkg.t_number_tab
  , o_service_name_tab         out  com_api_type_pkg.t_name_tab
) is
    l_params                com_api_type_pkg.t_param_tab;
    l_mods                  num_tab_tpt := num_tab_tpt(null);
    l_purpose_mods          num_tab_tpt := num_tab_tpt(null);
begin

    opr_api_shared_data_pkg.collect_auth_params(
        i_id            => i_auth_id
      , io_params       => l_params
    );

    rul_api_mod_pkg.select_mods(
        i_scale_type    => pmo_api_const_pkg.PROVIDER_HOST_SCALE_TYPE
      , i_params        => l_params
      , o_mods          => l_mods
    );

    rul_api_mod_pkg.select_mods(
        i_scale_type    => pmo_api_const_pkg.PURPOSE_SCALE_TYPE
      , i_params        => l_params
      , o_mods          => l_purpose_mods
    );

    select a.id
         , a.label
      bulk collect into
           o_service_id_tab
         , o_service_name_tab
      from pmo_ui_service_vw a
     where a.lang = i_lang
       and a.id in (
            select c.service_id
              from pmo_provider_host b
                 , pmo_purpose c
             where b.provider_id = c.provider_id
               and (b.mod_id is null or exists
                     (select 1 from table(cast(l_mods as num_tab_tpt)) d where d.column_value = b.mod_id))
               and (c.mod_id is null or exists      
                     (select 1 from table(cast(l_purpose_mods as num_tab_tpt)) p where p.column_value = c.mod_id))
           )
	order by a.label;           
end;

procedure get_own_services(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , o_service_id_tab           out  com_api_type_pkg.t_number_tab
  , o_service_name_tab         out  com_api_type_pkg.t_name_tab
) is
    l_params                com_api_type_pkg.t_param_tab;
    l_mods                  num_tab_tpt := num_tab_tpt(null);
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_purpose_mods          num_tab_tpt := num_tab_tpt(null);
begin

    opr_api_shared_data_pkg.collect_auth_params(
        i_id            => i_auth_id
      , io_params       => l_params
    );

    l_customer_id       := rul_api_param_pkg.get_param_num('CUSTOMER_ID', l_params);

    if l_customer_id is null then
        return;
    end if;

    rul_api_mod_pkg.select_mods(
        i_scale_type    => pmo_api_const_pkg.PROVIDER_HOST_SCALE_TYPE
      , i_params        => l_params
      , o_mods          => l_mods
    );

    rul_api_mod_pkg.select_mods(
        i_scale_type    => pmo_api_const_pkg.PURPOSE_SCALE_TYPE
      , i_params        => l_params
      , o_mods          => l_purpose_mods
    );

    select a.id
         , a.label
      bulk collect into
           o_service_id_tab
         , o_service_name_tab
      from pmo_ui_service_vw a
     where a.lang = i_lang
       and a.id in (
            select c.service_id
              from pmo_provider_host b
                 , pmo_purpose c
                 , pmo_order e
             where (b.mod_id is null or exists
                             (select 1 from table(cast(l_mods as num_tab_tpt)) d where d.column_value = b.mod_id))
               and (c.mod_id is null or exists      
                             (select 1 from table(cast(l_purpose_mods as num_tab_tpt)) p where p.column_value = c.mod_id))
               and b.provider_id   = c.provider_id
               and e.customer_id   = l_customer_id
               and e.purpose_id    = c.id
               and e.is_template   = 1
           );
end;

procedure get_all_purposes(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_service_id            in      com_api_type_pkg.t_short_id
  , o_purpose_id_tab           out  com_api_type_pkg.t_number_tab
  , o_purpose_name_tab         out  com_api_type_pkg.t_name_tab
) is
    l_params                com_api_type_pkg.t_param_tab;
    l_mods                  num_tab_tpt := num_tab_tpt(null);
    l_purpose_mods          num_tab_tpt := num_tab_tpt(null);
begin

    opr_api_shared_data_pkg.collect_auth_params(
        i_id            => i_auth_id
      , io_params       => l_params
    );

    rul_api_mod_pkg.select_mods(
        i_scale_type    => pmo_api_const_pkg.PROVIDER_HOST_SCALE_TYPE
      , i_params        => l_params
      , o_mods          => l_mods
    );

    rul_api_mod_pkg.select_mods(
        i_scale_type    => pmo_api_const_pkg.PURPOSE_SCALE_TYPE
      , i_params        => l_params
      , o_mods          => l_purpose_mods
    );

    select c.id
         , a.label
      bulk collect into
           o_purpose_id_tab
         , o_purpose_name_tab
      from pmo_ui_provider_vw a
         , pmo_purpose c
     where a.lang          = i_lang
       and c.service_id    = i_service_id
       and a.id            = c.provider_id
       and (c.mod_id is null or exists      
                     (select 1 from table(cast(l_purpose_mods as num_tab_tpt)) p where p.column_value = c.mod_id))
       and exists (select null 
                     from pmo_provider_host b 
                    where b.provider_id = c.provider_id
                      and (b.mod_id is null 
                           or exists (select null 
                                        from table(cast(l_mods as num_tab_tpt)) d 
                                       where d.column_value = b.mod_id)));
end;

/*
 * Returns outgoing collections with data about purposes, providers and provider groups.
 * @param i_provider_group_id – identifiers of a root provider group, may be NULL
 * @param o_is_group_tab      – o_is_group_tab(i) indicates whether o_purpose_id_tab(i) is group's or purpose's identifier  
 * @param o_purpose_name_tab  – contains names (labels) of providers or provider groups (depends on o_is_group_tab)  
 */
procedure get_all_purposes(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_service_id            in      com_api_type_pkg.t_short_id
  , i_provider_group_id     in      com_api_type_pkg.t_short_id
  , o_purpose_id_tab           out  com_api_type_pkg.t_number_tab
  , o_purpose_name_tab         out  com_api_type_pkg.t_name_tab
  , o_logo_path_tab            out  com_api_type_pkg.t_name_tab
  , o_is_group_tab             out  com_api_type_pkg.t_boolean_tab
) is
    l_params                com_api_type_pkg.t_param_tab;
    l_mods                  num_tab_tpt := num_tab_tpt(null);
    l_purpose_mods          num_tab_tpt := num_tab_tpt(null);
begin
    opr_api_shared_data_pkg.collect_auth_params(
        i_id            => i_auth_id
      , io_params       => l_params
    );
    rul_api_mod_pkg.select_mods(
        i_scale_type    => pmo_api_const_pkg.PROVIDER_HOST_SCALE_TYPE
      , i_params        => l_params
      , o_mods          => l_mods
    );
    rul_api_mod_pkg.select_mods(
        i_scale_type    => pmo_api_const_pkg.PURPOSE_SCALE_TYPE
      , i_params        => l_params
      , o_mods          => l_purpose_mods
    );
    
    with v as (
        select g.id as id
             , get_text(
                   i_table_name  => 'pmo_provider_group'
                 , i_column_name => 'label'
                 , i_object_id   => g.id
                 , i_lang        => i_lang
               ) as label
             , g.logo_path
             , 1 as is_group
          from pmo_provider_group g
         where exists (
                   select p.id
                     from pmo_provider p
                     join pmo_purpose ps on ps.provider_id = p.id
                    where (g.id is null and p.parent_id is null -- return "root" providers
                           or 
                           p.parent_id = g.id) -- return child providers
                      and ps.service_id = i_service_id
               )
         start with i_provider_group_id is null and g.parent_id is null
                 or g.parent_id = i_provider_group_id
       connect by prior g.id = parent_id
        union all
        select ps.id
             , get_text(
                   i_table_name  => 'pmo_provider'
                 , i_column_name => 'label'
                 , i_object_id   => p.id
                 , i_lang        => i_lang
               ) as label
             , p.logo_path
             , 0 as is_group               
          from pmo_provider p
          join pmo_purpose ps on ps.provider_id = p.id 
         where (i_provider_group_id is null and p.parent_id is null -- return "root" providers
                or 
                p.parent_id = i_provider_group_id) -- return child providers
           and ps.service_id = i_service_id
           and (ps.mod_id is null
                or
                ps.mod_id in (select pm.column_value from table(cast(l_purpose_mods as num_tab_tpt)) pm)
           )
           and exists (
               select null 
                 from pmo_provider_host h 
                where h.provider_id = p.id
                  and (h.mod_id is null 
                       or 
                       exists (select null 
                                 from table(cast(l_mods as num_tab_tpt)) t 
                                where t.column_value = h.mod_id)
                  )
           )
    )
    select v.id -- it may be an identifier of purpose (is_group = FALSE) or provider group (is_group = TRUE) 
         , v.label
         , v.logo_path
         , v.is_group
    bulk collect into
           o_purpose_id_tab
         , o_purpose_name_tab
         , o_logo_path_tab
         , o_is_group_tab
      from v;
end get_all_purposes;

procedure get_own_purposes(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_service_id            in      com_api_type_pkg.t_short_id
  , o_purpose_id_tab           out  com_api_type_pkg.t_number_tab
  , o_purpose_name_tab         out  com_api_type_pkg.t_name_tab
) is
    l_params                com_api_type_pkg.t_param_tab;
    l_mods                  num_tab_tpt := num_tab_tpt(null);
    l_purpose_mods          num_tab_tpt := num_tab_tpt(null);
    l_customer_id           com_api_type_pkg.t_medium_id;
begin

    opr_api_shared_data_pkg.collect_auth_params(
        i_id            => i_auth_id
      , io_params       => l_params
    );

    l_customer_id       := rul_api_param_pkg.get_param_num('CUSTOMER_ID', l_params);

    if l_customer_id is null then
        return;
    end if;

    rul_api_mod_pkg.select_mods(
        i_scale_type    => pmo_api_const_pkg.PROVIDER_HOST_SCALE_TYPE
      , i_params        => l_params
      , o_mods          => l_mods
    );

    rul_api_mod_pkg.select_mods(
        i_scale_type    => pmo_api_const_pkg.PURPOSE_SCALE_TYPE
      , i_params        => l_params
      , o_mods          => l_purpose_mods
    );

    select c.id
         , a.label
      bulk collect into
           o_purpose_id_tab
         , o_purpose_name_tab
      from pmo_ui_provider_vw a
         , pmo_provider_host b
         , pmo_purpose c
         , pmo_order e
     where a.lang = i_lang
       and a.id            = c.provider_id
       and (b.mod_id is null or exists
                     (select 1 from table(cast(l_mods as num_tab_tpt)) d where d.column_value = b.mod_id))
       and (c.mod_id is null or exists      
                     (select 1 from table(cast(l_purpose_mods as num_tab_tpt)) p where p.column_value = c.mod_id))
       and b.provider_id   = c.provider_id
       and e.customer_id   = l_customer_id
       and e.purpose_id    = c.id
       and c.service_id    = i_service_id
       and e.is_template   = 1;
end;

end;
/
