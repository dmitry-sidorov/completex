defmodule Completex.Repo do
  use Ecto.Repo,
    otp_app: :completex,
    adapter: Ecto.Adapters.Postgres
end
