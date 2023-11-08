defmodule CredstashEx.Credstash do
  alias ExAws.Dynamo
  alias ExAws.KMS

  @default_ddb_table "credential-store"
  @default_initial_version "0000000000000000001"
  @kms_key <<"alias/credstash">>

  def get_secret(name, table, version) do
    #{:ok, ciphertext} = :erlcloud_ddb2.get_item(table, [{"name", {:s, name}}, {"version", {:s, version}}], ddbConfig)
    ciphertext = Dynamo.get_item(table, %{name: name, version: version})
    |> ExAws.request!
    |> Dynamo.decode_item(as: CredstashEx.Db.Secret)
    secret = decrypt_secret(ciphertext)
    #IO.inspect(secret)
  end


  def get_secret(name, table \\ @default_ddb_table) do
    versionResponse = Dynamo.query(table,
      limit: 1,
      key_condition_expression: "#N = :name",
      expression_attribute_names: ["#N": "name"],
      expression_attribute_values: [name: name])
      |> ExAws.request!
      |> Dynamo.decode_item(as: CredstashEx.Db.Secret)
    case(versionResponse) do
      [] ->
        {:notfound, []}
      _ ->
        count = versionResponse.count
        case(count == 0) do
          true ->
            {:notfound, []}
          false ->
            decrypt_secret(hd(Map.get(versionResponse,"Items")))
        end
    end
  end

  def put_secret(name, secret, table \\ @default_ddb_table, version \\ @default_initial_version) do
    data = encrypt_secret(name, secret, version)
    secret_struct = %CredstashEx.Db.Secret{name: data.name, version: data.version, contents: data.contents, digest: data.digest, hmac: data.hmac, key: data.key}
    Dynamo.put_item(table, secret_struct) |> ExAws.request!
    #ddbResponse = :erlcloud_ddb2.put_item(table, data, [], ddbConfig)
  end


  def encrypt_secret(name, plaintext, version \\ @default_initial_version) do
    kmsKey = @kms_key
    numberOfBytes = 64
    kmsResponse = KMS.generate_data_key(kmsKey, [number_of_bytes: numberOfBytes, encryption_context: %{}])
    |> ExAws.request!
    IO.inspect(kmsResponse)
    wrappedKey = Map.get(kmsResponse, "CiphertextBlob")
    plaintext = Map.get(kmsResponse, "Plaintext")
    IO.inspect(plaintext)
    dataKey = :binary.part(plaintext, 0, 32)
    hmacKey = :binary.part(plaintext, 32, byte_size(plaintext) - byte_size(dataKey))
    ivec = <<1::128>>
    text = :crypto.crypto_one_time(:aes_ctr, dataKey, ivec, plaintext, [{:encrypt,:true}] )
    digest = :crypto.mac(:hmac, :sha256, hmacKey, text)
    b64Hmac = hexlify(digest)
    data = %{name: name, version: version, key: wrappedKey, contents: :base64.encode(text), hmac: b64Hmac, digest: "SHA256"}
    data
  end

  defp decrypt_secret(ciphertext) do
    keyBase64 = ciphertext.key
    hmac = ciphertext.hmac
    contents = ciphertext.contents
    kMS_Response = KMS.decrypt(keyBase64, [])
    |> ExAws.request!
    plaintext = Base.decode64!(Map.get(kMS_Response, "Plaintext"))
    dataKey = :binary.part(plaintext, 0, 32)
    hmacKey = :binary.part(plaintext, 32, byte_size(plaintext) - byte_size(dataKey))
    decodedContents = :base64.decode(contents)
    digest = :crypto.mac(:hmac, :sha256, hmacKey, decodedContents)
    hexDigest = hexlify(digest)
    case(hmac == hexDigest) do
      false ->
        {:error, :io_lib.format('Computed HMAC does not match stored HMAC', [])}
      true ->
        ivec = <<1::128>>
        text = :crypto.crypto_one_time(:aes_ctr, dataKey, ivec, decodedContents, [{:encrypt,:false}] )
        text
    end
  end

  defp hexlify(bin) when is_binary(bin) do
    for(<<h::4, l :: 4 <- bin>>, into: <<>>, do: <<hex(h), hex(l)>>)
  end


  defp hex(c) when c < 10 do
  ?0 + c
  end

  defp hex(c) do
  ?a + c - 10
  end
end
