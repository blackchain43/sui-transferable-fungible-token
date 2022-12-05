// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Example coin with a trusted manager responsible for minting/burning (e.g., a stablecoin)
/// By convention, modules defining custom coin types use upper case names, in contrast to
/// ordinary modules, which use camel case.
module usdt::usdt {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::pay;
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    /// Name of the coin. By convention, this type has the same name as its parent module
    /// and has no fields. The full type of the coin defined by this module will be `COIN<R1COIN>`.
    struct USDT has drop {}

    /// For when empty vector is supplied into join function.
    const ENoCoins: u64 = 0;
    /// Register the RCOIN currency to acquire its `TreasuryCap`. Because
    /// this is a module initializer, it ensures the currency only gets
    /// registered once.
    fun init(witness: USDT, ctx: &mut TxContext) {
        // Get a treasury cap for the coin 
        let (treasury_cap, metadata) = coin::create_currency<USDT>(witness, 9, b"USDT", b"", b"", option::none(),ctx);
        // Make it a share object so that anyone can mint
        transfer::share_object(metadata);
        transfer::transfer(treasury_cap, tx_context::sender(ctx))
        
    } 


    // public entry fun transfer(coin: &mut Coin<USDT>, amount: u64, recipient: address, ctx: &mut TxContext) {
    //   pay::split_and_transfer(coin, amount, recipient, ctx)
    // }
    public entry fun transfer<T>(coins: vector<coin::Coin<T>>, amount: u64, recipient: address, ctx: &mut TxContext) {
      assert!(vector::length(&coins) > 0, ENoCoins);
      let coin = vector::pop_back(&mut coins);
      pay::join_vec(&mut coin, coins);
      pay::split_and_transfer<T>(&mut coin, amount, recipient, ctx);
      transfer::transfer(coin, tx_context::sender(ctx))
    }

    public entry fun mint(
        treasury_cap: &mut TreasuryCap<USDT>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }
}
