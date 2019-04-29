create or replace package body com_api_reject_pkg is
/*********************************************************
*  API for Reject Management module <br />
*  Created by Mashonkin V.(mashonkin@bpcbt.com)  at 17.06.2015 <br />
*  Last changed by $Author: mashonkin $ <br />
*  $LastChangedDate:: 2015-06-17 19:28:48 +0300#$ <br />
*  Revision: $LastChangedRevision: 52735 $ <br />
*  Module: com_api_reject_pkg <br />
*  @headcom
**********************************************************/


    function get_iss_network_by_bin (
        i_bin in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_tiny_id
    is
        l_iss_network_id net_bin_range.iss_network_id%type;
    begin
        --net_api_bin_pkg.get_bin_info
        --net_ui_network_vw
        select
            a.iss_network_id
         into 
            l_iss_network_id
         from 
            (select
                row_number() over (order by n.bin_table_scan_priority) as rn,
                b.iss_network_id
             from
                net_bin_range_index i
                , net_bin_range b
                , net_network n
            where i.pan_prefix     = substr(to_char(i_bin), 1, 5)
              and i_bin            between substr(i.pan_low, 1, length(i_bin)) and substr(i.pan_high, 1, length(i_bin))
              and i.pan_low        = b.pan_low
              and i.pan_high       = b.pan_high
              and b.iss_network_id = n.id
              and (b.activation_date is null or b.activation_date <= sysdate)
            ) a
        where a.rn = 1;
        --
        return l_iss_network_id;
    exception
        when no_data_found then 
            trc_log_pkg.warn(
                i_text => 'get_iss_network_by_bin: iss_nework not found by bin [#1]', 
                i_env_param1 => i_bin
            );
        return null;
    end get_iss_network_by_bin;


begin
  null;
end com_api_reject_pkg;
/