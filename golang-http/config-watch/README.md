#CONFIG WATCHER

Updates a file when kube service account token is updated using fswatch and text/template.

Use `./build-script.sh _patch_number_`

then change patch number in ../deployment/envoy.yaml

see section
```yaml
        - name: file-watcher
          image: jatrat/file-watch:v0.0.14
          command: ["/app"]

```
