create or replace force view mup_ui_trans_rpt_vw as
select id
     , inst_id
     , file_id
     , record_number
     , status
     , report_type
     , activity_type
     , de094
     , mti
     , de002
     , de003
     , de004
     , de005
     , de009
     , de012
     , de022
     , de024
     , de025
     , de026
     , de031
     , de037
     , de038
     , de040
     , de041
     , de042
     , de043_123
     , de043_4
     , de043_5
     , de043_6
     , p0025_1
     , p0105
     , p0146
     , p0148
     , p0165
     , p2158
     , orig_transfer_agent_id
     , p2159
     , de049
     , de050
     , de054
     , de063
     , de072
     , l.lang
  from mup_trans_rpt r
     , com_language_vw l
/
