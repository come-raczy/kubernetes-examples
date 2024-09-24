# Examples using `kubectl` directly

The recommended setup is a freshly created cluster, for instance using Docker Desktop.

## Expose a service

The script `expose_service.sh` creates a deployment and a service, and then exposes the service using an ingress.
The service is trivially created using the `httpd` image. One ingress is created to access the service via `localhost`.
If there is a host name mapped to "127.0.0.1" in "/etc/hosts", another ingress is created to access the service via the
host name.
