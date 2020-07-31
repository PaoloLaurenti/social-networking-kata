defmodule SocialNetworkingKata.Cli do
  @moduledoc """
  The Cli of the Social Network
  """
  alias SocialNetworkingKata.Social.Following.FollowUserRequest
  alias SocialNetworkingKata.Social.Messages.Message
  alias SocialNetworkingKata.Social.Publishing.Message, as: MessageToPublish
  alias SocialNetworkingKata.Social.Publishing.PublishMessageRequest
  alias SocialNetworkingKata.Social.SocialNetwork
  alias SocialNetworkingKata.Social.Timeline
  alias SocialNetworkingKata.Social.Timeline.GetTimelineRequest
  alias SocialNetworkingKata.Social.VolatileSocialNetwork
  alias SocialNetworkingKata.Social.Wall
  alias SocialNetworkingKata.Social.Wall.Entry
  alias SocialNetworkingKata.Social.Wall.GetWallRequest
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

        {:req, %FollowUserRequest{} = req} ->
          action = fn ->
            social_network.follow_user(req)
            |> to_text
            |> Enum.each(&IO.puts/1)
          end

          {action, :loop}

        {:req, %GetWallRequest{} = req} ->
          action = fn ->
            social_network.get_wall(req)
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

    follow_user_data =
      Regex.named_captures(~r/^(?<follower>.+)\sfollows\s(?<followee>.+)$/, text_command)

    get_wall_data = Regex.named_captures(~r/^(?<name>[^\s]+)\swall$/, text_command)

    cond do
      text_command == "exit" ->
        :exit

      publish_message_data != nil ->
        {:req,
         PublishMessageRequest.new!(
           username: publish_message_data["name"],
           message: MessageToPublish.new!(text: publish_message_data["text"])
         )}

      get_timeline_data != nil ->
        {:req, GetTimelineRequest.new!(username: get_timeline_data["name"])}

      follow_user_data != nil ->
        {:req,
         FollowUserRequest.new!(
           followee: follow_user_data["followee"],
           follower: follow_user_data["follower"]
         )}

      get_wall_data != nil ->
        {:req, GetWallRequest.new!(username: get_wall_data["name"])}

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

    secs_to_text =
      secs_to_text_config()
      |> Enum.find(fn secs_to_text -> secs_to_text.predicate.(seconds_ago) end)

    {time_ago, unit} = secs_to_text.apply.(seconds_ago)
    "#{message.text} (#{time_ago} #{unit} ago)"
  end

  defp to_text({:ok, %Wall{} = wall}, clock) do
    wall.entries
    |> Enum.sort_by(& &1.message.sent_at, {:desc, DateTime})
    |> Enum.map(fn m -> to_text(m, clock) end)
  end

  defp to_text(%Entry{user: user, message: message}, clock) do
    {:ok, now} = clock.get_current_datetime()

    seconds_ago =
      (DateTime.diff(now, message.sent_at, :millisecond) / 1000)
      |> Float.ceil()
      |> trunc

    secs_to_text =
      secs_to_text_config()
      |> Enum.find(fn secs_to_text -> secs_to_text.predicate.(seconds_ago) end)

    {time_ago, unit} = secs_to_text.apply.(seconds_ago)
    "#{user.name} - #{message.text} (#{time_ago} #{unit} ago)"
  end

  defp secs_to_text_config do
    [
      %{
        predicate: fn secs_ago -> secs_ago == 86_400 end,
        apply: fn _secs_ago -> {1, "day"} end
      },
      %{
        predicate: fn secs_ago -> secs_ago > 86_400 end,
        apply: fn secs_ago -> {to_time_ago(secs_ago, 86_400), "days"} end
      },
      %{
        predicate: fn secs_ago -> secs_ago == 3600 end,
        apply: fn _secs_ago -> {1, "hour"} end
      },
      %{
        predicate: fn secs_ago -> secs_ago > 3600 end,
        apply: fn secs_ago -> {to_time_ago(secs_ago, 3600), "hours"} end
      },
      %{
        predicate: fn secs_ago -> secs_ago == 60 end,
        apply: fn _secs_ago -> {1, "minute"} end
      },
      %{
        predicate: fn secs_ago -> secs_ago > 60 end,
        apply: fn secs_ago -> {to_time_ago(secs_ago, 60), "minutes"} end
      },
      %{
        predicate: fn secs_ago -> secs_ago == 1 end,
        apply: fn _secs_ago -> {1, "second"} end
      },
      %{
        predicate: fn _secs_ago -> true end,
        apply: fn secs_ago -> {secs_ago, "seconds"} end
      }
    ]
  end

  defp to_time_ago(secs_ago, threshold_secs) do
    (secs_ago / threshold_secs) |> Float.ceil() |> trunc
  end
end
