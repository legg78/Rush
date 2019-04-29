begin
    for rec in (select 1 from user_objects where object_name = 'JCB_FILE_SEQ')
    loop
        execute immediate 'drop sequence jcb_file_seq';
    end loop;
end;
/

create sequence jcb_file_seq maxvalue 99999999 start with 10000001 nocycle nocache
/
