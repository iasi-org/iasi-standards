# PlantUML5

## Configuración

```yaml
engines:
  plantuml:
    enabled: true
    server: http://javier:1025
    format: svg
    cache: true
    styles:
      - resources/plantuml/iasi.puml
```

También admite un único estilo:

```yaml
styles: resources/plantuml/iasi.puml
```

Los estilos se incorporan antes de calcular el SHA1. Cualquier cambio en
`iasi.puml` invalida automáticamente la caché.
