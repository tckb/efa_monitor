defmodule EfaMonitor.DmFront.Web.Router do
  use EfaMonitor.DmFront.Web, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {EfaMonitor.DmFront.Web.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EfaMonitor.DmFront.Web do
    pipe_through :browser
    live "/", DmLive
  end
end
