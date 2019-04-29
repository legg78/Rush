create or replace force view iss_reissue_reason_vw as
select r.id
     , r.seqnum
     , r.inst_id
     , r.reissue_reason
     , r.reissue_command
     , r.pin_request
     , r.pin_mailer_request
     , r.embossing_request
     , r.reiss_start_date_rule
     , r.reiss_expir_date_rule
     , r.perso_priority
     , r.clone_optional_services
  from iss_reissue_reason r
/
