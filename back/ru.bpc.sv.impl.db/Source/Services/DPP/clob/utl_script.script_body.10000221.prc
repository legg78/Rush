begin
    update opr_rule_selection set oper_reason = 'OPRS1501' where oper_type = 'OPTP1501' and oper_reason = '%';
end;
