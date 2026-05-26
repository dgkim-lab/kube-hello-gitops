"""Current Traefik-backed ingress traffic paths.

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
    "splines": "polyline",
}


with Diagram(
    "Current Ingress Traffic Paths",
    filename="diagrams/ingress/ingress_traffic",
    show=True,
    direction="LR",
    graph_attr=graph_attr,
):
    app_user = Users("Browser\nhello.k3s.dgkim.net\nor /")
    file_user = Users("Browser\nfile-server.k3s.dgkim.net")

    with Cluster("k3s cluster"):
        traefik = Traefik("Traefik\nIngress Controller")

        with Cluster("hello-dev namespace"):
            app_ingress = Ingress("Ingress\nkube-hello-app\n/ and hello.k3s.dgkim.net")
            app_service = Service("Service\nkube-hello-app:80")
            app_pod = Pod("Pod\nkube-hello-app\ncontainer:3000")

            file_ingress = Ingress(
                "Ingress\nkube-hello-file-server\n/files and file-server.k3s.dgkim.net"
            )
            redirect = Ingress("Traefik Middleware\n/ -> /files redirect")
            file_service = Service("Service\nkube-hello-file-server:80")
            file_pod = Pod("Pod\nkube-hello-file-server\ncontainer:3000")

    app_user >> Edge(label="HTTP :80") >> traefik
    file_user >> Edge(label="HTTP :80") >> traefik

    traefik >> Edge(label="route / host rule") >> app_ingress
    app_ingress >> Edge(label="backend") >> app_service
    app_service >> Edge(label="targetPort 3000") >> app_pod

    traefik >> Edge(label="route /files or host rule") >> file_ingress
    file_ingress >> Edge(label="middleware for host root") >> redirect
    file_ingress >> Edge(label="backend") >> file_service
    file_service >> Edge(label="targetPort 3000") >> file_pod
