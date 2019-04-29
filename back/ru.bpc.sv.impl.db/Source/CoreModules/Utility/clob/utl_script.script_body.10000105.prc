begin
    update mcw_currency_rate t
    set t.p0164_1 = lpad(t.p0164_1, 3, '0')
      , t.de050   = lpad(t.de050,   3, '0')
      , t.p0164_2 = t.p0164_2/10000
    where t.id in (select f.id from mcw_currency_update f where f.mti is null);
end;
