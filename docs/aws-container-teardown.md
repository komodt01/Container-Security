# AWS Container Teardown

## Steps
1. **Destroy Infrastructure**
   ``bash
   cd terraform/aws
   terraform destroy -auto-approve
   ``

2. **Clean Up ECR**
   ``bash
   aws ecr delete-repository --repository-name myapp-repo --force
   ``

3. **Delete Logs**
   ``bash
   aws logs delete-log-group --log-group-name /ecs/myapp
   ``

## Notes
- Ensure all resources are deleted to avoid costs.
