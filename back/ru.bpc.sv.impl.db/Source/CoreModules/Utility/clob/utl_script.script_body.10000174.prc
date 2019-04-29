declare
  l_cnt     number;
begin
    select sum(column_value)
      into l_cnt
      from table(utl_parallel_update_pkg.event_object_update(cursor(
              select eo.id
                   , (
                         select e.event_type
                           from evt_event e
                          where e.id = eo.event_id
                     ) as event_type
                from evt_event_object eo
               where eo.event_type is null
                 and decode(eo.status, 'EVST0001', eo.procedure_name, null) is not null
           )));
end; 
