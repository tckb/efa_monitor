defmodule DmScenicFront do
  @moduledoc """
  Starter application using the Scenic framework.
  """

  def start(_type, _args) do
    # load the viewport configuration from config
    main_viewport_config = Application.get_env(:dm_scenic_front, :viewport)

    # start the application with the viewport
    children = [
      DmScenicFront.Sensor.Supervisor,
      {Scenic, viewports: [main_viewport_config]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
