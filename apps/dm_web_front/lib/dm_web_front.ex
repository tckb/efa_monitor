defmodule EfaMonitor.DmFront.Web do
  def controller do
    quote do
      use Phoenix.Controller, namespace: EfaMonitor.DmFront.Web
      import Plug.Conn
      import EfaMonitor.DmFront.Web.Gettext
      import Phoenix.LiveView.Controller, only: [live_render: 3]
      alias EfaMonitor.DmFront.Web.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/dm_web_front/templates",
        namespace: EfaMonitor.DmFront.Web

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import EfaMonitor.DmFront.Web.ErrorHelpers
      import EfaMonitor.DmFront.Web.Gettext
      alias EfaMonitor.DmFront.Web.Router.Helpers, as: Routes
      import Phoenix.LiveView, only: [live_render: 2, live_render: 3]
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import EfaMonitor.DmFront.Web.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
