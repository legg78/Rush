begin update net_bin_range set pan_low = rpad(pan_low, 19, '0'), pan_high = rpad(pan_high, 19, '9'), pan_length = 19 where iss_network_id in (1008, 1009) and length(pan_low) < 16 and length(pan_high) < 16 and pan_length < 16; net_api_bin_pkg.rebuild_bin_index; end;