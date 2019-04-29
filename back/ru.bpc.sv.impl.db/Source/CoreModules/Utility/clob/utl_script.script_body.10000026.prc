declare
    INSTANCE_TYPE_CORE              constant    com_api_type_pkg.t_sign       := 1;
    l_id          com_api_type_pkg.t_long_id;
    l_id_seq      com_api_type_pkg.t_long_id;
    l_min_seq     com_api_type_pkg.t_long_id;
    l_str         com_api_type_pkg.t_text;
    l_count       com_api_type_pkg.t_count := 0;
    l_diff        com_api_type_pkg.t_long_id;
    l_tmp_id      com_api_type_pkg.t_long_id;
begin
    --trc_config_pkg.init_cache;
    dbms_output.enable(buffer_size => NULL);
    for r in (
        select x.table_name
             , x.sequence_name
             , x.max_value_number
             , x.max_value
             , x.cycle_flag
             , x.order_flag
             , x.cache_size
             , x.increment_by
             , x.last_number
             , x.min_value
             , x.max_length
             , c.data_precision
             , x.user_table
          from (
              select case s.sequence_name
                         when 'COM_PARAMETER_SEQ' then 'COM_PARAMETER_ID_VW'
                         else substr(sequence_name, 1, instr(sequence_name, '_SEQ')-1)
                     end table_name
                   , s.sequence_name
                   , s.max_value max_value_number
                   , decode(s.max_value, 0, 'NOMAXVALUE', 'MAXVALUE '||s.max_value) max_value
                   , decode(s.cycle_flag, 'N', 'NOCYCLE', 'CYCLE') cycle_flag
                   , decode(s.order_flag, 'N', 'NOORDER', 'ORDER') order_flag
                   , decode(s.cache_size, 0, 'NOCACHE', 'CACHE '||s.cache_size) cache_size
                   , 'INCREMENT BY '||s.increment_by increment_by
                   , s.last_number
                   , case when t.table_name is null
                          then INSTANCE_TYPE_CORE
                          else to_number(rpad(1, length(s.max_value), 0)) + 1
                     end min_value
                   , length(s.max_value) max_length
                   , case when t.table_name is null then 0
                          else 1
                     end user_table
                from (select table_name from utl_table where is_split_seq = 1
                      union all
                      select 'COM_PARAMETER' table_name from dual) t
                   , user_sequences s
               where s.sequence_name = t.table_name(+) ||'_SEQ'
               ) x
             , user_tab_columns c
         where c.table_name  = x.table_name
           and c.table_name  = 'ACQ_TERMINAL'
           and c.column_name = 'ID'
      order by decode(sequence_name, 'TRC_LOG_SEQ', 1, 2)
             , sequence_name
    ) loop
        begin
            l_str := 'select nvl(max(id)+1, 0) from ' || r.table_name
                  || ' where id <= ' || r.max_value_number || '-10 and id < 50000000';
            execute immediate l_str into l_id;

            l_id_seq := greatest(l_id, r.min_value);
            l_min_seq := r.min_value;

            --check if l_id already used
            l_str := 'select count(*) from ' ||r.table_name || ' where id = ' || l_id_seq;
            execute immediate l_str into l_count;
            if l_count > 0 then
                dbms_output.put_line('The range is full. Table ' || r.table_name || ' MAX id = ' || l_id_seq);
            end if;

            if l_id = 0 then
                continue; -- Do not need to update a sequence because table is empty
            end if;

            l_min_seq := r.min_value;

            if r.cache_size != 'NOCACHE' then
                l_str := 'select ' || r.sequence_name || '.nextval from dual';
                execute immediate l_str into l_tmp_id;
                dbms_output.put_line('l_tmp_id['||l_tmp_id||']');
                l_diff := l_id_seq - l_tmp_id - 1;
            else
                l_diff := l_id_seq - r.last_number;
            end if;

            if l_diff != 0 then
                -- Use altering a sequence instead of its recreating to avoid objects' invalidation
                l_str := 'alter sequence ' || r.sequence_name || ' increment by '|| l_diff;

                if l_diff < 0 then
                    l_str := l_str || ' minvalue '   || l_min_seq; --(r.min_value-1);
                end if;

                if r.cache_size != 'NOCACHE' then
                    l_str := l_str || ' nocache';
                end if;
                execute immediate l_str;

                l_str := 'select ' || r.sequence_name || '.nextval from dual';
                execute immediate l_str into l_tmp_id;

                l_str :=
                    'alter sequence ' || r.sequence_name || ' '
                    || 'increment by 1 '
                    || 'minvalue '    || /*(r.min_value-1)*/ l_min_seq || ' '
                    || r.cache_size;
                execute immediate l_str;
            end if;

        exception
            when others then
                dbms_output.put_line(l_str);
                dbms_output.put_line('l_min_seq = ' || l_min_seq || ', l_diff = ' || l_diff
                                     || ', l_id_seq = ' || l_id_seq || ', l_id = ' || l_id
                                     || ', r.last_number = ' || r.last_number);
                raise;
        end;
    end loop;
end;
