create or replace package body net_cst_bin_pkg is

    g_network_priority          com_api_type_pkg.t_integer_tab;
  
    procedure init_network_priority is
        l_network               com_api_type_pkg.t_integer_tab;
        l_priority              com_api_type_pkg.t_integer_tab;
    begin
        g_network_priority.delete;
        
        select
            n.id
            , n.bin_table_scan_priority
        bulk collect into
            l_network
            , l_priority
        from
            net_network n;
        
        for i in 1..l_network.count loop
            g_network_priority(l_network(i)) := l_priority(i);
        end loop;
        
        l_network.delete;
        l_priority.delete;
    end;
    
    function bin_table_scan_priority (
        i_network_id            in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_tiny_id is
    begin
        if not g_network_priority.exists(i_network_id) then
            init_network_priority;
        end if;
        return g_network_priority(i_network_id);
   end;

    function extra_scan_priority (
        i_card_number           in com_api_type_pkg.t_card_number
        , i_network_id          in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_tiny_id is
    begin
        return 0;
    end;

    function advances_scan_priority (
        i_card_number           in com_api_type_pkg.t_card_number
        , i_pan_low             in com_api_type_pkg.t_card_number
        , i_network_id          in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_tiny_id is
    begin
        return 0;
    end;

begin
    init_network_priority;
end;
/
