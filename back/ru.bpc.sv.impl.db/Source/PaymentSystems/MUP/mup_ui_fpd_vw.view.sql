create or replace force view mup_ui_fpd_vw
as
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
    , a.de026
    , a.de049
    , a.de050
    , a.de071
    , a.de093
    , a.de100
    , a.p0148
    , a.p0165
    , a.p0300
    , a.p0302
    , a.p0369
    , a.p0370_1
    , a.p0370_2
    , a.p0372_1
    , a.p0372_2
    , a.p0374
    , a.p0375
    , a.p0378
    , a.p0380_1
    , a.p0380_2
    , a.p0381_1
    , a.p0381_2
    , a.p0384_1
    , a.p0384_2
    , a.p0390_1
    , a.p0390_2
    , a.p0391_1
    , a.p0391_2
    , a.p0392
    , a.p0393
    , a.p0394_1
    , a.p0394_2
    , a.p0395_1
    , a.p0395_2
    , a.p0396_1
    , a.p0396_2
    , a.p0400
    , a.p0401
    , a.p0402
    , a.p2358_1
    , a.p2358_2
    , a.p2358_3
    , a.p2358_4
    , a.p2358_5
    , a.p2358_6
    , a.p2359_1
    , a.p2359_2
    , a.p2359_3
    , a.p2359_4
    , a.p2359_5
    , a.p2359_6
    , l.lang
from
   mup_fpd a
   , com_language_vw l
/

