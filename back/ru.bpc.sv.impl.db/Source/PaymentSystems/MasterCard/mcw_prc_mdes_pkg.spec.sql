create or replace package mcw_prc_mdes_pkg is

    procedure upload_bulk_r311 (
        i_inst_id               in com_api_type_pkg.t_inst_id
    );

end;
/
