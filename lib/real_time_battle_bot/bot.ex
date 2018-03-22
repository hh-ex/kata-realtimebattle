defmodule RealTimeBattleBot.Bot do

  defmacro __using__(_opts) do
    quote do

      use GenServer
      alias RealTimeBattleBot.Protocol, as: P
      alias RealTimeBattleBot.Logger, as: L

      def handle_cast({message, context}, state) do
        #IO.inspect([:cast, {message, context}, state], label: :handle_cast)

        handle_message(message, context, state) #|> IO.inspect(label: :handle_message_return)
        {:noreply, state}
      end

      # Implement this function in your bot
      def handle_message(_message, _context, _state), do: :ok

      defoverridable [handle_message: 3]
    end
  end

end