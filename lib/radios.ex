defmodule Radios do
  @moduledoc """
  Module that implements database like functionality for writing
  information about radios.
  """

  use Agent

  def start_link(opts) do
    Agent.start_link(fn -> %{} end, opts)
  end

  @doc """
  Stores information about a radio.
  Returns `:ok`
  """
  @spec store(Agent.agent(), integer(), String.t(), list(String.t())) :: :ok
  def store(radio_store, id, radio_alias, locations) do
    Agent.update(radio_store, fn state ->
      Map.put(state, id, {radio_alias, MapSet.new(locations), :undefined})
    end)
  end

  @doc """
  Sets the current location for a radio
  Returns `:ok` if the location change is allowed, `:forbidden` otherwise.
  """
  @spec set_location(Agent.agent(), integer(), String.t()) :: :ok | :forbidden
  def set_location(radio_store, id, new_loc) do
    Agent.get_and_update(radio_store, fn state ->
      if Map.has_key?(state, id) do
        {radio_alias, locs, _} = Map.get(state, id)

        # Check is the new location is amoung the allowed ones
        if MapSet.member?(locs, new_loc) do
          {:ok, Map.put(state, id, {radio_alias, locs, new_loc})}
        else
          {:forbidden, state}
        end
      else
        {:forbidden, state}
      end
    end)
  end


  @doc """
  Gets the current location for a radio
  Returns `{:ok, s}` if the location for radio `id` is set, `:notfound` otherwise.
  """
  @spec get_location(Agent.agent(), integer()) :: {:ok, String.t()} | :notfound
  def get_location(radio_store, id) do
    Agent.get(radio_store, fn state ->
      case Map.get(state, id) do
        nil -> :notfound
        {_, _, :undefined} -> :notfound
        {_, _, loc} -> {:ok, loc}
      end
    end)
  end
end
