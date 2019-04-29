create or replace package utl_prc_process_pkg is

    procedure process_card (
        i_inst_id                   in com_api_type_pkg.t_inst_id := null
    );
    
    procedure process_account (
        i_inst_id                   in com_api_type_pkg.t_inst_id := null
    );
    
    procedure process_application (
        i_inst_id                   in com_api_type_pkg.t_inst_id := null
    );

end;
/
