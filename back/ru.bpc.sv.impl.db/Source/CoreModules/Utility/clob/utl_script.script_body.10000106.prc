declare
  l_cnt     number;
  l_from_id number;
  l_till_id number;
begin
  for i in 0 .. 100 loop
    l_from_id := com_api_id_pkg.get_from_id(get_sysdate - i);
    l_till_id := com_api_id_pkg.get_from_id(get_sysdate - i + 1);
    select sum(column_value)
      into l_cnt
      from table(opr_operation_parallel_update(cursor(
               select id
                    , incom_sess_file_id
                 from (
                     select id
                          , coalesce(
                                (select f.session_file_id
                                   from mcw_fin  m
                                      , mcw_file f
                                  where m.id = o.id
                                    and f.id = m.file_id)
                              , (select f.session_file_id
                                   from vis_fin_message  m
                                      , vis_file f
                                  where m.id = o.id
                                    and f.id = m.file_id)
                              , (select f.session_file_id
                                   from cup_fin_message  m
                                      , cup_file f
                                  where m.id = o.id
                                    and f.id = m.file_id)
                              , (select f.session_file_id
                                   from jcb_fin_message  m
                                      , jcb_file f
                                  where m.id = o.id
                                    and f.id = m.file_id)
                              , o.incom_sess_file_id
                            ) as incom_sess_file_id
                          , incom_sess_file_id as old_incom_sess_file_id
                       from opr_operation o
                      where id >= l_from_id
                        and id < l_till_id
                 )
                 where nvl(incom_sess_file_id, 0) != nvl(old_incom_sess_file_id, 0)
           )));
  end loop;
end;
