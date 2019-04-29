create or replace package cst_amk_agents_awarding_pkg as

procedure calculate_awarding(
    i_start_date        in     date
  , i_end_date          in     date 
  , i_dest_curr         in     com_api_type_pkg.t_curr_code      default '116'
);

procedure calculate_pilot_bonus(
    i_dest_curr         in     com_api_type_pkg.t_curr_code      default '116'
);

procedure calculate_periodic_bonus(
    i_dest_curr         in     com_api_type_pkg.t_curr_code      default '116'
);

end;
/
