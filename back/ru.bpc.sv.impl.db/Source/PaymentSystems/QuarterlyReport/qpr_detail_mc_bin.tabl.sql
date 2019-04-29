create table qpr_detail_mc_bin(
    bin                varchar2(24)
  , product_category   varchar2(100)
)
/
comment on table qpr_detail_mc_bin                   is 'MC BIN which is used in table qpr_detail'
/
comment on column qpr_detail_mc_bin.bin              is 'Full BIN for MC network'
/
comment on column qpr_detail_mc_bin.product_category is 'Product Category Code. D = Debit Product, C = Credit Product, P = Prepaid Product, O = Commercial Product, N = Not applicable'
/

