create table opr_bin_info
(
    oper_id                 number(16)            not null
  , part_key                date generated always as (to_date(substr(lpad(to_char(oper_id), 16, '0'), 1, 6), 'yymmdd')) virtual
  , participant_type        varchar2(8)
  , split_hash              number(4)
  , product_id              varchar2(3)
  , brand                   varchar2(3)
  , region                  varchar2(3)
  , product_type            varchar2(3)
  , account_funding_source  varchar2(1)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      
subpartition by list (split_hash)                                                        
subpartition template                                                                    
(                                                                                        
    <subpartition_list>                                                                  
)                                                                                        
(                                                                                        
    partition opr_bin_info_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))     
)                                                                                        
******************** partition end ********************/
/
comment on table opr_bin_info is 'Operation fee info'
/
comment on column opr_bin_info.oper_id is 'Operation ID'
/
comment on column opr_bin_info.split_hash is 'Hash value to split further processing'
/
comment on column opr_bin_info.participant_type is 'Type of operation participant (Dictionary "PRTY" - Issuer, Acquirer, Destination)'
/
comment on column opr_bin_info.product_id is 'MCW: This is the Product ID recognized by GCMS for the issuer account range and card program identifier combination. VIS: L - Electron, Spaces - not define, F - Classic, A - Traditional, I -Infinite, N -Platinum, P - Gold, S - Purchasing etc'
/
comment on column opr_bin_info.brand is 'The card program identifier associated to the account range'
/
comment on column opr_bin_info.region is 'MCW: 1 - US, A – Canada, B – Latin America and Caribbean, C – Asia/Pacific, D – Europe, E – South Asia/Middle East/Africa, VIS: 1 – US, 2 – Canada, 3 – EU, 4 – Asia-Pacific, 5 – Latin America and Caribbean, 6 – CEMEA '
/
comment on column opr_bin_info.product_type is 'The product type of the associated account range and card program identifier.Valid values: 1 = Consumer 2 = Commercial 3 = Both'
/
comment on column opr_bin_info.account_funding_source is 'Account Funding Source. C = Credit, D = Debit, P = Prepaid, H = Charge, R = Deferred Debit'
/
