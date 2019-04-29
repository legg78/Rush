create table csm_progress_map(id            number
                            , msg_type      varchar2(8)
                            , is_reversal   varchar2(1)
                            , case_progress varchar2(8)
                            , network_id    varchar2(4)
                            , priority      number(4)
                             )
/

comment on table csm_progress_map is 'Case progress mapping'
/
comment on column csm_progress_map.id is 'Primary key'
/
comment on column csm_progress_map.msg_type is 'Message type'
/
comment on column csm_progress_map.is_reversal is 'Reversal flag'
/
comment on column csm_progress_map.case_progress is 'Case progress'
/
comment on column csm_progress_map.network_id is 'Network id or % if any'
/
comment on column csm_progress_map.priority is 'Selection prioriry'
/
