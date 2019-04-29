create or replace force view jmx_ui_oracle_library_cache_vw as
select trunc(sum(decode(namespace, 'BODY', gethitratio * 100, 0)), 2) as hitratio_body
     , trunc(sum(decode(namespace, 'TABLE/PROCEDURE', gethitratio * 100, 0)), 2) as hitratio_table_proc
     , trunc(sum(decode(namespace, 'TRIGGER', gethitratio * 100, 0)), 2) as hitratio_trigger
     , trunc(sum(decode(namespace, 'SQL AREA', gethitratio * 100, 0)), 2) as hitratio_sqlarea
     , trunc(sum(decode(namespace, 'BODY', pins / (pins+reloads) * 100, 0)), 2) as pinhitratio_body
     , trunc(sum(decode(namespace, 'TABLE/PROCEDURE', pins / (pins+reloads) * 100, 0)), 2) as pinhitratio_table_proc
     , trunc(sum(decode(namespace, 'TRIGGER', pins / (pins+reloads) * 100, 0)), 2) as pinhitratio_trigger
     , trunc(sum(decode(namespace, 'SQL AREA', pins / (pins+reloads) * 100, 0)), 2) as pinhitratio_sqlarea
  from v$librarycache
 where namespace in ('BODY', 'TABLE/PROCEDURE', 'TRIGGER', 'SQL AREA')
/
