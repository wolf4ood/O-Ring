defmodule ExRing do
  @moduledoc """
  Elixir implementation of Ring Exercise
  """

  def start(n, m) do
    t0 = Time.utc_now()

    {creation_time, ring} = create_ring(n)
    run(ring, m)

    t1 = Time.utc_now()
    IO.puts("#{creation_time} #{Time.diff(t1, t0, :millisecond)} #{n} #{m}")
  end

  def run(_ring, 0), do: 0
  def run(ring, step) do
    send(ring, 0)
    receive do
      _ -> run(ring, step - 1)
    end
  end

  @spec create_ring(number) :: {number, pid}
  def create_ring(n) do
    t0 = Time.utc_now()
    ring = chain(self(), n)
    t1 = Time.utc_now()
    {Time.diff(t1, t0, :millisecond), ring}
  end


  #******************* HELPERS *******************

  @spec chain(pid, number) :: pid
  defp chain(parent, 0), do: parent
  defp chain(parent, n) do
    parent
    |> node_spawn()
    |> chain(n - 1)
  end

  defp node_spawn(dst) do
    spawn(__MODULE__, :process_node, [dst])
  end

  # process node function:
  # take a message and send it to destination node
  def process_node(dst) do
    receive do
      msg ->
        send(dst, msg+1)
    end
    process_node(dst)
  end
end
