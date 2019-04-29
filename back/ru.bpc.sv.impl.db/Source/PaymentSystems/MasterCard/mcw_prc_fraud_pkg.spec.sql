CREATE OR REPLACE package mcw_prc_fraud_pkg is

    procedure upload_fraud(
        i_inst_id   in  com_api_type_pkg.t_inst_id       default null
    );

end;
/
