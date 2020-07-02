defmodule SocialNetworkingKata.Cli do
  @moduledoc """
  The Cli of the Social Network
  """
  alias SocialNetworkingKata.Message
  alias SocialNetworkingKata.Message
  alias SocialNetworkingKata.Messages.GetTimelineCommand
  alias SocialNetworkingKata.Messages.PublishCommand
  alias SocialNetworkingKata.SocialNetwork
  alias SocialNetworkingKata.Timeline
  alias SocialNetworkingKata.User
  alias SocialNetworkingKata.UTCClock
  alias SocialNetworkingKata.VolatileSocialNetwork

  @spec main(args :: keyword()) :: :ok
  def main(args \\ []) do
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
        social_network.run(cmd)
        |> to_text
        |> Enum.each(&IO.puts/1)

        loop(social_network, clock)

      :not_recognized ->
        IO.puts("sorry \"#{text_cmd}\" is an unknown command")
        loop(social_network, clock)

      :exit ->
        nil
    end
  end

  @spec parse(text_command :: String.t(), clock :: Module) ::
          {:cmd, SocialNetwork.commands()} | :exit | :not_recognized
  defp parse(text_command, clock) do
    publish_message_data =
      Regex.named_captures(~r/^(?<name>[^\s]+)\s->\s(?<text>.+)$/, text_command)

    get_timeline_data = Regex.named_captures(~r/^(?<name>[^\s]+)$/, text_command)

    cond do
      text_command == "exit" ->
        :exit

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

      get_timeline_data != nil ->
        {:cmd, GetTimelineCommand.new!(user: User.new!(name: get_timeline_data["name"]))}

      true ->
        :not_recognized
    end
  end

  @spec to_text(SocialNetwork.commands() | Message.t()) :: String.t() | [String.t(), ...]
  defp to_text(:ok), do: [""]

  defp to_text({:ok, timeline = %Timeline{}}) do
    timeline.messages
    |> Enum.sort_by(fn m -> m.sent_at end, :desc)
    |> Enum.map(&to_text/1)
  end

  defp to_text(%Message{} = message) do
    minutes_ago =
      (DateTime.diff(DateTime.now!("Etc/UTC"), message.sent_at) / 60) |> Float.ceil() |> trunc

    minute_s =
      if minutes_ago == 1 do
        "minute"
      else
        "minutes"
      end

    "#{message.text} (#{minutes_ago} #{minute_s} ago)"
  end
end
