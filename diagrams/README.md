# Diagrams

Small diagrams-as-code examples for this repository.

## Setup

```sh
pip install -r diagrams/requirements.in
```

The `diagrams` package also requires Graphviz. On macOS:

```sh
brew install graphviz
```

## Render Ingress Traffic

```sh
python diagrams/ingress/ingress_traffic.py
```

Output:

```text
diagrams/ingress/ingress_traffic.png
```
