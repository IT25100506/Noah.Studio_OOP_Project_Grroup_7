package com.noahstudio.model;

/**
 * PhotographyPackage — Specific implementation for photography services.
 */
public class PhotographyPackage extends ServicePackage {

    public PhotographyPackage() {
        super();
        setType("photography");
    }

    public PhotographyPackage(String id, String name, double price,
                             String duration, String features,
                             String description, boolean active) {
        super(id, name, price, duration, features, description, active, "photography");
    }

    @Override
    public double getDiscountedPrice(String membershipLevel) {
        if ("Gold".equalsIgnoreCase(membershipLevel)) {
            return getPrice() * 0.95; // 5% discount for Gold members
        } else if ("Platinum".equalsIgnoreCase(membershipLevel)) {
            return getPrice() * 0.90; // 10% discount for Platinum members
        }
        return getPrice();
    }
}
