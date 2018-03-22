defmodule RealTimeBattleBot.BotHandler do
  @moduledoc "handling all interactions with the Bot."

  use GenServer
  alias RealTimeBattleBot.Protocol
  alias RealTimeBattleBot.BotContext
  alias RealTimeBattleBot.Logger

  def start_link(_, opts \\ []) do

    {:ok, bot_pid} = GenServer.start_link(YourBot, nil, [])

    GenServer.start_link(__MODULE__, bot_pid, opts)
  end

  def init(bot_pid) do

    Protocol.send_robot_option(0, 0) # Do not send signals
    Protocol.send_robot_option(1, 2) # Send rotateto and sweep direction events
    Protocol.send_robot_option(2, 0) # Do not send SIGUSR
    Protocol.send_robot_option(3, 1) # Use non blocking

    {:ok, %{context: %BotContext{}, bot: bot_pid}}
  end

  def handle_info({:stdin, line}, %{context: context, bot: bot} = state) do

    File.write("bot_stdin.log", "#{String.trim(line)} \n", [:append])

    #Logger.log("DEBUG:  IN #{inspect line}")

    context = with {:ok, data} <- Protocol.parse_line(line) do

      #IO.inspect({line, data})

      case data do
        {:warning, %{message: warning, }} -> Logger.log("WARNING: #{warning}")
        _ -> nil
      end

      context = BotContext.apply(data, context)

      GenServer.cast(bot, {data, context})
      case context do
        %BotContext{exit_robot: true} ->
          Logger.log("Got ExitRobot, stopping erlang runtime...")
          System.stop(0)
        _ -> nil
      end

      context
    else
      _ -> context
    end

    {:noreply, %{state|context: context}}
  end

end
