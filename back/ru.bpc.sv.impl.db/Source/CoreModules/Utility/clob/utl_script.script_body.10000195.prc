declare
  l_cnt     number;
begin
    select sum(column_value)
      into l_cnt
      from table(utl_parallel_update_pkg.event_card_number_update(cursor(
              select eo.id
                   , 'ISS_PRC_EXPORT_PKG.EXPORT_CARDS_NUMBERS' as procedure_name
                from evt_event_object eo
               where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'ITF_PRC_CARD_EXPORT_PKG.EXPORT_CARDS_NUMBERS'
           )));
end;
