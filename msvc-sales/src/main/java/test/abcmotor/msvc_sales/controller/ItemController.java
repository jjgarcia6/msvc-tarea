package test.abcmotor.msvc_sales.controller;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import test.abcmotor.msvc_sales.models.entities.Item;
import test.abcmotor.msvc_sales.services.ItemService;

@RestController
@RequestMapping("api/item")
public class ItemController {

    private final ItemService itemService;

    public ItemController(ItemService itemService) {
        this.itemService = itemService;
    }

    @GetMapping()
    public List<Item> getAllItems() {
        return itemService.getAllItems();
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getItemById(@PathVariable String id) {
        System.err.println("ID DEL PATH");
        System.err.println(id);
        Optional<Item> item = itemService.getItemById(id);
        if (item.isPresent()) {
            return ResponseEntity.ok(item.get());
        } else {
            return ResponseEntity.status(404)
                    .body(Collections.singletonMap("message", "The product doesn't exist in the microservice"));
        }
    }

    @PostMapping()
    public ResponseEntity<?> createItem(@RequestParam String productId, @RequestParam int quantity) {
        try {
            Optional<Item> item = itemService.getItemById(productId);
            if (item.isPresent()) {
                Item newItem = new Item(item.get().getProduct(), quantity);
                return ResponseEntity.status(HttpStatus.CREATED).body(newItem);
            } else {
                return ResponseEntity.status(404)
                        .body(Collections.singletonMap("message", "Product not found"));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("error", "Error creating item: " + e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateItem(@PathVariable String id, @RequestParam int quantity) {
        try {
            Optional<Item> existingItem = itemService.getItemById(id);
            if (existingItem.isPresent()) {
                Item item = existingItem.get();
                item.setQuantity(quantity);
                return ResponseEntity.ok(item);
            } else {
                return ResponseEntity.status(404)
                        .body(Collections.singletonMap("message", "Item not found"));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("error", "Error updating item: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteItem(@PathVariable String id) {
        try {
            Optional<Item> item = itemService.getItemById(id);
            if (item.isPresent()) {
                return ResponseEntity.ok()
                        .body(Collections.singletonMap("message", "Item deleted successfully"));
            } else {
                return ResponseEntity.status(404)
                        .body(Collections.singletonMap("message", "Item not found"));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("error", "Error deleting item: " + e.getMessage()));
        }
    }

    @GetMapping("/{id}/total")
    public ResponseEntity<?> getItemTotal(@PathVariable String id) {
        Optional<Item> item = itemService.getItemById(id);
        if (item.isPresent()) {
            return ResponseEntity.ok(Collections.singletonMap("total", item.get().getTotal()));
        } else {
            return ResponseEntity.status(404)
                    .body(Collections.singletonMap("message", "Item not found"));
        }
    }

    @GetMapping("/{id}/total-with-iva")
    public ResponseEntity<?> getItemTotalWithIva(@PathVariable String id) {
        Optional<Item> item = itemService.getItemById(id);
        if (item.isPresent()) {
            return ResponseEntity.ok(Collections.singletonMap("totalWithIva", item.get().getTotalWithIva()));
        } else {
            return ResponseEntity.status(404)
                    .body(Collections.singletonMap("message", "Item not found"));
        }
    }

    @GetMapping("/{id}/discount")
    public ResponseEntity<?> getItemDiscount(@PathVariable String id) {
        Optional<Item> item = itemService.getItemById(id);
        if (item.isPresent()) {
            return ResponseEntity.ok(Collections.singletonMap("totalDiscount", item.get().getTotalDiscount()));
        } else {
            return ResponseEntity.status(404)
                    .body(Collections.singletonMap("message", "Item not found"));
        }
    }

}
