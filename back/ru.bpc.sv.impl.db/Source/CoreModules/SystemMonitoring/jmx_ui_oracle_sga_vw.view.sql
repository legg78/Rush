create or replace force view jmx_ui_oracle_sga_vw as
select sum(decode(pool, 'java pool',   bytes,                                      0)) as java_pool_size
     , sum(decode(pool, 'java pool',   decode(name, 'free memory',      bytes, 0), 0)) as java_pool_free_size
     , sum(decode(pool, 'large pool' , bytes,                                      0)) as large_pool_size
     , sum(decode(pool, 'large pool',  decode(name, 'free memory',      bytes, 0), 0)) as large_pool_free_size
     , sum(decode(pool, 'shared pool', decode(name, 'dictionary cache', bytes, 0), 0)) as dictionary_cache_size
     , sum(decode(pool, 'shared pool', decode(name, 'library cache',    bytes, 0), 0)) as library_cache_size
     , sum(decode(pool, 'shared pool', decode(name, 'sql area',         bytes, 0), 0)) as sql_area_size
     , sum(decode(pool, 'shared pool', decode(name, 'library cache',    0,
                                                    'dictionary cache', 0,
                                                    'free memory',      0,
                                                    'sql area',         0, bytes), 0)) as shared_pool_size
     , sum(decode(pool, 'shared pool', decode(name, 'free memory',      bytes, 0), 0)) as shared_pool_free_size
     , sum(decode(pool, null,          decode(name, 'db_block_buffers', bytes,
                                                    'buffer_cache',     bytes, 0), 0)) as buffer_cache_size
     , sum(decode(pool, null,          decode(name, 'fixed_sga',        bytes, 0), 0)) as fixed_sga_size
     , sum(decode(pool, null,          decode(name, 'log_buffer',       bytes, 0), 0)) as log_buffer_size
  from v$sgastat
/
