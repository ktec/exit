defmodule Sup do
  use Supervisor

  def start_link(opts \\ []) do
    children = [
      {Server, opts}
    ]

    Supervisor.start_link(__MODULE__, children)
  end

  def init(opts) do
    Supervisor.init(opts, strategy: :one_for_all)
  end
end
