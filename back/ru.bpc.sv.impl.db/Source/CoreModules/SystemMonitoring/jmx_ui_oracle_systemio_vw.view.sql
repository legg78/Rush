create or replace force view jmx_ui_oracle_systemio_vw as
select s.physical_reads
     , s.block_gets
     , s.consistent_gets
     , s.block_changes
     , s.datafile_reads
     , s.datafile_writes
     , s.redo_writes
     , trunc(100.0 * (1.0 - s.physical_reads / (s.consistent_gets + s.block_gets)), 2) as hit_ratio
     , trunc(100.0 * (s.long_scans / (s.long_scans + s.short_scans)), 6)               as sql_not_indexed
  from (
         select sum(decode(name, 'physical reads',             value, 0)) as physical_reads
              , sum(decode(name, 'db block gets',              value, 0)) as block_gets
              , sum(decode(name, 'consistent gets',            value, 0)) as consistent_gets
              , sum(decode(name, 'table scans (long tables)',  value, 0)) as long_scans
              , sum(decode(name, 'table scans (short tables)', value, 0)) as short_scans
              , sum(decode(name, 'db block changes',           value, 0)) as block_changes
              , sum(decode(name, 'physical reads direct',      value, 0)) as datafile_reads
              , sum(decode(name, 'physical writes direct',     value, 0)) as datafile_writes
              , sum(decode(name, 'redo writes',                value, 0)) as redo_writes
           from v$sysstat
          where name in (
            'physical reads',
            'db block gets',
            'consistent gets',
            'table scans (long tables)',
            'table scans (short tables)',
            'db block changes',
            'physical reads direct',
            'physical writes direct',
            'redo writes'
           )
  ) s
/
