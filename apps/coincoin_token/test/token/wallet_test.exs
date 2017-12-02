defmodule Coincoin.Token.Test.WalletTest do
  use ExUnit.Case
  import Coincoin.Token.Test.Fixtures

  alias Coincoin.Token.Wallet

  setup tags do
    if tags[:mock_ledger] do
      {:ok, mock_ledger()}
    else
      {:ok, wallet: Wallet.generate_wallet()}
    end
  end

  test "generate wallet", %{wallet: w} do
    assert w.public_key != nil
    assert w.private_key != nil
    assert byte_size(w.address) == 40
  end

  test "sign and verify data", %{wallet: w} do
    data = "some data to sign"
    signature = Wallet.sign(data, w)
    assert Wallet.verify(data, signature, w)
  end

  @tag mock_ledger: true
  test "balance", %{alice: alice, bob: bob, joe: joe} do
    assert Wallet.balance(alice) == 36
    assert Wallet.balance(bob) == 24
    assert Wallet.balance(joe) == 10
  end

  @tag mock_ledger: true
  test "send", %{alice: alice, bob: bob, joe: joe} do
    compute_balances = fn ->
      for p <- [alice, bob, joe], do: Wallet.balance(p)
    end

    [a0, b0, j0] = compute_balances.()

    # first transaction
    amount = 10
    assert Wallet.send(amount, bob.address, alice) == :ok

    [a1, b1, j1] = compute_balances.()

    # 26
    assert a1 == a0 - amount
    # 34
    assert b1 == b0 + amount
    # 10
    assert j1 == j0

    # second transaction
    amount = 13
    assert Wallet.send(amount, joe.address, alice) == :ok

    [a2, b2, j2] = compute_balances.()

    # 13
    assert a2 == a1 - amount
    # 34
    assert b2 == b1
    # 23
    assert j2 == j1 + amount

    # third transaction
    amount = 1
    assert Wallet.send(amount, bob.address, joe) == :ok

    [a3, b3, j3] = compute_balances.()

    # 13
    assert a3 == a2
    # 35
    assert b3 == b2 + amount
    # 23
    assert j3 == j2 - amount

    # fourth transaction
    amount = 35
    assert Wallet.send(amount, joe.address, bob) == :ok

    [a4, b4, j4] = compute_balances.()

    # 13
    assert a4 == a3
    # 0
    assert b4 == b3 - amount
    # 58
    assert j4 == j3 + amount

    # fifth transaction
    amount = 19
    assert {:error, _reason} = Wallet.send(amount, bob.address, alice)

    [a5, b5, j5] = compute_balances.()

    # 13
    assert a5 == a4
    # 0
    assert b5 == b4
    # 58
    assert j5 == j4

    # sixth transaction
    amount = 29
    assert Wallet.send(amount, bob.address, joe) == :ok

    [a6, b6, j6] = compute_balances.()

    # 13
    assert a6 == a5
    # 29
    assert b6 == b5 + amount
    # 29
    assert j6 == j5 - amount
  end
end
