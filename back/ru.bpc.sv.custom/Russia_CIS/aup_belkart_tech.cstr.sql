begin
  for rec in (select 1 from user_constraints where constraint_name = 'AUP_BELKART_TECH_PK')
  loop
    execute immediate 'alter table aup_belkart_tech drop constraint aup_belkart_tech_pk drop index';
  end loop;
end;
/

alter table aup_belkart_tech add constraint aup_belkart_tech_pk primary key (time_mark, tech_id) using index   -- [@skip patch]
/
