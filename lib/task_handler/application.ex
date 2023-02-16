defmodule TaskHandler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TaskHandlerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TaskHandler.PubSub},
      # Start the Endpoint (http/https)
      TaskHandlerWeb.Endpoint
      # Start a worker by calling: TaskHandler.Worker.start_link(arg)
      # {TaskHandler.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TaskHandler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TaskHandlerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
