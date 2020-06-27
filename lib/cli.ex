defmodule SocialNetworkingKata.Cli do
  @moduledoc """
  The Cli of the Social Network
  """
  alias SocialNetworkingKata.Message
  alias SocialNetworkingKata.Message
  alias SocialNetworkingKata.Messages.PublishCommand
  alias SocialNetworkingKata.User
  alias SocialNetworkingKata.UTCClock
  alias SocialNetworkingKata.VolatileSocialNetwork

  @spec main(args :: keyword()) :: :ok
  def main(args) do
    social_network = Keyword.get(args, :social_network, VolatileSocialNetwork)
    clock = Keyword.get(args, :clock, UTCClock)
    loop(social_network, clock)
    IO.puts("bye")
  end

  @spec loop(social_network :: Module, clock :: Module) :: nil
  defp loop(social_network, clock) do
    text_cmd = IO.gets("") |> String.trim()
    cmd = parse(text_cmd, clock)

    case cmd do
      {:cmd, cmd} ->
        _result = social_network.run(cmd)
        loop(social_network, clock)

      :not_recognized ->
        IO.puts("sorry \"#{text_cmd}\" is an unknown command")
        loop(social_network, clock)

      :exit ->
        nil
    end
  end

  @spec parse(text_command :: String.t(), clock :: Module) ::
          {:cmd, PublishCommand.t()} | :exit | :not_recognized
  defp parse(text_command, clock) do
    publish_message_data =
      Regex.named_captures(~r/^(?<name>[^\s]+)\s->\s(?<text>.+)$/, text_command)

    cond do
      publish_message_data != nil ->
        {:cmd,
         PublishCommand.new!(
           user: User.new!(name: publish_message_data["name"]),
           message:
             Message.new!(
               text: publish_message_data["text"],
               sent_at: clock.get_current_datetime()
             )
         )}

      text_command == "exit" ->
        :exit

      true ->
        :not_recognized
    end
  end
end
