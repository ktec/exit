defmodule Server do
  use GenServer, restart: :transient

  def child_spec(arg) do
    %{
      id: Server,
      start: {Server, :start_link, [arg]}
    }
  end

  def start_link(opts \\ %{}) do
    IO.inspect(opts, label: "Server.start_link")
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(args) do
    Process.flag(:trap_exit, true)
    pid = self()

    state =
      %{monitor: Keyword.fetch!(args, :monitor)}
      |> IO.inspect(label: "Server.init #{inspect(pid)}")

    {:ok, state}
  end

  # If we trap exits, this will be called
  def handle_info({:EXIT, from, reason}, state) do
    IO.inspect({{from, reason}, state}, label: "Server.handle_info/2 exit 1")
    {:stop, reason, state}
  end

  def handle_info(:bye, state) do
    IO.inspect(state, label: "Server.handle_info/2 bye")
    Process.exit(self(), :normal)
    {:noreply, state}
  end

  def handle_info(:die, state) do
    IO.inspect(state, label: "Server.handle_info/2 die")
    Process.exit(self(), :kill)
    {:noreply, state}
  end

  def handle_info(:stop, state) do
    IO.inspect(state, label: "Server.handle_info/2 stop")
    {:stop, :normal, state}
  end

  def terminate(reason, state) do
    IO.inspect({reason, state}, label: "Server.terminate")
    cleanup(reason, state)
    :ok
  end

  def cleanup(reason, state) do
    send(state.monitor, {:goodbye, reason})
  end
end
