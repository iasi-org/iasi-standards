# Quarto Engine Core

Componentes comunes para engines Quarto.

## Configuracion

```yaml
engines:
  plantuml:
    enabled: true
    server: http://javier:1025
    format: svg
    cache: true
```

`cache` admite:

- `true`: reutiliza y actualiza la cache.
- `false`: siempre recompila.
- `clean`: limpia una vez y despues funciona como `true`.

La cache se guarda en:

```text
.quarto/<engine>/
  <sha1>.<format>
  <sha1>.sha1
```
