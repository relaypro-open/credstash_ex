defmodule CredstashEx do
  @requirements ["app.config"]
  @moduledoc """
  Documentation for `CredstashEx`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> CredstashEx.hello()
      :world

  """
  def hello do
    :world
  end

  def run(args) do
    CredstashEx.Credstash.get_secret("sendgrid_alert_username")
    # do work
  end
end
