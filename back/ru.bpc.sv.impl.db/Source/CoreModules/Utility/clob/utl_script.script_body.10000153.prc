declare
  l_cnt     number;
begin
    select sum(column_value)
      into l_cnt
      from table(utl_parallel_update_pkg.card_instance_parallel_update(cursor(
              select ci.id
                   , case
                         when ci.seq_number = (select max(s.seq_number) from iss_card_instance s where s.card_id = ci.card_id)
                         then com_api_type_pkg.TRUE
                         else com_api_type_pkg.FALSE
                     end as is_last_seq_number
                from iss_card_instance ci
               where ci.is_last_seq_number is null
           )));
end;
