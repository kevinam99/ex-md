defmodule MarkdownEditor.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MarkdownEditorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MarkdownEditor.PubSub},
      # Start the Agent for state management
      {Agent, fn -> %{} end, name: MarkdownEditor.DocumentStore},
      # Start the Endpoint (http/https)
      MarkdownEditorWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MarkdownEditor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MarkdownEditorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
