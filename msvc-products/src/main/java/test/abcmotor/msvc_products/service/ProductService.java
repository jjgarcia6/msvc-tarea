package test.abcmotor.msvc_products.service;

import java.util.List;
import java.util.Optional;

import org.springframework.web.multipart.MultipartFile;

import test.abcmotor.msvc_products.models.entities.Product;

public interface ProductService {
    String importProductsFromFile(MultipartFile file);

    List<Product> findAll();

    Optional<Product> findById(String id);

    Product create(Product product);

    Optional<Product> update(String id, Product product);

    boolean delete(String id);
}
