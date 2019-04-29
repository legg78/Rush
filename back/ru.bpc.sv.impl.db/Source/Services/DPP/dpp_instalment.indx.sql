create index dpp_instalment_dpp_id_ndx on dpp_instalment(dpp_id)
/
create index dpp_instalment_not_billed_ndx on dpp_instalment (decode(macros_id, null, dpp_id, null))
/
