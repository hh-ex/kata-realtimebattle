defmodule RealTimeBattleBot.Protocol do
  @moduledoc "Protocol for line language by RTB"

  @doc """
  Parsing a line from stdin.

    iex> RealTimeBattleBot.Protocol.parse_line("YourName lol\\n")
    {:ok, {:your_name, "lol"}}

    iex> RealTimeBattleBot.Protocol.parse_line("GameOption 3 1.23\\n")
    {:ok, {:game_option, %{option: 3, value: 1.23}}}

    iex> RealTimeBattleBot.Protocol.parse_line("Radar 1.23 3 98.765\\n")
    {:ok, {:radar,
             %{distance: 1.23, object_type: :cookie, object_type_id: 3,
               radar_angle: 98.765}}}

    iex> RealTimeBattleBot.Protocol.parse_line("Info 1.2 3.4 5.6\\n")
    {:ok, {:info, %{canon_angle: 5.6, speed: 3.4, time: 1.2}}}
  """
  def parse_line(line) do
    line
    |> String.trim()
    |> parse
  end

  def send_robot_option(option, value) when is_integer(option) and is_integer(value) do
    send_line("RobotOption #{option} #{value}")
  end

  def send_name(name) when is_binary(name) do
    send_line("Name #{name}")
  end

  def send_colour(home_colour, away_color) when is_binary(home_colour) and is_binary(away_color) do
    send_line("Colour #{home_colour} #{away_color}")
  end

  @doc """
    what is a list or single value of  :radar, :cannon or :robot
  """
  def send_rotate(what, velocity_rad) when is_float(velocity_rad) do
    send_line("Rotate #{what_to_rotate(what)} #{velocity_rad}")
  end

  # Can only rotate cannon and radar, NOT robot.
  def send_rotate_to(what, velocity_rad, angle_move_to_rad) when is_float(velocity_rad) and is_float(angle_move_to_rad) do
    send_line("RotateTo #{what_to_rotate(what)} #{velocity_rad} #{angle_move_to_rad}")
  end

  def send_rotate_amount(what, velocity_rad, angle_rotate_to_rad) when is_float(velocity_rad) and is_float(angle_rotate_to_rad) do
    send_line("RotateAmount #{what_to_rotate(what)} #{velocity_rad} #{angle_rotate_to_rad}")
  end

  # What can be :radar and/or :cannon
  def send_sweep(what, velocity_rad, angle_left_rad, angle_right_rad) when is_float(velocity_rad) and is_float(angle_left_rad) and is_float(angle_right_rad) do
    send_line("Sweep #{what_to_rotate(what)} #{velocity_rad} #{angle_left_rad} #{angle_right_rad}")
  end

  def send_accelerate(accelerate) when is_float(accelerate) do
    send_line("Accelerate #{accelerate}")
  end

  def send_brake(percent) when is_float(percent) do
    send_line("Brake #{min(max(percent, 0), 1)}")
  end

  def send_shoot(energy) when is_float(energy) do
    send_line("Shoot #{energy}")
  end

  def send_print(message) when is_binary(message) do
    send_line("Print #{message}")
  end

  def send_debug(message) when is_binary(message) do
    send_line("Debug #{message}")
  end

  #-------


  defp send_line(line) do
    # Simply write to stdout, where rtb will read our message.
    #RealTimeBattleBot.Logger.log("DEBUG: OUT #{inspect line}")
    IO.write "#{line} \r\n"
  end

  defp parse("Initialize 0"), do: {:ok, {:init, %{first_sequence: false}}}
  defp parse("Initialize 1"), do: {:ok, {:init, %{first_sequence: true}}}

  defp parse(<<"YourName ", name::binary>>), do: {:ok, {:your_name, name}}
  defp parse(<<"YourColour ", colour::binary>>), do: {:ok, {:your_colour, colour}}

  defp parse(<<"GameOption ", game_option::binary>>) do
    [option, value] = String.split(game_option, " ")
    {:ok, {:game_option, %{
      option: String.to_integer(option),
      value: safe_to_float(value),
    }}}
  end

  defp parse("GameStarts"), do: {:ok, :game_starts}
  # This message is sent when the game starts (surprise!)

  defp parse(<<"Radar ", radar::binary>>) do
    [distance, object_type, radar_angle] = String.split(radar, " ")
    object_type_id = safe_to_integer(object_type)
    {:ok, {:radar, %{
      distance: safe_to_float(distance),
      object_type: object_type(object_type_id),
      object_type_id: object_type_id,
      radar_angle: safe_to_float(radar_angle),
    }}}
  end

  defp parse(<<"Info ", info::binary>>) do
    [time, speed, cannon_angle] = String.split(info, " ")
    {:ok, {:info, %{
      time: safe_to_float(time),
      speed: safe_to_float(speed),
      canon_angle: safe_to_float(cannon_angle),
    }}}
  end

  defp parse(<<"Coordinates ", coords::binary>>) do
    [x, y, angle] = String.split(coords, " ")
    {:ok, {:coordinates, %{
      x: safe_to_float(x),
      y: safe_to_float(y),
      angle: safe_to_float(angle),
    }}}
  end

  defp parse(<<"RobotInfo ", info::binary>>) do
    [energy_level, teammate] = String.split(info, " ")
    {:ok, {:robot_info, %{
      energy_level: safe_to_integer(energy_level),
      teammate: safe_to_integer(teammate) == 1,
    }}}
  end

  defp parse(<<"RotationReached ", rotation::binary>>) do
    rotation = safe_to_integer(rotation)
    {:ok, {:rotation_reached, %{
      what_id: rotation,
      what_list: what_to_rotate(rotation),
    }}}
  end

  defp parse(<<"Energy ", energy::binary>>) do
    {:ok, {:energy, safe_to_integer(energy)}}
  end
  # The end of each round the robot will get to know its energy level. It will not, however, get the exact energy, instead it is discretized into a number of energy levels.

  defp parse(<<"RobotsLeft ", left::binary>>) do
    {:ok, {:robots_left, safe_to_integer(left)}}
  end
  # At the beginning of the game and when a robot is killed the number of remaining robots is broadcasted to all living robots.

  defp parse(<<"Collision ", collision::binary>>) do
    [object_type, angle] = String.split(collision, " ")
    object_type_id = safe_to_integer(object_type)
    {:ok, {:collision, %{
      object_type: object_type(object_type_id),
      object_type_id: object_type_id,
      angle: safe_to_float(angle),
    }}}
  end

  defp parse(<<"Warning ", warning::binary>>) do
    {:ok, {:warning, %{
      message: warning,
    }}}
  end

  defp parse("Dead"), do: {:ok, :dead}
  # Robot died. Do not try to send more messages to the server until the end of the game, the server doesn't read them.

  defp parse("GameFinishes"), do: {:ok, :game_finishes}
  # Current game is finished, get prepared for the next!

  defp parse("ExitRobot"), do: {:ok, :exit_robot}
  # Exit from the program immediately! Otherwise it will be killed forcefully.

  defp parse(line), do: {:error, {:unknown_line, line}}


  defp object_type(0), do: :robot
  defp object_type(1), do: :shoot
  defp object_type(2), do: :wall
  defp object_type(3), do: :cookie
  defp object_type(4), do: :mine
  defp object_type(5), do: :last
  defp object_type(_), do: :unknown

  defp what_to_rotate(1), do: [:robot]
  defp what_to_rotate(2), do: [:cannon]
  defp what_to_rotate(3), do: [:robot, :cannon]
  defp what_to_rotate(4), do: [:radar]
  defp what_to_rotate(5), do: [:robot, :radar]
  defp what_to_rotate(6), do: [:cannon, :radar]
  defp what_to_rotate(7), do: [:robot, :cannon, :radar]

  defp what_to_rotate(:robot ), do: 1
  defp what_to_rotate(:cannon), do: 2
  defp what_to_rotate(:radar ), do: 4
  defp what_to_rotate(what) when is_list(what), do: what_to_rotate(what, 0)
  defp what_to_rotate(_), do: []

  defp what_to_rotate([:robot |what], sum), do: what_to_rotate(what, sum+1)
  defp what_to_rotate([:cannon|what], sum), do: what_to_rotate(what, sum+2)
  defp what_to_rotate([:radar |what], sum), do: what_to_rotate(what, sum+4)
  defp what_to_rotate([            ], sum), do: sum

  defp safe_to_integer(string) do
    {integer, _rest} = Integer.parse(string)
    integer
  end

  defp safe_to_float(string) do
    {float, _rest} = Float.parse(string)
    float
  end

end
