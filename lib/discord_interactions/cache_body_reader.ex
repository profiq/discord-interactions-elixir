defmodule DiscordInteractions.CacheBodyReader do
  @moduledoc """
  Plug.Parsers body reader implementation which caches the request body
  in `conn.assigns[:raw_body]`.
  """

  @doc """
  `Plug.Conn.read_body/2` wrapper which stores the retrieved body
  in `conn.assigns[:raw_body]`.
  """
  @spec read_body(Plug.Conn.t(), Keyword.t()) ::
          {:ok, binary(), Plug.Conn.t()} | {:more, binary(), Plug.Conn.t()} | {:error, term()}
  def read_body(conn, opts) do
    with {:ok, body, conn} <- Plug.Conn.read_body(conn, opts) do
      conn = update_in(conn.assigns[:raw_body], &[body | &1 || []])
      {:ok, body, conn}
    end
  end
end
