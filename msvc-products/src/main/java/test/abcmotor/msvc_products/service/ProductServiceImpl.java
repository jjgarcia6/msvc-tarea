package test.abcmotor.msvc_products.service;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.opencsv.CSVReader;

import test.abcmotor.msvc_products.models.entities.Product;
import test.abcmotor.msvc_products.repository.ProductRepository;

@Service
public class ProductServiceImpl implements ProductService {

    private ProductRepository productRepository;
    private Environment environment;

    public ProductServiceImpl(ProductRepository productRepository, Environment environment) {
        this.productRepository = productRepository;
        this.environment = environment;
    }

    @Override
    public String importProductsFromFile(MultipartFile file) {
        String fileName = file.getOriginalFilename();
        if (fileName == null) {
            return "File name is null";
        }
        try {
            InputStream inputStream = file.getInputStream();
            if (fileName.endsWith(".csv")) {
                return importProductsFromCSV(inputStream);
            }
            if (fileName.endsWith(".xlsx")) {
                return importProductsFromExcel(inputStream);
            }
            return "The file format is not supported. Please upload a CSV or Excel file.";
        } catch (Exception e) {
            e.printStackTrace();
            return "An error occurred while processing the file: " + e.getMessage();
        }
    }

    private String importProductsFromCSV(InputStream inputStream) {
        try (CSVReader reader = new CSVReader(new InputStreamReader(inputStream))) {
            String[] headers = reader.readNext();
            if (headers == null) {
                return "CSV file mustn't contain header required";
            }

            int nameIndex = -1;
            int descriptionIndex = -1;
            int priceIndex = -1;
            int stockIndex = -1;
            int imageIndex = -1;
            int platformsIndex = -1;
            int genresIndex = -1;
            int discountIndex = -1;
            int developerIndex = -1;
            int publisherIndex = -1;
            int releaseDateIndex = -1;

            System.err.println("Headers: " + String.join(", ", headers));

            for (int i = 0; i < headers.length; i++) {
                switch (headers[i].trim().toLowerCase()) {
                    case "name":
                        nameIndex = i;
                        break;
                    case "description":
                        descriptionIndex = i;
                        break;
                    case "price":
                        priceIndex = i;
                        break;
                    case "stock":
                        stockIndex = i;
                        break;
                    case "image":
                        imageIndex = i;
                        break;
                    case "platforms":
                        platformsIndex = i;
                        break;
                    case "genres":
                        genresIndex = i;
                        break;
                    case "discount":
                        discountIndex = i;
                        break;
                    case "developer":
                        developerIndex = i;
                        break;
                    case "publisher":
                        publisherIndex = i;
                        break;
                    case "release_date":
                        releaseDateIndex = i;
                        break;
                }
            }

            System.err.println("Indices - Name: " + nameIndex + ", Description: " + descriptionIndex +
                    ", Price: " + priceIndex + ", Stock: " + stockIndex + ", Image: " + imageIndex +
                    ", Platforms: " + platformsIndex + ", Genres: " + genresIndex + ", Discount: " + discountIndex +
                    ", Developer: " + developerIndex + ", Publisher: " + publisherIndex + ", Release Date: "
                    + releaseDateIndex);

            if (nameIndex == -1 || descriptionIndex == -1 || priceIndex == -1 || stockIndex == -1 ||
                    imageIndex == -1 || platformsIndex == -1 || genresIndex == -1 || discountIndex == -1 ||
                    developerIndex == -1 || publisherIndex == -1 || releaseDateIndex == -1) {
                return "CSV file mustn't contain header required";
            }

            List<Product> products = new ArrayList<>();
            List<String> duplicatedProducts = new ArrayList<>();
            String[] line;

            while ((line = reader.readNext()) != null) {
                String productName = line[nameIndex].trim();

                // Check if product already exists in database
                if (productRepository.existsByName(productName)) {
                    duplicatedProducts.add(productName);
                    continue; // Skip this product
                }

                // Check if product is already in the current import list
                boolean alreadyInList = products.stream()
                        .anyMatch(p -> p.getName().equalsIgnoreCase(productName));

                if (alreadyInList) {
                    duplicatedProducts.add(productName + " (duplicate in file)");
                    continue; // Skip this product
                }

                Product product = new Product();
                product.setName(productName);
                product.setDescription(line[descriptionIndex].trim());
                product.setImage(line[imageIndex].trim());
                product.setPlatforms(line[platformsIndex].trim());
                product.setGenres(line[genresIndex].trim());
                product.setDeveloper(line[developerIndex].trim());
                product.setPublisher(line[publisherIndex].trim());
                try {
                    product.setPrice(Double.parseDouble(line[priceIndex].trim()));
                    product.setDiscount(Double.parseDouble(line[discountIndex].trim()));
                } catch (NumberFormatException e) {
                    product.setPrice(0.0);
                    product.setDiscount(0.0);
                }
                try {
                    product.setStock(Integer.parseInt(line[stockIndex].trim()));
                } catch (NumberFormatException e) {
                    product.setStock(0);
                }
                try {
                    SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
                    product.setRelease_date(dateFormat.parse(line[releaseDateIndex].trim()));
                } catch (Exception e) {
                    product.setRelease_date(null);
                }
                products.add(product);
            }

            productRepository.saveAll(products);

            // Build response message
            StringBuilder response = new StringBuilder();
            response.append("Products imported: ").append(products.size());

            if (!duplicatedProducts.isEmpty()) {
                response.append(". Duplicates skipped (").append(duplicatedProducts.size()).append("): ");
                response.append(String.join(", ", duplicatedProducts));
            }

            return response.toString();

        } catch (Exception e) {
            e.printStackTrace();
            return "Error importing products from CSV: " + e.getMessage();
        }
    }

