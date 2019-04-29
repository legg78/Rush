create index acq_merchant_contract_ndx on acq_merchant (contract_id)
/

create index acq_merchant_number_ndx on acq_merchant (merchant_number)
/

create index acq_merchant_number_rvrs_ndx on acq_merchant (reverse(merchant_number))
/

create index acq_merchant_name_ndx on acq_merchant (merchant_name)
/

create index acq_merchant_parent_ndx on acq_merchant (parent_id)
/

create index acq_merchant_partner_id_code on acq_merchant (partner_id_code)
/

drop index acq_merchant_partner_id_code
/
create unique index acq_merchant_partner_inst_uk on acq_merchant (partner_id_code, decode(partner_id_code, null, null, inst_id))
/
