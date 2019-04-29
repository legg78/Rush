create or replace package body qrz_ui_scheduler_running_pkg as

procedure run_scheduler
is
    l_count         com_api_type_pkg.t_tiny_id;
begin
    select count(*) 
      into l_count
      from qrz_scheduler_running 
     where rownum < 2;
    if l_count > 0 then
        update qrz_scheduler_running set is_running = com_api_type_pkg.TRUE;
    else
        insert into qrz_scheduler_running (is_running) values (com_api_type_pkg.TRUE);
    end if;
end;

procedure stop_scheduler
is
    l_count         com_api_type_pkg.t_tiny_id;
begin
    select count(*) 
      into l_count
      from qrz_scheduler_running 
     where rownum < 2;
    if l_count > 0 then
        update qrz_scheduler_running set is_running = com_api_type_pkg.FALSE;
    else
        insert into qrz_scheduler_running (is_running) values (com_api_type_pkg.FALSE);
    end if;
end;

function is_running return com_api_type_pkg.t_boolean
is
    l_result        com_api_type_pkg.t_boolean;
begin
    select is_running
      into l_result 
      from qrz_scheduler_running
     where rownum = 1;
    
    return l_result;
exception
    when no_data_found then
        l_result := com_api_type_pkg.FALSE;
        
        return l_result;
end;

end;
/