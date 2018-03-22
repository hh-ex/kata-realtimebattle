defmodule RealTimeBattleBot.StdInReader do
  @moduledoc "Reading from Stdout and forwarding via messages."

  use GenServer

  def start_link(receiver) do
    GenServer.start_link(__MODULE__, receiver)
  end

  def init(receiver) do
    {:ok, receiver, 0} # Send a :timeout message immediatly
  end

  def handle_info(:timeout, receiver) do

    # Read from stdin and forward line
    case read() do
      {:ok, line} -> send(receiver, {:stdin, line})
      _error -> nil
    end

    {:noreply, receiver, 0} # Loop using :timeout messages.
  end

  # Read a single line from stdin.
  defp read do
    case IO.read(:stdio, :line) do
      :eof -> {:error, :eof}
      {:error, reason} -> {:error, reason}
      line -> {:ok, line}
    end
  end

end
