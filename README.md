# CredstashEx

An Elixir implementation of [Credstash](https://github.com/fugue/credstash), a system to store
secrets securely using AWS infrastructure (KMS+DynoDB).

## Installation

The package can be installed
by adding `credstash_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:credstash_ex, git: ""https://github.com/relaypro-open/credstash_ex.git, tag: "0.1.0"}
  ]
end
```

## Configuration

Configure your AWS credentials as specified in [ex_aws](https://hexdocs.pm/ex_aws/readme.html)

## Use

```elixir
alias CredstashEx.Credstash
Credstash.put_secret("test_secret","one2three","credential-store")
Credstash.get_secret("test_secret","credential-store")        
"one2three"
```
