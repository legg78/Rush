create or replace package body acq_ui_revenue_sharing_pkg as

procedure add_revenue_sharing(
    o_revenue_sharing_id           out  com_api_type_pkg.t_medium_id
  , o_seqnum                       out  com_api_type_pkg.t_seqnum
  , i_terminal_id               in      com_api_type_pkg.t_short_id
  , i_customer_id               in      com_api_type_pkg.t_medium_id
  , i_account_id                in      com_api_type_pkg.t_account_id
  , i_provider_id               in      com_api_type_pkg.t_short_id
  , i_inst_id                   in      com_api_type_pkg.t_inst_id  default null
  , i_mod_id                    in      com_api_type_pkg.t_tiny_id
  , i_purpose_id                in      com_api_type_pkg.t_short_id
  , i_service_id                in      com_api_type_pkg.t_short_id
  , i_fee_type                  in      com_api_type_pkg.t_dict_value
  , i_fee_id                    in      com_api_type_pkg.t_short_id
) is
    l_inst_id                   com_api_type_pkg.t_inst_id;
begin
    o_revenue_sharing_id := acq_revenue_sharing_seq.nextval;

    o_seqnum := 1;

    if i_inst_id is null then
        select inst_id
          into l_inst_id
          from prd_customer
         where id = i_customer_id;
    else
        l_inst_id := i_inst_id;
    end if;

    insert into acq_revenue_sharing_vw (
        id
      , seqnum
      , terminal_id
      , customer_id
      , account_id
      , provider_id
      , mod_id
      , fee_type
      , fee_id
      , inst_id
      , service_id
      , purpose_id
    ) values (
        o_revenue_sharing_id
      , o_seqnum
      , i_terminal_id
      , i_customer_id
      , i_account_id
      , i_provider_id
      , i_mod_id
      , i_fee_type
      , i_fee_id
      , l_inst_id
      , i_service_id
      , i_purpose_id
    );

exception
    when no_data_found then
        null;
end;

procedure modify_revenue_sharing(
    i_revenue_sharing_id        in      com_api_type_pkg.t_medium_id
  , io_seqnum                   in out  com_api_type_pkg.t_seqnum
  , i_terminal_id               in      com_api_type_pkg.t_short_id
  , i_customer_id               in      com_api_type_pkg.t_medium_id
  , i_account_id                in      com_api_type_pkg.t_account_id
  , i_provider_id               in      com_api_type_pkg.t_short_id
  , i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_mod_id                    in      com_api_type_pkg.t_tiny_id
  , i_purpose_id                in      com_api_type_pkg.t_short_id
  , i_service_id                in      com_api_type_pkg.t_short_id
  , i_fee_type                  in      com_api_type_pkg.t_dict_value
  , i_fee_id                    in      com_api_type_pkg.t_short_id
) is
begin
    update acq_revenue_sharing_vw
       set seqnum      = io_seqnum
         , terminal_id = i_terminal_id
         , customer_id = i_customer_id
         , account_id  = i_account_id
         , provider_id = i_provider_id
         , inst_id     = i_inst_id
         , mod_id      = i_mod_id
         , purpose_id  = i_purpose_id
         , service_id  = i_service_id
         , fee_type    = i_fee_type
         , fee_id      = i_fee_id
     where id          = i_revenue_sharing_id;

    io_seqnum := io_seqnum + 1;

end;

procedure modify_revenue_sharing(
    i_revenue_sharing_id        in      com_api_type_pkg.t_medium_id
  , io_seqnum                   in out  com_api_type_pkg.t_seqnum
  , i_fee_type                  in      com_api_type_pkg.t_dict_value
  , i_fee_id                    in      com_api_type_pkg.t_short_id
) is
begin
    update acq_revenue_sharing_vw
       set seqnum      = io_seqnum
         , fee_type    = i_fee_type
         , fee_id      = i_fee_id
     where id          = i_revenue_sharing_id;

    io_seqnum := io_seqnum + 1;
end;

procedure remove_revenue_sharing(
    i_revenue_sharing_id        in      com_api_type_pkg.t_medium_id
  , i_seqnum                    in      com_api_type_pkg.t_seqnum
) is
begin
    update acq_revenue_sharing_vw
       set seqnum      = i_seqnum
     where id          = i_revenue_sharing_id;

    delete acq_revenue_sharing_vw
     where id          = i_revenue_sharing_id;

end;

end;
/
