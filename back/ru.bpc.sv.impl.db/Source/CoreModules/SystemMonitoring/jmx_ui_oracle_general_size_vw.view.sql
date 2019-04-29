create or replace force view jmx_ui_oracle_general_size_vw as
select round(data_size + temp_size) as file_size
     , round(data_size + temp_size + redo_size + control_file_size) as database_size
from (
       select
              (
                  select sum(d.bytes)
                    from dba_data_files d
              ) as data_size
            , (
                  select sum(nvl(t.bytes, 0))
                    from dba_temp_files t
              ) as temp_size
            , (
                  select sum(r.bytes)
                    from sys.v_$log r) as redo_size
            , (
                  select sum(block_size * file_size_blks)
                    from v$controlfile
              ) as control_file_size
         from dual
     ) t
/
