create or replace force view jmx_ui_oracle_pga_vw as
select sum(decode(name, 'aggregate PGA target parameter', value, 0)) as aggregate_target
     , sum(decode(name, 'total PGA inuse', value,
                        'total PGA used',  value,                0)) as used_bytes
  from v$pgastat
 where name in ('aggregate PGA target parameter', 'total PGA inuse')
/
