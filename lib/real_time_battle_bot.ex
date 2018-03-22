defmodule RealTimeBattleBot do

  use Application

  def start(_type, _args) do
    children = [
      %{
        id: RealTimeBattleBot.BotHandler,
        start: {RealTimeBattleBot.BotHandler, :start_link, [nil, [name: RealTimeBattleBot.BotHandler]]},
      },
      %{
        id: RealTimeBattleBot.StdInReader,
        start: {RealTimeBattleBot.StdInReader, :start_link, [RealTimeBattleBot.BotHandler]}
      },
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

end
