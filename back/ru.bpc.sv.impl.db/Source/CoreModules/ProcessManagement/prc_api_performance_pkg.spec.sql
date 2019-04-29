create or replace package prc_api_performance_pkg as
/*
* API for Performance monitoring
* Module: prc_api_performance_pkg
*/

procedure reset_performance_metrics;

procedure start_performance_metric(
    i_method_name    in     com_api_type_pkg.t_name
  , i_label_name     in     com_api_type_pkg.t_name
);

procedure finish_performance_metric(
    i_method_name    in     com_api_type_pkg.t_name
  , i_label_name     in     com_api_type_pkg.t_name
  , i_fetched_count  in     com_api_type_pkg.t_long_id  default null
);

procedure print_performance_metrics(
    i_processed_count  in     com_api_type_pkg.t_long_id
);
  
end prc_api_performance_pkg;
/
