# Alfred plugin: Kubernetes CI tests

This plugin executes a set of tools that validate and score Kubernetes configuration.

## Parameters

* `aws_access_key_id`

Access key ID of the `bot-k8s-ci` IAM user.

* `aws_secret_access_key`

Secret access key of the `bot-k8s-ci` IAM user.

## Example usage
```
- name: K8S CI tests
  image: wuakitv/alfred-k8s-ci
  settings:
    aws_access_key_id:
      from_consul_secret: bot-k8s-ci/aws_access_key_id
    aws_secret_access_key:
      from_consul_secret: bot-k8s-ci/aws_secret_access_key
