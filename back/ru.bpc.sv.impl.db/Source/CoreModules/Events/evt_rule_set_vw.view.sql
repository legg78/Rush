create or replace force view evt_rule_set_vw as
select id
     , seqnum
     , event_id
     , rule_set_id
     , mod_id
  from evt_rule_set
/
