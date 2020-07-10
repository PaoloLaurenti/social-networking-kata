defmodule SocialNetworkingKata.ServicesNamesResolver do
  @moduledoc """
  The module that provides the names of the processes that are running inside the system
  """
  alias SocialNetworkingKata.Registry, as: SocialNetworkRegistry

  @spec get_name(module :: module(), id :: any()) ::
          {:via, Registry, {SocialNetworkRegistry, {module(), any}}}
  def get_name(module, id) do
    {:via, Registry, {SocialNetworkRegistry, {module, id}}}
  end
end
