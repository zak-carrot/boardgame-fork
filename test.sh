                ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \

                ${BASTION_USER}@${BASTION_HOST} 
                
                'sudo su root && whoami && 
                
                aws eks update-kubeconfig --name todo-eks-cluster-1 --region ap-south-1 --profile jayesh && 
                
                kubectl create ns capstone --dry-run=client -o yaml | kubectl apply -f - && 
                
                kubectl apply -f /opt/app-files/deployment.yaml -n capstone && 
                
                kubectl rollout restart deployment.apps/boardgame-app -n capstone