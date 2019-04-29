create or replace package body adt_api_trigger_pkg as

g_trigger_template          constant com_api_type_pkg.t_text :=

'create or replace trigger <table_name>_trg
instead of delete or insert or update
on <table_name>_vw
referencing new as new old as old
for each row
declare
    l_audit_activated           com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE;
    l_entity_type               com_api_type_pkg.t_dict_value  := ''<entity_type>'';
    l_trail_id                  com_api_type_pkg.t_long_id;
    l_action_type               com_api_type_pkg.t_dict_value;
    l_changed_count             pls_integer := 0;
    l_config_stand              com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE;
begin
    if inserting then

        l_action_type := ''INSERT'';

        insert into <table_name>(
            <field_list>
        ) values (
            <new_field_list>
        );

    elsif updating then

        l_action_type := ''UPDATE'';

        <check_seqnum_value>

        update <table_name>
           set <update_field_list>
         where <pk_field_list>;

    elsif deleting then

        l_action_type := ''DELETE'';

        delete <table_name> where <pk_field_list>;
    else
        null;
    end if;

    begin
       select to_number(param_value, ''FM000000000000000000.0000'')
         into l_config_stand
         from set_parameter p
            , set_parameter_value v
        where p.name = ''CONFIGURATION_INSTANCE''
          and v.param_id = p.id
          and v.param_level = p.lowest_level;
    exception
        when no_data_found then
            l_config_stand := com_api_type_pkg.FALSE;
    end;

    begin
        select is_active
          into l_audit_activated
          from adt_entity
         where entity_type = l_entity_type
           and is_active != -1;
    exception
        when no_data_found then
            l_audit_activated := com_api_type_pkg.FALSE;
    end;

    if l_audit_activated = com_api_type_pkg.TRUE or l_config_stand = com_api_type_pkg.TRUE then

        l_trail_id := coalesce(com_ui_user_env_pkg.get_trail_id, adt_api_trail_pkg.get_trail_id);

        <check_value_list>

        adt_api_trail_pkg.put_audit_trail(
            i_trail_id          => l_trail_id
          , i_entity_type       => l_entity_type
          , i_object_id         => nvl(<object_id_field_list>)
          , i_action_type       => l_action_type
        );

    end if;
end;';

g_seqnum_template          constant com_api_type_pkg.t_full_desc :=
'if :old.seqnum > :new.seqnum then
            com_api_error_pkg.raise_error(
                i_error         => ''INCONSISTENT_DATA''
            );
        end if;';


procedure create_audit_trigger(
    i_entity_type       in      com_api_type_pkg.t_dict_value           default null
) is
    l_trigger_source        clob;
    l_field_list            varchar2(32767);
    l_new_field_list        varchar2(32767);
    l_update_field_list     varchar2(32767);
    l_check_value_list      varchar2(32767);
    l_pk_field_list         varchar2(32767);
    l_object_id_field_list  varchar2(32767);
    l_seqnum_source         varchar2(200);
    l_old                   varchar2(200);
    l_new                   varchar2(200);

    l_column_name_tab       com_api_type_pkg.t_oracle_name_tab;

    l_pk_column_name        com_api_type_pkg.t_oracle_name;
    l_pk_column_name_tab    com_api_type_pkg.t_oracle_name_tab;
    l_is_pk_column          com_api_type_pkg.t_boolean;

    type t_is_pk_column_tab is table of com_api_type_pkg.t_boolean index by com_api_type_pkg.t_oracle_name;
    l_is_pk_column_tab      t_is_pk_column_tab;
