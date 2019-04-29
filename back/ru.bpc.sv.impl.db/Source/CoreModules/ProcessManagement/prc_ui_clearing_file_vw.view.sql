create or replace force view prc_ui_clearing_file_vw
as
select
      ff.file_id
    , ff.file_date
    , ff.is_incoming
    , ff.is_rejected
    , ff.file_name
    , ff.network_id
    , get_text ( i_table_name  => 'net_network'
               , i_column_name => 'name'
               , i_object_id   => ff.network_id
               , i_lang        => l.lang
      ) network_name
    , ff.inst_id
    , get_text ( i_table_name  => 'ost_institution'
               , i_column_name => 'name'
               , i_object_id   => ff.inst_id
               , i_lang        => l.lang
      ) inst_name
    , ff.file_type
    , get_article_text ( i_article => ff.file_type
                       , i_lang    => l.lang
      ) file_type_desc
    , ff.file_status
    , get_article_text ( i_article => ff.file_status
                       , i_lang    => l.lang
      ) file_status_desc
    , ff.ack_status
    , get_article_text ( i_article => ff.ack_status
                       , i_lang    => l.lang
      ) ack_status_desc
    , ff.record_count
    , ff.amount
    , l.lang
from
    ( select
          f.id as file_id
        , f.file_date
        , vf.is_incoming
        , vf.is_returned as is_rejected
        , f.file_name
        , vf.network_id
        , vf.inst_id
        , f.file_type
        , f.status as file_status
        , vis_api_type_pkg.get_clearing_file_ack_status (
                                i_file_id     => f.id
                              , i_is_incoming => vf.is_incoming
                              , i_is_rejected => vf.is_returned
                              , i_status      => f.status
          ) ack_status
        , f.record_count
        , vf.src_amount as amount
      from
        prc_session_file f
        , vis_file vf
      where
          f.id = vf.id
      and f.file_type = 'FLTPCLVS'
      and vf.inst_id in (select inst_id from acm_cu_inst_vw)
      union all
      select
            f.id file_id
          , f.file_date
          , mf.is_incoming
          , mf.is_rejected
          , f.file_name
          , mf.network_id
          , mf.inst_id
          , f.file_type
          , f.status
          , mcw_api_type_pkg.get_clearing_file_ack_status (
                                i_file_id     => mf.id
                              , i_is_incoming => mf.is_incoming
                              , i_is_rejected => mf.is_rejected
                              , i_status      => f.status
            ) ack_status
          , f.record_count
          , mf.p0301
      from
        prc_session_file f
        , mcw_file mf
      where
          f.id = mf.session_file_id
      and f.file_type = 'FLTPCLMC'
      and mf.inst_id in (select inst_id from acm_cu_inst_vw)
    ) ff
    , com_language_vw l
/
