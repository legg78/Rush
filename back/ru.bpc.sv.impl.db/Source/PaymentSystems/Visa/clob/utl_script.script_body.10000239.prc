declare
    tcr_backup app_data_tpt;
begin
    select app_data_tpr(
               id --appl_data_id,
             , null
             , tcr  --parent_id
             , null
             , null
             , null
             , null
             , null
            )
      bulk collect into tcr_backup
      from vis_validation_rules;

    if tcr_backup.count > 0 then
        for i in tcr_backup.first .. tcr_backup.last loop
            tcr_backup(i).element_value_v := substr(to_char(tcr_backup(i).parent_id, 'FM99999999999999999999990'), -1);
        end loop;

        begin
            execute immediate 'alter table vis_validation_rules disable constraint VIS_VALIDATION_RULES_UK';
        exception
            when others then null;
        end;
        update vis_validation_rules set tcr = null;
    end if;

    execute immediate 'alter table vis_validation_rules modify(tcr varchar2(1))';

    if tcr_backup.count > 0 then
        forall q in tcr_backup.first .. tcr_backup.last
            update vis_validation_rules
               set tcr = tcr_backup(q).element_value_v
              where id = tcr_backup(q).appl_data_id;
    end if;
    begin
        execute immediate 'alter table vis_validation_rules enable constraint VIS_VALIDATION_RULES_UK';
    exception
        when others then null;
    end;
    begin
        execute immediate 'alter package vis_api_reject_pkg compile body';
    exception
        when others then null;
    end;
end;
