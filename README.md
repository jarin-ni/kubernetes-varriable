# Kubernetes Nextcloud Deployment with ArgoCD

This repository contains Kubernetes manifests for deploying a Nextcloud application with MariaDB database and Redis cache, managed via ArgoCD for GitOps continuous deployment.

## Architecture

The deployment includes:
- **Nextcloud**: Main application
- **MariaDB**: Database for Nextcloud
- **Redis**: Caching layer
- **NFS Storage**: Persistent storage for data
- **Ingress**: Traefik ingress for external access

## Prerequisites

Before deploying, ensure you have:

1. **Kubernetes Cluster**: A running Kubernetes cluster (v1.19+)
2. **ArgoCD**: Installed and accessible in your cluster
3. **NFS Server**: An NFS server for persistent storage
4. **Traefik Ingress Controller**: Installed for ingress management
5. **kubectl**: Configured to access your cluster
6. **Git**: For repository management

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/jarin-ni/kubernetes-varriable.git
cd kubernetes-varriable
```

### 2. Customize Configuration

Edit the YAML files in the `k8s/` directory to match your environment:

- `namespace.yaml`: Change namespace name
- `nextcloud.yaml`: Update app names, namespace, and environment variables
- `ingress.yaml`: Set your domain name
- `pv.yaml` & `pvc.yaml`: Configure storage settings
- `mariadb.yaml` & `redis.yaml`: Adjust database and cache settings

For different environments, create separate branches or use Kustomize overlays.

### 3. Apply ArgoCD Application

```bash
kubectl apply -f argocd-app.yaml
```

### 4. Verify Deployment

Check ArgoCD UI or CLI:

```bash
argocd app get nextcloud-var
```

## Detailed Configuration

### ArgoCD Project Setup

The `k8s/argocd-project.yaml` defines an ArgoCD AppProject that allows deployments to specified namespaces. Update the destinations if needed:

```yaml
spec:
  destinations:
    - namespace: nextcloud
      server: https://kubernetes.default.svc
```

### Storage Configuration

1. **StorageClass**: Defines the NFS storage class
2. **PersistentVolume**: Pre-allocated NFS volume
3. **PersistentVolumeClaim**: Claims storage for the application

Ensure your NFS server is configured and accessible from all cluster nodes.

**Note:** The automatic configuration uses `nextcloud.example.com` as the domain. Update `k8s/ingress.yaml` and the postStart command in `k8s/nextcloud.yaml` if you use a different domain.

### Application Components

#### Nextcloud
- Image: `nextcloud:27`
- Environment variables configured for MariaDB and Redis
- Database credentials loaded from `nextcloud-secret`
- Persistent storage mounted at `/var/www/html`
- **Automatic Configuration**: Post-start hook automatically configures trusted domains and Traefik overwrite settings

#### MariaDB
- Image: `mariadb:10.11`
- Uses secrets for database credentials
- Persistent storage for data

#### Redis
- Image: `redis:7.4.2`
- Append-only file enabled
- Persistent storage for data

### Secrets Management

The deployment includes a basic secret with placeholder values. **Important:** Change the default passwords before deploying to production!

To update the secret:

1. Generate base64 encoded passwords:
   ```bash
   echo -n "your-actual-root-password" | base64
   echo -n "your-actual-db-password" | base64
   ```

2. Edit `k8s/secret.yaml` and replace the `data` values with your encoded passwords

Or create the secret manually:
```bash
kubectl create secret generic nextcloud-secret \
  --namespace nextcloud \
  --from-literal=MYSQL_ROOT_PASSWORD=your-root-password \
  --from-literal=MYSQL_PASSWORD=your-db-password \
  --from-literal=MYSQL_DATABASE=nextcloud \
  --from-literal=MYSQL_USER=nextcloud
```

### Ingress Configuration

The ingress uses Traefik with the host specified in parameters. Ensure your DNS points to the ingress controller.

## Manual Deployment (Alternative)

If you prefer manual deployment without ArgoCD:

1. Edit the YAML files in `k8s/` to set your desired values
2. Apply the manifests:
   ```bash
   kubectl apply -k k8s/
   ```

## Monitoring and Maintenance

### Check Application Status

```bash
kubectl get pods -n nextcloud
kubectl get pvc -n nextcloud
kubectl get ingress -n nextcloud
```

### View Logs

```bash
kubectl logs -f deployment/nextcloud-var -n nextcloud
kubectl logs -f deployment/nextcloud-var-mariadb -n nextcloud
kubectl logs -f deployment/nextcloud-var-redis -n nextcloud
```

### Update Nextcloud

To update Nextcloud version:
1. Edit `k8s/nextcloud.yaml` and change the image tag
2. Commit and push changes
3. ArgoCD will automatically sync

### Backup Strategy

- **Database**: Use MariaDB backup tools
- **Files**: Backup the NFS share
- **Configuration**: Repository contains all configs

## Troubleshooting

### Common Issues

1. **PVC Pending**: Check NFS server connectivity and permissions
   ```bash
   kubectl describe pvc nextcloud-nfs-pvc-var -n nextcloud
   ```

2. **Pod CrashLoopBackOff**: Check logs and ensure secrets are created
   ```bash
   kubectl describe pod <pod-name> -n nextcloud
   ```

3. **Can't write into config directory**: This is automatically fixed by the initContainer that sets permissions on essential directories. If issues persist, check NFS mount permissions.

4. **SQLite database warning**: Ensure the `nextcloud-secret` contains correct MariaDB credentials and the MariaDB service is running.

5. **Ingress Not Working**: Verify Traefik installation and DNS configuration
   ```bash
   kubectl get ingress -n nextcloud
   ```

4. **ArgoCD Sync Issues**: Check ArgoCD logs and repository access
   ```bash
   argocd app logs nextcloud-var
   ```

### NFS Troubleshooting

Ensure NFS exports are correct:
```bash
showmount -e <nfs-server-ip>
```

Test mount from a node:
```bash
mount -t nfs <nfs-server-ip>:<path> /mnt/test
```

### ArgoCD Troubleshooting

- Check app status: `argocd app get nextcloud-var`
- Force sync: `argocd app sync nextcloud-var`
- View events: `kubectl get events -n argocd`

## Security Considerations

1. **Secrets**: Use Kubernetes secrets for sensitive data
2. **Network Policies**: Implement network policies to restrict traffic
3. **RBAC**: Configure appropriate RBAC for ArgoCD
4. **TLS**: Enable HTTPS for ingress
5. **Updates**: Regularly update images for security patches

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Check the troubleshooting section
- Review ArgoCD documentation
- Open an issue in this repository</content>
<parameter name="filePath">c:\Users\niraj\OneDrive - IIJ Group\Github\kubernetes-varriable\README.md