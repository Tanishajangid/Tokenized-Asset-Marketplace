module Marketplace::TokenizedAssets {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a tokenized asset for sale
    struct Asset has store, key {
        price: u64,         // Price of the asset in AptosCoin
        owner: address,     // Current owner of the asset
    }

    /// Function to tokenize and list an asset for sale
    public entry fun list_asset(owner: &signer, price: u64) {
        let asset = Asset {
            price,
            owner: signer::address_of(owner)
        };
        move_to(owner, asset);
    }

    /// Function to buy a tokenized asset
    public entry fun buy_asset(buyer: &signer, seller: address, amount: u64) acquires Asset {
        let asset = borrow_global_mut<Asset>(seller);
        
        // Ensure the buyer sends the correct amount
        assert!(amount >= asset.price, 1001); // Error code for insufficient payment
        
        // Transfer payment from buyer to seller
        let payment = coin::withdraw<AptosCoin>(buyer, asset.price);
        coin::deposit<AptosCoin>(seller, payment);

        // Transfer ownership to buyer
        asset.owner = signer::address_of(buyer);
    }
}
