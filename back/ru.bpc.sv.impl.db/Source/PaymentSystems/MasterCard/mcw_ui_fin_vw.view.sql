create or replace force view mcw_ui_fin_vw as
select a.id
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
     , iss_api_card_pkg.get_card_mask(i_card_number => c.card_number) as de002_mask
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
     , a.de022_12
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
     , a.de111
     , a.p0001_1
     , a.p0001_2
     , a.p0002
     , a.p0018
     , a.p0023
     , a.p0025_1
     , a.p0025_2
     , a.p0042
     , a.p0043
     , a.p0045
     , a.p0047
     , a.p0052
     , a.p0058
     , a.p0059
     , a.p0137
     , a.p0148
     , a.p0146
     , a.p0146_net
     , a.p0147
     , a.p0149_1
     , a.p0149_2
     , a.p0158_1
     , a.p0158_2
     , a.p0158_3
     , a.p0158_4
     , a.p0158_5
     , a.p0158_6
     , a.p0158_7
     , a.p0158_8
     , a.p0158_9
     , a.p0158_10
     , a.p0158_11
     , a.p0158_12
     , a.p0158_13
     , a.p0158_14
     , a.p0159_1
     , a.p0159_2
     , a.p0159_3
     , a.p0159_4
     , a.p0159_5
     , a.p0159_6
     , a.p0159_7
     , a.p0159_8
     , a.p0159_9
     , a.p0165
     , a.p0176
     , a.p0198
     , a.p0200_1
     , a.p0200_2
     , a.p0207
     , a.p0208_1
     , a.p0208_2
     , a.p0209
     , a.p0210_1
     , a.p0210_2
     , a.p0228
     , a.p0230
     , a.p0241
     , a.p0243
     , a.p0244
     , a.p0260
     , a.p0261
     , a.p0262
     , a.p0264
     , a.p0265
     , a.p0266
     , a.p0267
     , a.p0268_1
     , a.p0268_2
     , a.p0375
     , a.p1001
     , a.is_fsum_matched
     , a.fsum_id
     , a.emv_82
     , a.emv_84
     , a.emv_95
     , a.emv_9a
     , a.emv_9c
     , a.emv_9f02
     , a.emv_9f03
     , a.emv_9f09
     , a.emv_9f10
     , a.emv_9f1a
     , a.emv_9f1e
     , a.emv_9f26
     , a.emv_9f27
     , a.emv_5f2a
     , a.emv_9f33
     , a.emv_9f34
     , a.emv_9f35
     , a.emv_9f36
     , a.emv_9f37
     , a.emv_9f41
     , a.emv_9f53
     , a.dispute_rn
     , a.local_message
     , a.ird_trace
     , a.p0004_1
     , a.p0004_2
     , a.p0072
     , iss_api_token_pkg.decode_card_number(i_card_number => c.p0014, i_mask_error => 1) as p0014
     , iss_api_card_pkg.get_card_mask(i_card_number => c.p0014) as p0014_mask
     , a.p0028
     , a.p0029
     , a.p0674
     , a.p0021
     , a.p0022
     , a.ext_claim_id
     , a.ext_message_id
     , a.p0184
     , a.p0185
     , a.p0186
     , a.ext_msg_status
     , l.lang
  from mcw_fin a
     , mcw_card c
     , com_language_vw l
 where a.id = c.id(+)
/
