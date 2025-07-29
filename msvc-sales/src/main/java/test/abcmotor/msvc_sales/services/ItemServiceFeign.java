package test.abcmotor.msvc_sales.services;

import java.util.List;
import java.util.Optional;
import java.util.Random;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import feign.FeignException;
import test.abcmotor.msvc_sales.client.ProductFeignClient;
import test.abcmotor.msvc_sales.models.entities.Item;
import test.abcmotor.msvc_sales.models.entities.ProductDTO;

@Service
public class ItemServiceFeign implements ItemService {

    @Autowired
    private ProductFeignClient productFeignClient;

    @Override
    public List<Item> getAllItems() {
        return productFeignClient.getAllProducts()
                .stream()
                .map(product -> new Item(product, new Random().nextInt(10) + 1))
                .collect(Collectors.toList());

    }

    @Override
    public Optional<Item> getItemById(String id) {
        try {
            ProductDTO product = productFeignClient.getProductById(id);
            return Optional.of(new Item(product, new Random().nextInt(10) + 1));
        } catch (FeignException e) {
            return Optional.empty();
        }
    }

}
