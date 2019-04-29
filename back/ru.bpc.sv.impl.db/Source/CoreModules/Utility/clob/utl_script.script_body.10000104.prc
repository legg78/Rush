begin update iss_cardholder set cardholder_name = upper(cardholder_name) where cardholder_name != upper(cardholder_name); end;
