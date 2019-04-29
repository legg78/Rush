create or replace package orq_api_application_pkg as

/*
 * Processing of operational request.
 * @param i_appl_id     Application identifier
 */
procedure process_request(
    i_appl_id          in     com_api_type_pkg.t_long_id    default null
);

end;
/
