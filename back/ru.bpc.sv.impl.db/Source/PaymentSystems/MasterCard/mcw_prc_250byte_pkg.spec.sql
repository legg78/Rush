create or replace package mcw_prc_250byte_pkg as

-- Processing of MasterCard single message reconciliation
procedure load (
    i_inst_id               in  com_api_type_pkg.t_tiny_id
    , i_test_option         in  varchar2 default null -- possible value 'M' for test processing
);

end;
/
 