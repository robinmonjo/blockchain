defmodule Coincoin.Blockchain do
  @moduledoc """
  Documentation for Blockchain.
  """

  alias Coincoin.Blockchain.{Chain, P2P.Client, P2P.Command, P2P.Peers}

  # add a block to the blockchain
  @spec add(Coincoin.Blockchain.BlockData.t()) :: :ok | {:error, String.t()}
  def add(data), do: Command.broadcast_mining_request(data)

  # connect to an existing peer
  @spec connect(String.t() | integer) :: :ok | {:error, atom()}
  def connect(uri) do
    case Client.connect(uri) do
      {:ok, socket} ->
        Command.ask_all_blocks(socket)

      error ->
        error
    end
  end

  # list connected peers
  @spec peers() :: [%{address: String.t(), port: integer}]
  def peers do
    Enum.map(Peers.get_all(), fn p ->
      {:ok, {addr, port}} = :inet.peername(p)

      address =
        addr
        |> :inet_parse.ntoa()
        |> to_string()

      %{address: address, port: port}
    end)
  end

  # returns all blocks
  @spec blocks() :: [Coincoin.Blockchain.Block.t()]
  def blocks do
    Chain.all_blocks()
  end
end
