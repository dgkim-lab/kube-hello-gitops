# cert-manager with Route53 DNS-01

This setup installs cert-manager through Argo CD and uses Route53 DNS-01
validation for Let's Encrypt certificates.

## Manual Route53 credential secret

Create an IAM access key with permission to manage TXT records in the
`dgkim.net` Route53 hosted zone, then create the Kubernetes secret manually:

```shell
cp scripts/route53-secret.env.example.sh scripts/route53-secret.env.sh
vi scripts/route53-secret.env.sh

set -a
. ./scripts/route53-secret.env.sh
set +a

./scripts/create-route53-credentials-secret.sh
```

The generated secret is:

```text
cert-manager/route53-credentials
```

It contains:

```text
access-key-id
secret-access-key
```

Do not commit `scripts/route53-secret.env.sh`.

## IAM permissions

Use a policy like this, replacing the hosted zone ARN with the `dgkim.net`
hosted zone ID:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/REPLACE_WITH_HOSTED_ZONE_ID",
      "Condition": {
        "ForAllValues:StringEquals": {
          "route53:ChangeResourceRecordSetsRecordTypes": ["TXT"]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
```

## Verify

```shell
kubectl get pods -n cert-manager
kubectl get clusterissuer letsencrypt-route53-prod
kubectl -n argocd describe certificate argocd-server-tls
kubectl -n argocd get secret argocd-server-tls
curl -Iv https://argocd.k3s.dgkim.net
```
