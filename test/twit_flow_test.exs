defmodule TwitFlowTest do
  use ExUnit.Case
  doctest TwitFlow

  test "start/2" do
    application =
      TwitFlow.start([], [])
      |> case do
        {:ok, pid} ->
          [true, pid]

        {:error, {:already_started, pid}} ->
          [true, pid]

        _ ->
          false
      end

    assert [true, pid] = application

    pid
    |> case do
      nil -> nil
      pid -> Process.exit(pid, :normal)
    end
  end
end
