begin
    for rec in (select index_name from user_indexes where index_name = 'MCW_REJECT_CODE_ID_NDX')
    loop
        execute immediate 'drop index mcw_reject_code_id_ndx';
    end loop;
end;
/

create index mcw_reject_code_id_ndx on mcw_reject_code (reject_data_id)
/
