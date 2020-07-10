defmodule SocialNetworkingKata.Cli do
  @moduledoc """
  The Cli of the Social Network
  """
  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Publishing.Message, as: MessageToPublish
  alias SocialNetworkingKata.Social.Publishing.PublishMessageRequest
  alias SocialNetworkingKata.Social.SocialNetwork
  alias SocialNetworkingKata.Social.Timeline
  alias SocialNetworkingKata.Social.Timeline.GetTimelineRequest
  alias SocialNetworkingKata.Social.Users.User
  alias SocialNetworkingKata.Social.VolatileSocialNetwork

  @spec main(args :: keyword()) :: :ok
  def main(args \\ []) do
    social_network = Keyword.get(args, :social_network, VolatileSocialNetwork)
    loop(social_network)
    IO.puts("bye")
  end

  @spec loop(social_network :: Module) :: nil
  defp loop(social_network) do
    text_cmd = IO.gets("") |> String.trim()
    request = parse(text_cmd)

    {social_network_action, next_op} =
      case request do
        :not_recognized ->
          action = fn -> IO.puts("sorry \"#{text_cmd}\" is an unknown command") end
          {action, :loop}

        :exit ->
          action = fn -> :ok end
          {action, :stop}

        {:req, %PublishMessageRequest{} = req} ->
          action = fn ->
            social_network.publish_message(req)
            |> to_text
            |> Enum.each(&IO.puts/1)
          end

          {action, :loop}

        {:req, %GetTimelineRequest{} = req} ->
          action = fn ->
            social_network.get_timeline(req)
            |> to_text
            |> Enum.each(&IO.puts/1)
          end

          {action, :loop}
      end

    :ok = social_network_action.()

    if next_op == :loop do
      loop(social_network)
    else
      nil
    end
  end

  @spec parse(text_command :: String.t()) ::
          {:req, SocialNetwork.requests()} | :exit | :not_recognized
  defp parse(text_command) do
    publish_message_data =
      Regex.named_captures(~r/^(?<name>[^\s]+)\s->\s(?<text>.+)$/, text_command)

    get_timeline_data = Regex.named_captures(~r/^(?<name>[^\s]+)$/, text_command)

    cond do
      text_command == "exit" ->
        :exit

      publish_message_data != nil ->
        {:req,
         PublishMessageRequest.new!(
           user: User.new!(name: publish_message_data["name"]),
           message: MessageToPublish.new!(text: publish_message_data["text"])
         )}

      get_timeline_data != nil ->
        {:req, GetTimelineRequest.new!(user: User.new!(name: get_timeline_data["name"]))}

      true ->
        :not_recognized
    end
  end

  @spec to_text(SocialNetwork.requests() | Message.t()) :: String.t() | [String.t(), ...]
  defp to_text(:ok), do: [""]

  defp to_text({:ok, timeline = %Timeline{}}) do
    timeline.messages
    |> Enum.sort_by(fn m -> m.sent_at end, :desc)
    |> Enum.map(&to_text/1)
  end

  defp to_text(%Message{} = message) do
    minutes_ago =
      (DateTime.diff(DateTime.now!("Etc/UTC"), message.sent_at, :millisecond) / 60_000)
      |> Float.ceil()
      |> trunc

    minute_s =
      if minutes_ago == 1 do
        "minute"
      else
        "minutes"
      end

    "#{message.text} (#{minutes_ago} #{minute_s} ago)"
  end
end
