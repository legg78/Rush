create index crd_debt_invoice_debt_id_ndx on crd_invoice_debt (debt_id)
/****************** partition start ********************
    local
******************** partition end ********************/
/


create index crd_debt_invoice_inv_id_ndx on crd_invoice_debt (invoice_id)
/****************** partition start ********************
    global
******************** partition end ********************/
/
alter index crd_debt_invoice_debt_id_ndx rename to crd_invoice_debt_id_ndx
/
alter index crd_debt_invoice_inv_id_ndx rename to crd_invoice_inv_id_ndx
/

create index crd_invoice_debt_intr_id_ndx on crd_invoice_debt (debt_intr_id)
/
