
routed_network_name = "10_254_23_0_24"

vapp_name = "NetPlan Voyager"


vms = [
    {
        name = "dev-npvgr-app-01"
        cpus = 4
        memory = 4096
        disk = 40
        # user_data_file = "hbz.yaml"
        ip = "10.254.23.250"
    }
]