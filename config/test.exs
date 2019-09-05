use Mix.Config

config :efa_core, :api_config, %{
  vrr: {:http, "efa.vrr.de", "/standard/XSLT_DM_REQUEST"},
  vvs: {:http, "www2.vvs.de", "/vvs/XSLT_DM_REQUEST"},
  mvv: {:https, "efa.mvv-muenchen.de", "/mobile/XSLT_DM_REQUEST"},
  nvbw: {:http, "www.efa-bw.de", "/nvbw/XSLT_DM_REQUEST"},
  rta_chicago: {:http, "tripplanner.rtachicago.com", "/ccg3/XSLT_DM_REQUEST"}
}
