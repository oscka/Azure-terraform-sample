locals {
  dns_prefix = "test-aims-k8s-3-dns"
  node_pool_name = "agentpool2"
  cluster_name = "test-aims-k8s-3"
  default_node_pool_name = "agentpool"
}

module "aks_kubernetes_cluster" {
  source              = "../../../modules/container/kubernetes_cluster"
  dns_prefix          = local.dns_prefix
  name                = local.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  default_nodepool_name = local.default_node_pool_name
  enable_auto_scaling = true
  vm_size = "Standard_DS2_v2"
  max_count = 4
  min_count = 2
  depends_on = [
    module.resource_group
  ]
}


# 클러스터를 생성하고 클러스터에 배포할 yaml이나 네임스페이스 헬름을 호출 합니다 
# 구성중에 변수가 필요하면 aks_configure 디렉토리의 variables.tf에서 구성하시면 됩니다 
module "cluster_configure" {
  source = "./aks_configure"
  helm_repository_password = var.helm_repository_password
  helm_repository_username = var.helm_repository_username
  depends_on = [ module.aks_kubernetes_cluster ]
}

# 추가적인 노드풀 생성 할 때 사용합니다 
# 테스트단계라 비용때문에 주석 처리 했습니다  
# module "node_pool" {
#   source = "../../../modules/container/kubernetes_node_pool"
#   name = local.node_pool_name
#   cluster_id = module.aks_kubernetes_cluster.id
#   max_count = 2
#   min_count = 1
#   vm_size = "Standard_DS2_v2"
#   enable_auto_scaling = true
# }



# 클러스터 생성 후 kubeconfig 세팅하는 명령어가 aks_readme.md 라는 파일로 생성 합니다 
# 현재 디렉토리에서 aks_readme.md 파일을 확인후 터미널에서 명령어를 치시면 됩니다
module "kubectl_output" {
  source = "../../../modules/ETC/output_file"
  value = templatefile("../../common/user_templates/aks_readme.tpl", { rg_name = var.resource_group_name ,aks_name = local.cluster_name })
  out_path = "${path.module}/aks_readme.md"  
}

