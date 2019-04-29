create or replace package vis_prc_vcf_pkg as

procedure export_data(
    i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_company_id             in     com_api_type_pkg.t_short_id
);

end;
/
