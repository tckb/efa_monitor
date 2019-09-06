use Mix.Config

# api configs for the transport authority in Germany
# dm: departure monitor
config :dm_core, :api, %{
  vrr: %{
    scheme: :http,
    host: "efa.vrr.de",
    apis: %{
      dm: "/standard/XSLT_DM_REQUEST"
    }
  },
  vvs: %{
    scheme: :http,
    host: "www2.vvs.de",
    apis: %{
      dm: "/vvs/XSLT_DM_REQUEST"
    }
  },
  mvv: %{
    scheme: :https,
    host: "efa.mvv-muenchen.de",
    apis: %{
      dm: "/mobile/XSLT_DM_REQUEST"
    }
  },
  nvbw: %{
    scheme: :http,
    host: "www.efa-bw.de",
    apis: %{
      dm: "/nvbw/XSLT_DM_REQUEST"
    }
  },
  rta_chicago: %{
    scheme: :http,
    host: "tripplanner.rtachicago.com",
    apis: %{
      dm: "/ccg3/XSLT_DM_REQUEST"
    }
  }
}
