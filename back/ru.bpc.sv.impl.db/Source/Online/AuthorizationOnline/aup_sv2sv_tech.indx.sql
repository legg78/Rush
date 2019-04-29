create index aup_sv2sv_tech_trace on aup_sv2sv_tech (
    trace
    , direction
    , iso_msg_type
)
/
create index aup_sv2sv_tech_tech_id on aup_sv2sv_tech (
    tech_id
    , iso_msg_type
    , direction
)
/