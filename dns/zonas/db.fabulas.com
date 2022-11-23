$TTL    3600
@       IN      SOA     ns.fabulas.com. a.fabulas.com. (
                   2022051001           ; Serial
                         3600           ; Refresh [1h]
                          600           ; Retry   [10m]
                        86400           ; Expire  [1d]
                          600 )         ; Negative Cache TTL [1h]
;
@       IN      A       10.1.0.254
@       IN      NS      ns.fabulas.com.

ns      IN      A       10.1.0.254

oscuras         IN      A    10.1.0.253
maravillosas    IN      A    10.1.0.253
