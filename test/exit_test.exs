defmodule ExitTest do
  use ExUnit.Case
  doctest Exit

  setup _ do
    {:ok, sup} = Sup.start_link(monitor: self())
    # assert is_pid(sup)
    # assert Process.alive?(sup)

    [{Server, pid, :worker, [Server]}] = Supervisor.which_children(sup)

    %{pid: pid, sup: sup}
  end

  # normal exits

  test "when sup is stopped", %{pid: pid, sup: sup} do
    Process.exit(sup, :normal)

    assert_receive {:goodbye, :shutdown}
  end

  test "when process is stopped", %{pid: pid, sup: sup} do
    Process.exit(pid, :normal)

    assert_receive {:goodbye, :normal}
  end

  test "when process exits itself", %{pid: pid, sup: sup} do
    send(pid, :bye)

    assert_receive {:goodbye, :normal}
  end

  test "when process stops itself", %{pid: pid, sup: sup} do
    send(pid, :stop)

    assert_receive {:goodbye, :normal}
  end

  # :brutal_kills

  test "when process kills itself ", %{pid: pid, sup: sup} do
    send(pid, :die)

    refute_receive :goodbye
  end

  test "when process is killed", %{pid: pid, sup: sup} do
    Process.exit(pid, :kill)

    refute_receive :goodbye
  end
end
