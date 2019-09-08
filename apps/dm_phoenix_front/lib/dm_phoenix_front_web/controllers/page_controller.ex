defmodule EfaMonitor.DmPhxWeb.PageController do
  use EfaMonitor.DmPhxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
