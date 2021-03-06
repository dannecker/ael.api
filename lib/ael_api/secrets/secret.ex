defmodule Ael.Secrets.Secret do
  @moduledoc false

  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :action, :string
    field :bucket, :string
    field :resource_id, :string
    field :resource_name, :string
    field :content_type, :string, default: ""
    field :secret_url, :string

    field :expires_at, :utc_datetime
    field :inserted_at, :utc_datetime
  end
end
