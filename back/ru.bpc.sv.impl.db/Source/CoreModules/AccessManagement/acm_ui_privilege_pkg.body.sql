create or replace package body acm_ui_privilege_pkg
/*************************************************************
 * Provides an interface for managing privileges. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 30.09.2009 <br />
 * Module: ACM_UI_PRIVILEGE_PKG <br />
 * @headcom
 *************************************************************/
is
procedure add_privilege_role(
    o_id                 out  com_api_type_pkg.t_short_id
  , i_role_id         in      com_api_type_pkg.t_tiny_id
  , i_priv_id         in      com_api_type_pkg.t_short_id
  , i_limit_id        in      com_api_type_pkg.t_short_id
  , i_filter_limit_id in      com_api_type_pkg.t_short_id default null
) is
begin
    for rec in (
        select d.name
          from acm_role_vw d
         where i_role_id in (select a.id from acm_role_vw a)
           and i_priv_id in (select b.id from acm_privilege_vw b)
           and d.id      = i_role_id
    ) loop
        if rec.name = acm_api_const_pkg.ROLE_ROOT then
            com_api_error_pkg.raise_error(
                i_error => 'ROLE_ROOT_CANNOT_REMOVED'
            );
        end if;

        begin
            o_id := acm_role_privilege_seq.nextval;
            insert into acm_role_privilege_vw(
                id
              , role_id
              , priv_id
              , limit_id
              , filter_limit_id
            ) values(
                o_id
              , i_role_id
              , i_priv_id
              , i_limit_id
              , i_filter_limit_id
            );
        exception
            when dup_val_on_index then
                for rec in (select count(id) from acm_role_privilege where id = o_id)
                loop
                    raise;
                end loop;
                com_api_error_pkg.raise_error(
                    i_error      => 'ROLE_ALREADY_HAS_THIS_PRIVILEGE'
                  , i_env_param1 => com_api_i18n_pkg.get_text('acm_role', 'name', i_role_id)
                  , i_env_param2 => com_api_i18n_pkg.get_text('acm_privilege', 'label', i_priv_id)
                );
        end;
    end loop;
end add_privilege_role;

procedure remove_privilege_role(
    i_privs_role_id in      com_api_type_pkg.t_short_id
) is
begin
    for rec in (
        select a.id
             , a.name
          from acm_role_vw a
             , acm_role_privilege_vw b
         where a.id = b.role_id
           and b.id = i_privs_role_id)
    loop
        if rec.name = acm_api_const_pkg.ROLE_ROOT then
            com_api_error_pkg.raise_error(
                i_error => 'ROLE_ROOT_CANNOT_REMOVED'
            );
        end if;

        delete
            acm_role_privilege_vw a
        where
            a.id = i_privs_role_id;
    end loop;
end remove_privilege_role;

procedure remove_privilege_role(
    i_role_id in     com_api_type_pkg.t_tiny_id
  , i_priv_id in     com_api_type_pkg.t_short_id
) is
begin
    for rec in (
        select a.id
             , b.name
          from acm_role_privilege_vw a
             , acm_role_vw b
         where a.role_id = b.id
           and a.role_id = i_role_id
           and a.priv_id = i_priv_id
    ) loop

        if rec.name = acm_api_const_pkg.ROLE_ROOT then
            com_api_error_pkg.raise_error(
                i_error => 'ROLE_ROOT_CANNOT_REMOVED'
            );
        end if;

        remove_privilege_role(
            i_privs_role_id => rec.id
        );

    end loop;

end remove_privilege_role;

procedure set_limitation(
    i_role_id          in     com_api_type_pkg.t_tiny_id
  , i_priv_id          in     com_api_type_pkg.t_short_id
  , i_limit_id         in     com_api_type_pkg.t_short_id
  , i_filter_limit_id  in     com_api_type_pkg.t_short_id
) is
begin
    update acm_role_privilege
       set limit_id = i_limit_id
         , filter_limit_id = i_filter_limit_id
     where priv_id  = i_priv_id
       and role_id  = i_role_id;
end;