    private String importProductsFromExcel(InputStream inputStream) {
        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet sheet = workbook.getSheetAt(0);
            if (sheet == null) {
                return "The file Excel is empty ";
            }

            Row headerRow = sheet.getRow(0);
            if (headerRow == null) {
                return "The Excel file doesn't have a header.";
            }

            int columns = headerRow.getPhysicalNumberOfCells();
            int nameIdx = -1, descIdx = -1, priceIdx = -1, stockIdx = -1,
                    imageIdx = -1, platformsIdx = -1, genresIdx = -1, discountIdx = -1,
                    developerIdx = -1, publisherIdx = -1, releaseDateIndex = -1;

            for (int i = 0; i < columns; i++) {
                String value = headerRow.getCell(i).getStringCellValue().trim().toLowerCase();
                switch (value) {
                    case "name":
                        nameIdx = i;
                        break;
                    case "description":
                        descIdx = i;
                        break;
                    case "price":
                        priceIdx = i;
                        break;
                    case "stock":
                        stockIdx = i;
                        break;
                    case "image":
                        imageIdx = i;
                        break;
                    case "platforms":
                        platformsIdx = i;
                        break;
                    case "genres":
                        genresIdx = i;
                        break;
                    case "discount":
                        discountIdx = i;
                        break;
                    case "developer":
                        developerIdx = i;
                        break;
                    case "publisher":
                        publisherIdx = i;
                        break;
                    case "release_date":
                        releaseDateIndex = i;
                        break;
                }
            }

            if (nameIdx == -1 || descIdx == -1 || priceIdx == -1 || stockIdx == -1 ||
                    imageIdx == -1 || platformsIdx == -1 || genresIdx == -1 || discountIdx == -1 ||
                    developerIdx == -1 || publisherIdx == -1 || releaseDateIndex == -1) {
                return "The file mustn't contain columns required: name, description, price, stock";
            }

            List<Product> products = new ArrayList<>();
            List<String> duplicatedProducts = new ArrayList<>();

            for (int r = 1; r <= sheet.getLastRowNum(); r++) {
                Row row = sheet.getRow(r);
                if (row == null)
                    continue;

                String productName = getCellString(row, nameIdx);

                // Check if product already exists in database
                if (productRepository.existsByName(productName)) {
                    duplicatedProducts.add(productName);
                    continue; // Skip this product
                }

                // Check if product is already in the current import list
                boolean alreadyInList = products.stream()
                        .anyMatch(p -> p.getName().equalsIgnoreCase(productName));

                if (alreadyInList) {
                    duplicatedProducts.add(productName + " (duplicate in file)");
                    continue; // Skip this product
                }

                Product product = new Product();
                product.setName(productName);
                product.setDescription(getCellString(row, descIdx));
                product.setPrice(getCellDouble(row, priceIdx));
                product.setStock((int) getCellDouble(row, stockIdx));
                product.setImage(getCellString(row, imageIdx));
                product.setPlatforms(getCellString(row, platformsIdx));
                product.setGenres(getCellString(row, genresIdx));
                product.setDiscount(getCellDouble(row, discountIdx));
                product.setDeveloper(getCellString(row, developerIdx));
                product.setPublisher(getCellString(row, publisherIdx));
                product.setRelease_date(getCellDate(row, releaseDateIndex));
                products.add(product);
            }

            productRepository.saveAll(products);

            // Build response message
            StringBuilder response = new StringBuilder();
            response.append("Products imported: ").append(products.size());

            if (!duplicatedProducts.isEmpty()) {
                response.append(". Duplicates skipped (").append(duplicatedProducts.size()).append("): ");
                response.append(String.join(", ", duplicatedProducts));
            }

            return response.toString();
        } catch (Exception ex) {
            ex.printStackTrace();
            return "Error processing the Excel file: " + ex.getMessage();
        }
    }

    private String getCellString(Row row, int idx) {
        Cell cell = row.getCell(idx);
        if (cell == null)
            return "";
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                return String.valueOf(cell.getNumericCellValue());
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                return cell.getCellFormula();
            case BLANK:
            default:
                return "";
        }
    }

    private double getCellDouble(Row row, int idx) {
        Cell cell = row.getCell(idx);
        if (cell == null)
            return 0.0;
        if (cell.getCellType() == CellType.NUMERIC) {
            return cell.getNumericCellValue();
        } else if (cell.getCellType() == CellType.STRING) {
            try {
                return Double.parseDouble(cell.getStringCellValue());
            } catch (NumberFormatException e) {
                return 0.0;
            }
        }
        return 0.0;
    }

    private Date getCellDate(Row row, int idx) {
        Cell cell = row.getCell(idx);
        if (cell == null)
            return null;

        if (cell.getCellType() == CellType.NUMERIC) {
            // Si es una fecha de Excel (número serial)
            try {
                return cell.getDateCellValue();
            } catch (Exception e) {
                return null;
            }
        } else if (cell.getCellType() == CellType.STRING) {
            // Si es un string, intentar parsearlo
            try {
                SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
                return dateFormat.parse(cell.getStringCellValue().trim());
            } catch (Exception e) {
                // Si falla con dd-MM-yyyy, intentar con yyyy-MM-dd
                try {
                    SimpleDateFormat dateFormat2 = new SimpleDateFormat("yyyy-MM-dd");
                    return dateFormat2.parse(cell.getStringCellValue().trim());
                } catch (Exception e2) {
                    return null;
                }
            }
        }
        return null;
    }

    @Override
    public List<Product> findAll() {
        return (productRepository.findAll().stream().map(product -> {
            product.setPort(Integer.parseInt(environment.getProperty("local.server.port")));
            return product;
        }).collect(Collectors.toList()));
    }

    @Override
    public Optional<Product> findById(String id) {
        return productRepository.findById(id);
    }

    @Override
    public Product create(Product product) {
        return productRepository.save(product);
    }

    @Override
    public Optional<Product> update(String id, Product product) {
        return productRepository.findById(id)
                .map(existing -> {
                    existing.setName(product.getName());
                    existing.setDescription(product.getDescription());
                    existing.setPrice(product.getPrice());
                    existing.setStock(product.getStock());
                    existing.setImage(product.getImage());
                    existing.setPlatforms(product.getPlatforms());
                    existing.setGenres(product.getGenres());
                    existing.setDiscount(product.getDiscount());
                    existing.setDeveloper(product.getDeveloper());
                    existing.setPublisher(product.getPublisher());
                    existing.setRelease_date(product.getRelease_date());
                    return productRepository.save(existing);
                });
    }

    @Override
    public boolean delete(String id) {
        if (!productRepository.existsById(id))
            return false;
        productRepository.deleteById(id);
        return true;
    }

}