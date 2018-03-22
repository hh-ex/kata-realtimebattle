defmodule RealTimeBattleBot.BotContext do
  @moduledoc "Context with aggregated data send by RTB program."

  defstruct [
    initialized: false,
    first_sequence: false,
    name: "",
    colour: "",
    game_options: %{},
    energy: nil,
    robots_left: nil,
    dead: false,
    game_started: false,
    game_finished: false,
    exit_robot: false,
    coordinates: %{angle: 0, x: 0, y: 0},
    canon_angle: false,
    speed: false,
    time: false,
    last_radar: false,
    last_robot_info: false,
  ]

  def apply({:init, %{first_sequence: first_sequence}}, %__MODULE__{} = state) do
    %__MODULE__{state|initialized: true, first_sequence: first_sequence}
  end

  def apply({:your_name, name}, %__MODULE__{} = state) do
    %__MODULE__{state|name: name}
  end

  def apply({:your_colour, colour}, %__MODULE__{} = state) do
    %__MODULE__{state|colour: colour}
  end

  def apply({:game_option, %{option: option, value: value}}, %__MODULE__{game_options: game_options} = state) do
    %__MODULE__{state|game_options: Map.put(game_options, option, value)}
  end

  def apply(:game_starts, %__MODULE__{} = state) do
    %__MODULE__{state|game_started: true}
  end

  def apply({:energy, energy}, %__MODULE__{} = state) do
    %__MODULE__{state|energy: energy}
  end

  def apply({:robots_left, robots_left}, %__MODULE__{} = state) do
    %__MODULE__{state|robots_left: robots_left}
  end

  def apply(:dead, %__MODULE__{} = state) do
    %__MODULE__{state|dead: true}
  end

  def apply(:game_finishes, %__MODULE__{} = state) do
    %__MODULE__{state|game_finished: true}
  end

  def apply(:exit_robot, %__MODULE__{} = state) do
    %__MODULE__{state|exit_robot: true}
  end

  def apply({:coordinates, %{angle: 0, x: 0, y: 0}}, %__MODULE__{} = state) do
    %__MODULE__{state|coordinates: %{angle: 0, x: 0, y: 0}}
  end

  def apply({:info, %{canon_angle: canon_angle, speed: speed, time: time}}, %__MODULE__{} = state) do
    %__MODULE__{state|canon_angle: canon_angle, speed: speed, time: time}
  end

  def apply({:radar, radar}, %__MODULE__{} = state) do
    %__MODULE__{state|last_radar: radar}
  end

  def apply({:robot_info, robot_info}, %__MODULE__{} = state) do
    %__MODULE__{state|last_robot_info: robot_info}
  end

  def apply(_, %__MODULE__{} = state), do: state

end
