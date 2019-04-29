create or replace package vis_prc_vdep_pkg is

    -- BID - Represents the Business ID (BID) number for your organization, i.e. the issuer BID.
    function get_bid( 
        i_inst_id               in com_api_type_pkg.t_inst_id
    ) return com_api_type_pkg.t_name;

    procedure upload_bulk (
        i_inst_id               in com_api_type_pkg.t_inst_id
      , i_rows                  in com_api_type_pkg.t_medium_id     default 15000
    );

end vis_prc_vdep_pkg;
/
