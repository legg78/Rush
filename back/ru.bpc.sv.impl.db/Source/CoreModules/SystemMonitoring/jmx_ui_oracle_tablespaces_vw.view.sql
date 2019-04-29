create or replace force view jmx_ui_oracle_tablespaces_vw as
    select df.tablespace_name
         , dt.contents
         , dt.status
         , df.files_count
         , dt.block_size
         , dt.initial_extent
         , dt.next_extent
         , dt.min_extents
         , dt.max_extents
         , dt.pct_increase
         , df.bytes - dt.free_size as used_bytes
         , df.bytes as actual_bytes
         , df.max_bytes as max_bytes
         , dt.free_size as free_bytes
      from (
               select dts.tablespace_name
                    , dts.contents
                    , dts.status
                    , dts.block_size
                    , dts.initial_extent
                    , dts.next_extent
                    , dts.min_extents
                    , dts.max_extents
                    , dts.pct_increase
                    , dfs.free_size
                 from dba_tablespaces dts
      left outer join (
                          select tablespace_name
                               , sum(nvl(bytes, 0)) as free_size
                            from dba_free_space
                        group by tablespace_name
                      ) dfs
                   on dts.tablespace_name = dfs.tablespace_name
             order by 1
           ) dt
inner join (
                select ddf.tablespace_name
                     , count(1) as files_count
                     , sum(nvl(ddf.bytes, 0)) as bytes
                     , sum(decode(sign(nvl(ddf.maxbytes, 0) - nvl(ddf.bytes, 0)), -1, nvl(ddf.bytes, 0), nvl(ddf.maxbytes, 0))) as max_bytes
                  from dba_data_files ddf
              group by ddf.tablespace_name
             union all
                select dtf.tablespace_name
                     , count(1)                    as files_count
                     , sum(nvl(dtf.bytes, 0))      as bytes
                     , sum(decode(sign(nvl(dtf.maxbytes, 0) - nvl(dtf.bytes, 0)), -1, nvl(dtf.bytes, 0), nvl(dtf.maxbytes, 0))) as max_bytes
                  from dba_temp_files dtf
              group by dtf.tablespace_name
              order by 1
            ) df
         on dt.tablespace_name = df.tablespace_name
/
