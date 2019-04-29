begin
  for rec in (select 1 from user_constraints where constraint_name = 'AUP_BELKART_PK')
  loop
    execute immediate 'alter table aup_belkart drop constraint aup_belkart_pk drop index';
  end loop;
end;
/

alter table aup_belkart add constraint aup_belkart_pk primary key (auth_id, tech_id) using index -- [@skip patch]
/
