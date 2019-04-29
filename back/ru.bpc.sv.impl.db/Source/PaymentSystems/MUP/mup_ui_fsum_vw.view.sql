create or replace force view mup_ui_fsum_vw as
select
       a.id
     , a.network_id
     , get_text ( i_table_name  => 'net_network'
                , i_column_name => 'name'
                , i_object_id   => a.network_id
                , i_lang        => l.lang
       ) network_name
     , a.inst_id
     , get_text ( i_table_name  => 'ost_institution'
                , i_column_name => 'name'
                , i_object_id   => a.inst_id
                , i_lang        => l.lang
       ) inst_name
     , a.file_id
     , a.status
     , get_article_text ( i_article => a.status
                        , i_lang    => l.lang
       ) status_desc
     , a.mti
     , a.de024
     , a.de025
     , a.de049
     , a.de071
     , a.de093
     , a.de100
     , a.p0148
     , a.p0300
     , a.p0380_1
     , a.p0380_2
     , a.p0381_1
     , a.p0381_2
     , a.p0384_1
     , a.p0384_2
     , a.p0400
     , a.p0401
     , a.p0402
     , l.lang
from
     mup_fsum a
   , com_language_vw l
/
