begin
    for rec in (select 1 from user_objects where object_name = 'VIS_REJECT_DATA_SEQ')
    loop
        execute immediate 'drop sequence vis_reject_data_seq';
end loop;
end;
/

create sequence vis_reject_data_seq start with 1000000000000001 maxvalue 9999999999999999 minvalue 1000000000000001 nocycle nocache noorder
/
