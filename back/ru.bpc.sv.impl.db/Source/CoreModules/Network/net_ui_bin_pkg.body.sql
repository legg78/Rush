create or replace package body net_ui_bin_pkg is

    procedure sync_local_bins is
    begin
        net_api_bin_pkg.sync_local_bins;            
    end;

end;
/
