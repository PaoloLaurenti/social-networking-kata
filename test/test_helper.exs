Application.ensure_all_started(:mox)
Mox.defmock(SocialNetworkServerMock, for: SocialNetworkingKata.SocialNetwork)
Mox.defmock(ClockMock, for: SocialNetworkingKata.Clock)
ExUnit.start()
