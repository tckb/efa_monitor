defmodule EfaMonitor.DmFront.Web.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """
  require Logger

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.source.errors, field), fn {msg, opts} ->
      error_message =
        case opts do
          [validation: :inclusion, enum: available_opts] ->
            options =
              available_opts
              |> Enum.map(fn x ->
                x
                |> String.downcase(:ascii)
              end)
              |> Enum.join(", ")

            msg <> ", Available options: " <> options

          _ ->
            msg
        end

      content_tag(:div, error_message,
        class: "alert alert-danger container-fluid",
        role: "alert",
        data: [phx_error_for: input_id(form, field)]
      )
    end)
  end
end
