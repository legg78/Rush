begin
    update pmo_service set inst_id = 9999 where inst_id is null;
    update pmo_purpose set inst_id = 9999 where inst_id is null;
    update pmo_provider set inst_id = 9999 where inst_id is null;
    update pmo_provider_group set inst_id = 9999 where inst_id is null;
end;
