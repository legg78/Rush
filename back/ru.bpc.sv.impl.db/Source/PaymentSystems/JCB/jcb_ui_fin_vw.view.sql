create or replace force view jcb_ui_fin_vw
as
select
    a.id          
    , a.split_hash
    , a.status  
    , get_article_text(
        i_article => a.status
      , i_lang    => l.lang
    ) as status_desc
    , a.inst_id   
    , get_text(
        i_table_name  => 'ost_institution'
      , i_column_name => 'name'
      , i_object_id   => a.inst_id
      , i_lang        => l.lang
    ) as inst_name
    , a.network_id
    , get_text(
        i_table_name  => 'net_network'
      , i_column_name => 'name'
      , i_object_id   => a.network_id
      , i_lang        => l.lang
    ) as network_name
    , a.file_id
    , a.is_incoming
    , a.is_reversal
    , a.is_rejected
    , a.reject_id 
    , a.dispute_id
    , a.dispute_rn
    , a.impact
    , a.mti      
    , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as de002
    , a.de003_1
    , a.de003_2
    , a.de003_3
    , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number) as de002_mask
    , a.de004
    , a.de005
    , a.de006
    , a.de009
    , a.de010
    , a.de012
    , a.de014
    , a.de016
    , a.de022_1
    , a.de022_2
    , a.de022_3
    , a.de022_4
    , a.de022_5
    , a.de022_6
    , a.de022_7
    , a.de022_8
    , a.de022_9
    , a.de022_10
    , a.de022_11
    , a.de022_12
    , a.de023
    , a.de024
    , a.de025
    , a.de026
    , a.de030_1
    , a.de030_2
    , a.de031
    , a.de032
    , a.de033
    , a.de037
    , a.de038
    , a.de040
    , a.de041
    , a.de042
    , a.de043_1
    , a.de043_2
    , a.de043_3
    , a.de043_4
    , a.de043_5
    , a.de043_6
    , a.de049
    , a.de050
    , a.de051
    , a.de054
    , a.de055
    , a.de071
    , a.de072
    , a.de093
    , a.de094
    , a.de100    
    , a.p3001
    , a.p3002
    , a.p3003
    , a.p3005
    , a.p3006
    , a.p3007_1
    , a.p3007_2
    , a.p3008
    , a.p3009
    , a.p3011
    , a.p3012
    , a.p3013
    , a.p3014
    , a.p3201
    , a.p3202
    , a.p3203
    , a.p3205
    , a.p3206
    , a.p3207
    , a.p3208
    , a.p3209
    , a.p3210
    , a.p3211   
    , a.p3250   
    , a.p3251   
    , a.p3302   
    , a.emv_9f26
    , a.emv_9f02
    , a.emv_9f27
    , a.emv_9f10
    , a.emv_9f36
    , a.emv_95  
    , a.emv_82  
    , a.emv_9a  
    , a.emv_9c  
    , a.emv_9f37
    , a.emv_5f2a
    , a.emv_9f33
    , a.emv_9f34
    , a.emv_9f1a
    , a.emv_9f35
    , a.emv_84  
    , a.emv_9f09
    , a.emv_9f03
    , a.emv_9f1e
    , a.emv_9f41   
    , a.emv_4f   
    , l.lang
    , sf.file_name
from
    jcb_fin_message a
  , jcb_card c
  , jcb_file f
  , com_language_vw l
  , prc_session_file sf
where a.id = c.id(+)
  and f.id = a.file_id 
  and f.session_file_id = sf.id
/
