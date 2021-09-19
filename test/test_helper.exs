ExUnit.start()

Application.ensure_all_started(:mox)

Mox.defmock(SystemMock, for: MockBehaviourSystem)
