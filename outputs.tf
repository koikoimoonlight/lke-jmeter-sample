output "kubeconfig" {
	value = linode_lke_cluster.jmeter-perf.kubeconfig
	sensitive = true
}

output "nodes" {
	value = linode_lke_cluster.jmeter-perf.pool.0.nodes
}

data "linode_instances" "all" {}
data "linode_instances" "lke" {
	filter {
	  name = "label"
	  values = [for s in  data.linode_instances.all.instances.*.label : s if length(regexall("lke.*", s)) > 0 ]
	}
}
output "ip_address" {
  value = data.linode_instances.lke.instances.*.ip_address
}