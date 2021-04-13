defmodule ApiBanking.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ApiBanking.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ApiBanking.PubSub}
      # Start a worker by calling: ApiBanking.Worker.start_link(arg)
      # {ApiBanking.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ApiBanking.Supervisor)
  end
end
