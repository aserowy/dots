{ config, pkgs, ... }:
{
    services.telegraf = {
        enable = true;
        extraConfig = {
            agent = {
                interval = "10s";
                metric_batch_size = 1000;
                metric_buffer_limit = 10000;
            };
            inputs = {
                cpu = {
                    totalcpu = true;
                    percpu = true;
                    collect_cpu_time = false;
                    report_active = false;
                };
                disk = {};
                kernel = {};
                mem = {};
                swap = {};
                system = {};
            };
            outputs = {
                influxdb_v2 = {
                    organization = "athome";
                    bucket = "telegraf";
                    token = "$TOKEN";
                    urls = [
                        "http://localhost:8127"
                    ];
                };
            };
        };
        environmentFiles = [
            "/srv/telegraf/telegraf.env"
        ];
    };
}
