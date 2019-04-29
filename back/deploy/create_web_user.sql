create user web
  identified by web1
  default tablespace user_data_tbs
  temporary tablespace temp_tbs
  profile default
  account unlock
/
  -- 3 roles for main
grant connect to web
/
alter user web default role all
/

declare
    l_web_user      varchar2(30) := 'web';
    l_main_user     varchar2(30) := 'main';
begin
    for r in (
        select case when object_type in ('PACKAGE', 'FUNCTION') then 'EXECUTE'
                    when object_type = 'VIEW'                   then 'SELECT'
                    else null
               end grant_action
             , a.object_name
          from dba_objects a
         where a.owner = upper(l_main_user)
           and (
                (
                 (
                  a.object_name like '____UI%'
                  or
                  a.object_name like '____CU%'
                 )
                 and
                 a.object_type in ('PACKAGE', 'VIEW')
                )
                or
                a.object_type in ('TYPE', 'FUNCTION')
               )
         order by a.object_name
    ) loop
        begin
            execute immediate
                'create synonym '||l_web_user||'.'||r.object_name||' for '||l_main_user||'.'||r.object_name;
            if r.grant_action is not null then
                execute immediate
                    'grant '||r.grant_action||' on '||l_main_user||'.'||r.object_name||' to '||l_web_user;
            end if;
        exception
            when others then
                dbms_output.put_line(r.object_name||': '||SQLERRM);
--                raise;
        end;
    end loop;
end;
/
