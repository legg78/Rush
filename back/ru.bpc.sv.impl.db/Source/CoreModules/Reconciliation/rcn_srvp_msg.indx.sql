create unique index rcn_srvp_msg_ndx_uk on rcn_srvp_msg (msg_source, payment_order_number, order_id, recon_msg_id)
/
create index rcn_srvp_msg_recon_ndx on rcn_srvp_msg(decode(recon_status, 'RNST0000', recon_status, 'RNST0200', recon_status, null) asc)
/
create index rcn_srvp_msg_source_ndx on rcn_srvp_msg(msg_source)
/
create index rcn_srvp_msg_provider_ndx on rcn_srvp_msg(provider_id)
/