procedure add_privilege(
    io_id               in out  com_api_type_pkg.t_short_id
  , i_name              in      com_api_type_pkg.t_name
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_module            in      com_api_type_pkg.t_module_code
  , i_is_active         in      com_api_type_pkg.t_boolean
  , i_section_id        in      com_api_type_pkg.t_short_id
) is
begin
    if io_id is null  then
        select acm_privilege_seq.nextval into io_id from dual;

        insert into acm_privilege_vw(
            id
          , name
          , section_id
          , module_code
          , is_active
        )
        values(
            io_id
          , i_name
          , i_section_id
          , i_module
          , nvl(i_is_active, com_api_type_pkg.TRUE)
        );

    else
        update acm_privilege_vw a
           set a.name        = nvl(i_name, a.name)
             , a.module_code = nvl(i_module, a.module_code)
             , a.section_id  = nvl(i_section_id, a.section_id)
         where a.id          = io_id;
    end if;

    -- add/modify description
    com_api_i18n_pkg.add_text(
        i_table_name    => 'ACM_PRIVILEGE'
      , i_column_name   => 'LABEL'
      , i_object_id     => io_id
      , i_text          => i_short_desc
      , i_lang          => i_lang
    );

    com_api_i18n_pkg.add_text(
        i_table_name    => 'ACM_PRIVILEGE'
      , i_column_name   => 'DESCRIPTION'
      , i_object_id     => io_id
      , i_text          => i_full_desc
      , i_lang          => i_lang
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'PRIVILEGE_ALREADY_EXISTS'
          , i_env_param1 => i_name
        );
end add_privilege;

procedure remove_privilege(
    i_priv_id in     com_api_type_pkg.t_short_id
) is
begin
    delete from acm_privilege_vw a
     where a.id = i_priv_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'ACM_PRIVILEGE'
      , i_object_id => i_priv_id
    );
end;

procedure get_priv_limitation(
    i_priv_name         in      com_api_type_pkg.t_name
  , o_limitation           out  com_api_type_pkg.t_text
) is
    l_user_id           com_api_type_pkg.t_short_id;
begin

    l_user_id := com_ui_user_env_pkg.get_user_id;

    if l_user_id is null then
        o_limitation := '(1 = 0)';
    else
        for r in (
            select distinct
                   a.id
                 , a.condition
              from acm_priv_limitation a
                 , acm_cu_privilege_vw b
             where b.priv_name = upper(i_priv_name)
               and b.limit_id  = a.id(+)
               and nvl(a.limitation_type, acm_api_const_pkg.PRIV_LIMITATION_RESULT) = acm_api_const_pkg.PRIV_LIMITATION_RESULT
          order by a.id nulls last
        ) loop
            if o_limitation is not null then
                o_limitation := o_limitation || ') OR (';
            end if;
            if r.condition is not null then
                o_limitation := o_limitation || r.condition;
            else
                -- If current user has the privilege without limitation, empty value should be returned
                o_limitation := null;
            end if;
        end loop;

        if o_limitation is not null then
            o_limitation := '(' || o_limitation || ')';
        end if;
    end if;

end get_priv_limitation;

procedure check_filter_limitation(
    i_priv_name         in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
) is

    l_label_name           com_api_type_pkg.t_name;
    l_sql_str              com_api_type_pkg.t_text;
    l_sql_fields           com_api_type_pkg.t_text;
    l_sql_where            com_api_type_pkg.t_text;
    l_cur                  com_api_type_pkg.t_large_id;
    l_field                com_api_type_pkg.t_name;
    l_label_id             com_api_type_pkg.t_large_id;
    l_sql_result           com_api_type_pkg.t_large_id;
    l_priv_limit_field_tab acm_api_type_pkg.t_priv_limit_field_tab;
    l_is_find              com_api_type_pkg.t_boolean := 0;

