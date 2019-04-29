create or replace package cst_bmed_card_export_pkg is

procedure export_barcodes(
    i_service_id            in     com_api_type_pkg.t_short_id
);

end;
/
