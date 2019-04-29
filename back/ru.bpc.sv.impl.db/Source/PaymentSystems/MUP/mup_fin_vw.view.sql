create or replace force view mup_fin_vw as
select id
     , split_hash
     , inst_id
     , network_id
     , file_id
     , status
     , impact
     , is_incoming
     , is_reversal
     , is_rejected
     , is_fpd_matched
     , is_fsum_matched
     , dispute_id
     , dispute_rn
     , fpd_id
     , fsum_id
     , reject_id
     , mti
     , de024
     , de002
     , de003_1
     , de003_2
     , de003_3
     , de004
     , de005
     , de006
     , de009
     , de010
     , de012
     , de014
     , de022_1
     , de022_2
     , de022_3
     , de022_4
     , de022_5
     , de022_6
     , de022_7
     , de022_8
     , de022_9
     , de022_10
     , de022_11
     , de023
     , de025
     , de026
     , de030_1
     , de030_2
     , de031
     , de032
     , de033
     , de037
     , de038
     , de040
     , de041
     , de042
     , de043_1
     , de043_2
     , de043_3
     , de043_4
     , de043_5
     , de043_6
     , de049
     , de050
     , de051
     , de054
     , de055
     , de063
     , de071
     , de072
     , de073
     , de093
     , de094
     , de095
     , de100
     , p0025_1
     , p0025_2
     , p0137
     , p0146
     , p0146_net
     , p0148
     , p0149_1
     , p0149_2
     , p0165
     , p0190
     , p0198
     , p0228
     , p0261
     , p0262
     , p0265
     , p0266
     , p0267
     , p0268_1
     , p0268_2
     , p0375
     , p2002
     , p2063
     , p2158_1
     , p2158_2
     , p2158_3
     , p2158_4
     , p2158_5
     , p2158_6
     , p2159_1
     , p2159_2
     , p2159_3
     , p2159_4
     , p2159_5
     , p2159_6
     , emv_9f26
     , emv_9f27
     , emv_9f10
     , emv_9f37
     , emv_9f36
     , emv_95   
     , emv_9a 
     , emv_9c
     , emv_9f02
     , emv_5f2a
     , emv_82
     , emv_9f1a
     , emv_9f03   
     , emv_9f34
     , emv_9f33
     , emv_9f35
     , emv_9f1e    
     , emv_9f53
     , emv_84
     , emv_9f09
     , emv_9f41
     , emv_9f4c       
     , emv_91
     , emv_8a
     , emv_71
     , emv_72 
     , p2175_1
     , p2175_2
     , p2097_1
     , p2097_2
     , is_collection
     , p2001_1
     , p2001_2
     , p2001_3
     , p2001_4
     , p2001_5
     , p2001_6
     , p2001_7
  from mup_fin
/
