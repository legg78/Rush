create or replace force view mup_ui_fin_vw
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
    , a.is_fpd_matched
    , a.fpd_id
    , a.dispute_id
    , a.impact
    , a.mti
    , a.de024
    , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as de002
    , a.de003_1
    , a.de003_2
    , a.de003_3
    , a.de004
    , a.de005
    , a.de006
    , a.de009
    , a.de010
    , a.de012
    , a.de014
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
    , a.de023
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
    , a.de063
    , a.de071
    , a.de072
    , a.de073
    , a.de093
    , a.de094
    , a.de095
    , a.de100
    , a.p0025_1
    , a.p0025_2
    , a.p0137
    , a.p0146
    , a.p0146_net
    , a.p0148
    , a.p0149_1
    , a.p0149_2
    , a.p0165
    , a.p0190
    , a.p0198
    , a.p0228
    , a.p0261
    , a.p0262
    , a.p0265
    , a.p0266
    , a.p0267
    , a.p0268_1
    , a.p0268_2
    , a.p0375
    , a.p2002
    , a.p2063
    , a.p2158_1
    , a.p2158_2
    , a.p2158_3
    , a.p2158_4
    , a.p2158_5
    , a.p2158_6
    , a.p2159_1
    , a.p2159_2
    , a.p2159_3
    , a.p2159_4
    , a.p2159_5
    , a.p2159_6
    , a.p2175_1
    , utl_raw.cast_to_varchar2(a.p2175_2) as p2175_2
    , a.p2097_1
    , utl_raw.cast_to_varchar2(a.p2097_2) as p2097_2
    , a.p0176
    , a.p2072_1
    , utl_raw.cast_to_varchar2(a.p2072_2) as p2072_2
    , a.emv_9f26
    , a.emv_9f27
    , a.emv_9f10
    , a.emv_9f37
    , a.emv_9f36
    , a.emv_95  
    , a.emv_9a
    , a.emv_9c
    , a.emv_9f02
    , a.emv_5f2a
    , a.emv_82
    , a.emv_9f1a
    , a.emv_9f03
    , a.emv_9f34
    , a.emv_9f33
    , a.emv_9f35
    , a.emv_9f1e
    , a.emv_9f53
    , a.emv_84
    , a.emv_9f09
    , a.emv_9f41
    , a.emv_9f4c
    , a.emv_91
    , a.emv_8a
    , a.emv_71
    , a.emv_72
    , l.lang
    , a.p2001_1
    , a.p2001_2
    , a.p2001_3
    , a.p2001_4
    , a.p2001_5
    , a.p2001_6
    , a.p2001_7
 from mup_fin a
    , mup_card c
    , com_language_vw l
where a.id = c.id(+)
/
