alter profile default limit password_life_time unlimited
/

create user main
    identified by main1
    default tablespace user_data_tbs
    temporary tablespace temp_tbs
    profile default
    account unlock
/
-- 14 roles for main
grant resource to main
/
grant connect to main
/
alter user main default role all
/
grant create view to main
/
grant create table to main
/
grant create materialized view to main
/
grant drop any sequence to main
/
grant create sequence to main
/
grant create trigger to main
/
grant create any synonym to main
/
grant create any procedure to main
/
grant create library to main
/
grant administer database trigger to main
/
grant create any directory to main
/

-- 2 system privileges for main
grant unlimited tablespace to main
/
grant select any dictionary to main
/

-- 6 object privileges for main
grant execute on sys.dbms_crypto to main
/
grant execute on sys.dbms_lock to main
/
grant execute on sys.dbms_support to main
/
grant execute on sys.utl_recomp to main
/
grant execute on sys.dbms_snapshot to main
/
grant execute on sys.dbms_redefinition to main
/
grant execute on sys.dbms_workload_repository to main
/
