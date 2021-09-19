ExUnit.start()

Application.ensure_all_started(:mox)

Mox.defmock(FinchMock, for: MockBehaviourFinch)
Mox.defmock(SystemMock, for: MockBehaviourSystem)
