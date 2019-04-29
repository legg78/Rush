create or replace package itf_mpt_prc_ack_export_pkg is

procedure export_settl_acknowledgement(
   i_mpt_version         in 	    com_api_type_pkg.t_name
,  i_inst_id             in       com_api_type_pkg.t_inst_id
);

end itf_mpt_prc_ack_export_pkg;
/
