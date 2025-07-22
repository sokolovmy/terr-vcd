
routed_network_name = "10_254_23_0_24"

vapp_name = "NetPlan Voyager"


vms = [
    {
        name = "dev-npvgr-app-01"
        cpus = 4
        memory = 4096
        disk = 40
        user_data_file = "user-data.yaml"
        ip = "10.254.23.240"
    },
    {
        name = "dev-npvgr-app-02"
        cpus = 4
        memory = 4096
        disk = 40
        user_data_file = "user-data.yaml"
        ip = "10.254.23.241"
    }
]