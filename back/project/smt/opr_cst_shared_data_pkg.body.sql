create or replace package body opr_cst_shared_data_pkg is

procedure collect_global_oper_params(
    io_params       in out nocopy   com_api_type_pkg.t_param_tab
) is
begin
    trc_log_pkg.debug(
        i_text          => 'opr_cst_shared_data_pkg.collect_global_oper_params dummy'
    );
end;

procedure collect_oper_params(
    i_oper          in              opr_api_type_pkg.t_oper_rec         default null
  , i_iss_part      in              opr_api_type_pkg.t_oper_part_rec    default null
  , i_acq_part      in              opr_api_type_pkg.t_oper_part_rec    default null
  , io_params       in out nocopy   com_api_type_pkg.t_param_tab
) is
    
begin
    trc_log_pkg.debug(
        i_text          => 'opr_cst_shared_data_pkg.collect_oper_params dummy'
    );

    opr_api_shared_data_pkg.set_param(
        i_name   => 'IS_ACQ_HOSTED'
      , i_value  =>  com_api_flexible_data_pkg.get_flexible_value(
                                                i_field_name    => cst_smt_api_const_pkg.IS_HOSTED    
                                                , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                , i_object_id   => opr_api_shared_data_pkg.g_acq_participant.inst_id
                                                )
    );    

    opr_api_shared_data_pkg.set_param(
        i_name   => 'IS_ACQ_SWITCHED'
      , i_value  =>  com_api_flexible_data_pkg.get_flexible_value(
                                                i_field_name    => cst_smt_api_const_pkg.IS_SWITCHED    
                                                , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                , i_object_id   => opr_api_shared_data_pkg.g_acq_participant.inst_id
                                                )
    );
        
    opr_api_shared_data_pkg.set_param(
        i_name   => 'IS_ISS_HOSTED'
      , i_value  =>  com_api_flexible_data_pkg.get_flexible_value(
                                                i_field_name    => cst_smt_api_const_pkg.IS_HOSTED    
                                                , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                , i_object_id   => opr_api_shared_data_pkg.g_iss_participant.inst_id
                                                )
    );    

    opr_api_shared_data_pkg.set_param(
        i_name   => 'IS_ISS_SWITCHED'
      , i_value  =>  com_api_flexible_data_pkg.get_flexible_value(
                                                i_field_name    => cst_smt_api_const_pkg.IS_SWITCHED    
                                                , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                , i_object_id   => opr_api_shared_data_pkg.g_iss_participant.inst_id
                                                )
    );    

end;

end;
/
