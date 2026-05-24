# Ingress Quick Notes

Ingress exposes HTTP/HTTPS traffic from outside the cluster to a Kubernetes `Service`.

Typical path:

```text
browser -> node IP / load balancer -> Traefik -> Ingress -> Service -> Pod
```

## Check Ingress Support

Check that the cluster supports Ingress objects:

```sh
kubectl api-resources | grep -i ingress
```

Check that an Ingress controller exists:

```sh
kubectl get ingressclass
```

For k3s default Traefik, you should see something like:

```text
traefik   traefik.io/ingress-controller
```

Check that Traefik is running and exposed:

```sh
kubectl -n kube-system get pods,svc | grep -i traefik
```

## Create An Ingress

Example `ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kube-hello-app
spec:
  ingressClassName: traefik
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kube-hello-app
                port:
                  number: 80
```

Add the file to the app's `kustomization.yaml`, then commit and push so Argo CD can sync it.

## Verify

```sh
kubectl -n hello-dev get ingress -o wide
kubectl -n hello-dev describe ingress kube-hello-app
```

Then open:

```text
http://<k3s-node-ip>/
```

Avoid multiple Ingresses with the same host and same path, such as two apps both claiming `/`.
