# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :coincoin_blockchain, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:coincoin_blockchain, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :coincoin_blockchain,
  port: String.to_integer(System.get_env("P2P_PORT") || "5000"),
  proof_of_work: Coincoin.Blockchain.ProofOfWork

# around 3 seconds for a 132_904 hash/s
config :coincoin_blockchain, Coincoin.Blockchain.ProofOfWork,
  target: "00000C6D750EBFA67C0000000000000000000000000000000000000000000000"

import_config "#{Mix.env()}.exs"
