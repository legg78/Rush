create or replace package pos_api_const_pkg as

POS_BATCH_STATUS_OPENED         constant    com_api_type_pkg.t_dict_value   := 'PBSTOPEN';
POS_BATCH_STATUS_CLOSED         constant    com_api_type_pkg.t_dict_value   := 'PBSTCLSD';
POS_BATCH_STATUS_UPLOADING      constant    com_api_type_pkg.t_dict_value   := 'PBSTUPLD';

end;
/