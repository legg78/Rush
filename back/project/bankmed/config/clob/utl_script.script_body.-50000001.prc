begin update cst_bmed_cbs_narrative set need_aggregate = 0 where need_aggregate is null; end;
