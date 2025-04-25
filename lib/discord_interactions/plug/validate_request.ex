defmodule DiscordInteractions.Plug.ValidateRequest do
  @moduledoc """
  Validates security headers in Discord interaction requests.
  """

  @behaviour Plug

  import DiscordInteractions.Util
  import Plug.Conn

  require Logger

  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(conn, _opts) do
    with {:key, public_key} when public_key != nil <- {:key, Application.get_env(:discord_interactions, :public_key)},
         {:key, {:ok, public_key}} <- {:key, Base.decode16(public_key, case: :mixed)},
         {:body, body} when body != nil <- {:body, conn.assigns[:raw_body]},
         {:headers, [signature]} <- {:headers, get_req_header(conn, "x-signature-ed25519")},
         {:headers, [timestamp]} <- {:headers, get_req_header(conn, "x-signature-timestamp")},
         {:headers, {:ok, signature}} <- {:headers, Base.decode16(signature, case: :mixed)},
         {:valid?, true} <- {:valid?, Ed25519.valid_signature?(signature, timestamp <> body, public_key)}
    do
      conn
    else
      {:key, _} ->
        Logger.error("Discord public key is not configured")
        error(conn, :unauthorized)

      {:body, _} ->
        Logger.error("Could not retrieve cached request body, is the body reader configured?")
        error(conn, :unauthorized)

      {:headers, _} ->
        Logger.warning("Discord interaction request misses required security headers")
        error(conn, :unauthorized)

      {:valid?, _} ->
        Logger.warning("Discord interaction request has invalid signature")
        error(conn, :unauthorized)
    end
  end
end
