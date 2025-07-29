package test.abcmotor.msvc_sales.models.entities;

public class Item {

    private ProductDTO product;
    private int quantity;

    public Item(ProductDTO product, int quantity) {
        this.product = product;
        this.quantity = quantity;
    }

    public ProductDTO getProduct() {
        return product;
    }

    public void setProduct(ProductDTO product) {
        this.product = product;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Double getTotal() {
        if (product == null) {
            return 0.0;
        }
        double priceWithDiscount = product.getPrice() * (1 - product.getDiscount());
        return priceWithDiscount * quantity;
    }

    public Double getIva() {
        return getTotal() * 0.15;
    }

    // Métodos adicionales útiles
    public Double getOriginalTotal() {
        if (product == null) {
            return 0.0;
        }
        return product.getPrice() * quantity;
    }

    public Double getTotalDiscount() {
        if (product == null) {
            return 0.0;
        }
        return (product.getPrice() * product.getDiscount()) * quantity;
    }

    public Double getTotalWithIva() {
        return getTotal() + getIva();
    }

}
