terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "2.21.2"
    }
  }
}

provider "linode" {
    token = "${var.token}"
}

resource "linode_lke_cluster" "jmeter-perf" {
    label = "${var.linode_lke_cluster.label}"
    k8s_version = "${var.linode_lke_cluster.k8s_version}"
    region = "${var.linode.region}"

    pool {
        type = "${var.linode_lke_cluster.type}"
        count = "${var.linode_lke_cluster.count}"
    }
}