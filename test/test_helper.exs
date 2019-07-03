Logger.remove_backend(:console)
ExUnit.configure(exclude: [:pending, :integration])

ExUnit.start()
