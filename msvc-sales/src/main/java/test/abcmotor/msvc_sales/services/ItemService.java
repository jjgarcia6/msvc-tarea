package test.abcmotor.msvc_sales.services;

import java.util.List;
import java.util.Optional;

import test.abcmotor.msvc_sales.models.entities.Item;

public interface ItemService {

    List<Item> getAllItems();

    Optional<Item> getItemById(String id);

}