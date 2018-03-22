defmodule RealTimeBattleBot.Logger do

  @logfile "bot.log"

  def log(message) when is_binary(message) do
    File.write(@logfile, "#{message}\n", [:append])
  end

  def log(message) do
    File.write(@logfile, "#{inspect message}\n", [:append])
  end

end