begin

    select b.table_name || '.' || b.column_name
      bulk collect into l_pk_column_name_tab
      from adt_entity e
         , user_constraints  a
         , user_cons_columns b
     where a.table_name      = e.table_name
       and a.constraint_type = 'P'
       and a.constraint_name = b.constraint_name;

    for i in 1 .. l_pk_column_name_tab.count loop
        l_is_pk_column_tab(upper(l_pk_column_name_tab(i))) := com_api_const_pkg.TRUE;
    end loop;

    for r in (
        select e.entity_type
             , e.table_name
          from adt_entity e
         where (entity_type = i_entity_type or i_entity_type is null)
           and exists (select 1 from user_tab_columns c where c.table_name = e.table_name and c.column_name = 'ID')
    ) loop
        l_seqnum_source := null;

        select c.column_name
          bulk collect into l_column_name_tab
          from user_tab_columns c
         where c.table_name   = r.table_name
           and c.column_name != 'PART_KEY'
         order by c.column_id;

        for i in 1 .. l_column_name_tab.count loop

            if l_field_list is not null then
                l_field_list := l_field_list || chr(10) || lpad(', ', 12) || lower(l_column_name_tab(i));
            else
                l_field_list := lower(l_column_name_tab(i));
            end if;

            if l_new_field_list is not null then
                l_new_field_list := l_new_field_list || chr(10) || lpad(', ', 12) || ':new.' || lower(l_column_name_tab(i));
            else
                l_new_field_list := ':new.' || lower(l_column_name_tab(i));
            end if;

            l_pk_column_name  := r.table_name || '.' || l_column_name_tab(i);
            l_is_pk_column    := com_api_const_pkg.FALSE;

            if l_is_pk_column_tab.exists(l_pk_column_name) then
                if l_is_pk_column_tab(l_pk_column_name) = com_api_const_pkg.TRUE then
                    l_is_pk_column := com_api_const_pkg.TRUE;
                end if;
            end if;

            if l_is_pk_column = com_api_const_pkg.FALSE and l_column_name_tab(i) != 'SEQNUM' then
                if l_update_field_list is not null then
                    l_update_field_list := l_update_field_list || chr(10) || lpad(', ', 15) || lower(l_column_name_tab(i)) || ' = :new.' || lower(l_column_name_tab(i));
                else
                    l_update_field_list := lower(l_column_name_tab(i)) || ' = :new.' || lower(l_column_name_tab(i));
                end if;

                l_old := ' :old.' || l_column_name_tab(i);
                l_new := ' :new.' || l_column_name_tab(i);

                if l_check_value_list is not null then
                    l_check_value_list := l_check_value_list || chr(10) || lpad(' ', 8) || 'adt_api_trail_pkg.check_value(l_trail_id, ''' || l_column_name_tab(i) || ''',' || l_old || ',' || l_new || ', l_changed_count);';
                else
                    l_check_value_list := 'adt_api_trail_pkg.check_value(l_trail_id, ''' || l_column_name_tab(i) || ''',' || l_old || ',' || l_new || ', l_changed_count);';
                end if;
            end if;

            if l_is_pk_column = com_api_const_pkg.TRUE then
                if l_pk_field_list is not null then
                    l_pk_field_list := l_pk_field_list || chr(10) || lpad('and ', 15) || lower(l_column_name_tab(i)) || ' = :old.' || lower(l_column_name_tab(i));
                else
                    l_pk_field_list := lower(l_column_name_tab(i)) || ' = :old.' || lower(l_column_name_tab(i));
                end if;
                if lower(l_column_name_tab(i)) != 'lang' then
                    if l_object_id_field_list is not null then
                        l_object_id_field_list := l_object_id_field_list || chr(10) || ' :old.'||lower(l_column_name_tab(i))||', :new.'||lower(l_column_name_tab(i));
                    else
                        l_object_id_field_list := ' :old.'||lower(l_column_name_tab(i))||', :new.'||lower(l_column_name_tab(i));
                    end if;
                end if;
            end if;

            if l_column_name_tab(i) = 'SEQNUM' then
                l_seqnum_source := chr(10) || lpad(', ', 15) ||'seqnum = seqnum + 1';
            end if;

        end loop;

        if l_update_field_list is null and l_seqnum_source is not null then
            l_update_field_list := ' seqnum = seqnum + 1';
        else
            l_update_field_list := l_update_field_list || l_seqnum_source;
        end if;

        l_trigger_source := replace(g_trigger_template, '<table_name>',           lower(r.table_name));
        l_trigger_source := replace(l_trigger_source,   '<entity_type>',          r.entity_type);
        l_trigger_source := replace(l_trigger_source,   '<field_list>',           l_field_list);
        l_trigger_source := replace(l_trigger_source,   '<new_field_list>',       l_new_field_list);
        l_trigger_source := replace(l_trigger_source,   '<update_field_list>',    l_update_field_list);
        l_trigger_source := replace(l_trigger_source,   '<check_value_list>',     l_check_value_list);
        l_trigger_source := replace(l_trigger_source,   '<pk_field_list>',        l_pk_field_list);
        l_trigger_source := replace(l_trigger_source,   '<object_id_field_list>', l_object_id_field_list);

        if l_seqnum_source is not null then
            l_trigger_source := replace(l_trigger_source, '<check_seqnum_value>', g_seqnum_template);
        else
            l_trigger_source := replace(l_trigger_source, '<check_seqnum_value>');
        end if;

        begin
            execute immediate l_trigger_source;
        exception
            when others then
                trc_log_pkg.error(substr('creation trigger error: ['|| l_trigger_source||']', 1, 4000));
        end;

        l_trigger_source        := null;
        l_field_list            := null;
        l_new_field_list        := null;
        l_update_field_list     := null;
        l_check_value_list      := null;
        l_pk_field_list         := null;
        l_object_id_field_list  := null;

    end loop;
end create_audit_trigger;

end adt_api_trigger_pkg;
/
