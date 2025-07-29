package test.abcmotor.msvc_products.repository;

import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

import test.abcmotor.msvc_products.models.entities.Product;

public interface ProductRepository extends MongoRepository<Product, String> {
    // Custom query methods can be defined here if needed

    // Method to find product by name (to check for duplicates)
    Optional<Product> findByName(String name);

    // Method to check if product exists by name
    boolean existsByName(String name);

}