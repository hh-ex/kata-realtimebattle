defmodule YourBot do

  use RealTimeBattleBot.Bot

  # Customize your bot here
  @name "lol123"
  @color_home  "FF0000"
  @color_away  "00FF00"


  def init(_) do
    # Prepare some other stuff you need for your bot here, like a state different from :state
    {:ok, :state}
  end

  def handle_message({:init,  %{first_sequence: true}}, _context, _state) do
    # Starting the sequence of games
    L.log("INIT SEQUENCE")
    P.send_name(@name)
    P.send_colour(@color_home, @color_away)
  end

  def handle_message(:game_starts, _context, _state) do
    # Starting a single game, make your first moves
    L.log("GAME STARTS")

    P.send_sweep([:radar, :cannon], 10.0, -1.0, 1.0)
    P.send_rotate(:robot, 5.0)

    drive_fast()
  end

  def handle_message({:radar, %{object_type: :wall, distance: distance}}, _context, _state) when distance < 1 do
    L.log("Braking for wall")
    drive_slow()
    steer_left()
  end
  def handle_message({:radar, %{object_type: :wall, distance: distance}}, _context, _state) when distance >= 1 do
    drive_fast()
  end
  def handle_message({:radar, %{object_type: :cookie, radar_angle: radar_angle}}, _context, _state)  do
    L.log("Trying to eat the cookie")
    drive_normal()
    P.send_rotate_amount(:robot, 5.0, radar_angle)
  end
  def handle_message({:radar, %{object_type: _, distance: _}}, _context, _state)  do
    # Your radar has detected something.
    # If its another robot, a :robot_info will follow.
  end

  def handle_message({:robot_info, %{energy_level: _, teammate: false}}, _context, _state) do
    # There is a robot in front of you.
    L.log("Shooting at enemy robot")
    P.send_shoot(2.0)
    drive_fast()
  end


  def handle_message({:collision, %{angle: _, object_type: type, object_type_id: _}}, _context, _state) do
    L.log("Got hit by a #{inspect type}")
  end

  # Available but not really needed callbacks.
  def handle_message({:rotation_reached, %{what_id: _, what_list: _}}, _context, _state), do: nil
  def handle_message({:robots_left, _}, _context, _state), do: nil
  def handle_message({:energy, _}, _context, _state), do: nil
  def handle_message({:coordinates, %{angle: _, x: _, y: _}}, _context, _state), do: nil
  def handle_message({:info, %{canon_angle: _, speed: _, time: _}}, _context, _state), do: nil
  def handle_message({:game_option, %{option: _, value: _}}, _context, _state), do: nil
  def handle_message({:warning, %{message: _}}, _context, _state), do: nil

  def handle_message(message, context, state) do
    L.log("Not handling message you might want to know about.")
    L.log(message)
    L.log(context)
    L.log(state)
  end

  # Helper functions

  defp drive_slow() do
    P.send_brake(80.0)
    P.send_accelerate(0.1)
  end

  defp drive_normal() do
    P.send_brake(60.0)
    P.send_accelerate(0.3)
  end

  defp drive_fast() do
    P.send_brake(0.0)
    P.send_accelerate(1.0)
  end

  defp steer_left() do
    P.send_rotate(:robot, 2.0)
  end

end