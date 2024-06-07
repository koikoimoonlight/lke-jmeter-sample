variable "linode" {
    default = {
        region = "ap-northeast"
    }  
}

variable "token" {
    type = string
}

variable "linode_lke_cluster" {
    default = {
        label = "jmeter-perf"
        k8s_version = "1.29"
        type = "g6-standard-2"
        count = 2
    }
}