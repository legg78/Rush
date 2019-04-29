create unique index aup_cyberplat_in_uk on aup_cyberplat_in (
    receipt
    , nvl2(receipt, device_id, null)
    , nvl2(receipt, is_response, null)
    , nvl2(receipt, action, null)
)
/