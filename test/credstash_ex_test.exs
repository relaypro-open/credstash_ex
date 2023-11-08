defmodule CredstashExTest do
  alias CredstashEx.Credstash
  use ExUnit.Case
  doctest CredstashEx

  test "encrypt_decrypt" do
    name = "Test"
    secret = "1234567890abcdef"
    version = "1.0"
    encrypted = CredstashEx.Credstash.encrypt_secret(name, secret, version)
    decrypted = CredstashEx.Credstash.decrypt_secret(encrypted)
    assert decrypted == secret
  end

end
