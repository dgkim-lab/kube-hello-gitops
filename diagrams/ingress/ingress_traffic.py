"""Simplified Kubernetes Ingress traffic path.

Install dependencies:
    pip install diagrams

Render:
    python diagrams/ingress/ingress_traffic.py

This creates ingress_traffic.png in the current working directory.
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.client import Users

try:
    from diagrams.onprem.network import Traefik
except ImportError:
    from diagrams.generic.network import Router as Traefik

try:
    from diagrams.k8s.network import Ingress, Service
except ImportError:
    from diagrams.k8s.network import Ing as Ingress
    from diagrams.k8s.network import SVC as Service

from diagrams.k8s.compute import Pod


graph_attr = {
    "fontsize": "16",
    "pad": "0.4",
    "rankdir": "LR",
}


with Diagram(
    "Ingress Traffic Path",
    filename="diagrams/ingress/ingress_traffic",
    show=True,
    direction="LR",
    graph_attr=graph_attr,
):
    user = Users("Browser\nhttp://192.168.1.26/")

    with Cluster("k3s cluster"):
        traefik = Traefik("Traefik\nIngress Controller")
        ingress = Ingress("Ingress\n/kube-hello-app")
        service = Service("Service\nkube-hello-app:80")
        pod = Pod("Pod\ncontainer:3000")

    user >> Edge(label="HTTP :80") >> traefik
    traefik >> Edge(label="route rule") >> ingress
    ingress >> Edge(label="backend") >> service
    service >> Edge(label="targetPort 3000") >> pod