begin

    select distinct
           null
         , null
         , fld.field
         , fld.condition
         , fld.label_id
      bulk collect into l_priv_limit_field_tab
      from acm_cu_privilege_vw  prv
         , acm_priv_limitation  lim
         , acm_priv_limit_field fld
     where prv.priv_name = upper (i_priv_name)
       and prv.filter_limit_id = lim.id
       and lim.limitation_type = acm_api_const_pkg.PRIV_LIMITATION_FILTER
       and fld.priv_limit_id   = lim.id;

    for db_f_cnt in 1 .. l_priv_limit_field_tab.count loop

        l_is_find := 0;
        for ii in 1 .. i_param_tab.count loop
            if i_param_tab(ii).name = l_priv_limit_field_tab(db_f_cnt).field then
                l_is_find := 1;
                l_sql_fields := l_sql_fields ||
                case when i_param_tab (ii).char_value is null and  i_param_tab (ii).number_value is null and i_param_tab (ii).date_value is null
                then 'null'
                else ':fl' || ii
                end || ' ' || i_param_tab(ii).name || ',';
            end if;
        end loop;

        if l_is_find = 0 then
            l_sql_fields := l_sql_fields || ' null ' || l_priv_limit_field_tab(db_f_cnt).field||', ';
        end if;

    end loop;

    for ii in 1 .. i_param_tab.count loop  

        l_is_find := 0;
        for db_f_cnt in 1 .. l_priv_limit_field_tab.count loop
            if i_param_tab(ii).name = l_priv_limit_field_tab(db_f_cnt).field then
                l_is_find := 1;
                
            end if;

        end loop;

        if l_is_find = 0 then
            l_sql_fields := l_sql_fields ||case when i_param_tab (ii).char_value is null and  i_param_tab (ii).number_value is null and i_param_tab (ii).date_value is null 
                                                then 'null'
                                                else ':fl' || ii end ||' ' ||i_param_tab(ii).name||', ';
        end if;

    end loop;      

    for db_f_cnt in 1 .. l_priv_limit_field_tab.count loop
        l_is_find := 0;
        l_sql_where := null;

        for ii in 1 .. i_param_tab.count loop      
            if i_param_tab(ii).name = l_priv_limit_field_tab(db_f_cnt).field then
                l_sql_where  := trim( l_priv_limit_field_tab(db_f_cnt).condition);
                if l_sql_where is null then
                    exit;
                end if;
                l_is_find :=1;
                l_sql_str := nvl( l_priv_limit_field_tab(db_f_cnt).label_id,0) || ' label_id_, ''' ||  l_priv_limit_field_tab(db_f_cnt).field
                          || ''' field_ from dual) where not(' || l_sql_where || ')'; 
                exit;
            end if;
        end loop;
        
        if l_is_find =1 then
            l_sql_str := 'select label_id_,field_ from (select ' || l_sql_fields || l_sql_str;  
            begin
                l_cur := dbms_sql.open_cursor();
                begin
                    dbms_sql.parse(l_cur, l_sql_str, dbms_sql.native);
                exception when others then                  
                    trc_log_pkg.debug(l_sql_str);
                    com_api_error_pkg.raise_fatal_error('CONDITION_PARSING_ERROR');
                end;

                for ii in 1 .. i_param_tab.count loop
                    if i_param_tab(ii).char_value is not null then
                        dbms_sql.bind_variable(l_cur, ':fl' || ii, i_param_tab(ii).char_value);
                    elsif i_param_tab(ii).number_value is not null then
                        dbms_sql.bind_variable(l_cur, ':fl' || ii, i_param_tab(ii).number_value);
                    elsif i_param_tab(ii).date_value is not null then
                        dbms_sql.bind_variable(l_cur, ':fl' || ii, i_param_tab(ii).date_value);
                    end if;
                end loop;

                dbms_sql.define_column (l_cur, 1, l_label_id);
                dbms_sql.define_column (l_cur, 2, l_field, 200);

                l_sql_result := dbms_sql.execute (l_cur);

                while dbms_sql.fetch_rows(l_cur) > 0 loop
                    dbms_sql.column_value(l_cur, 1, l_label_id);
                    dbms_sql.column_value(l_cur, 2, l_field);
                    dbms_sql.close_cursor(l_cur);
                    begin
                        select lb.name into l_label_name from com_label lb where lb.id = l_label_id;
                        com_api_error_pkg.raise_error(i_error => l_label_name);
                    exception when no_data_found then
                        com_api_error_pkg.raise_error(i_error => 'CONDITION_NOT_PASSED', i_env_param1 => l_field);
                    end;
                end loop;

            exception
            when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
                raise;
            when others then
                com_api_error_pkg.raise_fatal_error(
                    i_error      => 'UNHANDLED_EXCEPTION'
                  , i_env_param1 => sqlerrm
                );

            end;


        end if;    
    end loop;

end check_filter_limitation;

end acm_ui_privilege_pkg;
/
