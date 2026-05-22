package com.noahstudio.model;

/**
 * VideographyPackage — Specific implementation for cinematic video services.
 */
public class VideographyPackage extends ServicePackage {

    public VideographyPackage() {
        super();
        setType("videography");
    }

    public VideographyPackage(String id, String name, double price,
                             String duration, String features,
                             String description, boolean active) {
        super(id, name, price, duration, features, description, active, "videography");
    }

    @Override
    public double getDiscountedPrice(String membershipLevel) {
        if ("Gold".equalsIgnoreCase(membershipLevel)) {
            return getPrice() * 0.90; // 10% discount for Gold members (Video is more expensive, higher incentive)
        } else if ("Platinum".equalsIgnoreCase(membershipLevel)) {
            return getPrice() * 0.85; // 15% discount for Platinum members
        }
        return getPrice();
    }
}
