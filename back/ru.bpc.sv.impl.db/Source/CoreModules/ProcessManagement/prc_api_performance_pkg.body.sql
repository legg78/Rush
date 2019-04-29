create or replace package body prc_api_performance_pkg as
/*
* API for Performance monitoring
* Module: prc_api_performance_pkg
*/

type t_timestamp_tab        is table of timestamp index by com_api_type_pkg.t_name;

g_timestamp_tab             t_timestamp_tab;

type t_performance_metric_rec is record (
    method_name             com_api_type_pkg.t_name
  , label_name              com_api_type_pkg.t_name
  , fetched_count           com_api_type_pkg.t_long_id
  , calls_count             com_api_type_pkg.t_long_id
  , calls_total_time        number(22,6)
);

type t_performance_metric_tab is table of t_performance_metric_rec index by com_api_type_pkg.t_name;

g_performance_metric        t_performance_metric_tab;

procedure reset_performance_metrics is
begin
    g_performance_metric.delete;
end reset_performance_metrics;

procedure start_performance_metric(
    i_method_name    in     com_api_type_pkg.t_name
  , i_label_name     in     com_api_type_pkg.t_name
) is
    l_label_name            com_api_type_pkg.t_name;
begin
    l_label_name := upper(i_method_name || i_label_name);
    g_timestamp_tab(l_label_name) := systimestamp;
end start_performance_metric;

procedure finish_performance_metric(
    i_method_name    in     com_api_type_pkg.t_name
  , i_label_name     in     com_api_type_pkg.t_name
  , i_fetched_count  in     com_api_type_pkg.t_long_id  default null
) is
    l_label_name            com_api_type_pkg.t_name;
    l_old_timestamp         timestamp;
    l_new_timestamp         timestamp;
    l_seconds               number(22,6);
begin
    l_new_timestamp := systimestamp;

    l_label_name    := upper(i_method_name || i_label_name);
    l_old_timestamp := g_timestamp_tab(l_label_name);

    l_seconds := round((trunc(l_new_timestamp, 'MI') - trunc(l_old_timestamp, 'MI')) * 24 * 60 * 60 + extract(second from (l_new_timestamp - l_old_timestamp)), 6);

    g_performance_metric(l_label_name).method_name       := i_method_name;
    g_performance_metric(l_label_name).label_name        := i_label_name;
    g_performance_metric(l_label_name).fetched_count     := nvl(g_performance_metric(l_label_name).fetched_count, 0)    + nvl(i_fetched_count, 0);
    g_performance_metric(l_label_name).calls_count       := nvl(g_performance_metric(l_label_name).calls_count, 0)      + 1;
    g_performance_metric(l_label_name).calls_total_time  := nvl(g_performance_metric(l_label_name).calls_total_time, 0) + l_seconds;
end finish_performance_metric;

procedure print_performance_metrics(
    i_processed_count  in     com_api_type_pkg.t_long_id
) is
    l_label_name              com_api_type_pkg.t_name;
begin
    trc_log_pkg.info('**** Start performance metrics ****');

    trc_log_pkg.info(
        i_text       => 'processed_count [#1]'
      , i_env_param1 => i_processed_count
    );

    l_label_name := g_performance_metric.first();
    while l_label_name is not null loop
        l_label_name := upper(g_performance_metric(l_label_name).method_name || g_performance_metric(l_label_name).label_name);

        trc_log_pkg.info(
            i_text       => 'Method [#1], label [#2], calls_count [#3], fetched_count [#4], calls_total_time [#5]'
          , i_env_param1 => g_performance_metric(l_label_name).method_name
          , i_env_param2 => g_performance_metric(l_label_name).label_name
          , i_env_param3 => g_performance_metric(l_label_name).calls_count
          , i_env_param4 => g_performance_metric(l_label_name).fetched_count
          , i_env_param5 => to_char(g_performance_metric(l_label_name).calls_total_time, 'FM999999999999999990.009999')
        );

        l_label_name := g_performance_metric.next(l_label_name);
    end loop;

    trc_log_pkg.info('**** Finish performance metrics ****');

    reset_performance_metrics;

end print_performance_metrics;

end prc_api_performance_pkg;
/
