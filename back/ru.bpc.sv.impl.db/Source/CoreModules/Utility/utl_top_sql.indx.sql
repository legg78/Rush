create index utl_top_sql_session_id_ndx on utl_top_sql (session_id)
/
create index utl_top_sql_snap_id_ndx on utl_top_sql (min_snap_id, max_snap_id, is_aggregation, sorting_type)
/
