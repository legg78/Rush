begin
  for rec in (select 1 from user_objects where object_name = 'MUP_REJECT_CODE_SEQ')
  loop
    execute immediate 'drop sequence mup_reject_code_seq';
  end loop;
end;
/

create sequence mup_reject_code_seq start with 1000000000000001 maxvalue 9999999999999999 minvalue 1000000000000001 nocycle nocache noorder
/
