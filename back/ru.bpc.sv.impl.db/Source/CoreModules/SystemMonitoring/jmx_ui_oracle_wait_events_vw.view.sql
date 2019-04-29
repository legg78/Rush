create or replace force view jmx_ui_oracle_wait_events_vw as
select sum(decode(event, 'control file sequential read',  total_waits,
                         'control file single write', total_waits,
                         'control file parallel write', total_waits, 0)) as waits_controfileio
     , sum(decode(event, 'direct path read', total_waits, 0)) as waits_directpath_read
     , sum(decode(event, 'file identify', total_waits,
                         'file open', total_waits, 0)) as waits_file_io
     , sum(decode(event, 'log file single write', total_waits,
                         'log file parallel write', total_waits, 0)) as waits_logwrite
     , sum(decode(event, 'db file scattered read', total_waits, 0)) as waits_multiblock_read
     , sum(decode(event, 'db file sequential read', total_waits, 0)) as waits_singleblock_read
     , sum(decode(event, 'SQL*Net message to client', total_waits,
                         'SQL*Net message to dblink', total_waits,
                         'SQL*Net more data to client', total_waits,
                         'SQL*Net more data to dblink', total_waits,
                         'SQL*Net break/reset to client', total_waits,
                         'SQL*Net break/reset to dblink', total_waits, 0)) as waits_sqlnet
     , sum(decode(event, 'control file sequential read',  0,
                         'control file single write',     0,
                         'control file parallel write',   0,
                         'direct path read',              0,
                         'file identify',                 0,
                         'file open',                     0,
                         'log file single write',         0,
                         'log file parallel write',       0,
                         'db file sequential read',       0,
                         'db file scattered read',        0,
                         'SQL*Net message to client',     0,
                         'SQL*Net message to dblink',     0,
                         'SQL*Net more data to client',   0,
                         'SQL*Net more data to dblink',   0,
                         'SQL*Net break/reset to client', 0,
                         'SQL*Net break/reset to dblink', 0, total_waits)) as waits_other
  from v$system_event
 where event in (
                    'control file sequential read',
                    'control file single write',
                    'control file parallel write',
                    'direct path read',
                    'file identify',
                    'file open',
                    'log file single write',
                    'log file parallel write',
                    'db file scattered read',
                    'db file sequential read',
                    'SQL*Net message to client',
                    'SQL*Net message to dblink',
                    'SQL*Net more data to client',
                    'SQL*Net more data to dblink',
                    'SQL*Net break/reset to client',
                    'SQL*Net break/reset to dblink'
                )
/
