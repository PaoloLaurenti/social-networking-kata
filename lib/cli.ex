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
  alias SocialNetworkingKata.Time.UTCClock

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
            |> to_text(clock)
            |> Enum.each(&IO.puts/1)
          end

          {action, :loop}
      end

    :ok = social_network_action.()

    if next_op == :loop do
      loop(social_network, clock)
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

  defp to_text(:ok), do: [""]

  defp to_text({:ok, timeline = %Timeline{}}, clock) do
    timeline.messages
    |> Enum.sort_by(& &1.sent_at, {:desc, DateTime})
    |> Enum.map(fn m -> to_text(m, clock) end)
  end

  defp to_text(%Message{} = message, clock) do
    {:ok, now} = clock.get_current_datetime()

    seconds_ago =
      (DateTime.diff(now, message.sent_at, :millisecond) / 1000)
      |> Float.ceil()
      |> trunc

    {time_ago, unit} =
      cond do
        seconds_ago == 86_400 ->
          {1, "day"}

        seconds_ago > 86_400 ->
          days_ago = (seconds_ago / 86_400) |> Float.ceil() |> trunc
          {days_ago, "days"}

        seconds_ago == 3600 ->
          {1, "hour"}

        seconds_ago > 3600 ->
          hours_ago = (seconds_ago / 3600) |> Float.ceil() |> trunc
          {hours_ago, "hours"}

        seconds_ago == 60 ->
          {1, "minute"}

        seconds_ago > 60 ->
          minutes_ago = (seconds_ago / 60) |> Float.ceil() |> trunc
          {minutes_ago, "minutes"}

        seconds_ago == 1 ->
          {seconds_ago, "second"}

        true ->
          {seconds_ago, "seconds"}
      end

    "#{message.text} (#{time_ago} #{unit} ago)"
  end
end
