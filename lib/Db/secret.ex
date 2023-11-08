defmodule CredstashEx.Db.Secret do
  @derive [ExAws.Dynamo.Encodable]
  defstruct [:name, :version, :contents, :digest, :hmac, :key]
end
